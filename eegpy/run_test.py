"""Purpose: main script of the test phase (PsychoPy version of runTest.m). Run this file to start.
The test phase uses the same duplets as the learning phase, with valid trials, omissions, deviants
and random deviants in the numbers of P['testTrialsPerKind'], and continues with the mask contrasts
at the end of the learning phase.
The learning phase must have been run before with the same participant ID and session.

Output in Data/TestPhase:
    P<id>_S<session>_test.json     all data
    P<id>_S<session>_test.csv      one row per trial
ESCAPE stops the task; the data collected so far are saved.
"""
import json
import os

from psychopy import core

from add_paths import add_paths

add_paths()   # makes the functions in the subfolders available

from abort_experiment import AbortExperiment
from add_deviant_positions import add_deviant_positions
from add_positions import add_positions
from ask_participant_info import ask_participant_info
from check_test_trials import check_test_trials
from close_screen import close_screen
from countdown import countdown
from get_key import get_key
from load_threshold import load_threshold
from make_test_trials import make_test_trials
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
    info = ask_participant_info('Test phase')
    if info is None:
        return

    folder = P['path']['test']
    if not os.path.isdir(folder):
        os.makedirs(folder)
    name = 'P%s_S%d' % (info['id'], info['session'])
    dataFile = os.path.join(folder, name + '_test')
    positionFile = os.path.join(P['path']['learning'], 'P%s_positions.json' % info['id'])
    learningFile = os.path.join(P['path']['learning'], name + '_learning.json')

    # mask contrasts: those at the end of the learning phase
    # (if there is no learning file, those from the calibration)
    threshold = load_threshold(P, info)
    if threshold is None:
        return
    if os.path.isfile(learningFile):
        with open(learningFile) as f:
            contrast = json.load(f)['contrastNow']
        print('Mask contrasts taken from the end of the learning phase: seen %.3f, unseen %.3f'
              % (contrast['seen'], contrast['unseen']))
    else:
        print('WARNING: no learning file found; the contrasts from the calibration are used.')
        contrast = {'seen': threshold['contrastSeen'], 'unseen': threshold['contrastUnseen']}

    # positions: the same as in the learning phase
    if not os.path.isfile(positionFile):
        print('No positions found for this participant. Run the learning phase first.')
        return
    with open(positionFile) as f:
        pos = json.load(f)

    # trial list
    trials = make_test_trials(P, info['idNumber'])
    trials = add_positions(trials, pos)
    trials = add_deviant_positions(trials, pos, P)
    check_test_trials(trials, pos, P)
    nMiniblocks = max(t['Miniblock_no'] for t in trials)

    # ---------------------------------------------------------------- RUN
    data = {'info': info, 'pos': pos, 'threshold': threshold, 'phase': 'test', 'trials': []}
    D = open_screen(P)
    D = prep_stimuli(D)
    aborted = False
    try:
        text_msg(D, P['text']['testInst'])
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
