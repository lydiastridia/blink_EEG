"""Purpose: the positions where T2 may appear on a deviant or random deviant trial:
not where T1 was shown on this trial, not on one of the positions to keep clear,
and not next to one of them.

Input:  T1position   where T1 is shown on this trial
        keepClear    the predictive T2 positions to keep clear (deviant_keep_clear)
        P            settings (params.py)
Output: allowed      list of allowed positions
"""


def allowed_deviant_positions(T1position, keepClear, P):
    nPositions = P['nPositions']
    allowed = []
    for p in range(1, nPositions + 1):
        if p == T1position:      # where T1 was shown on this trial
            continue
        if p in keepClear:       # a predictive T2
            continue
        neighbour = False
        for t2 in keepClear:
            distance = abs(p - t2)
            if distance == 1 or distance == nPositions - 1:   # nPositions - 1: 16 and 1 are neighbours
                neighbour = True
        if neighbour:            # next to a predictive T2
            continue
        allowed.append(p)
    return allowed
