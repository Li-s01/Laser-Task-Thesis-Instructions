function [elr, lrTraces] = peduks_coin_ELR_per_jump( blockData, options )
%For each real mean change point in a CP block,
%extracts the implied learning rate trace and computes the
%evoked learning rate shift with peduks_coin_compute_ELR_from_lrTrace.
%
%   IN:     blockData - preprocessed data for one block (CP only!)
%           options   - options struct
%   OUT:    elr       - nJumps x 1, ELR per real jump
%           lrTraces  - nJumps x (lrPreSamples+lrPostSamples+1) matrix,
%                       the underlying LR traces (event-indexed)

% implied learning rate at every laser event of this block
LR = peduks_coin_blockLearningRate(blockData, options);

% sample index of every laser event 
changeInEvidence = [0; diff(blockData.laser)];
changeIdx = find(changeInEvidence);

% sample index of every real change point 
changeInMean = [0; diff(blockData.trueMean)];
chMeanIndex = find(changeInMean);

% window around the change point, counted in laser events 
pre = options.behav.lrPreSamples;
post = options.behav.lrPostSamples;

% one learning-rate trace per change point, aligned to the event on
% which the jump occurred
lrTraces = [];
for iCP = 1:numel(chMeanIndex)
    jumpFrame = chMeanIndex(iCP);
    eventIdx = find(changeIdx == jumpFrame, 1, 'first');

    if isempty(eventIdx) || eventIdx - pre < 1 || eventIdx + post > numel(LR)
        continue
    end
    lrTraces(end+1, :) = LR(eventIdx - pre : eventIdx + post); 
end

% no usable change point in this block 
if isempty(lrTraces)
    elr = [];
    return
end

% evoked learning rate per jump
elr = nan(size(lrTraces,1), 1);
for iJmp = 1:size(lrTraces,1)
    elr(iJmp) = peduks_coin_compute_ELR_from_lrTrace(lrTraces(iJmp,:), options);
end

end
