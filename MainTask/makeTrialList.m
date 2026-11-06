function trials = makeTrialList(seq, p)
%MAKETRIALLIST  Full trial list (learning + test phase) for one participant.
%
%   trials = makeTrialList(seq, p)   seq from makeSequences, p from mainParams
%
%   Each element of trials is one trial with fields:
%     phase        'learning' or 'test'
%     miniblock    miniblock number within the phase
%     visibility   'seen' (weak T1 mask) or 'unseen' (strong T1 mask)
%     type         learning: 'predictive' | 'control' | 't1absent'
%                  test:     'valid' | 'deviant' | 'omission' | 'control' |
%                            'controlOmission' | 't1absent'
%     duplet       1 or 2 for trials with a predictive T1, otherwise 0
%     t1Pos        position of T1 (0 = no T1, mask only)
%     t2Pos        position of T2 (0 = omitted: blank screen, nothing appears)
%     trigStart, trigT1, trigT2   EEG trigger codes (trigT2 is sent at the
%                  moment T2 appears, or would have appeared on omissions)
%
%   The control condition:
%     'control'          T1 at a control position, T2 at R(1) or R(2) (balanced)
%     'controlOmission'  T1 at a control position, then nothing
%     't1absent'         no T1 (mask only), T2 at R(1) or R(2) (balanced)
%   Control T2s use the same two locations as the predictive duplets, so T2
%   locations are equally frequent and only the information in T1 differs.

trials = [];
for phaseName = {'learning', 'test'}
    ph = phaseName{1};
    if strcmp(ph, 'learning')
        nMB = p.learn.nMiniblocksPerCond;
    else
        nMB = p.test.nMiniblocksPerCond;
    end
    order = miniblockOrder(seq.startCondition, nMB, p);
    for mb = 1:numel(order)
        vis = order{mb};
        list = miniblockTrials(ph, seq.(vis), p);
        list = shuffleWithConstraints(list, p);
        for t = 1:numel(list)
            x = list(t);
            x.phase      = ph;
            x.miniblock  = mb;
            x.visibility = vis;
            x = addTriggers(x, vis, p);
            trials = [trials, orderFields(x)]; %#ok<AGROW>
        end
    end
end
end


function order = miniblockOrder(startCondition, nPerCond, p)
% Strict alternation of seen and unseen miniblocks.
if ~p.alternate
    error('makeTrialList:alternation', 'Only alternation is implemented (point 4 still open).');
end
if strcmp(startCondition, 'seen')
    pair = {'seen', 'unseen'};
else
    pair = {'unseen', 'seen'};
end
order = repmat(pair, 1, nPerCond);
end


function list = miniblockTrials(ph, s, p)
% Unshuffled trials of one miniblock for the set s (fields P, R, C).
list = struct('type', {}, 'duplet', {}, 't1Pos', {}, 't2Pos', {});
if strcmp(ph, 'learning')
    q = p.learn;
    for k = 1:2
        list = addN(list, q.predictivePerDuplet, 'predictive', k, s.P(k), s.R(k));
    end
    for i = 1:2
        for j = 1:2
            list = addN(list, q.controlPerPair, 'control', 0, s.C(i), s.R(j));
        end
    end
    for j = 1:2
        list = addN(list, q.t1AbsentPerT2, 't1absent', 0, 0, s.R(j));
    end
else
    q = p.test;
    for k = 1:2
        list = addN(list, q.validPerDuplet,    'valid',    k, s.P(k), s.R(k));
        list = addN(list, q.deviantPerDuplet,  'deviant',  k, s.P(k), s.R(3 - k));
        list = addN(list, q.omissionPerDuplet, 'omission', k, s.P(k), 0);
    end
    for i = 1:2
        for j = 1:2
            list = addN(list, q.controlPerPair, 'control', 0, s.C(i), s.R(j));
        end
        list = addN(list, q.controlOmissionPerControl, 'controlOmission', 0, s.C(i), 0);
    end
    for j = 1:2
        list = addN(list, q.t1AbsentPerT2, 't1absent', 0, 0, s.R(j));
    end
end
end


function list = addN(list, n, type, duplet, t1, t2)
for i = 1:n
    list(end+1).type = type; %#ok<AGROW>
    list(end).duplet = duplet;
    list(end).t1Pos  = t1;
    list(end).t2Pos  = t2;
end
end


function list = shuffleWithConstraints(list, p)
% Random order; reshuffle until the order rules in p.order hold.
viol = {'deviant', 'omission', 'controlOmission'};
for attempt = 1:100000
    list = list(randperm(numel(list)));
    types = {list.type};
    isV = ismember(types, viol);
    if p.order.firstTrialNoViolation && isV(1)
        continue
    end
    if longestRun(isV) > p.order.maxViolationsInRow
        continue
    end
    if longestSameRun(types) > p.order.maxSameTypeInRow
        continue
    end
    return
end
error('makeTrialList:order', 'Could not satisfy the order rules.');
end


function r = longestRun(x)
r = 0; c = 0;
for i = 1:numel(x)
    if x(i), c = c + 1; else, c = 0; end
    r = max(r, c);
end
end


function r = longestSameRun(types)
r = 1; c = 1;
for i = 2:numel(types)
    if strcmp(types{i}, types{i-1}), c = c + 1; else, c = 1; end
    r = max(r, c);
end
end


function t = addTriggers(t, vis, p)
off = 0;
if strcmp(vis, 'unseen')
    off = p.trig.unseenOffset;
end
g = p.trig;
switch t.type
    case {'predictive', 'valid'},  c1 = g.t1Predictive; c2 = g.t2Valid;
    case 'deviant',                c1 = g.t1Predictive; c2 = g.t2Deviant;
    case 'omission',               c1 = g.t1Predictive; c2 = g.omission;
    case 'control',                c1 = g.t1Control;    c2 = g.t2Control;
    case 'controlOmission',        c1 = g.t1Control;    c2 = g.controlOmission;
    case 't1absent',               c1 = g.t1Absent;     c2 = g.t2AfterT1Absent;
end
t.trigStart = g.trialStart + off;
t.trigT1    = c1 + off;
t.trigT2    = c2 + off;
end


function list = orderFields(list)
f = {'phase', 'miniblock', 'visibility', 'type', 'duplet', 't1Pos', 't2Pos', ...
     'trigStart', 'trigT1', 'trigT2'};
list = orderfields(list, f);
end
