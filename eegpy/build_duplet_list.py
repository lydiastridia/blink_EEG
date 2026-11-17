"""Purpose: finds all combinations of duplets that pass the rules (as the original generator does).
Each combination is a list of 16 numbers: T1, T2 of the four seen duplets, then T1, T2 of the
four unseen duplets. Together a combination uses each of the 16 positions once.
This takes a few seconds; write_duplet_list saves the result.

Input:  P      settings (params.py)
Output: rows   list of combinations
"""
import itertools

from valid_sets import valid_sets


def build_duplet_list(P):
    n = P['nPositions']
    everything = set(range(1, n + 1))
    setsOf = {}                                   # eight positions -> all valid sets of four duplets
    for eight in itertools.combinations(range(1, n + 1), n // 2):
        if sum(1 for p in eight if p <= n // 2) != n // 4:
            continue                              # both side rules need 4 right and 4 left positions
        found = valid_sets(list(eight), P)
        if found:
            setsOf[frozenset(eight)] = found

    rows = []
    for eight in sorted(setsOf, key=sorted):
        others = frozenset(everything - eight)    # the unseen set gets the other eight positions
        if others in setsOf:
            for seenSet in setsOf[eight]:
                for unseenSet in setsOf[others]:
                    rows.append([p for d in seenSet for p in d] + [p for d in unseenSet for p in d])
    return rows
