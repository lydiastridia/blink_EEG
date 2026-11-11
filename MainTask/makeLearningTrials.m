%Purpose: This function generates the trial sequence of the learning phase.
%   - seen and unseen miniblocks alternate (odd participant numbers start
%     with a seen miniblock, even numbers with an unseen miniblock)
%   - within a miniblock, the order of the trial kinds has uniform transition
%     probabilities (see makeTrialOrder)
%   - control and T1-absent trials: T2 appears equally often at each of the
%     two T2 locations
%   - omissions: in a proportion of the duplet and control trials, T2 does
%     not appear
%The positions on the screen are not filled in here yet.
%
%Usage: trials = makeLearningTrials(params, 3)   (participant 3)
%
%Each trial has:
%   Miniblock_no  number of the miniblock
%   Trial_no      number of the trial within the miniblock
%   visibility    'seen' (weak mask) or 'unseen' (strong mask)
%   kind          number of the trial kind (see params.design.kinds)
%   kindName      name of the trial kind, e.g., 'duplet1'
%   T1type        'predictive', 'control' or 'absent'
%   T2location    1 or 2: at which of the two T2 locations T2 appears
%   T2present     1 = T2 is shown, 0 = T2 is omitted
%   trialType     'valid', 'omission', 'control', 'controlOmission' or 'T1absent'

function [trials] = makeLearningTrials(params, subjectNum)

kinds = params.design.kinds;
nKinds = length(kinds);
nMiniblocks = 2 * params.learn.nMiniblocksPerVis;

%Which visibility comes first?
if mod(subjectNum, 2) == 1 %odd participant number
    visOrder = {'seen', 'unseen'};
else %even participant number
    visOrder = {'unseen', 'seen'};
end

%Which kind does each miniblock start with?
%The kind of the first trial appears once more than the other kinds, so the
%first kinds are spread equally over the miniblocks of each visibility
%(1 2 3 4 5 1 2 ..., in random order).
nPerVis = params.learn.nMiniblocksPerVis;
firstKinds = zeros(2, nPerVis); %row 1: first visibility, row 2: second visibility
for visi = 1 : 2
    tmp = repmat(1 : nKinds, 1, ceil(nPerVis / nKinds));
    tmp = tmp(1 : nPerVis);
    firstKinds(visi, :) = tmp(randperm(nPerVis));
end

%% CREATE THE TRIALS, MINIBLOCK BY MINIBLOCK
trials = [];
for miniblocki = 1 : nMiniblocks

    %Seen and unseen miniblocks alternate
    if mod(miniblocki, 2) == 1
        visi = 1;
    else
        visi = 2;
    end
    visibility = visOrder{visi};
    miniblockOfVis = ceil(miniblocki / 2); %1st, 2nd, ... miniblock of this visibility

    %Order of the trial kinds in this miniblock
    order = makeTrialOrder(nKinds, firstKinds(visi, miniblockOfVis));

    for triali = 1 : length(order)
        trial = [];
        trial.Miniblock_no = miniblocki;
        trial.Trial_no = triali;
        trial.visibility = visibility;
        trial.kind = order(triali);
        trial.kindName = kinds{order(triali)};

        %What kind of T1 is it?
        if strncmp(trial.kindName, 'duplet', 6)
            trial.T1type = 'predictive';
        elseif strncmp(trial.kindName, 'control', 7)
            trial.T1type = 'control';
        else
            trial.T1type = 'absent';
        end

        trial.T2location = 0; %filled in below
        trial.T2present = 1; %omissions are chosen below
        trial.trialType = ''; %filled in below

        trials = [trials, trial];
    end
end

%% T2 LOCATION
%duplet1 -> T2 location 1, duplet2 -> T2 location 2 (always).
%control and T1-absent trials: location 1 in half of the trials and location
%2 in the other half, in random order (separately per visibility and kind).
for visi = 1 : 2
    for kindi = 1 : nKinds
        index = find(strcmp({trials.visibility}, visOrder{visi}) & [trials.kind] == kindi);

        if strcmp(kinds{kindi}, 'duplet1')
            locations = ones(1, length(index));
        elseif strcmp(kinds{kindi}, 'duplet2')
            locations = 2 * ones(1, length(index));
        else
            locations = repmat([1 2], 1, ceil(length(index) / 2)); %1 2 1 2 ...
            locations = locations(1 : length(index));
            locations = locations(randperm(length(locations))); %random order
        end

        for i = 1 : length(index)
            trials(index(i)).T2location = locations(i);
        end
    end
end

%% OMISSIONS
%For each visibility and each duplet and control kind, T2 is omitted in a
%proportion of the trials. Rules: not in the first miniblocks of a visibility
%(params.learn.nMiniblocksNoOmission), never the first trial of a miniblock,
%and never two omissions in a row.
if params.learn.propOmission > 0
    omissionsOK = false;

    while ~omissionsOK
        for i = 1 : length(trials)
            trials(i).T2present = 1; %start again without omissions
        end

        for visi = 1 : 2
            %The miniblocks of this visibility in which omissions are allowed
            visMiniblocks = unique([trials(strcmp({trials.visibility}, visOrder{visi})).Miniblock_no]);
            allowedMiniblocks = visMiniblocks(params.learn.nMiniblocksNoOmission + 1 : end);

            for kindi = 1 : nKinds
                if strcmp(kinds{kindi}, 'T1absent')
                    continue %T1-absent trials always have a T2
                end

                allOfKind = find(strcmp({trials.visibility}, visOrder{visi}) & [trials.kind] == kindi);
                nOmissions = round(params.learn.propOmission * length(allOfKind));

                %Trials of this kind in which an omission is allowed
                candidates = allOfKind(ismember([trials(allOfKind).Miniblock_no], allowedMiniblocks) & [trials(allOfKind).Trial_no] > 1);
                if nOmissions > length(candidates)
                    error('Not enough trials for the omissions: lower propOmission or nMiniblocksNoOmission.');
                end

                chosen = candidates(randperm(length(candidates), nOmissions));
                for i = 1 : length(chosen)
                    trials(chosen(i)).T2present = 0;
                end
            end
        end

        %Check: never two omissions in a row within a miniblock
        omissionsOK = true;
        for i = 2 : length(trials)
            if trials(i).T2present == 0 && trials(i - 1).T2present == 0 && trials(i).Miniblock_no == trials(i - 1).Miniblock_no
                omissionsOK = false;
            end
        end
    end
end

%% NAME OF THE TRIAL TYPE
for i = 1 : length(trials)
    if strcmp(trials(i).T1type, 'predictive') && trials(i).T2present == 1
        trials(i).trialType = 'valid';
    elseif strcmp(trials(i).T1type, 'predictive') && trials(i).T2present == 0
        trials(i).trialType = 'omission';
    elseif strcmp(trials(i).T1type, 'control') && trials(i).T2present == 1
        trials(i).trialType = 'control';
    elseif strcmp(trials(i).T1type, 'control') && trials(i).T2present == 0
        trials(i).trialType = 'controlOmission';
    else
        trials(i).trialType = 'T1absent';
    end
end
end
