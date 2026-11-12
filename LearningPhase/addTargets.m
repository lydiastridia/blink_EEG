% This function decides, for every trial, which targets are shown
% It adds these fields to the trial list:
%   T1source    whose T1 position is used: 'duplet1', 'duplet2', 'control1',
%               'control2', or 'none' when T1 is missing
%   T1present   1 = T1 is shown, 0 = T1 is missing
%   T2present   1 = T2 is shown, 0 = T2 is missing (omission)
%   T2location  1 or 2: at which of the two T2 locations T2 appears (0 = no T2)
%   trialType   'valid', 'control', 'T1absent', 'omission' or 'controlOmission'
%
% Rules (separately for seen and unseen miniblocks):
%   duplet1 -> T2 always at location 1;  duplet2 -> T2 always at location 2
%   control1, control2 -> T2 at control location 1 in half of the trials, at control location 2 in the other half
%   targetAbsent -> in a proportion of the trials T1 is missing (T2 at duplet location 1 or 2, half each),
%                   in the other trials T2 is missing (T1 from duplet1, duplet2,
%                   control1 or control2, equally often)
%
% Usage: trials = addTargets(trials, params)

function [trials] = addTargets(trials, params)

visNames = {'seen', 'unseen'};
t1Sources = {'duplet1', 'duplet2', 'control1', 'control2'};

for visi = 1 : 2

    %% DUPLETS: T1 and T2 are both shown, T2 at the location of its duplet
    index = find(strcmp({trials.visibility}, visNames{visi}) & strcmp({trials.kindName}, 'duplet1'));
    for i = 1 : length(index)
        trials(index(i)).T1source = 'duplet1';
        trials(index(i)).T1present = 1;
        trials(index(i)).T2present = 1;
        trials(index(i)).T2location = 1;
        trials(index(i)).trialType = 'valid';
    end

    index = find(strcmp({trials.visibility}, visNames{visi}) & strcmp({trials.kindName}, 'duplet2'));
    for i = 1 : length(index)
        trials(index(i)).T1source = 'duplet2';
        trials(index(i)).T1present = 1;
        trials(index(i)).T2present = 1;
        trials(index(i)).T2location = 2;
        trials(index(i)).trialType = 'valid';
    end

    %% CONTROLS: T1 and T2 are both shown, T2 at location 1 or 2 (half each)
    for controli = 1 : 2
        controlName = ['control' num2str(controli)]; %'control1' or 'control2'
        index = find(strcmp({trials.visibility}, visNames{visi}) & strcmp({trials.kindName}, controlName));

        locations = repmat([1 2], 1, ceil(length(index) / 2)); %1 2 1 2 ...
        locations = locations(1 : length(index)); %keep as many as there are trials
        locations = locations(randperm(length(locations))); %random order

        for i = 1 : length(index)
            trials(index(i)).T1source = controlName;
            trials(index(i)).T1present = 1;
            trials(index(i)).T2present = 1;
            trials(index(i)).T2location = locations(i);
            trials(index(i)).trialType = 'control';
        end
    end

    %% DEVIANTS (test phase only): T1 of a duplet, but T2 at the location of the OTHER duplet
    index = find(strcmp({trials.visibility}, visNames{visi}) & strcmp({trials.kindName}, 'deviant'));
    index = index(randperm(length(index))); %random order, so that it is random which duplet is used on which trial

    sources = repmat([1 2], 1, ceil(length(index) / 2)); %1 2 1 2 ... (half from duplet1, half from duplet2)
    sources = sources(1 : length(index));

    for i = 1 : length(index)
        trials(index(i)).T1source = ['duplet' num2str(sources(i))]; %'duplet1' or 'duplet2'
        trials(index(i)).T1present = 1;
        trials(index(i)).T2present = 1;
        trials(index(i)).T2location = 3 - sources(i); %the other location: duplet1 -> location 2, duplet2 -> location 1
        trials(index(i)).trialType = 'deviant';
    end

    %% TARGET-ABSENT: either T1 or T2 is missing
    index = find(strcmp({trials.visibility}, visNames{visi}) & strcmp({trials.kindName}, 'targetAbsent'));
    index = index(randperm(length(index))); %random order, so that it is random which trials miss T1

    nT1absent = round(params.design.propT1absent * length(index)); %number of trials without T1
    indexT1absent = index(1 : nT1absent);
    indexT2absent = index(nT1absent + 1 : end);

    % T1 missing: mask only, then T2 at location 1 or 2 (half each)
    locations = repmat([1 2], 1, ceil(length(indexT1absent) / 2));
    locations = locations(1 : length(indexT1absent));
    locations = locations(randperm(length(locations)));

    for i = 1 : length(indexT1absent)
        trials(indexT1absent(i)).T1source = 'none';
        trials(indexT1absent(i)).T1present = 0;
        trials(indexT1absent(i)).T2present = 1;
        trials(indexT1absent(i)).T2location = locations(i);
        trials(indexT1absent(i)).trialType = 'T1absent';
    end

    % T2 missing (omission): T1 from duplet1, duplet2, control1 or control2, equally often
    sources = repmat(1 : 4, 1, ceil(length(indexT2absent) / 4)); %1 2 3 4 1 2 3 4 ...
    sources = sources(1 : length(indexT2absent));
    sources = sources(randperm(length(sources)));

    for i = 1 : length(indexT2absent)
        trials(indexT2absent(i)).T1source = t1Sources{sources(i)};
        trials(indexT2absent(i)).T1present = 1;
        trials(indexT2absent(i)).T2present = 0;
        trials(indexT2absent(i)).T2location = 0;
        if sources(i) <= 2 %T1 of a duplet
            trials(indexT2absent(i)).trialType = 'omission';
        else %T1 of a control
            trials(indexT2absent(i)).trialType = 'controlOmission';
        end
    end
end
end
