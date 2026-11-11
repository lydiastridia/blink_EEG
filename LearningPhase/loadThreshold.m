% This function loads the perceptual threshold of a participant from the calibration task 
% and returns it for the learning and main task:
% for the weak mask (conscious blocks), mask = threshold x 0,5
% for the strong mask (non-conscious blocks), mask = threshold x 1,5

function [maskContrast] = loadThreshold(subjectNum, sessionNum)

repoRoot = fileparts(fileparts(mfilename('fullpath')));
calibrationDir = fullfile(repoRoot, 'Data', 'Calibration');
fileName = sprintf('P%d_S%d_threshold.mat', subjectNum, sessionNum);
thresholdFile = fullfile(calibrationDir, fileName);

% In case of an error if the calibration has not been run yet or if the value was not saved,
% this stops it with a clear message

%Stop with a clear message if the calibration has not been run yet
if ~exist(thresholdFile, 'file')
    error(['The file ' fileName ' was not found in ' calibrationDir '. Run the calibration for this participant and session first.']);
end

% Loads the values saved during the calibration task
tmp = load(thresholdFile);

maskContrast.threshold = tmp.threshold;
maskContrast.seen = tmp.contrastSeen; %weak mask: conscious blocks
maskContrast.unseen = tmp.contrastUnseen; %strong mask: non-conscious blocks

%Checks that the values make sense
if isnan(maskContrast.threshold)
    error(['The threshold in ' fileName ' is not a number (NaN). Run the calibration again.']);
end
 
if maskContrast.unseen <= maskContrast.seen
    disp('WARNING: the strong mask is not stronger than the weak mask!');
end
 
%Shows the values in the Command Window
disp(['Threshold: ' num2str(maskContrast.threshold, '%.3f')]);
disp(['Mask contrast, conscious blocks (weak mask): ' num2str(maskContrast.seen, '%.3f')]);
disp(['Mask contrast, non-conscious blocks (strong mask): ' num2str(maskContrast.unseen, '%.3f')]);
end
