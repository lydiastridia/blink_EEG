"""Purpose: jump from T1 to T2 in positions, the shorter way round (as in the original generator):
+ = clockwise, - = counter-clockwise; half a circle (180 degrees) counts as -8.

Input:  t1, t2   positions 1-16
        n        number of positions (16)
Output: jump     -8 to +7 (1 position = 22.5 degrees)
"""

def jump_size(t1, t2, n=16):
    return (t2 - t1 + n // 2) % n - n // 2
