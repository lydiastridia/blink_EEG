function triggerClose(trig)
%TRIGGERCLOSE  Resets and closes the trigger port (if one is open).
if strcmp(trig.mode, 'serial') && ~isempty(trig.h)
    IOPort('Write', trig.h, uint8(255), 0);   % TriggerBox resting state
    IOPort('Close', trig.h);
end
end
