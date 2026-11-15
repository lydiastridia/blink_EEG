"""Test phase (PsychoPy version of runTest.m): the learning phase plus deviant trials.
Run the learning phase first, with the same participant ID and session."""
from common import run_main_task
from params import get_params

if __name__ == '__main__':
    run_main_task(get_params(), 'test')
