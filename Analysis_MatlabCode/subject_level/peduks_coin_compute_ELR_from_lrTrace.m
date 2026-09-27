function elr = peduks_coin_compute_ELR_from_lrTrace( lrTrace, options )
%PEDUKS_COIN_COMPUTE_IKS_FROM_KERNEL Takes integration kernel data
%(dimensions nJumpSizes * nSamples) and computes IKS depending on settings
%in options struct).
% IN:   lrTrace     - nSamples array of learning rates around change point
%       options     - the struct that holds all analysis options
% OUT:  elr         - evoked learning rate shift

% To find the right indices, we shift them by the number of samples pre
% change point that are contained in the vector
samplesPost = options.behav.evokedLrIdxPost + options.behav.lrPreSamples;
samplePre = options.behav.evokedLrIdxPre + options.behav.lrPreSamples;

% Average the LR during the post-CP samples and subtract the pre-CP LR
elr = mean(lrTrace(samplesPost)) - lrTrace(samplePre);