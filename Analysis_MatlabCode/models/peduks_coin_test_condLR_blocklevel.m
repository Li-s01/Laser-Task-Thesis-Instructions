function [T, lmmTable] = peduks_coin_test_condLR_blocklevel( options, subjectData, seqType, metrics, forceModel )
%Tests the instrCond effect on the two
%components of the average learning rate: pMove (how often the shield was moved) and
%condLR (the learning rate over those events only). 
%
%   IN:  options, subjectData (optional, as usual)
%        seqType    - 'CP' (default) or 'RW'
%        metrics    - default {'logCondLR', 'logPMove', 'logAvgLR'}
%        forceModel - 'auto' (default) selects per metric. 'base' or
%                     'slope' forces the same random-effects structure on
%                     all of them, which is what makes the estimates add
%                     up exactly - use it when reporting the
%                     decomposition as additive.
%   OUT: T        - the condLR table used
%        lmmTable - one row per metric, as returned by
%                   peduks_coin_select_random_slope.m plus a metric
%                   column and the residual diagnostics

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end
if nargin < 3 || isempty(seqType)
    seqType = 'CP';
end
if nargin < 4 || isempty(metrics)
    metrics = {'logCondLR', 'logPMove', 'logAvgLR'};
end
if nargin < 5 || isempty(forceModel)
    forceModel = 'auto';
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
T = peduks_coin_build_condLR_table(options, excludedBlocks, subjectData, seqType);

rows = cell(numel(metrics), 1);

for iM = 1:numel(metrics)
    metric = metrics{iM};

    formulaBase  = sprintf('%s ~ instrCondEffect + (1|subID) + (1|sequenceID)', metric);
    formulaSlope = sprintf('%s ~ instrCondEffect + (1+instrCondEffect|subID) + (1|sequenceID)', metric);

    % model choice, diagnostics and the result row
    row = peduks_coin_select_random_slope(T, formulaBase, formulaSlope, seqType, ...
        'nBlocks', forceModel, true);
    rows{iM} = addvars(row, string(metric), 'Before', 1, 'NewVariableNames', 'metric');
end

lmmTable = vertcat(rows{:});

fprintf('\n=== block-level decomposition of avgLR: instrCond effect (%s, forceModel=%s) ===\n', ...
    seqType, forceModel);
disp(lmmTable(:, {'metric','nBlocks','modelUsed','estimate','SE','df','tStat','pValue','slopeLRT_p'}));

if all(ismember({'logCondLR','logPMove','logAvgLR'}, metrics))
    e = @(m) lmmTable.estimate(lmmTable.metric == m);
    fprintf('\n  additivity check: logPMove (%.4f) + logCondLR (%.4f) = %.4f  vs logAvgLR %.4f\n', ...
        e("logPMove"), e("logCondLR"), e("logPMove") + e("logCondLR"), e("logAvgLR"));
end

fprintf('\n=== condition means ===\n');
for iM = 1:numel(metrics)
    m = metrics{iM};
    isA = T.instrCond == "A";
    fprintf('  %-8s  A (volatile, low noise) M = %.4f   B (stable, high noise) M = %.4f\n', ...
        m, mean(T.(m)(isA)), mean(T.(m)(~isA)));
end

fprintf('\n=== random-effects and residual diagnostics ===\n');
disp(lmmTable(:, {'metric','subID_interceptSD','subID_slopeSD','subID_corr', ...
    'sequenceID_interceptSD','resid_skewness','resid_lilliefors_p'}));

end
