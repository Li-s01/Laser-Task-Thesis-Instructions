function [T, lmmTable] = peduks_coin_test_RT_blocklevel( options, subjectData, seqType )
%Random-slope selection for the
%instrCond effect on RT. Follows procedure and criteria as
%implemented in peduks_coin_select_random_slope.m

%   OUT: T - the block-level RT table used
%        lmmTable - one row, see peduks_coin_select_random_slope.m

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end
if nargin < 3 || isempty(seqType)
    seqType = 'CP';
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
T = peduks_coin_build_RT_table(options, excludedBlocks, subjectData, seqType);

formulaBase  = 'logRT ~ jumpSize + instrCondEffect + (1|subID) + (1|sequenceID)';
formulaSlope = 'logRT ~ jumpSize + instrCondEffect + (1+instrCondEffect|subID) + (1|sequenceID)';

% model choice, diagnostics and the result row
lmmTable = peduks_coin_select_random_slope(T, formulaBase, formulaSlope, seqType, 'nObs');

end
