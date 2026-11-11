% This function initializes the parameters of the main task

function [params] = mainParams()

% This shows the trial kinds within one miniblock
% For now, every kind is shown equally often (20% each) but this can easily be changed
params.design.kinds = {'duplet1', 'duplet2', 'control1', 'control2', 'targetAbsent'};

%Target-absent trials -> I followed the manuscript for this, making it a flip-a-coin between
% which target is missing

params.design.propT1absent = 0.5;

% Number of trials in the learning phase
% trials / miniblock = n^2+1 => 26 if we settle on 5 kinds (2 duplets, 2 controls and 1 target)
% total number of trials = nr of cond x nr of miniblocks per cond x nr of trials per miniblock
% when we want to adjust the nr of trials, all we need to change is how many mini blocks we have per condition
% => the values will always increase in a step of 2 x 26

params.learn.nMiniblocksPerVis = 2; 

end
