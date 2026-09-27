function [ fh1, fh2, fh3 ] = peduks_coin_plot_subjectAdjustments( adjusts, jumpSizes, options )
%PEDUKS_COIN_PLOT_SUBJECTADJUSTMENT Plots the average timecourse of how a
%participant adjusts shield position after a mean jump of the laser
%location in the COIN task in the PEDUK study.

pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;

fsmp = options.behav.fsample;
timeAxis = [-pre/fsmp: 1/fsmp : post/fsmp];

% 1. Full interaction
fh1 = figure;
pStaPre = plot(timeAxis, squeeze(adjusts(1,1,:,:))', 'linewidth', 2);
hold on, 
pVolPre = plot(timeAxis, squeeze(adjusts(2,1,:,:))', '--', 'linewidth', 2);
pStaNoi = plot(timeAxis, squeeze(adjusts(1,2,:,:))', 'linewidth', 1);
pVolNoi = plot(timeAxis, squeeze(adjusts(2,2,:,:))', '--', 'linewidth', 1);

set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i), 'color', [0.5 0.5 0.5])
end
yline(0)
xline(0)
legend([pStaPre(end), pVolPre(end) pStaNoi(end), pVolNoi(end)], ...
    'stable, precise', 'volatile, precise', 'stable, noisy', 'volatile, noisy')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('Volatility * Stochasticity * JumpSize - start at 0')

% 2. Volatility during low noise
fh2 = figure;
pStaPre = plot(timeAxis, squeeze(adjusts(1,1,:,:))', 'linewidth', 2);
hold on, 
pVolPre = plot(timeAxis, squeeze(adjusts(2,1,:,:))', '--', 'linewidth', 2);

set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i), 'color', [0.5 0.5 0.5])
end
yline(0)
xline(0)
legend([pStaPre(end), pVolPre(end)], ...
    'stable, precise', 'volatile, precise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('Low noise: Volatility * JumpSize - start at 0')

% 3. Volatility during high noise
fh3 = figure;
pStaNoi = plot(timeAxis, squeeze(adjusts(1,2,:,:))', 'linewidth', 1);
hold on, 
pVolNoi = plot(timeAxis, squeeze(adjusts(2,2,:,:))', '--', 'linewidth', 1);

set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i), 'color', [0.5 0.5 0.5])
end
yline(0)
xline(0)
legend([pStaNoi(end), pVolNoi(end)], ...
    'stable, noisy', 'volatile, noisy')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('High noise: Volatility * JumpSize - start at 0')

% 4. Noise during low volatility
fh4 = figure;
pPreSta = plot(timeAxis, squeeze(adjusts(1,1,:,:))', 'linewidth', 2);
hold on, 
pNoiSta = plot(timeAxis, squeeze(adjusts(1,2,:,:))', 'linewidth', 1);

set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i), 'color', [0.5 0.5 0.5])
end
yline(0)
xline(0)
legend([pPreSta(end), pNoiSta(end)], ...
    'stable, precise', 'stable, noisy')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('Stable blocks: Noise * JumpSize - start at 0')

% 3. Noise during high volatility
fh5 = figure;
pPreVol = plot(timeAxis, squeeze(adjusts(2,1,:,:))', '--', 'linewidth', 2);
hold on, 
pNoiVol = plot(timeAxis, squeeze(adjusts(2,2,:,:))', '--', 'linewidth', 1);

set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i), 'color', [0.5 0.5 0.5])
end
yline(0)
xline(0)
legend([pPreVol(end), pNoiVol(end)], ...
    'volatile, precise', 'volatile, noisy')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('Volatile blocks: Noise * JumpSize - start at 0')

cleanUpFig(fh1);
cleanUpFig(fh2);
cleanUpFig(fh3);