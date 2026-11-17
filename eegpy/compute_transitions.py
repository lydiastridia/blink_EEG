"""Purpose: counts how often each kind follows each kind in an order.
If all numbers are equal, the transition probabilities are uniform.

Input:  order      list of kinds (make_trial_order)
        nKinds     number of kinds
Output: transMat   transMat[a][b] = how often kind a+1 is followed by kind b+1
"""

def compute_transitions(order, nKinds):
    transMat = [[0] * nKinds for _ in range(nKinds)]
    for i in range(1, len(order)):
        transMat[order[i - 1] - 1][order[i] - 1] += 1
    return transMat
