%Purpose: This function initializes all of the necessary parameters for the
%calibration task (screen, timing, stimuli, staircases, trial numbers, texts).


function [params] = calibParams()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Testing
params.testMode = true; %true on my laptop: skips the Psychtoolbox timing tests and prints every trial
                        %!!!!! MUST be false in the lab (accurate 16.7 ms timing)
params.debugWindow = false; %true: semi-transparent window (for debugging only)
params.debugOpacity = 0.85;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Screen
screens = Screen('screens'); %returns an array of screenNumbers

if any(screens == 1)
    params.screenToUse = 1; %second monitor (participant's screen)
else
    params.screenToUse = 0; %main screen
end

params.screen.res = Screen(params.screenToUse, 'resolution');

if params.screen.res.hz == 0 %some laptops do not report their refresh rate
    params.screen.res.hz = 60;
    disp('Refresh rate not reported by this screen: 60 Hz assumed.');
end

if params.screen.res.hz ~= 60
    disp('WARNING! Incorrect refresh rate!');
end

params.screen.bgColor = [1 1 1]; %near-black background

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Timing expressed in seconds
params.stiming.initFix = 0.5;
params.stiming.target = 0.01667;
params.stiming.ISI = 0.01667;
params.stiming.mask = 0.233;
params.stiming.ITI = [0.3333 : 0.0833 : 0.6666]; %5 possible values, one is chosen at random per trial
%No time limit for the visibility rating: the task waits until a key 1-4 is pressed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Timing expressed in refresh rate (aka: 16.67ms at 60 Hz)
params.timing.refreshRate = 1 / params.screen.res.hz; %duration of one frame in seconds
params.timing.offset = 0.002; %to be subtracted from actual presentation times to ensure accurate timing (original code)
params.timing.initFix = round(params.stiming.initFix / params.timing.refreshRate); %30 frames
params.timing.target = round(params.stiming.target / params.timing.refreshRate); %1 frame
params.timing.ISI = round(params.stiming.ISI / params.timing.refreshRate); %1 frame
params.timing.mask = round(params.stiming.mask / params.timing.refreshRate); %14 frames

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stimuli (sizes in pixels)
params.stim.textColor = [250 250 250];
params.stim.textSize = 28;
params.stim.fixColor = [255 255 255];
params.stim.fixSize = 10; %half-length of each line of the fixation cross
params.stim.fixLineWidth = 6;

params.stim.targetSize = 16;
params.stim.targetPositions = 16;
params.stim.targetRadius = 200; %distance of the positions from the center of the screen
params.stim.targetContrast = 0.35;
params.stim.targetColor = [255 * params.stim.targetContrast, 255 * params.stim.targetContrast, 255 * params.stim.targetContrast];

params.stim.maskRectLength = 12; %each mask element is a small rectangle of 16 x 12 pixels
params.stim.maskRectWidth = 16;
params.stim.maskSpace = 9; %distance from the target center to a mask element

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Trials
%Target-present trials = targetPositions x nTrialsPerPosition.
%All trials are shuffled together, as in the original code.
params.trials.nTrialsPerPosition = 5; %16 x 5 = 80 target-present trials
params.trials.propAbsent = 0.2; %20% target-absent trials -> 20 (100 trials in total)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calibration
params.cal.startContrast = [0.95 0.05]; %starting mask contrasts of staircase a and staircase b
params.cal.bigStep = 0.2; %step at the start ...
params.cal.smallStep = 0.05; %... and after enough reversals
params.cal.nReversalsSmallStep = 2; %manuscript: small steps "as soon as there had been at least
                                    %three switches" (original code: 2)
params.cal.reversalAtBounds = true; %original code: a trial at mask contrast 0 or 1 also counts as
                                    %a reversal (manuscript: only switches seen <-> unseen -> false)
params.cal.nReversalsUsed = 4; %threshold = mean mask contrast at the last 4 reversals
params.cal.nReversalsMax = 16; %only for a message at the end: did each staircase reach 16 reversals? (original code)

%Mask contrasts for the main task, derived from the threshold
params.cal.factorUnseen = 1.5; %non-conscious blocks: threshold increased by 50%
params.cal.factorSeen = 0.5; %conscious blocks: threshold decreased by 50%

%Practice trials before the calibration (fixed mask contrasts, not part of the staircases)
params.cal.practiceContrasts = [0.03 0.03 0.03 0.1 0.1 0.1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Keys
params.keys.continue = 'space';
params.keys.abort = 'ESCAPE';
params.keys.unseen = {'1'}; %rating 1 = unseen
params.keys.seen = {'2', '3', '4'}; %ratings 2-4 = seen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Text input
params.text.inst = ['In this task, a small grey square may flash very briefly\n' ...
    'at one of several positions around the central cross.\n' ...
    'Right after it, a pattern of small rectangles appears.\n\n' ...
    'On some trials there is no square at all.\n\n' ...
    'After each flash, rate how well you saw the square:\n\n' ...
    '1 = I did not see anything\n' ...
    '2 = I saw a brief glimpse, but I am not sure\n' ...
    '3 = I saw the square, but only weakly\n' ...
    '4 = I clearly saw the square\n\n' ...
    'Press 1 only if you had no impression at all.\n\n' ...
    'Please keep your eyes on the central cross.\n\n' ...
    'Press SPACE to continue.'];
params.text.practice = ['Practice\n\n' ...
    'A few practice trials at normal speed.\n' ...
    'Answer with the keys 1 to 4.\n\n' ...
    'Press SPACE to start.'];
params.text.start = ['The task now starts.\n\n' ...
    'It takes about 5 minutes.\n' ...
    'Keep your eyes on the central cross.\n\n' ...
    'Press SPACE to start.'];
params.text.vis = 'Seen?\n\n1   2   3   4';
params.text.prog = ['Thank you! This part is finished.\n\n' ...
    'Please wait for the experimenter.'];

%Example trial (one text per step)
params.text.example1 = ['Example trial\n\n' ...
    'Keep your eyes on this cross.\n\n(SPACE)'];
params.text.example2 = ['This is the square you are looking for (circled here).\n' ...
    'It flashes at ONE of the positions around the cross,\n' ...
    'for only a fraction of a second.\n\n(SPACE)'];
params.text.example3 = ['Right after the square, these rectangles appear\n' ...
    'around ALL positions. They are NOT the square:\n' ...
    'they can make the square hard to see.\n\n(SPACE)'];
params.text.example4 = ['Here both are shown together: the square sits in the gap\n' ...
    'between four rectangles. In the real task the square comes\n' ...
    'first and disappears before the rectangles appear.\n\n(SPACE)'];
params.text.example5 = ['Then you rate how well you saw the square:\n\n' ...
    '1 = I did not see anything\n' ...
    '2 = I saw a brief glimpse, but I am not sure\n' ...
    '3 = I saw the square, but only weakly\n' ...
    '4 = I clearly saw the square\n\n(SPACE)'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data folder: "Data/Calibration" inside this repository folder
repoRoot = fileparts(fileparts(mfilename('fullpath')));
params.path.data = fullfile(repoRoot, 'Data', 'Calibration');
end
