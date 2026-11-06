%Purpose: This function checks that the target appears equally often at every
%position: it prints the number of trials per position and checks that every
%round contains every position exactly once.
%Can also be run on its own:
%   params = calibParams; checkCalibTrials(makeCalibTrials(params), params)


function [ok] = checkCalibTrials(trials, params)

nPos = params.stim.targetPositions;
tarPos = [trials.tarPos];
rounds = [trials.round];

%Count the trials per position
counts = zeros(1, nPos);
for posi = 1 : nPos
    counts(posi) = sum(tarPos == posi);
end

%Print the counts
fprintf('\nPosition:  ');
for posi = 1 : nPos
    fprintf('%3d', posi);
end
fprintf('   absent   total\n');
fprintf('Trials:    ');
for posi = 1 : nPos
    fprintf('%3d', counts(posi));
end
fprintf('   %6d   %5d\n', sum(tarPos == 0), length(tarPos));

%Check that every round contains every position exactly once
ok = true;
nRounds = max(rounds);
for roundi = 1 : nRounds
    positionsInRound = tarPos(rounds == roundi & tarPos > 0);
    if ~isequal(sort(positionsInRound), 1 : nPos)
        ok = false;
        disp(['WARNING: round ' num2str(roundi) ' does not contain every position exactly once!']);
    end
end

if ok
    disp(['OK: every position appears ' num2str(params.trials.nTrialsPerPosition) ...
        ' times, once in each of the ' num2str(nRounds) ' rounds.']);
    disp(' ');
end
end
