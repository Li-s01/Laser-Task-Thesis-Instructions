function [ runELR ] = peduks_coin_runELR( lrData, options )
%PEDUKS_COIN_RUNELR Computes evoked learning rate shift for one
%run (e.g. 2 sessions of baseline type on one visit) of the COIN task in
%the PEDUK study.

for iVol = 1:2
    for iSto = 1:2
        runELR(iVol, iSto) = peduks_coin_compute_ELR_from_lrTrace(...
            squeeze(mean(lrData{iVol,iSto},1)), options);
    end
end

end