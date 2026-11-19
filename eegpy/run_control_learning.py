"""Purpose: main script of the control learning phase. Run this file to start.
It is the same as the learning phase (run_learning.py): the same miniblocks, seen/unseen order,
omission rate, trial, questions and mask correction. The only difference is that T1 never predicts
T2: instead of the four duplets, every trial has a T1 and a T2 at random positions
(add_random_positions), so there is nothing to learn.
The calibration must have been run before with the same participant ID and session.

Output in Data/ControlLearning:
    P<id>_S<session>_controlLearning.json     all data
    P<id>_S<session>_controlLearning.csv      one row per trial
ESCAPE stops the task; the data collected so far are saved.
"""
import os

from psychopy import core

from add_paths import add_paths

add_paths()   # makes the functions in the subfolders available

from abort_experiment import AbortExperiment
from add_random_positions import add_random_positions
from ask_participant_info import ask_participant_info
from check_control_trials import check_control_trials
from close_screen import close_screen
from countdown import countdown
from get_key import get_key
from load_threshold import load_threshold
from make_control_learning_trials import make_control_learning_trials
from open_screen import open_screen
from params import get_params
from prep_stimuli import prep_stimuli
from run_learning_trial import run_learning_trial
from run_questions import run_questions
from save_data import save_data
from set_mask_contrast import set_mask_contrast
from text_msg import text_msg


def main():
    # ---------------------------------------------------------------- PREPARATION
    P = get_params()
    info = ask_participant_info('Control learning phase')
    if info is None:
        return

    folder = P['path']['controlLearning']
    if not os.path.isdir(folder):
        os.makedirs(folder)
    name = 'P%s_S%d' % (info['id'], info['session'])
    dataFile = os.path.join(folder, name + '_controlLearning')

    # mask contrasts from the calibration
    threshold = load_threshold(P, info)
    if threshold is None:
        return
    contrast = {'seen': threshold['contrastSeen'], 'unseen': threshold['contrastUnseen']}

    # how the locations are answered (keyboard or mouse): the choice made in the calibration
    P['responseMode'] = threshold['participant'].get('responseMode', P['responseMode'])
    info['responseMode'] = P['responseMode']
    print('Location answers: %s' % P['responseMode'])

    # trial list: as in the learning phase, but with random positions
    trials = make_control_learning_trials(P, info['idNumber'])
    trials = add_random_positions(trials, P)
    check_control_trials(trials, P, 'Control learning phase')
    nMiniblocks = max(t['Miniblock_no'] for t in trials)

    # ---------------------------------------------------------------- RUN
    data = {'info': info, 'threshold': threshold, 'phase': 'controlLearning', 'trials': []}
    D = open_screen(P)
    D = prep_stimuli(D)
    aborted = False
    try:
        if P['responseMode'] == 'mouse':
            text_msg(D, P['text']['learnInstMouse'])
        else:
            text_msg(D, P['text']['learnInst'])
        get_key(['space'])

        for miniblocki in range(1, nMiniblocks + 1):
            block = [t for t in trials if t['Miniblock_no'] == miniblocki]
            vis = block[0]['visibility']   # 'seen' or 'unseen'

            # instruction of this miniblock, and correction factor for the mask contrast
            if vis == 'seen':
                text_msg(D, P['text']['seenBlock'])
                correction = P['correctionSeen']
            else:
                text_msg(D, P['text']['unseenBlock'])
                correction = P['correctionUnseen']
            get_key(['space'])
            countdown(D)
            nWrong = 0   # number of ratings that do not fit this miniblock

            for trial in block:
                # mask contrast on this trial
                trial['maskContrast'] = contrast[vis]
                set_mask_contrast(D, contrast[vis])

                # the trial and the questions
                timing = run_learning_trial(D, P, trial)
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
                    nWrong = nWrong + sum(1 for r in ratings if r == 1)   # not seen in a seen miniblock
                else:
                    nWrong = nWrong + sum(1 for r in ratings if r > 1)    # seen in an unseen miniblock
                if nWrong >= P['nWrongAllowed']:
                    contrast[vis] = min(1.0, contrast[vis] * correction)
                    nWrong = 0
                    print('Adjusting mask contrast')

                if P['testMode']:
                    print('   miniblock %d (%s) trial %d | %s | T1 %d T2 %d | answers %d %d | seen %d %d | mask %.3f'
                          % (miniblocki, vis, trial['Trial_no'], trial['trialType'], trial['T1position'],
                             trial['T2position'], trial['T1answer'], trial['T2answer'],
                             trial['T1visibility'], trial['T2visibility'], trial['maskContrast']))

            # save after every miniblock, in case something goes wrong
            data['contrastNow'] = dict(contrast)
            save_data(dataFile + '_partial', data)

            # break between the miniblocks
            if miniblocki < nMiniblocks:
                text_msg(D, P['text']['break'] % (nMiniblocks - miniblocki))
                get_key(['space'])

        text_msg(D, P['text']['end'])
        core.wait(2.5)
    except AbortExperiment:
        aborted = True
        print('Stopped with ESCAPE.')
    finally:
        close_screen(D)

    # ---------------------------------------------------------------- SAVE
    data['contrastNow'] = dict(contrast)   # mask contrasts at the end (after the corrections)
    if aborted:
        save_data(dataFile + '_partial', data)
        print('Data so far saved in %s_partial.json / .csv' % dataFile)
    else:
        save_data(dataFile, data)
        for ext in ('.json', '.csv'):
            if os.path.isfile(dataFile + '_partial' + ext):
                os.remove(dataFile + '_partial' + ext)
        print('%s.json and .csv have been saved' % dataFile)


if __name__ == '__main__':
    main()
