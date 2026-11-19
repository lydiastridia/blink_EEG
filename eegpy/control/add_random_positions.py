"""Purpose: chooses the positions of the control trials, so that T1 never predicts T2.
Separately for seen and unseen trials:
    T1: every position equally often (balanced_positions), on all trials
    T2: every position equally often on the trials with a T2, paired with the T1s at random;
        T2 is never at the position of T1 on the same trial
Omissions get T1 only (T2position = 0). No trial has a predicted T2 (predictedT2position = 0).

Input:  trials   control trial list (make_control_learning_trials or make_control_test_trials)
        P        settings (params.py)
Output: trials   the same list, now with T1position, T2position and predictedT2position
"""
import random

from balanced_positions import balanced_positions


def add_random_positions(trials, P):
    nPositions = P['nPositions']
    for vis in ['seen', 'unseen']:
        withT2 = [t for t in trials if t['visibility'] == vis and t['trialType'] == 'random']
        omissions = [t for t in trials if t['visibility'] == vis and t['trialType'] == 'omission']

        # trials with a T2: T1s and T2s each balanced, then paired at random
        T1s = balanced_positions(len(withT2), nPositions)
        T2s = balanced_positions(len(withT2), nPositions)

        # T2 may not be at the position of T1: swap such a T2 with the T2 of another trial
        for i in range(len(T1s)):
            if T2s[i] == T1s[i]:
                others = [j for j in range(len(T1s)) if T2s[j] != T1s[i] and T2s[i] != T1s[j]]
                if not others:
                    raise RuntimeError('No T2 positions could be found that differ from T1.')
                j = random.choice(others)
                T2s[i], T2s[j] = T2s[j], T2s[i]

        for trial, T1, T2 in zip(withT2, T1s, T2s):
            trial.update(T1position=T1, T2position=T2, predictedT2position=0)

        # omissions: T1 balanced, no T2
        for trial, T1 in zip(omissions, balanced_positions(len(omissions), nPositions)):
            trial.update(T1position=T1, T2position=0, predictedT2position=0)
    return trials
