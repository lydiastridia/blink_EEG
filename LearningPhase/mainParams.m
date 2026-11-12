% This function initializes the parameters of the main task

function [params] = mainParams()

% Start from the calibration settings, so that the screen, the target and the
% mask are exactly the same as in the calibration (otherwise the threshold
% from the calibration would not be valid for this task)
thisFolder = fileparts(mfilename('fullpath')); %the folder of this file (LearningPhase)
addpath(fullfile(thisFolder, '..', 'Calibration')); %so that MATLAB finds the calibration functions
params = calibParams();

% This shows the trial kinds within one miniblock

params.design.kinds = {'duplet1', 'duplet1','duplet2', 'duplet2', 'control1', 'control2', 'targetAbsent'};

%Target-absent trials -> I followed the manuscript for this, making it a flip-a-coin between
% which target is missing

params.design.propT1absent = 0.5;

% Number of trials in the learning phase
% trials / miniblock = n^2+1 => 50 if we settle on 7 kinds (4 duplets, 2 controls and 1 target)
% total number of trials = nr of cond x nr of miniblocks per cond x nr of trials per miniblock
% when we want to adjust the nr of trials, all we need to change is how many mini blocks we have per condition
% => the values will always increase in a step of 2 x 50

params.learn.nMiniblocksPerVis = 2; 

%% Positions
params.pos.nPositions = 16; %positions on the circle (22.5 degrees apart)
%Jump sizes from T1 to T2 for the two duplets of a set, in positions
%(1 position = 22.5 degrees): [3 6] = 67.5 and 135 degrees, [2 7] = 45 and 157.5 degrees
params.pos.jumpsA = [3 6];
params.pos.jumpsB = [2 7];
%Rule 5 (to be decided): T2 locations left and right, both duplet T1s on the same side
params.pos.leftRightRule = true;

%% Timing of a trial (in seconds)
% target (16.7 ms), ISI (16.7 ms), mask (233 ms) and ITI come from calibParams
params.stiming.initFix = 1; %fixation cross at the start of a trial (manuscript: 1 s)
params.stiming.blank = 1; %fixation between the first mask and T2 (manuscript: 1 s)
params.stiming.delay = 2; %fixation after T2, before the questions (manuscript: 2 s)

% The same in frames (1 frame = 16.7 ms at 60 Hz)
params.timing.initFix = round(params.stiming.initFix / params.timing.refreshRate); %60 frames
params.timing.blank = round(params.stiming.blank / params.timing.refreshRate); %60 frames
params.timing.delay = round(params.stiming.delay / params.timing.refreshRate); %120 frames

%% Is T2 followed by a mask?
% false = T2 is shown without a mask (my design: T2 is always visible)
% true = T2 is followed by the same mask as T1 (as in the manuscript)
params.learn.maskT2 = false;

%% Questions after each trial (letter version of the original code)
params.stim.letters = 'aefgiklmorsuwxyz'; %16 letters, one per position; shuffled on every trial
params.stim.letterSize = 35; %text size of the letters
params.text.loc1 = '1?'; %shown in the centre: where was target 1?
params.text.loc2 = '2?'; %where was target 2?
params.text.vis1 = 'Seen 1?\n\n1   2   3   4';
params.text.vis2 = 'Seen 2?\n\n1   2   3   4';
params.stiming.afterResponse = 0.35; %short wait after each answer (original code)

%% Mask contrast correction during the task (original code)
% When the ratings do not fit the miniblock (seen miniblock: rating 1;
% unseen miniblock: rating 2, 3 or 4), the mask contrast is changed a little
params.learn.nWrongAllowed = 2; %after this many "wrong" ratings the mask contrast is corrected
params.learn.correctionSeen = 0.95; %seen miniblocks: mask contrast decreased by 5% (manuscript; original code: 0.9)
params.learn.correctionUnseen = 1.05; %unseen miniblocks: mask contrast increased by 5% (manuscript and original code)

%% Texts of the learning phase
params.text.learnInst = ['In this task, two small grey squares flash one after the other,\n' ...
    'each at one of the positions around the central cross.\n' ...
    'Sometimes one of the two squares is missing.\n\n' ...
    'After each trial you answer four questions:\n\n' ...
    '1?  Where was the first square? Type the letter shown at its position.\n' ...
    '2?  Where was the second square? Type the letter shown at its position.\n' ...
    'Seen 1?  How well did you see the first square (1 to 4)?\n' ...
    'Seen 2?  How well did you see the second square (1 to 4)?\n\n' ...
    'If you did not see a square, follow your gut feeling and guess its position.\n' ...
    'Press 1 only if you had no impression at all.\n\n' ...
    'Please keep your eyes on the central cross.\n\n' ...
    'Press SPACE to continue.'];
params.text.seenBlock = ['In this block, you will be able to see the targets.\n' ...
    'Do your best to identify the locations correctly afterwards.\n\n' ...
    'Press SPACE to start.'];
params.text.unseenBlock = ['In this block, you will probably not see the targets.\n' ...
    'Do not get frustrated by this, it happens on purpose!\n' ...
    'Please try your best to guess the location.\n\n' ...
    'Press SPACE to start.'];
params.text.break = 'Good job! Remaining number of blocks: %d\n\nTake a short break.\n\nPress SPACE to continue.';
params.text.learnEnd = ['Thank you! This part is finished.\n\n' ...
    'Please wait for the experimenter.'];

%% Data folder: "Data/LearningPhase" inside this repository folder
repoRoot = fileparts(thisFolder);
params.path.learning = fullfile(repoRoot, 'Data', 'LearningPhase');

%% Test phase: like the learning phase, plus deviant trials
% deviant = T1 of a duplet, but T2 at the location of the other duplet
params.test.kinds = {'duplet1', 'duplet1', 'duplet2', 'duplet2', 'control1', 'control2', 'deviant', 'targetAbsent'};
params.test.nMiniblocksPerVis = 1; %miniblocks per visibility in the test phase (8 x 8 + 1 = 65 trials each)
params.text.testInst = ['The task continues in the same way as before.\n\n' ...
    'Press SPACE to continue.'];
params.path.test = fullfile(repoRoot, 'Data', 'TestPhase');

end
