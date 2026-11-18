"""Purpose: builds the list of all valid combinations of duplets and saves it as duplets/duplet_list.csv
(the file name is in P['path']['dupletList']).

Input:  P       settings (params.py)
Output: nRows   number of combinations in the list
"""
from build_duplet_list import build_duplet_list
from rules_label import rules_label


def write_duplet_list(P):
    rows = build_duplet_list(P)
    with open(P['path']['dupletList'], 'w') as f:
        f.write(rules_label(P) + '\n')
        f.write('seenT1_1,seenT2_1,seenT1_2,seenT2_2,seenT1_3,seenT2_3,seenT1_4,seenT2_4,'
                'unseenT1_1,unseenT2_1,unseenT1_2,unseenT2_2,unseenT1_3,unseenT2_3,unseenT1_4,unseenT2_4\n')
        for row in rows:
            f.write(','.join(str(p) for p in row) + '\n')
    return len(rows)
