function [slopeTable, T] = peduks_coin_build_last3_pooled_table( options, T, excludedBlocks, subjectData, seqType )
%Pools the 5 kernel betas across all
%blocks of the given seqType and condition, then fits a linear slope
%using only the last 3 laser events 
%   OUT: slopeTable - long format: subID, instrCond, instrCondEffect,
%                     slopeLast3 
%        T - input T, with <seqType>_A_slopeLast3/<seqType>_B_slopeLast3
%            added

if nargin < 5 || isempty(seqType)
    seqType = 'CP';
end
if nargin < 4
    subjectData = [];
end

subIDs = options.subjectIDs;
rows = struct([]);
slopeA = nan(numel(subIDs),1);
slopeB = nan(numel(subIDs),1);
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
    pooledBetas = struct('A', [], 'B', []);
    blockIDs = unique(subData.blockID);
    for iB = blockIDs(:)'
        blockData = subData(subData.blockID == iB, :);
        % skip excluded blocks and blocks of the other sequence type
        if isempty(blockData) || ismember(iB, subExcluded) || ~strcmp(char(string(blockData.seqType(1))), seqType)
            continue
        end
        blockMove = peduks_coin_blockMovements(blockData, options);
        betas = peduks_coin_blockKernels(blockData, blockMove, options);
        if isempty(betas) || any(isnan(betas))
            continue
        end
        instr = char(string(blockData.instrCond(1)));
        % collect the kernel weights of every block of this instruction
        pooledBetas.(instr) = [pooledBetas.(instr); betas(:)'];
    end

    for c = {'A','B'}
        instrChar = c{1};
        if isempty(pooledBetas.(instrChar))
            continue
        end
        avgBetas = mean(pooledBetas.(instrChar), 1, 'omitnan');

        last3 = avgBetas(3:5);           
        % straight line through the last three lags; its slope is the measure
        p = polyfit(-3:-1, last3, 1);
        slope = p(1);

        row = struct('subID', subID, 'instrCond', string(instrChar), ...
            'instrCondEffect', (instrChar=='B')-0.5, 'slopeLast3', slope);
        if isempty(rows), rows = row; else, rows(end+1) = row; end 
        if strcmp(instrChar,'A'), slopeA(iSub) = slope; else, slopeB(iSub) = slope; end
    end
end

slopeTable = struct2table(rows);
T.([seqType '_A_slopeLast3']) = slopeA;
T.([seqType '_B_slopeLast3']) = slopeB;

end
