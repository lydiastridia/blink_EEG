"""Purpose: which predictive T2 positions a deviant T2 has to keep clear of.
    deviant         : P['deviantAwayFrom'] = 'allT2'       -> all four predictive T2s of the set
                      P['deviantAwayFrom'] = 'predictedT2' -> only the predicted T2 of its duplet
    randomDeviant   : always all four predictive T2s of the set (there is no predicted T2)

Input:  trial       one deviant or random deviant trial
        pos         positions of the participant (make_positions)
        P           settings (params.py)
Output: keepClear   list of T2 positions
"""


def deviant_keep_clear(trial, pos, P):
    thisSet = pos[trial['visibility']]
    if trial['trialType'] == 'deviant' and P['deviantAwayFrom'] == 'predictedT2':
        keepClear = [trial['predictedT2position']]
    else:
        keepClear = list(thisSet['T2'])
    return keepClear
