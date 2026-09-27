function [ stim, perform, fhs ] = peduks_coin_runPerformance( subData, options, doPlot )
%PEDUKS_COIN_RUNPERFORMANCE ...
%   IN:     ...
%           doPlot      - if true, generate + return per-block figures
%                         (default: false)

if nargin < 3
    doPlot = false;
end
fhs = [];

for iBlock = 1: max(unique(subData.blockID))
    blockData = subData(subData.blockID == iBlock, :);
    if ~isempty(blockData)
        if doPlot
            fhs(end+1) = peduks_coin_plot_blockData(blockData, options);
            cleanUpFig(fhs(end));
        end
        [stim{iBlock}, perform{iBlock}] = ...
            peduks_coin_blockTrackingPerformance(blockData, options);
    end
end

end