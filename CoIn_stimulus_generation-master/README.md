# CoIn (Continuous Inference) Laser Stimulus Generator — Ambiguous Conditions

Python code for generating stimulus sequences for the continuous laser task (coin task / Save-the-World-Task). It is based on the Python translation of the original MATLAB stimulus generation code from the Peduks study.

This version generates **ambiguous** sequences. In these sequences it is hard to tell whether a change in the observations is a real change of the true mean or just noise. There are two ambiguous conditions:

- **Ambiguous change-point (CP):** The true mean stays in one place and then jumps. The jumps are smaller than in the standard conditions, and the noise is higher. So the jumps are hard to separate from noise.
- **Ambiguous random walk (RW):** The true mean moves slowly and continuously. The noisy observations are drawn around it.

The code also creates two short practice sequences, and it selects the most ambiguous sequences out of many random ones.

## Installation

```bash
pip install -r requirements.txt
```

## Project Structure

```
CoIn_stimulus_generation/
├── config.py                              # All parameters (sample rate, noise, jumps, durations, output path)
│
├── design_ambiguous_cp.py                 # Defines the ambiguous CP condition (noise, jump sizes, epoch durations)
├── design_ambiguous_rw.py                 # Defines the ambiguous RW condition (walk speed, observation noise)
├── generate_ambiguous_cp_session.py       # Generates a session of ambiguous CP blocks and writes CSVs
├── generate_ambiguous_rw_session.py       # Generates a session of ambiguous RW blocks and writes CSVs
│
├── generate_mean_jumps.py                 # CP: true mean trajectory with jumps
├── generate_block_stimulus.py             # CP: adds noisy observations to the true mean
├── generate_value_vec.py                  # CP: draws observation durations and values per epoch
├── generate_block_stimulus_random_walk.py # RW: true mean as a random walk + noisy observations
│
├── sequence_selection.py                  # Generates 50 CP and 50 RW sequences and keeps the 4 most ambiguous of each
├── moving_average_check.py                # Moving average of the observations + interactive comparison plots
├── generate_practice_sequences.py         # Two practice CP sequences (volatile, noisy)
│
├── write_session_to_csv_file.py           # Writes one CSV file per block
├── plot_session.py                        # Plots true mean and observations of each block
├── analyse_session.py                     # Plots movement and step sizes per block
├── laser_colours.py                       # Colour definitions for the plots
├── test_ambiguous_cp.py                   # Generates and plots an example CP session
├── test_ambiguous_rw.py                   # Generates and plots an example RW session
└── sequences/                             # Generated output (gitignored)
```

## How It Works

### Ambiguous change-point (CP)

1. **Design:** `design_ambiguous_cp.py` reads the CP parameters from `config.py`.
2. **True mean:** `generate_mean_jumps.py` creates the true laser position. It stays in one place for a number of observations (drawn from `DUR_MEAN_STD_MIN_MAX_AMBIGUOUS_CP`) and then jumps by one of the values in `JUMP_VALUE_SET_AMBIGUOUS_CP`.
3. **Observations:** `generate_block_stimulus.py` and `generate_value_vec.py` fill each epoch with noisy observations. Each observation is shown for a number of frames drawn from a truncated exponential distribution (`JUMP_DURATION_*_SEC`). Its value is drawn from a normal distribution around the true mean with `NOISE_STD_AMBIGUOUS_CP`.

### Ambiguous random walk (RW)

1. **Design:** `design_ambiguous_rw.py` reads the RW parameters from `config.py`.
2. **Stimulus:** `generate_block_stimulus_random_walk.py` moves the true mean by a small random step every frame (`SIGMA_STREAM_AMBIGUOUS_RW`). A new noisy observation (`SIGMA_OBS_AMBIGUOUS_RW`) is drawn after jittered intervals, using the same duration settings as CP (`JUMP_DURATION_*_SEC`).

### Sequence selection

`sequence_selection.py` makes sure that the final sequences are really ambiguous:

1. It generates 50 CP and 50 RW sequences (seeds 0–49), each with one block.
2. For each sequence it computes a weighted moving average of the observations. The observations are grouped in blocks of 3 (weights 0.1, 0.3, 0.6, newest counts most).
3. It finds periods where this average is more than 10° (half of the 20° shield) away from the true mean, in the same direction. Periods shorter than 30 frames are ignored.
4. Each sequence gets a score: the sum of the squared period durations. So long periods count much more than short ones.
5. The 4 sequences with the highest score are kept for each condition. Each one is saved twice: once as it is and once rotated by 180° on the circle (for a second repetition that looks different).

### Output format

Each CSV file is one block, with one row per frame (60 Hz):

| Column     | Meaning                                  |
| ---------- | ---------------------------------------- |
| `true_pos` | True mean position in degrees (0–359)    |
| `obs_pos`  | Shown observation in degrees (0–359)     |
| `true_var` | Noise standard deviation in degrees      |

## Configuration

All parameters are in `config.py`:

- **`SAMPLE_RATE`:** Frames per second (default 60).
- **`MAIN_SESSION['blockDurationMin']`:** Block length in minutes (default 3). Used for both ambiguous conditions.
- **`JUMP_DURATION_MEAN_SEC`, `_MIN_SEC`, `_MAX_SEC`:** How long each observation is shown.
- **Ambiguous CP:** `NOISE_STD_AMBIGUOUS_CP`, `JUMP_VALUE_SET_AMBIGUOUS_CP`, `DUR_MEAN_STD_MIN_MAX_AMBIGUOUS_CP`.
- **Ambiguous RW:** `SIGMA_STREAM_AMBIGUOUS_RW`, `SIGMA_OBS_AMBIGUOUS_RW`.
- **`OUTPUT_DIR`:** Where `generate_practice_sequences.py` and `moving_average_check.py` read and write files. **Change this to your own path** (for example the `resources/sequences` folder of your task code) or set it to `'sequences'`.

Some settings are set directly in the scripts:

- `sequence_selection.py`: number of sequences, number of best sequences, shield size, moving average weights. It always writes to the local `sequences/` folder.
- `generate_practice_sequences.py`: noise, epoch durations, jump values and seeds of the practice sequences.

## Usage

Generate the final ambiguous sequences:

```bash
python sequence_selection.py
```

This writes `ambiguous_cp_final_block1–4.csv`, `ambiguous_rw_final_block1–4.csv` and their `_rot180` versions to `sequences/`. The plots of the selected sequences (interactive HTML) are saved in `sequences/selection_plots/`.

Generate the practice sequences:

```bash
python generate_practice_sequences.py
```

Generate and plot an example session (to check the parameters):

```bash
python test_ambiguous_cp.py
python test_ambiguous_rw.py
```

All sequences use fixed seeds, so running the scripts again gives the same sequences.

