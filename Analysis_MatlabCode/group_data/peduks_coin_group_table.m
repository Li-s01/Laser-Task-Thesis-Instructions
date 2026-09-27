function groupTable = peduks_coin_group_table( options, excludedBlocks, subjectData )
%Stacks each subject's condition means into one
%table, one row per subject, one column per (seqType x instrCond x metric)
%combination 
%   OUT:    groupTable - table, one row per subject

if nargin < 3
    subjectData = [];
end

subIDs = options.subjectIDs;
groupTable = table();
if nargin < 2 || isempty(excludedBlocks)
    excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
end

% one row per subject
for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    perform = peduks_coin_get_subject_field(subID, options, subjectData, 'perform');
    if isempty(subData) || isempty(perform)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);
    % condition means for this subject
    cs = peduks_coin_condition_means(perform, options, subExcluded);

    row = table(subID, 'VariableNames', {'subID'});
    row.totalReward = cs.totalReward;

    for iS = 1:numel(options.seqIDs)
        for iI = 1:numel(options.instrIDs)
            c = cs.byCondition{iS, iI};
            % builds column names like CP_A_meanInaction
            prefix = [options.seqIDs{iS} '_' options.instrIDs{iI} '_'];
            metricFields = setdiff(fieldnames(c), {'label','blocks'}, 'stable');
            for iM = 1:numel(metricFields)
                row.([prefix metricFields{iM}]) = c.(metricFields{iM});
            end
            row.([prefix 'nBlocks']) = numel(c.blocks);
        end
    end

    groupTable = [groupTable; row]; 
end

end
