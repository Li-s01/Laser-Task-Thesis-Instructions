%  combines the CP grand-average/trajectory
%  plots and the CP A-vs-B paired comparison plots into one 2x3 figure

options = peduks_coin_options;
subjectData = peduks_coin_load_all_subjects(options);
excludedBlocks = peduks_coin_excluded_blocks(options, subjectData);
col = peduks_coin_colours;

panelLetters = {'A','B','C','D','E','F'};


kernelData = peduks_coin_build_kernel_array(options, excludedBlocks, subjectData);
kernelDataCP = kernelData(:,1,:,:);
kernelGrandMean = squeeze(mean(kernelDataCP, 1:3));
kernelSubMeans  = squeeze(mean(kernelDataCP, [2 3]));
sampleOrderKernel = -5:-1;

% ELR 
[fhLR, statsTableLR] = peduks_coin_plot_grandAvg_lrTraces_byInstrCond(options, subjectData);
close(fhLR);

% RT 
[subjMeansRT, ~] = CP_jumpLocked_adjustments(options, subjectData);
close(gcf);

meanAdjA = mean(subjMeansRT.A, 1, 'omitnan');
nAdjA    = sum(~isnan(subjMeansRT.A(:,1)));
semAdjA  = std(subjMeansRT.A, 0, 1, 'omitnan') / sqrt(nAdjA);
meanAdjB = mean(subjMeansRT.B, 1, 'omitnan');
nAdjB    = sum(~isnan(subjMeansRT.B(:,1)));
semAdjB  = std(subjMeansRT.B, 0, 1, 'omitnan') / sqrt(nAdjB);

adjTimeAxis = (-options.behav.adjustPreSamples:options.behav.adjustPostSamples) / options.behav.fsample;

% data for the bottom row 
T = peduks_coin_group_table(options, excludedBlocks, subjectData);
[~, T] = peduks_coin_build_last3_pooled_table(options, T, excludedBlocks, subjectData);
[~, T] = peduks_coin_add_RT_new(T, options, excludedBlocks, subjectData);
T = peduks_coin_add_ELR_to_table(T, options, excludedBlocks, subjectData);

%build the combined figure
figure('Name', 'CP: results plots together', 'Color', 'w', 'Position', [50 50 1300 750]);

% panel A: kernel grand average
subplot(2,3,1); hold on
for iSub = 1:size(kernelSubMeans,1)
    plot(sampleOrderKernel, squeeze(kernelSubMeans(iSub,:)), '-', 'Color', col.individ, 'LineWidth', 0.5);
end
plot(sampleOrderKernel, kernelGrandMean, '-', 'Color', col.lowNoise, 'LineWidth', 3);
yline(0);
xlim([-5.5 -0.5]);
xlabel('Beam event preceding shield movement');
ylabel('Average weight on decision');
title('Grand-average kernel', 'FontWeight', 'normal');
box off
addPanelLetter(panelLetters{1});
hold off

% panel B:learning rate, A vs. B
subplot(2,3,2); hold on
offs = statsTableLR.offsetFromCP;
xPatch = [offs; flipud(offs)]';
fill(xPatch, [statsTableLR.grandMean_A + statsTableLR.SEM_A; flipud(statsTableLR.grandMean_A - statsTableLR.SEM_A)]', ...
    col.volatile, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill(xPatch, [statsTableLR.grandMean_B + statsTableLR.SEM_B; flipud(statsTableLR.grandMean_B - statsTableLR.SEM_B)]', ...
    col.stable, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
xline(0, 'LineWidth', 0.5, 'Color', col.medNoise, 'HandleVisibility', 'off');
yline(0, 'HandleVisibility', 'off');
hMeanA = plot(offs, statsTableLR.grandMean_A, '-', 'Color', col.volatile, 'LineWidth', 3);
hMeanB = plot(offs, statsTableLR.grandMean_B, '-', 'Color', col.stable, 'LineWidth', 3);
xlim([offs(1) 4]);

ylChangept = ylim;
text(0.1, ylChangept(1) + 0.35*(ylChangept(2)-ylChangept(1)), 'Change Point', ...
    'FontSize', 8, 'Color', col.medNoise, 'HorizontalAlignment', 'left');
xlabel('Beam event around changepoint');
ylabel('Average learning rate');
title('Learning rate', 'FontWeight', 'normal');
legend([hMeanA hMeanB], {'volatile, low noise', 'stable, high noise'}, ...
    'Location', 'best', 'Box', 'off');
box off
addPanelLetter(panelLetters{2});
hold off

% panel C: jump-locked adjustment, A vs. B
subplot(2,3,3); hold on
hAdjA = shadedErrorBar(adjTimeAxis, meanAdjA, semAdjA, 'lineprops', {'-', 'Color', col.volatile, 'LineWidth', 2});
hAdjB = shadedErrorBar(adjTimeAxis, meanAdjB, semAdjB, 'lineprops', {'-', 'Color', col.stable, 'LineWidth', 2});
hMeanAdjA = hAdjA.mainLine;
hMeanAdjB = hAdjB.mainLine;
xline(0, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5, 'HandleVisibility', 'off');
yline(0, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5, 'HandleVisibility', 'off');
xlabel('Time from change point (s)');
ylabel({'Angular distance (rad)', 'to pre-changepoint level'});
title('Reaction time after Change Point', 'FontWeight', 'normal');
xlim([-1 5]);
legend([hMeanAdjA hMeanAdjB], {'volatile, low noise', 'stable, high noise'}, ...
    'Location', 'northwest', 'Box', 'off');
box off
addPanelLetter(panelLetters{3});
hold off

% panel D: slopeLast3 A vs. B
subplot(2,3,4);
plotPairedSubplot(T, 'slopeLast3', 'Linear kernel slope', col.volatile, col.stable);
addPanelLetter(panelLetters{4});

% panel E: ELR A vs. B
subplot(2,3,5);
plotPairedSubplot(T, 'ELR', 'Evoked learning rate', col.volatile, col.stable);
addPanelLetter(panelLetters{5});

% panel F: RT A vs. B
subplot(2,3,6);
plotPairedSubplot(T, 'RT', 'Reaction time to reach half-way', col.volatile, col.stable);
addPanelLetter(panelLetters{6});

set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');


function plotPairedSubplot(T, metricName, yLabelText, colA, colB)

valsA = T.(['CP_A_' metricName]);
valsB = T.(['CP_B_' metricName]);
hold on
for iS = 1:height(T)
    plot([1 2], [valsA(iS) valsB(iS)], '-', 'Color', [0.75 0.75 0.75], 'HandleVisibility', 'off');
end
scatter(ones(height(T),1), valsA, 60, colA, 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5, 'HandleVisibility', 'off');
scatter(2*ones(height(T),1), valsB, 60, colB, 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5, 'HandleVisibility', 'off');
meanA = mean(valsA, 'omitnan'); semA = std(valsA,'omitnan')/sqrt(sum(~isnan(valsA)));
meanB = mean(valsB, 'omitnan'); semB = std(valsB,'omitnan')/sqrt(sum(~isnan(valsB)));
errorbar([1 2], [meanA meanB], [semA semB], '-k', 'LineWidth', 2, 'CapSize', 10, 'HandleVisibility', 'off');
xlim([0.5 2.5]);
xticks([1 2]);
xticklabels({'volatile, low noise', 'stable, high noise'});
ylabel(yLabelText);
box off
hold off
end

function addPanelLetter(letter)
% panel letter
text(-0.15, 1.12, letter, 'Units', 'normalized', ...
    'FontWeight', 'bold', 'FontSize', 14, 'VerticalAlignment', 'top');
end
