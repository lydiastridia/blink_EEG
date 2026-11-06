function p = mainParams()
%MAINPARAMS  Design settings for the main task (duplets, trial numbers, triggers).
%
%   All numbers of the design are here. The trial counts are given PER
%   MINIBLOCK, so every miniblock contains every trial type in the same
%   proportions (rare trials spread evenly over the session).

%% ---------------------------------------------------------------- Ring
p.nPositions = 16;          % positions 1-16, clockwise, 1 = just right of 12 o'clock
                            % (same numbering as the calibration)

%% ---------------------------------------------------------------- Duplet rules
% Per visibility condition: 2 predictive T1s (P), their 2 T2s (R) and
% 2 control T1s (C) = 6 positions. The two conditions never share a position.
p.rule.minStepT1T2    = 2;  % every T1 at least 2 steps (45 deg) from every T2 it can precede
p.rule.minStepControl = 3;  % control T1s at least 3 steps (67.5 deg) from predictive T1s
p.rule.oppositeHemifieldT2 = true;   % the two T2s left and right (alpha lateralisation)
p.rule.allQuadrants   = true;        % the 6 positions cover all 4 quadrants
p.rule.maxDifficultyDiff = 1;        % sets for seen/unseen: total duplet distance differs <= 1 step

%% ---------------------------------------------------------------- Blocks
% Alternation of conscious and non-conscious miniblocks (point 4, still to
% decide). Now: strict alternation, starting condition counterbalanced.
p.alternate = true;

%% ---------------------------------------------------------------- Learning phase
% Per miniblock (one visibility condition), 32 trials:
p.learn.nMiniblocksPerCond = 6;
p.learn.predictivePerDuplet = 10;    % 2 duplets x 10 = 20 (always valid)
p.learn.controlPerPair      = 2;     % each control T1 x each T2 location: 2 x 2 x 2 = 8
p.learn.t1AbsentPerT2       = 2;     % T1 absent, T2 at each location: 2 x 2 = 4
% -> per condition: 120 predictive (60 per duplet), 48 control, 24 T1-absent = 192

%% ---------------------------------------------------------------- Test phase
% Per miniblock (one visibility condition), 42 trials:
p.test.nMiniblocksPerCond = 12;
p.test.validPerDuplet     = 9;       % 18 valid
p.test.deviantPerDuplet   = 3;       % 6 deviants: T1 of one duplet -> T2 of the other
p.test.omissionPerDuplet  = 5;       % 10 omissions after a predictive T1
p.test.controlPerPair     = 1;       % control T1 x T2 location: 2 x 2 = 4
p.test.controlOmissionPerControl = 1;% 2 omissions after a control T1
p.test.t1AbsentPerT2      = 1;       % 2 T1-absent trials (T2 present)
% -> per condition: 216 valid, 72 deviant, 120 omission, 48 control,
%    24 control omission, 24 T1-absent = 504

%% ---------------------------------------------------------------- Order within a miniblock
p.order.maxViolationsInRow = 2;      % deviants/omissions: never more than 2 in a row
p.order.firstTrialNoViolation = true;% a miniblock never starts with a violation
p.order.maxSameTypeInRow = 3;

%% ---------------------------------------------------------------- Trigger codes
% Seen block code; the unseen code is the seen code + 10.
p.trig.trialStart      = 10;
p.trig.t1Predictive    = 31;
p.trig.t1Control       = 32;
p.trig.t1Absent        = 33;
p.trig.mask            = 50;          % same in both conditions
p.trig.t2Valid         = 61;
p.trig.t2Deviant       = 62;
p.trig.t2Control       = 63;
p.trig.omission        = 64;          % at the moment T2 would have appeared
p.trig.controlOmission = 65;
p.trig.t2AfterT1Absent = 66;
p.trig.unseenOffset    = 10;
p.trig.rating          = 80;          % + rating (81-84)
p.trig.noResponse      = 89;
p.trig.learningStart   = 1;
p.trig.testStart       = 2;
p.trig.miniblockSeen   = 5;
p.trig.miniblockUnseen = 6;

%% ================================================================ Running the task
%% ---------------------------------------------------------------- Testing
p.testMode    = true;   % true on a laptop: skips Psychtoolbox timing tests and
                        % prints every trial. MUST be false in the lab.
p.demo        = true;   % true: short demo (first 2 miniblocks of each phase,
                        % 6 trials each). false: the full experiment.
p.demoMiniblocks = 2;
p.demoTrials     = 6;

%% ---------------------------------------------------------------- Display
% Same dark display as the calibration (original nonconSeq code).
p.bgColor         = [1 1 1];
p.fixColor        = [255 255 255];
p.textColor       = [255 255 255];
p.textSize        = 28;
p.t1Color         = [89 89 89];     % T1: grey square, masked (as in the calibration)
p.t2Color         = [200 200 200];  % T2: brighter square, never masked (clearly visible)
p.oddballColor    = [200 120 120];  % learning-phase cover task: tinted T2
p.maskColorStrong = [255 255 255];  % mask colour at contrast 1
p.radius       = 200;               % pixels (convert to degrees for the lab screen)
p.targetSize   = 16;
p.fixArm       = 10;
p.fixLineWidth = 4;
p.maskRectLong  = 16;
p.maskRectShort = 12;
p.maskGap       = 9;

%% ---------------------------------------------------------------- Timing (s)
p.tFixation = [0.5 1.0];   % jittered
p.tT1       = 1/60;        % 16.7 ms
p.tISI      = 1/60;        % 16.7 ms
p.tMask     = 0.233;
p.tSOA      = 1.2;         % T1 onset -> T2 onset (delay period for anticipation)
p.tT2       = 0.05;        % 50 ms, unmasked
p.tPostT2   = 0.8;         % blank after T2: EEG response window (and cover-task responses)
p.tRespMax  = 3.3;         % visibility rating of T1
p.tITI      = [0.333 0.666];

%% ---------------------------------------------------------------- Responses
% Point 7 (what participants answer) is still open. Defaults:
% - every trial: delayed rating of T1 visibility (1-4), to verify that T1
%   was unseen in non-conscious blocks;
% - learning phase only: cover task, press SPACE when T2 is tinted.
p.oddballProp = 0.2;       % share of learning trials with a tinted T2

%% ---------------------------------------------------------------- Mask contrast
% Fixed per visibility condition, read from the calibration file
% P<nr>_S<session>_threshold.mat.

%% ---------------------------------------------------------------- Keys
p.continueKey = 'space';
p.oddballKey  = 'space';
p.abortKey    = 'ESCAPE';

%% ---------------------------------------------------------------- EEG triggers
p.trigMode    = 'none';    % 'none' (laptop: printed in test mode) or 'serial' (TriggerBox)
p.trigPort    = 'COM3';    % TriggerBox port in the lab (ask the lab)
p.trigPulse   = 0.010;     % trigger held for 10 ms, then reset to 0

%% ---------------------------------------------------------------- Files
repoRoot      = fileparts(fileparts(mfilename('fullpath')));
p.calibDir    = fullfile(repoRoot, 'Data', 'Calibration');
p.dataDir     = fullfile(repoRoot, 'Data', 'MainTask');
end
