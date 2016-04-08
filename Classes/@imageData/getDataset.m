function dataset = getDataset(obj, type, orient, col_channel, options)
% function dataset = getDataset(obj, type, orient, col_channel, options)
% Get 4D dataset, [height, width, color, depth], @b LEGACY @b function, please use
% imageData.getData3D instead!
%
% Parameters:
% type: type of the dataset to retrieve, 'image', 'model','mask', 'selection', or 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% orient: [@em optional], can be @em NaN or @em empty
% @li when @b 0 (@b default) returns the dataset transposed to the current orientation (obj.orientation)
% @li when @b 1 returns transposed dataset to the zx configuration: [y,x,c,z] -> [x,z,c,y]
% @li when @b 2 returns transposed dataset to the zy configuration: [y,x,c,z] -> [y,z,c,y]
% @li when @b 3 not used
% @li when @b 4 returns original dataset to the yx configuration: [y,x,c,z]
% @li when @b 5 not used
% col_channel: [@em optional],
% @li when @b type is 'image', @b col_channel is a vector with color numbers to take, when @b NaN [@e default] take the colors
% selected in the imageData.slices{3} variable, when @b 0 - take all colors of the dataset.
% @li when @b type is 'model' @b col_channel may be @em NaN - to take all materials of the model or an integer to take specific material. In the later case the selected material will have index = 1.
% options: [@em optional], a structure with extra parameters
% @li .blockModeSwitch -> override the imageData.blockModeSwitch (@b 0 - return full dataset, @b 1 - return only the shown part)
% @li .y -> [@em optional], [ymin, ymax] of the part of the dataset to take
% @li .x -> [@em optional], [xmin, xmax] of the part of the dataset to take
% @li .z -> [@em optional], [zmin, zmax] of the part of the dataset to take
%
% Return values:
% dataset: 4D stack. For the 'image' type: [1:height, 1:width, 1:colors, 1:thickness]; for all other types: [1:height, 1:width, 1:thickness]

%| 
% @b Examples:
% @code dataset = handles.Img{handles.Id}.I.getDataset('image');      // get the complete 4D dataset in the shown orientation  @endcode
% @code dataset = handles.Img{handles.Id}.I.getDataset('image', 0, NaN, options.blockModeSwitch=1); // get the croped to the viewing window dataset, with the shown colors @endcode
% @code dataset = handles.Img{handles.Id}.I.getDataset('image', 4, 2); // get transposed to the XY orientation dataset with only second color channel @endcode
% @code dataset = obj.getDataset('image');      // Call within the class, get the complete dataset  @endcode
% @attention @b sensitive to the imageData.blockModeSwitch
% @attention @b not @b sensitive to the shown ROI
% @attention @b legacy @b function, @b use @b imageData.getData3D @b insead!
% @attention for normal calls it is recommended to use ib_getDataset.m wrapper function, as @code
% dataset = ib_getDataset('image', handles); @endcode

% Copyright (C) 30.10.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 20.08.2015, Ilya Belevich, Simplified syntax
% 03.09.2015, Ilya Belevich updated to use imageData.getData3D method
% 18.09.2016, changed .slices to cells

if nargin < 5; options=struct(); end;
if nargin < 4; col_channel = NaN; end;
if nargin < 3; orient=NaN; end;
time = 1;

if ~isfield(options, 'blockModeSwitch'); options.blockModeSwitch = obj.blockModeSwitch; end;
if isfield(options, 'y'); options.blockModeSwitch = 1; end;

if orient==0 || isnan(orient); orient=obj.orientation; end;

if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0;  col_channel = 1:size(obj.img,3); end;
end

options.t = [time time];   % define the time point
dataset = obj.getData3D(type, time, orient, col_channel, options);

end