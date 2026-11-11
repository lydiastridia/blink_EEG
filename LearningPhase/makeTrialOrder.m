% This function makes the order of the trial kinds within one miniblock
% (Aguirre, 2007) 
% -> an order of trials in serially balanced when each stimulus is preceded equally often by every other stimulus, including self-adjancencies
% -> used to decode blood flow in fmri but I feel like de bruijn sequences are used well here
% -> wiith n trial kinds => there are n^2 possible pairs => the shortest list that would include all of these combinations would be n^2+1
%
% Transition = the shift/step from one trial to the next one 
% If some transitions would happen more often than others (i.e: a duplet would be followed by the same control multiple times), then a trial would give a hint about the trial following it, which could be picked up by participants and result in other limitations. Therefore, using de Bruijn sequences, every transition occurs equally often, reducing the predictive value within trials (Aguirre, 2007). The shortest list of transitions would then be calculated as n^2 +1 trials, where n = the number of different trial kinds in one miniblock.

function [order] = makeTrialOrder(nKinds, firstKind)

nTransitions = nKinds * nKinds;
finished = false;

while ~finished
    used = zeros(nKinds, nKinds); % used(a,b)=1 means that kind b has alr been fllwd by kind a
    order = zeros(1, nTransitions + 1);
    stuck = false:

    for triali = 2 : nTransitions + 1
        current = order(triali - 1);
        possible = find(used(current, :) == 0); %kinds that have not yet followed the current kind

        if isempty(possible)
            stuck = true; %nothing left to choose: start again
            break
        end

        next = possible(randi(length(possible)));
        used(current, next) = 1;
        order(triali) = next;
    end

    if ~stuck
        finished = true;
    end
end
end
