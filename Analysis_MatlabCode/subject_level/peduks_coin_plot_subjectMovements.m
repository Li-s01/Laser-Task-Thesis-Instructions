function [ fh1, fh2, fh3 ] = peduks_coin_plot_subjectMovements( moveSamples, sideSwitches, moveOnsets )
%PEDUKS_COIN_PLOT_SUBJECTMOVEMENTS Plots several indices of how a
%participant moved their shield during constant mean laser position in the
%COIN task in the PEDUK study.

col = peduks_coin_colours;

fh1 = figure;
h1 = notBoxPlot(moveSamples{1,1}, 'style', 'line', 'jitter', 0.2);
hold on
h2 = notBoxPlot(moveSamples{1,2}, 2, 'style', 'line', 'jitter', 0.2);
h3 = notBoxPlot(moveSamples{2,1}, 3, 'style', 'line', 'jitter', 0.2);
h4 = notBoxPlot(moveSamples{2,2}, 4, 'style', 'line', 'jitter', 0.2);
xticks(1:4)
xticklabels({'stable', 'stableNoisy', 'volatile', 'volatileNoisy'})
ylabel('Time spent moving (in %)')
title('Movement during stable mean - time spent')

fh2 = figure;
h1=notBoxPlot(sideSwitches{1,1}, 'style', 'line', 'jitter', 0.2);
hold on, h2=notBoxPlot(sideSwitches{1,2}, 2, 'style', 'line', 'jitter', 0.2);
hold on, h3=notBoxPlot(sideSwitches{2,1}, 3, 'style', 'line', 'jitter', 0.2);
hold on, h4=notBoxPlot(sideSwitches{2,2}, 4, 'style', 'line', 'jitter', 0.2);
xticks(1:4)
xticklabels({'stable', 'stableNoisy', 'volatile', 'volatileNoisy'})
ylabel('Side switches per second')
title('Movement during stable mean - switches')


fh3 = figure;
h1=notBoxPlot(moveOnsets{1,1}, 'style', 'line', 'jitter', 0.2);
hold on, h2=notBoxPlot(moveOnsets{1,2}, 2, 'style', 'line', 'jitter', 0.2);
hold on, h3=notBoxPlot(moveOnsets{2,1}, 3, 'style', 'line', 'jitter', 0.2);
hold on, h4=notBoxPlot(moveOnsets{2,2}, 4, 'style', 'line', 'jitter', 0.2);
xticks(1:4)
xticklabels({'stable', 'stableNoisy', 'volatile', 'volatileNoisy'})
ylabel('Movement onsets per second')
title('Movement during stable mean - onsets')

cleanUpFig(fh1);
cleanUpFig(fh2);
cleanUpFig(fh3);


%{
fh3 = figure; 
plot(1, sideSwitches{1,1}, 'o', 'color', col.stable)
hold on; 
plot(1, mean(sideSwitches{2,1}), 'o', 'color', col.stable, 'markerfacecolor', col.stable, 'markersize', 8)
plot(2, sideSwitches{2,1}, 'o', 'color', col.volatile)
plot(2, mean(sideSwitches{2,1}), 'o', 'color', col.volatile, 'markerfacecolor', col.volatile, 'markersize', 8)
plot(3, sideSwitches{1,2}, 'o', 'color', col.stable/2)
plot(3, mean(sideSwitches{1,2}), 'o', 'color', col.stable/2, 'markerfacecolor', col.stable/2, 'markersize', 8)
plot(4, sideSwitches{2,2}, 'o', 'color', col.volatile/2)
plot(4, mean(sideSwitches{2,2}), 'o', 'color', col.volatile/2, 'markerfacecolor', col.volatile/2, 'markersize', 8)
xlim([0 5])

fh3 = figure;
plot(1, sideSwitches{1,1}, 'o', 'color', col.stable)
hold on; 
plot(1, mean(sideSwitches{2,1}), 'o', 'color', col.stable, 'markerfacecolor', col.stable, 'markersize', 8)
plot(2, sideSwitches{2,1}, 'o', 'color', col.volatile)
plot(2, mean(sideSwitches{2,1}), 'o', 'color', col.volatile, 'markerfacecolor', col.volatile, 'markersize', 8)
plot(3, sideSwitches{1,2}, 'o', 'color', col.stable/2)
plot(3, mean(sideSwitches{1,2}), 'o', 'color', col.stable/2, 'markerfacecolor', col.stable/2, 'markersize', 8)
plot(4, sideSwitches{2,2}, 'o', 'color', col.volatile/2)
plot(4, mean(sideSwitches{2,2}), 'o', 'color', col.volatile/2, 'markerfacecolor', col.volatile/2, 'markersize', 8)
xlim([0 5])
%}


end