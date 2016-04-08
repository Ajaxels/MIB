function [xOut,yOut,zOut,tOut] = convertMouseToDataCoordinates(obj, x, y, mode, permuteSw)
% function [xOut,yOut,zOut,tOut] = convertMouseToDataCoordinates(obj, x, y, mode, transpose)
% Convert coordinates under the mouse cursor to the coordinates of the dataset.
%
% Parameters:
% x: x - coordinate
% y: y - coordinate
% mode:  [@em optional] a string that defines a mode of the shown image, @b default is 'shown'
% @li 'shown' - the most common one, convert coordinates of the mouse
% above the image to the coordinates of the dataset
% @li 'full' - suppose to do the conversion for the situation when the full
% image is rendered in the handles.imageAxes, never used...?
% @li 'blockmode' - when the blockface mode is switched on the function
% returns coordinates under the mouse for the Block
% permuteSw: [@em optional], can be @em empty
% @li when @b 0 returns the coordinates for the dataset in the original xy-orientation;
% @li when @b 1 (@b default) returns coordinates for the dataset so that the currently selected orientation becomes @b xy
%
% Return values:
% xOut: x - coordinate with the dataset
% yOut: y - coordinate with the dataset
% zOut: z - coordinate with the dataset
% tOut: t - time coordinate

%| 
% @b Examples:
% @code [xOut,yOut] = imageData.convertMouseToDataCoordinates(x, y);  // do conversion' @endcode
% @code [xOut,yOut] = convertMouseToDataCoordinates(obj,x, y);   // Call within the class; do conversion @endcode

% Copyright (C) 31.03.2015, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 



if nargin < 5; permuteSw = 1; end;
if nargin < 4; mode = 'shown'; end;

if strcmp(mode, 'shown')
    % used in im_browser_winMouseMotionFcn, toolbar_zoomBtn
    xOut = x*obj.magFactor + max([0 floor(obj.axesX(1))]);
    yOut = y*obj.magFactor + max([0 floor(obj.axesY(1))]);
elseif strcmp(mode, 'blockmode')    
    xOut = x*obj.magFactor;
    yOut = y*obj.magFactor;
else
    %sprintf('Mag=%f, x1=%f, axexX=%f\n',obj.magFactor, x(1), obj.axesX(1))
    xOut = (x*obj.magFactor +  max([0 obj.axesX(1)]))/max([1 obj.magFactor]);
    yOut = (y*obj.magFactor +  max([0 obj.axesY(1)]))/max([1 obj.magFactor]);
    
%     if obj.magFactor < 1
%         xOut = x*obj.magFactor +  max([0 obj.axesX(1)]);
%         yOut = y*obj.magFactor +  max([0 obj.axesY(1)]);
%     else
%         xOut = (x*obj.magFactor +  max([0 obj.axesX(1)]))/obj.magFactor;
%         yOut = (y*obj.magFactor +  max([0 obj.axesY(1)]))/obj.magFactor;
%     end
end

zOut = zeros(size(xOut,1))+obj.getCurrentSliceNumber();
% generate zOut coordinates
if permuteSw == 0
    tempX = xOut;
    tempY = yOut;
    tempZ = zOut;
    if obj.orientation == 1    % zx
        xOut = tempY;
        yOut = tempZ;
        zOut = tempX;
    elseif obj.orientation == 2 % zy
        xOut = tempZ;
        yOut = tempY;
        zOut = tempX;
    end
end
tOut = obj.slices{5}(1);
end