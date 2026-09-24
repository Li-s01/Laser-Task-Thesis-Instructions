# CoIn (Continuous Inference) Laser Stimulus Generator (Python version)

Python translation of the original MATLAB stimulus generation codebase for the Peduks study's continuous laser task. This package generates stimulus sequences with block-wise volatility and noise manipulation for use with the coin task (Save-the-World-Task).

## Project Structure

```
CoIn_stimulus_generation/
├── coin_script_sequence_generation.py   # Main entry point — generates all sessions
├── generate_laser_session.py             # Assembles a full session (multiple blocks)
├── generate_laser_session_practice.py    # Same, but shorter practice sessions
├── generate_mean_jumps.py                # Generates the underlying true mean trajectory
├── generate_block_stimulus.py            # Fills each epoch with noisy laser observations
├── generate_value_vec.py                 # Core: draws durations & values per epoch
├── design_vola_stocha.py                 # Defines volatility/noise block conditions
├── generate_coin_session_csv_files.py    # Exports sessions as PsychoPy-ready CSVs
├── write_session_to_csv_file.py          # Per-block CSV writer
├── write_exp_csv_file.py                 # Experiment-level CSV with block metadata
├── write_exp_csv_file_with_tones.py      # Variant with tone stimuli
├── laser_colours.py                      # Colour definitions for each condition
├── analyse_session.py                    # Session analysis & summary statistics
├── plot_session.py                       # Plotting utilities
├── test_all.py                           # Full test suite
└── sequences/                            # Generated output (gitignored)
```

## How It Works

1. **Design**: `design_vola_stocha.py` defines 4 block types with different volatility and noise levels.
2. **Mean trajectory**: `generate_mean_jumps.py` creates the true underlying laser position that jumps at block-type-dependent rates.
3. **Noisy observations**: `generate_value_vec.py` fills each stable-mean epoch with noisy observation values. Durations are drawn from a truncated exponential distribution (hard bounds: 6–60 frames at 60 Hz). Values are drawn from a normal distribution around the current true mean.
4. **Assembly**: `generate_block_stimulus.py` stitches epochs together into full blocks. `generate_laser_session.py` combines blocks into sessions.
5. **Export**: CSV files are written per-block with columns `true_pos`, `obs_pos`, `true_var` (one row per frame at 60 Hz).

## Configuration

All high-level experimental parameters are centralized in `config.py`. You can adjust:

- **`SAMPLE_RATE`**: Default is 60Hz.
- **Session Durations**: Change `blockDurationMin` for `MAIN_SESSION`, `ONLINE_TRAINING_SESSION`, and `PRACTICE_SESSION` in minutes.
- **Jump Limits**: Adjust `JUMP_DURATION_MEAN_SEC`, `JUMP_DURATION_MIN_SEC`, and `JUMP_DURATION_MAX_SEC` to manipulate the distributions for the time the laser stays in one place.
- **Block Properties**: Override the number of blocks per session type, or the base noise levels (`NOISE_STD_LOW` and `NOISE_STD_HIGH`).
- **Version/Output Control**: The `VERSION` prefix modifies the output folder/file names (e.g. `v4`).
- **Export Path**: Modify `OUTPUT_DIR` (defaults to `sequences/`). _💡 Hint: You can provide an absolute path here to generate sequences directly into your PsychoPy/task codebase's resources folder!_

If you modify these and want to ensure structural sequence logic still works smoothly, run `python test_all.py`.

## Usage

```bash
cd CoIn_stimulus_generation
python coin_script_sequence_generation.py
```

This generates all session types (practice, online training, baseline, main) and exports counterbalanced CSV files into `sequences/`.

## Running Tests

```bash
cd CoIn_stimulus_generation
python test_all.py
```

## Changes from Original MATLAB

### Truncation Fix

**Affected files**: `generate_value_vec.py`, `generate_block_stimulus_random_walk.py`

#### The Problem

`generate_value_vec` draws observation durations from a truncated exponential distribution (bounded to [6, 60] frames) until the total exceeds the epoch length. It then sliced the overshoot off the last duration to fit exactly — e.g. a legally drawn 8-frame duration could become 1 frame if the overshoot was 7. This violated the 6-frame (100 ms) hard lower bound.

The bug occurred at every epoch boundary (every time the true mean jumps), affecting ~50 seams per 3-minute block. Testing confirmed 1-frame observations in 22 out of 72 generated CSV files.

#### The Fix (Merge Approach)

The overshoot is corrected _before_ values are painted. If trimming the last duration drops it below `min_dur`, the fragment is removed and its frames are absorbed into the preceding duration. Old logic is preserved as comments.

#### Design Considerations

The merge causes the predecessor observation to last slightly longer than its original exponential draw (~9 extra frames on average). This affects ~8% of observations per block (the last observation of each epoch). However, this stretch falls well within the natural variance of the exponential distribution (mean=18, range=[6, 60]), making it indistinguishable from normal variation in both participant perception and statistical analysis.

#### Alternative Approaches Considered

| Approach           | How it works                                                         | Trade-off                                                         |
| ------------------ | -------------------------------------------------------------------- | ----------------------------------------------------------------- |
| **Merge** (chosen) | Absorb sub-minimum tail into predecessor                             | One observation per epoch is slightly longer                      |
| **Fit-from-below** | Stop drawing early, stretch last duration to fill remainder          | Same magnitude of distortion, but requires rewriting the loop     |
| **Redraw**         | Reject and regenerate entire duration sequence until it fits cleanly | Zero statistical bias, but unpredictable runtime for short epochs |

The merge approach was chosen because it is minimal (3 lines), always terminates, and its statistical cost is unmeasurable in practice. The redraw approach is the only statistically "pure" option but introduces complexity and performance risk for no practical gain.
