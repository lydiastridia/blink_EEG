"""Purpose: location answer with the mouse (as nonconSeq_showFrame_mouseresponse_seq.m of the
original code). The cursor is put in the centre and shown. The answer is the position whose
square the cursor enters first; it counts at once, no click is needed. The square around each
position is as large as in the original code (infixationtarget.m): half the horizontal distance
between positions 1 and 16, minus one pixel, on each side of the position.
The letters and the question stay on the screen while the participant moves the mouse.
ESCAPE stops the task (raises AbortExperiment).

Input:  D          screen with stimuli (prep_stimuli); the letters and the question text
                   must already be set
Output: position   1-16, the position that was chosen
        RT         response time in seconds (from the moment the question appeared)
"""
from psychopy import core, event

from abort_experiment import AbortExperiment


def get_location_mouse(D):
    win = D['win']
    mouse = D['mouse']
    positions = D['positions']
    halfSide = (positions[0][0] - positions[-1][0]) / 2 - D['pix']   # positions 1 and 16

    event.clearEvents()
    mouse.setPos((0, 0))       # start in the centre
    mouse.setVisible(True)
    clock = core.Clock()
    position = 0
    while position == 0:
        for letter in D['letters']:
            letter.draw()
        D['centreText'].draw()
        win.flip()
        if event.getKeys(['escape']):
            mouse.setVisible(False)
            raise AbortExperiment()
        x, y = mouse.getPos()
        for posi, (px, py) in enumerate(positions):
            if abs(x - px) <= halfSide and abs(y - py) <= halfSide:
                position = posi + 1
                break
    RT = clock.getTime()
    mouse.setVisible(False)
    return position, RT
