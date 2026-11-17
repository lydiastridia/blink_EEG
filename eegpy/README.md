# eegpy: PsychoPy version

The same three tasks as the MATLAB version, written for PsychoPy (free, no licence needed).

One function per file; the file has the same name as the function.

**Start a task** (run these files)

| File | What it is |
| --- | --- |
| `run_calibration.py` | Calibration (two staircases, threshold, convergence graph) |
| `run_learning.py` | Learning phase |
| `run_test.py` | Test phase (learning phase plus deviant trials) |
| `make_duplet_list.py` | Makes `duplet_list.csv`; run it after changing a rule for the duplets |

**Settings and data files**

| File | What it is |
| --- | --- |
| `params.py` | All settings |
| `duplet_list.csv` | All combinations of duplets that pass the rules; one row is picked at random per participant |

**Calibration**

| File | What it does |
| --- | --- |
| `make_calib_trials.py` | Trial list of the calibration |
| `run_calib_trial.py` | One calibration trial |
| `plot_convergence.py` | Convergence graph |

**Learning and test phase: trial list and duplets**

| File | What it does |
| --- | --- |
| `make_trial_order.py` | Order of one miniblock (every kind follows every kind once) |
| `compute_transitions.py` | Counts the transitions (used by the check) |
| `make_learning_trials.py` | Trial list: miniblocks, visibility, kinds |
| `balanced_list.py` | Helper: values in turn, in random order |
| `add_targets.py` | Which T1 and T2 are shown (valid, omission, deviant) |
| `jump_size.py` | Jump from T1 to T2 in positions |
| `check_set.py` | The rules for one set of four duplets |
| `valid_sets.py` | All valid sets for eight positions |
| `build_duplet_list.py` | All valid combinations of duplets |
| `rules_label.py` | First line of `duplet_list.csv` (the rules it was made with) |
| `write_duplet_list.py` | Saves `duplet_list.csv` |
| `read_duplet_list.py` | Reads `duplet_list.csv` (remakes it if the rules changed) |
| `make_positions.py` | Picks the duplets of one participant |
| `add_positions.py` | Gives every trial its positions |
| `check_learning_trials.py` | Prints the overview of the trial list |
| `run_learning_trial.py` | One learning or test trial on the screen |
| `run_questions.py` | The four questions and the ITI |

**Screen, keys, files**

| File | What it does |
| --- | --- |
| `open_screen.py` | Opens the window |
| `find_positions.py` | The 16 positions on the circle |
| `prep_mask.py` | The mask rectangles |
| `prep_stimuli.py` | Makes all stimuli |
| `draw_fixation.py`, `draw_target.py`, `draw_mask.py` | Draw one element |
| `set_mask_contrast.py` | Sets the mask colour |
| `show_frames.py` | Shows the screen for a number of frames |
| `show_fixation.py` | Fixation cross for a number of seconds |
| `text_msg.py` | Text in the centre of the screen |
| `countdown.py` | Count-down 3-2-1 |
| `close_screen.py` | Closes the window |
| `get_key.py`, `get_rating.py`, `get_letter.py` | Wait for a key, a rating 1-4, a letter |
| `abort_experiment.py` | The error raised by ESCAPE |
| `ask_participant_info.py` | Dialog box for the participant's details |
| `load_threshold.py` | Loads the threshold of the calibration |
| `save_data.py` | Saves the data (.json and .csv) |

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
- `P['nMiniblocksPerVis']`, `P['testMiniblocksPerVis']`, `P['kinds']`, `P['testKinds']`: number of trials.
- `P['maskT2']`: whether T2 is followed by a mask.
- `P['sideRule']`, `P['t2AwayFromMidline']`: rules for the duplets (then run `make_duplet_list.py`).

## Data

Saved in the `Data` folder next to this folder, as `.json` (everything) and `.csv` (one row per trial).
The files are separate from those of the MATLAB version (`.mat`): a calibration done in MATLAB
cannot be used here, and the other way round.
