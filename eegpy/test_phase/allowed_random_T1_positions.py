"""Purpose: the positions where T1 may appear on a random deviant trial: positions that are never
a T1, in either set. These are the T2 positions of both sets (all 16 positions are used, each is
a T1 or a T2 in one of the two sets), so the T1 of a random deviant cannot call up a learned pair.

Input:  pos       positions of the participant (make_positions)
Output: allowed   list of 8 positions
"""


def allowed_random_T1_positions(pos):
    allowed = sorted(pos['seen']['T2'] + pos['unseen']['T2'])
    return allowed
