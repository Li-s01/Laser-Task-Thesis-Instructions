function details = peduks_coin_subjects(subID, options )
%GEÄNDERT
%PEDUKS_COIN_SUBJECTS Function that sets all subject-specific options and 
%paths for the analysis of the EEG data in the COIN task in the PEDUK study
%   IN:     subID       - subject id, e.g. 64
%           options     - the struct that holds all analysis options
%   OUT:    details     - a struct that holds all options/details for sid

% String for folder names and files
details.subjName = sprintf('sub-%03.0f', subID);

% Defaults: nSessions and blocks
details.nSessions.onlineTrain = [1; 1];

for iTskTyp = 1:numel(options.taskTypes)
    tt = options.taskTypes{iTskTyp};
    switch tt
        case 'onlineTrain'
            nBlocks = 12;
    end

    for iVis = 1:1
        details.analysis.(tt).behav{iVis}.blockList = 1: nBlocks;
    end
end




%% subject directories
details.raw.behav.folder = fullfile(options.rawDir, details.subjName);
details.analysis.folder = fullfile(options.workDir, details.subjName);
if ~exist(details.analysis.folder, 'dir')
    mkdir(details.analysis.folder);
end

%% task-specific directory tree
for iType = 1: numel(options.taskTypes)
    tt = options.taskTypes{iType};
    details.analysis.(tt).folder = fullfile(details.analysis.folder, tt);
    if ~exist(details.analysis.(tt).folder, 'dir')
        mkdir(details.analysis.(tt).folder);
    end

    %% visit-specific folders and files
    for iVis = 1:1
        details.analysis.(tt).behav{iVis}.folder = ...
            fullfile(details.analysis.(tt).folder,'behav' );

        %% session-specific files
        for iSes = 1: details.nSessions.(tt)(iVis)
            
%---------- raw behaviour files ----------------------------------------%
            fileName = ls(fullfile(details.raw.behav.folder, ...
                [details.subjName '_vis-' num2str(iVis) ...
                '_ses-' num2str(iSes) '_task-laser_type-' tt '*']));
            details.raw.(tt).behavFileNames{iVis, iSes} = fileName(1:end-1);
                        
        end

        %% visit-specific files

%------ intermediate behaviour files -----------------------------------%

        % raw data loaded
        details.analysis.(tt).behav{iVis}.responseDataCsv = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_responseDataRaw.mat']);
        % raw stimulus loaded
        details.analysis.(tt).behav{iVis}.stimData = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_stimDataRaw.mat']);
        % preprocessed behavioural data
        details.analysis.(tt).behav{iVis}.responseData = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_responseData.mat']);
        
        % raw behaviour per block (figures)
        for iBlock = 1: 12
            details.analysis.(tt).behav{iVis}.blockFigures{iBlock} = ...
            fullfile(details.analysis.(tt).behav{iVis}.folder, ['block' num2str(iBlock) '_blockPlot.fig']);
        end
        % performance indices
        details.analysis.(tt).behav{iVis}.performance = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_perform.mat']);
        % condition-level means (seqType x instrCond) and matched sequence pairs
        details.analysis.(tt).behav{iVis}.conditionMeans = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_condSummary.mat']);
        
        % integration kernels
        details.analysis.(tt).behav{iVis}.blockKernels = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_blockKernels.mat']);
        details.analysis.(tt).behav{iVis}.kernelConditionPlot = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_kernelsPerCondition.fig']);
        % regression kernels
        details.analysis.(tt).behav{iVis}.blockRegKernels = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_blockRegKernels.mat']);
        details.analysis.(tt).behav{iVis}.regKernelConditionPlot = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_regKernelsPerCondition.fig']);
        details.analysis.(tt).behav{iVis}.regBetaConditionPlot = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_regBetasPerCondition.fig']);
        % integration kernel steepness
        details.analysis.(tt).behav{iVis}.kernelSteepness = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_kernelSteepness.mat']);
        
        % movement/adjustments
        details.analysis.(tt).behav{iVis}.movements = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_blockMovements.mat']);
        details.analysis.(tt).behav{iVis}.adjustInteractionFig = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_adjustmentsPerCondition.fig']);
        details.analysis.(tt).behav{iVis}.adjustLowNoiseFig = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_adjustmentsLowNoise.fig']);
        details.analysis.(tt).behav{iVis}.adjustHighNoiseFig = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_adjustmentsHighNoise.fig']);
        details.analysis.(tt).behav{iVis}.movePercMovingFig = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_movePercentMovingPerCondition.fig']);
        details.analysis.(tt).behav{iVis}.moveSideSwitchingFig = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_moveSideSwitchingPerCondition.fig']);
        details.analysis.(tt).behav{iVis}.moveStartMovingFig = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_moveStartMovingPerCondition.fig']);
        % reaction times
        details.analysis.(tt).behav{iVis}.reactionTimes = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_reactionTimes.mat']);

        % learning rates
        details.analysis.(tt).behav{iVis}.blockLearningRates = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_blockLearningRates.mat']);
        details.analysis.(tt).behav{iVis}.lrTraceConditionPlot = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_lrTracePerCondition.fig']);
        details.analysis.(tt).behav{iVis}.lrCorrTraceConditionPlot = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_lrCorrTracePerCondition.fig']);
        details.analysis.(tt).behav{iVis}.lrTracePerJsConditionPlot = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_lrTracePerJsPerCondition.fig']);
        % evoked LR shift
        details.analysis.(tt).behav{iVis}.evokedLearningRate = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_evokedLearningRates.mat']);
        details.analysis.(tt).behav{iVis}.evokedLearningRatePerJumpSize = fullfile(details.analysis.(tt).behav{iVis}.folder, ...
            [details.subjName '_vis-' num2str(iVis) '_' tt '_evokedLearningRatesPerJumpSize.mat']);

    end


    %% subject-specific (overview) files
    details.analysis.overview.performRewardFig = fullfile(details.analysis.folder, ...
        [details.subjName '_performOverview_reward.fig']);
    details.analysis.overview.performAvgDevFromMeanFig = fullfile(details.analysis.folder, ...
        [details.subjName '_performOverview_avgDevFromMean.fig']);
    details.analysis.overview.performAvgPeFig = fullfile(details.analysis.folder, ...
        [details.subjName '_performOverview_avgPredErr.fig']);
    details.analysis.overview.inactionN2sFig = fullfile(details.analysis.folder, ...
        [details.subjName '_inactionOverview_nTrialsAbove2s.fig']);
    details.analysis.overview.inactionMeanFig = fullfile(details.analysis.folder, ...
        [details.subjName '_inactionOverview_meanDuration.fig']);
    details.analysis.overview.inactionMaxFig = fullfile(details.analysis.folder, ...
        [details.subjName '_inactionOverview_maxDuration.fig']);
    
    %details.analysis.overview.rtFig = fullfile(details.analysis.folder, ...
        %[details.subjName '_reactionTimes.fig']);
    
    
end



