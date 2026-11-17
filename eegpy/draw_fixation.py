"""Purpose: draws the fixation cross. It appears at the next flip.

Input:  D   screen with stimuli (prep_stimuli)
"""


def draw_fixation(D):
    for part in D['fix']:
        part.draw()
