"""Purpose: returns n values in random order, with every value used equally often. When n is not
a multiple of the number of values, the remaining ones are chosen at random, each at most once
(so no duplet always gets the extra trials).
Used to give every duplet the same number of omission and deviant trials.

Input:  values   e.g. [1, 2, 3, 4]
        n        number of values needed
Output: list of n values
"""
import random


def balanced_list(values, n):
    values = list(values)
    out = values * (n // len(values))                       # every value equally often
    out = out + random.sample(values, n % len(values))     # the rest: different values, at random
    random.shuffle(out)
    return out
