"""Trial lists and positions (no screen needed).

A translation of makeTrialOrder.m, makeLearningTrials.m, addTargets.m,
makePositions.m, addPositions.m and checkLearningTrials.m.
"""
import math
import random


# ---------------------------------------------------------------- calibration
def make_calib_trials(P):
    """All calibration trials in one list, shuffled together (as in the original code)."""
    nPresent = P['nPositions'] * P['nTrialsPerPosition']
    nAbsent = int(round(nPresent / (1 - P['propAbsent']))) - nPresent
    allPositions = list(range(1, P['nPositions'] + 1)) * P['nTrialsPerPosition'] + [0] * nAbsent
    random.shuffle(allPositions)
    trials = []
    for tarPos in allPositions:
        trials.append({'tarPos': tarPos, 'cond': 1 if tarPos > 0 else 0, 'ITI': random.choice(P['ITI'])})
    return trials


# ---------------------------------------------------------------- trial order
def make_trial_order(nKinds, firstKind):
    """Order in which every kind follows every kind exactly once (nKinds*nKinds + 1 trials).
    Kinds are numbered 1..nKinds. Method: try, and start again when stuck."""
    nTransitions = nKinds * nKinds
    while True:
        used = [[0] * (nKinds + 1) for _ in range(nKinds + 1)]
        order = [firstKind]
        stuck = False
        for _ in range(nTransitions):
            current = order[-1]
            possible = [k for k in range(1, nKinds + 1) if used[current][k] == 0]
            if not possible:
                stuck = True
                break
            nxt = random.choice(possible)
            used[current][nxt] = 1
            order.append(nxt)
        if not stuck:
            return order


def compute_transitions(order, nKinds):
    transMat = [[0] * nKinds for _ in range(nKinds)]
    for i in range(1, len(order)):
        transMat[order[i - 1] - 1][order[i] - 1] += 1
    return transMat


def make_trials(kinds, nPerVis, subjectNum):
    """Trial list: miniblocks alternate between seen and unseen;
    odd participant numbers start with seen, even numbers with unseen."""
    nKinds = len(kinds)
    if subjectNum % 2 == 1:
        visOrder = ['seen', 'unseen']
    else:
        visOrder = ['unseen', 'seen']

    # which kind starts each miniblock: balanced over the miniblocks of a visibility
    firstKinds = {}
    for vis in visOrder:
        first = (list(range(1, nKinds + 1)) * int(math.ceil(nPerVis / float(nKinds))))[:nPerVis]
        random.shuffle(first)
        firstKinds[vis] = first

    trials = []
    for miniblocki in range(1, 2 * nPerVis + 1):
        vis = visOrder[(miniblocki - 1) % 2]
        miniblockOfVis = (miniblocki - 1) // 2
        order = make_trial_order(nKinds, firstKinds[vis][miniblockOfVis])
        for triali, kind in enumerate(order, start=1):
            trials.append({'Miniblock_no': miniblocki, 'Trial_no': triali, 'visibility': vis,
                           'kind': kind, 'kindName': kinds[kind - 1]})
    return trials


# ---------------------------------------------------------------- targets
def _balanced(values, n):
    """n values taken in turn from 'values' (1 2 1 2 ...), in random order."""
    out = (list(values) * int(math.ceil(n / float(len(values)))))[:n]
    random.shuffle(out)
    return out


def add_targets(trials, P):
    """Decides for every trial which targets are shown (T1source, T2location, trialType)."""
    t1Sources = ['duplet1', 'duplet2', 'control1', 'control2']
    for vis in ['seen', 'unseen']:
        def index_of(kindName):
            return [i for i, t in enumerate(trials) if t['visibility'] == vis and t['kindName'] == kindName]

        # duplets: T2 always at the location of its duplet
        for d in (1, 2):
            for i in index_of('duplet%d' % d):
                trials[i].update(T1source='duplet%d' % d, T1present=1, T2present=1, T2location=d,
                                 trialType='valid')

        # controls: T2 at location 1 or 2 (half each)
        for c in (1, 2):
            index = index_of('control%d' % c)
            locations = _balanced([1, 2], len(index))
            for i, loc in zip(index, locations):
                trials[i].update(T1source='control%d' % c, T1present=1, T2present=1, T2location=loc,
                                 trialType='control')

        # deviants (test phase only): T1 of a duplet, T2 at the location of the OTHER duplet
        index = index_of('deviant')
        random.shuffle(index)
        sources = ([1, 2] * int(math.ceil(len(index) / 2.0)))[:len(index)]
        for i, s in zip(index, sources):
            trials[i].update(T1source='duplet%d' % s, T1present=1, T2present=1, T2location=3 - s,
                             trialType='deviant')

        # target-absent: either T1 or T2 is missing
        index = index_of('targetAbsent')
        random.shuffle(index)
        nT1absent = int(math.floor(P['propT1absent'] * len(index) + 0.5))
        indexT1absent = index[:nT1absent]
        indexT2absent = index[nT1absent:]

        locations = _balanced([1, 2], len(indexT1absent))
        for i, loc in zip(indexT1absent, locations):
            trials[i].update(T1source='none', T1present=0, T2present=1, T2location=loc,
                             trialType='T1absent')

        sources = _balanced([1, 2, 3, 4], len(indexT2absent))
        for i, s in zip(indexT2absent, sources):
            trials[i].update(T1source=t1Sources[s - 1], T1present=1, T2present=0, T2location=0,
                             trialType='omission' if s <= 2 else 'controlOmission')
    return trials


# ---------------------------------------------------------------- positions
def make_positions(P, subjectNum):
    """Positions of one participant: for seen and for unseen miniblocks 2 duplet T1s,
    2 control T1s and 2 T2 locations. Random, but they follow the rules:
      1 no position is used twice
      2 each set covers all four quadrants
      3 fixed jump sizes (jumpsA / jumpsB), swapped between seen and unseen every 2 participants
      4 one clockwise and one counter-clockwise duplet per set
      5 (if leftRightRule) T2s left and right, both duplet T1s on the same side
    Positions are numbered 1-16 clockwise, starting at the top (1-8 right, 9-16 left)."""
    n = P['nPositions']
    pairNumber = int(math.ceil(subjectNum / 2.0))
    if pairNumber % 2 == 1:
        jumps = {'seen': P['jumpsA'], 'unseen': P['jumpsB']}
    else:
        jumps = {'seen': P['jumpsB'], 'unseen': P['jumpsA']}

    while True:
        allRulesOK = True
        pos = {}
        for vis in ['seen', 'unseen']:
            theseJumps = list(jumps[vis])
            random.shuffle(theseJumps)
            direction = random.choice([[1, -1], [-1, 1]])
            dupletT1 = [random.randint(1, n), random.randint(1, n)]
            T2 = [(dupletT1[k] + direction[k] * theseJumps[k] - 1) % n + 1 for k in range(2)]
            controlT1 = [random.randint(1, n), random.randint(1, n)]
            thisSet = dupletT1 + controlT1 + T2

            quadrants = set(int(math.ceil(p / (n / 4.0))) for p in thisSet)
            if len(quadrants) < 4:
                allRulesOK = False

            if P['leftRightRule']:
                isLeft = [p > n / 2 for p in thisSet]
                if isLeft[4] == isLeft[5]:      # both T2 locations on the same side
                    allRulesOK = False
                if isLeft[0] != isLeft[1]:      # duplet T1s on different sides
                    allRulesOK = False

            pos[vis] = {'dupletT1': dupletT1, 'controlT1': controlT1, 'T2': T2,
                        'jumps': [direction[k] * theseJumps[k] for k in range(2)], 'all': thisSet}

        allTwelve = pos['seen']['all'] + pos['unseen']['all']
        if len(set(allTwelve)) < len(allTwelve):
            allRulesOK = False
        if allRulesOK:
            pos['subjectNum'] = subjectNum
            return pos


def add_positions(trials, pos):
    """Gives every trial its positions (0 = this target is not shown)."""
    for t in trials:
        thisSet = pos[t['visibility']]
        source = t['T1source']
        if source in ('duplet1', 'duplet2'):
            k = int(source[-1]) - 1
            t['T1position'] = thisSet['dupletT1'][k]
            t['predictedT2position'] = thisSet['T2'][k]
        elif source in ('control1', 'control2'):
            k = int(source[-1]) - 1
            t['T1position'] = thisSet['controlT1'][k]
            t['predictedT2position'] = 0
        else:
            t['T1position'] = 0
            t['predictedT2position'] = 0
        if t['T2present'] == 1:
            t['T2position'] = thisSet['T2'][t['T2location'] - 1]
        else:
            t['T2position'] = 0
    return trials


# ---------------------------------------------------------------- check
def check_trials(trials, kinds):
    """Prints an overview of the trial list and checks the transitions."""
    nKinds = len(kinds)
    typeNames = ['valid', 'control', 'deviant', 'T1absent', 'omission', 'controlOmission']
    nMiniblocks = max(t['Miniblock_no'] for t in trials)
    ok = True
    print('')
    print('%d trials in %d miniblocks. The first miniblock is %s.' % (len(trials), nMiniblocks,
                                                                     trials[0]['visibility']))
    print('')
    print('Trials per trial type:')
    print('%-18s %8s %8s' % ('', 'seen', 'unseen'))
    for name in typeNames:
        nSeen = sum(1 for t in trials if t['visibility'] == 'seen' and t['trialType'] == name)
        nUnseen = sum(1 for t in trials if t['visibility'] == 'unseen' and t['trialType'] == name)
        print('%-18s %8d %8d' % (name, nSeen, nUnseen))
    print('%-18s %8d %8d' % ('total', sum(1 for t in trials if t['visibility'] == 'seen'),
                             sum(1 for t in trials if t['visibility'] == 'unseen')))

    for m in range(1, nMiniblocks + 1):
        order = [t['kind'] for t in trials if t['Miniblock_no'] == m]
        transMat = compute_transitions(order, nKinds)
        if len(set(v for row in transMat for v in row)) != 1:
            ok = False
            print('WARNING: transition probabilities are not uniform in miniblock %d!' % m)
    if ok:
        print('OK: in every miniblock, every entry of the list follows every entry equally often.')
    print('')
    return ok
