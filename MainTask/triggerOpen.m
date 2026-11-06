function trig = triggerOpen(p)
%TRIGGEROPEN  Prepares sending EEG triggers.
%
%   trig = triggerOpen(p)
%   p.trigMode = 'none'   : no hardware; in test mode every trigger is printed
%                           in the Command Window (to check codes and order).
%   p.trigMode = 'serial' : Brain Products TriggerBox on p.trigPort (e.g. 'COM3'),
%                           opened with Psychtoolbox's IOPort.

trig.mode  = p.trigMode;
trig.pulse = p.trigPulse;
trig.print = p.testMode;
trig.h     = [];
switch trig.mode
    case 'none'
    case 'serial'
        trig.h = IOPort('OpenSerialPort', p.trigPort);
        IOPort('Write', trig.h, uint8(0), 0);           % all lines low
    otherwise
        error('triggerOpen:mode', 'Unknown trigger mode "%s".', trig.mode);
end
end
