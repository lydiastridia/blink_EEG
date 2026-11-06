%waits for the visibility ratings 1-4 and returns which key was pressed + RT in case we will later analyse this too

function [key, rating, RT] = getRating(params)

ratingKeys = {'1', '2', '3', '4'};
tStart = GetSecs;

while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        keyNames = KbName(keyCode); %e.g., '1!' for the top row, '1' for the number pad
        if ~iscell(keyNames)
            keyNames = {keyNames};
        end

        if ismember(params.keys.abort, keyNames)
            error('calib:abort', 'Stopped with ESCAPE.');
        end

        %Check every key that is down: is it 1, 2, 3 or 4?
        for i = 1 : length(keyNames)
            keyname = keyNames{i};
            if ~isempty(keyname)
                firstCharacter = keyname(1); %'1!' -> '1'
                if ismember(firstCharacter, ratingKeys)
                    key = firstCharacter;
                    rating = str2double(firstCharacter);
                    RT = secs - tStart;
                    return
                end
            end
        end
    end
    WaitSecs(0.001);
end
end
