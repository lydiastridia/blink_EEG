"""Purpose: closes the window and shows the mouse cursor again.

Input:  D   screen (open_screen)
"""


def close_screen(D):
    D['win'].mouseVisible = True
    D['win'].close()
