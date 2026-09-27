function pSubData = peduks_coin_runPreprocBehavData( subData, options )
%Goes through behavData collected from csv
%files, unwraps circular degrees into radians and removes all data before
%the first hit.
%   IN:     subData     - table with behav data read from csv file
%           options     - the struct that holds all analysis options

pSubData = table;
nBlocks = 0;
availBlocks = unique(subData.blockID);
for iBlock = 1: numel(availBlocks)
    blockData = subData(subData.blockID == availBlocks(iBlock), :);
    nBlocks = nBlocks +1;
    nRows = size(blockData, 1);

    % extract time according to frames
    matTime = (0:nRows-1)' / options.behav.fsample;

    %% unwrap degrees 
    % convert degrees to radians Geändert
    shieldNorm = mod(mod(blockData.shieldRotation, 360) + 360, 360);
    shield = unwrap(shieldNorm * pi/180);
    laser = unwrap(blockData.laserRotation * pi/180);
    shieldWidth = blockData.shieldDegrees*pi/180;
    trueMean = unwrap(blockData.trueMean * pi/180);
    trueNoise = blockData.trueVariance*pi/180;

    kLaser = round(median(laser - shield) / (2*pi));
    laser = laser - kLaser*2*pi;
    kTrueMean = round(median(trueMean - shield) / (2*pi));
    trueMean = trueMean - kTrueMean*2*pi;
    % compute distance
    laserDistance = mod((laser - shield) + pi, 2*pi) - pi;
    absLaserDistance = abs(laserDistance);

    %% exclude everything that happens before the first hit event
    % but keep ~150ms more so we can look at the run-up to the laser event
    laserEvents = find([0; diff(laser)]);
    tolArea = unique(shieldWidth)/2;
    preEvSmp = options.behav.fsample * options.behav.preFirstLaserTime;
    for iEv = 1:numel(laserEvents)
        if absLaserDistance(laserEvents(iEv)) <= tolArea
            lastSmp2excl = laserEvents(iEv)-1;
            break
        end
    end
    % Remove the samples just before the first event
    lastSmp2excl = max(lastSmp2excl - preEvSmp, 0);
    smp2excl = 1:lastSmp2excl;
    flagIncluded = true(nRows,1);
    flagIncluded(smp2excl) = false;

    newBlockID = iBlock*ones(nRows,1);


    % collect all
    bData = table;
    bData.sessID = blockData.sessID;
    bData.blockID = newBlockID;
    bData.blockInSes = nBlocks*ones(nRows,1);
    bData.seqType = blockData.seqType;               
    bData.instrCond = blockData.instruction_framing; 
    bData.blockFileName = blockData.blockFileName;   % original vs rot180
    bData.order = blockData.order;                  % counterbalancing 1-4
    bData.currentFrame = blockData.currentFrame;
    bData.includeFrame = flagIncluded;
    bData.timeOfFrame = matTime;
    bData.trueMean = trueMean;
    bData.trueNoise = trueNoise;
    bData.laser = laser;
    bData.shield = shield;%
    bData.shieldWidth = shieldWidth;
    bData.laserDistance = laserDistance;
    bData.absLaserDistance = absLaserDistance;
    bData.totalReward = blockData.totalReward; %


    % include in preprocessed subData
    pSubData = [pSubData; bData];

    % if this has been block 12, move to the next session
    if nBlocks == 12
        nBlocks = 0;
    end
end

end