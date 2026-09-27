function [ adjust, meanMove ] = peduks_coin_runAdjustments( subData, ...
    options, blockList )
%PEDUKS_COIN_RUNADJUSTMENTS Computes shield adjustment behaviour for one
%run (e.g. 2 sessions of baseline type on one visit) of the COIN task in
%the PEDUK study.

% Subset of blocks to analyse
if nargin < 3
    blockList = unique(subData.blockID);
end

% Count blocks per condition
nBlocks = zeros(2,2);

% Prepare output
allAdjusts = [];
allJumps = [];

allAdjustsCon = cell(2,2);
allJumpsCon = cell(2,2);

% Run through blocks
for iBlock = blockList
    blockData = subData(subData.blockID == iBlock, :);

    if ~isempty(blockData)
        % compute adjustments after mean change
        [allAdjustments{iBlock}, allJumpSizes{iBlock}, allMeanMoves{iBlock}] = ...
            peduks_coin_blockAdjustments(blockData, options);

        % save all of them
        allAdjusts = [allAdjusts; allAdjustments{iBlock}];
        allJumps = [allJumps; allJumpSizes{iBlock}];

        % allocate adjustments to different conditions
        vol = unique(blockData.volatility)+1;
        sto = unique(blockData.stochasticity)+1;
        nBlocks(vol,sto) = nBlocks(vol,sto) + 1;
        allAdjustsCon{vol,sto} = [allAdjustsCon{vol,sto}; ...
            allAdjustments{iBlock}];
        allJumpsCon{vol,sto} = [allJumpsCon{vol,sto}; ...
            allJumpSizes{iBlock}];
        allMeanMovesCon{vol,sto,nBlocks(vol,sto)} = allMeanMoves{iBlock};
    end
end

% allocate adjustements to jump sizes
jumpSizes = unique(allJumps);
for iVol = 1:2
    for iSto = 1:2
        for iJmp = 1: numel(jumpSizes)
            singleAdjusts{iVol,iSto,iJmp} = ...
                allAdjustsCon{iVol,iSto}(allJumpsCon{iVol,iSto}==jumpSizes(iJmp),:);
            meanAdjusts(iVol,iSto,iJmp,:) = ...
                nanmean(singleAdjusts{iVol,iSto,iJmp}, 1);
            medianAdjusts(iVol,iSto,iJmp,:) = ...
                nanmedian(singleAdjusts{iVol,iSto,iJmp}, 1);
        end
    end
end

% analyse movement during stable mean
moveSamples = cell(2,2);
sideSwitches = cell(2,2);
moveOnsets = cell(2,2);
for iVol = 1:2
    for iSto = 1:2
        for iBl = 1: size(allMeanMovesCon,3)
            moveSamples{iVol,iSto} = [moveSamples{iVol,iSto} ...
                allMeanMovesCon{iVol,iSto,iBl}.percentMovingSamples];
            sideSwitches{iVol,iSto} = [sideSwitches{iVol,iSto} ...
                allMeanMovesCon{iVol,iSto,iBl}.sideSwitchesPerSec];
            moveOnsets{iVol,iSto} = [moveOnsets{iVol,iSto} ...
                allMeanMovesCon{iVol,iSto,iBl}.moveOnsetsPerSec];
        end
    end
end

adjust.allAdjusts = allAdjusts;
adjust.allJumps = allJumps;
adjust.allAdjusts = allAdjusts;
adjust.allJumps = allJumps;
adjust.singleAdjusts = singleAdjusts;
adjust.meanAdjusts = meanAdjusts;
adjust.medianAdjusts = medianAdjusts;
adjust.jumpSizes = jumpSizes;

meanMove.allMeanMoves = allMeanMoves;
meanMove.allMeanMovesCon = allMeanMovesCon;
meanMove.moveSamples = moveSamples;
meanMove.sideSwitches = sideSwitches;
meanMove.moveOnsets = moveOnsets;

end