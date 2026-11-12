%Purpose: Main script to run the test phase. Type runTest in the Command
%Window to start. The test phase is the learning phase plus deviant trials
%(T1 of a duplet, T2 at the location of the other duplet). It uses the same
%functions as the learning phase (folder LearningPhase) and the same positions.
%The learning phase must have been run before for the same participant and session.
%All numbers are in mainParams.m (params.test).
%
%Output (in Data/TestPhase):
%   P<id>_S<session>_test.mat     all data (struct testData)
%ESCAPE stops the task; the data collected so far are saved.

function runTest()

%% PREPARATION
%The functions of the learning phase are used here as well
thisFolder = fileparts(mfilename('fullpath')); %the folder of this file (TestPhase)
addpath(fullfile(thisFolder, '..', 'LearningPhase'));

%Load the parameters
params = mainParams();

%Use the trial kinds and the number of miniblocks of the test phase
params.design.kinds = params.test.kinds;
params.learn.nMiniblocksPerVis = params.test.nMiniblocksPerVis;

%Enter the subject's details
info = askParticipantInfo();

%Seed the Matlab random number generator using the current time
RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', sum(100*clock)));

%Make the data directory & warn if there is a duplicate subject ID
if ~exist(params.path.test, 'dir')
    mkdir(params.path.test);
end

fileName = sprintf('P%s_S%d', info.id, info.session);
dataFile = fullfile(params.path.test, [fileName '_test.mat']);
partialFile = fullfile(params.path.test, [fileName '_test_partial.mat']);
learningFile = fullfile(params.path.learning, [fileName '_learning.mat']);
positionFile = fullfile(params.path.learning, sprintf('P%s_positions.mat', info.id));

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

%Mask contrasts: continue with the contrasts at the end of the learning phase.
%If there is no learning file, the contrasts from the calibration are used.
maskContrast = loadThreshold(info.id, info.session);
if exist(learningFile, 'file')
    tmp = load(learningFile);
    contrast = tmp.learn.contrastNow;
    disp('Mask contrasts taken from the end of the learning phase:');
    disp(['   seen miniblocks: ' num2str(contrast.seen, '%.3f') ', unseen miniblocks: ' num2str(contrast.unseen, '%.3f')]);
else
    disp('WARNING: no learning file found for this participant and session!');
    disp('The mask contrasts from the calibration are used.');
    contrast.seen = maskContrast.seen; %weak mask
    contrast.unseen = maskContrast.unseen; %strong mask
end

%Positions of this participant: the same as in the learning phase
if exist(positionFile, 'file')
    tmp = load(positionFile);
    pos = tmp.pos;
    disp('Positions of this participant loaded.');
else
    error('No positions found for this participant. Run the learning phase first (runLearning).');
end

%Prepare the trials (and check them)
trials = makeLearningTrials(params, info.idNumber);
trials = addTargets(trials, params);
checkLearningTrials(trials, params);
trials = addPositions(trials, pos);

%Start the actual experiment
disp('OK, press any key to continue ...');
pause;

%% RUN EXPERIMENT
nTrials = length(trials);
nMiniblocks = max([trials.Miniblock_no]);

%Everything that is saved
testData.info = info;
testData.params = params;
testData.pos = pos;
testData.maskContrast = maskContrast;
testData.startTime = datestr(now);
testData.timing = []; %one entry per trial: when everything appeared (from runLearningTrial)
testData.answers = []; %one entry per trial: the answers (from runQuestions)

try
    %Initialize PTB window
    [w, rect] = openScreen(params);
    params.screen.pos.Center = floor([rect(3) rect(4)] / 2); %center of the screen in pixels

    %Determine position of elements on screen
    positions = findPositions(params);
    maskPos = prepMask(params, positions);

    %Instruction screen
    textMsg(w, params.text.testInst, params);
    getKey(params.keys.continue);

    %Loop over miniblocks
    for miniblocki = 1 : nMiniblocks

        trialIndex = find([trials.Miniblock_no] == miniblocki); %the trials of this miniblock
        visName = trials(trialIndex(1)).visibility; %'seen' or 'unseen'

        %Instruction of this miniblock and correction factor for the mask contrast
        if strcmp(visName, 'seen')
            textMsg(w, params.text.seenBlock, params);
            maskCorrection = params.learn.correctionSeen;
        else
            textMsg(w, params.text.unseenBlock, params);
            maskCorrection = params.learn.correctionUnseen;
        end
        getKey(params.keys.continue);

        %Count-down
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

        nWrong = 0; %number of ratings that do not fit this miniblock

        %Loop over trials
        for i = 1 : length(trialIndex)
            triali = trialIndex(i);

            %Mask contrast and mask color on this trial
            currentContrast = contrast.(visName);
            maskColor = [255 * currentContrast, 255 * currentContrast, 255 * currentContrast];

            %Run the trial and ask the questions
            timing = runLearningTrial(w, params, positions, maskPos, trials(triali), maskColor);
            answers = runQuestions(w, params, positions, trials(triali));

            %Save this trial
            trials(triali).maskContrast = currentContrast;
            testData.timing = [testData.timing, timing];
            testData.answers = [testData.answers, answers];

            %Check whether the mask contrast has to be corrected (original code).
            %Only masked targets that were really shown are counted.
            ratings = [];
            if trials(triali).T1position > 0
                ratings = [ratings, answers.T1visibility];
            end
            if trials(triali).T2position > 0 && params.learn.maskT2
                ratings = [ratings, answers.T2visibility];
            end

            if strcmp(visName, 'seen')
                nWrong = nWrong + sum(ratings == 1); %unseen in a seen miniblock
            else
                nWrong = nWrong + sum(ratings > 1); %seen in an unseen miniblock
            end

            if nWrong >= params.learn.nWrongAllowed
                disp('Adjusting mask contrast');
                contrast.(visName) = contrast.(visName) * maskCorrection;
                if contrast.(visName) > 1 %the mask cannot be brighter than white
                    contrast.(visName) = 1;
                end
                nWrong = 0; %reset the counter
            end

            %Print the trial in the Command Window (test mode only)
            if params.testMode
                disp(['   miniblock ' num2str(miniblocki) ' (' visName ') trial ' num2str(i) ...
                    ' | ' trials(triali).trialType ' | T1 ' num2str(trials(triali).T1position) ...
                    ' T2 ' num2str(trials(triali).T2position) ' | answers ' num2str(answers.T1answer) ...
                    ' ' num2str(answers.T2answer) ' | seen ' num2str(answers.T1visibility) ...
                    ' ' num2str(answers.T2visibility) ' | mask ' num2str(currentContrast, '%.3f')]);
            end
        end

        %Save after every miniblock, in case something goes wrong
        testData.trials = trials;
        testData.contrastNow = contrast;
        save(partialFile, 'testData');

        %Break between the miniblocks
        if miniblocki < nMiniblocks
            textMsg(w, sprintf(params.text.break, nMiniblocks - miniblocki), params);
            getKey(params.keys.continue);
        end
    end

    %End screen
    textMsg(w, params.text.learnEnd, params);
    WaitSecs(2.5);

    Screen('CloseAll');
    ShowCursor;
    Priority(0);

catch err
    %Something went wrong or ESCAPE was pressed:
    %close the screen and save the data collected so far
    Screen('CloseAll');
    ShowCursor;
    Priority(0);

    testData.trials = trials;
    testData.contrastNow = contrast;
    save(partialFile, 'testData');
    disp(['Data so far saved in ' fileName '_test_partial.mat']);

    if strcmp(err.identifier, 'calib:abort')
        disp('Test phase stopped with ESCAPE.');
        return;
    else
        rethrow(err);
    end
end

%% SAVE
testData.trials = trials;
testData.contrastNow = contrast; %mask contrasts at the end (after the corrections)
testData.endTime = datestr(now);
save(dataFile, 'testData');
disp([fileName '_test.mat has been saved']);

if exist(partialFile, 'file')
    delete(partialFile);
end
end
