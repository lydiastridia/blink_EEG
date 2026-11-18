"""Purpose: returns n values taken in turn from 'values' (1 2 3 4 1 2 ...), in random order.
Used to give every duplet the same number of omission and deviant trials.

Input:  values   e.g. [1, 2, 3, 4]
        n        number of values needed
Output: list of n values
"""
import math
import random


def balanced_list(values, n):
    out = (list(values) * int(math.ceil(n / float(len(values)))))[:n]
    random.shuffle(out)
    return out
