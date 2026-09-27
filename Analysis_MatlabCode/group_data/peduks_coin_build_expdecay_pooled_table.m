function [tauTable, T] = peduks_coin_build_expdecay_pooled_table( options, T, excludedBlocks, subjectData, seqType )
%Pools the 5 kernel betas across
%all blocks of one sequence type within a
%condition, then fits an exponential decay once per subject x condition.
%
%Fit uses peduks_coin_fit_exp_decay_bound 
% OUT:tauTable long format: subID, instrCond, instrCondEffect,
% tauPooled, R2pooled 
% T - input T, with <seqType>_A_tauPooled/<seqType>_B_tauPooled added

if nargin < 4
    subjectData = [];
end
if nargin < 5 || isempty(seqType)
    seqType = 'CP';
end

subIDs = options.subjectIDs;
rows = struct([]);
tauA = nan(numel(subIDs),1);
tauB = nan(numel(subIDs),1);
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
        pooledBetas.(instr) = [pooledBetas.(instr); betas(:)'];
    end

    for c = {'A','B'}
        instrChar = c{1};
        if isempty(pooledBetas.(instrChar))
            continue
        end
        avgBetas = mean(pooledBetas.(instrChar), 1, 'omitnan');

        % Bounded fit: tau in [0.1,20], A in [-5,5] 
        [tau, A] = peduks_coin_fit_exp_decay_bound(avgBetas, -5:-1);
        if isnan(tau)
            R2 = NaN;
        else
            pred = A*exp((-5:-1)/tau);
            R2 = 1 - sum((avgBetas-pred).^2) / sum((avgBetas-mean(avgBetas)).^2);
        end

        row = struct('subID', subID, 'instrCond', string(instrChar), ...
            'instrCondEffect', (instrChar=='B')-0.5, 'tauPooled', tau, 'R2pooled', R2);
        if isempty(rows), rows = row; else, rows(end+1) = row; end
        if strcmp(instrChar,'A'), tauA(iSub) = tau; else, tauB(iSub) = tau; end
    end
end

tauTable = struct2table(rows);
T.([seqType '_A_tauPooled']) = tauA;
T.([seqType '_B_tauPooled']) = tauB;

end
