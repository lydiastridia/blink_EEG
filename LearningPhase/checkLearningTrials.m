% This function just checks the trial list of the learning phase and prints and overview in the command window:
% trial type = valid, control, T1absent, omission or controlomission
% 1 -> the nr of trials per trial type, for con and noncon miniblocks
% 2 -> the number of trials per trial kind
% 3 -> whether the transition probabilities are uniform in every miniblock
% 4 -> whether T2 appears equally often at both T2 locations

function [ok] = checkLearningTrials(trials, params)

kinds = params.design.kinds;
nKinds = length(kinds);
typeNames = {'valid', 'control', 'deviant', 'T1absent', 'omission', 'controlOmission'};
nMiniblocks = max([trials.Miniblock_no]);
ok = true;

% Which trials are seen, and which are unseen?
isSeen = strcmp({trials.visibility}, 'seen');
isUnseen = strcmp({trials.visibility}, 'unseen');

disp(' ');
disp(['Learning phase: ' num2str(length(trials)) ' trials in ' num2str(nMiniblocks) ' miniblocks.']);
disp(['The first miniblock is ' trials(1).visibility '.']);

% 1. Number of trials per trial type
disp(' ');
disp('Trials per trial type:');
fprintf('%-18s %8s %8s\n', '', 'seen', 'unseen');
for typei = 1 : length(typeNames)
    isType = strcmp({trials.trialType}, typeNames{typei});
    fprintf('%-18s %8d %8d\n', typeNames{typei}, sum(isSeen & isType), sum(isUnseen & isType));
end
fprintf('%-18s %8d %8d\n', 'total', sum(isSeen), sum(isUnseen));

% 2. Number of trials per trial kind
% (a kind that is listed twice in params.design.kinds is counted once here)
kindNames = unique(kinds, 'stable'); %every name once, in the original order
disp(' ');
disp('Trials per trial kind:');
fprintf('%-18s %8s %8s\n', '', 'seen', 'unseen');
for kindi = 1 : length(kindNames)
    isKind = strcmp({trials.kindName}, kindNames{kindi});
    fprintf('%-18s %8d %8d\n', kindNames{kindi}, sum(isSeen & isKind), sum(isUnseen & isKind));
end

% 3. Are the transition probabilities uniform in every miniblock?
disp(' ');
transitionsOK = true;
for miniblocki = 1 : nMiniblocks
    order = [trials([trials.Miniblock_no] == miniblocki).kind];
    transMat = computeTransitions(order, nKinds);
    if length(unique(transMat)) ~= 1 %not all numbers in the table are the same
        transitionsOK = false;
        disp(['WARNING: transition probabilities are not uniform in miniblock ' num2str(miniblocki) '!']);
    end
end
if transitionsOK
    disp('OK: in every miniblock, every entry of the list follows every entry equally often.');
else
    ok = false;
end

% 4. Does T2 appear equally often at both T2 locations?
nLoc1Seen = sum(isSeen & [trials.T2location] == 1);
nLoc2Seen = sum(isSeen & [trials.T2location] == 2);
nLoc1Unseen = sum(isUnseen & [trials.T2location] == 1);
nLoc2Unseen = sum(isUnseen & [trials.T2location] == 2);

disp(['T2 in seen miniblocks:   location 1 = ' num2str(nLoc1Seen) ' trials, location 2 = ' num2str(nLoc2Seen) ' trials.']);
disp(['T2 in unseen miniblocks: location 1 = ' num2str(nLoc1Unseen) ' trials, location 2 = ' num2str(nLoc2Unseen) ' trials.']);

% A difference of a few trials is normal (odd numbers cannot be split in half)
if abs(nLoc1Seen - nLoc2Seen) > nKinds || abs(nLoc1Unseen - nLoc2Unseen) > nKinds
    ok = false;
    disp('WARNING: the two T2 locations are not used equally often!');
end
disp(' ');
end
