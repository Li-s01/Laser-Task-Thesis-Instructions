function [fh, statsTable] = peduks_coin_plot_grandAvg_lrTraces_byInstrCond( options, subjectData )
%learning-rate grand average 
%split by instrCond (A=Volatile, B=Noise)  
%   OUT: fh - figure handle
%        statsTable - offsetFromCP, nSub_A, grandMean_A, SEM_A, nSub_B,
%                     grandMean_B, SEM_B

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
subIDs = options.subjectIDs;
nSub = numel(subIDs);

pre  = options.behav.lrPreSamples;
post = options.behav.lrPostSamples;
nCols = pre + post + 1;
sampleOrder = -pre:post;

condIDs = {'A', 'B'};
condNames = {'A (Volatile)', 'B (Noise)'};
nCond = numel(condIDs);

subjMean = nan(nSub, nCols, nCond);

for iSub = 1:nSub
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(subData)
        continue
    end
    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);

    for iC = 1:nCond
        allTraces = [];
        for iB = unique(subData.blockID)'
            if ismember(iB, subExcluded)
                continue
            end
            blockData = subData(subData.blockID == iB, :);
            if isempty(blockData) || ~strcmp(charify(blockData.seqType(1)), 'CP')
                continue
            end
            if ~strcmp(charify(blockData.instrCond(1)), condIDs{iC})
                continue
            end
            [~, lrTraces] = peduks_coin_ELR_per_jump(blockData, options);
            if ~isempty(lrTraces)
                allTraces = [allTraces; lrTraces]; 
            end
        end

        if ~isempty(allTraces)
            subjMean(iSub, :, iC) = mean(allTraces, 1, 'omitnan');
        end
    end
end

col = peduks_coin_colours;
condColors = {col.volatile, col.stable};

% grand mean +/- SEM per condition
grandMean = nan(nCond, nCols);
grandSEM  = nan(nCond, nCols);
nSubValid = nan(nCond, 1);

for iC = 1:nCond
    validSub = ~all(isnan(subjMean(:, :, iC)), 2);
    nSubValid(iC) = sum(validSub);
    grandMean(iC, :) = mean(subjMean(validSub, :, iC), 1, 'omitnan');
    grandSEM(iC, :)  = std(subjMean(validSub, :, iC), 0, 1, 'omitnan') ./ sqrt(nSubValid(iC));
end

fh = figure; hold on;
xline(0, 'LineWidth', 0.5, 'Color', col.medNoise, 'Label', 'changepoint / ELR baseline', ...
    'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'horizontal', 'FontSize', 8);
yline(0);

% background: shaded mean +/- SEM band per condition
xPatch = [sampleOrder, fliplr(sampleOrder)];
for iC = 1:nCond
    yPatch = [grandMean(iC, :) + grandSEM(iC, :), fliplr(grandMean(iC, :) - grandSEM(iC, :))];
    fill(xPatch, yPatch, condColors{iC}, 'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
        'HandleVisibility', 'off');
end

% foreground: bold  mean per condition
legendHandles = gobjects(1, nCond);
legendLabels  = cell(1, nCond);
for iC = 1:nCond
    h1 = plot(sampleOrder, grandMean(iC, :), '-', 'Color', condColors{iC}, 'LineWidth', 3);
    legendHandles(iC) = h1;
    legendLabels{iC} = sprintf('%s mean +/- SEM (n=%d)', condNames{iC}, nSubValid(iC));
end

xlim([-pre 4]);
xlabel('Beam event around changepoint');
ylabel('Average learning rate (clipped)');
title('Peri-changepoint LR grand average by instrCond (mean +/- SEM)');
legend(legendHandles, legendLabels, 'Location', 'best');

% shade the ELR post-window (offset 2-3)
yl = ylim;
hWin = fill([2 3 3 2], [yl(1) yl(1) yl(2) yl(2)], [0.85 0.7 0.1], ...
    'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
uistack(hWin, 'bottom');
ylim(yl);
text(2.5, yl(2) - 0.05*(yl(2)-yl(1)), 'ELR post-window', 'HorizontalAlignment', 'center', ...
    'FontSize', 8, 'Color', [0.5 0.4 0.05]);

hold off;

if exist('cleanUpFig', 'file')
    fh = cleanUpFig(fh);
end

offsetFromCP = sampleOrder';
statsTable = table(offsetFromCP, ...
    repmat(nSubValid(1), nCols, 1), grandMean(1, :)', grandSEM(1, :)', ...
    repmat(nSubValid(2), nCols, 1), grandMean(2, :)', grandSEM(2, :)', ...
    'VariableNames', {'offsetFromCP', 'nSub_A', 'grandMean_A', 'SEM_A', ...
    'nSub_B', 'grandMean_B', 'SEM_B'});

fprintf('\n=== Peri-CP clipped LR by instrCond, mean +/- SEM (window %d to %d) ===\n', -pre, post);
disp(statsTable);

end

function s = charify(x)
if iscell(x), s = char(x{1}); else, s = char(x); end
end
