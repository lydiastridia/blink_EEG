"""Purpose: all settings of the three tasks (calibration, learning phase, test phase).

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
    # 4 duplets and 1 omission kind -> 5 x 5 + 1 = 26 trials per miniblock folllowing de Bruijne: 80% duplets, 20% omissions
    P['nDuplets'] = 4
    P['kinds'] = ['duplet1', 'duplet2', 'duplet3', 'duplet4', 'omission']
    P['nMiniblocksPerVis'] = 2         # miniblocks per visibility (2 -> 4 miniblocks, 104 trials)
    P['maskT2'] = True                 # T2 is followed by the same mask as T1

    # Duplets: the tasks pick one row of duplet_list.csv at random for every new participant.
    # After changing one of these rules, run make_duplet_list.py to make the list again.
    P['sideRule'] = 'crossed'          # 'crossed'    : one duplet each right->right, left->left, right->left, left->right
                                       # 'rightToLeft': every T1 on the right, every T2 on the left (original sequence file)
    P['t2AwayFromMidline'] = True      # no T2 at positions 1, 8, 9, 16 (next to the vertical midline); only with 'crossed'
    P['t2NotNeighbours'] = True        # no two T2 positions of a set are next to each other

    # Mask contrast correction during the task
    P['nWrongAllowed'] = 2
    P['correctionSeen'] = 0.95         # seen miniblocks: mask contrast - 5% (manuscript)
    P['correctionUnseen'] = 1.05       # unseen miniblocks: mask contrast + 5%

    # Questions
    P['letters'] = 'aefgiklmorsuwxyz'  # 16 letters, shuffled on every trial
    # How the locations are answered: 'keyboard' (type the letter) or 'mouse' (move the cursor
    # from the centre onto the letter; it counts as soon as the cursor reaches it, as in the
    # original code). It is chosen per participant in the calibration dialog and then used in
    # the learning and test phase; this value is only used if no choice was saved.
    P['responseMode'] = 'keyboard'

    # ---------------- Test phase ----------------
    # Number of trials of each kind in ONE test miniblock (together 52 -> 52 trials per miniblock).
    # The trials of each kind (except random deviants) are divided equally over the 4 duplets
    # (so use multiples of 4).
    #   valid    : T1 of a duplet, T2 at the predicted position (as in the learning phase)
    #   omission : T1 of a duplet, no T2 (as in the learning phase)
    #   deviant       : T1 of a duplet, T2 at a random allowed position (see P['deviantAwayFrom'])
    #   randomDeviant : T1 at a random position that is never a T1 (in either set), T2 at a random
    #                   position that is not a predictive T2 of the set and not next to one
    # The order of the trials within a miniblock is random.
    P['testTrialsPerKind'] = {'valid': 20, 'omission': 16, 'deviant': 8, 'randomDeviant': 8}
    P['testMiniblocks'] = 2                # test miniblocks in total; they alternate seen / unseen
    # Where the T2 of a deviant may NOT appear (always also not where T1 was shown on that trial):
    #   'predictedT2' : on or next to the predicted T2 of that trial's duplet
    #   'allT2'       : on or next to any of the four predictive T2s of the set
    P['deviantAwayFrom'] = 'allT2'

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
        'example1': 'Example trial\n\nKeep your eyes on this cross.\n\n(SPACE)',
        'example2': ('This is the square you are looking for (circled here).\n'
                     'It flashes at ONE of the positions around the cross,\n'
                     'for only a fraction of a second.\n\n(SPACE)'),
        'example3': ('Right after the square, these rectangles appear\n'
                     'around ALL positions. They are NOT the square:\n'
                     'they can make the square hard to see.\n\n(SPACE)'),
        'example4': ('Here both are shown together: the square sits in the gap\n'
                     'between four rectangles. In the real task the square comes\n'
                     'first and disappears before the rectangles appear.\n\n(SPACE)'),
        'example5': ('Then you rate how well you saw the square:\n\n'
                     '1 = I did not see anything\n'
                     '2 = I saw a brief glimpse, but I am not sure\n'
                     '3 = I saw the square, but only weakly\n'
                     '4 = I clearly saw the square\n\n(SPACE)'),
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
        'learnInstMouse': ('In this task, two small grey squares flash one after the other,\n'
                           'each at one of the positions around the central cross.\n'
                           'Sometimes one of the two squares is missing.\n\n'
                           'After each trial you answer four questions:\n\n'
                           '1?  Where was the first square? Move the mouse onto the letter at its position.\n'
                           '2?  Where was the second square? Move the mouse onto the letter at its position.\n'
                           '(The mouse starts in the centre; your answer counts as soon as it reaches a letter.)\n'
                           'Seen 1?  How well did you see the first square (keys 1 to 4)?\n'
                           'Seen 2?  How well did you see the second square (keys 1 to 4)?\n\n'
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

    # ---------------- Data folders (in the folder Data on the desktop) ----------------
    thisFolder = os.path.dirname(os.path.abspath(__file__))
    dataFolder = os.path.join(os.path.expanduser('~'), 'Desktop', 'Data')
    P['path'] = {
        'calibration': os.path.join(dataFolder, 'Calibration'),
        'learning': os.path.join(dataFolder, 'LearningPhase'),
        'test': os.path.join(dataFolder, 'TestPhase'),
        'controlLearning': os.path.join(dataFolder, 'ControlLearning'),
        'controlTest': os.path.join(dataFolder, 'ControlTest'),
        'dupletList': os.path.join(thisFolder, 'duplets', 'duplet_list.csv'),
    }
    return P
