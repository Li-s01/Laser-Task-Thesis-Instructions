function rt = peduks_coin_compute_RT_per_jump( allAdjust, jumpSize, options )
%Computes RT separately for each individual jump, not on an
%already-averaged trajectory.
%   IN:     allAdjust - nJumps x nSamples matrix, one row per real jump
%           jumpSize  - nJumps x 1 vector, jump size for each row
%           options   - options struct
%   OUT:    rt        - nJumps x 1 vector, RT in seconds (NaN if never reached)

pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;
fsmp = options.behav.fsample;
timeAxis = -pre/fsmp : 1/fsmp : post/fsmp;
rtTimes = timeAxis(pre+1:end);

nJumps = size(allAdjust,1);
rt = nan(nJumps,1);
halfJumps = jumpSize/2;

for iJmp = 1:nJumps
    adjustData = allAdjust(iJmp, (pre+1):end);
    timeReached = rtTimes(adjustData >= halfJumps(iJmp));
    if ~isempty(timeReached)
        rt(iJmp) = timeReached(1);
    end
end

end