%Purpose: This function draws the convergence graph of the two staircases and
%saves it as <fileName>.png and <fileName>.fig.
%   x-axis: calibration trial number
%   y-axis: mask contrast used on that trial
%   orange = staircase a, blue = staircase b
%   filled dot = rated seen, open dot = rated unseen, black circle = reversal
%   dashed line = threshold, dotted lines = the two main-task contrasts

%
%To redraw the graph later from a saved file:
%   load('P1_S1_calibration.mat');
%   plotConvergence(cal, 'P1_S1_convergence_again')

function plotConvergence(cal, fileName)

%Colors (red, green, blue, each from 0 to 1)
orange = [0.85 0.33 0.10]; %staircase a
blue = [0.00 0.45 0.74]; %staircase b

%Open an empty figure with a white background
fig = figure('Color', 'w', 'Position', [100 100 900 500]);
hold on %keep everything in the same graph

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Staircase a
%x = calibration trial numbers, y = mask contrast used on each of these trials
xA = cal.trialNumber.a;
yA = cal.maskC.a(1 : length(xA)); %maskC has one extra value at the end (for the next trial), which we leave out

%The line
lineA = plot(xA, yA, '-', 'Color', orange, 'LineWidth', 1.5);

%A dot for every trial: filled if seen, open if unseen
for i = 1 : length(xA)
    if cal.vis.a(i) == 1 %seen
        plot(xA(i), yA(i), 'o', 'MarkerFaceColor', orange, 'MarkerEdgeColor', orange, 'MarkerSize', 6);
    elseif cal.vis.a(i) == 0 %unseen
        plot(xA(i), yA(i), 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', orange, 'MarkerSize', 6);
    end
end

%A black circle around every reversal
for i = 1 : length(cal.reversalPosition.a)
    trialOfReversal = cal.reversalPosition.a(i); %staircase trial at which the reversal happened
    plot(xA(trialOfReversal), yA(trialOfReversal), 'o', 'MarkerEdgeColor', 'k', 'MarkerSize', 11);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Staircase b (exactly the same, in blue)
xB = cal.trialNumber.b;
yB = cal.maskC.b(1 : length(xB));

lineB = plot(xB, yB, '-', 'Color', blue, 'LineWidth', 1.5);

for i = 1 : length(xB)
    if cal.vis.b(i) == 1 %seen
        plot(xB(i), yB(i), 'o', 'MarkerFaceColor', blue, 'MarkerEdgeColor', blue, 'MarkerSize', 6);
    elseif cal.vis.b(i) == 0 %unseen
        plot(xB(i), yB(i), 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', blue, 'MarkerSize', 6);
    end
end

for i = 1 : length(cal.reversalPosition.b)
    trialOfReversal = cal.reversalPosition.b(i);
    plot(xB(trialOfReversal), yB(trialOfReversal), 'o', 'MarkerEdgeColor', 'k', 'MarkerSize', 11);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Horizontal lines from trial 0 to the last trial
lastTrial = length(cal.data) + 1;

%Threshold: black dashed line
plot([0 lastTrial], [cal.thresholdValue.c cal.thresholdValue.c], 'k--', 'LineWidth', 1.5);
text(1, cal.thresholdValue.c, ['threshold ' num2str(cal.thresholdValue.c, '%.2f')], 'VerticalAlignment', 'bottom');

%Main-task contrasts: grey dotted lines
plot([0 lastTrial], [cal.contrastUnseen cal.contrastUnseen], ':', 'Color', [0.4 0.4 0.4]);
text(1, cal.contrastUnseen, ['main task, unseen blocks ' num2str(cal.contrastUnseen, '%.2f')], 'VerticalAlignment', 'bottom');

plot([0 lastTrial], [cal.contrastSeen cal.contrastSeen], ':', 'Color', [0.4 0.4 0.4]);
text(1, cal.contrastSeen, ['main task, seen blocks ' num2str(cal.contrastSeen, '%.2f')], 'VerticalAlignment', 'bottom');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Legend (only the two lines), axes and title
textA = ['staircase a (start ' num2str(cal.maskC.a(1)) ')'];
textB = ['staircase b (start ' num2str(cal.maskC.b(1)) ')'];
legend([lineA lineB], {textA, textB}, 'Location', 'northeast');

xlim([0 lastTrial]);
ylim([-0.05 1.05]); %a bit of space below 0 and above 1
xlabel('Calibration trial');
ylabel('Mask contrast');
title(['Calibration ' cal.name], 'Interpreter', 'none'); %'none': show the _ in P1_S1 as it is
box on
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Save the graph as a picture (.png) and as a MATLAB figure (.fig)
print(fig, [fileName '.png'], '-dpng', '-r150');
savefig(fig, [fileName '.fig']);
end
