"""Purpose: shows one trial of the learning phase (also used in the test phase):
fixation (1 s) -> T1 -> ISI -> mask -> fixation (1 s) -> T2 -> ISI -> mask -> delay (2 s).
When T2 is missing (omission), only the fixation cross is shown in its place; the mask still follows.
If P['maskT2'] is False, T2 is not followed by a mask.
The mask contrast must have been set before with set_mask_contrast.

Input:  D        screen with stimuli (prep_stimuli)
        P        settings (params.py)
        trial    one trial of the trial list (with T1position and T2position)
Output: timing   when everything appeared, to check the timing afterwards (seconds)
"""
from show_frames import show_frames


def run_learning_trial(D, P, trial):
    F = P['frames']
    show_frames(D, F['initFix'], '')                              # fixation
    T1Onset = show_frames(D, F['target'], trial['T1position'])    # T1
    ISI1Onset = show_frames(D, F['ISI'], '')                      # ISI
    mask1Onset = show_frames(D, F['mask'], 'mask')                # mask
    show_frames(D, F['blank'], '')                                # fixation between mask and T2
    T2Onset = show_frames(D, F['target'], trial['T2position'])    # T2 (0 = missing)

    if P['maskT2']:
        T2Offset = show_frames(D, F['ISI'], '')                   # ISI
        mask2Onset = show_frames(D, F['mask'], 'mask')            # mask
        show_frames(D, F['delay'], '')                            # delay
        mask2 = mask2Onset - T1Onset
    else:
        T2Offset = show_frames(D, F['delay'], '')                 # delay directly after T2
        mask2 = 0

    timing = {'T1Duration': ISI1Onset - T1Onset,       # should be 0.0167
              'mask1Onset': mask1Onset - T1Onset,      # should be 0.0333
              'T2Onset': T2Onset - T1Onset,            # should be 1.2667
              'T2Duration': T2Offset - T2Onset,        # should be 0.0167
              'mask2Onset': mask2}                     # should be 1.3 (0 = no second mask)
    return timing
