function fh = peduks_coin_plot_subjectLrTracePerJs( lrTracePerJsCon, ...
    options )
%PEDUKS_COIN_PLOT_SUBJECTLRTRACE Plots the implied learning rate for 
%evidence samples around change points in the mean for one participant, 
%separately for volatility and noise conditions, in the COIN task in the 
%PEDUK study.

col = peduks_coin_colours;
timeAxis = [-options.behav.lrPreSamples:options.behav.lrPostSamples];
xLblStr = 'evidence samples '; yLblStr = 'implied learning rate';
tStr = 'Learning rates: ';

fh = figure;

for iJs = 1:3
    volaKerns = squeeze(nanmean(lrTracePerJsCon{2,1}(:,iJs,:),1));
    stabKerns = squeeze(nanmean(lrTracePerJsCon{1,1}(:,iJs,:),1));
    staNoiKerns = squeeze(nanmean(lrTracePerJsCon{1,2}(:,iJs,:),1));
    volNoiKerns = squeeze(nanmean(lrTracePerJsCon{2,2}(:,iJs,:),1));
    
    ax1 = subplot(2, 3, iJs); % 1 2 3
    plot(timeAxis, volaKerns, 'color', col.volatile, 'linewidth', 2);
    hold on
    plot(timeAxis, stabKerns, 'color', col.stable, 'linewidth', 2);
    
    xlabel([xLblStr 'around change points']);
    ylabel(yLblStr);
    yline(0, 'color', col.medNoise);
    
    title([tStr 'low noise, jump size ' num2str(iJs)])
    legend('volatile blocks', ...
        'stable blocks', ...
        'location', 'northwest', 'box', 'off');
    box off;
    ax1.LineWidth = 1;
    
    
    ax2 = subplot(2, 3, iJs+3); % 4 5 6 
    plot(timeAxis, volNoiKerns, 'color', col.volaNoisy, 'linewidth', 2);
    hold on
    plot(timeAxis, staNoiKerns, 'color', col.stabNoisy, 'linewidth', 2);
    
    xlabel([xLblStr 'around change points']);
    ylabel(yLblStr);
    yline(0, 'color', col.medNoise);
    
    title([tStr 'high noise, jump size ' num2str(iJs)])
    legend('noisy volatile blocks', ...
        'noisy stable blocks', ...
        'location', 'northwest', 'box', 'off');
    box off;
    ax2.LineWidth = 1;
end

linkaxes

cleanUpFig(fh);

end
