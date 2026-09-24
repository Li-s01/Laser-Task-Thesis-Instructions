"""
config.py

Centralized configuration file for the CoIn (Continuous Inference) Laser Stimulus Generator.
This file contains the high-level parameters for generating the experimental sequences.
"""

# =============================================================================
# Global Settings
# =============================================================================
# The sampling rate for all sequences in Hz (e.g. 60 for PsychoPy/monitor refresh rate)
SAMPLE_RATE = 60

# Version strings used for output folder and file naming.
# NOTE: VERSION and VERSION_PRACTICE must match the corresponding fields
# in laserTaskRefactor/laserTask/config.py (sequence_version and
# practice_sequence_version). Update both sides when regenerating.
VERSION = "v4"
VERSION_PRACTICE = "v3"

# Output directory for the generated sequences
# By default ('sequences'), it creates a folder inside the current directory.
# You can change this to an absolute path to export directly to a task codebase
# (e.g., OUTPUT_DIR = '/home/user/my_experiment/resources/sequences').
OUTPUT_DIR = (
    "/Users/livschroder/Documents/Bachelorarbeit/coinTaskThesisStudents-main/sequences"
)


# =============================================================================
# Experimental Parameters
# =============================================================================

# Bounds for drawing the "jump" durations per epoch.
# The laser stays in one position (epoch) for a period drawn from a
# truncated exponential distribution. These are in seconds.
JUMP_DURATION_MEAN_SEC = 0.3
JUMP_DURATION_MIN_SEC = 0.1
JUMP_DURATION_MAX_SEC = 1.0

# Base characteristics of the block conditions:
DUR_MEAN_STD_MIN_MAX_STABLE = [
    10,
    1.5,
    8,
    15,
]  # [Mean, Std, Min, Max] of epochs per block
DUR_MEAN_STD_MIN_MAX_VOLATILE = [
    3,
    1.5,
    2,
    6,
]  # [Mean, Std, Min, Max] of epochs per block


# Noise values for the observations (in degrees)
NOISE_STD_LOW = 10
NOISE_STD_HIGH = 20


# Allowed jumps for the mean position in degrees
# (When the true mean jumps, it jumps by one of these values)
JUMP_VALUE_SET = [-40, -30, -20, 20, 30, 40]

#--Ambiguous Change-Point condition----
NOISE_STD_AMBIGUOUS_CP = 22 
JUMP_VALUE_SET_AMBIGUOUS_CP = [-25, -20, -15, 15, 20, 25]  #smaller than normal
DUR_MEAN_STD_MIN_MAX_AMBIGUOUS_CP = [6, 1.5, 2, 10]  # intermediate volatility

#---Ambiguous Random Walk condition---
SIGMA_STREAM_AMBIGUOUS_RW = 2.0   # intermediate between 1.5 (stable) and 3 (volatile)
SIGMA_OBS_AMBIGUOUS_RW = 20       # same as NOISE_STD_HIGH 

# =============================================================================
# Session Configurations
# =============================================================================
# Settings specific to different types of sessions. The durations are in minutes.

# For standard/main EEG infusion sessions and Random Walk online equivalents
MAIN_SESSION = {
    "nBlocks": 12,  # Often 4 block types * 3 repetitions
    "blockDurationMin": 3,  # Duration per block in minutes
}

# For online training sessions
ONLINE_TRAINING_SESSION = {"nBlocks": 4, "blockDurationMin": 0.5}

# For short practice sessions (e.g. before the main task)
PRACTICE_SESSION = {"nBlocks": 4, "blockDurationMin": 1}

# For general testing and standard "generate_laser_session" function defaults
DEFAULT_SESSION = {"nBlocks": 12, "blockDurationMin": 3}
