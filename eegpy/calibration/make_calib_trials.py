"""Purpose: makes the trial list of the calibration. As in the original code, all trials
(every position equally often, plus the target-absent trials) are put in one list and shuffled.

Input:  P        settings (params.py)
Output: trials   list of trials; each trial has
                 cond     1 = target present, 0 = target absent
                 tarPos   target position (1-16), 0 on target-absent trials
                 ITI      duration of the inter-trial interval (s)
"""
import random


def make_calib_trials(P):
    nTarPresTrials = P['nPositions'] * P['nTrialsPerPosition']   # 16 x 5 = 80
    nTarAbsTrials = int(round(nTarPresTrials / (1 - P['propAbsent']))) - nTarPresTrials   # 20

    # one list: every position nTrialsPerPosition times, and a 0 for every target-absent trial
    allPositions = list(range(1, P['nPositions'] + 1)) * P['nTrialsPerPosition'] + [0] * nTarAbsTrials
    random.shuffle(allPositions)

    trials = []
    for tarPos in allPositions:
        trial = {'tarPos': tarPos}
        if tarPos == 0:
            trial['cond'] = 0   # target absent
        else:
            trial['cond'] = 1   # target present
        trial['ITI'] = random.choice(P['ITI'])
        trials.append(trial)
    return trials
