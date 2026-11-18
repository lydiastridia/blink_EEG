"""Purpose: count-down 3-2-1 (1 s each), then 1 s of fixation, before a block starts.

Input:  D   screen with stimuli (prep_stimuli)
"""
from psychopy import core

from show_fixation import show_fixation
from text_msg import text_msg


def countdown(D):
    for number in ['3', '2', '1']:
        text_msg(D, number)
        core.wait(1.0)
    show_fixation(D, 1.0)
