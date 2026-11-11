% This function makes the list of all trials of the learning phase.
% At least for now, every trials gets its miniblock, its number within the miniblock,
% the visibility of the miniblock and its trial kind
%
%con and noncon miniblocks alternate
%participants with an odd nr start with a con miniblock
%participants with an even number start with a noncon miniblock
%within a miniblock, the kinds are ordered by makeTrialOrder.m

function [trials] = makeLearningTrials(params, subjectNum);

kinds = params.design.kinds;
nKinds = length(kinds);
nPerVis = params.learn.nMiniblocksPerVis;
nMiniblocks = 2 * nPerVis;

%Which visibility comes first? (con/noncon)

if mod(subjectNum,2) == 1 
    visOrder = {'seen', 'unseen'};
else
    visOrder = {'unseen','seen'};
end

%Which kind does each miniblock start with?
% Because of the n^2+1 formula, the number will not be dividable by 5 given that we have 5 kinds
% therefore, the first kind of a miniblock appears once more than the other kinds
% => the first kinds are spread equally over the miniblocks of each visibility 

firstKinds = zeros(2, nPerVis); %row 1: first visibility, row 2: second visibility
for visi = 1 : 2
    tmp = repmat(1 : nKinds, 1, ceil(nPerVis / nKinds)); %1 2 3 4 5 1 2 3 4 5 ...
    tmp = tmp(1 : nPerVis); %keep as many as there are miniblocks
    firstKinds(visi, :) = tmp(randperm(nPerVis)); %random order
end

% Create the trials, miniblock by miniblock
trials = [];
for miniblocki = 1 : nMiniblocks

    % Seen and unseen miniblocks alternate
    if mod(miniblocki, 2) == 1
        visi = 1;
    else
        visi = 2;
    end
    visibility = visOrder{visi};
    miniblockOfVis = ceil(miniblocki / 2); %1st, 2nd, ... miniblock of this visibility

    % Order of the trial kinds in this miniblock
    order = makeTrialOrder(nKinds, firstKinds(visi, miniblockOfVis));

    for triali = 1 : length(order)
        trial = [];
        trial.Miniblock_no = miniblocki;
        trial.Trial_no = triali;
        trial.visibility = visibility;
        trial.kind = order(triali);
        trial.kindName = kinds{order(triali)};

        trials = [trials, trial];
    end
end
end
