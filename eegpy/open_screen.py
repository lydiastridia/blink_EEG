"""Purpose: opens the PsychoPy window.
All sizes in params.py are given in pixels (as in the MATLAB version). PsychoPy works here in
'height' units (1 = the height of the screen), so every size is divided by P['SCREEN_HEIGHT_PIX'].

Input:  P   settings (params.py)
Output: D   dictionary that holds the window and, later, all stimuli (see prep_stimuli)
"""
from psychopy import visual


def open_screen(P):
    if P['fullScreen']:
        win = visual.Window(fullscr=True, screen=P['screen'], color=P['bgColor'],
                            colorSpace='rgb255', units='height', allowGUI=False)
    else:
        win = visual.Window(size=[1200, 750], fullscr=False, screen=P['screen'],
                            color=P['bgColor'], colorSpace='rgb255', units='height')
    win.mouseVisible = False

    D = {'win': win, 'P': P, 'pix': 1.0 / P['SCREEN_HEIGHT_PIX']}  # D['pix'] = one pixel in height units
    return D
