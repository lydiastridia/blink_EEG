"""Purpose: the duplets of one participant: four for seen and four for unseen miniblocks.
One combination is picked at random from duplet_list.csv, so every combination has the same
chance (as in the original code).

Input:  P            settings (params.py)
        subjectNum   participant number (stored with the positions)
Output: pos          pos['seen'] and pos['unseen'], each with T1, T2 and jumps of duplets 1-4
"""
import random

from jump_size import jump_size
from read_duplet_list import read_duplet_list


def make_positions(P, subjectNum):
    row = random.choice(read_duplet_list(P))
    pos = {'subjectNum': subjectNum}
    for vis, numbers in (('seen', row[:8]), ('unseen', row[8:])):
        duplets = [(numbers[i], numbers[i + 1]) for i in range(0, 8, 2)]
        random.shuffle(duplets)                   # which one is called duplet 1, 2, 3, 4
        pos[vis] = {'T1': [d[0] for d in duplets], 'T2': [d[1] for d in duplets],
                    'jumps': [jump_size(d[0], d[1], P['nPositions']) for d in duplets]}
    return pos
