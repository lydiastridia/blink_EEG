"""All settings of the PsychoPy version (calibration, learning phase, test phase).

The values are the same as in calibParams.m and mainParams.m of the MATLAB version.
Sizes are given in pixels as Psychtoolbox saw the screen (see SCREEN_HEIGHT_PIX).
"""
import os


def get_params():
    P = {}

    # ---------------- General ----------------
    P['testMode'] = True       # True: prints every trial in the output window
    P['fullScreen'] = True     # False: a window (for debugging only)
    P['screen'] = 0            # 0 = main screen, 1 = second monitor

    # Height of the screen in pixels as Psychtoolbox saw it (MacBook: 900).
    # All sizes below are divided by this number, so that the stimuli have the
    # same size on the screen as in the MATLAB version.
    P['SCREEN_HEIGHT_PIX'] = 900.0
    P['refreshRate'] = 60.0    # Hz; the durations below are counted in frames

    # ---------------- Colours (0-255) ----------------
    P['bgColor'] = [1, 1, 1]              # near-black background
    P['textColor'] = [250, 250, 250]
    P['fixColor'] = [255, 255, 255]
    P['targetContrast'] = 0.35
    P['targetColor'] = [255 * 0.35] * 3   # grey 89

    # ---------------- Sizes (pixels) ----------------
    P['textSize'] = 28
    P['letterSize'] = 35
    P['fixSize'] = 10          # half-length of each line of the fixation cross
    P['fixLineWidth'] = 6
    P['targetSize'] = 16
    P['nPositions'] = 16
    P['targetRadius'] = 200    # distance of the positions from the centre
    P['maskRectLength'] = 12   # each mask element is a rectangle of 16 x 12 pixels
    P['maskRectWidth'] = 16
    P['maskSpace'] = 9         # distance from the target centre to a mask element

    # ---------------- Timing (frames at 60 Hz) ----------------
    P['frames'] = {
        'calibFix': 30,    # 0.5 s fixation at the start of a calibration trial
        'target': 1,       # 16.7 ms
        'ISI': 1,          # 16.7 ms
        'mask': 14,        # 233 ms
        'initFix': 60,     # 1 s fixation at the start of a learning/test trial
        'blank': 60,       # 1 s between the first mask and T2
        'delay': 120,      # 2 s after T2, before the questions
    }
    P['ITI'] = [0.3333, 0.4166, 0.4999, 0.5832, 0.6665]  # one is chosen at random
    P['afterResponse'] = 0.35  # short wait after each answer (learning/test phase)

    # ---------------- Calibration ----------------
    P['nTrialsPerPosition'] = 5        # 16 x 5 = 80 target-present trials
    P['propAbsent'] = 0.2              # 20% target-absent trials -> 100 trials in total
    P['startContrast'] = [0.95, 0.05]  # staircase a and staircase b
    P['bigStep'] = 0.2
    P['smallStep'] = 0.05
    P['nReversalsSmallStep'] = 2       # small steps after 2 reversals (original code)
    P['reversalAtBounds'] = True       # contrast 0 or 1 also counts as a reversal (original code)
    P['nReversalsUsed'] = 4            # threshold = mean of the last 4 reversals
    P['nReversalsMax'] = 16
    P['factorUnseen'] = 1.5            # non-conscious blocks: threshold x 1.5
    P['factorSeen'] = 0.5              # conscious blocks: threshold x 0.5
    P['practiceContrasts'] = [0.03, 0.03, 0.03, 0.1, 0.1, 0.1]

    # ---------------- Learning phase ----------------
    P['kinds'] = ['duplet1', 'duplet1', 'duplet2', 'duplet2', 'control1', 'control2', 'targetAbsent']
    P['propT1absent'] = 0.5            # share of the target-absent trials in which T1 is missing
    P['nMiniblocksPerVis'] = 2         # miniblocks per visibility (7 x 7 + 1 = 50 trials each)
    P['maskT2'] = False                # False: T2 without a mask; True: T2 masked like T1 (manuscript)

    # Positions
    P['jumpsA'] = [3, 6]               # in positions (1 position = 22.5 degrees): 67.5 and 135 degrees
    P['jumpsB'] = [2, 7]               # 45 and 157.5 degrees
    P['leftRightRule'] = True          # T2 locations left and right, both duplet T1s on the same side

    # Mask contrast correction during the task
    P['nWrongAllowed'] = 2
    P['correctionSeen'] = 0.95         # seen miniblocks: mask contrast - 5% (manuscript)
    P['correctionUnseen'] = 1.05       # unseen miniblocks: mask contrast + 5%

    # Questions
    P['letters'] = 'aefgiklmorsuwxyz'  # 16 letters, shuffled on every trial

    # ---------------- Test phase ----------------
    P['testKinds'] = ['duplet1', 'duplet1', 'duplet2', 'duplet2', 'control1', 'control2',
                      'deviant', 'targetAbsent']
    P['testMiniblocksPerVis'] = 1      # 8 x 8 + 1 = 65 trials each

    # ---------------- Texts ----------------
    P['text'] = {
        'calibInst': ('In this task, a small grey square may flash very briefly\n'
                      'at one of several positions around the central cross.\n'
                      'Right after it, a pattern of small rectangles appears.\n\n'
                      'On some trials there is no square at all.\n\n'
                      'After each flash, rate how well you saw the square:\n\n'
                      '1 = I did not see anything\n'
                      '2 = I saw a brief glimpse, but I am not sure\n'
                      '3 = I saw the square, but only weakly\n'
                      '4 = I clearly saw the square\n\n'
                      'Press 1 only if you had no impression at all.\n\n'
                      'Please keep your eyes on the central cross.\n\n'
                      'Press SPACE to continue.'),
        'practice': ('Practice\n\nA few practice trials at normal speed.\n'
                     'Answer with the keys 1 to 4.\n\nPress SPACE to start.'),
        'calibStart': ('The task now starts.\n\nIt takes about 5 minutes.\n'
                       'Keep your eyes on the central cross.\n\nPress SPACE to start.'),
        'vis': 'Seen?\n\n1   2   3   4',
        'vis1': 'Seen 1?\n\n1   2   3   4',
        'vis2': 'Seen 2?\n\n1   2   3   4',
        'loc1': '1?',
        'loc2': '2?',
        'end': 'Thank you! This part is finished.\n\nPlease wait for the experimenter.',
        'learnInst': ('In this task, two small grey squares flash one after the other,\n'
                      'each at one of the positions around the central cross.\n'
                      'Sometimes one of the two squares is missing.\n\n'
                      'After each trial you answer four questions:\n\n'
                      '1?  Where was the first square? Type the letter shown at its position.\n'
                      '2?  Where was the second square? Type the letter shown at its position.\n'
                      'Seen 1?  How well did you see the first square (1 to 4)?\n'
                      'Seen 2?  How well did you see the second square (1 to 4)?\n\n'
                      'If you did not see a square, follow your gut feeling and guess its position.\n'
                      'Press 1 only if you had no impression at all.\n\n'
                      'Please keep your eyes on the central cross.\n\n'
                      'Press SPACE to continue.'),
        'testInst': 'The task continues in the same way as before.\n\nPress SPACE to continue.',
        'seenBlock': ('In this block, you will be able to see the targets.\n'
                      'Do your best to identify the locations correctly afterwards.\n\n'
                      'Press SPACE to start.'),
        'unseenBlock': ('In this block, you will probably not see the targets.\n'
                        'Do not get frustrated by this, it happens on purpose!\n'
                        'Please try your best to guess the location.\n\n'
                        'Press SPACE to start.'),
        'break': ('Good job! Remaining number of blocks: %d\n\nTake a short break.\n\n'
                  'Press SPACE to continue.'),
    }

    # ---------------- Data folders (inside the repository folder) ----------------
    thisFolder = os.path.dirname(os.path.abspath(__file__))
    repoRoot = os.path.dirname(thisFolder)
    P['path'] = {
        'calibration': os.path.join(repoRoot, 'Data', 'Calibration'),
        'learning': os.path.join(repoRoot, 'Data', 'LearningPhase'),
        'test': os.path.join(repoRoot, 'Data', 'TestPhase'),
    }
    return P
