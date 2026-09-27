function rt = peduks_coin_compute_RT_from_adjustment( adjust, jumpSizes, options )
%PEDUKS_COIN_COMPUTE_RT_FROM_ADJUSTMENT Takes adjustment time course data
%(dimensions nJumpSizes * nSamples) and computes RT per jump size (with or
%without normalising adjustment time course depending on setting in options
%struct).
% IN:   adjust      - nJumpSizes * nSamples array of adjustment time course
%       jumpSizes   - nJumpSizes * 1 vector with jump sizes
%       options     - the struct that holds all analysis options
% OUT:  rt          - reaction time per jump size (nJumpSize * 1)

% Do we normalise adjustments before computing RT?
doNorm = options.behav.flagNormaliseAdjustments;

% Gather settings and time dimension
pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;
fsmp = options.behav.fsample;
timeAxis = [-pre/fsmp: 1/fsmp : post/fsmp];
rtTimes = timeAxis(pre+1:end);

% Determine half of the mean jump (how far subjects have to adjust the
% shield position)
nJumpSizes = numel(jumpSizes);
if nJumpSizes ~= size(adjust,1)
    error('number of jump sizes does not match dimensions of adjustments')
end
halfJumps = jumpSizes/2;

% Normalise & compute RTs
for iJmp = 1: nJumpSizes
    %if doNorm
    %    % subtract position at the time of the mean jump
    %    adjust(iJmp, :) = squeeze(adjust(iJmp,:)) - squeeze(adjust(iJmp,pre+1));
    %end
    % consider position data after mean jump
    adjustData = squeeze(adjust(iJmp, (pre+1):end));
    % extract times post mean jump where position was at least half-way to
    % the new mean
    timeReached = rtTimes(adjustData>=halfJumps(iJmp));
    if isempty(timeReached)
        rt(iJmp) = NaN;
    else
        % take the first time point as the RT
        rt(iJmp) = timeReached(1);
    end
end

