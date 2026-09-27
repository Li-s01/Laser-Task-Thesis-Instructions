function [ stim, perf ] = peduks_coin_blockTrackingPerformance( blockData, options )
%PEDUKS_COIN_BLOCKTRACKINGPERFORMANCE Computes several indices for quantifying
%how well a participant was tracking the laser position in the COIN task.

%% Keep track of conditions
stim.seqType = unique(blockData.seqType);
perf.seqType = unique(blockData.seqType);
stim.instrCond = unique(blockData.instrCond);
perf.instrCond = unique(blockData.instrCond);

shield = blockData.shield(blockData.includeFrame);
laser = blockData.laser(blockData.includeFrame);
trueMean = blockData.trueMean(blockData.includeFrame);
trueNoise = blockData.trueNoise(blockData.includeFrame);
shieldWidth = blockData.shieldWidth(blockData.includeFrame);

%% Collect raw and derived stimulus
% stimulus and generating stats
stim.position   = laser;
stim.genMean    = trueMean;
stim.movAvg     = movmean(laser, [options.behav.movAvgWin-1 0]);
stim.genStd     = trueNoise;
% change points in generating stats
stim.nMeanCPs   = sum(diff(trueMean)~=0);% + sum(diff(blockData.trueMean)>0);
stim.sumDeltaMean = sum(abs(diff(trueMean)));
% bias in stimulus and generating stats
stim.moveBias   = sum(diff(laser));
stim.meanBias   = sum(diff(trueMean));

%% Collect raw and derived behaviour
% useful variables
shield1stDeriv = [0; diff(shield)];
shield2ndDeriv = [0; 0; diff(diff(shield))];

leftTurnOnsets = shield1stDeriv>0 &shield2ndDeriv>0;
rightTurnOnsets = shield1stDeriv<0 &shield2ndDeriv<0;
isShieldMovement = shield1stDeriv ~= 0;

distance = mod((laser - shield) + pi, 2*pi) - pi;
absDistance = abs(distance);
if numel(unique(shieldWidth)) == 1
    hitArea = unique(shieldWidth)/2;
else
    hitArea = shieldWidth/2;
end
signDistance = sign(distance);
signChange = [0; diff(signDistance)];

% quantify how long it took them to react to misses: defined as the times
% where they're not moving despite missing lasers (and the sign of the
% misses not changing!)
didNotReact = ~isShieldMovement & absDistance > hitArea & ~signChange;
durations = diff([0; find([0; diff(didNotReact)]); numel(didNotReact)]);
if didNotReact(1) == true
    inactionDurs = durations(1:2:end);
else
    inactionDurs = durations(2:2:end);
end
inactionSecs = inactionDurs/options.behav.fsample;

% position and movement
perf.position       = shield;
perf.positionPE     = distance;
perf.overallPosPE   = sum(absDistance);
perf.meanPosPE      = mean(absDistance);
perf.medianPosPE    = median(absDistance);
perf.diff2genMean   = mod((trueMean - shield) + pi, 2*pi) - pi;
perf.sumDiff2mean   = sum(abs(perf.diff2genMean));
perf.meanDiff2mean  = mean(abs(perf.diff2genMean));
perf.medianDiff2mean= median(abs(perf.diff2genMean));
perf.nMoveOnsets    = sum(leftTurnOnsets) + sum(rightTurnOnsets);
perf.nMoveFrames    = sum(isShieldMovement);
perf.overallMove    = sum(abs(shield1stDeriv));
perf.inactionSecs   = inactionSecs;
perf.meanInaction   = mean(inactionSecs);
perf.medianInaction = median(inactionSecs);
perf.maxInaction    = max(inactionSecs);
perf.nInaction2s    = sum(inactionSecs>2);

% movement biases
perf.moveBias       = sum(shield1stDeriv);
perf.relMoveBias    = perf.moveBias - stim.moveBias;
perf.trackBias      = sum(perf.positionPE);
perf.relTrackBias   = perf.trackBias - stim.moveBias; %???
perf.infBias        = sum(perf.diff2genMean);
perf.relInfBias     = perf.infBias - stim.meanBias;

% shield size and updates
perf.stdev          = 0.5*shieldWidth;
perf.meanStdev      = mean(perf.stdev);
perf.absPositionPE  = absDistance;
perf.diff2absPE     = absDistance - perf.stdev;
perf.sumDiff2absPE  = sum(abs(perf.diff2absPE));

% shield size biases
perf.sizeTrackBias  = sum(perf.diff2absPE);

% volatility biases
perf.diff2genMeanCPs    = perf.nMoveOnsets - stim.nMeanCPs;
perf.diff2sumDeltaMean  = perf.overallMove - stim.sumDeltaMean;

% time since last shield movement 
lastMoveFrame = find(isShieldMovement, 1, 'last');
if isempty(lastMoveFrame)
    lastMoveFrame = 0;
end
perf.secsSinceLastMove = (numel(shield) - lastMoveFrame) / options.behav.fsample;

% longest single stretch of inactivity anywhere in the block (not just
% at the end) - catches a long pause even if the person later moved again
notMoving = ~isShieldMovement;
d = diff([0; notMoving; 0]);
runStarts = find(d == 1);
runEnds = find(d == -1) - 1;
runLengths = runEnds - runStarts + 1;
if isempty(runLengths)
    perf.maxInactivityGap = 0;
else
    perf.maxInactivityGap = max(runLengths) / options.behav.fsample;
end

%reward/loss
perf.reward = blockData.totalReward(end);

%implied learning rate (per laser event, works for CP and RW)
[blockLR, blockLRcorr]= peduks_coin_blockLearningRate(blockData, options);
perf.meanLR = mean(blockLR, 'omitnan');
perf.medianLR = median(blockLR,'omitnan');
perf.meanLRcorr= mean(blockLRcorr, 'omitnan');

%integration kernel steepness (works for CP and RW)
blockMove = peduks_coin_blockMovements(blockData, options);
[betas, nTrials, avgKernels, ~] = peduks_coin_blockKernels(blockData, blockMove, options);
perf.iks = peduks_coin_compute_IKS_from_kernel(betas, options);

% second version of IKS with stepness for all 5 kernals
kernelFit = polyfit(1:numel(betas), betas, 1);
perf.kernelSlope = kernelFit(1);

% adjustment behaviour after real mean jumps (CP-only)
if strcmp(unique(blockData.seqType), 'CP')
    [allAdjust, jumpSize, moveAtMean] = peduks_coin_blockAdjustments(blockData, options);
    rt = peduks_coin_compute_RT_per_jump(allAdjust, jumpSize, options);
    perf.meanRT = mean(rt, 'omitnan');
    perf.nJumps = numel(jumpSize);
    perf.percentMovingAtConstMean = mean(moveAtMean.percentMovingSamples, 'omitnan');
else
    perf.meanRT = NaN;
    perf.nJumps = 0;
    perf.percentMovingAtConstMean = NaN;
end

%ELR
if strcmp(unique(blockData.seqType), 'CP')
    elrVals = peduks_coin_ELR_per_jump(blockData, options);
    perf.meanELR = mean(elrVals, 'omitnan');
else
    perf.meanELR = NaN;
end

end
