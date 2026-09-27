function fh = peduks_coin_plot_subjectLrTrace( lrTraceCon, ...
    options )
%PEDUKS_COIN_PLOT_SUBJECTLRTRACE Plots the implied learning rate for 
%evidence samples around change points in the mean for one participant, 
%separately for volatility and noise conditions, in the COIN task in the 
%PEDUK study.

col = peduks_coin_colours;

timeAxis = [-options.behav.lrPreSamples:options.behav.lrPostSamples];
xLblStr = 'evidence samples '; yLblStr = 'implied learning rate';
tStr = 'Learning rates: ';
volaKerns = squeeze(nanmean(lrTraceCon{2,1},1));
stabKerns = squeeze(nanmean(lrTraceCon{1,1},1));
staNoiKerns = squeeze(nanmean(lrTraceCon{1,2},1));
volNoiKerns = squeeze(nanmean(lrTraceCon{2,2},1));
        
% plotting
fh = figure;

ax1 = subplot(2, 1, 1);
plot(timeAxis, volaKerns, 'color', col.volatile, 'linewidth', 2);
hold on
plot(timeAxis, stabKerns, 'color', col.stable, 'linewidth', 2);

xlabel([xLblStr 'around change points']);
ylabel(yLblStr);
yline(0, 'color', col.medNoise);

title([tStr 'low noise blocks'])
legend('volatile blocks', ...
    'stable blocks', ...
    'location', 'northwest', 'box', 'off');
box off;
ax1.LineWidth = 1;


ax2 = subplot(2, 1, 2);
plot(timeAxis, volNoiKerns, 'color', col.volaNoisy, 'linewidth', 2);
hold on
plot(timeAxis, staNoiKerns, 'color', col.stabNoisy, 'linewidth', 2);

xlabel([xLblStr 'around change points']);
ylabel(yLblStr);
yline(0, 'color', col.medNoise);

title([tStr 'high noise blocks'])
legend('noisy volatile blocks', ...
    'noisy stable blocks', ...
    'location', 'northwest', 'box', 'off');
box off;
ax2.LineWidth = 1;

linkaxes

cleanUpFig(fh);

end
