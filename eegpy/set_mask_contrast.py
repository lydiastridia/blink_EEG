"""Purpose: sets the colour of the mask: mask colour = 255 x mask contrast
(contrast 0 = black, invisible on the background; contrast 1 = white, strongest mask).

Input:  D          screen with stimuli (prep_stimuli)
        contrast   mask contrast between 0 and 1
"""


def set_mask_contrast(D, contrast):
    color = [255 * contrast, 255 * contrast, 255 * contrast]
    for rect in D['mask']:
        rect.fillColor = color
