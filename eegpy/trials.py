"""Trial lists and positions (no screen needed).

The duplets follow the rules of the original sequence generator: four duplets per visibility.
"""
import itertools
import math
import os
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
    """n values taken in turn from 'values' (1 2 3 4 1 2 ...), in random order."""
    out = (list(values) * int(math.ceil(n / float(len(values)))))[:n]
    random.shuffle(out)
    return out


def add_targets(trials, P):
    """Decides for every trial which targets are shown.
    It adds: T1duplet   (1-4) the duplet whose T1 is shown
             T2location (1-4) the duplet whose T2 position is used, 0 = T2 is missing
             trialType  'valid', 'omission' or 'deviant'
    T1 is shown on every trial."""
    nDuplets = P['nDuplets']
    for vis in ['seen', 'unseen']:
        def index_of(kindName):
            return [i for i, t in enumerate(trials) if t['visibility'] == vis and t['kindName'] == kindName]

        # duplets: T1 of the duplet, T2 at the position of the same duplet
        for d in range(1, nDuplets + 1):
            for i in index_of('duplet%d' % d):
                trials[i].update(T1duplet=d, T2location=d, trialType='valid')

        # omissions: T1 of one of the duplets (each duplet equally often), T2 is missing
        index = index_of('omission')
        sources = _balanced(range(1, nDuplets + 1), len(index))
        for i, d in zip(index, sources):
            trials[i].update(T1duplet=d, T2location=0, trialType='omission')

        # deviants (test phase only): T1 of one duplet, T2 at the position of ANOTHER duplet
        index = index_of('deviant')
        sources = _balanced(range(1, nDuplets + 1), len(index))
        for i, d in zip(index, sources):
            others = [k for k in range(1, nDuplets + 1) if k != d]
            trials[i].update(T1duplet=d, T2location=random.choice(others), trialType='deviant')
    return trials


# ---------------------------------------------------------------- positions
def jump(t1, t2, n=16):
    """Jump from T1 to T2 in positions, the shorter way round (as in the original generator):
    + = clockwise, - = counter-clockwise; half a circle (180 degrees) counts as -8."""
    return (t2 - t1 + n // 2) % n - n // 2


def check_set(duplets, P):
    """Checks the rules for one set of four duplets. duplets = [(T1, T2), (T1, T2), ...]"""
    n = P['nPositions']
    jumps = [jump(t1, t2, n) for (t1, t2) in duplets]

    # two clockwise and two counter-clockwise duplets
    if sum(1 for j in jumps if j < 0) != 2:
        return False
    # four different jump sizes
    if len(set(abs(j) for j in jumps)) != 4:
        return False
    # clockwise and counter-clockwise jumps add up to zero
    if sum(jumps) != 0:
        return False
    # all four quadrants (1-4, 5-8, 9-12, 13-16) are used
    positions = [p for d in duplets for p in d]
    if len(set((p - 1) // (n // 4) for p in positions)) < 4:
        return False

    # sides: positions 1-8 are on the right, 9-16 on the left
    sides = [('R' if t1 <= n // 2 else 'L', 'R' if t2 <= n // 2 else 'L') for (t1, t2) in duplets]
    if P['sideRule'] == 'crossed':
        # one duplet of each kind: right->right, left->left, right->left, left->right
        if len(set(sides)) != 4:
            return False
    elif P['sideRule'] == 'rightToLeft':
        # every T1 on the right, every T2 on the left (as in the original sequence file)
        if any(s != ('R', 'L') for s in sides):
            return False
    else:
        raise ValueError("P['sideRule'] must be 'crossed' or 'rightToLeft'")

    # no T2 directly next to the vertical midline (not possible with 'rightToLeft')
    if P['t2AwayFromMidline'] and P['sideRule'] != 'rightToLeft':
        midline = [1, n // 2, n // 2 + 1, n]
        if any(t2 in midline for (t1, t2) in duplets):
            return False
    return True


def valid_sets(eight, P):
    """All ways to make four duplets out of eight positions that pass check_set."""
    found = []
    for t1s in itertools.combinations(eight, 4):            # which four positions are T1 ...
        rest = [p for p in eight if p not in t1s]
        for t2s in itertools.permutations(rest):             # ... and which T2 goes with which T1
            duplets = list(zip(t1s, t2s))
            if check_set(duplets, P):
                found.append(duplets)
    return found


def build_duplet_list(P):
    """All combinations of duplets that pass the rules (as the original generator does).
    Each combination is a list of 16 numbers: T1, T2 of the four seen duplets, then T1, T2 of
    the four unseen duplets. Together a combination uses each of the 16 positions once.
    This takes a few seconds; the result is saved by write_duplet_list."""
    n = P['nPositions']
    everything = set(range(1, n + 1))
    setsOf = {}                                   # eight positions -> all valid sets of four duplets
    for eight in itertools.combinations(range(1, n + 1), n // 2):
        if sum(1 for p in eight if p <= n // 2) != n // 4:
            continue                              # both side rules need 4 right and 4 left positions
        found = valid_sets(list(eight), P)
        if found:
            setsOf[frozenset(eight)] = found

    rows = []
    for eight in sorted(setsOf, key=sorted):
        others = frozenset(everything - eight)    # the unseen set gets the other eight positions
        if others in setsOf:
            for seenSet in setsOf[eight]:
                for unseenSet in setsOf[others]:
                    rows.append([p for d in seenSet for p in d] + [p for d in unseenSet for p in d])
    return rows


def duplet_list_file():
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), 'duplet_list.csv')


def rules_label(P):
    """One line that says with which rules a list was made (first line of the file)."""
    return '# sideRule=%s t2AwayFromMidline=%s' % (P['sideRule'], P['t2AwayFromMidline'])


def write_duplet_list(P):
    """Builds the list and saves it as duplet_list.csv next to this file."""
    rows = build_duplet_list(P)
    with open(duplet_list_file(), 'w') as f:
        f.write(rules_label(P) + '\n')
        f.write('seenT1_1,seenT2_1,seenT1_2,seenT2_2,seenT1_3,seenT2_3,seenT1_4,seenT2_4,'
                'unseenT1_1,unseenT2_1,unseenT1_2,unseenT2_2,unseenT1_3,unseenT2_3,unseenT1_4,unseenT2_4\n')
        for row in rows:
            f.write(','.join(str(p) for p in row) + '\n')
    return len(rows)


def read_duplet_list(P):
    """Reads duplet_list.csv. If the file is missing, or was made with other rules than those
    in params.py, it is made again first."""
    fileName = duplet_list_file()
    upToDate = False
    if os.path.isfile(fileName):
        with open(fileName) as f:
            upToDate = (f.readline().strip() == rules_label(P))
    if not upToDate:
        print('Making the list of duplet combinations for the current rules (takes a few seconds) ...')
        nRows = write_duplet_list(P)
        print('duplet_list.csv now has %d combinations.' % nRows)
    with open(fileName) as f:
        lines = f.read().splitlines()[2:]         # skip the rules line and the column names
    return [[int(p) for p in line.split(',')] for line in lines]


def make_positions(P, subjectNum):
    """The duplets of one participant: one combination picked at random from duplet_list.csv
    (every combination has the same chance), as in the original code."""
    row = random.choice(read_duplet_list(P))
    pos = {'subjectNum': subjectNum}
    for vis, numbers in (('seen', row[:8]), ('unseen', row[8:])):
        duplets = [(numbers[i], numbers[i + 1]) for i in range(0, 8, 2)]
        random.shuffle(duplets)                   # which one is called duplet 1, 2, 3, 4
        pos[vis] = {'T1': [d[0] for d in duplets], 'T2': [d[1] for d in duplets],
                    'jumps': [jump(d[0], d[1], P['nPositions']) for d in duplets]}
    return pos


def add_positions(trials, pos):
    """Gives every trial its positions:
    T1position, T2position (0 = T2 is missing) and predictedT2position (where T2 belongs after this T1)."""
    for t in trials:
        thisSet = pos[t['visibility']]
        t['T1position'] = thisSet['T1'][t['T1duplet'] - 1]
        t['predictedT2position'] = thisSet['T2'][t['T1duplet'] - 1]
        if t['T2location'] > 0:
            t['T2position'] = thisSet['T2'][t['T2location'] - 1]
        else:
            t['T2position'] = 0
    return trials


# ---------------------------------------------------------------- check
def check_trials(trials, kinds):
    """Prints an overview of the trial list and checks the transitions."""
    nKinds = len(kinds)
    typeNames = ['valid', 'omission', 'deviant']
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
