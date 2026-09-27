function [Tcombined, lmmInteraction, slopeLast3Interaction] = CP_RW_interaction_test( options, subjectData )
%Tests whether the instrCond effect differs
%between CP and RW blocks.
%For the 7 general tracking measures it reuses the per-block table from
%CP_RW_metrics_boxplots.m and fits
%   metric ~ instrCondEffect*seqType + (1|subID) + (1|sequenceID)
%   OUT: Tcombined - the per-block table (CP+RW) used
%        lmmInteraction - one row per general tracking measure: main
%        effect and interaction estimate/SE/df/tStat/pValue, modelUsed,
%        slope-selection and covariance diagnostics, formula fit
%        slopeLast3Interaction - same columns, one row, for slopeLast3

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

CORR_DEGENERATE_CUTOFF = 0.95;

%General tracking measures 
[Tcombined, ~] = CP_RW_metrics_boxplots(options, subjectData);


Tcombined.seqType = categorical(Tcombined.seqType, {'CP','RW'});

metrics = {'reward','logNMovements','meanInaction','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};
labels  = {'reward','nMovements (log)','meanInaction','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};

lmmRows = struct([]);
for m = 1:numel(metrics)
    metric = metrics{m};
    label = labels{m};

    formulaBase  = [metric ' ~ instrCondEffect*seqType + (1|subID) + (1|sequenceID)'];
    formulaSlope = [metric ' ~ instrCondEffect*seqType + (1+instrCondEffect|subID) + (1|sequenceID)'];

    fitBase = fitlme(Tcombined, formulaBase);

    lastwarn('');  
    fitSlope = fitlme(Tcombined, formulaSlope);
    warnMsg = lastwarn;
    hasSingularWarning = ~isempty(warnMsg) && ...
        (contains(warnMsg, 'singular', 'IgnoreCase', true) || ...
         contains(warnMsg, 'converge', 'IgnoreCase', true) || ...
         contains(warnMsg, 'iteration limit', 'IgnoreCase', true));

    comparison = compare(fitBase, fitSlope);
    lrtP = comparison.pValue(2);

    [~, ~, covStats] = covarianceParameters(fitSlope);
    statsSub = covStats{1};  
    statsSeq = covStats{2};  

    isInterceptSD = strcmp(statsSub.Type, 'std') & strcmp(statsSub.Name1, '(Intercept)');
    isSlopeSD     = strcmp(statsSub.Type, 'std') & strcmp(statsSub.Name1, 'instrCondEffect');
    isCorr        = strcmp(statsSub.Type, 'corr');
    corrEstimate  = statsSub.Estimate(isCorr);

    isDegenerate = hasSingularWarning || abs(corrEstimate) >= CORR_DEGENERATE_CUTOFF;
    useSlope = (lrtP < 0.05) && ~isDegenerate;

    if useSlope
        fitUsed = fitSlope;
        modelUsed = "slope";
        modelFormula = formulaSlope;
    else
        fitUsed = fitBase;
        modelUsed = "intercept-only";
        modelFormula = formulaBase;
    end

    c = fitUsed.Coefficients;
    idxMain = find(strcmp(c.Name, 'instrCondEffect'));
    idxInt  = find(contains(c.Name, 'instrCondEffect') & contains(c.Name, 'seqType'));
    if numel(idxMain) ~= 1 || numel(idxInt) ~= 1
        error('CP_RW_interaction_test:coefNotFound', ...
            'Could not uniquely identify the main/interaction term for %s. Coefficient names: %s', ...
            metric, strjoin(c.Name, ', '));
    end

    row = struct( ...
        'metric', string(label), ...
        'modelUsed', modelUsed, ...
        'estimate_CPmain', c.Estimate(idxMain), 'SE_CPmain', c.SE(idxMain), 'pValue_CPmain', c.pValue(idxMain), ...
        'estimate_interaction', c.Estimate(idxInt), 'SE_interaction', c.SE(idxInt), ...
        'df_interaction', c.DF(idxInt), 'tStat_interaction', c.tStat(idxInt), 'pValue_interaction', c.pValue(idxInt), ...
        'slopeLRT_p', lrtP, ...
        'slopeSingularWarning', hasSingularWarning, ...
        'subID_interceptSD', statsSub.Estimate(isInterceptSD), ...
        'subID_slopeSD', statsSub.Estimate(isSlopeSD), ...
        'subID_corr', corrEstimate, ...
        'sequenceID_interceptSD', statsSeq.Estimate(1), ...
        'model', string(modelFormula));
    if isempty(lmmRows), lmmRows = row; else, lmmRows(end+1) = row; end 
end

lmmInteraction = struct2table(lmmRows);

fprintf('\n=== instrCondEffect x seqType interaction, general tracking measures ===\n');
disp(lmmInteraction(:, {'metric','modelUsed','estimate_CPmain','pValue_CPmain', ...
    'estimate_interaction','SE_interaction','df_interaction','tStat_interaction','pValue_interaction'}));

%slopeLast3
excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
T2 = peduks_coin_group_table(options, excludedBlocks, subjectData);

[slopeTableCP, T2] = peduks_coin_build_last3_pooled_table(options, T2, excludedBlocks, subjectData, 'CP');
slopeTableCP.seqType = repmat("CP", height(slopeTableCP), 1);

[slopeTableRW, T2] = peduks_coin_build_last3_pooled_table(options, T2, excludedBlocks, subjectData, 'RW'); 
slopeTableRW.seqType = repmat("RW", height(slopeTableRW), 1);

slopeTableCombined = [slopeTableCP; slopeTableRW];

slopeTableCombined.seqType = categorical(slopeTableCombined.seqType, {'CP','RW'});

fitSL = fitlme(slopeTableCombined, 'slopeLast3 ~ instrCondEffect*seqType + (1|subID)');
c = fitSL.Coefficients;
idxMain = find(strcmp(c.Name, 'instrCondEffect'));
idxInt  = find(contains(c.Name, 'instrCondEffect') & contains(c.Name, 'seqType'));
if numel(idxMain) ~= 1 || numel(idxInt) ~= 1
    error('CP_RW_interaction_test:coefNotFound', ...
        'Could not uniquely identify the main/interaction term for slopeLast3. Coefficient names: %s', ...
        strjoin(c.Name, ', '));
end

slRow = struct( ...
    'metric', "slopeLast3", ...
    'modelUsed', "intercept-only (fixed, no sequenceID)", ...
    'estimate_CPmain', c.Estimate(idxMain), 'SE_CPmain', c.SE(idxMain), 'pValue_CPmain', c.pValue(idxMain), ...
    'estimate_interaction', c.Estimate(idxInt), 'SE_interaction', c.SE(idxInt), ...
    'df_interaction', c.DF(idxInt), 'tStat_interaction', c.tStat(idxInt), 'pValue_interaction', c.pValue(idxInt), ...
    'slopeLRT_p', NaN, 'slopeSingularWarning', false, ...
    'subID_interceptSD', NaN, 'subID_slopeSD', NaN, 'subID_corr', NaN, 'sequenceID_interceptSD', NaN, ...
    'model', "slopeLast3 ~ instrCondEffect*seqType + (1|subID)");
slopeLast3Interaction = struct2table(slRow);

fprintf('\n=== instrCondEffect x seqType interaction, slopeLast3 ===\n');
disp(slopeLast3Interaction(:, {'metric','modelUsed','estimate_CPmain','pValue_CPmain', ...
    'estimate_interaction','SE_interaction','df_interaction','tStat_interaction','pValue_interaction'}));

end
