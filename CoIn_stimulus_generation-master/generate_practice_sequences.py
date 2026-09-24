import numpy as np
from generate_mean_jumps import generate_mean_jumps
from generate_block_stimulus import generate_block_stimulus
from write_session_to_csv_file import write_session_to_csv_file
import config

DURATION_MIN = 1
SAMPLE_RATE  = config.SAMPLE_RATE
jump_values=[-35, -30, -25, 25, 30, 35]

# jump duration settings (same as main experiment)
JUMP_DUR = {
    'mean': config.JUMP_DURATION_MEAN_SEC * SAMPLE_RATE,
    'min':  config.JUMP_DURATION_MIN_SEC  * SAMPLE_RATE,
    'max':  config.JUMP_DURATION_MAX_SEC  * SAMPLE_RATE,
}

def generate_cp_practice(noise, dur_mean_std_min_max, seed, filename):
    block_design = {
        'noiseStd':         noise,
        'durMeanStdMinMax': dur_mean_std_min_max,
        'jumpValueSet':    jump_values,
    }
    session = {
        'nBlocks':       1,
        'blockDuration': DURATION_MIN,
        'sampleRate':    SAMPLE_RATE,
        'jumpDuration':  JUMP_DUR,
        'blocks':        [],
    }
    np.random.seed(seed)
    stim = generate_mean_jumps(DURATION_MIN * 60, block_design, SAMPLE_RATE)
    stim = generate_block_stimulus(stim, session, noise)
    session['blocks'].append({
        'blockID':   1,
        'blockType': 'practice',
        'duration':  DURATION_MIN * 60,
        'stim':      stim,
    })
    write_session_to_csv_file(session, filename, config.OUTPUT_DIR)
    print(f"Saved: {config.OUTPUT_DIR}/{filename}_block1.csv")


if __name__ == '__main__':
    # Volatile practice: 
    generate_cp_practice(
        noise=16,
        dur_mean_std_min_max=[4, 1, 2, 6],
        seed=42,
        filename='practice_cp_volatile'
    )

    # Noise practice: 
    generate_cp_practice(
        noise=24,
        dur_mean_std_min_max=[10, 2, 8, 15],
        seed=99,
        filename='practice_cp_noise'
    )