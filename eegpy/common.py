"""Everything the three tasks share: window, stimuli, key presses, saving.

Only basic PsychoPy functions are used (visual, core, event, gui).
Durations of the stimuli are counted in screen frames, as in the MATLAB version.
"""
import csv
import json
import math
import os
import random

from psychopy import core, event, gui, visual


class AbortExperiment(Exception):
    """Raised when ESCAPE is pressed."""
    pass


# ---------------------------------------------------------------- participant
def ask_participant_info(title):
    """Dialog box for the participant's details. Returns a dictionary, or None if cancelled.
    The ID may contain letters and numbers. idNumber (the digits in the ID) is used for the
    counterbalancing; an ID without digits gets the sum of its character codes."""
    while True:
        info = {'Participant ID': '', 'Session': '1', 'Age': '', 'Gender': '', 'Handedness (r/l)': 'r'}
        dlg = gui.DlgFromDict(dictionary=info, title=title,
                              order=['Participant ID', 'Session', 'Age', 'Gender', 'Handedness (r/l)'])
        if not dlg.OK:
            return None
        pid = str(info['Participant ID']).strip()
        session = str(info['Session']).strip()
        if pid != '' and pid.isalnum() and session.isdigit():
            break
        print('Please use letters and numbers only for the ID, and a number for the session.')

    digits = ''.join(ch for ch in pid if ch.isdigit())
    if digits == '':
        idNumber = sum(ord(ch) for ch in pid)
    else:
        idNumber = int(digits)
    return {'id': pid, 'idNumber': idNumber, 'session': int(session), 'age': str(info['Age']),
            'gender': str(info['Gender']), 'handedness': str(info['Handedness (r/l)'])}


# ---------------------------------------------------------------- screen
class Display(object):
    """The window and all stimuli. Sizes are given in pixels (as in the MATLAB version)
    and converted to PsychoPy 'height' units by dividing by P['SCREEN_HEIGHT_PIX']."""

    def __init__(self, P):
        self.P = P
        s = 1.0 / P['SCREEN_HEIGHT_PIX']  # one "MATLAB pixel" in height units
        self.s = s
        if P['fullScreen']:
            self.win = visual.Window(fullscr=True, screen=P['screen'], color=P['bgColor'],
                                     colorSpace='rgb255', units='height', allowGUI=False)
        else:
            self.win = visual.Window(size=[1200, 750], fullscr=False, screen=P['screen'],
                                     color=P['bgColor'], colorSpace='rgb255', units='height')
        self.win.mouseVisible = False
        win = self.win

        # the 16 positions: clockwise, starting at the top (as in findPositions.m)
        # in PsychoPy, y goes up and (0, 0) is the centre of the screen
        n = P['nPositions']
        angle = 2 * math.pi / n
        self.xy = []
        for posi in range(n):
            a = angle / 2 + posi * angle
            self.xy.append((P['targetRadius'] * s * math.sin(a), P['targetRadius'] * s * math.cos(a)))

        # fixation cross: two thin rectangles
        L = 2 * P['fixSize'] * s
        W = P['fixLineWidth'] * s
        self.fix = [visual.Rect(win, width=L, height=W, pos=(0, 0), fillColor=P['fixColor'],
                                lineColor=None, colorSpace='rgb255'),
                    visual.Rect(win, width=W, height=L, pos=(0, 0), fillColor=P['fixColor'],
                                lineColor=None, colorSpace='rgb255')]

        # target: one square that is moved to the position of the trial
        self.target = visual.Rect(win, width=P['targetSize'] * s, height=P['targetSize'] * s,
                                  pos=(0, 0), fillColor=P['targetColor'], lineColor=None,
                                  colorSpace='rgb255')

        # mask: four rectangles (left, right, bottom, top) around every position (as in prepMask.m)
        space = P['maskSpace'] * s
        rl = P['maskRectLength'] * s
        rw = P['maskRectWidth'] * s
        self.mask = []
        for (x, y) in self.xy:
            centres = [(x - space - rl / 2, y, rl, rw), (x + space + rl / 2, y, rl, rw),
                       (x, y - space - rl / 2, rw, rl), (x, y + space + rl / 2, rw, rl)]
            for (cx, cy, w, h) in centres:
                self.mask.append(visual.Rect(win, width=w, height=h, pos=(cx, cy), fillColor=[0, 0, 0],
                                             lineColor=None, colorSpace='rgb255'))

        # texts
        self.text = visual.TextStim(win, text='', pos=(0, 0), height=P['textSize'] * s,
                                    color=P['textColor'], colorSpace='rgb255', wrapWidth=1.6)
        self.centreText = visual.TextStim(win, text='', pos=(0, 0), height=P['letterSize'] * s,
                                          color=P['textColor'], colorSpace='rgb255')
        self.letters = [visual.TextStim(win, text='', pos=xy, height=P['letterSize'] * s,
                                        color=P['textColor'], colorSpace='rgb255') for xy in self.xy]

    # ------------------------------------------------ drawing
    def draw_fix(self):
        for part in self.fix:
            part.draw()

    def set_mask_contrast(self, contrast):
        """Mask colour = 255 x mask contrast (0 = black, 1 = white)."""
        color = [255 * contrast] * 3
        for rect in self.mask:
            rect.fillColor = color

    def draw_mask(self):
        for rect in self.mask:
            rect.draw()

    def frames(self, n, what):
        """Shows the fixation cross plus 'what' for n frames. Returns the time of the first frame.
        what: '' (cross only), 'mask', or a position number 1-16 (the target at that position)."""
        onset = None
        for framei in range(n):
            self.draw_fix()
            if what == 'mask':
                self.draw_mask()
            elif what != '' and what > 0:
                self.target.pos = self.xy[what - 1]
                self.target.draw()
            t = self.win.flip()
            if framei == 0:
                onset = t
        return onset

    def message(self, txt):
        """Shows a text in the centre of the screen."""
        self.text.text = txt
        self.text.draw()
        return self.win.flip()

    def wait(self, seconds):
        """Fixation cross for a number of seconds."""
        self.frames(max(1, int(round(seconds * self.P['refreshRate']))), '')

    def countdown(self):
        for number in ['3', '2', '1']:
            self.message(number)
            core.wait(1.0)
        self.wait(1.0)

    # ------------------------------------------------ keys
    def get_key(self, keyList):
        """Waits for one of the keys in keyList. ESCAPE stops the task."""
        event.clearEvents()
        clock = core.Clock()
        while True:
            keys = event.waitKeys(keyList=list(keyList) + ['escape'], timeStamped=clock)
            key, rt = keys[0]
            if key == 'escape':
                raise AbortExperiment()
            return key, rt

    def wait_space(self):
        self.get_key(['space'])

    def get_rating(self):
        """Waits for 1, 2, 3 or 4 (top row or number pad). Returns the rating and the RT."""
        key, rt = self.get_key(['1', '2', '3', '4', 'num_1', 'num_2', 'num_3', 'num_4'])
        return int(key[-1]), rt

    def close(self):
        self.win.mouseVisible = True
        self.win.close()


# ---------------------------------------------------------------- learning / test trial
def run_main_trial(D, P, trial):
    """One trial of the learning or test phase:
    fixation -> T1 -> ISI -> mask -> fixation (1 s) -> T2 -> [ISI -> mask if maskT2] -> delay (2 s).
    The mask contrast must have been set before with D.set_mask_contrast()."""
    F = P['frames']
    D.frames(F['initFix'], '')
    T1Onset = D.frames(F['target'], trial['T1position'])
    ISI1Onset = D.frames(F['ISI'], '')
    mask1Onset = D.frames(F['mask'], 'mask')
    D.frames(F['blank'], '')
    T2Onset = D.frames(F['target'], trial['T2position'])
    if P['maskT2']:
        T2Offset = D.frames(F['ISI'], '')
        mask2Onset = D.frames(F['mask'], 'mask')
        delayOnset = D.frames(F['delay'], '')
        mask2 = mask2Onset - T1Onset
    else:
        delayOnset = D.frames(F['delay'], '')
        T2Offset = delayOnset
        mask2 = 0
    return {'T1Duration': ISI1Onset - T1Onset, 'mask1Onset': mask1Onset - T1Onset,
            'T2Onset': T2Onset - T1Onset, 'T2Duration': T2Offset - T2Onset, 'mask2Onset': mask2}


def run_questions(D, P, trial):
    """The four questions after a trial (letter version of the original code) and the ITI."""
    n = P['nPositions']
    letters = list(P['letters'])
    random.shuffle(letters)  # letters[2] is the letter shown at position 3
    result = {'letters': ''.join(letters)}

    for targeti, centre in ((1, P['text']['loc1']), (2, P['text']['loc2'])):
        for posi in range(n):
            D.letters[posi].text = letters[posi]
            D.letters[posi].draw()
        D.centreText.text = centre
        D.centreText.draw()
        D.win.flip()
        letter, rt = D.get_key(letters)
        answer = letters.index(letter) + 1
        result['T%dletter' % targeti] = letter
        result['T%danswer' % targeti] = answer
        result['T%danswerRT' % targeti] = rt
        core.wait(P['afterResponse'])

    D.message(P['text']['vis1'])
    result['T1visibility'], result['T1visibilityRT'] = D.get_rating()
    core.wait(P['afterResponse'])
    D.message(P['text']['vis2'])
    result['T2visibility'], result['T2visibilityRT'] = D.get_rating()

    ITI = random.choice(P['ITI'])
    D.wait(ITI)
    result['ITI'] = ITI

    # were the location answers correct? ('' = this target was not shown)
    result['T1correct'] = int(result['T1answer'] == trial['T1position']) if trial['T1position'] > 0 else ''
    result['T2correct'] = int(result['T2answer'] == trial['T2position']) if trial['T2position'] > 0 else ''
    return result


def run_main_task(P, phase):
    """The learning phase (phase = 'learning') or the test phase (phase = 'test')."""
    import trials as T

    info = ask_participant_info('Learning phase' if phase == 'learning' else 'Test phase')
    if info is None:
        return
    name = 'P%s_S%d' % (info['id'], info['session'])
    folder = P['path'][phase]
    if not os.path.isdir(folder):
        os.makedirs(folder)
    dataFile = os.path.join(folder, name + '_' + phase)
    positionFile = os.path.join(P['path']['learning'], 'P%s_positions.json' % info['id'])
    thresholdFile = os.path.join(P['path']['calibration'], name + '_threshold.json')
    learningFile = os.path.join(P['path']['learning'], name + '_learning.json')

    # mask contrasts from the calibration
    if not os.path.isfile(thresholdFile):
        print('No threshold file found: %s' % thresholdFile)
        print('Run the calibration first (run_calibration.py) with the same ID and session.')
        return
    with open(thresholdFile) as f:
        threshold = json.load(f)
    contrast = {'seen': threshold['contrastSeen'], 'unseen': threshold['contrastUnseen']}
    print('Threshold %.3f | seen miniblocks %.3f | unseen miniblocks %.3f'
          % (threshold['threshold'], contrast['seen'], contrast['unseen']))

    if phase == 'learning':
        kinds = P['kinds']
        nPerVis = P['nMiniblocksPerVis']
        if not os.path.isdir(P['path']['learning']):
            os.makedirs(P['path']['learning'])
        # positions: made once per participant and saved, afterwards always loaded
        pos = None
        if os.path.isfile(positionFile):
            with open(positionFile) as f:
                pos = json.load(f)
            print('Positions of this participant loaded.')
        if pos is None or 'T1' not in pos.get('seen', {}):
            # no file yet (or a file from the old design with two duplets): make new positions
            pos = T.make_positions(P, info['idNumber'])
            with open(positionFile, 'w') as f:
                json.dump(pos, f, indent=1)
    else:
        kinds = P['testKinds']
        nPerVis = P['testMiniblocksPerVis']
        if not os.path.isfile(positionFile):
            print('No positions found for this participant. Run the learning phase first.')
            return
        with open(positionFile) as f:
            pos = json.load(f)
        # continue with the mask contrasts at the end of the learning phase
        if os.path.isfile(learningFile):
            with open(learningFile) as f:
                contrast = json.load(f)['contrastNow']
            print('Mask contrasts taken from the end of the learning phase: seen %.3f, unseen %.3f'
                  % (contrast['seen'], contrast['unseen']))
        else:
            print('WARNING: no learning file found; the contrasts from the calibration are used.')

    trials = T.make_trials(kinds, nPerVis, info['idNumber'])
    trials = T.add_targets(trials, P)
    T.check_trials(trials, kinds)
    trials = T.add_positions(trials, pos)
    nMiniblocks = max(t['Miniblock_no'] for t in trials)

    data = {'info': info, 'pos': pos, 'threshold': threshold, 'phase': phase, 'trials': []}
    D = Display(P)
    aborted = False
    try:
        D.message(P['text']['learnInst'] if phase == 'learning' else P['text']['testInst'])
        D.wait_space()

        for miniblocki in range(1, nMiniblocks + 1):
            block = [t for t in trials if t['Miniblock_no'] == miniblocki]
            vis = block[0]['visibility']
            if vis == 'seen':
                D.message(P['text']['seenBlock'])
                correction = P['correctionSeen']
            else:
                D.message(P['text']['unseenBlock'])
                correction = P['correctionUnseen']
            D.wait_space()
            D.countdown()
            nWrong = 0  # number of ratings that do not fit this miniblock

            for trial in block:
                trial['maskContrast'] = contrast[vis]
                D.set_mask_contrast(contrast[vis])
                timing = run_main_trial(D, P, trial)
                answers = run_questions(D, P, trial)
                trial.update(timing)
                trial.update(answers)
                data['trials'].append(trial)

                # mask contrast correction (original code): only masked targets that were shown count
                ratings = []
                if trial['T1position'] > 0:
                    ratings.append(trial['T1visibility'])
                if trial['T2position'] > 0 and P['maskT2']:
                    ratings.append(trial['T2visibility'])
                if vis == 'seen':
                    nWrong += sum(1 for r in ratings if r == 1)
                else:
                    nWrong += sum(1 for r in ratings if r > 1)
                if nWrong >= P['nWrongAllowed']:
                    contrast[vis] = min(1.0, contrast[vis] * correction)
                    nWrong = 0
                    print('Adjusting mask contrast')

                if P['testMode']:
                    print('   miniblock %d (%s) trial %d | %s | T1 %d T2 %d | answers %d %d | seen %d %d | mask %.3f'
                          % (miniblocki, vis, trial['Trial_no'], trial['trialType'], trial['T1position'],
                             trial['T2position'], trial['T1answer'], trial['T2answer'],
                             trial['T1visibility'], trial['T2visibility'], trial['maskContrast']))

            data['contrastNow'] = dict(contrast)
            save_data(dataFile + '_partial', data)
            if miniblocki < nMiniblocks:
                D.message(P['text']['break'] % (nMiniblocks - miniblocki))
                D.wait_space()

        D.message(P['text']['end'])
        core.wait(2.5)
    except AbortExperiment:
        aborted = True
        print('Stopped with ESCAPE.')
    finally:
        D.close()

    data['contrastNow'] = dict(contrast)
    if aborted:
        save_data(dataFile + '_partial', data)
        print('Data so far saved in %s_partial.json / .csv' % dataFile)
    else:
        save_data(dataFile, data)
        for ext in ('.json', '.csv'):
            if os.path.isfile(dataFile + '_partial' + ext):
                os.remove(dataFile + '_partial' + ext)
        print('%s.json and .csv have been saved' % dataFile)


# ---------------------------------------------------------------- saving
def save_data(fileBase, data):
    """Saves everything as .json, and the trials as a .csv table (one row per trial)."""
    with open(fileBase + '.json', 'w') as f:
        json.dump(data, f, indent=1)
    rows = data.get('trials', [])
    if rows:
        columns = []
        for row in rows:
            for key in row:
                if key not in columns:
                    columns.append(key)
        with open(fileBase + '.csv', 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=columns)
            writer.writeheader()
            for row in rows:
                writer.writerow(row)
