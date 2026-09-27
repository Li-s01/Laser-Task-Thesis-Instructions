function [interCPtable, overlapSummary] = CP_RT_window_overlap_check( options, subjectData )
%Checks how often the post-jump RT window
%reaches past the next change point in
%the same block.
%   OUT: interCPtable - one row per change point used by
%        peduks_coin_blockAdjustments.m: subID, blockID, cpSample,
%        secToNextCP (NaN if no later change point in that block)
%        overlapSummary - struct: nCP, nWithNextCPKnown,
%        medianSecToNextCP, pctWithin9s

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

fsmp = options.behav.fsample;
nSamplesBefore = options.behav.adjustPreSamples;
windowSec = options.behav.adjustPostSamples / fsmp;

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
subIDs = options.subjectIDs;

rows = struct([]);
for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(subData), continue; end
    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);
    blockIDs = unique(subData.blockID);
    for iB = blockIDs(:)'
        blockData = subData(subData.blockID == iB, :);
        if isempty(blockData) || ismember(iB, subExcluded) || ~strcmp(charify(blockData.seqType(1)), 'CP')
            continue
        end

        changeInMean = [0; diff(blockData.trueMean)];
        changeInMean(~blockData.includeFrame) = 0;
        cpAll = sort([find(changeInMean>0); find(changeInMean<0)]);

        % same inclusion window peduks_coin_blockAdjustments.m uses
        validCP = cpAll(cpAll >= nSamplesBefore & cpAll < numel(blockData.shield) - 120);

        for iCP = 1:numel(validCP)
            thisCP = validCP(iCP);
          
            laterCPs = cpAll(cpAll > thisCP);
            if isempty(laterCPs)
                secToNext = NaN;
            else
                secToNext = (laterCPs(1) - thisCP) / fsmp;
            end
            row = struct('subID', subID, 'blockID', iB, 'cpSample', thisCP, 'secToNextCP', secToNext);
            if isempty(rows), rows = row; else, rows(end+1) = row; end 
        end
    end
end
interCPtable = struct2table(rows);

known = ~isnan(interCPtable.secToNextCP);
overlapSummary = struct( ...
    'nCP', height(interCPtable), ...
    'nWithNextCPKnown', sum(known), ...
    'medianSecToNextCP', median(interCPtable.secToNextCP(known)), ...
    'pctWithin9s', 100*mean(interCPtable.secToNextCP(known) < windowSec));

fprintf('\n=== inter-change-point interval check (CP blocks) ===\n');
fprintf('Window currently used for RT/adjustment: %.1fs\n', windowSec);
fprintf('Change points with a later CP in the same block: %d of %d\n', ...
    overlapSummary.nWithNextCPKnown, overlapSummary.nCP);
fprintf('Median time to next CP: %.2fs\n', overlapSummary.medianSecToNextCP);
fprintf('Of those, %.1f%% have their next CP within %.1fs (i.e. the CURRENT window already overlaps)\n', ...
    overlapSummary.pctWithin9s, windowSec);

fprintf('\n=== distribution of time to next CP (percentiles) ===\n');
prctiles = [5 10 25 50 75 90 95];
vals = prctile(interCPtable.secToNextCP(known), prctiles);
disp(table(prctiles', vals', 'VariableNames', {'percentile','secToNextCP'}));

end

function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
