%Purpose: This function checks the trial sequence of the learning phase and
%prints an overview in the Command Window:
%   1. the number of trials per visibility and trial type
%   2. the number of trials per visibility and trial kind
%   3. whether the transition probabilities are uniform in every miniblock
%   4. whether T2 appears equally often at both T2 locations
%Can be run on its own:
%   params = mainParams; trials = makeLearningTrials(params, 1); checkLearningTrials(trials, params)

function [ok] = checkLearningTrials(trials, params)

kinds = params.design.kinds;
nKinds = length(kinds);
visNames = {'seen', 'unseen'};
typeNames = {'valid', 'omission', 'control', 'controlOmission', 'T1absent'};
ok = true;

nMiniblocks = max([trials.Miniblock_no]);
disp(' ');
disp(['Learning phase: ' num2str(length(trials)) ' trials in ' num2str(nMiniblocks) ' miniblocks.']);
disp(['Order of the miniblocks: ' trials(1).visibility ' first, then alternating.']);

%1. Number of trials per visibility and trial type
disp(' ');
disp('Trials per trial type:');
fprintf('%-18s %8s %8s\n', '', 'seen', 'unseen');
for typei = 1 : length(typeNames)
    nSeen = sum(strcmp({trials.visibility}, 'seen') & strcmp({trials.trialType}, typeNames{typei}));
    nUnseen = sum(strcmp({trials.visibility}, 'unseen') & strcmp({trials.trialType}, typeNames{typei}));
    fprintf('%-18s %8d %8d\n', typeNames{typei}, nSeen, nUnseen);
end
fprintf('%-18s %8d %8d\n', 'total', sum(strcmp({trials.visibility}, 'seen')), sum(strcmp({trials.visibility}, 'unseen')));

%2. Number of trials per visibility and trial kind
disp(' ');
disp('Trials per trial kind:');
fprintf('%-18s %8s %8s\n', '', 'seen', 'unseen');
for kindi = 1 : nKinds
    nSeen = sum(strcmp({trials.visibility}, 'seen') & [trials.kind] == kindi);
    nUnseen = sum(strcmp({trials.visibility}, 'unseen') & [trials.kind] == kindi);
    fprintf('%-18s %8d %8d\n', kinds{kindi}, nSeen, nUnseen);
end

%3. Uniform transition probabilities in every miniblock?
for miniblocki = 1 : nMiniblocks
    order = [trials([trials.Miniblock_no] == miniblocki).kind];
    transMat = computeTransitions(order, nKinds);
    if length(unique(transMat)) ~= 1
        ok = false;
        disp(['WARNING: transition probabilities are not uniformly distributed in miniblock ' num2str(miniblocki) '!']);
    end
end
disp(' ');
if ok
    disp('OK: in every miniblock, every kind follows every kind exactly once.');
end

%4. T2 location balanced?
for visi = 1 : 2
    inVis = strcmp({trials.visibility}, visNames{visi});
    n1 = sum(inVis & [trials.T2location] == 1);
    n2 = sum(inVis & [trials.T2location] == 2);
    disp(['T2 location in ' visNames{visi} ' miniblocks: location 1 = ' num2str(n1) ' trials, location 2 = ' num2str(n2) ' trials.']);
    if abs(n1 - n2) > nKinds
        ok = false;
        disp('WARNING: the two T2 locations are not used equally often!');
    end
end
disp(' ');
end
