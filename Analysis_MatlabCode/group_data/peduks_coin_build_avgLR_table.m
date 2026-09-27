function avgLRtable = peduks_coin_build_avgLR_table( options, excludedBlocks, subjectData, seqType )
%Block-level average learning rate for
%all blocks of the given seqType, one row per subject x block, with
%sequenceID 
%   OUT: avgLRtable - subID, blockID, sequenceID, instrCond,
%                     instrCondEffect, avgLR, logAvgLR, nEvents


if nargin < 4 || isempty(seqType)
    seqType = 'CP';
end
if nargin < 3
    subjectData = [];
end
if nargin < 2 || isempty(excludedBlocks)
    excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
end

subIDs = options.subjectIDs;
rows = struct([]);

% go through every subject, then every block of that subject
for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(subData)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);
    blockIDs = unique(subData.blockID);
    for iB = blockIDs(:)'
        blockData = subData(subData.blockID == iB, :);
        % skip excluded blocks and blocks of the other sequence type
        if isempty(blockData) || ismember(iB, subExcluded) || ~strcmp(charify(blockData.seqType(1)), seqType)
            continue
        end

        LR = peduks_coin_blockLearningRate(blockData, options); % clipped
        instrChar = charify(blockData.instrCond(1));
        seqID = string(erase(charify(blockData.blockFileName(1)), '_rot180'));

        % average over all laser events of the block, including the zeros from events without movement
        avgLRval = mean(LR, 'omitnan');
        row = struct('subID', subID, 'blockID', iB, 'sequenceID', seqID, ...
            'instrCond', string(instrChar), 'instrCondEffect', (instrChar=='B')-0.5, ...
            'avgLR', avgLRval, 'logAvgLR', log(avgLRval), 'nEvents', sum(~isnan(LR)));
        if isempty(rows), rows = row; else, rows(end+1) = row; end 
    end
end

% one row per block
avgLRtable = struct2table(rows);

end

function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
