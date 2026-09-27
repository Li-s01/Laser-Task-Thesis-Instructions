%CP_RW_EXCLUSIONDIAGNOSTICS

options = peduks_coin_options;
subjectData = peduks_coin_load_all_subjects(options);

subIDs = options.subjectIDs;
rows = struct([]);

for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    perform = peduks_coin_get_subject_field(subID, options, subjectData, 'perform');
    if isempty(subData) || isempty(perform)
        continue
    end

    for iB = unique(subData.blockID)'
        blockData = subData(subData.blockID == iB, :);
        if isempty(blockData)
            continue
        end
        if iB > numel(perform)
            continue
        end
        p = perform{iB};
        seqType = charify(blockData.seqType(1));

        blockMove = peduks_coin_blockMovements(blockData, options);
        nMov = blockMove.nMovements;

        trueMeanIncl = blockData.trueMean(blockData.includeFrame);
        nMeanCPs = sum(diff(trueMeanIncl) ~= 0);

        shield = blockData.shield(blockData.includeFrame);
        shield1stDeriv = [0; diff(shield)];
        notMoving = shield1stDeriv == 0;
        dRun = diff([0; notMoving; 0]);
        runStarts = find(dRun == 1);
        runEnds = find(dRun == -1) - 1;
        runLengthsAll = runEnds - runStarts + 1;

        % start-of-block inactivity: 
        if ~isempty(runStarts) && runStarts(1) == 1
            startInactivityGap = runLengthsAll(1) / options.behav.fsample;
        else
            startInactivityGap = 0;
        end

        runLengths = sort(runLengthsAll, 'descend');
        if numel(runLengths) >= 2
            secondMaxInactivityGap = runLengths(2) / options.behav.fsample;
        else
            secondMaxInactivityGap = NaN;
        end

        row = struct('subID', subID, 'blockID', iB, 'seqType', string(seqType), ...
            'instrCond', string(charify(blockData.instrCond(1))), ...
            'nMovements', nMov, 'nMeanCPs', nMeanCPs, ...
            'maxInactivityGap', p.maxInactivityGap, ...
            'secondMaxInactivityGap', secondMaxInactivityGap, ...
            'startInactivityGap', startInactivityGap, ...
            'maxInaction', p.maxInaction, 'nInaction2s', p.nInaction2s, ...
            'meanInaction', p.meanInaction, 'reward', p.reward);
        if isempty(rows), rows = row; else, rows(end+1) = row; end 
    end
end

T = struct2table(rows);

fprintf('\nBlocks total: %d (CP=%d, RW=%d)\n', height(T), sum(T.seqType=='CP'), sum(T.seqType=='RW'));
fprintf('Blocks with startInactivityGap > 10s: %d\n', sum(T.startInactivityGap > 10));
fprintf('\nFull diagnostic table (CP and RW):\n');
disp(T)

function s = charify(x)
if iscell(x), s = char(x{1}); else, s = char(x); end
end