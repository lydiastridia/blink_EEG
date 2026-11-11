%Purpose: Main script to run the learning phase. Type runLearning in the
%Command Window to start. The calibration must have been run before for the
%same participant and session (the mask contrasts are loaded from its threshold file).
%All numbers are in mainParams.m.
%
%Output (in Data/LearningPhase):
%   P<nr>_positions.mat           the positions of this participant (made once, then loaded again)
%   P<nr>_S<session>_learning.mat all data (struct learn)
%ESCAPE stops the task; the data collected so far are saved.

function runLearning()

%% PREPARATION
%Load the parameters
params = mainParams();

%Enter the subject's details
info = askParticipantInfo();

%Seed the Matlab random number generator using the current time
RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', sum(100*clock)));

%Make the data directory & warn if there is a duplicate subject ID
if ~exist(params.path.learning, 'dir')
    mkdir(params.path.learning);
end

fileName = sprintf('P%d_S%d', info.id, info.session);
dataFile = fullfile(params.path.learning, [fileName '_learning.mat']);
partialFile = fullfile(params.path.learning, [fileName '_learning_partial.mat']);
positionFile = fullfile(params.path.learning, sprintf('P%d_positions.mat', info.id));

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

%Load the mask contrasts from the calibration
maskContrast = loadThreshold(info.id, info.session);
contrast.seen = maskContrast.seen; %weak mask
contrast.unseen = maskContrast.unseen; %strong mask

%Positions of this participant: made once and saved, afterwards always loaded
if exist(positionFile, 'file')
    tmp = load(positionFile);
    pos = tmp.pos;
    disp('Positions of this participant loaded.');
else
    disp('Choosing the positions of this participant (this can take a moment) ...');
    pos = makePositions(params, info.id);
    save(positionFile, 'pos');
end

%Prepare the trials (and check them)
trials = makeLearningTrials(params, info.id);
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
learn.info = info;
learn.params = params;
learn.pos = pos;
learn.maskContrast = maskContrast;
learn.startTime = datestr(now);
learn.timing = []; %one entry per trial: when everything appeared (from runLearningTrial)
learn.answers = []; %one entry per trial: the answers (from runQuestions)

try
    %Initialize PTB window
    [w, rect] = openScreen(params);
    params.screen.pos.Center = floor([rect(3) rect(4)] / 2); %center of the screen in pixels

    %Determine position of elements on screen
    positions = findPositions(params);
    maskPos = prepMask(params, positions);

    %Instruction screen
    textMsg(w, params.text.learnInst, params);
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
            learn.timing = [learn.timing, timing];
            learn.answers = [learn.answers, answers];

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
        learn.trials = trials;
        learn.contrastNow = contrast;
        save(partialFile, 'learn');

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

    learn.trials = trials;
    learn.contrastNow = contrast;
    save(partialFile, 'learn');
    disp(['Data so far saved in ' fileName '_learning_partial.mat']);

    if strcmp(err.identifier, 'calib:abort')
        disp('Learning phase stopped with ESCAPE.');
        return;
    else
        rethrow(err);
    end
end

%% SAVE
learn.trials = trials;
learn.contrastNow = contrast; %mask contrasts at the end (after the corrections)
learn.endTime = datestr(now);
save(dataFile, 'learn');
disp([fileName '_learning.mat has been saved']);

if exist(partialFile, 'file')
    delete(partialFile);
end
end
