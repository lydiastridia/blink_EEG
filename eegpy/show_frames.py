"""Purpose: shows the fixation cross, plus a target or the mask, for a number of screen frames
(1 frame = 16.7 ms at 60 Hz). Counting frames is how the durations are kept exact.

Input:  D         screen with stimuli (prep_stimuli)
        nFrames   number of frames
        what      ''      : fixation cross only
                  'mask'  : fixation cross and mask
                  1-16    : fixation cross and the target at that position
                  0       : fixation cross only (target missing on this trial)
Output: onset     time at which the first frame appeared on the screen
"""
from draw_fixation import draw_fixation
from draw_mask import draw_mask
from draw_target import draw_target


def show_frames(D, nFrames, what):
    onset = None
    for framei in range(nFrames):
        draw_fixation(D)
        if what == 'mask':
            draw_mask(D)
        elif what != '' and what > 0:
            draw_target(D, what)
        flipTime = D['win'].flip()
        if framei == 0:
            onset = flipTime
    return onset
