function [generalTable, mainTable] = CP_RW_satterthwaite_check( options, subjectData )
%CP_RW_SATTERTHWAITE_CHECK Recomputes instrCondEffect significance with
%Satterthwaite-approximated degrees of freedom instead of fitlme's
%residual df, for every general tracking measure (both seqType) and for
%RT, ELR, avgLR and slopeLast3.


if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

CORR_DEGENERATE_CUTOFF = 0.95;

% general tracking measures (CP + RW)
[T, ~] = CP_RW_metrics_boxplots(options, subjectData);
metrics = {'reward','logNMovements','meanInaction','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};
labels  = {'reward','nMovements (log)','meanInaction','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};
seqTypes = {'CP','RW'};

rows = struct([]);
for s = 1:numel(seqTypes)
    seqType = seqTypes{s};
    Tsub = T(T.seqType == seqType, :);
    for m = 1:numel(metrics)
        metric = metrics{m};
        label = labels{m};

        formulaBaseRE  = [metric ' ~ instrCondEffect + (1|subID) + (1|sequenceID)'];
        formulaSlopeRE = [metric ' ~ instrCondEffect + (1+instrCondEffect|subID) + (1|sequenceID)'];

        fitBaseRE = fitlme(Tsub, formulaBaseRE);
        lastwarn('');
        fitSlopeRE = fitlme(Tsub, formulaSlopeRE);
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
            fitUsed = fitSlopeRE;
            modelUsed = "slope";
        else
            fitUsed = fitBaseRE;
            modelUsed = "intercept-only";
        end

        row = buildSatterthwaiteRow(fitUsed, modelUsed, string(label));
        row.seqType = string(seqType);
        if isempty(rows), rows = row; else, rows(end+1) = row; end
    end
end
generalTable = struct2table(rows);
generalTable = generalTable(:, {'seqType','metric','modelUsed','estimate','SE', ...
    'df_residual','tStat_residual','pValue_residual', ...
    'df_satterthwaite','tStat_satterthwaite','pValue_satterthwaite'});

fprintf('\n=== Satterthwaite vs. residual df: general tracking measures ===\n');
disp(generalTable);

%RT, ELR, avgLR, slopeLast3; CP only
mainRows = struct([]);

[RTt, lmmRT] = peduks_coin_test_RT_blocklevel(options, subjectData);
if lmmRT.modelUsed == "slope"
    reRT = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reRT = '(1|subID) + (1|sequenceID)';
end
fitRT = fitlme(RTt, ['logRT ~ jumpSize + instrCondEffect + ' reRT]);
row = buildSatterthwaiteRow(fitRT, lmmRT.modelUsed, "RT (log)");
mainRows = appendRow(mainRows, row);

[ELRt, lmmELR] = peduks_coin_test_ELR_blocklevel(options, subjectData);
if lmmELR.modelUsed == "slope"
    reELR = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reELR = '(1|subID) + (1|sequenceID)';
end
fitELR = fitlme(ELRt, ['ELR ~ instrCondEffect + ' reELR]);
row = buildSatterthwaiteRow(fitELR, lmmELR.modelUsed, "ELR");
mainRows = appendRow(mainRows, row);

[avgLRt, lmmAvgLR] = peduks_coin_test_avgLR_blocklevel(options, subjectData);
if lmmAvgLR.modelUsed == "slope"
    reAvgLR = '(1+instrCondEffect|subID) + (1|sequenceID)';
else
    reAvgLR = '(1|subID) + (1|sequenceID)';
end
fitAvgLR = fitlme(avgLRt, ['logAvgLR ~ instrCondEffect + ' reAvgLR]);
row = buildSatterthwaiteRow(fitAvgLR, lmmAvgLR.modelUsed, "avgLR (log)");
mainRows = appendRow(mainRows, row);

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
Tfull = peduks_coin_group_table(options, excludedBlocks, subjectData);
[slopeTable, ~] = peduks_coin_build_last3_pooled_table(options, Tfull, excludedBlocks, subjectData);
fitSL = fitlme(slopeTable, 'slopeLast3 ~ instrCondEffect + (1|subID)');
row = buildSatterthwaiteRow(fitSL, "intercept-only", "slopeLast3");
mainRows = appendRow(mainRows, row);

mainTable = struct2table(mainRows);
mainTable = mainTable(:, {'metric','modelUsed','estimate','SE', ...
    'df_residual','tStat_residual','pValue_residual', ...
    'df_satterthwaite','tStat_satterthwaite','pValue_satterthwaite'});

fprintf('\n=== Satterthwaite vs. residual df: confirmatory measures (CP) ===\n');
disp(mainTable);

end

function row = buildSatterthwaiteRow(fitUsed, modelUsed, label)
cResid = fitUsed.Coefficients;
idxResid = strcmp(cResid.Name, 'instrCondEffect');

[~, ~, statsSatt] = fixedEffects(fitUsed, 'DFMethod', 'satterthwaite');
idxSatt = strcmp(statsSatt.Name, 'instrCondEffect');

row = struct( ...
    'metric', label, ...
    'modelUsed', string(modelUsed), ...
    'estimate', cResid.Estimate(idxResid), ...
    'SE', cResid.SE(idxResid), ...
    'df_residual', cResid.DF(idxResid), ...
    'tStat_residual', cResid.tStat(idxResid), ...
    'pValue_residual', cResid.pValue(idxResid), ...
    'df_satterthwaite', statsSatt.DF(idxSatt), ...
    'tStat_satterthwaite', statsSatt.tStat(idxSatt), ...
    'pValue_satterthwaite', statsSatt.pValue(idxSatt));
end

function rows = appendRow(rows, row)
if isempty(rows)
    rows = row;
else
    rows(end+1) = row; 
end
end
