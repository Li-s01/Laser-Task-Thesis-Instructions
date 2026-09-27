function [ allAdjust, jumpSize, moveAtMean ] = ...
    peduks_coin_blockAdjustments( blockData, options )
%PEDUKS_COIN_BLOCKADJUSTMENTS Computes mean adjustment behaviour after a
%mean jump in the COIN task, excluding the time in the block before the
%first laser hit event. Also analyses the movement behaviour during
%constant mean periods (i.e., after the new mean has been reached and
%before it jumps again).

nSamplesBefore = options.behav.adjustPreSamples;
nSamplesAfter = options.behav.adjustPostSamples;
fsmp = options.behav.fsample;

% find change points in true mean
changeInMean = [0; diff(blockData.trueMean)];

% ignore change points before first laser hit
changeInMean(~blockData.includeFrame) = 0;

%% Part I
cpUp = find(changeInMean>0);
cpDown = find(changeInMean<0);

% movement adjustments
allAdjust = [];
meanLvl = [];
jumpSize = [];
currVar = [];

% nan-pad the variables to allow for samples before start and after end of
% block
shield_pad = [NaN(nSamplesBefore, 1); blockData.shield; NaN(nSamplesAfter, 1)];
trueMean_pad = [NaN(nSamplesBefore, 1); blockData.trueMean; NaN(nSamplesAfter, 1)];
for iUp = 1: numel(cpUp)
    % only consider mean jumps after at least nSamplesBefore into the
    % block, and before at least 2s before the end of the block
    if cpUp(iUp) >= nSamplesBefore && cpUp(iUp) < numel(blockData.shield) -120
        % adjustments are centered around the previous mean (at the sample
        % before the change point)
        % wrapped to shortest circular distance - shield/trueMean are
        % unwrapped continuous radians (see peduks_coin_runPreprocBehavData.m),
        % so the raw difference can drift by more than 2*pi within a block
        % (many change points per block) even though nothing "jumped" locally
        allAdjust = [allAdjust; ...
            mod((shield_pad(cpUp(iUp) : cpUp(iUp)+nSamplesBefore+nSamplesAfter)' ...
            - blockData.trueMean(cpUp(iUp)-1)) + pi, 2*pi) - pi];
        % the position of the true mean
        meanLvl = [meanLvl; trueMean_pad(cpUp(iUp) : cpUp(iUp)+nSamplesBefore+nSamplesAfter)'];
        % how much the mean changed
        jumpSize = [jumpSize; changeInMean(cpUp(iUp))];
        % the noise level at the time of the mean jump (not relevant for
        % PEDUKS)
        currVar = [currVar; blockData.trueNoise(cpUp(iUp))];
    end
end
for iDown = 1: numel(cpDown)
    % only consider mean jumps after at least nSamplesBefore into the
    % block, and before at least 2s before the end of the block
    if cpDown(iDown) >= nSamplesBefore && cpDown(iDown) < numel(blockData.shield) -120
        % adjustments are centered around the previous mean (at the sample
        % before the change point)
        % NOTE: negated so that, like up-jumps, positive values mean
        % "progress towards the new mean" (down-jumps naturally move the
        % raw shield-minus-old-mean quantity negative, which without this
        % flip does not match the sign convention of jumpSize below, and
        % silently cancels with up-jump trajectories when pooled/averaged
        % by jump size in peduks_coin_add_RT_new.m)
        allAdjust = [allAdjust; ...
        -(mod((shield_pad(cpDown(iDown) : cpDown(iDown)+nSamplesBefore+nSamplesAfter)' ...
        - blockData.trueMean(cpDown(iDown)-1)) + pi, 2*pi) - pi)];
        % the position of the true mean
        meanLvl = [meanLvl; trueMean_pad(cpDown(iDown) : cpDown(iDown)+nSamplesBefore+nSamplesAfter)'];
        % how much the mean changed
        jumpSize = [jumpSize; -changeInMean(cpDown(iDown))];
        % the noise level at the time of the mean jump (not relevant for
        % PEDUKS)
        currVar = [currVar; blockData.trueNoise(cpDown(iDown))];
    end
end

% classify jumpSizes
jumpSize = round(jumpSize,4);
jumpSD = round(jumpSize./currVar,1);

% normalise shield adjustment to pre-changepoint level (force adjustment
% time course to start at zero)
if options.behav.flagNormaliseAdjustments
    for iAdj = 1: size(allAdjust,1)
        allAdjust(iAdj, :) = squeeze(allAdjust(iAdj, :)) - ...
            squeeze(allAdjust(iAdj, nSamplesBefore+1));
    end
end



%% Part II
% analyse movement behaviour after mean has been reached & before mean
% jumps again
tolArea = unique(blockData.shieldWidth)/2;
cps = find(changeInMean);
cps = [cps; numel(blockData.trueMean)];
for iCP = 1: numel(cps)-1
    % go through all samples after this CP, before the next
    for iSmp = cps(iCP)+1 : cps(iCP+1)
        % mark the sample where shieldPosition reaches trueMean
        distToNewMean = mod((blockData.shield(iSmp) - blockData.trueMean(iSmp)) + pi, 2*pi) - pi;
        if abs(distToNewMean) <= tolArea
            reachedNewMean(iCP, 1) = iSmp; % sample where it's reached
            reachedNewMean(iCP, 2) = iSmp - cps(iCP); % RT in samples
            break
        end
    end
    moveAtConstMean = blockData.shield(iSmp:cps(iCP+1));
    moveAtMean.constMeanWindowLength(iCP) = numel(moveAtConstMean);
    if numel(moveAtConstMean) < 3
        moveAtMean.percentMovingSamples(iCP) = NaN;
        moveAtMean.sideSwitchesPerSec(iCP) = NaN;
        moveAtMean.moveOnsetsPerSec(iCP) = NaN;
    else
        moveAtMean.percentMovingSamples(iCP) = numel(find(diff(moveAtConstMean)))/numel(moveAtConstMean);
        aboveBelowMean = sign(mod((moveAtConstMean - blockData.trueMean(cps(iCP)+1)) + pi, 2*pi) - pi);
        moveAtMean.sideSwitchesPerSec(iCP) = numel(find(diff(aboveBelowMean(aboveBelowMean~=0))))*fsmp/numel(moveAtConstMean);
        firstDeriv = [0; round(diff(moveAtConstMean),2)];
        secondDeriv = [0; 0; round(diff(diff(moveAtConstMean)),2)];
        moveAtMean.moveOnsetsPerSec(iCP) = numel(find((firstDeriv>0 & secondDeriv>0) | (firstDeriv<0 & secondDeriv<0)))*fsmp/numel(moveAtConstMean);
    end
end