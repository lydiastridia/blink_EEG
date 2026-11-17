"""Purpose: finds all ways to make four duplets out of eight positions that pass check_set.

Input:  eight   eight positions
        P       settings (params.py)
Output: found   list of sets; each set is [(T1, T2), (T1, T2), (T1, T2), (T1, T2)]
"""
import itertools

from check_set import check_set


def valid_sets(eight, P):
    found = []
    for t1s in itertools.combinations(eight, 4):            # which four positions are T1 ...
        rest = [p for p in eight if p not in t1s]
        for t2s in itertools.permutations(rest):             # ... and which T2 goes with which T1
            duplets = list(zip(t1s, t2s))
            if check_set(duplets, P):
                found.append(duplets)
    return found
