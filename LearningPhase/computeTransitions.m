% This function count how often each kind is followed by each kind (e.g: duplet my duplet, duplet by control, control by comtrol, etc)
% transMat(a,b) = nr of times that kind b came directly after kind a
% if transition probs are uniform, then all of the numbers in the table should be equal

function [transMat] = computeTransition(order, nKinds)

transMat = zeros(nKinds, nKinds);

for triali = 1 : length(order) - 1
    from = order(triali);
    to = order(triali + 1);
    transMat(from, to) = transMat(from, to) + 1;
end
end
