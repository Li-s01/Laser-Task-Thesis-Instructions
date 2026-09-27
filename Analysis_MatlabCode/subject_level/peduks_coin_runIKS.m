function [ runIKS ] = peduks_coin_runIKS( kernelData, options )
%PEDUKS_COIN_RUNIKS Computes integration kernel steepness for one
%run (e.g. 2 sessions of baseline type on one visit) of the COIN task in
%the PEDUK study.

for iVol = 1:2
    for iSto = 1:2
        runIKS(iVol, iSto) = peduks_coin_compute_IKS_from_kernel(...
            squeeze(mean(kernelData{iVol,iSto},1)), options);
    end
end

end