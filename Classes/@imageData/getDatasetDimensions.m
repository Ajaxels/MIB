function [height, width, color, depth, time] = getDatasetDimensions(obj, type, orient, color, options)
% function [height width color depth, time] = getDatasetDimensions(obj, type, orient, color, options)
% Get dimensions of the dataset
%
% Parameters:
% type:  type of the dataset to retrieve dimensions, 'image' (@b default), 'model', 'mask', 'selection'
% orient: [@em optional], can be @em NaN 
% @li when @b 0 (@b default) returns the dataset transposed to the current orientation (obj.orientation)
% @li when @b 1 returns dimensions of the transposed dataset to the zx configuration: [y,x,c,z,t] -> [x,z,c,y,t]
% @li when @b 2 returns dimensions of the transposed dataset to the zy configuration: [y,x,c,z,t] -> [y,z,c,y,t]
% @li when @b 3 not used
% @li when @b 4 returns dimensions of the original dataset to the yx configuration: [y,x,c,z,t]
% @li when @b 5 not used
% color: [@em optional], can be @e NaN
% @li when @b type is 'image', color is a vector with color numbers to take, otherwise take the colors selected in the imageData.slices{3} variable
% @li when @b type is 'model' color may be 0 - to take all materials of the model or an integer to take specific material.
% options: [@em optional], a structure with extra parameters
% @li .blockModeSwitch -> override the imageData.blockModeSwitch (@b 0 - return dimensions of the full dataset, @b 1 - return dimensions of the shown part only)
% @li .orientation -> override the imageData.orientation parameter
%
% Return values:
% height: height of the dataset
% width: width of the dataset
% color: vector of colors of the dataset
% depth: number of z-layers of the dataset
% time: number of time points

%| 
% @b Examples:
% @code [height width color depth] = imageData.getDatasetDimensions('image')      // get dimensions of the complete dataset  @endcode
% @code [height width color depth] = imageData.getDatasetDimensions('image', 1);  // get dimensions of the transposed dataset  @endcode
% @code [height width color depth] = getDatasetDimensions(obj, 'image', NaN, NaN, options.blockModeSwitch=1)      // Call within the class; get dimensions of the cropped not transposed, with shown colors dataset  @endcode
% @attention @b sensitive to the imageData.blockModeSwitch
% @attention @b not @b sensitive to the shown ROI

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices to cells

if nargin < 5;
    options.blockModeSwitch = obj.blockModeSwitch;
    options.orientation = obj.orientation;
end;
if nargin < 4; color = NaN; end;
if nargin < 3; orient = NaN; end;
if nargin < 2; type = 'image'; end;

if ~isfield(options, 'blockModeSwitch'); options.blockModeSwitch = obj.blockModeSwitch; end;
if ~isfield(options, 'orientation'); options.orientation = obj.orientation; end;

if isnan(orient); orient = obj.orientation; end;
if isnan(color)
    if strcmp(type,'image')
        color = obj.slices{3};
    end
elseif color==0
    color = 1:obj.colors;   % get vector of all colors
end;

time = size(obj.img,5);

if options.blockModeSwitch == 0     % get the full size dataset
    if orient == 4 % yx
        height = size(obj.img,1);
        width = size(obj.img,2);
        depth = size(obj.img,4);
    elseif orient==1     % xz
        height = size(obj.img,2);
        width = size(obj.img,4);
        depth = size(obj.img,1);
    elseif orient==2 % yz
        height = size(obj.img,1);
        width = size(obj.img,4);
        depth = size(obj.img,2);
    end
else        % get the shown block
    Xlim = ceil(obj.axesX);
    Ylim = ceil(obj.axesY);
    if orient == 4    % get dataset dimensions for the yx direction
        if options.orientation==1     % xz
            height = size(obj.img,1);
            width = abs(diff([min([Ylim(2) obj.width]) max([Ylim(1) 1])]))+1;
            depth = abs(diff([min([Xlim(2) obj.no_stacks]) max([Xlim(1) 1])]))+1;
        elseif options.orientation==2 % yz
            height = abs(diff([min([Ylim(2) obj.height]) max([Ylim(1) 1])]))+1;
            width = size(obj.img,2);
            depth = abs(diff([min([Xlim(2) obj.no_stacks]) max([Xlim(1) 1])]))+1;
        elseif options.orientation==4 % yx
            height = abs(diff([max([Ylim(1) 1]) min([Ylim(2) obj.height])]))+1;
            width = abs(diff([min([Xlim(2) obj.width]) max([Xlim(1) 1])]))+1;
            depth = size(obj.img,4);
        end
    elseif orient == 1    % get dataset dimensions for the xz direction
        if options.orientation==1     % xz
            depth = size(obj.img,1);
            height = abs(diff([min([Ylim(2) obj.width]) max([Ylim(1) 1])]))+1;
            width = abs(diff([min([Xlim(2) obj.no_stacks]) max([Xlim(1) 1])]))+1;
        elseif options.orientation==2 % yz
            height = size(obj.img, 1);
            width = abs(diff([min([Xlim(2) obj.no_stacks]) max([Xlim(1) 1])]))+1;
            depth = abs(diff([min([Ylim(2) obj.width]) max([Ylim(1) 1])]))+1;
        elseif options.orientation==4 % yx
            height = size(obj.img, 1);
            width = abs(diff([min([Ylim(2) obj.width]) max([Ylim(1) 1])]))+1;
            depth = abs(diff([min([Xlim(2) obj.no_stacks]) max([Xlim(1) 1])]))+1;
        end
    elseif orient == 2    % get dataset dimensions for the yz direction
        if options.orientation==1     % xz
            width = abs(diff([min([Xlim(2) obj.no_stacks]) max([Xlim(1) 1])]))+1;
            height = size(obj.img,2);
            depth = abs(diff([min([Ylim(2) obj.height]) max([Ylim(1) 1])]))+1;
        elseif options.orientation==2 % yz
            height = abs(diff([min([Ylim(2) obj.height]) max([Ylim(1) 1])]))+1;
            width = abs(diff([min([Xlim(2) obj.no_stacks]) max([Xlim(1) 1])]))+1;
            depth = size(obj.img,2);
        elseif options.orientation==4 % yx
            height = abs(diff([min([Ylim(2) obj.height]) max([Ylim(1) 1])]))+1;
            width = size(obj.img,2);
            depth = abs(diff([min([Xlim(2) obj.no_stacks]) max([Xlim(1) 1])]))+1;
        end
    end
end
end