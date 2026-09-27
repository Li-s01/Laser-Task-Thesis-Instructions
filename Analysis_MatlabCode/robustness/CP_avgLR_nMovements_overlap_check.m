function [mergedTable, corrResult, controlModel] = CP_avgLR_nMovements_overlap_check( options, subjectData )
%Joins the block-level avgLR and nMovements tables, 
% correlates logAvgLR with
%logNMovements, and refits avgLR with logNMovements as a covariate.
%   OUT: mergedTable - joined avgLR/nMovements block table 
%        corrResult - struct: r, p, n
%        controlModel - the LME with logNMovements as covariate

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);

avgLRtable = peduks_coin_build_avgLR_table(options, excludedBlocks, subjectData, 'CP');
nMovTable  = peduks_coin_build_nMovements_table(options, excludedBlocks, subjectData, 'CP');

mergedTable = innerjoin(avgLRtable, nMovTable, 'Keys', {'subID','blockID'}, ...
    'RightVariables', {'nMovements','logNMovements'});

[r, p] = corr(mergedTable.logAvgLR, mergedTable.logNMovements);
corrResult = struct('r', r, 'p', p, 'n', height(mergedTable));
fprintf('\n=== correlation: logAvgLR vs. logNMovements (CP blocks) ===\n');
fprintf('r = %.3f, p = %.3g, n = %d blocks\n', r, p, height(mergedTable));

%does the avgLR instrCond effect stays when controlling for nMovements?
CORR_DEGENERATE_CUTOFF = 0.95;
formulaBaseRE  = 'logAvgLR ~ instrCondEffect + (1|subID) + (1|sequenceID)';
formulaSlopeRE = 'logAvgLR ~ instrCondEffect + (1+instrCondEffect|subID) + (1|sequenceID)';
fitBaseRE = fitlme(mergedTable, formulaBaseRE);
lastwarn('');
fitSlopeRE = fitlme(mergedTable, formulaSlopeRE);
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
else
    re = '(1|subID) + (1|sequenceID)';
end

fitPlain     = fitlme(mergedTable, ['logAvgLR ~ instrCondEffect + ' re]);
controlModel = fitlme(mergedTable, ['logAvgLR ~ instrCondEffect + logNMovements + ' re]);

cPlain = fitPlain.Coefficients;
cCtrl  = controlModel.Coefficients;
idxPlain = strcmp(cPlain.Name, 'instrCondEffect');
idxCtrl  = strcmp(cCtrl.Name, 'instrCondEffect');

fprintf('\n=== avgLR instrCondEffect, without vs. with logNMovements as covariate ===\n');
fprintf('without:             Estimate = %.4f, SE = %.4f, p = %.4g\n', ...
    cPlain.Estimate(idxPlain), cPlain.SE(idxPlain), cPlain.pValue(idxPlain));
fprintf('with logNMovements:  Estimate = %.4f, SE = %.4f, p = %.4g\n', ...
    cCtrl.Estimate(idxCtrl), cCtrl.SE(idxCtrl), cCtrl.pValue(idxCtrl));

end
