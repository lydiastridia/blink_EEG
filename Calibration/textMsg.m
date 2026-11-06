%Purpose: This function displays a message in the middle of the screen.
%Experiment: blinkEEG (based on the nonconSeq calibration)
%Date: November 2026

function textMsg(w, text, params)

DrawFormattedText(w, text, 'center', 'center', params.stim.textColor);
Screen('Flip', w);
end
