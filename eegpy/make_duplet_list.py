"""Purpose: makes duplets/duplet_list.csv: all combinations of duplets that pass the rules in params.py.

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
