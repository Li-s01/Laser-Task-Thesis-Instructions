function ELRtable = peduks_coin_build_ELR_table( options, excludedBlocks, subjectData, seqType )
%Block-level evoked learning rate (ELR): for
%each CP block, all real changepoint jumps within that block are pooled
%into one block-level ELR value
%   OUT: ELRtable - subID, blockID, sequenceID, instrCond,
%                   instrCondEffect, ELR, nJumps

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

        % one value per change point in this block
        elr = peduks_coin_ELR_per_jump(blockData, options); % per-jump ELR, first output
        if isempty(elr)
            continue
        end

        instrChar = charify(blockData.instrCond(1));
        seqID = string(erase(charify(blockData.blockFileName(1)), '_rot180'));

        row = struct('subID', subID, 'blockID', iB, 'sequenceID', seqID, ...
            'instrCond', string(instrChar), 'instrCondEffect', (instrChar=='B')-0.5, ...
            % the block value is the mean over its change points
            'ELR', mean(elr, 'omitnan'), 'nJumps', sum(~isnan(elr)));
        if isempty(rows), rows = row; else, rows(end+1) = row; end 
    end
end

if isempty(rows)
    ELRtable = table();
else
    ELRtable = struct2table(rows);
end

end

function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
