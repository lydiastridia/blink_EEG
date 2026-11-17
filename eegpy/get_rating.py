"""Purpose: waits for a visibility rating: 1, 2, 3 or 4 (top row or number pad).

Output: rating   1, 2, 3 or 4
        RT       response time in seconds
"""
from get_key import get_key


def get_rating():
    key, RT = get_key(['1', '2', '3', '4', 'num_1', 'num_2', 'num_3', 'num_4'])
    rating = int(key[-1])  # '3' and 'num_3' both end with 3
    return rating, RT
