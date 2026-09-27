function [ runELR ] = peduks_coin_runELRperJs( lrData, options )
%PEDUKS_COIN_RUNELRPERJS Computes evoked learning rate shift, separated by
%jump size, for one run (e.g. 2 sessions of baseline type on one visit) of 
%the COIN task in the PEDUK study.

for iVol = 1:2
    for iSto = 1:2
        for iJs = 1:3
            runELR(iVol, iSto, iJs) = peduks_coin_compute_ELR_from_lrTrace(...
                squeeze(mean(lrData{iVol,iSto}(:,iJs,:),1)), options);
        end
    end
end

end