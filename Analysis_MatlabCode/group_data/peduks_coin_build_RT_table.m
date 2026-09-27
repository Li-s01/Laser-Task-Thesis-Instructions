function RTtable = peduks_coin_build_RT_table( options, excludedBlocks, subjectData, seqType )
%Block-level RT: for each CP block, jumps are
%grouped by jumpSize within that block only, averaged pointwise per 
% jumpSize group, and RT computed once per
%block x jumpSize group via peduks_coin_compute_RT_from_adjustment 

%   OUT: RTtable - subID, blockID, sequenceID, instrCond,
%                  instrCondEffect, jumpSize, rt, logRT, nJumps

if nargin < 4 || isempty(seqType)
    seqType = 'CP';
end
if nargin < 3
    subjectData = [];
end
if nargin < 2 || isempty(excludedBlocks)
    excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
end

subIDs = options.subjectIDs;
rows = struct([]);

% go through every subject, then every block of that subject
for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(subData)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);
    blockIDs = unique(subData.blockID);
    for iB = blockIDs(:)'
        blockData = subData(subData.blockID == iB, :);
        % skip excluded blocks and blocks of the other sequence type
        if isempty(blockData) || ismember(iB, subExcluded) || ~strcmp(charify(blockData.seqType(1)), seqType)
            continue
        end

        [allAdjust, jumpSize, ~] = peduks_coin_blockAdjustments(blockData, options);
        if isempty(allAdjust)
            continue
        end
        js = round(jumpSize, 4);

        instrChar = charify(blockData.instrCond(1));
        seqID = string(erase(charify(blockData.blockFileName(1)), '_rot180'));

        
        uniqueJS = unique(js);
        avgTraces = nan(numel(uniqueJS), size(allAdjust,2));
        nJumpsPerJS = nan(numel(uniqueJS), 1);
        for iJS = 1:numel(uniqueJS)
            thisGroup = allAdjust(js == uniqueJS(iJS), :);
            avgTraces(iJS,:) = mean(thisGroup, 1, 'omitnan');
            nJumpsPerJS(iJS) = size(thisGroup, 1);
        end

        % time until the averaged adjustment covers half the jump
        rtVals = peduks_coin_compute_RT_from_adjustment(avgTraces, uniqueJS, options);

        for iJS = 1:numel(uniqueJS)
            row = struct('subID', subID, 'blockID', iB, 'sequenceID', seqID, ...
                'instrCond', string(instrChar), 'instrCondEffect', (instrChar=='B')-0.5, ...
                'jumpSize', uniqueJS(iJS), 'rt', rtVals(iJS), 'logRT', log(rtVals(iJS)), ...
                'nJumps', nJumpsPerJS(iJS));
            if isempty(rows), rows = row; else, rows(end+1) = row; end 
        end
    end
end

if isempty(rows)
    RTtable = table();
else
    RTtable = struct2table(rows);
end

end

function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
