"""Purpose: dialog box for the participant's details.
The ID may contain letters and numbers. idNumber (the digits in the ID, e.g. P03 -> 3) is used
for the counterbalancing; an ID without digits gets the sum of its character codes.
In the calibration the dialog also asks how the locations will be answered (keyboard or mouse);
the learning and test phase then use that choice.

Input:  title             text at the top of the dialog box
        askResponseMode   True: also ask 'Location answers' (keyboard / mouse)
Output: info    dictionary with id, idNumber, session, age, gender, handedness
                (and responseMode if it was asked); None if the dialog was cancelled
"""
from psychopy import gui


def ask_participant_info(title, askResponseMode=False):
    order = ['Participant ID', 'Session', 'Age', 'Gender', 'Handedness (r/l)']
    if askResponseMode:
        order.append('Location answers')
    while True:
        answers = {'Participant ID': '', 'Session': '1', 'Age': '', 'Gender': '', 'Handedness (r/l)': 'r'}
        if askResponseMode:
            answers['Location answers'] = ['keyboard', 'mouse']   # a list becomes a drop-down menu
        dlg = gui.DlgFromDict(dictionary=answers, title=title, order=order)
        if not dlg.OK:
            return None
        pid = str(answers['Participant ID']).strip()
        session = str(answers['Session']).strip()
        if pid != '' and pid.isalnum() and session.isdigit():
            break
        print('Please use letters and numbers only for the ID, and a number for the session.')

    digits = ''.join(ch for ch in pid if ch.isdigit())
    if digits == '':
        idNumber = sum(ord(ch) for ch in pid)
    else:
        idNumber = int(digits)

    info = {'id': pid, 'idNumber': idNumber, 'session': int(session), 'age': str(answers['Age']),
            'gender': str(answers['Gender']), 'handedness': str(answers['Handedness (r/l)'])}
    if askResponseMode:
        info['responseMode'] = str(answers['Location answers'])
    return info
