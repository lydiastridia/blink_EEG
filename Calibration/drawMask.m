%Purpose: This function draws the mask around all positions. It appears at
%the next Screen('Flip').
%The mask color is computed in runCalibration, as in the original code:
%mask color = mask contrast x 255 (contrast 0 = black, invisible on the
%background; contrast 1 = white, strongest mask).

function drawMask(w, maskPos, maskColor)

Screen('FillRect', w, maskColor, maskPos);
end
