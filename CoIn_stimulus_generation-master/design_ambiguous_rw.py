"""
Ambiguous random walk environment
"""
import config


def design_ambiguous_rw():
    design = {}
    design['blockTypes'] = ['ambiguousRW']

    blocks = [None] * 1
    blocks[0] = {
        'sigmaStream': config.SIGMA_STREAM_AMBIGUOUS_RW,
        'sigmaObs': config.SIGMA_OBS_AMBIGUOUS_RW,
    }

    design['blocks'] = blocks
    return design