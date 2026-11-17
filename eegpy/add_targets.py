"""Purpose: decides for every trial which targets are shown. T1 is shown on every trial.
It adds:  T1duplet    (1-4) the duplet whose T1 is shown
          T2location  (1-4) the duplet whose T2 position is used, 0 = T2 is missing
          trialType   'valid', 'omission' or 'deviant'

Input:  trials   trial list (make_learning_trials)
        P        settings (params.py)
Output: trials   the same list with the new fields
"""
import random

from balanced_list import balanced_list


def add_targets(trials, P):
    nDuplets = P['nDuplets']
    for vis in ['seen', 'unseen']:
        def index_of(kindName):
            return [i for i, t in enumerate(trials) if t['visibility'] == vis and t['kindName'] == kindName]

        # duplets: T1 of the duplet, T2 at the position of the same duplet
        for d in range(1, nDuplets + 1):
            for i in index_of('duplet%d' % d):
                trials[i].update(T1duplet=d, T2location=d, trialType='valid')

        # omissions: T1 of one of the duplets (each duplet equally often), T2 is missing
        index = index_of('omission')
        sources = balanced_list(range(1, nDuplets + 1), len(index))
        for i, d in zip(index, sources):
            trials[i].update(T1duplet=d, T2location=0, trialType='omission')

        # deviants (test phase only): T1 of one duplet, T2 at the position of ANOTHER duplet
        index = index_of('deviant')
        sources = balanced_list(range(1, nDuplets + 1), len(index))
        for i, d in zip(index, sources):
            others = [k for k in range(1, nDuplets + 1) if k != d]
            trials[i].update(T1duplet=d, T2location=random.choice(others), trialType='deviant')
    return trials
