function [ LR, LRcorr, LRraw, LRcorrRaw, predErr, update, timeToMove ] = ...
    peduks_coin_blockLearningRate( blockData, options )
%Computes implied learning rate as the
%shield position update from laser event to laser event, as a function
%of the prediction error. Locked to laser (observation) events, not mean
%change points

%Setting the outlier bounds
nSamples = numel(blockData.laser);
if numel(options.behav.lrCutoff) > 1
    lowerC = options.behav.lrCutoff(1); upperC = options.behav.lrCutoff(2);
else
    lowerC = -options.behav.lrCutoff; upperC = options.behav.lrCutoff;
end

if numel(options.behav.lrCorrCutoff) > 1
    lowerCcorr = options.behav.lrCorrCutoff(2); upperCcorr = options.behav.lrCorrCutoff(2);
else
    lowerCcorr = -options.behav.lrCorrCutoff; upperCcorr = options.behav.lrCorrCutoff;
end

pe = blockData.laserDistance;
pe(~blockData.includeFrame) = NaN;
shield = blockData.shield;
shield(~blockData.includeFrame) = NaN; 

%Finding the laser events
changeInEvidence = [0; diff(blockData.laser)];
changeIdx = find(changeInEvidence);
changeIdx = [changeIdx; nSamples; nSamples];

%main loop
for iChange = 1: numel(changeIdx)-2
    predErr(iChange) = pe(changeIdx(iChange));
    update(iChange)  = -(pe(changeIdx(iChange+1)-1) - pe(changeIdx(iChange)));
    timeToMove(iChange) = changeIdx(iChange+1) - changeIdx(iChange);
end

%computes learning rate
LR = update ./ predErr;
updateCorr = update ./ timeToMove;
LRcorr = updateCorr ./ predErr;

LRraw = LR;
LRcorrRaw = LRcorr;

if options.behav.lrExclusion
    LR(LR<lowerC)=NaN; LR(LR>upperC)=NaN;
    LRcorr(LRcorr<lowerCcorr)=NaN; LRcorr(LRcorr>upperCcorr)=NaN;
else
    LR(LR<lowerC)=lowerC; LR(LR>upperC)=upperC;
    LRcorr(LRcorr<lowerCcorr)=lowerCcorr; LRcorr(LRcorr>upperCcorr)=upperCcorr;
end

end