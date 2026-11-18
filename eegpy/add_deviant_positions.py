"""Purpose: chooses the T2 position of every deviant trial, at random from the allowed positions
(allowed_deviant_positions). Run it after add_positions.

Input:  trials   trial list (after add_positions)
        pos      duplets of the participant (make_positions)
        P        settings (params.py)
Output: trials   the same list; deviant trials now have their T2position
"""
import random

from allowed_deviant_positions import allowed_deviant_positions


def add_deviant_positions(trials, pos, P):
    for trial in trials:
        if trial['trialType'] == 'deviant':
            allowed = allowed_deviant_positions(pos[trial['visibility']], trial['T1duplet'], P)
            trial['T2position'] = random.choice(allowed)
    return trials
