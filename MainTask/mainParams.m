%Purpose: This function initializes the parameters of the main task.
%Change numbers HERE, not in the other files.
%(For now only the design of the learning phase: which trials, how many.)
%Experiment: blinkEEG (based on the nonconSeq sequence task)

function [params] = mainParams()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Trial kinds within one miniblock
%Each miniblock has one visibility (seen or unseen) and contains these kinds.
%Every kind is shown equally often, and every kind follows every kind
%(including itself) exactly once: uniform transition probabilities.
%   number of trials per miniblock = (number of kinds x number of kinds) + 1
%   5 kinds -> (5 x 5) + 1 = 26 trials, each kind 5 times (one kind 6 times)
params.design.kinds = {'duplet1', 'duplet2', 'control1', 'control2', 'T1absent'};
%   duplet1, duplet2:    predictive: T1 at a fixed position, T2 at its fixed partner
%   control1, control2:  not predictive: T1 at a control position, T2 at one of
%                        the two T2 locations (half of the trials each)
%   T1absent:            no T1 (mask only), T2 at one of the two T2 locations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Number of trials in the learning phase (flexible)
%Total number of trials = 2 visibilities x nMiniblocksPerVis x 26
%   2 miniblocks per visibility ->  4 miniblocks = 104 trials (for now)
%  10 miniblocks per visibility -> 20 miniblocks = 520 trials (each duplet 50 times)
params.learn.nMiniblocksPerVis = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Omissions in the learning phase (T1 is shown, but T2 does not appear)
params.learn.propOmission = 0.1; %proportion of the duplet and control trials in which T2 is omitted
                                 %(0 = no omissions in the learning phase)
params.learn.nMiniblocksNoOmission = 0; %no omissions in the first ... miniblocks of each visibility,
                                        %so that the rule can be learned first (e.g., 2 in the real experiment)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Order of the miniblocks: seen and unseen miniblocks alternate.
%Participants with an odd number start with a seen miniblock,
%participants with an even number with an unseen miniblock.
end
