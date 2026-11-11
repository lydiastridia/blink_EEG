% This function allocates the positions on the circle to every trial
% It adds these fields to the trial list:
%   T1position          position (1 to 16) where T1 is shown, 0 = no T1
%   T2position          position (1 to 16) where T2 is shown, 0 = no T2
%   predictedT2position position where T2 is expected after this T1
%                       (only for a duplet T1, also when T2 is missing), 0 = no prediction
%
% The positions come from makePositions: pos.seen is used in seen miniblocks,
% pos.unseen in unseen miniblocks.
%
% Usage: trials = addPositions(trials, pos)

function [trials] = addPositions(trials, pos)

for triali = 1 : length(trials)

    %The set of positions for this trial: pos.seen or pos.unseen
    thisSet = pos.(trials(triali).visibility);

    %% T1 position: depends on whose T1 is used
    source = trials(triali).T1source;

    if strcmp(source, 'duplet1')
        trials(triali).T1position = thisSet.dupletT1(1);
        trials(triali).predictedT2position = thisSet.T2(1);

    elseif strcmp(source, 'duplet2')
        trials(triali).T1position = thisSet.dupletT1(2);
        trials(triali).predictedT2position = thisSet.T2(2);

    elseif strcmp(source, 'control1')
        trials(triali).T1position = thisSet.controlT1(1);
        trials(triali).predictedT2position = 0;

    elseif strcmp(source, 'control2')
        trials(triali).T1position = thisSet.controlT1(2);
        trials(triali).predictedT2position = 0;

    else %'none': T1 is missing
        trials(triali).T1position = 0;
        trials(triali).predictedT2position = 0;
    end

    %% T2 position: T2 location 1 or 2 of this set
    if trials(triali).T2present == 1
        trials(triali).T2position = thisSet.T2(trials(triali).T2location);
    else %T2 is missing
        trials(triali).T2position = 0;
    end
end
end
