function fh = peduks_coin_plot_mainEffects_kernels( kernelData )
%Plots post-change point shield
%adjustment time course per average condition (volatility and noise).

col = peduks_coin_colours;
sampleOrder = -5:-1;
offset = 0.15;

% Average over levels of irrelevant condition
kernelDataNois = squeeze(mean(kernelData,2)); % avg over vola levels
%kernelDataVola = squeeze(mean(kernelData,3)); % avg over noise levels

fh = figure;
% Effect of volatility
% subplot(1,2,1);
% peduks_coin_plot_kernelWeights_perSubject(kernelDataVola, ...
%     col.stable, col.volatile, col.medNoise, sampleOrder, offset);


[p1, p2] =peduks_coin_plot_kernelWeights_perSubject(kernelDataNois, ...
    col.precise, col.noisy, col.medNoise, sampleOrder, offset);


%subplot(1,2,1); title('Effect of seqType (CP vs. RW)'); %Vergleich RW und
%CP. Kann interessant sein
title('Effect of instrCond (A vs. B)');
legend([p1 p2], {'A (Volatile)', 'B (Noise)'}, 'Location', 'northwest', 'Box', 'off');


fh = cleanUpFig(fh);

%legend([p1, p2], conLabels{1}, conLabels{2}, 'Location','northwest', 'box', 'off');

%{

% Avg over participants and std error of the mean
noisMean = squeeze(mean(kernelDataNois,1));
noisSE = squeeze(std(kernelDataNois,[],1))/sqrt(nSubjects);

volaMean = squeeze(mean(kernelDataVola,1));
volaSE = squeeze(std(kernelDataVola,[],1))/sqrt(nSubjects);


fh = figure;
doZoom = 0;
newFigure = false;
subplot(1,2,1);
peduks_coin_plot_groupAdjusts_errorBars(...
        squeeze(volaMean(1,:,:)), squeeze(volaSE(1,:,:)), ...
        squeeze(volaMean(2,:,:)), squeeze(volaSE(2,:,:)), ...
        col.stable, col.volatile, 3, 3, 'stable', 'volatile', ...
        sampleOrder, col.lineStyles, jumpSizes, ...
        'Effect of volatility', doZoom, newFigure);
subplot(1,2,2);
peduks_coin_plot_groupAdjusts_errorBars(...
        squeeze(noisMean(1,:,:)), squeeze(noisSE(1,:,:)), ...
        squeeze(noisMean(2,:,:)), squeeze(noisSE(2,:,:)), ...
        col.precise, col.noisy, 3, 3, 'low noise', 'high noise', ...
        sampleOrder, col.lineStyles, jumpSizes, ...
        'Effect of noise', doZoom, newFigure);

fh = cleanUpFig(fh);
%fh.Position = [1167 544 950 250];
%}
end