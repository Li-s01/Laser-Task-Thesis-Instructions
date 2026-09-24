"""
Ambiguous change-point environment
"""
import config


def design_ambiguous_cp():
    design = {}
    design['blockTypes'] = ['ambiguousCP']

    blocks = [None] * 1
    blocks[0] = {
        'durMeanStdMinMax': config.DUR_MEAN_STD_MIN_MAX_AMBIGUOUS_CP,
        'noiseStd': config.NOISE_STD_AMBIGUOUS_CP,
        'jumpValueSet': config.JUMP_VALUE_SET_AMBIGUOUS_CP,
    }

    design['blocks'] = blocks
    return design