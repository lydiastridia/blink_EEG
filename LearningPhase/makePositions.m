% This function chooses the positions for one participant
%one set of 6 positions for seen miniblocks and one set for unseen miniblocks
%each set has 2 duplet T1 positions, 2 control T1 positions and 2T2 locations
%The positions are currently random and I will have to modify stuff to make them more uniform, but they ave to follow these rules, 
% 4 of them being drawn from the manuscript:
%
%The positions are random, but they have to follow these rules:
% 1 -> the seen and the unseen set share no position
% 2 -> each set covers all four quadrants
% 3 -> the jump sizes (T1 to T2) are fixed (params.pos.jumpsA and jumpsB);
%      which of the two goes to seen is swapped every 2 participants
% 4 -> each set has one clockwise and one counter-clockwise duplet
% 5 -> (only if params.pos.leftRightRule is true) one T2 location is on the
%      left and one on the right, and both duplet T1s are on the same side
%
%Method: draw random positions, check the rules, repeat until all rules hold.
%Positions are numbered 1 to 16, clockwise, starting at the top (1 to 8 are
%on the right side, 9 to 16 on the left side).

function [pos] = makePositions(params, subjectNum)

nPositions = params.pos.nPositions;
visNames = {'seen','unseen'};

%Rule 3: which jump sizes belong to seen and which to unseen?
%jumps adjusted in pairs of participants
%participants 1-2: seen=jumpsA, participants 3-4: seen=JumpsB, etc
pairNumber = ceil(subjectNum/2);
if mod(pairNumber, 2) == 1
    jumps.seen = params.pos.jumpsA;
    jumps.unseen = params.pos.jumpsB;
else
    jumps.seen = params.pos.jumpsB;
    jumps.unseen = params.pos.jumpsA;
end

finished = false;
while ~finished

    allRulesOK = true;

    for visi = 1 : 2
        visName = visNames{visi};

        %Rule 3: 2 jump sizes of this set in random order
        theseJumps = jumps.(visName);
        theseJumps = theseJumps(randperm(2));

        %Rule 4: one duplet jumps clockwise and the other one counter-clockwise
        if rand < 0.5
            direction = [1 -1];
        else
            direction = [-1 1];
        end

%Draw the two duplet T1 positions; T2 = T1 + jump
%(mod keeps the result between 1 and 16, e.g. 15 + 3 = position 2)
        dupletT1 = randi(nPositions, 1, 2);
        T2 = dupletT1 + direction .* theseJumps;
        T2 = mod(T2 - 1, nPositions) + 1;

        %Draw the two control T1 positions
        controlT1 = randi(nPositions, 1, 2);

        thisSet = [dupletT1, controlT1, T2];

        %Rule 2: all four quadrants (1-4, 5-8, 9-12, 13-16)
        quadrants = ceil(thisSet / (nPositions / 4));
        if length(unique(quadrants)) < 4
            allRulesOK = false;
        end

        %Rule 5: T2 left and right, both duplet T1s on the same side
        if params.pos.leftRightRule
            isLeft = thisSet > nPositions / 2; %positions 9 to 16
            dupletT1Left = isLeft(1 : 2);
            T2Left = isLeft(5 : 6);
            if T2Left(1) == T2Left(2) %both T2 locations on the same side
                allRulesOK = false;
            end
            if dupletT1Left(1) ~= dupletT1Left(2) %duplet T1s on different sides
                allRulesOK = false;
            end
        end

        %Store this set
        pos.(visName).dupletT1 = dupletT1;
        pos.(visName).controlT1 = controlT1;
        pos.(visName).T2 = T2;
        pos.(visName).jumps = direction .* theseJumps; %+ = clockwise, - = counter-clockwise
        pos.(visName).all = thisSet;
    end

    %Rule 1: no position is used twice (within a set or in both sets)
    allTwelve = [pos.seen.all, pos.unseen.all];
    if length(unique(allTwelve)) < length(allTwelve)
        allRulesOK = false;
    end

    if allRulesOK
        finished = true;
    end
end

pos.subjectNum = subjectNum;
end
