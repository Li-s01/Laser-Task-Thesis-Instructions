function flagged = peduks_coin_flag_dropout_blocks( perform, threshold, metricName )
%Lists blocks with >= threshold seconds
%of shield inactivity.
%   IN:     perform    - cell array of per-block performance structs
%           threshold  - seconds of inactivity to flag (default 20)
%           metricName - 'secsSinceLastMove' (default)
%                        or 'maxInactivityGap' 
%   OUT:    flagged    - table: blockID, seqType, instrCond, value

if nargin < 2
    threshold = 20;
end
if nargin < 3
    metricName = 'secsSinceLastMove';
end

nBlocks = numel(perform);
blockID = (1:nBlocks)';
seqType = cell(nBlocks,1);
instrCond = cell(nBlocks,1);
val = nan(nBlocks,1);

for iB = 1:nBlocks
    seqType{iB} = charify(perform{iB}.seqType);
    instrCond{iB} = charify(perform{iB}.instrCond);
    val(iB) = perform{iB}.(metricName);
end

isFlagged = val >= threshold;
flagged = table(blockID(isFlagged), seqType(isFlagged), instrCond(isFlagged), val(isFlagged), ...
    'VariableNames', {'blockID','seqType','instrCond',metricName});

if isempty(flagged)
    fprintf('No blocks with >= %d s %s.\n', threshold, metricName);
else
    fprintf('%d block(s) with >= %d s %s:\n', height(flagged), threshold, metricName);
    disp(flagged);
end

end


function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end