function [ lrTraceCon, lrTracePerJsCon, lrCorrTraceCon, LRcon, LRcorrCon, ...
    LRraw, LRcorrRaw, LRrawCon, LRcorrRawCon ] = ...
    peduks_coin_runLearningRate( subData, options, blockList )
%PEDUKS_COIN_RUNLEARNINGRATE Runs through all blocks of a run of the COIN
%task and computes implied learning rates per block.

% Subset of blocks to analyse - if nothing indicated, analyse all
if nargin < 3
    blockList = unique(subData.blockID);
end

% Go through data block-wise, extract kernels and assign condition
nBlocks = zeros(2,2);
LR = [];
LRcorr = [];
LRraw = [];
LRcorrRaw = [];
LRrawCon = cell(2,2);
LRcorrRawCon = cell(2,2);

for iBlock = blockList
    blockData = subData(subData.blockID == iBlock, :);
    % check whether current block is empty
    if ~isempty(blockData)
        % compute learning rates
        [lrTrace(iBlock, :), lrTracePerJs(iBlock, :, :), lrCorrTrace(iBlock, :), ~, ...
            blockLR, blockLRcorr, blockLRraw, blockLRcorrRaw] = ...
            peduks_coin_blockLearningRate(blockData, options, false);

        LR = [LR blockLR];
        LRcorr = [LRcorr blockLRcorr];
        LRraw = [LRraw blockLRraw];
        LRcorrRaw = [LRcorrRaw blockLRcorrRaw];

        % allocate learning rates to different conditions
        vol = unique(blockData.volatility)+1;
        sto = unique(blockData.stochasticity)+1;
        nBlocks(vol,sto) = nBlocks(vol,sto) + 1;
        lrTraceCon{vol,sto}(nBlocks(vol,sto), :) = lrTrace(iBlock, :);
        lrTracePerJsCon{vol,sto}(nBlocks(vol,sto), :, :) = lrTracePerJs(iBlock, :, :);
        lrCorrTraceCon{vol,sto}(nBlocks(vol,sto), :) = lrCorrTrace(iBlock, :);

        LRcon{vol,sto}.mean(nBlocks(vol,sto)) = nanmean(blockLR);
        LRcon{vol,sto}.std(nBlocks(vol,sto)) = nanstd(blockLR);
        LRcorrCon{vol,sto}.mean(nBlocks(vol,sto)) = nanmean(blockLRcorr);
        LRcorrCon{vol,sto}.std(nBlocks(vol,sto)) = nanstd(blockLRcorr);

        LRrawCon{vol,sto} = [LRrawCon{vol,sto} blockLRraw];
        LRcorrRawCon{vol,sto} = [LRcorrRawCon{vol,sto} blockLRcorrRaw];
        
    end
end

%LR(abs(LR)>20) = [];
%LRcorr(abs(LRcorr)>2) = [];

end