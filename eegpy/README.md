# eegpy: PsychoPy version

The same three tasks as the MATLAB version, written for PsychoPy and updated,
plus two control tasks: the learning and test phase without anything to learn.

Usually one function per file; the file has the same name as the function. 
The start files are at the top, the functions are in subfolders. 
`add_paths.py` makes the subfolders available to the start files.

```
eegpy/
    run_calibration.py      start: calibration
    run_learning.py         start: learning phase
    run_test.py             start: test phase
    run_control_learning.py start: control learning phase (as the learning phase, random T1-T2 pairs)
    run_control_test.py     start: control test phase (as the test phase, random T1-T2 pairs)
    make_duplet_list.py     start: makes duplets/duplet_list.csv (after changing a duplet rule)
    params.py               all settings
    add_paths.py            adds the subfolders to python
    general/                participant details, threshold file, saving + the ESCAPE error
    screen/                 window, stimuli, drawing, timing in frames (to be changed probably), texts
    responses/              key presses: any key, ratings 1-4, letters; also added the option to indicate the location with the mouse -> still to decide on how much time the cursor needs to be above to decide between hovering and selection
    calibration/            calibration trial list, one calibration trial, convergence graph
    duplets/                rules for the duplets, the list of all valid combinations, choosing the duplets of a participant, positions of every trial
    trial/                  one learning/test trial on the screen, and the four questions after it
    learning_phase/         trial list of the learning phase (serially balanced miniblocks) and its check
    test_phase/             trial list of the test phase, deviant positions, and its check
    control/                trial lists of the two control tasks, random balanced positions, and their check
```

**general/**: `abort_experiment.py`, `ask_participant_info.py`, `load_threshold.py`, `save_data.py`

**screen/**: `open_screen.py`, `find_positions.py`, `prep_mask.py`, `prep_stimuli.py`, `draw_fixation.py`, `draw_target.py`, `draw_mask.py`, `set_mask_contrast.py`, `show_frames.py`, `show_fixation.py`, `text_msg.py`, `countdown.py`, `close_screen.py`

**responses/**: `get_key.py`, `get_rating.py`, `get_letter.py`, `get_location_mouse.py`

**calibration/**: `make_calib_trials.py`, `run_example_trial.py`, `run_calib_trial.py`, `plot_convergence.py`

**duplets/**: `jump_size.py`, `check_set.py`, `valid_sets.py`, `build_duplet_list.py`, `rules_label.py`, `write_duplet_list.py`, `read_duplet_list.py`, `make_positions.py`, `add_positions.py`, `duplet_list.csv`

**trial/**: `run_learning_trial.py`, `run_questions.py`

**learning_phase/**: `make_trial_order.py`, `compute_transitions.py`, `make_learning_trials.py`, `balanced_list.py`, `add_targets.py`, `check_learning_trials.py`

**test_phase/**: `make_test_trials.py`, `longest_run.py`, `deviant_keep_clear.py`, `allowed_deviant_positions.py`, `allowed_random_T1_positions.py`, `add_deviant_positions.py`, `check_test_trials.py`

**control/**: `make_control_learning_trials.py`, `make_control_test_trials.py`, `balanced_positions.py`, `add_random_positions.py`, `check_control_trials.py`

## How to run

1. `run_calibration.py` in python 3.11 with psychopy
2. Then `run_learning.py`, then `run_test.py`, with the same participant ID and session.
3. The control tasks: `run_control_learning.py`, then `run_control_test.py`, also with the same
   ID and session (we still need to discuss this tho)

ESCAPE stops a task at any question screen; the data so far are saved.

## Settings to know

In `params.py`:

- `P['fullScreen'] = False` shows the task in a window (useful for a first try).
- `P['SCREEN_HEIGHT_PIX']` is the screen height in pixels as Psychtoolbox saw it (MacBook: 900).
  It keeps the stimuli the same size as in the MATLAB version.
- `P['nMiniblocksPerVis']`, `P['kinds']`: number of learning trials -> adjustable in params
- `P['testTrialsPerKind']`, `P['testMiniblocks']`, `P['deviantAwayFrom']`: the test phase

- `P['sideRule']`, `P['t2AwayFromMidline']`, `P['t2NotNeighbours']`: rules for the duplets (then run `make_duplet_list.py`).


## Data

Saved in the folder `Data` on the desktop (`~/Desktop/Data`), as `.json` (everything) and `.csv` (one row per trial).
+ the convergence graph
