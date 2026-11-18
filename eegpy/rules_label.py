"""Purpose: one line that says with which rules a list of duplets was made.
It is the first line of duplet_list.csv, so that an out-of-date list can be recognised.

Input:  P   settings (params.py)
Output: the line, e.g. '# sideRule=crossed t2AwayFromMidline=True t2NotNeighbours=True'
"""

def rules_label(P):
    return '# sideRule=%s t2AwayFromMidline=%s t2NotNeighbours=%s' % (P['sideRule'], P['t2AwayFromMidline'],
                                                                   P['t2NotNeighbours'])
