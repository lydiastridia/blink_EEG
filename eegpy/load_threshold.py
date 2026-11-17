"""Purpose: loads the threshold file that the calibration saved for this participant and session.

Input:  P      settings (params.py)
        info   participant details (ask_participant_info)
Output: threshold dictionary (threshold, contrastSeen, contrastUnseen, ...),
        or None if there is no threshold file
"""
import json
import os


def load_threshold(P, info):
    fileName = os.path.join(P['path']['calibration'], 'P%s_S%d_threshold.json' % (info['id'], info['session']))
    if not os.path.isfile(fileName):
        print('No threshold file found: %s' % fileName)
        print('Run the calibration first (run_calibration.py) with the same ID and session.')
        return None

    with open(fileName) as f:
        threshold = json.load(f)
    print('Threshold %.3f | seen miniblocks %.3f | unseen miniblocks %.3f'
          % (threshold['threshold'], threshold['contrastSeen'], threshold['contrastUnseen']))
    return threshold
