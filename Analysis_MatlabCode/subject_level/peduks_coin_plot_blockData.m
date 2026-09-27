function fh = peduks_coin_plot_blockData( blockData, options )
%PEDUKS_COIN_PLOT_BLOCKDATA Plots shield movement behaviour for one block
%of the COIN task in the PEDUK study

col = peduks_coin_colours;
seqIdx = find(strcmp(options.seqIDs, unique(blockData.seqType)));
instrIdx = find(strcmp(options.instrIDs, unique(blockData.instrCond)));
con = options.conditionLabels{seqIdx, instrIdx};

% mark the times which we exclude from analysis
timeIncluded = blockData.timeOfFrame(blockData.includeFrame);
startTime = timeIncluded(1);
%bands = [0 timeIncluded(1)];                                                      
%xp = [bands fliplr(bands)];

% plot laser location as event instead of continuously
laserEvents = blockData.laser([1; diff(blockData.laser)] ~= 0);
laserEventTimes = blockData.timeOfFrame([1; diff(blockData.laser)] ~= 0);

fh = figure('Color', 'w');

ax1 = subplot(2, 1, 1);
plot(blockData.timeOfFrame, blockData.trueMean, 'linewidth', 3, 'color', [1 0.2 0.2]);
hold on;
plot(laserEventTimes, laserEvents, '*', 'color', [0.6 0 0]);
shadedErrorBar(blockData.timeOfFrame, blockData.shield, 0.5*blockData.shieldWidth);
xline(startTime, 'color', col.medNoise, 'LineWidth', 2);
%yp = ([[1;1]*min(ylim); [1;1]*max(ylim)]*ones(1,size(bands,1))).';                  % Y-Coordinate Band Definitions
%patch(xp, yp, [1 1 1]*0.25, 'FaceAlpha',0.1, 'EdgeColor',[1 1 1]*0.25)

legend('true mean', 'laser location', 'shield position +/- width');
xlabel('Time (sec) across block')
ylabel('Location in radians');

ax2 = subplot(2, 1, 2);
plot(blockData.timeOfFrame, blockData.absLaserDistance, 'color', [0 0 0.6]); hold on;
plot(blockData.timeOfFrame, 0.5*blockData.shieldWidth, 'k', 'linewidth', 2);
plot(blockData.timeOfFrame, blockData.trueNoise, 'color', [0.2 0.2 1], 'linewidth', 3);
xline(startTime, 'color', col.medNoise, 'LineWidth', 2);
%yp = ([[1;1]*min(ylim); [1;1]*max(ylim)]*ones(1,size(bands,1))).';                  % Y-Coordinate Band Definitions
%patch(xp, yp, [1 1 1]*0.25, 'FaceAlpha',0.1, 'EdgeColor',[1 1 1]*0.25)

title('Absoluted distance to shield over time');
xlabel('Time (sec) across block');
ylabel('Radians');
legend({'abs PE' 'shield size', 'true variance'});

for i = 1:numel(fh.Children)
    fh.Children(i).FontSize = 14;
    fh.Children(i).LineWidth = 1;
    fh.Children(i).Box = 'off';
end

linkaxes([ax1 ax2], 'x');


end