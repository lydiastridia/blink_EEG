function [ok, why] = setIsValid(s, p)
%SETISVALID  Checks one condition's set of positions against the duplet rules.
%
%   [ok, why] = setIsValid(s, p)   s has fields P, R, C (2 positions each).
%   why names the first rule that failed ('' if ok).
%


ok = false;
v  = [stepsBetween(s.P(1), s.R(1), p), stepsBetween(s.P(2), s.R(2), p)];
dv = [stepsBetween(s.P(1), s.R(2), p), stepsBetween(s.P(2), s.R(1), p)];

if numel(unique([s.P s.R s.C])) < 6
    why = 'positions not distinct'; return
end
if sign(v(1)) == sign(v(2)) || any(abs(v) == 8)
    why = 'rule 1: duplets must turn in opposite directions'; return
end
if abs(v(1)) == abs(v(2))
    why = 'rule 2: duplet distances must differ'; return
end
if abs(dv(1)) == abs(dv(2)) || any(ismember(abs(dv), abs(v)))
    why = 'rule 3: deviant distances must differ from each other and from valid ones'; return
end
T1 = [s.P s.C];
for a = T1
    for b = s.R
        if abs(stepsBetween(a, b, p)) < p.rule.minStepT1T2
            why = 'rule 4: a T1 is too close to a T2'; return
        end
    end
end
for c = s.C
    for q = s.P
        if abs(stepsBetween(c, q, p)) < p.rule.minStepControl
            why = 'rule 5: a control T1 is too close to a predictive T1'; return
        end
    end
end
if p.rule.oppositeHemifieldT2 && (s.R(1) <= p.nPositions/2) == (s.R(2) <= p.nPositions/2)
    why = 'rule 6: T2s must be in opposite hemifields'; return
end
if p.rule.allQuadrants && numel(unique(floor(([s.P s.R s.C] - 1) / (p.nPositions/4)))) < 4
    why = 'rule 7: positions must cover all quadrants'; return
end
ok = true;
why = '';
end
