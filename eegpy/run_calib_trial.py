"""Purpose: shows one calibration trial:
fixation -> target (or nothing) -> ISI -> mask -> 'Seen?' -> ITI.

Input:  D              screen with stimuli (prep_stimuli)
        P              settings (params.py)
        trial          one trial of the calibration list (make_calib_trials)
        maskContrast   mask contrast on this trial
Output: result         the answer and the timing of this trial
"""
from get_rating import get_rating
from set_mask_contrast import set_mask_contrast
from show_fixation import show_fixation
from show_frames import show_frames
from text_msg import text_msg


def run_calib_trial(D, P, trial, maskContrast):
    F = P['frames']
    set_mask_contrast(D, maskContrast)

    show_frames(D, F['calibFix'], '')                       # fixation
    if trial['cond'] == 1:
        targetOnset = show_frames(D, F['target'], trial['tarPos'])   # target
    else:
        targetOnset = show_frames(D, F['target'], '')               # no target
    ISIOnset = show_frames(D, F['ISI'], '')                 # ISI
    show_frames(D, F['mask'], 'mask')                       # mask

    text_msg(D, P['text']['vis'])                           # 'Seen?'
    rating, RT = get_rating()
    show_fixation(D, trial['ITI'])                          # ITI

    result = {'cond': trial['cond'], 'tarPos': trial['tarPos'], 'maskContrast': maskContrast,
              'rating': rating, 'RT': RT, 'targetDuration': ISIOnset - targetOnset}
    return result
