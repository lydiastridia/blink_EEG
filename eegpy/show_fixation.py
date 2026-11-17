"""Purpose: shows only the fixation cross for a number of seconds (e.g. the ITI).

Input:  D         screen with stimuli (prep_stimuli)
        seconds   duration in seconds
"""
from show_frames import show_frames


def show_fixation(D, seconds):
    nFrames = max(1, int(round(seconds * D['P']['refreshRate'])))
    show_frames(D, nFrames, '')
