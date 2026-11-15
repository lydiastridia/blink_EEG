"""Makes duplet_list.csv: all combinations of duplets that pass the rules in params.py.

Run this once after changing a rule for the duplets (P['sideRule'], P['t2AwayFromMidline'],
or the checks in check_set in trials.py). The tasks pick one row of the list at random
for every new participant.
"""
import trials as T
from params import get_params

if __name__ == '__main__':
    P = get_params()
    print('Making the list (takes a few seconds) ...')
    nRows = T.write_duplet_list(P)
    print('duplet_list.csv has been saved with %d combinations.' % nRows)
    print('Rules: ' + T.rules_label(P))
