%Purpose: This function loads the perceptual threshold of a participant from
%the calibration task and returns the mask contrasts for the main task:
%   weak mask   (conscious blocks)     = threshold x 0.5
%   strong mask (non-conscious blocks) = threshold x 1.5
%The calibration saves these values in Data/Calibration, in the file
%P<nr>_S<session>_threshold.mat.
%
%Usage: maskContrast = loadThreshold(3, 1)   (participant 3, session 1)
%
%Output:
%   maskContrast.threshold   the threshold (mask contrast, 0 to 1)
%   maskContrast.seen        mask contrast for the conscious blocks
%   maskContrast.unseen      mask contrast for the non-conscious blocks

function [maskContrast] = loadThreshold(subjectNum, sessionNum)

%Where the calibration saved the file: "Data/Calibration" inside the repository folder
repoRoot = fileparts(fileparts(mfilename('fullpath')));
calibrationDir = fullfile(repoRoot, 'Data', 'Calibration');
fileName = sprintf('P%d_S%d_threshold.mat', subjectNum, sessionNum);
thresholdFile = fullfile(calibrationDir, fileName);

%Stop with a clear message if the calibration has not been run yet
if ~exist(thresholdFile, 'file')
    error(['The file ' fileName ' was not found in ' calibrationDir '. Run the calibration for this participant and session first.']);
end

%Load the values saved by the calibration
tmp = load(thresholdFile);

maskContrast.threshold = tmp.threshold;
maskContrast.seen = tmp.contrastSeen; %weak mask: conscious blocks
maskContrast.unseen = tmp.contrastUnseen; %strong mask: non-conscious blocks

%Check that the values make sense
if isnan(maskContrast.threshold)
    error(['The threshold in ' fileName ' is not a number (NaN). Run the calibration again.']);
end

if maskContrast.unseen <= maskContrast.seen
    disp('WARNING: the strong mask is not stronger than the weak mask!');
end

%Show the values in the Command Window
disp(['Threshold: ' num2str(maskContrast.threshold, '%.3f')]);
disp(['Mask contrast, conscious blocks (weak mask): ' num2str(maskContrast.seen, '%.3f')]);
disp(['Mask contrast, non-conscious blocks (strong mask): ' num2str(maskContrast.unseen, '%.3f')]);
end
