"""Purpose: makes the mask: four small rectangles (left, right, below, above) around each of the
16 positions (as in prepMask.m). The colour is set later with set_mask_contrast.

Input:  D           screen (open_screen)
        positions   the 16 positions (find_positions)
Output: mask        list of 64 rectangles
"""
from psychopy import visual


def prep_mask(D, positions):
    P = D['P']
    pix = D['pix']
    space = P['maskSpace'] * pix        # distance from the position to a rectangle
    length = P['maskRectLength'] * pix
    width = P['maskRectWidth'] * pix

    mask = []
    for (x, y) in positions:
        rects = [(x - space - length / 2, y, length, width),   # left
                 (x + space + length / 2, y, length, width),   # right
                 (x, y - space - length / 2, width, length),   # below
                 (x, y + space + length / 2, width, length)]   # above
        for (cx, cy, w, h) in rects:
            mask.append(visual.Rect(D['win'], width=w, height=h, pos=(cx, cy), fillColor=[0, 0, 0],
                                    lineColor=None, colorSpace='rgb255'))
    return mask
