"""Purpose: the error that is raised when ESCAPE is pressed.
The run scripts catch it, close the screen and save the data collected so far."""


class AbortExperiment(Exception):
    pass
