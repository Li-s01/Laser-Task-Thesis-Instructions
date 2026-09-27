function sensitivityTable = CP_RT_windowSize_sensitivity_check( options, subjectData, windowSizesSec )
%Refits the RT block-level LMM for other window sizes
%and reports, per window, the instrCondEffect estimate and how many RTs
%are missing - overall and per instruction condition. One run gives the
%whole window-size table reported in the thesis.

%   IN:  options, subjectData (optional, as usual)
%        windowSizesSec - window sizes in seconds (default 4:1:9)
%   OUT: sensitivityTable - one row per window size: windowSec, nObs,
%        nMissing, pctMissing, pctMissing_A, pctMissing_B,
%        diffPP_BminusA, modelUsed, estimate, SE, df, tStat, pValue

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end
if nargin < 3 || isempty(windowSizesSec)
    windowSizesSec = 4:1:9;
end

fsmp = options.behav.fsample;
rows = struct([]);

for iW = 1:numel(windowSizesSec)
    windowSec = windowSizesSec(iW);
    optsThis = options;
    optsThis.behav.adjustPostSamples = windowSec * fsmp;

    fprintf('\n--- window = %.0fs ---\n', windowSec);
    [T, lmmTable] = peduks_coin_test_RT_blocklevel(optsThis, subjectData, 'CP');

    nObs = height(T);
    isMissing = isnan(T.rt);
    nMissing = sum(isMissing);

    % missingness per instruction condition, in percent of that
    % condition's block x jumpSize cells
    pctMissA = 100 * mean(isMissing(T.instrCond == "A"));
    pctMissB = 100 * mean(isMissing(T.instrCond == "B"));

    row = struct( ...
        'windowSec', windowSec, ...
        'nObs', nObs, ...
        'nMissing', nMissing, ...
        'pctMissing', 100*nMissing/nObs, ...
        'pctMissing_A', pctMissA, ...
        'pctMissing_B', pctMissB, ...
        'diffPP_BminusA', pctMissB - pctMissA, ...
        'modelUsed', lmmTable.modelUsed, ...
        'estimate', lmmTable.estimate, ...
        'SE', lmmTable.SE, ...
        'df', lmmTable.df, ...
        'tStat', lmmTable.tStat, ...
        'pValue', lmmTable.pValue);
    if isempty(rows), rows = row; else, rows(end+1) = row; end 
end

sensitivityTable = struct2table(rows);

fprintf('\n=== RT window-size sensitivity check (CP) ===\n');
disp(sensitivityTable);

end