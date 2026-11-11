%Purpose: This function counts how often each kind is followed by each kind.
%transMat(a, b) = number of times that kind b came directly after kind a.
%With uniform transition probabilities, all numbers in the table are equal.

function [transMat] = computeTransitions(order, nKinds)

transMat = zeros(nKinds, nKinds);

for triali = 1 : length(order) - 1
    from = order(triali);
    to = order(triali + 1);
    transMat(from, to) = transMat(from, to) + 1;
end
end
