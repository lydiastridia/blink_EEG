%This script waits until a user presses a specified key.
%Usage: getKey('space'). ESCAPE stops the calibration.
%Based on the original code, with two additions:
%   1. ESCAPE stops the calibration so I don't throw my laptop out of the window
%   2. it first waits until all keys are released, so that one key press is
%      not counted on several screens in a row (e.g., the example trial)

function getKey(key)

KbReleaseWait; %wait until all keys are released (addition 2)

while 1
    while 1 %this just makes this loop infinite, as the boolean statement "1" is always true
        [keyIsDown, secs, keyCode] = KbCheck; %returns keyboard status (keyIsDown), time (secs) of the status check, and keyboard scan code
        if keyIsDown
            break
        end
    end
    theAnswer = KbName(keyCode); %looks up the identity of the key pressed
    if ismember('ESCAPE', theAnswer) %ESCAPE stops the calibration (addition 1)
        error('calib:abort', 'Stopped with ESCAPE.');
    end
    if ismember(key, theAnswer)
        break
    end
end
end
