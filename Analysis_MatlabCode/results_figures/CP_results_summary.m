%  CP RESULTS SUMMARY 
% Produces the LMM
%  results table for meanInaction, IKS, nMovements (log), slopeLast3, 
% RT, and ELR, plus the grand-average and
%  A-vs-B kernel weight plots 

options = peduks_coin_options;

% load subData/perform for every subject 
subjectData= peduks_coin_load_all_subjects(options);

% compute exclusion criteria 
excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);

%Long-format table for the block-level metrics with sequenceID
L = peduks_coin_group_long_table(options, excludedBlocks, subjectData);
Lcp = L(L.seqType == 'CP', :);

%earlyA: true for counterbalancing orders 1 & 4 otherwise false
Lcp.earlyA = ismember(mod(Lcp.subID,4)+1, [1,4]);

simpleMetrics = {'meanInaction', 'iks'};

rows = struct([]);
for iM = 1:numel(simpleMetrics)
    m = simpleMetrics{iM};

    fitBase = fitlme(Lcp, [m ' ~ instrCondEffect + (1|subID) + (1|sequenceID)']);
    cB = fitBase.Coefficients;
    idxIntercept = strcmp(cB.Name, '(Intercept)');
    idxB = strcmp(cB.Name, 'instrCondEffect');

    
    fitAdj = fitlme(Lcp, [m ' ~ instrCondEffect + earlyA + (1|subID) + (1|sequenceID)']);
    cA = fitAdj.Coefficients;
    idxA = strcmp(cA.Name, 'instrCondEffect');

    fitOrder = fitlme(Lcp, [m ' ~ instrCondEffect*earlyA + (1|subID) + (1|sequenceID)']);
    cO = fitOrder.Coefficients;
    idxO = strcmp(cO.Name, 'instrCondEffect:earlyA_1');

    row = struct('metric', string(m), ...
        'intercept', cB.Estimate(idxIntercept), ...
        'estimate', cB.Estimate(idxB), 'SE', cB.SE(idxB), ...
        'CI_low', cB.Lower(idxB), 'CI_high', cB.Upper(idxB), ...
        'pValue', cB.pValue(idxB), ...
        'estimate_orderAdj', cA.Estimate(idxA), 'SE_orderAdj', cA.SE(idxA), ...
        'pValue_orderAdj', cA.pValue(idxA), ...
        'orderInteraction_est', cO.Estimate(idxO), 'orderInteraction_p', cO.pValue(idxO), ...
        'model', "metric ~ instrCondEffect + (1|subID) + (1|sequenceID)");
    if isempty(rows), rows = row; else, rows(end+1) = row; end 
end

%nMovements
nMovTable = peduks_coin_build_nMovements_table(options, excludedBlocks, subjectData);
nMovTable.earlyA = ismember(mod(nMovTable.subID,4)+1, [1,4]);

% random-slope selection 
CORR_DEGENERATE_CUTOFF = 0.95;

fitNMbaseRE = fitlme(nMovTable, 'logNMovements ~ instrCondEffect + (1|subID) + (1|sequenceID)');
lastwarn('');
fitNMslopeRE = fitlme(nMovTable, 'logNMovements ~ instrCondEffect + (1+instrCondEffect|subID) + (1|sequenceID)');
warnMsg = lastwarn;
hasSingularWarning = ~isempty(warnMsg) && ...
    (contains(warnMsg, 'singular', 'IgnoreCase', true) || ...
     contains(warnMsg, 'converge', 'IgnoreCase', true) || ...
     contains(warnMsg, 'iteration limit', 'IgnoreCase', true));

comparisonNM = compare(fitNMbaseRE, fitNMslopeRE);
lrtP_NM = comparisonNM.pValue(2);

[~, ~, covStatsNM] = covarianceParameters(fitNMslopeRE);
statsSubNM = covStatsNM{1};
isCorrNM = strcmp(statsSubNM.Type, 'corr');
corrEstimateNM = statsSubNM.Estimate(isCorrNM);

isDegenerateNM = hasSingularWarning || abs(corrEstimateNM) >= CORR_DEGENERATE_CUTOFF;
useSlopeNM = (lrtP_NM < 0.05) && ~isDegenerateNM;

if useSlopeNM
    modelUsedNM = "slope";
    reNM = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    modelUsedNM = "intercept-only";
    reNM = '(1|subID) + (1|sequenceID)';
end
fprintf('nMovements random-slope selection: %s (LRT p=%.4g)\n', modelUsedNM, lrtP_NM);

fitNMbase = fitlme(nMovTable, ['logNMovements ~ instrCondEffect + ' reNM]);
fitNMadj = fitlme(nMovTable, ['logNMovements ~ instrCondEffect + earlyA + ' reNM]);
fitNMorder = fitlme(nMovTable, ['logNMovements ~ instrCondEffect*earlyA + ' reNM]);
cB = fitNMbase.Coefficients; cA = fitNMadj.Coefficients; cO = fitNMorder.Coefficients;
idxIntercept = strcmp(cB.Name, '(Intercept)');
idxB = strcmp(cB.Name, 'instrCondEffect');
idxA = strcmp(cA.Name, 'instrCondEffect');
idxO = strcmp(cO.Name, 'instrCondEffect:earlyA_1');

rowNM = struct('metric', "nMovements (log)", ...
    'intercept', cB.Estimate(idxIntercept), ...
    'estimate', cB.Estimate(idxB), 'SE', cB.SE(idxB), ...
    'CI_low', cB.Lower(idxB), 'CI_high', cB.Upper(idxB), ...
    'pValue', cB.pValue(idxB), ...
    'estimate_orderAdj', cA.Estimate(idxA), 'SE_orderAdj', cA.SE(idxA), ...
    'pValue_orderAdj', cA.pValue(idxA), ...
    'orderInteraction_est', cO.Estimate(idxO), 'orderInteraction_p', cO.pValue(idxO), ...
    'model', string(['logNMovements ~ instrCondEffect + ' reNM]));
rows(end+1) = rowNM;

resultsTableFull = struct2table(rows);

%slopeLast3(no sequenceID)
T = peduks_coin_group_table(options, excludedBlocks, subjectData);
[slopeTable, T] = peduks_coin_build_last3_pooled_table(options, T, excludedBlocks, subjectData);
slopeTable.earlyA = ismember(mod(slopeTable.subID,4)+1, [1,4]);

fitSLbase = fitlme(slopeTable, 'slopeLast3 ~ instrCondEffect + (1|subID)');
fitSLadj = fitlme(slopeTable, 'slopeLast3 ~ instrCondEffect + earlyA + (1|subID)');
fitSLorder = fitlme(slopeTable, 'slopeLast3 ~ instrCondEffect*earlyA + (1|subID)');
cB = fitSLbase.Coefficients; cA = fitSLadj.Coefficients; cO = fitSLorder.Coefficients;
idxIntercept = strcmp(cB.Name, '(Intercept)');
idxB = strcmp(cB.Name, 'instrCondEffect');
idxA = strcmp(cA.Name, 'instrCondEffect');
idxO = strcmp(cO.Name, 'instrCondEffect:earlyA_1');

rowSL = table("slopeLast3", cB.Estimate(idxIntercept), cB.Estimate(idxB), cB.SE(idxB), ...
    cB.Lower(idxB), cB.Upper(idxB), cB.pValue(idxB), ...
    cA.Estimate(idxA), cA.SE(idxA), cA.pValue(idxA), ...
    cO.Estimate(idxO), cO.pValue(idxO), ...
    "slopeLast3 ~ instrCondEffect + (1|subID)", ...
    'VariableNames', resultsTableFull.Properties.VariableNames);

% RT 
[RTtable, T] = peduks_coin_add_RT_new(T, options, excludedBlocks, subjectData);

[RTblockTable, lmmRT] = peduks_coin_test_RT_blocklevel(options, subjectData);
RTblockTable.earlyA = ismember(mod(RTblockTable.subID,4)+1, [1,4]);
fprintf('RT random-slope selection: %s (LRT p=%.4f)\n', lmmRT.modelUsed, lmmRT.slopeLRT_p);

if lmmRT.modelUsed == "slope"
    reRT = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reRT = '(1|subID) + (1|sequenceID)';
end

fitRTbase = fitlme(RTblockTable, ['logRT ~ jumpSize + instrCondEffect + ' reRT]);
fitRTadj = fitlme(RTblockTable, ['logRT ~ jumpSize + instrCondEffect + earlyA + ' reRT]);
fitRTorder = fitlme(RTblockTable, ['logRT ~ jumpSize + instrCondEffect*earlyA + ' reRT]);
cB = fitRTbase.Coefficients; cA = fitRTadj.Coefficients; cO = fitRTorder.Coefficients;
idxIntercept = strcmp(cB.Name, '(Intercept)');
idxB = strcmp(cB.Name, 'instrCondEffect');
idxA = strcmp(cA.Name, 'instrCondEffect');
idxO = strcmp(cO.Name, 'instrCondEffect:earlyA_1');

rowRT = table("RT (log)", cB.Estimate(idxIntercept), cB.Estimate(idxB), cB.SE(idxB), ...
    cB.Lower(idxB), cB.Upper(idxB), cB.pValue(idxB), ...
    cA.Estimate(idxA), cA.SE(idxA), cA.pValue(idxA), ...
    cO.Estimate(idxO), cO.pValue(idxO), ...
    string(['logRT ~ jumpSize + instrCondEffect + ' reRT]), ...
    'VariableNames', resultsTableFull.Properties.VariableNames);

% ELR 
T = peduks_coin_add_ELR_to_table(T, options, excludedBlocks, subjectData);

[ELRtable, lmmELR] = peduks_coin_test_ELR_blocklevel(options, subjectData);
ELRtable.earlyA = ismember(mod(ELRtable.subID,4)+1, [1,4]);
fprintf('ELR random-slope selection: %s (LRT p=%.4f)\n', lmmELR.modelUsed, lmmELR.slopeLRT_p);

if lmmELR.modelUsed == "slope"
    reELR = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reELR = '(1|subID) + (1|sequenceID)';
end

fitELRbase = fitlme(ELRtable, ['ELR ~ instrCondEffect + ' reELR]);
fitELRadj = fitlme(ELRtable, ['ELR ~ instrCondEffect + earlyA + ' reELR]);
fitELRorder = fitlme(ELRtable, ['ELR ~ instrCondEffect*earlyA + ' reELR]);
cB = fitELRbase.Coefficients; cA = fitELRadj.Coefficients; cO = fitELRorder.Coefficients;
idxIntercept = strcmp(cB.Name, '(Intercept)');
idxB = strcmp(cB.Name, 'instrCondEffect');
idxA = strcmp(cA.Name, 'instrCondEffect');
idxO = strcmp(cO.Name, 'instrCondEffect:earlyA_1');

rowELR = table("ELR", cB.Estimate(idxIntercept), cB.Estimate(idxB), cB.SE(idxB), ...
    cB.Lower(idxB), cB.Upper(idxB), cB.pValue(idxB), ...
    cA.Estimate(idxA), cA.SE(idxA), cA.pValue(idxA), ...
    cO.Estimate(idxO), cO.pValue(idxO), ...
    string(['ELR ~ instrCondEffect + ' reELR]), ...
    'VariableNames', resultsTableFull.Properties.VariableNames);

% avgLR 
[avgLRtable, lmmAvgLR] = peduks_coin_test_avgLR_blocklevel(options, subjectData);
avgLRtable.earlyA = ismember(mod(avgLRtable.subID,4)+1, [1,4]);
fprintf('avgLR random-slope selection: %s (LRT p=%.4f)\n', lmmAvgLR.modelUsed, lmmAvgLR.slopeLRT_p);

if lmmAvgLR.modelUsed == "slope"
    reAvgLR = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reAvgLR = '(1|subID) + (1|sequenceID)';
end

fitAvgLRbase = fitlme(avgLRtable, ['logAvgLR ~ instrCondEffect + ' reAvgLR]);
fitAvgLRadj = fitlme(avgLRtable, ['logAvgLR ~ instrCondEffect + earlyA + ' reAvgLR]);
fitAvgLRorder = fitlme(avgLRtable, ['logAvgLR ~ instrCondEffect*earlyA + ' reAvgLR]);
cB = fitAvgLRbase.Coefficients; cA = fitAvgLRadj.Coefficients; cO = fitAvgLRorder.Coefficients;
idxIntercept = strcmp(cB.Name, '(Intercept)');
idxB = strcmp(cB.Name, 'instrCondEffect');
idxA = strcmp(cA.Name, 'instrCondEffect');
idxO = strcmp(cO.Name, 'instrCondEffect:earlyA_1');

rowAvgLR = table("avgLR (log)", cB.Estimate(idxIntercept), cB.Estimate(idxB), cB.SE(idxB), ...
    cB.Lower(idxB), cB.Upper(idxB), cB.pValue(idxB), ...
    cA.Estimate(idxA), cA.SE(idxA), cA.pValue(idxA), ...
    cO.Estimate(idxO), cO.pValue(idxO), ...
    string(['logAvgLR ~ instrCondEffect + ' reAvgLR]), ...
    'VariableNames', resultsTableFull.Properties.VariableNames);

%Combine everything into one table
resultsTableFull = [resultsTableFull; rowSL; rowRT; rowELR; rowAvgLR];
resultsTableFull = sortrows(resultsTableFull, 'pValue')

%Kernel plots grand average and A vs. B 
kernelData = peduks_coin_build_kernel_array(options, excludedBlocks, subjectData);

fh1 = peduks_coin_plot_grandAverage_kernels(kernelData(:,1,:,:), options);
fh1.Name = 'CP grand-average kernel';
figure(fh1); sgtitle('CP: Grand-Average Kernel');

fh2 = peduks_coin_plot_mainEffects_kernels(kernelData(:,1,:,:));
fh2.Name = 'CP kernel A vs B';
figure(fh2); sgtitle('CP kernel A vs B');

% Paired AvsB comparison plots 
figure('Name', 'CP nMovements A vs B');
boxplot(nMovTable.nMovements, nMovTable.instrCond);
xlabel('Instruction'); ylabel('nMovements per block');
title('CP: nMovements per block, A vs. B');
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');

