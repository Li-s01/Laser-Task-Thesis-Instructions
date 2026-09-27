function condSummary = peduks_coin_condition_means( perform, options, excludedBlockIDs )
%Averages block-level performance metrics
%per condition (seqType x instrCond) for one subject. 
%
%Follows the approach of Webers peduks_coin_plot_overview_subjectPerformance.m 
%   IN:     perform -cell array of per-block performance structs
%           options - options struct
%   OUT:    condSummary - struct:
%             .totalReward- summed reward across all blocks
%             .byCondition{seqIdx, instrIdx} -condition means

if nargin < 3
    excludedBlockIDs = [];
end

nBlocks = numel(perform);
condSummary.totalReward = sum(cellfun(@(p) p.reward, perform));
metrics = {'meanPosPE', 'meanDiff2mean', 'overallMove', 'meanInaction', 'reward', 'meanLR', 'secsSinceLastMove', 'iks', 'kernelSlope', 'meanRT', 'percentMovingAtConstMean', 'meanELR'};

%condition means
condSummary.byCondition = cell(numel(options.seqIDs), numel(options.instrIDs));
for iS = 1:numel(options.seqIDs)
    for iI = 1:numel(options.instrIDs)
        blocksHere = [];
        for iB = 1:nBlocks
            if ismember(iB, excludedBlockIDs)
                continue
            end
            if strcmp(charify(perform{iB}.seqType), options.seqIDs{iS}) && ...
                    strcmp(charify(perform{iB}.instrCond), options.instrIDs{iI})
                blocksHere(end+1) = iB; 
            end
        end
        c = struct;
        c.label = options.conditionLabels{iS,iI};
        c.blocks = blocksHere;
        for iM = 1:numel(metrics)
            vals = nan(1, numel(blocksHere));
            for k = 1:numel(blocksHere)
                vals(k) = perform{blocksHere(k)}.(metrics{iM});
            end
            c.(metrics{iM}) = mean(vals);
        end
        condSummary.byCondition{iS,iI} = c;
    end
end

end


function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end