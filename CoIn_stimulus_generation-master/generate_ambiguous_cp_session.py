"""
Generates a session of ambiguous change-point blocks.
"""
from design_ambiguous_cp import design_ambiguous_cp
from generate_mean_jumps import generate_mean_jumps
from generate_block_stimulus import generate_block_stimulus
from write_session_to_csv_file import write_session_to_csv_file
import config


def generate_ambiguous_cp_session(n_blocks=4,
                                   session_file_name='ambiguous_cp',
                                   output_dir='sequences'):

    # Basic session settings
    session = {}
    session['nBlocks'] = n_blocks
    session['blockDuration'] = config.MAIN_SESSION['blockDurationMin']  
    session['design'] = design_ambiguous_cp()
    session['blockSequence'] = [1] * n_blocks  # all blocks have the same type
    session['blockTypes'] = session['design']['blockTypes']
    session['sampleRate'] = config.SAMPLE_RATE

    # Jump durations, changed from seconds to samples
    session['jumpDuration'] = {
        'mean': config.JUMP_DURATION_MEAN_SEC * config.SAMPLE_RATE,
        'min': config.JUMP_DURATION_MIN_SEC * config.SAMPLE_RATE,
        'max': config.JUMP_DURATION_MAX_SEC * config.SAMPLE_RATE,
    }

    # Make one stimulus for each block
    session['blocks'] = []
    for i_block in range(n_blocks):
        # There is only one block design, so we always use the first one
        block_design = session['design']['blocks'][0]

        # Make the mean values with jumps 
        stim = generate_mean_jumps(
             session['blockDuration'] * 60,
             block_design,
             session['sampleRate']
         )

        # Add noise to the mean values
        stim = generate_block_stimulus(stim, session, block_design['noiseStd'])

        # Save the block
        block = {
            'blockID': 1,
            'blockType': 'ambiguousCP',
            'duration': session['blockDuration'] * 60,
            'stim': stim,
        }
        session['blocks'].append(block)

    # Save the whole session as CSV files
    write_session_to_csv_file(session, session_file_name, output_dir)
    return session
