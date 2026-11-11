%Purpose: Main script to run the calibration task. Type runCalibration in the
%Command Window to start.
%Two interleaved staircases (a: starts with a strong mask, b: starts with a
%weak mask) look for the mask contrast at which the target is seen on about
%half of the trials (the perceptual threshold). All numbers are in calibParams.m.

%
%Output (in Data/Calibration):
%   P<nr>_S<session>_calibration.mat   all data (struct cal)
%   P<nr>_S<session>_threshold.mat     threshold + mask contrasts for the main task
%   P<nr>_S<session>_convergence.png   convergence graph (also .fig)
%   P<nr>_S<session>_summary.txt       short summary
%ESCAPE stops the task; the data collected so far are saved.

function runCalibration()

%% PREPARATION
%Load the parameters
params = calibParams();

%Enter the subject's details
info = askParticipantInfo();

%Seed the Matlab random number generator using the current time, every participant gets a different order
RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', sum(100*clock)));

%Make the data directory & warn if there is a duplicate subject ID
if ~exist(params.path.data, 'dir')
    mkdir(params.path.data);
end

fileName = sprintf('P%d_S%d', info.id, info.session);
dataFile = fullfile(params.path.data, [fileName '_calibration.mat']);
partialFile = fullfile(params.path.data, [fileName '_calibration_partial.mat']);

if exist(dataFile, 'file')
    disp('WARNING: Subject file already exists!');
    wish = input('Do you want to continue: y/n?', 's');
    if strcmp(wish, 'y')
        disp('The old file will be overwritten.');
    elseif strcmp(wish, 'n')
        return;
    else
        disp('Please answer y or n next time. Stopped.');
        return;
    end
end

KbName('UnifyKeyNames');

%Prepare the trials (and check that every position appears equally often)
trials = makeCalibTrials(params);
checkCalibTrials(trials, params);

%Start the actual experiment
disp('OK, press any key to continue ...');
pause;

%% RUN EXPERIMENT
%Initalize all important variables as well as output
nTrials = length(trials);

%Initialize all of the variables necessary for the calibration task
%Define key responses to be accepted
seenKey = params.keys.seen; %{'2', '3', '4'}
unseenKey = params.keys.unseen; %{'1'}

%Define all other parameters related to the two staircases
nReversals.a = 0; %in order to keep track of how many times direction in a given staircase is reversed
nReversals.b = 0;
reversalPosition.a = [];
reversalPosition.b = [];

maskC.a(1) = params.cal.startContrast(1); %starting mask contrasts for the two staircases
maskC.b(1) = params.cal.startContrast(2);
maskC.blank = []; %mask contrasts used on the target-absent trials
maskC.c(1) = 0; %combination of both mask contrasts to keep track of changes for target contrast
threshold.a = 0;
threshold.b = 0;

vis.a = []; %answers: 0 = unseen, 1 = seen, 2 = inadmissible
vis.b = [];
vis.blank = [];

trialNumber.a = []; %calibration trial number of each staircase trial (new: for the convergence graph)
trialNumber.b = [];

%Define all of the counters necessary
count.all = 0; %total trial number
count.a = 0;
count.b = 0;
count.blank = 0;
count.allStaircase = 0;
crosses = 0;

%Everything that is saved
cal.info = info;
cal.params = params;
cal.trials = trials;
cal.startTime = datestr(now);
cal.data = []; %one entry per calibration trial
cal.practice = []; %one entry per practice trial

%Run calibration
try
    %Initialize PTB window
    [w, rect] = openScreen(params);
    params.screen.pos.Center = floor([rect(3) rect(4)] / 2); %center of the screen in pixels

    %Determine position of elements on screen
    positions = findPositions(params);
    maskPos = prepMask(params, positions);

    %Instruction screen
    textMsg(w, params.text.inst, params);
    getKey(params.keys.continue);

    %Example trial (new)
    runExampleTrial(w, params, positions, maskPos);

    %Practice trials (new: fixed weak masks, not part of the staircases)
    textMsg(w, params.text.practice, params);
    getKey(params.keys.continue);

    for practicei = 1 : length(params.cal.practiceContrasts)
        practiceTrial.cond = 1;
        practiceTrial.tarPos = randi(params.stim.targetPositions);
        practiceTrial.ITI = params.stiming.ITI(randi(length(params.stiming.ITI)));
        practiceContrast = params.cal.practiceContrasts(practicei);
        maskColor = [255 * practiceContrast, 255 * practiceContrast, 255 * practiceContrast];
        result = runTrial(w, params, positions, maskPos, practiceTrial, maskColor);
        cal.practice = [cal.practice, result];
    end

    %Start of the calibration
    textMsg(w, params.text.start, params);
    getKey(params.keys.continue);

    textMsg(w, sprintf('3'), params);
    WaitSecs(1.0);
    textMsg(w, sprintf('2'), params);
    WaitSecs(1.0);
    textMsg(w, sprintf('1'), params);
    WaitSecs(1.0);

    %Initial fixation
    drawFixation(w, params);
    Screen('Flip', w);
    WaitSecs(1.0);

    for triali = 1 : nTrials

        %UPDATE CALIBRATION INFO
        count.all = count.all + 1; %track number of all trials

        %Determine which stair to use for this trial, depending on whether
        %target is present or absent
        if trials(triali).cond == 1 %target-present
            if randi(2) == 2
                currentStair = 'a';
            else
                currentStair = 'b';
            end

            count.(currentStair) = count.(currentStair) + 1;
            count.allStaircase = count.allStaircase + 1; %to keep track of target-absent trials

            %Determine which step size to use
            if nReversals.(currentStair) >= params.cal.nReversalsSmallStep
                stepSize.(currentStair) = params.cal.smallStep;
            else
                stepSize.(currentStair) = params.cal.bigStep;
            end
        else %target-absent
            currentStair = 'blank';

            count.(currentStair) = count.(currentStair) + 1;
            count.allStaircase = count.allStaircase + 1; %to keep track of target-absent trials

            if randi(2) == 2
                maskC.(currentStair)(count.(currentStair)) = maskC.a(end);
            else
                maskC.(currentStair)(count.(currentStair)) = maskC.b(end);
            end
        end

        maskC.c(count.allStaircase) = maskC.(currentStair)(count.(currentStair));

        %Update mask color
        maskColor = [255 * maskC.(currentStair)(count.(currentStair)), 255 * maskC.(currentStair)(count.(currentStair)), 255 * maskC.(currentStair)(count.(currentStair))]; %uses the mask contrast currently in the last position for the given stair

        disp(['Trial: ' num2str(triali)]);

        result = runTrial(w, params, positions, maskPos, trials(triali), maskColor); %run the individual trial

        %UPDATE CALIBRATION INFO 2
        %Categorize responses according to visibility
        keyVisibility = result.key;

        if ~isempty(keyVisibility)
            if ismember(keyVisibility, unseenKey) %target not seen
                vis.(currentStair)(count.(currentStair)) = 0;
            elseif ismember(keyVisibility, seenKey)
                vis.(currentStair)(count.(currentStair)) = 1;
            else
                vis.(currentStair)(count.(currentStair)) = 2; %to account for inadmissible responses
            end
        else
            vis.(currentStair)(count.(currentStair)) = 2; %to also account for missing responses
        end

        %Update mask contrast for next presentation only if target-present
        %trial
        if trials(triali).cond == 1 %target-present
            trialNumber.(currentStair)(count.(currentStair)) = triali; %for the convergence graph

            if ~isempty(keyVisibility) && ismember(keyVisibility, unseenKey)
                maskC.(currentStair)(count.(currentStair) + 1) = maskC.(currentStair)(count.(currentStair)) - stepSize.(currentStair);
            elseif ~isempty(keyVisibility) && ismember(keyVisibility, seenKey)
                maskC.(currentStair)(count.(currentStair) + 1) = maskC.(currentStair)(count.(currentStair)) + stepSize.(currentStair);
            else
                maskC.(currentStair)(count.(currentStair) + 1) = maskC.(currentStair)(count.(currentStair)); %don't change mask contrast if inadmissable response given
            end

            %Check to see if the two staircases have crossed
            if ~isempty(maskC.a) && ~isempty(maskC.b)
                if maskC.a(end) <= maskC.b(end) && crosses == 0
                    crosses = 1;
                end
            end

            %Check to see whether there are any reversals
            if count.(currentStair) > 1 && vis.(currentStair)(count.(currentStair)) < 2 && vis.(currentStair)(count.(currentStair) - 1) < 2 %aka, neither the first nor inadmissable trials
                if vis.(currentStair)(count.(currentStair)) ~= vis.(currentStair)(count.(currentStair) - 1) || ...
                        (params.cal.reversalAtBounds && (maskC.(currentStair)(count.(currentStair)) == 0 || maskC.(currentStair)(count.(currentStair)) == 1))
                    nReversals.(currentStair) = nReversals.(currentStair) + 1;
                    reversalPosition.(currentStair)(nReversals.(currentStair)) = count.(currentStair);
                    if nReversals.(currentStair) >= params.cal.nReversalsMax
                        threshold.(currentStair) = 1;
                    end
                end
            end

            %Round to 3 decimals (new: removes tiny errors such as 0.30000000004)
            maskC.(currentStair)(count.(currentStair) + 1) = round(maskC.(currentStair)(count.(currentStair) + 1) * 1000) / 1000;

            %Reset mask contrast if boundaries are reached
            if maskC.(currentStair)(count.(currentStair) + 1) < 0
                maskC.(currentStair)(count.(currentStair) + 1) = 0;
            elseif maskC.(currentStair)(count.(currentStair) + 1) > 1
                maskC.(currentStair)(count.(currentStair) + 1) = 1;
            end
        end

        %Save this trial (new)
        result.trial = triali;
        result.staircase = currentStair;
        result.maskContrast = maskC.c(count.allStaircase);
        result.vis = vis.(currentStair)(count.(currentStair));
        cal.data = [cal.data, result];

        %Print the trial in the Command Window (new, test mode only)
        if params.testMode
            disp(['   position ' num2str(trials(triali).tarPos) ' | staircase ' currentStair ...
                ' | mask ' num2str(result.maskContrast, '%.2f') ' | rating ' num2str(result.rating) ...
                ' | reversals a ' num2str(nReversals.a) ', b ' num2str(nReversals.b)]);
        end

        %Save every 10 trials, in case something goes wrong (new)
        if mod(triali, 10) == 0
            cal.count = count;
            cal.nReversals = nReversals;
            cal.maskC = maskC;
            cal.vis = vis;
            cal.reversalPosition = reversalPosition;
            cal.trialNumber = trialNumber;
            save(partialFile, 'cal');
        end
    end

    %Progress Screen
    textMsg(w, params.text.prog, params);
    WaitSecs(2.5);

    Screen('CloseAll');
    ShowCursor;
    Priority(0);

catch err
    %New: something went wrong or ESCAPE was pressed:
    %close the screen and save the data collected so far
    Screen('CloseAll');
    ShowCursor;
    Priority(0);

    cal.count = count;
    cal.nReversals = nReversals;
    cal.maskC = maskC;
    cal.vis = vis;
    cal.reversalPosition = reversalPosition;
    cal.trialNumber = trialNumber;
    save(partialFile, 'cal');
    disp(['Data so far saved in ' fileName '_calibration_partial.mat']);

    if strcmp(err.identifier, 'calib:abort')
        disp('Calibration stopped with ESCAPE.');
        return;
    else
        rethrow(err);
    end
end

%% CALCULATE THRESHOLD MASK CONTRAST
thresholdValue.a = NaN;
thresholdValue.b = NaN;
thresholdValue.c = NaN;
cal.warnings = {};

if ~isempty(reversalPosition.a) || ~isempty(reversalPosition.b)
    if nReversals.a >= params.cal.nReversalsUsed && nReversals.b >= params.cal.nReversalsUsed
        thresholdValue.a = mean(maskC.a(reversalPosition.a(end - params.cal.nReversalsUsed + 1 : end)));
        thresholdValue.b = mean(maskC.b(reversalPosition.b(end - params.cal.nReversalsUsed + 1 : end)));
        thresholdValue.c = mean([thresholdValue.a, thresholdValue.b]);
    else
        disp('WARNING: Number of reversals not met!');
        cal.warnings{end + 1} = 'Number of reversals not met!';
        thresholdValue.a = mean(maskC.a(reversalPosition.a));
        thresholdValue.b = mean(maskC.b(reversalPosition.b));
        thresholdValue.c = mean([thresholdValue.a, thresholdValue.b]);
    end
else
    disp('WARNING: No reversals at all!');
    cal.warnings{end + 1} = 'No reversals at all!';
end

if threshold.a && threshold.b
    disp('Both staircases reached the desired number of total reversals.');
elseif ~threshold.a && ~threshold.b
    disp('WARNING: Neither staircase reached the desired number of total reversals.');
else
    disp('WARNING: Only one staircase reached the desired number of total reversals.');
end

fprintf('\n=== THRESHOLD DEBUG ===\n');
fprintf('nReversals.a = %d, nReversals.b = %d (need >= %d)\n', nReversals.a, nReversals.b, params.cal.nReversalsUsed);
fprintf('length(reversalPosition.a) = %d, length(reversalPosition.b) = %d\n', length(reversalPosition.a), length(reversalPosition.b));
fprintf('reversalPosition.a = %s\n', mat2str(reversalPosition.a));
fprintf('reversalPosition.b = %s\n', mat2str(reversalPosition.b));
fprintf('maskC.a = %s\n', mat2str(maskC.a, 3));
fprintf('maskC.b = %s\n', mat2str(maskC.b, 3));
fprintf('thresholdValue.a = %s\n', mat2str(thresholdValue.a));
fprintf('thresholdValue.b = %s\n', mat2str(thresholdValue.b));
fprintf('thresholdValue.c = %s\n', mat2str(thresholdValue.c));
fprintf('========================\n\n');

%Mask contrasts for the main task (new)
contrastUnseen = thresholdValue.c * params.cal.factorUnseen; %non-conscious blocks: threshold + 50%
if contrastUnseen > 1
    contrastUnseen = 1;
end
contrastSeen = thresholdValue.c * params.cal.factorSeen; %conscious blocks: threshold - 50%

%Other warnings (new)
if abs(thresholdValue.a - thresholdValue.b) > 0.2
    cal.warnings{end + 1} = 'The two staircases ended more than 0.2 apart: look at the convergence graph.';
end

%False alarms: target-absent trials rated as seen (new)
validBlankAnswers = vis.blank(vis.blank < 2);
falseAlarmRate = mean(validBlankAnswers == 1);
if falseAlarmRate > 0.5
    cal.warnings{end + 1} = 'More than half of the target-absent trials were rated as seen.';
end

%% SAVE
%Add all info to be saved to cal structure
cal.name = fileName;
cal.count = count;
cal.nReversals = nReversals;
cal.maskC = maskC;
cal.vis = vis;
cal.reversalPosition = reversalPosition;
cal.trialNumber = trialNumber;
cal.crosses = crosses;
cal.thresholdValue = thresholdValue;
cal.contrastUnseen = contrastUnseen;
cal.contrastSeen = contrastSeen;
cal.falseAlarmRate = falseAlarmRate;
cal.endTime = datestr(now);

%Save final data
save(dataFile, 'cal');
disp([fileName '_calibration has been saved']);

%Small file for the main task (new)
threshold = thresholdValue.c;
participant = info;
save(fullfile(params.path.data, [fileName '_threshold.mat']), 'threshold', 'contrastUnseen', 'contrastSeen', 'participant');

%Convergence graph (new)
plotConvergence(cal, fullfile(params.path.data, [fileName '_convergence']));

%Summary in the Command Window and in a text file (new)
summary = {};
summary{end + 1} = ['Participant ' num2str(info.id) ', session ' num2str(info.session) ', ' cal.startTime];
summary{end + 1} = ['Threshold (mask contrast): ' num2str(thresholdValue.c, '%.3f')];
summary{end + 1} = ['  staircase a: ' num2str(thresholdValue.a, '%.3f') ' (' num2str(nReversals.a) ' reversals)'];
summary{end + 1} = ['  staircase b: ' num2str(thresholdValue.b, '%.3f') ' (' num2str(nReversals.b) ' reversals)'];
summary{end + 1} = ['Main task contrasts: non-conscious ' num2str(contrastUnseen, '%.3f') ' | conscious ' num2str(contrastSeen, '%.3f')];
summary{end + 1} = ['False alarms (seen without target): ' num2str(100 * falseAlarmRate, '%.0f') '%'];
for i = 1 : length(cal.warnings)
    summary{end + 1} = ['WARNING: ' cal.warnings{i}];
end

fid = fopen(fullfile(params.path.data, [fileName '_summary.txt']), 'w');
disp(' ');
for i = 1 : length(summary)
    disp(summary{i});
    fprintf(fid, '%s\n', summary{i});
end
fclose(fid);
disp(['Saved in: ' params.path.data]);

%The complete file is saved, so the partial file is no longer needed
if exist(partialFile, 'file')
    delete(partialFile);
end
end
