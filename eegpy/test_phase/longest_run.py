"""Purpose: finds the longest run of non-predictive trials (omissions and deviants) in a row.

Input:  block   list of trials, each with a 'trialType'
Output: longest number of non-predictive trials in a row
"""


def longest_run(block):
    longest = 0
    current = 0
    for trial in block:
        if trial['trialType'] == 'valid':
            current = 0
        else:
            current = current + 1
            if current > longest:
                longest = current
    return longest
