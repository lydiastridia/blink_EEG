"""Purpose: makes the trial list of the control test phase. It has the same structure as the test
phase: the same number of miniblocks (P['testMiniblocks']), the same number of trials per miniblock,
the same seen/unseen order and a random order within each miniblock. Because there are no duplets,
valid trials, deviants and random deviants are all the same here: trials with a random T2
('random'). Omissions stay omissions, so the omission rate is the same as in the test phase.
The positions are chosen afterwards by add_random_positions.

Input:  P            settings (params.py)
        subjectNum   participant number used for the counterbalancing (info['idNumber'])
Output: trials       list of trials with Miniblock_no, Trial_no, visibility and trialType
"""
import random


def make_control_test_trials(P, subjectNum):
    counts = P['testTrialsPerKind']
    nOmission = counts['omission']
    nRandom = sum(counts[kind] for kind in counts if kind != 'omission')   # valid + deviant + randomDeviant
    nMiniblocks = P['testMiniblocks']
    if nMiniblocks % 2 != 0:
        print('WARNING: %d control test miniblocks: seen and unseen will not have the same number of miniblocks.'
              % nMiniblocks)

    # which visibility comes first (as in the other tasks)
    if subjectNum % 2 == 1:
        visOrder = ['seen', 'unseen']
    else:
        visOrder = ['unseen', 'seen']

    trials = []
    for miniblocki in range(1, nMiniblocks + 1):
        vis = visOrder[(miniblocki - 1) % 2]
        block = [{'trialType': 'random'} for i in range(nRandom)] + \
                [{'trialType': 'omission'} for i in range(nOmission)]
        random.shuffle(block)
        for triali, trial in enumerate(block, start=1):
            trial.update(Miniblock_no=miniblocki, Trial_no=triali, visibility=vis)
            trials.append(trial)
    return trials
