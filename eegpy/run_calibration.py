"""Purpose: main script of the calibration task (PsychoPy version of runCalibration.m).

ESCAPE stops the task; the data collected so far are saved.
"""
import json
import os
import random

from psychopy import core

from add_paths import add_paths

add_paths()   # makes the functions in the subfolders available

from abort_experiment import AbortExperiment
from ask_participant_info import ask_participant_info
from close_screen import close_screen
from countdown import countdown
from get_key import get_key
from make_calib_trials import make_calib_trials
from open_screen import open_screen
from params import get_params
from plot_convergence import plot_convergence
from prep_stimuli import prep_stimuli
from run_calib_trial import run_calib_trial
from save_data import save_data
from text_msg import text_msg


def main():
    P = get_params()
    info = ask_participant_info('Calibration')
    if info is None:
        return
    name = 'P%s_S%d' % (info['id'], info['session'])
    folder = P['path']['calibration']
    if not os.path.isdir(folder):
        os.makedirs(folder)
    fileBase = os.path.join(folder, name)

    trialList = make_calib_trials(P)

    # ---- staircase variables (same names as in the original code)
    nReversals = {'a': 0, 'b': 0}
    reversalPosition = {'a': [], 'b': []}   # which trials of a staircase were reversals (1 = first)
    maskC = {'a': [P['startContrast'][0]], 'b': [P['startContrast'][1]], 'blank': []}
    vis = {'a': [], 'b': [], 'blank': []}   # 0 = unseen, 1 = seen
    trialNumber = {'a': [], 'b': []}        # calibration trial number of each staircase trial
    count = {'a': 0, 'b': 0, 'blank': 0}
    reachedMax = {'a': False, 'b': False}

    data = {'info': info, 'trials': [], 'practice': []}
    D = open_screen(P)
    D = prep_stimuli(D)
    aborted = False
    try:
        text_msg(D, P['text']['calibInst'])
        get_key(['space'])

        # ---- practice trials (weak masks)
        text_msg(D, P['text']['practice'])
        get_key(['space'])
        countdown(D)
        for contrast in P['practiceContrasts']:
            practiceTrial = {'cond': 1, 'tarPos': random.randint(1, P['nPositions']),
                             'ITI': random.choice(P['ITI'])}
            data['practice'].append(run_calib_trial(D, P, practiceTrial, contrast))

        # ---- calibration
        text_msg(D, P['text']['calibStart'])
        get_key(['space'])
        countdown(D)

        for triali, trial in enumerate(trialList, start=1):
            if trial['cond'] == 1:      # target-present: one of the two staircases, at random
                stair = random.choice(['a', 'b'])
                count[stair] += 1
                if nReversals[stair] >= P['nReversalsSmallStep']:
                    stepSize = P['smallStep']
                else:
                    stepSize = P['bigStep']
                currentContrast = maskC[stair][count[stair] - 1]
            else:                       # target-absent: the current contrast of a or of b
                stair = 'blank'
                count[stair] += 1
                currentContrast = random.choice([maskC['a'][-1], maskC['b'][-1]])
                maskC['blank'].append(currentContrast)

            result = run_calib_trial(D, P, trial, currentContrast)

            if result['rating'] == 1:
                vis[stair].append(0)    # unseen
            else:
                vis[stair].append(1)    # seen (2, 3 or 4)

            if trial['cond'] == 1:
                trialNumber[stair].append(triali)
                c = count[stair]
                # next mask contrast: unseen -> weaker mask, seen -> stronger mask
                if vis[stair][c - 1] == 0:
                    nextContrast = currentContrast - stepSize
                else:
                    nextContrast = currentContrast + stepSize

                # reversal: the answer changed, or the contrast is at 0 or 1 (original code)
                if c > 1:
                    answerChanged = vis[stair][c - 1] != vis[stair][c - 2]
                    atBound = P['reversalAtBounds'] and currentContrast in (0, 1)
                    if answerChanged or atBound:
                        nReversals[stair] += 1
                        reversalPosition[stair].append(c)
                        if nReversals[stair] >= P['nReversalsMax']:
                            reachedMax[stair] = True

                # keep the contrast between 0 and 1
                nextContrast = round(nextContrast * 1000) / 1000.0
                nextContrast = min(1.0, max(0.0, nextContrast))
                maskC[stair].append(nextContrast)

            result.update(trial=triali, staircase=stair)
            data['trials'].append(result)
            if P['testMode']:
                print('Trial %d | position %d | staircase %s | mask %.2f | rating %d | reversals a %d, b %d'
                      % (triali, trial['tarPos'], stair, currentContrast, result['rating'],
                         nReversals['a'], nReversals['b']))
            if triali % 10 == 0:
                save_data(fileBase + '_calibration_partial', data)

        text_msg(D, P['text']['end'])
        core.wait(2.5)
    except AbortExperiment:
        aborted = True
        print('Stopped with ESCAPE.')
    finally:
        close_screen(D)

    if aborted:
        save_data(fileBase + '_calibration_partial', data)
        print('Data so far saved. No threshold was computed.')
        return

    # ---- threshold: mean mask contrast at the last 4 reversals of each staircase, averaged
    warnings = []
    thresholdValue = {'a': None, 'b': None, 'c': None}
    nUsed = P['nReversalsUsed']
    if reversalPosition['a'] and reversalPosition['b']:
        if nReversals['a'] >= nUsed and nReversals['b'] >= nUsed:
            usedA = reversalPosition['a'][-nUsed:]
            usedB = reversalPosition['b'][-nUsed:]
        else:
            warnings.append('Number of reversals not met!')
            usedA = reversalPosition['a']
            usedB = reversalPosition['b']
        valuesA = [maskC['a'][c - 1] for c in usedA]
        valuesB = [maskC['b'][c - 1] for c in usedB]
        thresholdValue['a'] = sum(valuesA) / len(valuesA)
        thresholdValue['b'] = sum(valuesB) / len(valuesB)
        thresholdValue['c'] = (thresholdValue['a'] + thresholdValue['b']) / 2
    else:
        warnings.append('Not enough reversals to compute a threshold!')

    data.update(maskC=maskC, vis=vis, nReversals=nReversals, reversalPosition=reversalPosition,
                trialNumber=trialNumber, thresholdValue=thresholdValue, warnings=warnings)
    save_data(fileBase + '_calibration', data)
    for ext in ('.json', '.csv'):
        if os.path.isfile(fileBase + '_calibration_partial' + ext):
            os.remove(fileBase + '_calibration_partial' + ext)

    if thresholdValue['c'] is None:
        print('WARNING: ' + ' '.join(warnings))
        return

    contrastUnseen = min(1.0, thresholdValue['c'] * P['factorUnseen'])
    contrastSeen = thresholdValue['c'] * P['factorSeen']
    if abs(maskC['a'][-1] - maskC['b'][-1]) > 0.2:
        warnings.append('The two staircases ended more than 0.2 apart: look at the convergence graph.')
    if vis['blank']:
        falseAlarms = sum(vis['blank']) / len(vis['blank'])
    else:
        falseAlarms = 0.0

    with open(fileBase + '_threshold.json', 'w') as f:
        json.dump({'threshold': thresholdValue['c'], 'contrastUnseen': contrastUnseen,
                   'contrastSeen': contrastSeen, 'participant': info}, f, indent=1)

    print('')
    print('Participant %s, session %d' % (info['id'], info['session']))
    print('Threshold (mask contrast): %.3f' % thresholdValue['c'])
    print('  staircase a: %.3f (%d reversals)' % (thresholdValue['a'], nReversals['a']))
    print('  staircase b: %.3f (%d reversals)' % (thresholdValue['b'], nReversals['b']))
    print('Main task contrasts: non-conscious %.3f | conscious %.3f' % (contrastUnseen, contrastSeen))
    print('False alarms (seen without target): %d%%' % round(100 * falseAlarms))
    for w in warnings:
        print('WARNING: ' + w)

    plot_convergence(fileBase + '_convergence.png', name, maskC, trialNumber, reversalPosition,
                     thresholdValue['c'], contrastUnseen, contrastSeen)
    print('Saved in: ' + folder)


if __name__ == '__main__':
    main()
