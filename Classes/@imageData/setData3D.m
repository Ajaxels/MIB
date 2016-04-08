function result = setData3D(obj, type, dataset, time, orient, col_channel, options, custom_img)
% function result = setData3D(obj, type, dataset, time, orient, col_channel, options, custom_img)
% Set the 4D dataset (height:width:colors:depth) into the 5D dataset
%
% Parameters:
% type: type of the dataset to set, 'image', 'model','mask', 'selection', 'custom' ('custom' indicates to use custom_img as the dataset), 'everything'('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% dataset: 3D or 4D stack. For the 'image' type: [1:height, 1:width, 1:colors, 1:depth]; for all other types: [1:height, 1:width, 1:thickness]
% time: [@em optional], an index of the time point to show, when @em NaN gets the dataset for the current time point
% orient: [@em optional], can be @em NaN 
% @li when @b 0 (@b default) updates the dataset transposed from the current orientation (obj.orientation)
% @li when @b 1 returns transposed dataset from the zx configuration: [x,z,c,y,t] -> [y,x,c,z,t]
% @li when @b 2 returns transposed dataset from the zy configuration: [y,z,c,y,t] -> [y,x,c,z,t]
% @li when @b 3 not used
% @li when @b 4 returns original dataset from the yx configuration: [y,x,c,z,t]
% @li when @b 5 not used
% col_channel: [@em optional], can be @e NaN
% @li when @b type is 'image', col_channel is a vector with color numbers to take, when @b NaN [@e default] take the colors
% selected in the imageData.slices{3} variable, when @b 0 - take all colors of the dataset.
% @li when @b type is 'model' col_channel may be @em NaN - to take all materials of the model or an integer to take specific material. In the later case the selected material in @b slice will have index = 1.
% options: [@em optional], a structure with extra parameters
% @li .blockModeSwitch -> override the imageData.blockModeSwitch (@b 0 - update the full dataset, @b 1 - update only the shown part)
% @li .y -> [@em optional], [ymin, ymax] of the part of the dataset to take
% @li .x -> [@em optional], [xmin, xmax] of the part of the dataset to take
% @li .z -> [@em optional], [zmin, zmax] of the part of the dataset to take
% custom_img: [@em optional], can be @e NaN; the function return a slice not from the imageData class but from this custom_img, requires to
% specify the 'custom' @b type. 'custom_img' should be a 3D/4D dataset.
%
% Return values:
% result: -> @b 1 - success, @b 0 - error

%| 
% @b Examples:
% @code dataset = handles.Img{handles.Id}.I.setData3D('image', dataset);      // set the 4D dataset for the current time point, in the shown orientation  @endcode
% @code dataset = handles.Img{handles.Id}.I.setData3D('image', dataset, 5, 4); // set the 4D dataset for the 5-th time point in the XY orientation @endcode
% @code dataset = handles.Img{handles.Id}.I.setData3D('selection', dataset, 5, 1, 2); // set the 5-th timepoint in the the XZ-orientation, color channel=2 @endcode
% @code dataset = obj.setData3D(img, 'image', dataset, [], 4);      // Call within the class; set the 4D dataset for the current time point in the XY orientation  @endcode
% @attention @b sensitive to the @code imageData.blockModeSwitch @endcode
% @attention @b not @b sensitive to the shown ROI
% @attention for normal calls it is recommended to use ib_setDataset.m wrapper function, as @code
% dataset = ib_setDataset('image', handles); @endcode

% Copyright (C) 03.09.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

if nargin < 8; custom_img = NaN; end;
if nargin < 7; options = struct();  end;
if nargin < 6; col_channel = NaN;   end;
if nargin < 5; orient = NaN; end;
if nargin < 4; time = NaN; end;

if isnan(time); time = obj.slices{5}(1); end;
if orient == 0 || isnan(orient); orient=obj.orientation; end;

if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0;  col_channel = 1:size(obj.img,3); end;
end

options.t = [time time];   % define the time point
result = obj.setData4D(type, dataset, orient, col_channel, options);
end