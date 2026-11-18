"""Purpose: waits until one of the letters shown on the screen is pressed.

Input:  letters   the allowed letters, e.g. ['a', 'e', 'f', ...]
Output: letter    the letter that was pressed
        RT        response time in seconds
"""
from get_key import get_key


def get_letter(letters):
    letter, RT = get_key(letters)
    return letter, RT
