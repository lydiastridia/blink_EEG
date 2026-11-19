"""Purpose: returns n positions in random order, with every position used equally often
(when n is not a multiple of the number of positions, the remaining ones are chosen at random,
each at most once).

Input:  n            number of positions needed
        nPositions   number of positions (P['nPositions'], 16)
Output: list of n positions (1 to nPositions)
"""
import random


def balanced_positions(n, nPositions):
    allPositions = list(range(1, nPositions + 1))
    out = allPositions * (n // nPositions)                       # every position equally often
    out = out + random.sample(allPositions, n % nPositions)     # the rest: different positions, at random
    random.shuffle(out)
    return out
