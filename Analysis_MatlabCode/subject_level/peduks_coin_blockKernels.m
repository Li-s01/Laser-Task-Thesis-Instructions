function [ betas, nTrials, avgKernels, nKernels ] = ...
    peduks_coin_blockKernels( blockData, blockMove, options )
%PEDUKS_COIN_BLOCKKERNELS Computes integration kernels using regression of
%movement magnitude onto distance of the last few laser events from the
%shield. Laser-event-locked

nSamplesBefore = options.behav.kernelPreSamplesEvi;

pe = blockData.laserDistance;
pe(~blockData.includeFrame) = NaN;
peTrace = [NaN pe'];

changeInEvidence = [0; diff(blockData.laser)];
changeIdx = find(changeInEvidence);

startLeft = blockMove.left.onsets;
recentEvidenceLeft = nan(numel(startLeft), nSamplesBefore);
for iLeft = 1: numel(startLeft)
    allPriorChanges = changeIdx(changeIdx<startLeft(iLeft));
    if numel(allPriorChanges)>=nSamplesBefore
        recentChanges = allPriorChanges(end-nSamplesBefore+1:end);
        nonAvail = 0;
    else
        recentChanges = allPriorChanges;
        nonAvail = nSamplesBefore-numel(allPriorChanges);
    end
    recentEvidenceLeft(iLeft, :) = peTrace([ones(nonAvail,1); recentChanges+1]);
end

startRight = blockMove.right.onsets;
recentEvidenceRight = nan(numel(startRight), nSamplesBefore);
for iRight = 1: numel(startRight)
    allPriorChanges = changeIdx(changeIdx<startRight(iRight));
    if numel(allPriorChanges)>=nSamplesBefore
        recentChanges = allPriorChanges(end-nSamplesBefore+1:end);
        nonAvail = 0;
    else
        recentChanges = allPriorChanges;
        nonAvail = nSamplesBefore-numel(allPriorChanges);
    end
    recentEvidenceRight(iRight, :) = peTrace([ones(nonAvail,1); recentChanges+1]);
end

moveKernels = [recentEvidenceLeft; -recentEvidenceRight];
avgKernels = mean(moveKernels, 1, 'omitnan');
nKernels = size(moveKernels, 1);

Y = [blockMove.left.stepSizes; -blockMove.right.stepSizes];
X = [recentEvidenceLeft; recentEvidenceRight];
if options.behav.flagNormaliseEvidence
    X = (X - mean(X,1,'omitnan'))./std(X,0,1,'omitnan');
    Y = (Y - mean(Y))./std(Y);
end

toRemove = isnan(X(:,1));
X(toRemove,:) = [];
Y(toRemove) = [];
nTrials = size(X,1);

% ordinary least squares 
betas = X \ Y;

end