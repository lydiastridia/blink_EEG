% This function asks the fourquestions after a trial and then shows the ITI

%   1. where was target 1?  (16 letters on the circle and '1?', the participant types a letter)
%   2. where was target 2?  (the same letters and '2?')
%   3. 'Seen 1?'            (keys 1-4)
%   4. 'Seen 2?'            (keys 1-4)
%The letters are shuffled on every trial, so the participant cannot prepare
%a key press before the letters appear. There is no time limit.
%
%Input:
%   trial         one trial from the trial list (T1position, T2position, ...)
%Output:
%   result        the answers and response times of this trial

function [result] = runQuestions(w, params, positions, trial)

nPositions = params.stim.targetPositions;

%Shuffle the letters: letters(3) is the letter shown at position 3
letters = params.stim.letters(randperm(nPositions));
centreTexts = {params.text.loc1, params.text.loc2};

%% Questions 1 and 2: where was target 1, where was target 2?
for targeti = 1 : 2

    %Draw one letter at every position, and '1?' or '2?' in the centre
    Screen('TextSize', w, params.stim.letterSize);
    for posi = 1 : nPositions
        x = positions.x(posi);
        y = positions.y(posi);
        letterRect = [x - 30, y - 30, x + 30, y + 30]; %the letter is centred in this square
        DrawFormattedText(w, letters(posi), 'center', 'center', params.stim.textColor, [], [], [], [], [], letterRect);
    end
    DrawFormattedText(w, centreTexts{targeti}, 'center', 'center', params.stim.textColor);
    Screen('Flip', w);

    %Wait for a letter and find the position where this letter was shown
    [letter, RT] = getLetter(params, letters);
    answerPosition = find(letters == letter);

    if targeti == 1
        result.T1letter = letter;
        result.T1answer = answerPosition;
        result.T1answerRT = RT;
    else
        result.T2letter = letter;
        result.T2answer = answerPosition;
        result.T2answerRT = RT;
    end

    WaitSecs(params.stiming.afterResponse);
end

%% Questions 3 and 4: visibility of target 1 and of target 2
Screen('TextSize', w, params.stim.textSize); %back to the normal text size

DrawFormattedText(w, params.text.vis1, 'center', 'center', params.stim.textColor);
Screen('Flip', w);
KbReleaseWait;
[key, rating, RT] = getRating(params);
result.T1visibility = rating;
result.T1visibilityRT = RT;
WaitSecs(params.stiming.afterResponse);

DrawFormattedText(w, params.text.vis2, 'center', 'center', params.stim.textColor);
Screen('Flip', w);
KbReleaseWait;
[key, rating, RT] = getRating(params);
result.T2visibility = rating;
result.T2visibilityRT = RT;

%% ITI (fixation cross): one of the 5 possible durations, chosen at random
ITI = params.stiming.ITI(randi(length(params.stiming.ITI)));
drawFixation(w, params);
Screen('Flip', w);
WaitSecs(ITI);
KbReleaseWait; %make sure the last key was released before the next trial

%% Were the location answers correct? (NaN = this target was not shown)
if trial.T1position > 0
    result.T1correct = (result.T1answer == trial.T1position);
else
    result.T1correct = NaN;
end

if trial.T2position > 0
    result.T2correct = (result.T2answer == trial.T2position);
else
    result.T2correct = NaN;
end

result.letters = letters;
result.ITI = ITI;
end
