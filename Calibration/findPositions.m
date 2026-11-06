%Purpose: This function identifies the exact position of the targets on the
%screen: 16 positions, equally spaced on a circle around the center.


function [positions] = findPositions(params)

nTargetPositions = params.stim.targetPositions;
centerX = params.screen.pos.Center(1);
centerY = params.screen.pos.Center(2);
r = params.stim.targetRadius;

%Define the x,y coordinates of the positions
c = 2 * pi; %full circle
angle = c / nTargetPositions; %angle between two consecutive positions 22,5
for posi = 1 : nTargetPositions
    angles(posi) = angle/2 + (posi - 1) * angle;
end

for posi = 1 : nTargetPositions
    positions.x(posi) = centerX + r * sin(angles(posi));
    positions.y(posi) = centerY - r * cos(angles(posi)); %minus: on the screen, y goes down
end
end
