function [T, lmmTable] = CP_RW_metrics_boxplots( options, subjectData )
%CP_RW_METRICS_BOXPLOTS Boxplots comparing CP vs. RW blocks 
%for reward, nMovements, meanInaction, maxInaction, nInaction2s, meanPosPE,
%and meanDiff2mean. 
%   OUT: T - long-format table with one row per block: subID,
%       blockID, seqType, instrCond, instrCondEffect, sequenceID, and the
%       7 measures 
%       lmmTable - one row per (seqType x metric): modelUsed,the
%       instrCondEffect estimate, SE, df, tStat, pValue and 95% CI 

if nargin < 1 || isempty(options)
    options = peduks_coin_options;
end
if nargin < 2 || isempty(subjectData)
    subjectData = peduks_coin_load_all_subjects(options);
end

excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);

subIDs = options.subjectIDs;
rows = struct([]);

for iSub = 1:numel(subIDs)
    subID = subIDs(iSub);
    subData = peduks_coin_get_subject_field(subID, options, subjectData, 'subData');
    perform = peduks_coin_get_subject_field(subID, options, subjectData, 'perform');
    if isempty(subData) || isempty(perform)
        continue
    end

    subExcluded = excludedBlocks.blockID(excludedBlocks.subID == subID);

    for iB = unique(subData.blockID)'
        if ismember(iB, subExcluded)
            continue
        end
        blockData = subData(subData.blockID == iB, :);
        if isempty(blockData), continue; end

        p = perform{iB};
        blockMove = peduks_coin_blockMovements(blockData, options);

        instrChar = charify(blockData.instrCond(1));
        if strcmp(instrChar, options.instrIDs{1})
            instrCondEffect = -0.5;
        else
            instrCondEffect = 0.5;
        end
        seqID = string(erase(charify(blockData.blockFileName(1)), '_rot180'));

        row = struct( ...
            'subID', subID, ...
            'blockID', iB, ...
            'seqType', string(unique(blockData.seqType)), ...
            'instrCond', string(instrChar), ...
            'instrCondEffect', instrCondEffect, ...
            'sequenceID', seqID, ...
            'reward', p.reward, ...
            'nMovements', blockMove.nMovements, ...
            'logNMovements', log(blockMove.nMovements), ...
            'meanInaction', p.meanInaction, ...
            'maxInaction', p.maxInaction, ...
            'nInaction2s', p.nInaction2s, ...
            'meanPosPE', p.meanPosPE, ...
            'meanDiff2mean', p.meanDiff2mean);

        if isempty(rows), rows = row; else, rows(end+1) = row; end
    end
end

T = struct2table(rows);

%% Figure: one subplot per measure, CP vs RW boxplots side by side

metrics  = {'reward','nMovements','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};
titles   = {'Reward','Number of Movements','Max. Inaction Duration (s)','Inaction Episodes >2s','Tracking Error (rad)','Inference Error (rad)'};

groupOrder = {'CP','RW'};
colorCP = [0.0902 0.6353 0.6353];  
colorRW = [0.8392 0.1843 0.3529];  
colors  = [colorCP; colorRW];
panelLetters = {'A','B','C','D','E','F'};  

figure('Name', 'CP vs. RW: general tracking measures', 'Color', 'w', ...
    'Position', [100 100 1050 650]);

for m = 1:numel(metrics)
    subplot(2, 3, m);
    metric = metrics{m};
    vals = T.(metric);
    grp  = cellstr(T.seqType);

    boxplot(vals, grp, 'GroupOrder', groupOrder, 'Colors', 'k', 'Symbol', 'k.');

    
    h = findobj(gca, 'Tag', 'Box');
    for j = 1:numel(h)
        patch(get(h(j), 'XData'), get(h(j), 'YData'), ...
            colors(numel(h)-j+1, :), 'FaceAlpha', 0.6);
    end

    nCP = sum(strcmp(grp, 'CP'));
    nRW = sum(strcmp(grp, 'RW'));
    set(gca, 'XTickLabel', {sprintf('CP (N=%d)', nCP), sprintf('RW (N=%d)', nRW)});
    title(titles{m}, 'FontWeight', 'normal');
    box off

   
    text(-0.15, 1.12, panelLetters{m}, 'Units', 'normalized', ...
        'FontWeight', 'bold', 'FontSize', 14, 'VerticalAlignment', 'top');
end

set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');

% save the figure
% exportgraphics(gcf, fullfile(pwd, 'CP_RW_general_measures.png'), 'Resolution', 300);

%% LMM: instrCond (A vs B) effect on each measure, fit separately for CP and RW

CORR_DEGENERATE_CUTOFF = 0.95;

lmmMetrics = {'reward','logNMovements','meanInaction','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};
lmmLabels  = {'reward','nMovements (log)','meanInaction','maxInaction','nInaction2s','meanPosPE','meanDiff2mean'};

lmmRows = struct([]);
for iType = 1:numel(groupOrder)
    seqTypeLabel = groupOrder{iType};
    Tsub = T(T.seqType == seqTypeLabel, :);

    for m = 1:numel(lmmMetrics)
        metric = lmmMetrics{m};
        metricLabel = lmmLabels{m};

        formulaBase  = [metric ' ~ instrCondEffect + (1|subID) + (1|sequenceID)'];
        formulaSlope = [metric ' ~ instrCondEffect + (1+instrCondEffect|subID) + (1|sequenceID)'];

        fitBase = fitlme(Tsub, formulaBase);

        lastwarn('');  
        fitSlope = fitlme(Tsub, formulaSlope);
        warnMsg = lastwarn;
        hasSingularWarning = ~isempty(warnMsg) && ...
            (contains(warnMsg, 'singular', 'IgnoreCase', true) || ...
             contains(warnMsg, 'converge', 'IgnoreCase', true) || ...
             contains(warnMsg, 'iteration limit', 'IgnoreCase', true));

        comparison = compare(fitBase, fitSlope);
        lrtP = comparison.pValue(2);

        % random-effects covariance diagnostics 
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
        idx = strcmp(c.Name, 'instrCondEffect');

        lmmRow = struct( ...
            'seqType', string(seqTypeLabel), ...
            'metric', string(metricLabel), ...
            'modelUsed', modelUsed, ...
            'estimate', c.Estimate(idx), ...
            'SE', c.SE(idx), ...
            'df', c.DF(idx), ...
            'tStat', c.tStat(idx), ...
            'pValue', c.pValue(idx), ...
            'CI_low', c.Lower(idx), ...
            'CI_high', c.Upper(idx), ...
            'slopeLRT_p', lrtP, ...
            'slopeSupported_a02', lrtP < 0.2, ...
            'slopeSingularWarning', hasSingularWarning, ...
            'subID_interceptSD', statsSub.Estimate(isInterceptSD), ...
            'subID_slopeSD', statsSub.Estimate(isSlopeSD), ...
            'subID_slopeSD_low', statsSub.Lower(isSlopeSD), ...
            'subID_slopeSD_high', statsSub.Upper(isSlopeSD), ...
            'subID_corr', corrEstimate, ...
            'subID_corr_low', statsSub.Lower(isCorr), ...
            'subID_corr_high', statsSub.Upper(isCorr), ...
            'sequenceID_interceptSD', statsSeq.Estimate(1), ...
            'model', string(modelFormula));
        if isempty(lmmRows), lmmRows = lmmRow; else, lmmRows(end+1) = lmmRow; end
    end
end

lmmTable = struct2table(lmmRows);

fprintf('\n=== instrCond (A vs. B) effect, by seqType and measure ===\n');
disp(lmmTable(:, {'seqType','metric','modelUsed','estimate','SE','df','tStat','pValue','slopeLRT_p','slopeSupported_a02'}));

fprintf('\n=== subID random-effects covariance diagnostics ===\n');
disp(lmmTable(:, {'seqType','metric','subID_interceptSD','subID_slopeSD', ...
    'subID_corr','subID_corr_low','subID_corr_high','sequenceID_interceptSD'}));

end


function s = charify(x)
if iscell(x)
    s = char(x{1});
else
    s = char(x);
end
end
