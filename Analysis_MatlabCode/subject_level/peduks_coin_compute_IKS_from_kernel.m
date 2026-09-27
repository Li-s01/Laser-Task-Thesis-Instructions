function iks = peduks_coin_compute_IKS_from_kernel( kernel, options )
%PEDUKS_COIN_COMPUTE_IKS_FROM_KERNEL Takes integration kernel data
%(dimensions nJumpSizes * nSamples) and computes IKS depending on settings
%in options struct).
% IN:   kernel      - nSamples array of weights
%       options     - the struct that holds all analysis options
% OUT:  iks         - integration kernel steepness

sample1 = options.behav.kernelSteepnessIndices(1);
sample2 = options.behav.kernelSteepnessIndices(2);
iks = kernel(sample1) - kernel(sample2);