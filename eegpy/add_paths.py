"""Purpose: adds the subfolders of eegpy to Python's search path, so that the functions in them can
be imported by their name, wherever they are (like addpath in MATLAB). Every start file
(run_calibration.py, run_learning.py, run_test.py, run_control_learning.py, run_control_test.py,
make_duplet_list.py) calls this first.
If you add a new subfolder, add its name to the list below.
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
