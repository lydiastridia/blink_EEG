"""Purpose: computes the 16 target positions on a circle around the fixation cross.
Positions are numbered clockwise, starting at the top (as in findPositions.m):
1-8 are on the right, 9-16 on the left. No position lies on the vertical or horizontal midline.

Input:  P           settings (params.py)
Output: positions   list of (x, y) in height units; positions[0] is position 1.
                    In PsychoPy (0, 0) is the centre of the screen and y goes up.
"""
import math


def find_positions(P):
    pix = 1.0 / P['SCREEN_HEIGHT_PIX']
    radius = P['targetRadius'] * pix
    nPositions = P['nPositions']
    angle = 2 * math.pi / nPositions  # 22.5 degrees

    positions = []
    for posi in range(nPositions):
        a = angle / 2 + posi * angle  # half a step from the top, so that no position is on the midline
        positions.append((radius * math.sin(a), radius * math.cos(a)))
    return positions
