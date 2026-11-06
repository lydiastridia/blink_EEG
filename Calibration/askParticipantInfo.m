%Purpose: This function asks the participant details in the Command Window.
%A question is asked again until the answer is valid.
%(To stop: press Ctrl+C in the Command Window.)

function [info] = askParticipantInfo()

%Participant number
answerOK = false;
while ~answerOK
    info.id = str2double(input('Participant number: ', 's'));
    if isnan(info.id) || info.id < 1 || info.id ~= round(info.id)
        disp('  -> Please type a whole number only (e.g., 3).');
    else
        answerOK = true;
    end
end

%Session number
answerOK = false;
while ~answerOK
    info.session = str2double(input('Session number: ', 's'));
    if isnan(info.session) || info.session < 1 || info.session ~= round(info.session)
        disp('  -> Please type a whole number only (e.g., 1).');
    else
        answerOK = true;
    end
end

%Age
answerOK = false;
while ~answerOK
    info.age = str2double(input('Age: ', 's'));
    if isnan(info.age) || info.age < 16 || info.age > 99
        disp('  -> Please type the age in years, between 16 and 99 (e.g., 24).');
    else
        answerOK = true;
    end
end

%Gender
answerOK = false;
while ~answerOK
    info.gender = strtrim(input('Gender: ', 's'));
    if isempty(info.gender)
        disp('  -> Please type something.');
    else
        answerOK = true;
    end
end

%Handedness
answerOK = false;
while ~answerOK
    info.handedness = lower(strtrim(input('Handedness (r/l): ', 's')));
    if strcmp(info.handedness, 'r') || strcmp(info.handedness, 'l')
        answerOK = true;
    else
        disp('  -> Please type r (right) or l (left).');
    end
end

end


