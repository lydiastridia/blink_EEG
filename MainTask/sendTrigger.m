function sendTrigger(trig, code)
%SENDTRIGGER  Sends one EEG trigger (1-254).
%
%   sendTrigger(trig, code)   Call it right after the Screen('Flip') that
%   shows the event, so the marker matches the moment the stimulus appears.
%   In 'serial' mode the code is held for trig.pulse seconds, then reset to 0
%   (TriggerBox programming examples, Brain Products). 255 is the TriggerBox's
%   resting value and is not used as a code.

if code < 1 || code > 254
    error('sendTrigger:code', 'Trigger codes must be 1-254 (got %d).', code);
end
switch trig.mode
    case 'serial'
        IOPort('Write', trig.h, uint8(code), 0);
        WaitSecs(trig.pulse);
        IOPort('Write', trig.h, uint8(0), 0);
end
if trig.print
    fprintf('    trigger %3d\n', code);
end
end
