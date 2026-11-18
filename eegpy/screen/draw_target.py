"""Purpose: draws the target at one of the 16 positions. It appears at the next flip.

Input:  D          screen with stimuli (prep_stimuli)
        position   1-16
"""


def draw_target(D, position):
    D['target'].pos = D['positions'][position - 1]
    D['target'].draw()
