%  RW RESULTS SUMMARY 
% Produces the LMM
%  results table for meanInaction, IKS, nMovements (log), slopeLast3
%  and tau (exponential decay) on RW blocks plus
%  the grand-average and AvsB kernel weight plots 

options = peduks_coin_options;

% load subData/perform for every subject 
subjectData = peduks_coin_load_all_subjects(options);

% compute exclusion criteria 
excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);

%Long-format table for the block-level metrics
L = peduks_coin_group_long_table(options, excludedBlocks, subjectData);
Lrw = L(L.seqType == 'RW', :);

% earlyA: true for counterbalancing orders 1 & 4
Lrw.earlyA = ismember(mod(Lrw.subID,4)+1, [1,4]);

simpleMetrics = {'meanInaction', 'iks'};

rows = struct([]);
for iM = 1:numel(simpleMetrics)
    m = simpleMetrics{iM};

    fitBase = fitlme(Lrw, [m ' ~ instrCondEffect + (1|subID) + (1|sequenceID)']);
    cB = fitBase.Coefficients;
    idxIntercept = strcmp(cB.Name, '(Intercept)');
    idxB = strcmp(cB.Name, 'instrCondEffect');

    %order-adjusted
    fitAdj = fitlme(Lrw, [m ' ~ instrCondEffect + earlyA + (1|subID) + (1|sequenceID)']);
    cA = fitAdj.Coefficients;
    idxA = strcmp(cA.Name, 'instrCondEffect');

    
    fitOrder = fitlme(Lrw, [m ' ~ instrCondEffect*earlyA + (1|subID) + (1|sequenceID)']);
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
nMovTable = peduks_coin_build_nMovements_table(options, excludedBlocks, subjectData, 'RW');
nMovTable.earlyA = ismember(mod(nMovTable.subID,4)+1, [1,4]);

fitNMbase = fitlme(nMovTable, 'logNMovements ~ instrCondEffect + (1|subID) + (1|sequenceID)');
fitNMadj = fitlme(nMovTable, 'logNMovements ~ instrCondEffect + earlyA + (1|subID) + (1|sequenceID)');
fitNMorder = fitlme(nMovTable, 'logNMovements ~ instrCondEffect*earlyA + (1|subID) + (1|sequenceID)');
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
    'model', "logNMovements ~ instrCondEffect + (1|subID) + (1|sequenceID)");
rows(end+1) = rowNM;

resultsTableRW = struct2table(rows);

%slopeLast3 
T = peduks_coin_group_table(options, excludedBlocks, subjectData);
[slopeTable, T] = peduks_coin_build_last3_pooled_table(options, T, excludedBlocks, subjectData, 'RW');
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
    'VariableNames', resultsTableRW.Properties.VariableNames);

%tau (exponential decay, pooled, bounded fit)  Rows with a divergent
%  fit (NaN) or a poor fit are dropped
%  before the LME 
[tauTable, T] = peduks_coin_build_expdecay_pooled_table(options, T, excludedBlocks, subjectData, 'RW');
badFit = isnan(tauTable.tauPooled) | tauTable.R2pooled < 0;
fprintf('tau (RW): dropping %d/%d subject x condition rows (divergent fit or R2pooled<0)\n', ...
    sum(badFit), height(tauTable));
tauTable = tauTable(~badFit, :);
tauTable.earlyA = ismember(mod(tauTable.subID,4)+1, [1,4]);

fitTAUbase = fitlme(tauTable, 'tauPooled ~ instrCondEffect + (1|subID)');
fitTAUadj = fitlme(tauTable, 'tauPooled ~ instrCondEffect + earlyA + (1|subID)');
fitTAUorder = fitlme(tauTable, 'tauPooled ~ instrCondEffect*earlyA + (1|subID)');
cB = fitTAUbase.Coefficients; cA = fitTAUadj.Coefficients; cO = fitTAUorder.Coefficients;
idxIntercept = strcmp(cB.Name, '(Intercept)');
idxB = strcmp(cB.Name, 'instrCondEffect');
idxA = strcmp(cA.Name, 'instrCondEffect');
idxO = strcmp(cO.Name, 'instrCondEffect:earlyA_1');

rowTAU = table("tau (pooled)", cB.Estimate(idxIntercept), cB.Estimate(idxB), cB.SE(idxB), ...
    cB.Lower(idxB), cB.Upper(idxB), cB.pValue(idxB), ...
    cA.Estimate(idxA), cA.SE(idxA), cA.pValue(idxA), ...
    cO.Estimate(idxO), cO.pValue(idxO), ...
    "tauPooled ~ instrCondEffect + (1|subID)", ...
    'VariableNames', resultsTableRW.Properties.VariableNames);

%Combine everything into one table
resultsTableRW = [resultsTableRW; rowSL; rowTAU];
resultsTableRW = sortrows(resultsTableRW, 'pValue')

%Kernel plots: grand average (raw) + A vs. B 
kernelData = peduks_coin_build_kernel_array(options, excludedBlocks, subjectData);

fh1 = peduks_coin_plot_grandAverage_kernels(kernelData(:,2,:,:), options);
fh1.Name = 'RW grand-average kernel';
figure(fh1); sgtitle('RW - Grand-Average Kernel (raw, 5 lags)');

fh2 = peduks_coin_plot_mainEffects_kernels(kernelData(:,2,:,:));
fh2.Name = 'RW kernel A vs B';
figure(fh2); sgtitle('RW - Kernel Weights A vs. B (significant lags marked)');

%Paired AvsB comparison plots 
figure('Name', 'RW nMovements A vs B');
boxplot(nMovTable.nMovements, nMovTable.instrCond);
xlabel('Instruction'); ylabel('nMovements per block');
title('RW: nMovements per block, A vs. B');
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');
