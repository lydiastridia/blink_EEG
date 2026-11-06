%Purpose: This function draws the grey target square at position tarPos.
%It appears at the next Screen('Flip').


function drawTarget(w, params, positions, tarPos)

halfSize = params.stim.targetSize / 2;
x = positions.x(tarPos);
y = positions.y(tarPos);

targetRect = [x - halfSize, y - halfSize, x + halfSize, y + halfSize]; %[left top right bottom]
Screen('FillRect', w, params.stim.targetColor, targetRect);
end
