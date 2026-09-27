# The Effect of Volatility and Noise Instructions on Belief Updating in an Ambiguous Environment

Code for the bachelor's thesis by Liv Schröder (Cognitive Science, University of
Osnabrück, 2026). Supervisors: Prof. Dr. Lilian Weber, Dr. Frank Hezemans.

This study asked whether the belief that an environment is volatile or stochastic is enough to shift belief-updating behaviour, even when nothing about the environment's actual statistics changes. In a continuous predictive inference task, participants used a shield to catch laser beams. They saw the same change-point and random-walk sequences twice: once while told the source was volatile with little noise, and once while told it was stable with a lot of noise.

## Contents

| Folder | Contents |
|---|---|
| `lasker-task-main/` | The online experiment|
| `CoIn_stimulus_generation-master/` | Python code that generates and selects the ambiguous sequences |
| `Analysis_MatlabCode/` | MATLAB analysis: preprocessing, measures, mixed-effects models, figures and robustness checks |


## Running the analysis

1. Open MATLAB (developed with R2025a; the Statistics and Machine Learning
   Toolbox is required).
2. Run `peduks_coin_setup_paths.m` in `Analysis_MatlabCode/` — it adds all
   subfolders to the path.
3. Set the data directory in `config/peduks_coin_options.m`.
4. Run `subject_level/loop_peduks_coin_behav.m` to preprocess all participants.
5. Run `results_figures/CP_results_summary.m` and `RW_results_summary.m` for the
   results tables, and `results_figures/CP_results_plots_together.m` for the
   main figure. The scripts in `robustness/` are run individually.

Subfolders: `config/` (options and subject settings), `subject_level/`
(preprocessing and per-block measures), `group_data/` (tables across
participants), `models/` (linear mixed-effects models), `results_figures/`,
`robustness/`.

## Origin of the code

The task and the analysis build on code from the study by Weber et al. (2026).
