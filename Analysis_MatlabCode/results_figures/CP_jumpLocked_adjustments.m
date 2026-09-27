function [subjMeans, T] = CP_jumpLocked_adjustments( options, subjectData )
%CP_JUMPLOCKED_ADJUSTMENTS Change-point-locked (jump-locked) plot of shield
%adjustment behaviour in CP blocks, split by instrCond (A vs. B).

%   OUT: subjMeans 
%       T - long-format table, one row per single change point 


if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);

nSamplesBefore = options.behav.adjustPreSamples;
nSamplesAfter  = options.behav.adjustPostSamples;
fsmp           = options.behav.fsample;
nSamples       = nSamplesBefore + nSamplesAfter + 1;
timeAxis       = (-nSamplesBefore:nSamplesAfter) / fsmp;

subIDs = options.subjectIDs;
rows = struct([]);

% per-subject collection of all adjustment trajectories, per instrCond
subjAdjustA = cell(numel(subIDs),1);
subjAdjustB = cell(numel(subIDs),1);

for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(subData)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);

    for iB = unique(subData.blockID)'
        if ismember(iB, subExcluded)
            continue
        end
        blockData = subData(subData.blockID == iB, :);
        if isempty(blockData) || ~strcmp(char(string(blockData.seqType(1))), 'CP')
            continue
        end

        [allAdjust, jumpSize, ~] = peduks_coin_blockAdjustments(blockData, options);
        if isempty(allAdjust)
            continue
        end

        instr = char(string(blockData.instrCond(1)));

        for iJ = 1:size(allAdjust,1)
            row = struct('subID', subID, 'blockID', iB, 'instrCond', string(instr), ...
                'jumpSize', jumpSize(iJ), 'adjust', allAdjust(iJ,:));
            if isempty(rows), rows = row; else, rows(end+1) = row; end
        end

        if strcmp(instr, 'A')
            subjAdjustA{iSub} = [subjAdjustA{iSub}; allAdjust];
        else
            subjAdjustB{iSub} = [subjAdjustB{iSub}; allAdjust];
        end
    end
end

T = struct2table(rows);

% average within subject first then across subjects 
subjMeans.A = nan(numel(subIDs), nSamples);
subjMeans.B = nan(numel(subIDs), nSamples);
for iSub = 1:numel(subIDs)
    if ~isempty(subjAdjustA{iSub})
        subjMeans.A(iSub,:) = mean(subjAdjustA{iSub}, 1, 'omitnan');
    end
    if ~isempty(subjAdjustB{iSub})
        subjMeans.B(iSub,:) = mean(subjAdjustB{iSub}, 1, 'omitnan');
    end
end

% grand average +/- SEM across subjects
meanA = mean(subjMeans.A, 1, 'omitnan');
nA    = sum(~isnan(subjMeans.A(:,1)));
semA  = std(subjMeans.A, 0, 1, 'omitnan') / sqrt(nA);

meanB = mean(subjMeans.B, 1, 'omitnan');
nB    = sum(~isnan(subjMeans.B(:,1)));
semB  = std(subjMeans.B, 0, 1, 'omitnan') / sqrt(nB);

% mean RT per condition, for the vertical reference lines

RTtable = peduks_coin_build_RT_table(options, excludedBlocks, subjectData);

subjRT_A = nan(numel(subIDs),1);
subjRT_B = nan(numel(subIDs),1);
for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    rowsA = RTtable(RTtable.subID == subID & RTtable.instrCond == "A", :);
    rowsB = RTtable(RTtable.subID == subID & RTtable.instrCond == "B", :);
    if ~isempty(rowsA)
        subjRT_A(iSub) = mean(rowsA.rt, 'omitnan');
    end
    if ~isempty(rowsB)
        subjRT_B(iSub) = mean(rowsB.rt, 'omitnan');
    end
end

meanRT_A = mean(subjRT_A, 'omitnan');
meanRT_B = mean(subjRT_B, 'omitnan');

%plot
col = peduks_coin_colours;
colorA = col.volatile;
colorB = col.stable;

figure('Name', 'CP: jump-locked shield adjustment, A vs. B', 'Color', 'w', ...
    'Position', [100 100 700 500]);
hold on


for iSub = 1:numel(subIDs)
    if ~isnan(subjMeans.A(iSub,1))
        hA = plot(timeAxis, subjMeans.A(iSub,:), '-', 'Color', colorA, 'LineWidth', 0.5);
        hA.Color(4) = 0.2;
        hA.HandleVisibility = 'off';
    end
    if ~isnan(subjMeans.B(iSub,1))
        hB = plot(timeAxis, subjMeans.B(iSub,:), '-', 'Color', colorB, 'LineWidth', 0.5);
        hB.Color(4) = 0.2;
        hB.HandleVisibility = 'off';
    end
end

shadedErrorBar(timeAxis, meanA, semA, 'lineprops', {'-', 'Color', colorA, 'LineWidth', 2});
shadedErrorBar(timeAxis, meanB, semB, 'lineprops', {'-', 'Color', colorB, 'LineWidth', 2});

xline(0, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
yline(0, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);

% mean RT per condition, as a vertical reference line
xline(meanRT_A, 'Color', colorA, 'LineStyle', '--', 'LineWidth', 1.5, ...
    'Label', sprintf('mean RT (A) = %.2f s', meanRT_A), ...
    'LabelOrientation', 'horizontal', 'LabelVerticalAlignment', 'top', ...
    'HandleVisibility', 'off');
xline(meanRT_B, 'Color', colorB, 'LineStyle', '--', 'LineWidth', 1.5, ...
    'Label', sprintf('mean RT (B) = %.2f s', meanRT_B), ...
    'LabelOrientation', 'horizontal', 'LabelVerticalAlignment', 'bottom', ...
    'HandleVisibility', 'off');

xlabel('Time from change point (s)');
ylabel({'Shield adjustment (rad)', 'relative to pre-change-point level'});
title(sprintf('CP: adjustment after change points (A: N=%d, B: N=%d subjects)', nA, nB));
xlim([-1 5]);
legend({'A (Volatile)', 'B (Noise)'}, 'Location', 'northwest', 'Box', 'off');
box off
hold off

set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');

end
