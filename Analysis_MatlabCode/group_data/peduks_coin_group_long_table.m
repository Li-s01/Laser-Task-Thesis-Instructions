function longTable = peduks_coin_group_long_table( options, excludedBlocks, subjectData )
%Stacks each subject's block-level perform
%data into one long-format table - one row per subject x block. Includes
%sequenceID for random effect

% the block-level measures carried into the table
metrics = {'meanPosPE', 'meanDiff2mean', 'overallMove', 'meanInaction', ...
    'reward', 'meanLR', 'medianLR', 'meanLRcorr', 'secsSinceLastMove', ...
    'iks', 'kernelSlope', 'meanRT', 'percentMovingAtConstMean', 'meanELR', 'maxInactivityGap'};

subIDs = options.subjectIDs;
longTable = table();
if nargin < 3
    subjectData = [];
end
if nargin < 2 || isempty(excludedBlocks)
    excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
end

% one row per subject and block
for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    perform = peduks_coin_get_subject_field(subID, options, subjectData, 'perform');
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(perform) || isempty(subData)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);

    for iB = 1:numel(perform)
        if ismember(iB, subExcluded)
            continue
        end
        p = perform{iB};
        row = table(subID, iB, 'VariableNames', {'subID','blockID'});
        row.seqType = string(charify(p.seqType));
        row.instrCond = string(charify(p.instrCond));
        % centred contrast: instruction A is -0.5, B is +0.5
        if strcmp(row.instrCond, options.instrIDs{1})
            row.instrCondEffect = -0.5;
        else
            row.instrCondEffect = 0.5;
        end
        fn = subData.blockFileName(subData.blockID == iB);
        % both presentations of a sequence share this ID, so fitlme can use it as a random effect
        row.sequenceID = string(erase(charify(fn(1)), '_rot180'));
        for iM = 1:numel(metrics)
            row.(metrics{iM}) = p.(metrics{iM});
        end
        longTable = [longTable; row]; 
    end
end

end


function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
