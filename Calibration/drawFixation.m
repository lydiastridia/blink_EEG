%Purpose: This function draws the fixation cross. It appears at the next


function drawFixation(w, params)

x = params.screen.pos.Center(1);
y = params.screen.pos.Center(2);
crossLength = params.stim.fixSize;

Screen('DrawLine', w, params.stim.fixColor, x - crossLength, y, x + crossLength, y, params.stim.fixLineWidth); %horizontal line
Screen('DrawLine', w, params.stim.fixColor, x, y - crossLength, x, y + crossLength, params.stim.fixLineWidth); %vertical line
end
