function excludedBlocks = peduks_coin_excluded_blocks( options, subjectData )
%PEDUKS_COIN_EXCLUDED_BLOCKS Returns table of blocks to exclude from all
%analyses, based on criteria. BUT NOT USED IN THE END!
%   OUT: excludedBlocks - table with columns subID, blockID

useExclusionCriteria = false;

if nargin < 2
    subjectData = [];
end

subIDs = options.subjectIDs;
rows = struct([]);

if useExclusionCriteria
for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    perform = peduks_coin_get_subject_field(subID, options, subjectData, 'perform');
    if isempty(subData) || isempty(perform)
        continue
    end

    for iB = unique(subData.blockID)'
        blockData = subData(subData.blockID == iB, :);
        if isempty(blockData), continue; end

        p = perform{iB};
        gap = p.maxInactivityGap;

        if gap >= 45
            row = struct('subID', subID, 'blockID', iB);
            if isempty(rows), rows = row; else, rows(end+1) = row; end 
        end
    end
end
end

if isempty(rows)
    excludedBlocks = table(zeros(0,1), zeros(0,1), 'VariableNames', {'subID','blockID'});
else
    excludedBlocks = struct2table(rows);
end


fprintf('Excluded blocks: %d\n', height(excludedBlocks));
if height(excludedBlocks) > 0
    fprintf('Subjects: %s\n', num2str(unique(excludedBlocks.subID)'));
    disp(excludedBlocks)
end

end
