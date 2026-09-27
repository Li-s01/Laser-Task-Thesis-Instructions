function nMovTable = peduks_coin_build_nMovements_table( options, excludedBlocks, subjectData, seqType )
%Block-level nMovements for all blocks of the given seqType, one row per subject
%x block, with sequenceID 
%   OUT: nMovTable - subID, blockID, sequenceID, instrCond,
%                    instrCondEffect, nMovements, logNMovements

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

        % how often the shield was moved in this block
        blockMove = peduks_coin_blockMovements(blockData, options);
        instrChar = charify(blockData.instrCond(1));
        seqID = string(erase(charify(blockData.blockFileName(1)), '_rot180'));

        % log scale for the model; a block without any movement has no log
        if blockMove.nMovements > 0
            logN = log(blockMove.nMovements);
        else
            logN = NaN;
        end

        row = struct('subID', subID, 'blockID', iB, 'sequenceID', seqID, ...
            'instrCond', string(instrChar), 'instrCondEffect', (instrChar=='B')-0.5, ...
            'nMovements', blockMove.nMovements, 'logNMovements', logN);
        if isempty(rows), rows = row; else, rows(end+1) = row; end 
    end
end

% one row per block
nMovTable = struct2table(rows);

end

function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
