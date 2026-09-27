function [statsOut, fh] = peduks_coin_check_lrCutoff_appropriateness( options, subjectData, seqType )
%Checks whether lrCutoff is a good bound for this
%datasetand reports percentiles of
%the pooled raw distribution and the share of
%values the bound clips at each end.
%   IN:  options, subjectData 
%        seqType 
%   OUT: statsOut 
%        fh - histogram of the raw LR distribution with the bound marked

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

if nargin < 3 || isempty(seqType)
    seqType = 'all';
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
subIDs = options.subjectIDs;

allRaw = [];

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
        if isempty(blockData)
            continue
        end
        if ~strcmpi(seqType, 'all') && ~strcmp(charify(blockData.seqType(1)), seqType)
            continue
        end
        [~, ~, LRraw] = peduks_coin_blockLearningRate(blockData, options);
        allRaw = [allRaw; LRraw(:)]; 
    end
end

finiteRaw = allRaw(isfinite(allRaw));
nTotal = numel(allRaw);
nFinite = numel(finiteRaw);

prcs = [1 5 25 50 75 95 99];
prcVals = prctile(finiteRaw, prcs);

fprintf('\n=== Raw LR distribution, ALL beam events, %s blocks (n=%d events, %d finite / %d total) ===\n', ...
    upper(seqType), nFinite, nFinite, nTotal);
for i = 1:numel(prcs)
    fprintf('  %2dth percentile: %.4f\n', prcs(i), prcVals(i));
end

bound = options.behav.lrCutoff;
boundLabel = sprintf('lrCutoff [%g, %g]', bound(1), bound(2));

fracBelow = mean(finiteRaw < bound(1));
fracAbove = mean(finiteRaw > bound(2));

fprintf('\n=== Share of the FINITE raw distribution the bound clips ===\n');
fprintf('  %s: %.2f%% below lower bound, %.2f%% above upper bound (%.2f%% total clipped)\n', ...
    boundLabel, 100*fracBelow, 100*fracAbove, 100*(fracBelow+fracAbove));

statsOut = struct('percentiles', prcVals, 'percentileLevels', prcs, ...
    'bound', bound, 'fracBelow', fracBelow, 'fracAbove', fracAbove);
statsOut.boundLabel = boundLabel;
statsOut.seqType = seqType;
statsOut.finiteRaw = finiteRaw;  

% histogram
binLo = min(prcVals(1), bound(1) - 0.2);
binHi = max(prcVals(end), bound(2) + 0.2);

fh = figure;
histogram(finiteRaw, 'BinLimits', [binLo binHi], 'NumBins', 200, ...
    'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'none');
hold on;
xline(bound(1), '--', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5);
xline(bound(2), '--', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5, ...
    'Label', boundLabel, 'LabelOrientation', 'horizontal');
xlabel('Raw learning rate (finite values only)');
ylabel('Count');
title(sprintf('Raw LR distribution vs. lrCutoff (%s blocks)', upper(seqType)));
hold off;

end

function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
