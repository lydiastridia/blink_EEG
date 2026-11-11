%Purpose: This function shows one trial of the learning phase on the screen:
%fixation (1 s) -> T1 (1 frame) -> ISI (1 frame) -> mask (233 ms)
%-> fixation (1 s) -> T2 (1 frame) -> [ISI -> mask, only if params.learn.maskT2 is true]
%-> delay with fixation (2 s)
%When a target is missing (position 0), only the fixation cross is shown instead.
%The questions come afterwards, in a separate function.
%Durations are counted in screen frames (params.timing).
%
%Input:
%   trial         one trial from the trial list (T1position, T2position, ...)
%   maskColor     mask color in this miniblock ([255*contrast 255*contrast 255*contrast])
%Output:
%   result        when each event appeared on the screen (to check the timing afterwards)

function [result] = runLearningTrial(w, params, positions, maskPos, trial, maskColor)

frameDuration = params.timing.refreshRate;

%Fixation
drawFixation(w, params);
fixOnset = Screen('Flip', w);

%T1 (when T1 is missing only the fixation cross is shown)
drawFixation(w, params);
if trial.T1position > 0
    drawTarget(w, params, positions, trial.T1position);
end
T1Onset = Screen('Flip', w, fixOnset + (params.timing.initFix - 0.5) * frameDuration);

%ISI
drawFixation(w, params);
ISI1Onset = Screen('Flip', w, T1Onset + (params.timing.target - 0.5) * frameDuration);

%Mask
drawFixation(w, params);
drawMask(w, maskPos, maskColor);
mask1Onset = Screen('Flip', w, ISI1Onset + (params.timing.ISI - 0.5) * frameDuration);

%Fixation between the mask and T2
drawFixation(w, params);
blankOnset = Screen('Flip', w, mask1Onset + (params.timing.mask - 0.5) * frameDuration);

%T2 (when T2 is missing only the fixation cross is shown)
drawFixation(w, params);
if trial.T2position > 0
    drawTarget(w, params, positions, trial.T2position);
end
T2Onset = Screen('Flip', w, blankOnset + (params.timing.blank - 0.5) * frameDuration);

if params.learn.maskT2
    %ISI
    drawFixation(w, params);
    ISI2Onset = Screen('Flip', w, T2Onset + (params.timing.target - 0.5) * frameDuration);

    %Mask
    drawFixation(w, params);
    drawMask(w, maskPos, maskColor);
    mask2Onset = Screen('Flip', w, ISI2Onset + (params.timing.ISI - 0.5) * frameDuration);

    %Delay (fixation cross)
    drawFixation(w, params);
    delayOnset = Screen('Flip', w, mask2Onset + (params.timing.mask - 0.5) * frameDuration);
    T2Offset = ISI2Onset; %T2 disappears when the ISI starts
    result.mask2Onset = mask2Onset - T1Onset; %should be 1.3
else
    %No mask: the delay (fixation cross) starts directly after T2
    drawFixation(w, params);
    delayOnset = Screen('Flip', w, T2Onset + (params.timing.target - 0.5) * frameDuration);
    T2Offset = delayOnset; %T2 disappears when the delay starts
    result.mask2Onset = 0; %0 = there was no second mask
end

%End of the delay: the fixation cross stays, and the function returns
drawFixation(w, params);
delayEnd = Screen('Flip', w, delayOnset + (params.timing.delay - 0.5) * frameDuration);

%Save when everything happened on this trial (times in seconds, onsets relative to T1)
result.maskColor = maskColor;
result.T1Onset = T1Onset;
result.T1Duration = ISI1Onset - T1Onset; %measured, should be 0.0167
result.mask1Onset = mask1Onset - T1Onset; %should be 0.0333
result.T2Onset = T2Onset - T1Onset; %should be 1.2667
result.T2Duration = T2Offset - T2Onset; %measured, should be 0.0167
result.delayDuration = delayEnd - delayOnset; %should be 2
end
