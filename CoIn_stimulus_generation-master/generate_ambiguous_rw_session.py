"""
Generates a session of ambiguous random walk blocks.
"""
from design_ambiguous_rw import design_ambiguous_rw
from generate_block_stimulus_random_walk import generate_block_stimulus_random_walk
from write_session_to_csv_file import write_session_to_csv_file
import config


def generate_ambiguous_rw_session(n_blocks=4,
                                   session_file_name='ambiguous_rw',
                                   output_dir='sequences'):

    # Basic session settings
    session = {}
    session['nBlocks'] = n_blocks
    session['blockDuration'] = config.MAIN_SESSION['blockDurationMin']
    session['design'] = design_ambiguous_rw()
    session['blockSequence'] = [1] * n_blocks  # all blocks have the same type
    session['blockTypes'] = session['design']['blockTypes']
    session['sampleRate'] = config.SAMPLE_RATE

    # Jump durations, changed from seconds to samples
    session['jumpDuration'] = {
        'mean': config.JUMP_DURATION_MEAN_SEC * config.SAMPLE_RATE,
        'min': config.JUMP_DURATION_MIN_SEC * config.SAMPLE_RATE,
        'max': config.JUMP_DURATION_MAX_SEC * config.SAMPLE_RATE,
    }

    # There is only one block design, so we always use the first one.
    # Add the settings that the random walk function needs.
    block_design = session['design']['blocks'][0]
    block_design['stimDur'] = session['blockDuration'] * 60
    block_design['Fs'] = session['sampleRate']
    block_design['doJitter'] = 1  # turn jitter on
    block_design['jitter'] = {
        'mean': session['jumpDuration']['mean'],
        'min': session['jumpDuration']['min'],
        'max': session['jumpDuration']['max'],
    }

    # Make one stimulus for each block
    session['blocks'] = []
    for i_block in range(n_blocks):
        # Make the random walk stimulus
        stim = generate_block_stimulus_random_walk(
            session['design']['blocks'][0]
        )

        # Save the block
        block = {
            'blockID': 1,
            'blockType': 'ambiguousRW',
            'duration': session['blockDuration'] * 60,
            'stim': stim,
        }
        session['blocks'].append(block)

    # Save the whole session as CSV files
    write_session_to_csv_file(session, session_file_name, output_dir)
    return session
