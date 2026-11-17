"""Purpose: checks the rules for one set of four duplets. The first four are the rules of the
original sequence generator; the side rule and the midline rule are additions (see params.py).

Input:  duplets   [(T1, T2), (T1, T2), (T1, T2), (T1, T2)]
        P         settings (params.py)
Output: True if all rules hold, otherwise False
"""
from jump_size import jump_size


def check_set(duplets, P):
    n = P['nPositions']
    jumps = [jump_size(t1, t2, n) for (t1, t2) in duplets]

    # two clockwise and two counter-clockwise duplets
    if sum(1 for j in jumps if j < 0) != 2:
        return False
    # four different jump sizes
    if len(set(abs(j) for j in jumps)) != 4:
        return False
    # clockwise and counter-clockwise jumps add up to zero
    if sum(jumps) != 0:
        return False
    # all four quadrants (1-4, 5-8, 9-12, 13-16) are used
    positions = [p for d in duplets for p in d]
    if len(set((p - 1) // (n // 4) for p in positions)) < 4:
        return False

    # sides: positions 1-8 are on the right, 9-16 on the left
    sides = [('R' if t1 <= n // 2 else 'L', 'R' if t2 <= n // 2 else 'L') for (t1, t2) in duplets]
    if P['sideRule'] == 'crossed':
        # one duplet of each kind: right->right, left->left, right->left, left->right
        if len(set(sides)) != 4:
            return False
    elif P['sideRule'] == 'rightToLeft':
        # every T1 on the right, every T2 on the left (as in the original sequence file)
        if any(s != ('R', 'L') for s in sides):
            return False
    else:
        raise ValueError("P['sideRule'] must be 'crossed' or 'rightToLeft'")

    # no T2 directly next to the vertical midline (not possible with 'rightToLeft')
    if P['t2AwayFromMidline'] and P['sideRule'] != 'rightToLeft':
        midline = [1, n // 2, n // 2 + 1, n]
        if any(t2 in midline for (t1, t2) in duplets):
            return False
    return True
