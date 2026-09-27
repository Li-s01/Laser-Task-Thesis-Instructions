function options = peduks_coin_options
%GEÄNDERT
%PEDUKS_COIN_OPTIONS Sets all options for the analysis of EEG data from the
%continuous inference task in the PEDUK study.
%   OUT:    options         - the struct that holds all analysis options

%%%---- ENTER YOUR PATHS HERE -----------------------------------------%%%
% This is where we are now (where the code is to be found):
options.codeDir = fileparts(mfilename('fullpath'));
% This is the base root for both raw data and analysis:
options.mainDir = '/Users/livschroder/Documents/Bachelorarbeit/Analysis';
options.rawDir = fullfile(options.mainDir, 'Data');
options.workDir = fullfile(options.mainDir, 'Results');
%%%--------------------------------------------------------------------%%%

options.subjectIDs = [5959, 4531, 4918, 5092, 5890, 6103, 6106, 6112, 5113, 6076, 3430, 3487, 6130, 5476, 5032, 3622, 5245, 5122, 5086, 9997, 4984, 5017, 5995, 3721, 4165, 3655, 5257, 5875, 3511, 3337, 5341, 5881, 6097, 10004];
%sub025, baseline, vis1, ses1 EEG recording missing
options.dataReview.subjectIDs = [];
options.notInDataReview.subjectIDs = [];
options.pilots.subjectIDs = [];

options.taskTypes       = {'onlineTrain'};
options.conditionLabels = {'CP_Volatile', 'CP_Noise'; 'RW_Volatile', 'RW_Noise'};
options.conditionIDs    = 1:4;

options.instrLabels = {'Volatile', 'Noise'};   
options.instrIDs    = {'A', 'B'};

options.seqLabels   = {'Change Point', 'Random Walk'};            
options.seqIDs      = {'CP', 'RW'};

%-- behaviour ------------------------------------------------------------%
options.behav.subjectIDs    = options.subjectIDs;
options.behav.doExclude = false;
options.behav.excludedSubjectIDs = []; 
[~, options.behav.excludedSubjectIndices] = ismember(options.behav.excludedSubjectIDs, ...
    options.behav.subjectIDs); 

options.behav.flagLoadData = 1;
options.behav.flagPerformance = 1;
options.behav.flagKernels = 1;
options.behav.flagAdjustments = 0; % später wieder auf 1 setzen!
options.behav.flagReactionTimes = 0; % später wieder auf 1 setzen, wenn anpassungen gemacht wurden!
%options.behav.flagMoveCost = 1;

options.behav.fsample = 60;
options.behav.preFirstLaserTime = 150/1000; % 150ms
options.behav.movAvgWin = 100;
options.behav.minResponseDistance = 20; % in samples, responses closer to that will be unified to one movement
options.behav.minStepSize = 10*pi/180; % in radians, everything below will be discarded as a small shield move

options.behav.kernelPreSamples = 5*options.behav.fsample;
options.behav.kernelPostSamples = 1*options.behav.fsample;
options.behav.kernelPreSamplesEvi = 5;
options.behav.kernelPostSamplesEvi = 4;
options.behav.flagBaselineCorrectKernels = 0;
options.behav.flagUseBinaryRegression = 0;
options.behav.flagNormaliseEvidence = 0;
options.behav.nSamplesKernelBaseline = 1.5*options.behav.fsample;
options.behav.kernelSteepnessIndices = [5 4];

options.behav.adjustPreSamples = 1*options.behav.fsample;
options.behav.adjustPostSamples = 9*options.behav.fsample;
options.behav.flagNormaliseAdjustments = 1;

options.behav.lrPreSamples = 2;
options.behav.lrPostSamples = 7;
options.behav.lrExclusion = false;
options.behav.lrCutoff = [0 0.8];%0 0.8[-2.5 3];%[-0.6 1.3];%[-2.5 3];%1.5; % try [-0.2:0.8]; Cedric: [-0.6 1.3]
options.behav.lrCorrCutoff = 0.1;
options.behav.evokedLrIdxPost = [3 4]; % samples that count as post-change point LR - relative to first sample at CP
options.behav.evokedLrIdxPre = 1; % sample that counts as 'at change-point' LR - relative to first sample at CP

%options.behav.meanJumpSet = [-3 -2 -1.5 -1 -0.5 0.5 1 1.5 2 3]*20*pi/180;
%options.behav.varianceSet = [10 20 30]*pi/180;
options.behav.maxRtSamples = 2*options.behav.fsample; 
% distance between jump sizes is min=2s in volatile conditions

