%Purpose: This function runs one calibration trial:
%fixation (0.5 s) -> target (1 frame; nothing on target-absent trials)
%-> ISI (1 frame) -> mask (233 ms) -> "Seen?" until a key 1-4 -> ITI
%Durations are counted in screen frames (params.timing, from calibParams).
%Experiment: blinkEEG (based on the nonconSeq calibration)
%Date: November 2026
%
%Input:
%   trial         one trial from makeCalibTrials (cond, tarPos, ITI)
%   maskColor     mask color on this trial ([255*contrast 255*contrast 255*contrast])
%Output:
%   result        what happened on this trial (rating, RT, timing, ...)

function [result] = runTrial(w, params, positions, maskPos, trial, maskColor)

frameDuration = params.timing.refreshRate;

%Fixation
drawFixation(w, params);
fixOnset = Screen('Flip', w);

%Target (on target-absent trials only the fixation cross is shown)
drawFixation(w, params);
if trial.cond == 1
    drawTarget(w, params, positions, trial.tarPos);
end
targetOnset = Screen('Flip', w, fixOnset + params.timing.initFix * frameDuration - params.timing.offset);

%ISI
drawFixation(w, params);
ISIOnset = Screen('Flip', w, targetOnset + params.timing.target * frameDuration - params.timing.offset);

%Mask
drawFixation(w, params);
drawMask(w, maskPos, maskColor);
maskOnset = Screen('Flip', w, ISIOnset + params.timing.ISI * frameDuration - params.timing.offset);

%Visibility question
DrawFormattedText(w, params.text.vis, 'center', 'center', params.stim.textColor);
Screen('Flip', w, maskOnset + params.timing.mask * frameDuration - params.timing.offset);
[key, rating, RT] = getRating(params);

%ITI (fixation cross)
drawFixation(w, params);
Screen('Flip', w);
WaitSecs(trial.ITI);
KbReleaseWait; %make sure the rating key was released before the next trial

%Save what happened on this trial
result.cond = trial.cond;
result.tarPos = trial.tarPos;
result.maskColor = maskColor;
result.key = key;
result.rating = rating;
result.RT = RT;
result.ITI = trial.ITI;
result.targetDuration = ISIOnset - targetOnset; %measured, to check the timing afterwards
end
