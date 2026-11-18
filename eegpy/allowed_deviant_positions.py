"""Purpose: the positions where T2 may appear on a deviant trial. Never allowed: the predicted T2
of this trial's duplet, the positions next to it, and the position where T1 was shown on this trial.
P['deviantAwayFrom'] decides whether the other three T2s of the set are kept clear as well:
    'predictedT2' : only the predicted T2 of this trial's duplet (and its neighbours) is excluded
    'allT2'       : all four predictive T2s of the set (and their neighbours) are excluded

Input:  thisSet      duplets of this visibility (pos['seen'] or pos['unseen'], from make_positions)
        duplet       the duplet whose T1 is shown (1-4)
        P            settings (params.py)
Output: allowed      list of allowed positions
"""


def allowed_deviant_positions(thisSet, duplet, P):
    nPositions = P['nPositions']
    T1 = thisSet['T1'][duplet - 1]
    predictedT2 = thisSet['T2'][duplet - 1]

    # which T2 positions have to be kept clear
    if P['deviantAwayFrom'] == 'allT2':
        keepClear = thisSet['T2']
    else:
        keepClear = [predictedT2]

    allowed = []
    for p in range(1, nPositions + 1):
        if p == T1:              # where T1 was shown on this trial
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
