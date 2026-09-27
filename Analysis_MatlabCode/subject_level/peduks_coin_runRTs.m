function [ runRTs ] = peduks_coin_runRTs( adjust, options )
%PEDUKS_COIN_RUNRTS Computes RT from shield adjustment behaviour for one
%run (e.g. 2 sessions of baseline type on one visit) of the COIN task in
%the PEDUK study.

% Decide whether to use the mean or the median
adjustData = adjust.meanAdjusts;

% Determine jumpSizes
jumpSizes = unique(adjust.jumpSizes);

for iVol = 1:2
    for iSto = 1:2
        runRTs(iVol, iSto, :) = peduks_coin_compute_RT_from_adjustment(...
            squeeze(adjustData(iVol,iSto,:,:)), jumpSizes, options);
    end
end

end