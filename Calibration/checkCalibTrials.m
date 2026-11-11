%Purpose: This function checks that the target appears equally often at every
%position: it prints the number of trials per position.
%Can also be run on its own:
%   params = calibParams; checkCalibTrials(makeCalibTrials(params), params)


function [ok] = checkCalibTrials(trials, params)

nPos = params.stim.targetPositions;
tarPos = [trials.tarPos];

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

%Check that every position appears equally often
ok = true;
for posi = 1 : nPos
    if counts(posi) ~= params.trials.nTrialsPerPosition
        ok = false;
        disp(['WARNING: position ' num2str(posi) ' does not appear ' num2str(params.trials.nTrialsPerPosition) ' times!']);
    end
end

if ok
    disp(['OK: every position appears ' num2str(params.trials.nTrialsPerPosition) ' times.']);
    disp(' ');
end
end
