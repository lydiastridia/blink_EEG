"""Purpose: prints an overview of the test trial list: trials per type, trials per duplet,
the longest run of omissions/deviants, and checks the positions of the deviants and random deviants.

Input:  trials   trial list of the test phase (after add_deviant_positions)
        pos      duplets of the participant (make_positions)
        P        settings (params.py)
Output: ok       True if all checks passed
"""
from allowed_deviant_positions import allowed_deviant_positions
from allowed_random_T1_positions import allowed_random_T1_positions
from deviant_keep_clear import deviant_keep_clear
from longest_run import longest_run


def check_test_trials(trials, pos, P):
    typeNames = ['valid', 'omission', 'deviant', 'randomDeviant']
    nMiniblocks = max(t['Miniblock_no'] for t in trials)
    ok = True

    print('')
    print('Test phase: %d trials in %d miniblocks. The first miniblock is %s.'
          % (len(trials), nMiniblocks, trials[0]['visibility']))

    # trials per type
    print('')
    print('Trials per trial type:')
    print('%-14s %8s %8s' % ('', 'seen', 'unseen'))
    for name in typeNames:
        nSeen = sum(1 for t in trials if t['visibility'] == 'seen' and t['trialType'] == name)
        nUnseen = sum(1 for t in trials if t['visibility'] == 'unseen' and t['trialType'] == name)
        print('%-14s %8d %8d' % (name, nSeen, nUnseen))

    # trials per duplet
    print('')
    print('Trials per duplet (seen and unseen together; random deviants belong to no duplet):')
    print('%-14s %8s %8s %8s %8s' % ('', 'duplet 1', 'duplet 2', 'duplet 3', 'duplet 4'))
    for name in ['valid', 'omission', 'deviant']:
        numbers = [sum(1 for t in trials if t['trialType'] == name and t['T1duplet'] == d)
                   for d in range(1, P['nDuplets'] + 1)]
        print('%-14s %8d %8d %8d %8d' % tuple([name] + numbers))

    # longest run of omissions/deviants in every miniblock (for information)
    print('')
    for m in range(1, nMiniblocks + 1):
        block = [t for t in trials if t['Miniblock_no'] == m]
        print('Miniblock %d: at most %d omissions/deviants in a row.' % (m, longest_run(block)))

    # deviants and random deviants: T1 and T2 at allowed positions?
    for t in trials:
        if t['trialType'] == 'deviant' or t['trialType'] == 'randomDeviant':
            allowed = allowed_deviant_positions(t['T1position'], deviant_keep_clear(t, pos, P), P)
            if t['T2position'] not in allowed:
                ok = False
                print('WARNING: the T2 of trial %d in miniblock %d is at a position that is not allowed!'
                      % (t['Trial_no'], t['Miniblock_no']))
        if t['trialType'] == 'randomDeviant' and t['T1position'] not in allowed_random_T1_positions(pos):
            ok = False
            print('WARNING: the T1 of random deviant %d in miniblock %d is at a T1 position!'
                  % (t['Trial_no'], t['Miniblock_no']))
    if ok:
        print('OK: every deviant and random deviant is at allowed positions.')
    print('')
    return ok
