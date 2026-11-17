"""Purpose: prints an overview of the trial list and checks that in every miniblock every kind
follows every kind equally often.

Input:  trials   trial list (add_targets)
        kinds    list of kinds
Output: ok       True if all checks passed
"""
from compute_transitions import compute_transitions


def check_learning_trials(trials, kinds):
    nKinds = len(kinds)
    typeNames = ['valid', 'omission', 'deviant']
    nMiniblocks = max(t['Miniblock_no'] for t in trials)
    ok = True
    print('')
    print('%d trials in %d miniblocks. The first miniblock is %s.' % (len(trials), nMiniblocks,
                                                                     trials[0]['visibility']))
    print('')
    print('Trials per trial type:')
    print('%-18s %8s %8s' % ('', 'seen', 'unseen'))
    for name in typeNames:
        nSeen = sum(1 for t in trials if t['visibility'] == 'seen' and t['trialType'] == name)
        nUnseen = sum(1 for t in trials if t['visibility'] == 'unseen' and t['trialType'] == name)
        print('%-18s %8d %8d' % (name, nSeen, nUnseen))
    print('%-18s %8d %8d' % ('total', sum(1 for t in trials if t['visibility'] == 'seen'),
                             sum(1 for t in trials if t['visibility'] == 'unseen')))

    for m in range(1, nMiniblocks + 1):
        order = [t['kind'] for t in trials if t['Miniblock_no'] == m]
        transMat = compute_transitions(order, nKinds)
        if len(set(v for row in transMat for v in row)) != 1:
            ok = False
            print('WARNING: transition probabilities are not uniform in miniblock %d!' % m)
    if ok:
        print('OK: in every miniblock, every entry of the list follows every entry equally often.')
    print('')
    return ok
