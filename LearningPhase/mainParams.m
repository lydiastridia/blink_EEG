% This function initializes the parameters of the main task

function [params] = mainParams()

% This shows the trial kinds within one miniblock
% For now, every kind is shown equally often (20% each) but this can easily be changed
params.design.kinds = {'duplet1', 'duplet1','duplet2', 'duplet2', 'control1', 'control2', 'targetAbsent'};

%Target-absent trials -> I followed the manuscript for this, making it a flip-a-coin between
% which target is missing

params.design.propT1absent = 0.5;

% Number of trials in the learning phase
% trials / miniblock = n^2+1 => 50 if we settle on 7 kinds (4 duplets, 2 controls and 1 target)
% total number of trials = nr of cond x nr of miniblocks per cond x nr of trials per miniblock
% when we want to adjust the nr of trials, all we need to change is how many mini blocks we have per condition
% => the values will always increase in a step of 2 x 50

params.learn.nMiniblocksPerVis = 2; 

%% Positions
params.pos.nPositions = 16; %positions on the circle (22.5 degrees apart)
%Jump sizes from T1 to T2 for the two duplets of a set, in positions
%(1 position = 22.5 degrees): [3 6] = 67.5 and 135 degrees, [2 7] = 45 and 157.5 degrees
params.pos.jumpsA = [3 6];
params.pos.jumpsB = [2 7];
%Rule 5 (to be decided): T2 locations left and right, both duplet T1s on the same side
params.pos.leftRightRule = true;

end
