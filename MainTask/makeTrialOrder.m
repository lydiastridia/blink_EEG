%Purpose: This function makes the order of the trial kinds within one
%miniblock, with uniform transition probabilities: every kind is followed by
%every kind (including itself) exactly once.
%With n kinds there are n x n transitions, so the order has (n x n) + 1 trials.
%Each kind appears n times, and the kind of the first trial once more
%(the first and the last trial are always of the same kind).
%
%Usage: order = makeTrialOrder(5, 2)   -> 26 numbers between 1 and 5, starting with kind 2
%
%How it works: start with the kind firstKind. For every next trial, choose at
%random among the kinds that have not yet followed the current kind. If no
%kind is left before all transitions are used, start again.

function [order] = makeTrialOrder(nKinds, firstKind)

nTransitions = nKinds * nKinds;
finished = false;

while ~finished
    used = zeros(nKinds, nKinds); %used(a, b) = 1: kind b has already followed kind a
    order = zeros(1, nTransitions + 1);
    order(1) = firstKind;
    stuck = false;

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
