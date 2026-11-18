"""Purpose: prints an overview of the test trial list: trials per type, trials per duplet,
the longest run of omissions/deviants, and checks the positions of the deviants.

Input:  trials   trial list of the test phase (after add_deviant_positions)
        pos      duplets of the participant (make_positions)
        P        settings (params.py)
Output: ok       True if all checks passed
"""
from allowed_deviant_positions import allowed_deviant_positions
from longest_run import longest_run


def check_test_trials(trials, pos, P):
    typeNames = ['valid', 'omission', 'deviant']
    nMiniblocks = max(t['Miniblock_no'] for t in trials)
    ok = True

    print('')
    print('Test phase: %d trials in %d miniblocks. The first miniblock is %s.'
          % (len(trials), nMiniblocks, trials[0]['visibility']))

    # trials per type
    print('')
    print('Trials per trial type:')
    print('%-12s %8s %8s' % ('', 'seen', 'unseen'))
    for name in typeNames:
        nSeen = sum(1 for t in trials if t['visibility'] == 'seen' and t['trialType'] == name)
        nUnseen = sum(1 for t in trials if t['visibility'] == 'unseen' and t['trialType'] == name)
        print('%-12s %8d %8d' % (name, nSeen, nUnseen))

    # trials per duplet
    print('')
    print('Trials per duplet (seen and unseen together):')
    print('%-12s %8s %8s %8s %8s' % ('', 'duplet 1', 'duplet 2', 'duplet 3', 'duplet 4'))
    for name in typeNames:
        numbers = [sum(1 for t in trials if t['trialType'] == name and t['T1duplet'] == d)
                   for d in range(1, P['nDuplets'] + 1)]
        print('%-12s %8d %8d %8d %8d' % tuple([name] + numbers))

    # longest run of omissions/deviants in every miniblock (for information)
    print('')
    for m in range(1, nMiniblocks + 1):
        block = [t for t in trials if t['Miniblock_no'] == m]
        print('Miniblock %d: at most %d omissions/deviants in a row.' % (m, longest_run(block)))

    # deviants: T2 at an allowed position?
    for t in trials:
        if t['trialType'] == 'deviant':
            allowed = allowed_deviant_positions(pos[t['visibility']], t['T1duplet'], P)
            if t['T2position'] not in allowed:
                ok = False
                print('WARNING: deviant in miniblock %d, trial %d is at a position that is not allowed!'
                      % (t['Miniblock_no'], t['Trial_no']))
    if ok:
        if P['deviantAwayFrom'] == 'allT2':
            print('OK: every deviant T2 is away from all predictive T2s (not on one, not next to one).')
        else:
            print('OK: every deviant T2 is away from its predicted T2 (not on it, not next to it).')
    print('')
    return ok
