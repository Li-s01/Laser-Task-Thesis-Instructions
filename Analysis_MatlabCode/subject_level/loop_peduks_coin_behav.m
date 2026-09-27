function loop_peduks_coin_behav( options )
%LOOP_PEDUKS_COIN_PREPROC Loops over all participants in options.behav.subjectIDs
%and processes their behavioural data (movements, kernels, adjustments).
%   IN:     options     - the struct that holds all analysis options
peduks_coin_setup_paths
if nargin < 1
    options = peduks_coin_options;
end

doLoadData = true;
doPerformance = true;
doPlot = false; 
doConditionMeans = true;
doChangepoint = false;
doKernels = false;
doLearningRate = false;

for iSub = 1: length(options.behav.subjectIDs)
    subID = options.behav.subjectIDs(iSub);
    details = peduks_coin_subjects(subID, options);
    disp(details.subjName);
    
    for iVis = 1: 1
        disp(['visit ' num2str(iVis)]);
        for iType = 1:1 %numel(options.taskTypes) 
            tt = options.taskTypes{iType};
            disp(tt)
            
            if ~exist(details.analysis.(tt).behav{iVis}.folder, 'dir')
                mkdir(details.analysis.(tt).behav{iVis}.folder);
            end
            
            %% Load data 
            if doLoadData
                subData = peduks_coin_load_savedData(details.raw.onlineTrain.behavFileNames(1,:));
                save(details.analysis.(tt).behav{iVis}.responseDataCsv, 'subData');
                
                % unwrap circular degrees into radians and remove all data
                % before the first hit
                subData = peduks_coin_runPreprocBehavData(subData, options);
                save(details.analysis.(tt).behav{iVis}.responseData, 'subData');
            else
                load(details.analysis.(tt).behav{iVis}.responseData, 'subData');
            end

            %% General Performance (Abweichung vom Mean, Anzahl Hits, Gesamtreward...)
            if doPerformance
                [stim, perform, fhs] = peduks_coin_runPerformance(subData, options, doPlot);
                save(details.analysis.(tt).behav{iVis}.performance, 'stim', 'perform');
                if doPlot
                    for i=1:numel(fhs)
                        savefig(fhs(i), details.analysis.(tt).behav{iVis}.blockFigures{i});
                    end
                end
                close all
            end           
            
            % MANUAL STEP: Exclude blocks/sessions from further analysis
            blockList = details.analysis.(tt).behav{iVis}.blockList;

            flagged = peduks_coin_flag_dropout_blocks(perform);        % default: 20s
            flagged = peduks_coin_flag_dropout_blocks(perform, 30);    % eigene Schwelle

            %% Condition-level means (seqType x instrCond) and matched sequence pairs
            if doConditionMeans
                 if ~exist('perform', 'var')
                    load(details.analysis.(tt).behav{iVis}.performance, 'perform');
                 end
                condSummary = peduks_coin_condition_means(perform, options);
                save(details.analysis.(tt).behav{iVis}.conditionMeans, 'condSummary');
            end
            
            %% Movement at changepoints (adjustments, meanMoves)
            if doChangepoint
                [adjust, meanMove] = peduks_coin_runAdjustments(subData, options, blockList);
                save(details.analysis.(tt).behav{iVis}.movements, 'adjust', 'meanMove');
            
                % Plot avg adjustment behaviour per condition
                [fh4, fh5, fh6] = peduks_coin_plot_subjectAdjustments(...
                    adjust.meanAdjusts, adjust.jumpSizes, options);
                savefig(fh4, details.analysis.(tt).behav{iVis}.adjustInteractionFig);
                savefig(fh5, details.analysis.(tt).behav{iVis}.adjustLowNoiseFig);
                savefig(fh6, details.analysis.(tt).behav{iVis}.adjustHighNoiseFig);
                
                % Plot movement results for this visit and task type
                [fh1, fh2, fh3] = peduks_coin_plot_subjectMovements(...
                    meanMove.moveSamples, meanMove.sideSwitches, meanMove.moveOnsets);
                savefig(fh1, details.analysis.(tt).behav{iVis}.movePercMovingFig);
                savefig(fh2, details.analysis.(tt).behav{iVis}.moveSideSwitchingFig);
                savefig(fh3, details.analysis.(tt).behav{iVis}.moveStartMovingFig);
    
                % Compute RTs for this participant & run
                rts = peduks_coin_runRTs(adjust, options);
                save(details.analysis.(tt).behav{iVis}.reactionTimes, 'rts');
                close all
            end
            
            %% Integration kernels
            if doKernels
                [betasCon, nTrialsCon, avgKernelsCon, nKernelsCon] = ...
                    peduks_coin_runKernels(subData, options, blockList);
                save(details.analysis.(tt).behav{iVis}.blockKernels, ...
                    'betasCon', 'nTrialsCon', 'avgKernelsCon', 'nKernelsCon');
                fh = peduks_coin_plot_subjectKernels(betasCon, ...
                    nTrialsCon, options);
                savefig(fh, details.analysis.(tt).behav{iVis}.kernelConditionPlot)
                
                % Compute IKS for this participant & run
                iks = peduks_coin_runIKS(betasCon, options);
                save(details.analysis.(tt).behav{iVis}.kernelSteepness, 'iks');
                close all
            end

            
            %% Implied learning rate
            if doLearningRate
                [lrTraceCon, lrTracePerJsCon, lrCorrTraceCon, LRcon, LRcorrCon] = ...
                    peduks_coin_runLearningRate(subData, options, blockList);
                save(details.analysis.(tt).behav{iVis}.blockLearningRates, ...
                    'lrTraceCon', 'lrTracePerJsCon', 'lrCorrTraceCon', 'LRcon', 'LRcorrCon');
                fh1 = peduks_coin_plot_subjectLrTrace(lrTraceCon, options);
                savefig(fh1, details.analysis.(tt).behav{iVis}.lrTraceConditionPlot)
                fh2 = peduks_coin_plot_subjectLrTrace(lrCorrTraceCon, options);
                savefig(fh2, details.analysis.(tt).behav{iVis}.lrCorrTraceConditionPlot)
                fh3 = peduks_coin_plot_subjectLrTracePerJs(lrTracePerJsCon, options);
                fh3.Position = [586 457 1219 420];
                savefig(fh3, details.analysis.(tt).behav{iVis}.lrTracePerJsConditionPlot)
                
                load(details.analysis.(tt).behav{iVis}.blockLearningRates, ...
                    'lrTraceCon', 'lrTracePerJsCon');
    
                % Compute evoked LR for this participant & run
                elr = peduks_coin_runELR(lrTraceCon, options);
                save(details.analysis.(tt).behav{iVis}.evokedLearningRate, 'elr');
    
                elrPerJs = peduks_coin_runELRperJs(lrTracePerJsCon, options);
                save(details.analysis.(tt).behav{iVis}.evokedLearningRatePerJumpSize, 'elrPerJs');
                close all
            end
            
        end
        
    end
    close all
    
    
    % Summary plots per participant (across visits and task types)
    % [avgReward, fhs] = peduks_coin_plot_overview_subjectPerformance(subID, options);
    % savefig(fhs(1), details.analysis.overview.performRewardFig)
    % savefig(fhs(2), details.analysis.overview.performAvgDevFromMeanFig)
    % savefig(fhs(3), details.analysis.overview.performAvgPeFig)
    % savefig(fhs(4), details.analysis.overview.inactionN2sFig)
    % savefig(fhs(5), details.analysis.overview.inactionMeanFig)
    % savefig(fhs(6), details.analysis.overview.inactionMaxFig)
    % 
end
