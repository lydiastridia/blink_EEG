"""Purpose: the four questions after a trial, then the ITI (letter version of the original code):
1. '1?'      where was the first target? 16 letters are shown on the circle; type the letter
2. '2?'      where was the second target?
3. 'Seen 1?' visibility of the first target (1-4)
4. 'Seen 2?' visibility of the second target (1-4)
The letters are shuffled on every trial, as in the original code. No time limit.

Input:  D        screen with stimuli (prep_stimuli)
        P        settings (params.py)
        trial    the trial that was just shown
Output: result   answers, response times and whether the locations were correct
"""
import random

from psychopy import core

from get_letter import get_letter
from get_rating import get_rating
from show_fixation import show_fixation
from text_msg import text_msg


def run_questions(D, P, trial):
    letters = list(P['letters'])
    random.shuffle(letters)   # letters[0] is shown at position 1, letters[1] at position 2, ...
    result = {'letters': ''.join(letters)}

    # questions 1 and 2: the locations
    for targeti in (1, 2):
        for posi in range(P['nPositions']):
            D['letters'][posi].text = letters[posi]
            D['letters'][posi].draw()
        D['centreText'].text = P['text']['loc%d' % targeti]
        D['centreText'].draw()
        D['win'].flip()

        letter, RT = get_letter(letters)
        result['T%dletter' % targeti] = letter
        result['T%danswer' % targeti] = letters.index(letter) + 1   # the position of that letter
        result['T%danswerRT' % targeti] = RT
        core.wait(P['afterResponse'])

    # questions 3 and 4: visibility
    text_msg(D, P['text']['vis1'])
    result['T1visibility'], result['T1visibilityRT'] = get_rating()
    core.wait(P['afterResponse'])
    text_msg(D, P['text']['vis2'])
    result['T2visibility'], result['T2visibilityRT'] = get_rating()

    # ITI: one of the possible durations, at random
    ITI = random.choice(P['ITI'])
    show_fixation(D, ITI)
    result['ITI'] = ITI

    # were the locations correct? ('' = this target was not shown)
    if trial['T1position'] > 0:
        result['T1correct'] = int(result['T1answer'] == trial['T1position'])
    else:
        result['T1correct'] = ''
    if trial['T2position'] > 0:
        result['T2correct'] = int(result['T2answer'] == trial['T2position'])
    else:
        result['T2correct'] = ''
    return result
