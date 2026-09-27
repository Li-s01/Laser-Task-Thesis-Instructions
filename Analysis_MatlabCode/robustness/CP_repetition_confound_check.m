function [Tcp, repCheckTable, mainRepCheckTable] = CP_repetition_confound_check( options, subjectData )
%Checks whether the CP instrCond effect is
%confounded with first-vs-second presentation of the same sequence

%   OUT: Tcp - CP block table with isRot180/blockInSes/order added
%        repCheckTable - per general tracking metric: modelUsed,
%        estimate/pValue with and without each covariate, shift in SE
%        mainRepCheckTable - same, for RT/ELR/avgLR

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

%build the CP table with isRot180 / blockInSes / order
[T, ~] = CP_RW_metrics_boxplots(options, subjectData);
Tcp = T(T.seqType == "CP", :);

Tcp.isRot180 = false(height(Tcp),1);
Tcp.blockInSes = nan(height(Tcp),1);
Tcp.order = nan(height(Tcp),1);
for i = 1:height(Tcp)
    subData = peduks_coin_get_subject_field(Tcp.subID(i), options, subjectData, 'subData');
    b = subData(subData.blockID == Tcp.blockID(i), :);
    Tcp.isRot180(i)   = contains(charify(b.blockFileName(1)), '_rot180');
    Tcp.blockInSes(i) = b.blockInSes(1);
    Tcp.order(i)      = b.order(1);
end

fprintf('\n=== instrCond x isRot180 crosstab (CP blocks) ===\n');
disp(crosstab(cellstr(Tcp.instrCond), Tcp.isRot180));

fprintf('\n=== mean blockInSes by order x instrCond (CP blocks) ===\n');
disp(varfun(@mean, Tcp, 'InputVariables', 'blockInSes', ...
    'GroupingVariables', {'order','instrCond'}));


CORR_DEGENERATE_CUTOFF = 0.95;
metrics = {'reward','logNMovements','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};
labels  = {'reward','nMovements (log)','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};

repRows = struct([]);
for m = 1:numel(metrics)
    metric = metrics{m};
    label = labels{m};

    formulaBaseRE  = [metric ' ~ instrCondEffect + (1|subID) + (1|sequenceID)'];
    formulaSlopeRE = [metric ' ~ instrCondEffect + (1+instrCondEffect|subID) + (1|sequenceID)'];

    fitBaseRE = fitlme(Tcp, formulaBaseRE);
    lastwarn('');
    fitSlopeRE = fitlme(Tcp, formulaSlopeRE);
    warnMsg = lastwarn;
    hasSingularWarning = ~isempty(warnMsg) && ...
        (contains(warnMsg, 'singular', 'IgnoreCase', true) || ...
         contains(warnMsg, 'converge', 'IgnoreCase', true) || ...
         contains(warnMsg, 'iteration limit', 'IgnoreCase', true));
    comparison = compare(fitBaseRE, fitSlopeRE);
    lrtP = comparison.pValue(2);
    [~, ~, covStats] = covarianceParameters(fitSlopeRE);
    statsSub = covStats{1};
    isCorr = strcmp(statsSub.Type, 'corr');
    corrEstimate = statsSub.Estimate(isCorr);
    isDegenerate = hasSingularWarning || abs(corrEstimate) >= CORR_DEGENERATE_CUTOFF;
    useSlope = (lrtP < 0.05) && ~isDegenerate;
    if useSlope
        re = '(1+instrCondEffect|subID) + (1|sequenceID)';
        modelUsed = "slope";
    else
        re = '(1|subID) + (1|sequenceID)';
        modelUsed = "intercept-only";
    end

    fitBase = fitlme(Tcp, [metric ' ~ instrCondEffect + ' re]);
    fitRot  = fitlme(Tcp, [metric ' ~ instrCondEffect + isRot180 + ' re]);
    fitBIS  = fitlme(Tcp, [metric ' ~ instrCondEffect + blockInSes + ' re]);

    cBase = fitBase.Coefficients; cRot = fitRot.Coefficients; cBIS = fitBIS.Coefficients;
    idxBase = strcmp(cBase.Name, 'instrCondEffect');
    idxRot  = strcmp(cRot.Name, 'instrCondEffect');
    idxBIS  = strcmp(cBIS.Name, 'instrCondEffect');

    row = struct( ...
        'metric', string(label), ...
        'modelUsed', modelUsed, ...
        'estimate_base', cBase.Estimate(idxBase), 'SE_base', cBase.SE(idxBase), 'pValue_base', cBase.pValue(idxBase), ...
        'estimate_withRot180', cRot.Estimate(idxRot), 'SE_withRot180', cRot.SE(idxRot), 'pValue_withRot180', cRot.pValue(idxRot), ...
        'estimate_withBlockInSes', cBIS.Estimate(idxBIS), 'SE_withBlockInSes', cBIS.SE(idxBIS), 'pValue_withBlockInSes', cBIS.pValue(idxBIS), ...
        'shift_rot180_in_SEunits', (cRot.Estimate(idxRot) - cBase.Estimate(idxBase)) / cBase.SE(idxBase));
    if isempty(repRows), repRows = row; else, repRows(end+1) = row; end 
end
repCheckTable = struct2table(repRows);

fprintf('\n=== repetition/order-in-session confound check (CP, general tracking measures) ===\n');
disp(repCheckTable(:, {'metric','modelUsed','estimate_base','pValue_base', ...
    'estimate_withRot180','pValue_withRot180','estimate_withBlockInSes','pValue_withBlockInSes','shift_rot180_in_SEunits'}));

%same check for RT, ELR, avgLR
mainNames    = {'RT (log)', 'ELR', 'avgLR (log)'};
mainDepVars  = {'logRT', 'ELR', 'logAvgLR'};
mainExtraFixed = {'jumpSize + ', '', ''};

mainRows = struct([]);
for m = 1:numel(mainNames)
    label = mainNames{m};
    depVar = mainDepVars{m};
    extraFixed = mainExtraFixed{m};

    switch label
        case 'RT (log)'
            [Tm, lmmTable] = peduks_coin_test_RT_blocklevel(options, subjectData);
        case 'ELR'
            [Tm, lmmTable] = peduks_coin_test_ELR_blocklevel(options, subjectData);
        case 'avgLR (log)'
            [Tm, lmmTable] = peduks_coin_test_avgLR_blocklevel(options, subjectData);
    end

    Tm.isRot180 = false(height(Tm),1);
    Tm.blockInSes = nan(height(Tm),1);
    for i = 1:height(Tm)
        subData = peduks_coin_get_subject_field(Tm.subID(i), options, subjectData, 'subData');
        b = subData(subData.blockID == Tm.blockID(i), :);
        Tm.isRot180(i)   = contains(charify(b.blockFileName(1)), '_rot180');
        Tm.blockInSes(i) = b.blockInSes(1);
    end

    if lmmTable.modelUsed == "slope"
        re = '(1+instrCondEffect|subID) + (1|sequenceID)';
    else
        re = '(1|subID) + (1|sequenceID)';
    end

    fitBase = fitlme(Tm, [depVar ' ~ ' extraFixed 'instrCondEffect + ' re]);
    fitRot  = fitlme(Tm, [depVar ' ~ ' extraFixed 'instrCondEffect + isRot180 + ' re]);
    fitBIS  = fitlme(Tm, [depVar ' ~ ' extraFixed 'instrCondEffect + blockInSes + ' re]);

    cBase = fitBase.Coefficients; cRot = fitRot.Coefficients; cBIS = fitBIS.Coefficients;
    idxBase = strcmp(cBase.Name, 'instrCondEffect');
    idxRot  = strcmp(cRot.Name, 'instrCondEffect');
    idxBIS  = strcmp(cBIS.Name, 'instrCondEffect');

    row = struct( ...
        'metric', string(label), ...
        'modelUsed', lmmTable.modelUsed, ...
        'estimate_base', cBase.Estimate(idxBase), 'SE_base', cBase.SE(idxBase), 'pValue_base', cBase.pValue(idxBase), ...
        'estimate_withRot180', cRot.Estimate(idxRot), 'SE_withRot180', cRot.SE(idxRot), 'pValue_withRot180', cRot.pValue(idxRot), ...
        'estimate_withBlockInSes', cBIS.Estimate(idxBIS), 'SE_withBlockInSes', cBIS.SE(idxBIS), 'pValue_withBlockInSes', cBIS.pValue(idxBIS), ...
        'shift_rot180_in_SEunits', (cRot.Estimate(idxRot) - cBase.Estimate(idxBase)) / cBase.SE(idxBase));
    if isempty(mainRows), mainRows = row; else, mainRows(end+1) = row; end 
end
mainRepCheckTable = struct2table(mainRows);

fprintf('\n=== repetition/order-in-session confound check (CP, confirmatory measures) ===\n');
disp(mainRepCheckTable(:, {'metric','modelUsed','estimate_base','pValue_base', ...
    'estimate_withRot180','pValue_withRot180','estimate_withBlockInSes','pValue_withBlockInSes','shift_rot180_in_SEunits'}));

fprintf('\nNote: slopeLast3 (kernel slope) is not included above - see function help for why.\n');

end

function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
