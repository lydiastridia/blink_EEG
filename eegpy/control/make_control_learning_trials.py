"""Purpose: makes the trial list of the control learning phase. It has the same structure as the
learning phase: the same miniblocks (26 trials, serially balanced), the same seen/unseen order and
the omissions at the same kind of places. The only difference: the four duplets are replaced by
trials with a random T2 (trialType 'random'), so there is nothing to learn.
The positions are chosen afterwards by add_random_positions.

Input:  P            settings (params.py)
        subjectNum   participant number used for the counterbalancing (info['idNumber'])
Output: trials       list of trials with Miniblock_no, Trial_no, visibility and trialType
                     ('random' = T1 and a random T2, 'omission' = T1 only)
"""
from make_learning_trials import make_learning_trials


def make_control_learning_trials(P, subjectNum):
    trials = make_learning_trials(P['kinds'], P['nMiniblocksPerVis'], subjectNum)
    for trial in trials:
        if trial['kindName'] == 'omission':
            trial['trialType'] = 'omission'
        else:
            trial['trialType'] = 'random'
        del trial['kind'], trial['kindName']   # the duplet labels have no meaning here
    return trials
