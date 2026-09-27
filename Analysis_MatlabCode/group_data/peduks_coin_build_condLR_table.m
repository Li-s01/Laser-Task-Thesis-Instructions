function condLRtable = peduks_coin_build_condLR_table( options, excludedBlocks, subjectData, seqType, moveTol )
%Decomposition of the average learning rate into the two components used by Foucault et al.
%(2025): 
% (i) the proportion of laser events on which the shield was
%actually moved (pMove), 
% and (ii) the average learning rate for actual movements
%   OUT: condLRtable - subID, blockID, sequenceID, instrCond,
%                      instrCondEffect, nEvents, nMoveEvents, pMove,
%                      condLR, condLR_thesisBounds, avgLR_foucaultBounds
%

FOUCAULT_BOUNDS = [-0.6 1.3];
THESIS_BOUNDS   = [0 0.8];

if nargin < 5 || isempty(moveTol)
    moveTol = 0;
end
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
        if isempty(blockData) || ismember(iB, subExcluded) || ~strcmp(charify(blockData.seqType(1)), seqType)
            continue
        end

      
        [~, ~, LRraw, ~, ~, update] = peduks_coin_blockLearningRate(blockData, options);
        LRraw  = LRraw(:);
        update = update(:);

        % avgLR 
        lrThesisAll = winsorize(LRraw, THESIS_BOUNDS);

        % keep only events with a usable learning rate
        ok = isfinite(LRraw) & ~isnan(update);
        LRraw  = LRraw(ok);
        update = update(ok);
        if isempty(LRraw)
            continue
        end

        isMove = abs(update) > moveTol;

        lrF = winsorize(LRraw, FOUCAULT_BOUNDS);
        lrT = winsorize(LRraw, THESIS_BOUNDS);

        nEvents     = numel(LRraw);
        nMoveEvents = sum(isMove);
        if nMoveEvents == 0
            continue   % no movement at all 
        end

        instrChar = charify(blockData.instrCond(1));
        seqID = string(erase(charify(blockData.blockFileName(1)), '_rot180'));

        row = struct('subID', subID, 'blockID', iB, 'sequenceID', seqID, ...
            'instrCond', string(instrChar), 'instrCondEffect', (instrChar=='B')-0.5, ...
            'nEvents', nEvents, 'nMoveEvents', nMoveEvents, ...
            'pMove', nMoveEvents / nEvents, ...
            'condLR', mean(lrF(isMove)), ...
            'condLR_thesisBounds', mean(lrT(isMove)), ...
            'avgLR_foucaultBounds', mean(lrF), ...
            'avgLR_thesisBounds', mean(lrT), ...
            'avgLR_asInThesis', mean(lrThesisAll, 'omitnan'));
        if isempty(rows), rows = row; else, rows(end+1) = row; end 
    end
end

if isempty(rows)
    condLRtable = table();
    return
end

condLRtable = struct2table(rows);

% log-scale columns

condLRtable.logPMove   = log(condLRtable.pMove);
condLRtable.logCondLR  = log(condLRtable.condLR_thesisBounds);
condLRtable.logAvgLR   = log(condLRtable.avgLR_thesisBounds);

% check on the decomposition 
resid  = condLRtable.avgLR_foucaultBounds - condLRtable.pMove .* condLRtable.condLR;
residT = condLRtable.avgLR_thesisBounds   - condLRtable.pMove .* condLRtable.condLR_thesisBounds;
fprintf('\n=== condLR table (%s blocks, n=%d, moveTol=%g) ===\n', ...
    upper(seqType), height(condLRtable), moveTol);
fprintf('  decomposition check, Foucault bounds  avgLR = pMove * condLR : max abs dev = %.3g\n', max(abs(resid)));
fprintf('  decomposition check, thesis bounds     avgLR = pMove * condLR : max abs dev = %.3g\n', max(abs(residT)));
fprintf('  avgLR thesis bounds: this script M = %.4f   vs build_avgLR_table style M = %.4f\n', ...
    mean(condLRtable.avgLR_thesisBounds), mean(condLRtable.avgLR_asInThesis));
fprintf('  pMove   : M = %.3f (SD = %.3f), range [%.3f %.3f]\n', ...
    mean(condLRtable.pMove), std(condLRtable.pMove), min(condLRtable.pMove), max(condLRtable.pMove));
fprintf('  condLR  : M = %.3f (SD = %.3f), range [%.3f %.3f]  (bounds [%.1f %.1f])\n', ...
    mean(condLRtable.condLR), std(condLRtable.condLR), ...
    min(condLRtable.condLR), max(condLRtable.condLR), FOUCAULT_BOUNDS(1), FOUCAULT_BOUNDS(2));
fprintf('  condLR with thesis bounds [%.1f %.1f]: M = %.3f (SD = %.3f), range [%.3f %.3f]\n', ...
    THESIS_BOUNDS(1), THESIS_BOUNDS(2), ...
    mean(condLRtable.condLR_thesisBounds), std(condLRtable.condLR_thesisBounds), ...
    min(condLRtable.condLR_thesisBounds), max(condLRtable.condLR_thesisBounds));
residLog = condLRtable.logAvgLR - (condLRtable.logPMove + condLRtable.logCondLR);
fprintf('  log decomposition check  logAvgLR = logPMove + logCondLR : max abs dev = %.3g\n', ...
    max(abs(residLog)));

end

function y = winsorize(x, b)
y = x;
y(y < b(1)) = b(1);
y(y > b(2)) = b(2);
end

function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
