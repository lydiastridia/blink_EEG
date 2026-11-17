"""Purpose: waits until one of the allowed keys is pressed. Other keys are ignored.
ESCAPE stops the task (raises AbortExperiment).

Input:  keyList   allowed keys, e.g. ['space'] or ['1', '2', '3', '4']
Output: key       the key that was pressed
        RT        response time in seconds
"""
from psychopy import core, event

from abort_experiment import AbortExperiment


def get_key(keyList):
    event.clearEvents()
    clock = core.Clock()
    keys = event.waitKeys(keyList=list(keyList) + ['escape'], timeStamped=clock)
    key, RT = keys[0]
    if key == 'escape':
        raise AbortExperiment()
    return key, RT
