function [ blockMove, correctLeft, correctRight ] = ...
    peduks_coin_blockMovements( blockData, options )

% Start by excluding everything that happened prior to the first hit
startSample = find(blockData.includeFrame);
startSample = startSample(1);

blockData(1:startSample-1, :) = [];

% Determine movement onsets
shield1stDeriv = [0; diff(blockData.shield)];
shield2ndDeriv = [0; 0; diff(diff(blockData.shield))];

leftTurnOnsets = shield1stDeriv>0 &shield2ndDeriv>0;
rightTurnOnsets = shield1stDeriv<0 &shield2ndDeriv<0;

leftOnsetIdx = find(leftTurnOnsets);
rightOnsetIdx = find(rightTurnOnsets);

% Find movement offsets (more difficult as we don't always get the
% derivatives we would expect for the offsets if people end their move by 
% pressing the other direction 
leftOffsetIdx = [];
for iOn = 1: numel(leftOnsetIdx)
    for iFrame = leftOnsetIdx(iOn) : numel(shield1stDeriv)
        if shield1stDeriv(iFrame) <= 0
            break
        end
    end
    leftOffsetIdx(iOn,1) = iFrame;
end

rightOffsetIdx = [];
for iOn = 1: numel(rightOnsetIdx)
    for iFrame = rightOnsetIdx(iOn) : numel(shield1stDeriv)
        if shield1stDeriv(iFrame) >= 0
            break
        end
    end
    rightOffsetIdx(iOn,1) = iFrame;
end

%GEÄNDERT
leftStepSizes = blockData.shield(leftOffsetIdx-1) - blockData.shield(leftOnsetIdx-1);
rightStepSizes = blockData.shield(rightOnsetIdx-1) - blockData.shield(rightOffsetIdx-1);

% exclude very small steps
origLeftStepSizes = leftStepSizes;
origRightStepSizes = rightStepSizes;


%% group together steps that are very close together in time
leftDiscard = [];
newLeftStepSizes = leftStepSizes;
for iL = 2: numel(leftOnsetIdx)
    if (leftOnsetIdx(iL) - leftOffsetIdx(iL-1)) ...
            < options.behav.minResponseDistance
        leftDiscard = [leftDiscard; iL];
        % determine relevant stepSize to adjust
        relStep = iL-1;
        for iBack = 1: iL
            if ~ismember(relStep, leftDiscard)
                break;
            else
                relStep = relStep-1;
            end
        end
        % adjust step size of relevant previous step
        newLeftStepSizes(relStep) = ...
            blockData.shield(leftOffsetIdx(iL)-1) ...
            - blockData.shield(leftOnsetIdx(relStep)-1);
    end
end
cleanLeftStepSizes = newLeftStepSizes;
cleanLeftOnsetIdx = leftOnsetIdx;
cleanLeftStepSizes(leftDiscard) = [];
cleanLeftOnsetIdx(leftDiscard) = [];

rightDiscard = [];
newRightStepSizes = rightStepSizes;
for iR = 2: numel(rightOnsetIdx)
    if (rightOnsetIdx(iR) - rightOffsetIdx(iR-1)) ...
            < options.behav.minResponseDistance
        rightDiscard = [rightDiscard; iR];
        % determine relevant stepSize to adjust
        relStep = iR-1;
        for iBack = 1: iR
            if ~ismember(relStep, rightDiscard)
                break;
            else
                relStep = relStep-1;
            end
        end
        % adjust step size of relevant previous step
        newRightStepSizes(relStep) = ...
            blockData.shield(rightOnsetIdx(relStep)-1) ...
            - blockData.shield(rightOffsetIdx(iR)-1);
    end
end
cleanRightStepSizes = newRightStepSizes;
cleanRightOnsetIdx = rightOnsetIdx;
cleanRightStepSizes(rightDiscard) = [];
cleanRightOnsetIdx(rightDiscard) = [];

%% Exclude very small steps
smallStepsLeft = find(cleanLeftStepSizes < options.behav.minStepSize);
cleanLeftOnsetIdx(smallStepsLeft) = [];
cleanLeftStepSizes(smallStepsLeft) = [];
smallStepsRight = find(cleanRightStepSizes < options.behav.minStepSize);
cleanRightOnsetIdx(smallStepsRight) = [];
cleanRightStepSizes(smallStepsRight) = [];

%% Sort into movements towards/away from the mean
distance2mean = mod((blockData.trueMean - blockData.shield) + pi, 2*pi) - pi;
correctLeft = distance2mean(cleanLeftOnsetIdx)>0;
correctRight = distance2mean(cleanRightOnsetIdx)<0;

%% Collate output
blockMove.left.onsets = cleanLeftOnsetIdx + startSample-1;
blockMove.left.stepSizes = cleanLeftStepSizes;
blockMove.left.smallSteps = numel(smallStepsLeft);
blockMove.left.unifiedSteps = numel(leftDiscard);
blockMove.left.origStepSizes = origLeftStepSizes;

blockMove.left.onsetsTowards = cleanLeftOnsetIdx(correctLeft)  + startSample-1;
blockMove.left.stepSizesTowards = cleanLeftStepSizes(correctLeft);
blockMove.left.onsetsAway = cleanLeftOnsetIdx(~correctLeft)  + startSample-1;
blockMove.left.stepSizesAway = cleanLeftStepSizes(~correctLeft);

blockMove.right.onsets = cleanRightOnsetIdx + startSample-1;
blockMove.right.stepSizes = cleanRightStepSizes;
blockMove.right.smallSteps = numel(smallStepsRight);
blockMove.right.unifiedSteps = numel(rightDiscard);
blockMove.right.origStepSizes = origRightStepSizes;

blockMove.right.onsetsTowards = cleanRightOnsetIdx(correctRight)  + startSample-1;
blockMove.right.stepSizesTowards = cleanRightStepSizes(correctRight);
blockMove.right.onsetsAway = cleanRightOnsetIdx(~correctRight)  + startSample-1;
blockMove.right.stepSizesAway = cleanRightStepSizes(~correctRight);

blockMove.nMovements = numel(cleanLeftOnsetIdx) + numel(cleanRightOnsetIdx);
blockMove.nTowards = sum(correctLeft)+sum(correctRight);
blockMove.nAway = sum(~correctLeft)+sum(~correctRight);
blockMove.stepSizes = [cleanLeftStepSizes; cleanRightStepSizes];
blockMove.stepSizesTowards = [blockMove.left.stepSizesTowards; blockMove.right.stepSizesTowards];
blockMove.stepSizesAway = [blockMove.left.stepSizesAway; blockMove.right.stepSizesAway];
blockMove.origStepSizes = [origLeftStepSizes; origRightStepSizes];
blockMove.nSmallSteps = numel(smallStepsLeft) + numel(smallStepsRight);
blockMove.nUnifiedSteps = numel(leftDiscard) + numel(rightDiscard);


end