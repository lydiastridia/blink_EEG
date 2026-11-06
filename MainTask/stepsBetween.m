function d = stepsBetween(a, b, p)
%STEPSBETWEEN  Signed number of ring steps from position a to b.
%   Positive = clockwise, negative = counter-clockwise; range -7..8
%   (8 = opposite side). One step = 360/16 = 22.5 degrees.
n = p.nPositions;
d = mod(b - a, n);
d(d > n/2) = d(d > n/2) - n;
end
