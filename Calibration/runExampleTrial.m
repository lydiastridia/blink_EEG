%Purpose: This function shows a slow example trial with explanations
%(SPACE moves on). The square and the mask stay on the screen, and a red
%circle shows the square, so participants know exactly what to look for.
%The texts are in calibParams.m (params.text.example1 to example5).
%Experiment: blinkEEG
%Date: November 2026

function runExampleTrial(w, params, positions, maskPos)

tarPos = 3; %position used in the example
exampleContrast = 0.6; %clearly visible mask, for the example only
exampleColor = [255 * exampleContrast, 255 * exampleContrast, 255 * exampleContrast];
textY = params.screen.pos.Center(2) + params.stim.targetRadius + 60; %text below the circle

%Red circle around the target
circleRadius = params.stim.maskSpace + params.stim.maskRectLength + 8;
circleRect = [positions.x(tarPos) - circleRadius, positions.y(tarPos) - circleRadius, ...
    positions.x(tarPos) + circleRadius, positions.y(tarPos) + circleRadius];

%1. Fixation
drawFixation(w, params);
DrawFormattedText(w, params.text.example1, 'center', params.screen.pos.Center(2) + 60, params.stim.textColor);
Screen('Flip', w);
getKey(params.keys.continue);

%2. The square
drawFixation(w, params);
drawTarget(w, params, positions, tarPos);
Screen('FrameOval', w, [220 0 0], circleRect, 3);
DrawFormattedText(w, params.text.example2, 'center', textY, params.stim.textColor);
Screen('Flip', w);
getKey(params.keys.continue);

%3. The mask
drawFixation(w, params);
drawMask(w, maskPos, exampleColor);
DrawFormattedText(w, params.text.example3, 'center', textY, params.stim.textColor);
Screen('Flip', w);
getKey(params.keys.continue);

%4. Both together
drawFixation(w, params);
drawTarget(w, params, positions, tarPos);
drawMask(w, maskPos, exampleColor);
Screen('FrameOval', w, [220 0 0], circleRect, 3);
DrawFormattedText(w, params.text.example4, 'center', textY, params.stim.textColor);
Screen('Flip', w);
getKey(params.keys.continue);

%5. The rating
textMsg(w, params.text.example5, params);
getKey(params.keys.continue);
end
