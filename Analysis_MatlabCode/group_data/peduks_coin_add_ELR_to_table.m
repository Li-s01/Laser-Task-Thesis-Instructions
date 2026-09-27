function T = peduks_coin_add_ELR_to_table( T, options, excludedBlocks, subjectData )
%Adds CP_A_ELR and CP_B_ELR columns to T,
%pools the raw per-jump LR traces
%across ALL CP blocks of a condition, average them
%pointwise, then compute ELR once on that single pooled average trace.

if nargin < 4
    subjectData = [];
end

subIDs = options.subjectIDs;
elrA = nan(numel(subIDs),1);
elrB = nan(numel(subIDs),1);
if nargin < 3 || isempty(excludedBlocks)
    excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
end

% go through every subject, then every block of that subject
for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(subData)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);
    pooledTraces = struct('A', [], 'B', []);
    blockIDs = unique(subData.blockID);
    for iB = blockIDs(:)'
        blockData = subData(subData.blockID == iB, :);
        
        if ismember(iB, subExcluded) || ~strcmp(charify(blockData.seqType(1)), 'CP')
            continue
        end
        instrChar = charify(blockData.instrCond(1));
        [~, lrTraces] = peduks_coin_ELR_per_jump(blockData, options);
        if isempty(lrTraces)
            continue
        end
        % collect the learning-rate traces of all blocks of this instruction
        pooledTraces.(instrChar) = [pooledTraces.(instrChar); lrTraces];
    end

    if ~isempty(pooledTraces.A)
        % one averaged trace per instruction
        avgTraceA = mean(pooledTraces.A, 1, 'omitnan');
        elrA(iSub) = peduks_coin_compute_ELR_from_lrTrace(avgTraceA, options);
    end
    if ~isempty(pooledTraces.B)
        avgTraceB = mean(pooledTraces.B, 1, 'omitnan');
        elrB(iSub) = peduks_coin_compute_ELR_from_lrTrace(avgTraceB, options);
    end
end

% attach to the wide table: one value per subject and instruction
T.CP_A_ELR = elrA;
T.CP_B_ELR = elrB;

end

function s = charify(x)
if iscell(x), s = char(x{1}); else, s = char(x); end
end
