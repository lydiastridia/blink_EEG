"""Purpose: prints an overview of a control trial list and checks that T1 does not predict T2:
trials per type, how often each position is T1 and T2, and how often the same T1-T2 pair occurs.

Input:  trials   control trial list (after add_random_positions)
        P        settings (params.py)
        name     name of the phase, for the printout
Output: ok       True if no T2 is at the position of its T1
"""


def check_control_trials(trials, P, name):
    positions = range(1, P['nPositions'] + 1)
    nMiniblocks = max(t['Miniblock_no'] for t in trials)
    print('')
    print('%s: %d trials in %d miniblocks. The first miniblock is %s.'
          % (name, len(trials), nMiniblocks, trials[0]['visibility']))

    ok = True
    for vis in ['seen', 'unseen']:
        visTrials = [t for t in trials if t['visibility'] == vis]
        withT2 = [t for t in visTrials if t['trialType'] == 'random']
        nOmission = len(visTrials) - len(withT2)
        print('')
        print('%s: %d trials with a random T2, %d omissions (%d%%)'
              % (vis, len(withT2), nOmission, round(100.0 * nOmission / len(visTrials))))

        T1counts = [sum(1 for t in visTrials if t['T1position'] == p) for p in positions]
        T2counts = [sum(1 for t in withT2 if t['T2position'] == p) for p in positions]
        print('   every position is T1 %d to %d times, and T2 %d to %d times'
              % (min(T1counts), max(T1counts), min(T2counts), max(T2counts)))

        pairs = {}
        for t in withT2:
            pair = (t['T1position'], t['T2position'])
            pairs[pair] = pairs.get(pair, 0) + 1
        print('   %d different T1-T2 pairs; the most frequent pair occurs %d times'
              % (len(pairs), max(pairs.values()) if pairs else 0))

        if any(t['T1position'] == t['T2position'] for t in withT2):
            print('WARNING: a T2 is at the position of its T1!')
            ok = False
    if ok:
        print('')
        print('OK: no T2 is at the position of its T1.')
    print('')
    return ok
