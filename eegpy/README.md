# eegpy: PsychoPy version

The same three tasks as the MATLAB version, written for PsychoPy (free, no licence needed).

| File | What it is |
| --- | --- |
| `run_calibration.py` | Calibration (two staircases, threshold, convergence graph) |
| `run_learning.py` | Learning phase |
| `run_test.py` | Test phase (learning phase plus deviant trials) |
| `params.py` | All settings |
| `trials.py` | Trial lists and positions |
| `common.py` | Window, stimuli, key presses, the trial, the questions, saving |

## How to run

1. Install PsychoPy (standalone app) from psychopy.org.
2. Open PsychoPy and switch to the Coder view.
3. Open `run_calibration.py` and press the green Run button. Fill in the dialog box.
4. Then `run_learning.py`, then `run_test.py`, with the same participant ID and session.

ESCAPE stops a task at any question screen; the data so far are saved.

## Settings to know

In `params.py`:

- `P['fullScreen'] = False` shows the task in a window (useful for a first try).
- `P['SCREEN_HEIGHT_PIX']` is the screen height in pixels as Psychtoolbox saw it (MacBook: 900).
  It keeps the stimuli the same size as in the MATLAB version.
- `P['nMiniblocksPerVis']`, `P['testMiniblocksPerVis']`, `P['kinds']`, `P['testKinds']`: number of trials.
- `P['maskT2']`: whether T2 is followed by a mask.

## Data

Saved in the `Data` folder next to this folder, as `.json` (everything) and `.csv` (one row per trial).
The files are separate from those of the MATLAB version (`.mat`): a calibration done in MATLAB
cannot be used here, and the other way round.
