function checkResid = peduks_coin_check_all_residuals( options, subjectData )
%Residual-normality check (skewness, Lilliefors test, QQ-plot) for every metric in
%CP_results_summary.m
%   OUT: checkResid - one row per metric: n, skewness, lilliefors_h/p,
%        modelUsed, model (formula fit)

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);

rows = struct([]);
residLabels = {};
residVecs = {};

% meanInaction, iks 
L = peduks_coin_group_long_table(options, excludedBlocks, subjectData);
Lcp = L(L.seqType == 'CP', :);

simpleMetrics = {'meanInaction', 'iks'};
for iM = 1:numel(simpleMetrics)
    m = simpleMetrics{iM};
    formula = [m ' ~ instrCondEffect + (1|subID) + (1|sequenceID)'];
    fitM = fitlme(Lcp, formula);
    resid = residuals(fitM);
    [h, p] = lillietest(resid);
    row = struct('metric', string(m), 'n', numel(resid), 'skewness', skewness(resid), ...
        'lilliefors_h', h, 'lilliefors_p', p, 'modelUsed', "intercept-only (fixed)", 'model', string(formula));
    if isempty(rows), rows = row; else, rows(end+1) = row; end
    residLabels{end+1} = m; residVecs{end+1} = resid; 
end

%nMovements (log) 
nMovTable = peduks_coin_build_nMovements_table(options, excludedBlocks, subjectData);
formula = 'logNMovements ~ instrCondEffect + (1|subID) + (1|sequenceID)';
fitNM = fitlme(nMovTable, formula);
resid = residuals(fitNM);
[h, p] = lillietest(resid);
row = struct('metric', "nMovements (log)", 'n', numel(resid), 'skewness', skewness(resid), ...
    'lilliefors_h', h, 'lilliefors_p', p, 'modelUsed', "intercept-only (fixed)", 'model', string(formula));
rows(end+1) = row;
residLabels{end+1} = 'nMovements (log)'; residVecs{end+1} = resid;

%slopeLast3 
T = peduks_coin_group_table(options, excludedBlocks, subjectData);
[slopeTable, T] = peduks_coin_build_last3_pooled_table(options, T, excludedBlocks, subjectData);
formula = 'slopeLast3 ~ instrCondEffect + (1|subID)';
fitSL = fitlme(slopeTable, formula);
resid = residuals(fitSL);
[h, p] = lillietest(resid);
row = struct('metric', "slopeLast3", 'n', numel(resid), 'skewness', skewness(resid), ...
    'lilliefors_h', h, 'lilliefors_p', p, 'modelUsed', "intercept-only (fixed)", 'model', string(formula));
rows(end+1) = row;
residLabels{end+1} = 'slopeLast3'; residVecs{end+1} = resid;

%RT (log)
[RTblockTable, lmmRT] = peduks_coin_test_RT_blocklevel(options, subjectData);
if lmmRT.modelUsed == "slope"
    reRT = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reRT = '(1|subID) + (1|sequenceID)';
end
formula = ['logRT ~ jumpSize + instrCondEffect + ' reRT];
fitRT = fitlme(RTblockTable, formula);
resid = residuals(fitRT);
[h, p] = lillietest(resid);
row = struct('metric', "RT (log)", 'n', numel(resid), 'skewness', skewness(resid), ...
    'lilliefors_h', h, 'lilliefors_p', p, 'modelUsed', lmmRT.modelUsed, 'model', string(formula));
rows(end+1) = row;
residLabels{end+1} = 'RT (log)'; residVecs{end+1} = resid;

%ELR 
[ELRtable, lmmELR] = peduks_coin_test_ELR_blocklevel(options, subjectData);
if lmmELR.modelUsed == "slope"
    reELR = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reELR = '(1|subID) + (1|sequenceID)';
end
formula = ['ELR ~ instrCondEffect + ' reELR];
fitELR = fitlme(ELRtable, formula);
resid = residuals(fitELR);
[h, p] = lillietest(resid);
row = struct('metric', "ELR", 'n', numel(resid), 'skewness', skewness(resid), ...
    'lilliefors_h', h, 'lilliefors_p', p, 'modelUsed', lmmELR.modelUsed, 'model', string(formula));
rows(end+1) = row;
residLabels{end+1} = 'ELR'; residVecs{end+1} = resid;

%avgLR 
[avgLRtable, lmmAvgLR] = peduks_coin_test_avgLR_blocklevel(options, subjectData);
if lmmAvgLR.modelUsed == "slope"
    reAvgLR = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reAvgLR = '(1|subID) + (1|sequenceID)';
end
formula = ['logAvgLR ~ instrCondEffect + ' reAvgLR];
fitAvgLR = fitlme(avgLRtable, formula);
resid = residuals(fitAvgLR);
[h, p] = lillietest(resid);
row = struct('metric', "avgLR (log)", 'n', numel(resid), 'skewness', skewness(resid), ...
    'lilliefors_h', h, 'lilliefors_p', p, 'modelUsed', lmmAvgLR.modelUsed, 'model', string(formula));
rows(end+1) = row;
residLabels{end+1} = 'avgLR (log)'; residVecs{end+1} = resid;

%summary table
checkResid = struct2table(rows);
fprintf('\n=== residual normality check, all metrics (CP) ===\n');
disp(checkResid(:, {'metric','n','skewness','lilliefors_h','lilliefors_p','modelUsed'}));

%QQ-plots
nMetrics = numel(residLabels);
nCols = 4;
nRows = ceil(nMetrics / nCols);
figure('Name', 'Residual normality check, all metrics', 'Color', 'w', ...
    'Position', [100 100 1100 260*nRows]);
for iM = 1:nMetrics
    subplot(nRows, nCols, iM);
    qqplot(residVecs{iM});
    title(sprintf('%s (skew=%.2f)', residLabels{iM}, skewness(residVecs{iM})));
end
sgtitle('QQ-plots of model residuals vs. normal, all metrics (CP)');

end
