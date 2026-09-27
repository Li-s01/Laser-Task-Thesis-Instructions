function [RTtable, T] = peduks_coin_add_RT_new( T, options, excludedBlocks, subjectData )
%Computes RT.
%pools raw per-jump adjustment trajectories across all CP blocks of a
%condition, groups them by jump size, averages pointwise within each
%jump-size group, then computes RT once per jump-size group.
%   OUT:    RTtable - long format: subID, instrCond, instrCondEffect,
%                     jumpSize, rt - one row per subject x condition x
%                     jump size
%           T       - input T, with CP_A_RT/CP_B_RT added 

if nargin < 4
    subjectData = [];
end

subIDs = options.subjectIDs;
rows = struct([]);
rtA = nan(numel(subIDs),1);
rtB = nan(numel(subIDs),1);
if nargin < 3 || isempty(excludedBlocks)
    excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
end

for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    if isempty(subData)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);
    % collect the raw jump trajectories of this subject, separately per instruction
    pooled.A = struct('adjust', [], 'jumpSize', []);
    pooled.B = struct('adjust', [], 'jumpSize', []);
    blockIDs = unique(subData.blockID);
    for iB = blockIDs(:)'
        blockData = subData(subData.blockID == iB, :);
        
        if ismember(iB, subExcluded) || ~strcmp(charify(blockData.seqType(1)), 'CP')
            continue
        end
        instrChar = charify(blockData.instrCond(1));
        [allAdjust, jumpSize, ~] = peduks_coin_blockAdjustments(blockData, options);
        if isempty(allAdjust)
            continue
        end
        % all blocks of one instruction are pooled
        pooled.(instrChar).adjust = [pooled.(instrChar).adjust; allAdjust];
        pooled.(instrChar).jumpSize = [pooled.(instrChar).jumpSize; jumpSize(:)];
    end

    for c = {'A','B'}
        instrChar = c{1};
        adjustAll = pooled.(instrChar).adjust;
        jsAll = round(pooled.(instrChar).jumpSize, 4);
        if isempty(adjustAll)
            continue
        end

        % trajectories are averaged within a jump size
        uniqueJS = unique(jsAll);
        avgTraces = nan(numel(uniqueJS), size(adjustAll,2));
        for iJS = 1:numel(uniqueJS)
            avgTraces(iJS,:) = mean(adjustAll(jsAll==uniqueJS(iJS),:), 1, 'omitnan');
        end

        % time until the averaged adjustment covers half the jump
        rtVals = peduks_coin_compute_RT_from_adjustment(avgTraces, uniqueJS, options);

        for iJS = 1:numel(uniqueJS)
            row = struct('subID', subID, 'instrCond', instrChar, ...
                'instrCondEffect', (instrChar=='B')-0.5, ...
                'jumpSize', uniqueJS(iJS), 'rt', rtVals(iJS));
            if isempty(rows), rows = row; else, rows(end+1) = row; end 
        end

        if strcmp(instrChar,'A')
            % the subject value is the mean over the jump sizes
            rtA(iSub) = mean(rtVals, 'omitnan');
        else
            rtB(iSub) = mean(rtVals, 'omitnan');
        end
    end
end

RTtable = struct2table(rows);
T.CP_A_RT = rtA;
T.CP_B_RT = rtB;

end

function s = charify(x)
if iscell(x), s = char(x{1}); else, s = char(x); end
end
