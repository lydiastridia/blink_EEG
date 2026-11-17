"""Purpose: shows a text in the centre of the screen (instructions, questions, breaks).

Input:  D      screen with stimuli (prep_stimuli)
        text   the text; '\n' starts a new line
"""


def text_msg(D, text):
    D['text'].text = text
    D['text'].draw()
    D['win'].flip()
