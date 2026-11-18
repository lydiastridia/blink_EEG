"""Purpose: makes the trial list of the learning phase (also used for the test phase).
Miniblocks alternate between seen and unseen; odd participant numbers start with seen,
even numbers with unseen. Every miniblock has its own serially balanced order.

Input:  kinds        list of kinds (P['kinds'] or P['testKinds'])
        nPerVis      number of miniblocks per visibility
        subjectNum   participant number used for the counterbalancing (info['idNumber'])
Output: trials       list of trials with Miniblock_no, Trial_no, visibility, kind, kindName
"""
import math
import random

from make_trial_order import make_trial_order


def make_learning_trials(kinds, nPerVis, subjectNum):
    nKinds = len(kinds)
    if subjectNum % 2 == 1:
        visOrder = ['seen', 'unseen']
    else:
        visOrder = ['unseen', 'seen']

    # which kind starts each miniblock: balanced over the miniblocks of a visibility
    firstKinds = {}
    for vis in visOrder:
        first = (list(range(1, nKinds + 1)) * int(math.ceil(nPerVis / float(nKinds))))[:nPerVis]
        random.shuffle(first)
        firstKinds[vis] = first

    trials = []
    for miniblocki in range(1, 2 * nPerVis + 1):
        vis = visOrder[(miniblocki - 1) % 2]
        miniblockOfVis = (miniblocki - 1) // 2
        order = make_trial_order(nKinds, firstKinds[vis][miniblockOfVis])
        for triali, kind in enumerate(order, start=1):
            trials.append({'Miniblock_no': miniblocki, 'Trial_no': triali, 'visibility': vis,
                           'kind': kind, 'kindName': kinds[kind - 1]})
    return trials
