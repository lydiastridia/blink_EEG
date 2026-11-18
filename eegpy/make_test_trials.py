"""Purpose: makes the trial list of the test phase. Every miniblock contains exactly the numbers of
trials in P['testTrialsPerKind'] (e.g. 20 valid, 16 omissions, 16 deviants). The trials of each kind
are divided equally over the four duplets, and the order within a miniblock is random.
Miniblocks alternate between seen and unseen; odd participant numbers start with seen,
even numbers with unseen (as in the learning phase).

Input:  P            settings (params.py)
        subjectNum   participant number used for the counterbalancing (info['idNumber'])
Output: trials       list of trials with Miniblock_no, Trial_no, visibility, trialType,
                     T1duplet (1-4; 0 = random deviant, no duplet) and T2location (1-4 = that
                     duplet's T2, 0 = no T2, -1 = deviant or random deviant: the positions are
                     chosen later by add_deviant_positions)
"""
import random

from balanced_list import balanced_list


def make_test_trials(P, subjectNum):
    nDuplets = P['nDuplets']
    counts = P['testTrialsPerKind']
    nMiniblocks = P['testMiniblocks']

    # warnings
    for trialType in counts:
        if trialType != 'randomDeviant' and counts[trialType] % nDuplets != 0:
            print('WARNING: %d %s trials per miniblock cannot be divided equally over %d duplets.'
                  % (counts[trialType], trialType, nDuplets))
    if nMiniblocks % 2 != 0:
        print('WARNING: %d test miniblocks: seen and unseen will not have the same number of miniblocks.'
              % nMiniblocks)

    # which visibility comes first
    if subjectNum % 2 == 1:
        visOrder = ['seen', 'unseen']
    else:
        visOrder = ['unseen', 'seen']

    trials = []
    for miniblocki in range(1, nMiniblocks + 1):
        vis = visOrder[(miniblocki - 1) % 2]

        # all trials of this miniblock: for every kind, each duplet equally often
        block = []
        for trialType in counts:
            if trialType == 'randomDeviant':
                # random deviants belong to no duplet: T1 and T2 are chosen by add_deviant_positions
                for i in range(counts[trialType]):
                    block.append({'trialType': trialType, 'T1duplet': 0, 'T2location': -1})
                continue
            for d in balanced_list(range(1, nDuplets + 1), counts[trialType]):
                if trialType == 'valid':
                    T2location = d       # T2 of the same duplet
                elif trialType == 'omission':
                    T2location = 0       # no T2
                else:
                    T2location = -1      # deviant: position chosen by add_deviant_positions
                block.append({'trialType': trialType, 'T1duplet': d, 'T2location': T2location})

        # random order
        random.shuffle(block)

        for triali in range(len(block)):
            block[triali]['Miniblock_no'] = miniblocki
            block[triali]['Trial_no'] = triali + 1
            block[triali]['visibility'] = vis
            trials.append(block[triali])
    return trials
