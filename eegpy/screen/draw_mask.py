"""Purpose: draws the mask around all positions. It appears at the next flip.
The colour must have been set before with set_mask_contrast.

Input:  D   screen with stimuli (prep_stimuli)
"""


def draw_mask(D):
    for rect in D['mask']:
        rect.draw()
