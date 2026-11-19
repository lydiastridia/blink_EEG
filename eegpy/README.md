# eegpy: PsychoPy version

The same three tasks as the MATLAB version, written for PsychoPy (free, no licence needed).

One function per file; the file has the same name as the function. The start files are at the top;
the functions are in subfolders. `add_paths.py` makes the subfolders available to the start files
(like `addpath` in MATLAB).

```
eegpy/
    run_calibration.py      start: calibration
    run_learning.py         start: learning phase
    run_test.py             start: test phase
    make_duplet_list.py     start: makes duplets/duplet_list.csv (after changing a duplet rule)
    params.py               all settings
    add_paths.py            adds the subfolders to Python's search path
    general/                participant details, threshold file, saving, the ESCAPE error
    screen/                 window, stimuli, drawing, timing in frames, texts
    responses/              key presses: any key, ratings 1-4, letters
    calibration/            calibration trial list, one calibration trial, convergence graph
    duplets/                rules for the duplets, the list of all valid combinations, choosing the duplets of a participant, positions of every trial
    trial/                  one learning/test trial on the screen, and the four questions after it
    learning_phase/         trial list of the learning phase (serially balanced miniblocks) and its check
    test_phase/             trial list of the test phase, deviant positions, and its check
```

**general/**: `abort_experiment.py`, `ask_participant_info.py`, `load_threshold.py`, `save_data.py`

**screen/**: `open_screen.py`, `find_positions.py`, `prep_mask.py`, `prep_stimuli.py`, `draw_fixation.py`, `draw_target.py`, `draw_mask.py`, `set_mask_contrast.py`, `show_frames.py`, `show_fixation.py`, `text_msg.py`, `countdown.py`, `close_screen.py`

**responses/**: `get_key.py`, `get_rating.py`, `get_letter.py`

**calibration/**: `make_calib_trials.py`, `run_calib_trial.py`, `plot_convergence.py`

**duplets/**: `jump_size.py`, `check_set.py`, `valid_sets.py`, `build_duplet_list.py`, `rules_label.py`, `write_duplet_list.py`, `read_duplet_list.py`, `make_positions.py`, `add_positions.py`, `duplet_list.csv`

**trial/**: `run_learning_trial.py`, `run_questions.py`

**learning_phase/**: `make_trial_order.py`, `compute_transitions.py`, `make_learning_trials.py`, `balanced_list.py`, `add_targets.py`, `check_learning_trials.py`

**test_phase/**: `make_test_trials.py`, `longest_run.py`, `deviant_keep_clear.py`, `allowed_deviant_positions.py`, `allowed_random_T1_positions.py`, `add_deviant_positions.py`, `check_test_trials.py`

## How to run

1. In VS Code, with the Python 3.11 environment that has PsychoPy (or in the PsychoPy app, Coder view),
   open `run_calibration.py` and press Run. Fill in the dialog box.
2. Then `run_learning.py`, then `run_test.py`, with the same participant ID and session.

ESCAPE stops a task at any question screen; the data so far are saved.

## Settings to know

In `params.py`:

- `P['fullScreen'] = False` shows the task in a window (useful for a first try).
- `P['SCREEN_HEIGHT_PIX']` is the screen height in pixels as Psychtoolbox saw it (MacBook: 900).
  It keeps the stimuli the same size as in the MATLAB version.
- `P['nMiniblocksPerVis']`, `P['kinds']`: number of learning trials.
- `P['testTrialsPerKind']`, `P['testMiniblocks']`, `P['deviantAwayFrom']`: the test phase.
- `P['maskT2']`: whether T2 is followed by a mask.
- `P['sideRule']`, `P['t2AwayFromMidline']`, `P['t2NotNeighbours']`: rules for the duplets (then run `make_duplet_list.py`).

VS Code may show yellow lines under the imports of the start files if it does not know the subfolders.
The file `.vscode/settings.json` tells it where to look; the code runs either way.

## Data

Saved in the folder `Data` on the desktop (`~/Desktop/Data`), as `.json` (everything) and `.csv` (one row per trial).
The files are separate from those of the MATLAB version (`.mat`): a calibration done in MATLAB
cannot be used here, and the other way round.
