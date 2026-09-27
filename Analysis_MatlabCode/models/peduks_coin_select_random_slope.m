function lmmTable = peduks_coin_select_random_slope( T, formulaBase, formulaSlope, seqType, countName, forceModel, residDiag )
%Fits the model with only intercept and the
%random-slope version of a block-level model and picks between them:
%   - the likelihood-ratio test between the two models is significant
%     (compare(fitBase, fitSlope), p < .05), AND
%   - fitlme raised no singularity/convergence warning on the slope
%     model, AND
%   - the by-subject intercept-slope correlation stays below .95
%Otherwise the intercept-only model is used. 
%
%   IN:  T            - block-level table
%        formulaBase  - intercept-only model formula 
%        formulaSlope - same model with (1+instrCondEffect|subID)
%        seqType      - 'CP' or 'RW'
%        countName    - name of the row-count column (default 'nBlocks')
%        forceModel   - 'auto' (default) runs the selection above.
%                       'base' or 'slope' skips it and forces that
%                       random-effects structure on the model. Needed
%                       when several metrics must share one structure,
%                       see peduks_coin_test_condLR_blocklevel.m
%        residDiag    - true also returns skewness and a Lilliefors p of
%                       the residuals of the model used (default false)
%   OUT: lmmTable     - one row: seqType, <countName>, modelUsed,
%                       instrCondEffect estimate/SE/df/tStat/pValue,
%                       slopeLRT_p, slopeSingularWarning and the subID /
%                       sequenceID covariance diagnostics


if nargin < 5 || isempty(countName)
    countName = 'nBlocks';
end
if nargin < 6 || isempty(forceModel)
    forceModel = 'auto';
end
if nargin < 7 || isempty(residDiag)
    residDiag = false;
end

CORR_DEGENERATE_CUTOFF = 0.95;

fitBase = fitlme(T, formulaBase);

lastwarn('');  % clear, so any warning below is caused by fitSlope only
fitSlope = fitlme(T, formulaSlope);
warnMsg = lastwarn;
hasSingularWarning = ~isempty(warnMsg) && ...
    (contains(warnMsg, 'singular', 'IgnoreCase', true) || ...
     contains(warnMsg, 'converge', 'IgnoreCase', true) || ...
     contains(warnMsg, 'iteration limit', 'IgnoreCase', true));

comparison = compare(fitBase, fitSlope);
lrtP = comparison.pValue(2);


[~, ~, covStats] = covarianceParameters(fitSlope);
statsSub = covStats{1};  % subID: (Intercept) std, corr, instrCondEffect std
statsSeq = covStats{2};  % sequenceID: (Intercept) std

isInterceptSD = strcmp(statsSub.Type, 'std') & strcmp(statsSub.Name1, '(Intercept)');
isSlopeSD     = strcmp(statsSub.Type, 'std') & strcmp(statsSub.Name1, 'instrCondEffect');
isCorr        = strcmp(statsSub.Type, 'corr');
corrEstimate  = statsSub.Estimate(isCorr);

isDegenerate = hasSingularWarning || abs(corrEstimate) >= CORR_DEGENERATE_CUTOFF;
switch lower(forceModel)
    case 'base',  useSlope = false;
    case 'slope', useSlope = true;
    otherwise,    useSlope = (lrtP < 0.05) && ~isDegenerate;
end

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
idx = strcmp(c.Name, 'instrCondEffect');

lmmRow = struct( ...
    'seqType', string(seqType), ...
    countName, height(T), ...
    'modelUsed', modelUsed, ...
    'estimate', c.Estimate(idx), ...
    'SE', c.SE(idx), ...
    'df', c.DF(idx), ...
    'tStat', c.tStat(idx), ...
    'pValue', c.pValue(idx), ...
    'slopeLRT_p', lrtP, ...
    'slopeSingularWarning', hasSingularWarning, ...
    'subID_interceptSD', statsSub.Estimate(isInterceptSD), ...
    'subID_slopeSD', statsSub.Estimate(isSlopeSD), ...
    'subID_corr', corrEstimate, ...
    'subID_corr_low', statsSub.Lower(isCorr), ...
    'subID_corr_high', statsSub.Upper(isCorr), ...
    'sequenceID_interceptSD', statsSeq.Estimate(1));

% residual diagnostics of the model that was actually used, for metrics
% that are not log transformed and so are not covered by
% peduks_coin_check_all_residuals.m
if residDiag
    res = residuals(fitUsed);
    res = res(~isnan(res));
    lmmRow.resid_skewness = skewness(res);
    try
        [~, lillieP] = lillietest(res);
    catch
        lillieP = NaN;
    end
    lmmRow.resid_lilliefors_p = lillieP;
end

lmmRow.model = string(modelFormula);

lmmTable = struct2table(lmmRow);

end
