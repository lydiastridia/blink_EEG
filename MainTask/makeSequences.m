function seq = makeSequences(participantNum, p)
%MAKESEQUENCES  Duplets and control positions for one participant.
%
%   seq = makeSequences(participantNum, p)   (p from mainParams)
%
%   Per visibility condition there are 6 positions:
%     P(1) -> R(1)   predictive duplet 1 (always valid in the learning phase)
%     P(2) -> R(2)   predictive duplet 2
%     C(1), C(2)     control T1s, followed by R(1) or R(2) at random
%   Deviants (test phase only): P(1) -> R(2) and P(2) -> R(1), so every T2
%   location is expected after one T1 and unexpected after the other.
%
%   Counterbalancing: participants 1 & 2 get the same two sets, but set A is
%   unseen for participant 1 and seen for participant 2. Participants 3 & 4
%   get a new pair, and so on. Recruit an even number of participants.
%
%   seq.seen and seq.unseen each have fields P, R, C (positions 1-16).
%   seq.pairIndex, seq.setAIsUnseen and seq.startCondition are saved too.

pairIndex = ceil(participantNum / 2);
setAIsUnseen = mod(participantNum, 2) == 1;

% Same random sets for both members of a pair: seed by the pair number.
oldState = rng;
rng(1000 + pairIndex);
setA = drawSet(p, []);
setB = drawMatchedSet(p, setA);
% Starting condition of the alternation, counterbalanced across pairs.
startSeen = mod(pairIndex, 2) == 0;
rng(oldState);

if setAIsUnseen
    seq.unseen = setA;  seq.seen = setB;
else
    seq.unseen = setB;  seq.seen = setA;
end
seq.pairIndex    = pairIndex;
seq.setAIsUnseen = setAIsUnseen;
if startSeen
    seq.startCondition = 'seen';
else
    seq.startCondition = 'unseen';
end
end


function s = drawMatchedSet(p, other)
% A set that shares no position with "other", has different duplet
% distances (no rule carrying over) but similar difficulty.
dOther = duplDist(other, p);
for attempt = 1:100000
    s = drawSet(p, [other.P other.R other.C]);
    d = duplDist(s, p);
    if ~isequal(sort(d), sort(dOther)) && abs(sum(d) - sum(dOther)) <= p.rule.maxDifficultyDiff
        return
    end
end
error('makeSequences:noSet', 'No matching second set found.');
end


function s = drawSet(p, forbidden)
% Random set of 6 positions that satisfies all rules (see setIsValid).
free = setdiff(1:p.nPositions, forbidden);
for attempt = 1:1000000
    pos = free(randperm(numel(free), 6));
    s.P = pos(1:2); s.R = pos(3:4); s.C = pos(5:6);
    if setIsValid(s, p)
        return
    end
end
error('makeSequences:noSet', 'No valid set found.');
end


function d = duplDist(s, p)
d = abs([stepsBetween(s.P(1), s.R(1), p), stepsBetween(s.P(2), s.R(2), p)]);
end
