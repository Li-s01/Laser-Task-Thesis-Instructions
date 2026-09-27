function fh = peduks_coin_plot_grandAverage_kernels( kernelData, options )

col = peduks_coin_colours;
sampleOrder = -5:-1;
nSubjects = size(kernelData,1);

% average over (subjects and) conditions
grandAvgDataMean = squeeze(mean(kernelData, 1:3));
grandAvgDataSubs = squeeze(mean(kernelData, [2 3]));

% determine x-axis
pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;
fsmp = options.behav.fsample;
timeAxis = [-pre/fsmp: 1/fsmp : post/fsmp];

%%
fh = figure;

for iSub = 1:nSubjects
    plot(sampleOrder, squeeze(grandAvgDataSubs(iSub, :)), '-', ...
        'color', col.individ, 'linewidth', 0.5);
    hold on;
end
plot(sampleOrder, grandAvgDataMean, ...
    '-', 'color', col.lowNoise, 'linewidth', 3);
hold on;

yline(0);

xlim([-5.5 -0.5])
xlabel('Beam event preceding shield movement')
ylabel('Average weight on decision')

fh = cleanUpFig(fh);