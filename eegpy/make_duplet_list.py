"""Purpose: makes duplets/duplet_list.csv: all combinations of duplets that pass the rules in params.py.

Run this once after changing a rule for the duplets (P['sideRule'], P['t2AwayFromMidline'],
P['t2NotNeighbours'], or the checks in check_set.py). The tasks pick one row of the list at random
for every new participant.
"""
from add_paths import add_paths

add_paths()   # makes the functions in the subfolders available

from rules_label import rules_label
from write_duplet_list import write_duplet_list
from params import get_params

if __name__ == '__main__':
    P = get_params()
    print('Making the list (takes a few seconds) ...')
    nRows = write_duplet_list(P)
    print('duplet_list.csv has been saved with %d combinations.' % nRows)
    print('Rules: ' + rules_label(P))
