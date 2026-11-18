"""Purpose: makes the order of one miniblock, in which every kind follows every kind exactly once
(serially balanced, as in the original code: n kinds -> n x n + 1 trials).
Method: build the order step by step; if it gets stuck, start again.

Input:  nKinds      number of kinds (e.g. 5)
        firstKind   the kind that starts (and ends) the miniblock
Output: order       list of kinds (1 to nKinds)
"""
import random


def make_trial_order(nKinds, firstKind):
    nTransitions = nKinds * nKinds
    while True:
        used = [[0] * (nKinds + 1) for _ in range(nKinds + 1)]
        order = [firstKind]
        stuck = False
        for _ in range(nTransitions):
            current = order[-1]
            possible = [k for k in range(1, nKinds + 1) if used[current][k] == 0]
            if not possible:
                stuck = True
                break
            nxt = random.choice(possible)
            used[current][nxt] = 1
            order.append(nxt)
        if not stuck:
            return order
