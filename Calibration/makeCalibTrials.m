%Purpose: This function generates the trial sequence for the calibration task.
%As in the original code: all trials (every position equally often, plus the
%target-absent trials) are put in one list, and the whole list is shuffled.
%
%Each trial has:
%   cond    1 = target-present, 0 = target-absent
%   tarPos  target position (1-16), 0 on target-absent trials
%   ITI     duration of the inter-trial interval (s)

function [trials] = makeCalibTrials(params)

%Define necessary variables
nPos = params.stim.targetPositions;
nTrialsPerPosition = params.trials.nTrialsPerPosition;
nTarPresTrials = nPos * nTrialsPerPosition; %16 x 5 = 80 target-present trials
nTarAbsTrials = round(nTarPresTrials / (1 - params.trials.propAbsent)) - nTarPresTrials; %20, so that absent trials are 20% of all trials

%One list with all trials: every position nTrialsPerPosition times, and a 0 for every target-absent trial
allPositions = [repmat(1 : nPos, 1, nTrialsPerPosition), zeros(1, nTarAbsTrials)];

%Shuffle the whole list
allPositions = allPositions(randperm(length(allPositions)));

%Create the trials
trials = [];
for triali = 1 : length(allPositions)
    trial = [];
    trial.tarPos = allPositions(triali);
    if trial.tarPos == 0
        trial.cond = 0; %target-absent
    else
        trial.cond = 1; %target-present
    end

    %Choose the ITI at random from the possible values
    ITIOrder = params.stiming.ITI(randperm(length(params.stiming.ITI)));
    trial.ITI = ITIOrder(1);

    trials = [trials, trial];
end
end
