%Purpose: This function generates the trial sequence for the calibration task.
%The trials are made in ROUNDS, so that the target is spread evenly over the
%circle during the whole calibration:
%   - one round = every position once + some target-absent trials, in random order
%   - number of rounds = params.trials.nTrialsPerPosition, so every position
%     appears exactly that many times
%   - the target-absent trials are divided as evenly as possible over the rounds

%
%Each trial has:
%   cond    1 = target-present, 0 = target-absent
%   tarPos  target position (1-16), 0 on target-absent trials
%   round   round number
%   ITI     duration of the inter-trial interval (s)

function [trials] = makeCalibTrials(params)

%Define necessary variables
nPos = params.stim.targetPositions;
nRounds = params.trials.nTrialsPerPosition;
nTarPresTrials = nPos * nRounds; %to calculate how many target-present trials we have
nTarAbsTrials = round(nTarPresTrials / (1 - params.trials.propAbsent)) - nTarPresTrials; %so that absent trials are taking up 20% of the trials

%Number of target-absent trials in each round (e.g., 20 over 5 rounds = 4 each).
%If they do not divide evenly, the extra ones go to randomly chosen rounds.
absentPerRound = zeros(1, nRounds);
for roundi = 1 : nRounds
    absentPerRound(roundi) = floor(nTarAbsTrials / nRounds);
end
nExtra = nTarAbsTrials - sum(absentPerRound);
extraRounds = randperm(nRounds, nExtra);
for i = 1 : nExtra
    absentPerRound(extraRounds(i)) = absentPerRound(extraRounds(i)) + 1;
end

%Create the trials, round by round
trials = [];
for roundi = 1 : nRounds
    %Every position once, plus the target-absent trials (position 0) of this round
    roundPositions = [1 : nPos, zeros(1, absentPerRound(roundi))];

    %Random order within the round
    roundPositions = roundPositions(randperm(length(roundPositions)));

    for i = 1 : length(roundPositions)
        trial = [];
        trial.tarPos = roundPositions(i);
        if trial.tarPos == 0
            trial.cond = 0; %target-absent
        else
            trial.cond = 1; %target-present
        end
        trial.round = roundi;

        %Choose the ITI at random from the possible values
        ITIOrder = params.stiming.ITI(randperm(length(params.stiming.ITI)));
        trial.ITI = ITIOrder(1);

        trials = [trials, trial];
    end
end
end
