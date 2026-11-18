"""Purpose: reads duplet_list.csv. If the file is missing, or was made with other rules than those
in params.py, it is made again first.

Input:  P      settings (params.py)
Output: rows   list of combinations (16 numbers each)
"""
import os

from rules_label import rules_label
from write_duplet_list import write_duplet_list


def read_duplet_list(P):
    fileName = P['path']['dupletList']
    upToDate = False
    if os.path.isfile(fileName):
        with open(fileName) as f:
            upToDate = (f.readline().strip() == rules_label(P))
    if not upToDate:
        print('Making the list of duplet combinations for the current rules (takes a few seconds) ...')
        nRows = write_duplet_list(P)
        print('duplet_list.csv now has %d combinations.' % nRows)
    with open(fileName) as f:
        lines = f.read().splitlines()[2:]         # skip the rules line and the column names
    return [[int(p) for p in line.split(',')] for line in lines]
