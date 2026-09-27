function fh = peduks_coin_plot_subjectKernels( betasCon, ...
    nTrialsCon, options )
%PEDUKS_COIN_PLOT_SUBJECTKERNELS Plots the beta weights of evidence samples
%preceding responses for one participant, separately for volatility and
%noise conditions, in the COIN task in the PEDUK study.

col = peduks_coin_colours;

timeAxis = [-options.behav.kernelPreSamplesEvi:-1];
xLblStr = 'evidence samples '; yLblStr = 'avg weight on decision';
tStr = 'Integration kernels: ';
volaKerns = squeeze(nanmean(betasCon{2,1},1));
stabKerns = squeeze(nanmean(betasCon{1,1},1));
staNoiKerns = squeeze(nanmean(betasCon{1,2},1));
volNoiKerns = squeeze(nanmean(betasCon{2,2},1));
        
% plotting
fh = figure;

ax1 = subplot(2, 1, 1);
plot(timeAxis, volaKerns, 'color', col.volatile, 'linewidth', 2);
hold on
plot(timeAxis, stabKerns, 'color', col.stable, 'linewidth', 2);

xlabel([xLblStr 'leading up to button press']);
ylabel(yLblStr);
yline(0, 'color', col.medNoise);

title([tStr 'low noise blocks'])
legend(['volatile blocks (N=' num2str(sum(nTrialsCon{2,1})) ')'], ...
    ['stable blocks (N=' num2str(sum(nTrialsCon{1,1})) ')'], ...
    'location', 'northwest', 'box', 'off');
box off;
ax1.LineWidth = 1;


ax2 = subplot(2, 1, 2);
plot(timeAxis, volNoiKerns, 'color', col.volaNoisy, 'linewidth', 2);
hold on
plot(timeAxis, staNoiKerns, 'color', col.stabNoisy, 'linewidth', 2);

xlabel([xLblStr 'leading up to button press']);
ylabel(yLblStr);
yline(0, 'color', col.medNoise);

title([tStr 'high noise blocks'])
legend(['noisy volatile blocks (N=' num2str(sum(nTrialsCon{2,2})) ')'], ...
    ['noisy stable blocks (N=' num2str(sum(nTrialsCon{1,2})) ')'], ...
    'location', 'northwest', 'box', 'off');
box off;
ax2.LineWidth = 1;

cleanUpFig(fh);

end
