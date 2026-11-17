"""Purpose: gives every trial its positions.
It adds:  T1position            where T1 is shown (1-16)
          T2position            where T2 is shown (1-16), 0 = T2 is missing
          predictedT2position   where T2 belongs after this T1

Input:  trials   trial list (add_targets)
        pos      positions of the participant (make_positions)
Output: trials   the same list with the new fields
"""

def add_positions(trials, pos):
    for t in trials:
        thisSet = pos[t['visibility']]
        t['T1position'] = thisSet['T1'][t['T1duplet'] - 1]
        t['predictedT2position'] = thisSet['T2'][t['T1duplet'] - 1]
        if t['T2location'] > 0:
            t['T2position'] = thisSet['T2'][t['T2location'] - 1]
        else:
            t['T2position'] = 0
    return trials
