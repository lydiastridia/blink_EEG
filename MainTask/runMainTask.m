function runMainTask()
%RUNMAINTASK  Main task: learning phase, then test phase (EEG).
%
%   Type  runMainTask  in the Command Window. Settings are in mainParams.m.
%   Run the calibration first: the mask contrasts are read from
%   Data/Calibration/P<ID>_S<session>_threshold.mat (or typed in if missing).
%
%   Trial: fixation -> T1 (16.7 ms) -> ISI -> mask (233 ms; weak in seen
%   blocks, strong in unseen blocks) -> blank until 1.2 s after T1 -> T2
%   (50 ms, unmasked) or nothing (omission) -> 0.8 s blank -> rating of T1
%   visibility (1-4) -> ITI.
%   Learning phase: predictive, control and T1-absent trials, plus a cover
%   task (SPACE when T2 is tinted). Test phase: valid, deviant, omission,
%   control, control-omission and T1-absent trials.
%   ESCAPE stops at any response or instruction screen; data are saved.

p = mainParams();

%% Participant details
info = askParticipantInfo();
if ~exist(p.dataDir, 'dir')
    mkdir(p.dataDir);
end
base     = sprintf('P%s_S%s', info.id, info.session);
outFile  = fullfile(p.dataDir, [base '_main.mat']);
if exist(outFile, 'file')
    answer = input(sprintf('%s already exists. Overwrite? (y/n): ', outFile), 's');
    if ~strcmpi(answer, 'y')
        disp('Stopped. Use another participant number or session.');
        return
    end
end

%% Mask contrasts from the calibration (fixed for the whole task)
[contrast, calibSource] = loadContrasts(p, base);
fprintf('Mask contrast: seen blocks %.3f, unseen blocks %.3f (%s)\n', ...
    contrast.seen, contrast.unseen, calibSource);

%% Design: duplets, control positions, trial list
seq    = makeSequences(str2double(info.id), p);
trials = makeTrialList(seq, p);
trials = addOddballs(trials, p);
if p.demo
    trials = demoSubset(trials, p);
    fprintf('DEMO: %d trials (set p.demo = false in mainParams for the full task).\n', numel(trials));
end
fprintf('Unseen set: duplets %d->%d, %d->%d, controls %d, %d | Seen set: duplets %d->%d, %d->%d, controls %d, %d\n', ...
    seq.unseen.P(1), seq.unseen.R(1), seq.unseen.P(2), seq.unseen.R(2), seq.unseen.C, ...
    seq.seen.P(1), seq.seen.R(1), seq.seen.P(2), seq.seen.R(2), seq.seen.C);

main = struct();
main.info        = info;
main.params      = p;
main.seq         = seq;
main.contrast    = contrast;
main.calibSource = calibSource;
main.planned     = trials;
main.results     = [];
main.startTime   = datestr(now);

trig = struct('mode', 'none', 'h', [], 'pulse', 0, 'print', false);
try
    %% Screen and triggers
    KbName('UnifyKeyNames');
    keys.continue = KbName(p.continueKey);
    keys.oddball  = KbName(p.oddballKey);
    keys.abort    = KbName(p.abortKey);

    clear Screen
    Screen('Preference', 'SkipSyncTests', double(p.testMode));
    avoidMacVulkan(p);
    [w, rect] = Screen('OpenWindow', max(Screen('Screens')), p.bgColor);
    ifiMeasured = Screen('GetFlipInterval', w);
    nominalHz   = Screen('NominalFrameRate', w);
    if nominalHz > 0, ifi = 1 / nominalHz; else, ifi = ifiMeasured; end
    Screen('TextSize', w, p.textSize);
    Screen('TextFont', w, 'Arial');
    HideCursor;
    Priority(MaxPriority(w));
    [cx, cy] = RectCenter(rect);
    geom = makeGeometry(p, cx, cy);
    fr.t1   = max(1, round(p.tT1   / ifi));
    fr.isi  = max(1, round(p.tISI  / ifi));
    fr.mask = max(1, round(p.tMask / ifi));
    fr.t2   = max(1, round(p.tT2   / ifi));
    main.screen = struct('ifi', ifi, 'ifiMeasured', ifiMeasured, 'resolution', rect(3:4), 'frames', fr);
    trig = triggerOpen(p);

    %% Phases and miniblocks
    phases = {'learning', 'test'};
    for ph = 1:2
        phase = phases{ph};
        P = trials(strcmp({trials.phase}, phase));
        showPhaseInstructions(w, p, phase);
        waitKey(keys.continue, keys);
        if strcmp(phase, 'learning'), code = p.trig.learningStart; else, code = p.trig.testStart; end
        sendTrigger(trig, code);

        for mb = unique([P.miniblock])
            M = P([P.miniblock] == mb);
            showText(w, p, sprintf(['%s phase, block %d of %d\n\n' ...
                'Keep your eyes on the central cross.\n\nPress SPACE to start.'], ...
                capitalise(phase), mb, max([P.miniblock])));
            waitKey(keys.continue, keys);
            if strcmp(M(1).visibility, 'seen'), code = p.trig.miniblockSeen; else, code = p.trig.miniblockUnseen; end
            sendTrigger(trig, code);

            for t = 1:numel(M)
                r = runTrial(w, p, geom, keys, ifi, fr, M(t), contrast.(M(t).visibility), trig);
                main.results = [main.results, r];
                if p.testMode
                    fprintf('%-8s mb %2d %-6s %-15s T1 %2d T2 %2d mask %.2f | rating %g%s\n', ...
                        r.phase, r.miniblock, r.visibility, r.type, r.t1Pos, r.t2Pos, ...
                        r.maskContrast, r.rating, oddballText(r));
                end
            end
            save(outFile, 'main');                % after every miniblock
        end
    end

    main.endTime = datestr(now);
    save(outFile, 'main');
    showText(w, p, 'Thank you! The task is finished.\n\nPlease wait for the experimenter.\n\n(Experimenter: press SPACE)');
    waitKey(keys.continue, keys);
    cleanupAll(trig);
    printSummary(main);
    fprintf('Saved: %s\n\n', outFile);

catch err
    if ~isempty(main.results)
        save(outFile, 'main');
        fprintf('\nData so far saved in %s\n', outFile);
    end
    cleanupAll(trig);
    if strcmp(err.identifier, 'main:abort')
        disp('Main task stopped with ESCAPE.');
    else
        rethrow(err);
    end
end
end


%% ======================================================================
%% One trial
%% ======================================================================

function r = runTrial(w, p, geom, keys, ifi, fr, tr, maskContrast, trig)
r = tr;                                   % planned trial: phase, type, positions, triggers
r.maskContrast = maskContrast;

% Fixation (jittered)
drawFixation(w, p, geom);
tFix = Screen('Flip', w);
sendTrigger(trig, tr.trigStart);
fixDur = p.tFixation(1) + rand * diff(p.tFixation);

% T1 (on T1-absent trials only the fixation cross; the trigger still marks the moment)
drawFixation(w, p, geom);
if tr.t1Pos > 0
    drawSquare(w, p, geom, tr.t1Pos, p.t1Color);
end
tT1 = Screen('Flip', w, tFix + fixDur - 0.5 * ifi);
sendTrigger(trig, tr.trigT1);

% ISI
drawFixation(w, p, geom);
tISI = Screen('Flip', w, tT1 + (fr.t1 - 0.5) * ifi);

% Mask (fixed contrast for this visibility condition)
drawFixation(w, p, geom);
drawMask(w, p, geom, maskContrast);
tMask = Screen('Flip', w, tISI + (fr.isi - 0.5) * ifi);
sendTrigger(trig, p.trig.mask);

% Delay (blank with fixation)
drawFixation(w, p, geom);
Screen('Flip', w, tMask + (fr.mask - 0.5) * ifi);

% T2 (unmasked) or omission: nothing appears, but the trigger marks the moment
drawFixation(w, p, geom);
if tr.t2Pos > 0
    if tr.oddball, col = p.oddballColor; else, col = p.t2Color; end
    drawSquare(w, p, geom, tr.t2Pos, col);
end
tT2 = Screen('Flip', w, tT1 + p.tSOA - 0.5 * ifi);
sendTrigger(trig, tr.trigT2);

% T2 off, then blank window (EEG response; cover-task SPACE presses)
drawFixation(w, p, geom);
tT2off = Screen('Flip', w, tT2 + (fr.t2 - 0.5) * ifi);
r.oddballPressed = false;
r.oddballRT      = NaN;
tEnd = tT2 + p.tPostT2;
while GetSecs < tEnd
    [down, secs, code] = KbCheck;
    if down
        if code(keys.abort)
            error('main:abort', 'Stopped with ESCAPE.');
        end
        if strcmp(tr.phase, 'learning') && code(keys.oddball) && ~r.oddballPressed
            r.oddballPressed = true;
            r.oddballRT      = secs - tT2;
        end
    end
    WaitSecs(0.001);
end

% Delayed rating of T1 visibility
DrawFormattedText(w, ['How well did you see the FIRST square\n(the one before the rectangles)?\n\n' ...
    '1 = nothing    2 = glimpse, unsure    3 = weakly    4 = clearly'], ...
    'center', 'center', p.textColor);
Screen('Flip', w);
[r.rating, r.rt, r.keyName] = getRating(keys, p.tRespMax);
if isnan(r.rating)
    sendTrigger(trig, p.trig.noResponse);
else
    sendTrigger(trig, p.trig.rating + r.rating);
end

% ITI
drawFixation(w, p, geom);
Screen('Flip', w);
WaitSecs(p.tITI(1) + rand * diff(p.tITI));
KbReleaseWait;

% Timing record (for checking)
r.tT1 = tT1;
r.tT2 = tT2;
r.t1Duration = tISI - tT1;
r.t2Duration = tT2off - tT2;
r.soa        = tT2 - tT1;
end


%% ======================================================================
%% Design helpers
%% ======================================================================

function trials = addOddballs(trials, p)
% Cover task in the learning phase: in each miniblock, p.oddballProp of the
% trials with a T2 get a tinted T2. Test-phase trials never do.
[trials.oddball] = deal(false);
L = find(strcmp({trials.phase}, 'learning') & [trials.t2Pos] > 0);
for mb = unique([trials(L).miniblock])
    idx = L([trials(L).miniblock] == mb);
    n = round(p.oddballProp * numel(idx));
    pick = idx(randperm(numel(idx), n));
    [trials(pick).oddball] = deal(true);
end
end

function trials = demoSubset(trials, p)
% First p.demoMiniblocks miniblocks per phase, first p.demoTrials trials each.
keep = false(size(trials));
for ph = {'learning', 'test'}
    for mb = 1:p.demoMiniblocks
        idx = find(strcmp({trials.phase}, ph{1}) & [trials.miniblock] == mb);
        keep(idx(1:min(end, p.demoTrials))) = true;
    end
end
trials = trials(keep);
end

function [contrast, source] = loadContrasts(p, base)
% Reads the fixed mask contrasts saved by runCalibration.
f = fullfile(p.calibDir, [base '_threshold.mat']);
if exist(f, 'file')
    c = load(f);
    contrast.seen   = c.contrastSeen;
    contrast.unseen = c.contrastUnseen;
    source = f;
else
    fprintf('No calibration file found (%s).\n', f);
    thr = str2double(askValid('Type the threshold (mask contrast 0-1): ', ...
        @(x) ~isnan(str2double(x)) && str2double(x) > 0 && str2double(x) <= 1, ...
        'Enter a number between 0 and 1.'));
    contrast.seen   = thr * 0.5;              % manuscript factors
    contrast.unseen = min(1, thr * 1.5);
    source = 'typed in';
end
end


%% ======================================================================
%% Screen helpers (same drawing as the calibration)
%% ======================================================================

function geom = makeGeometry(p, cx, cy)
step   = 2 * pi / p.nPositions;
angles = step / 2 + (0:p.nPositions - 1) * step;     % position 1 just right of 12 o'clock
geom.x = cx + p.radius * sin(angles);
geom.y = cy - p.radius * cos(angles);
geom.cx = cx; geom.cy = cy;
L = p.maskRectLong; S = p.maskRectShort; g = p.maskGap;
rects = zeros(4, 4 * p.nPositions);
for i = 1:p.nPositions
    x = geom.x(i); y = geom.y(i);
    rects(:, 4*i-3) = [x - L/2, y - g - S, x + L/2, y - g    ];
    rects(:, 4*i-2) = [x - L/2, y + g,     x + L/2, y + g + S];
    rects(:, 4*i-1) = [x - g - S, y - L/2, x - g,     y + L/2];
    rects(:, 4*i  ) = [x + g,     y - L/2, x + g + S, y + L/2];
end
geom.maskRects = rects;
end

function drawFixation(w, p, geom)
a = p.fixArm;
Screen('DrawLines', w, [-a a 0 0; 0 0 -a a], p.fixLineWidth, p.fixColor, [geom.cx geom.cy]);
end

function drawSquare(w, p, geom, pos, col)
s = p.targetSize;
Screen('FillRect', w, col, CenterRectOnPoint([0 0 s s], geom.x(pos), geom.y(pos)));
end

function drawMask(w, p, geom, contrast)
col = p.bgColor + contrast * (p.maskColorStrong - p.bgColor);
Screen('FillRect', w, col, geom.maskRects);
end

function showPhaseInstructions(w, p, phase)
if strcmp(phase, 'learning')
    txt = ['Part 1\n\n' ...
        'On each trial, a small grey square may flash briefly around the cross,\n' ...
        'followed by a pattern of rectangles.\n' ...
        'About a second later, a brighter square appears.\n\n' ...
        'If the brighter square is REDDISH, press SPACE as fast as you can.\n\n' ...
        'Afterwards, rate how well you saw the FIRST (grey) square:\n' ...
        '1 = nothing   2 = glimpse, unsure   3 = weakly   4 = clearly\n' ...
        'Press 1 only if you had no impression at all.\n\n' ...
        'Keep your eyes on the cross.\n\nPress SPACE to continue.'];
else
    txt = ['Part 2\n\n' ...
        'The trials look the same as before.\n' ...
        'Sometimes the brighter square does not appear.\n' ...
        'You no longer need to look for reddish squares.\n\n' ...
        'After each trial, rate how well you saw the FIRST (grey) square:\n' ...
        '1 = nothing   2 = glimpse, unsure   3 = weakly   4 = clearly\n\n' ...
        'Keep your eyes on the cross.\n\nPress SPACE to continue.'];
end
showText(w, p, txt);
end

function showText(w, p, txt)
DrawFormattedText(w, txt, 'center', 'center', p.textColor);
Screen('Flip', w);
end

function s = capitalise(s)
s(1) = upper(s(1));
end

function t = oddballText(r)
t = '';
if r.oddball || r.oddballPressed
    t = sprintf(' | tinted %d, SPACE %d', r.oddball, r.oddballPressed);
end
end


%% ======================================================================
%% Keyboard and input helpers (as in the calibration)
%% ======================================================================

function info = askParticipantInfo()
info.id = askValid('Participant number: ', @(x) isWholeNumber(x, 1, 999), ...
    'Enter a whole number (1-999). It sets the counterbalancing.');
info.session = askValid('Session number: ', @(x) isWholeNumber(x, 1, 99), 'Enter a whole number (1-99).');
info.age = str2double(askValid('Age: ', @(x) isWholeNumber(x, 16, 99), 'Enter the age as a whole number (16-99).'));
info.gender = askValid('Gender: ', @(x) ~isempty(x), 'Please enter something.');
info.handedness = lower(askValid('Handedness (r/l): ', @(x) any(strcmpi(x, {'r', 'l'})), 'Enter r (right) or l (left).'));
info.language = askValid('Language (e.g., E): ', @(x) ~isempty(x), 'Please enter something.');
end

function s = askValid(prompt, isOk, message)
while true
    s = strtrim(input(prompt, 's'));
    if isOk(s)
        return
    end
    fprintf('  -> %s\n', message);
end
end

function ok = isWholeNumber(x, lo, hi)
v  = str2double(x);
ok = ~isnan(v) && v == round(v) && v >= lo && v <= hi;
end

function [rating, rt, keyName] = getRating(keys, tMax)
rating = NaN; rt = NaN; keyName = '';
tStart = GetSecs;
while GetSecs - tStart < tMax
    [down, secs, code] = KbCheck;
    if down
        if code(keys.abort)
            error('main:abort', 'Stopped with ESCAPE.');
        end
        names = KbName(find(code));
        if ~iscell(names), names = {names}; end
        for n = 1:numel(names)
            nm = names{n};
            if ~isempty(nm) && any(nm(1) == '1234')
                rating = str2double(nm(1)); rt = secs - tStart; keyName = nm;
                return
            end
        end
        keyName = names{1};
    end
    WaitSecs(0.001);
end
end

function waitKey(keyCode, keys)
KbReleaseWait;
while true
    [down, ~, code] = KbCheck;
    if down
        if code(keys.abort)
            error('main:abort', 'Stopped with ESCAPE.');
        end
        if code(keyCode)
            return
        end
    end
    WaitSecs(0.01);
end
end

function cleanupAll(trig)
try
    triggerClose(trig);
catch
end
sca;
ShowCursor;
Priority(0);
end

function avoidMacVulkan(p)
% Test mode on a Mac: stop Psychtoolbox from using the Vulkan display backend,
% which drops frames on macOS 26 (see the calibration).
if p.testMode && ismac
    cv = Screen('Preference', 'ConserveVRAM');
    if isempty(cv), cv = 0; end
    Screen('Preference', 'ConserveVRAM', bitor(cv, 8192));
end
end


%% ======================================================================
%% Summary
%% ======================================================================

function printSummary(main)
R = main.results;
fprintf('\n========== Main task: participant %s, session %s ==========\n', main.info.id, main.info.session);
for vis = {'seen', 'unseen'}
    X = R(strcmp({R.visibility}, vis{1}) & [R.t1Pos] > 0);
    ok = ~isnan([X.rating]);
    fprintf('%-6s blocks: T1 rated seen (2-4) on %.0f%% of trials with a T1 (mask %.3f)\n', ...
        vis{1}, 100 * mean([X(ok).rating] > 1), main.contrast.(vis{1}));
end
L = R(strcmp({R.phase}, 'learning') & [R.t2Pos] > 0);
if ~isempty(L)
    hits = mean([L([L.oddball]).oddballPressed]);
    fa   = mean([L(~[L.oddball]).oddballPressed]);
    fprintf('Cover task: hits %.0f%%, false alarms %.0f%%\n', 100 * hits, 100 * fa);
end
fprintf('Missing ratings: %d of %d\n', sum(isnan([R.rating])), numel(R));
end
