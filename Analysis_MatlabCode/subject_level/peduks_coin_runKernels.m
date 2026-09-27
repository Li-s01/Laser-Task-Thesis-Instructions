function [ betasCon, nTrialsCon, avgKernelsCon, nKernelsCon ] = ...
    peduks_coin_runKernels( subData, options, blockList )
%PEDUKS_COIN_RUNKERNELS Runs through all blocks of a run of the COIN
%task and computes regression-based integration kernels per block.

% Subset of blocks to analyse - if nothing indicated, analyse all
if nargin < 3
    blockList = unique(subData.blockID);
end

% Go through data block-wise, extract kernels and assign condition
nBlocks = zeros(2,2);
for iBlock = blockList
    blockData = subData(subData.blockID == iBlock, :);
    % check whether current block is empty
    if ~isempty(blockData)
        % pre-process movements in this block
        blockMove(iBlock) = ...
            peduks_coin_blockMovements(blockData, options);

        % compute integration kernels
        [betas(iBlock, :), nTrials(iBlock), ...
            avgKernels(iBlock, :), nKernels(iBlock)] = ...
            peduks_coin_blockKernels(blockData, blockMove(iBlock), options);

        % allocate kernels to different conditions
        vol = unique(blockData.volatility)+1;
        sto = unique(blockData.stochasticity)+1;
        nBlocks(vol,sto) = nBlocks(vol,sto) + 1;
        betasCon{vol,sto}(nBlocks(vol,sto), :) = betas(iBlock, :);
        nTrialsCon{vol,sto}(nBlocks(vol,sto)) = nTrials(iBlock);
        avgKernelsCon{vol,sto}(nBlocks(vol,sto), :) = avgKernels(iBlock, :);
        nKernelsCon{vol,sto}(nBlocks(vol,sto)) = nKernels(iBlock);
    end
end


end