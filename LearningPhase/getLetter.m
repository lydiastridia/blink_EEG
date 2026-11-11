% This function waits until the participant presses one of the letters corresponding to the locations, like in the original code
%other keys are ignored, but ESC stops the task

function [letter, RT] = getLetter(params, letters)

KbReleaseWait; %waits until all keys are released so that previous answer is not counted again
tStart = GetSecs;

while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        keyNames = KbName(keyCode); %name of the key that is down, e.g. 'a'
        if ~iscell(keyNames)
            keyNames = {keyNames};
        end

        if ismember(params.keys.abort, keyNames)
            error('calib:abort', 'Stopped with ESCAPE.');
        end

        %Check every key that is down: is it one of the letters?
        for i = 1 : length(keyNames)
            keyname = keyNames{i};
            if length(keyname) == 1 %a letter key has a name of one character
                if ismember(keyname, letters)
                    letter = keyname;
                    RT = secs - tStart;
                    return
                end
            end
        end
    end
    WaitSecs(0.001);
end
end
