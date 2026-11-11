# Calibration

The calibration is very similar to the manuscript, I mainly tweaked around some of the contradictions between the code and the manuscript + the encountered errors.

## How to run
Open MATLAB in this folder and type `runCalibration`. Settings (number of trials, staircase steps, colours, timing) are all in `calibParams.m`.

## Files (one function per file, written in the style of the original nonconSeq code)
| File | What it does | Original code |
|---|---|---|
| `runCalibration.m` | Main script: participant info, instructions, practice, trial loop with the staircases, threshold, saving | `nonconSeq_runCal.m` |
| `calibParams.m` | All settings and texts; also picks the screen, checks the refresh rate and converts durations to frames | `nonconSeq_initParams_cal.m` |
| `makeCalibTrials.m` | Trial list: every position 5 times plus the target-absent trials, all shuffled together | `nonconSeq_prepTrials_cal.m` |
| `checkCalibTrials.m` | Prints how often each position appears and checks every round | (new) |
| `findPositions.m` | Screen positions of the 16 targets | `findPositions.m` |
| `prepMask.m` | Screen positions of the mask rectangles | `nonconSeq_prepMask.m` |
| `runTrial.m` | One trial: fixation, target, ISI, mask, rating, ITI | `nonconSeq_doTrials_cal.m` |
| `runExampleTrial.m` | Slow example trial with explanations | (new) |
| `drawFixation.m`, `drawTarget.m`, `drawMask.m` | Drawing | `nonconSeq_stimulus_cal.m` |
| `textMsg.m` | Shows a text on the screen | `textMsg.m` |
| `getKey.m` | Waits for a specific key | `getKey.m` |
| `getRating.m` | Waits for the rating 1-4 | `nonconSeq_showFrame_cal.m` |
| `openScreen.m` | Opens the Psychtoolbox window | `nonconSeq_initPTBWin.m` |
| `askParticipantInfo.m` | Participant details in the Command Window | `nonconSeq_initSession.m` |
| `plotConvergence.m` | Convergence graph of both staircases (.png and .fig) | (new) |

## Output (in `Data/Calibration`)
`P<nr>_S<session>_calibration.mat` (all data), `_threshold.mat` (read by the main task), `_convergence.png/.fig`, `_summary.txt`.
