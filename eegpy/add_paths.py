"""Purpose: adds the subfolders of eegpy to Python's search path,
every newly added subfolder will be written down in here
"""
import os
import sys

folders = ['calibration', 'control', 'duplets', 'general', 'learning_phase', 'responses', 'screen', 'test_phase', 'trial']


def add_paths():
    thisFolder = os.path.dirname(os.path.abspath(__file__))   # the eegpy folder
    for folder in folders:
        path = os.path.join(thisFolder, folder)
        if path not in sys.path:
            sys.path.insert(0, path)
