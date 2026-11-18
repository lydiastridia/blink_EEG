"""Purpose: makes all stimuli once, before the task starts, and stores them in D:
the fixation cross, the target, the mask, the text in the centre and the 16 letters.

Input:  D   screen (open_screen)
Output: D   the same dictionary, now also with the stimuli
"""
from psychopy import visual

from find_positions import find_positions
from prep_mask import prep_mask


def prep_stimuli(D):
    P = D['P']
    pix = D['pix']
    win = D['win']
    positions = find_positions(P)
    D['positions'] = positions

    # fixation cross: two thin rectangles
    length = 2 * P['fixSize'] * pix
    width = P['fixLineWidth'] * pix
    D['fix'] = [visual.Rect(win, width=length, height=width, pos=(0, 0), fillColor=P['fixColor'],
                            lineColor=None, colorSpace='rgb255'),
                visual.Rect(win, width=width, height=length, pos=(0, 0), fillColor=P['fixColor'],
                            lineColor=None, colorSpace='rgb255')]

    # target: one square that is moved to the position of the trial
    D['target'] = visual.Rect(win, width=P['targetSize'] * pix, height=P['targetSize'] * pix, pos=(0, 0),
                              fillColor=P['targetColor'], lineColor=None, colorSpace='rgb255')

    # mask
    D['mask'] = prep_mask(D, positions)

    # texts: instructions in the centre, '1?' / '2?' in the centre, and one letter per position
    D['text'] = visual.TextStim(win, text='', pos=(0, 0), height=P['textSize'] * pix,
                                color=P['textColor'], colorSpace='rgb255', wrapWidth=1.6)
    D['centreText'] = visual.TextStim(win, text='', pos=(0, 0), height=P['letterSize'] * pix,
                                      color=P['textColor'], colorSpace='rgb255')
    D['letters'] = []
    for xy in positions:
        D['letters'].append(visual.TextStim(win, text='', pos=xy, height=P['letterSize'] * pix,
                                            color=P['textColor'], colorSpace='rgb255'))
    return D
