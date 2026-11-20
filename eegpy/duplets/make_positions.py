"""Purpose: the duplets of one participant: four for seen and four for unseen miniblocks.
All participants get the same two sets (P['dupletSetA'] and P['dupletSetB'] in params.py).
Which set is seen depends on the participant number: numbers 1, 2 (5, 6, 9, 10, ...) see set A,
numbers 3, 4 (7, 8, 11, 12, ...) see set B. Together with the first visibility (odd numbers start
with seen, make_learning_trials) this gives four groups.
The sets are checked against the duplet rules (check_set) and must use all positions between them.

Input:  P            settings (params.py)
        subjectNum   participant number (info['idNumber'])
Output: pos          pos['seen'] and pos['unseen'], each with T1, T2 and jumps of duplets 1-4,
                     and pos['seenSet'] / pos['unseenSet'] ('A' or 'B')
"""
from check_set import check_set
from jump_size import jump_size


def make_positions(P, subjectNum):
    sets = {'A': [tuple(d) for d in P['dupletSetA']], 'B': [tuple(d) for d in P['dupletSetB']]}

    # check the two sets
    for name in sets:
        if not check_set(sets[name], P):
            raise ValueError('Duplet set %s in params.py does not meet the duplet rules.' % name)
    allPositions = [p for name in sets for d in sets[name] for p in d]
    if sorted(allPositions) != list(range(1, P['nPositions'] + 1)):
        raise ValueError('Duplet sets A and B in params.py must use every position exactly once.')

    # which set is seen
    if (subjectNum - 1) % 4 < 2:
        seenSet, unseenSet = 'A', 'B'
    else:
        seenSet, unseenSet = 'B', 'A'

    pos = {'subjectNum': subjectNum, 'seenSet': seenSet, 'unseenSet': unseenSet}
    for vis, name in (('seen', seenSet), ('unseen', unseenSet)):
        duplets = sets[name]
        pos[vis] = {'T1': [d[0] for d in duplets], 'T2': [d[1] for d in duplets],
                    'jumps': [jump_size(d[0], d[1], P['nPositions']) for d in duplets]}
    return pos
