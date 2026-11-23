"""Purpose: this shows an example with explanations so that participants get a closer idea about what to expect, 
this is an optional file and can easily be removed

Input:  D   screen with stimuli (prep_stimuli)
        P   settings (params.py)
"""
from psychopy import visual

from draw_fixation import draw_fixation
from draw_mask import draw_mask
from draw_target import draw_target
from get_key import get_key
from set_mask_contrast import set_mask_contrast
from text_msg import text_msg


def run_example_trial(D, P):
    win = D['win']
    pix = D['pix']
    tarPos = 3                 # position used in the example
    exampleContrast = 0.6      # clearly visible mask, for the example only
    set_mask_contrast(D, exampleContrast)

    # text below the circle of positions (in PsychoPy, negative y is below the centre)
    textBelow = visual.TextStim(win, text='', pos=(0, -(P['targetRadius'] + 60) * pix),
                                height=P['textSize'] * pix, color=P['textColor'], colorSpace='rgb255',
                                wrapWidth=1.6, anchorVert='top')

    # red circle around the target
    circleRadius = (P['maskSpace'] + P['maskRectLength'] + 8) * pix
    circle = visual.Circle(win, radius=circleRadius, pos=D['positions'][tarPos - 1], fillColor=None,
                           lineColor=[220, 0, 0], colorSpace='rgb255', lineWidth=3)

    # 1. Fixation (text just below the cross)
    draw_fixation(D)
    textBelow.pos = (0, -60 * pix)
    textBelow.text = P['text']['example1']
    textBelow.draw()
    win.flip()
    get_key(['space'])
    textBelow.pos = (0, -(P['targetRadius'] + 60) * pix)

    # 2. The square
    draw_fixation(D)
    draw_target(D, tarPos)
    circle.draw()
    textBelow.text = P['text']['example2']
    textBelow.draw()
    win.flip()
    get_key(['space'])

    # 3. The mask
    draw_fixation(D)
    draw_mask(D)
    textBelow.text = P['text']['example3']
    textBelow.draw()
    win.flip()
    get_key(['space'])

    # 4. Both together
    draw_fixation(D)
    draw_target(D, tarPos)
    draw_mask(D)
    circle.draw()
    textBelow.text = P['text']['example4']
    textBelow.draw()
    win.flip()
    get_key(['space'])

    # 5. The rating
    text_msg(D, P['text']['example5'])
    get_key(['space'])
