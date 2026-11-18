"""Purpose: chooses the positions of the deviant trials. Run it after add_positions.
    deviant       : T1 is the duplet's T1 (already set); T2 at a random allowed position
    randomDeviant : T1 at a random position that is never a T1 (allowed_random_T1_positions);
                    T2 at a random allowed position
Allowed T2 positions: see allowed_deviant_positions and deviant_keep_clear.

Input:  trials   trial list (after add_positions)
        pos      positions of the participant (make_positions)
        P        settings (params.py)
Output: trials   the same list; deviant trials now have their positions
"""
import random

from allowed_deviant_positions import allowed_deviant_positions
from allowed_random_T1_positions import allowed_random_T1_positions
from deviant_keep_clear import deviant_keep_clear


def add_deviant_positions(trials, pos, P):
    for trial in trials:
        if trial['trialType'] == 'randomDeviant':
            trial['T1position'] = random.choice(allowed_random_T1_positions(pos))

        if trial['trialType'] == 'deviant' or trial['trialType'] == 'randomDeviant':
            keepClear = deviant_keep_clear(trial, pos, P)
            allowed = allowed_deviant_positions(trial['T1position'], keepClear, P)
            trial['T2position'] = random.choice(allowed)
    return trials
