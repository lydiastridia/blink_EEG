%Purpose: This function prepares the exact position of the mask elements on
%the screen: four small rectangles (top, bottom, left, right) around every
%possible target position. almost identical to the original code

%Each column of maskPos is one rectangle: [left; top; right; bottom] in pixels.

function [maskPos] = prepMask(params, positions)

%Define important variables
nObjects = params.stim.targetPositions;
space = params.stim.maskSpace;
rectLength = params.stim.maskRectLength;
rectWidth = params.stim.maskRectWidth;
x = positions.x;
y = positions.y;

%Build the mask by defining the screen positions of the four rectangles
%around each position
for i = 1 : nObjects
    rectangles.top(1, i) = x(i) - rectWidth/2;
    rectangles.top(2, i) = y(i) - space - rectLength;
    rectangles.top(3, i) = x(i) + rectWidth/2;
    rectangles.top(4, i) = y(i) - space;

    rectangles.bottom(1, i) = x(i) - rectWidth/2;
    rectangles.bottom(2, i) = y(i) + space;
    rectangles.bottom(3, i) = x(i) + rectWidth/2;
    rectangles.bottom(4, i) = y(i) + space + rectLength;

    rectangles.left(1, i) = x(i) - space - rectLength;
    rectangles.left(2, i) = y(i) - rectWidth/2;
    rectangles.left(3, i) = x(i) - space;
    rectangles.left(4, i) = y(i) + rectWidth/2;

    rectangles.right(1, i) = x(i) + space;
    rectangles.right(2, i) = y(i) - rectWidth/2;
    rectangles.right(3, i) = x(i) + space + rectLength;
    rectangles.right(4, i) = y(i) + rectWidth/2;
end

maskPos = [rectangles.left, rectangles.right, rectangles.bottom, rectangles.top];
end
