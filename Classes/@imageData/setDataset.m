function result = setDataset(obj, type, dataset, orient, col_channel, options)
% function result = setDataset(obj, type, dataset, orient, col_channel, options)
% Update complete 4D dataset, @b LEGACY @b function, please use
% imageData.setData3D instead!
%
% Parameters:
% type: type of the dataset to update, 'image', 'model', 'mask', 'selection', 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% dataset: a 4D stack with images
% orient: [@em optional], can be @em NaN
% @li when @b 0 (@b default) returns the dataset transposed to the current orientation (obj.orientation)
% @li when @b 1 returns transposed dataset to the zx configuration: [y,x,c,z] -> [x,z,c,y]
% @li when @b 2 returns transposed dataset to the zy configuration: [y,x,c,z] -> [y,z,c,y]
% @li when @b 3 not used
% @li when @b 4 returns original dataset to the yx configuration: [y,x,c,z]
% @li when @b 5 not used
% col_channel: [@em optional], can be @e NaN;
% @li when @b type is 'image', col_channel is a vector with color numbers to set, when @b NaN [@e default] update set the
% colors selected in the imageData.slices{3} variable; when @em 0 - update all colors of the dataset.
% @li when @b type is 'model' col_channel may be @em NaN - to update all materials of the model or an integer to update specific material.
% options: [@em optional], a structure with extra parameters
% @li .blockModeSwitch -> override the imageData.blockModeSwitch (@b 0 - update full dataset, @b 1 - update only the shown area)
% @li .y -> [@em optional], [ymin, ymax] of the part of the dataset to set;
% @li .x -> [@em optional], [xmin, xmax] of the part of the dataset to set
% @li .z -> [@em optional], [zmin, zmax] of the part of the dataset to set
%
% Return values:
% result: -> @b 1 - success, @b 0 - error

%|
% @b Examples:
% @code result = handles.Img{handles.Id}.I.setDataset('image', dataset);      // set the 4D dataset into 5D at the current time point  @endcode
% @code result = handles.Img{handles.Id}.I.setDataset('image', dataset, 0, NaN, options.blockModeSwitch=1); // set the croped to the viewing window part of the dataset, with shown colors @endcode
% @code result = handles.Img{handles.Id}.I.setDataset('image', dataset, 1, 2); // set complete transposed (XZ) dataset with only second color channel @endcode
% @code result = obj.setDataset('image', dataset);      // Call within the class; set the complete dataset  @endcode
% @attention @b sensitive to the @code imageData.blockModeSwitch @endcode
% @attention @b not @b sensitive to the shown ROI
% @attention for normal calls it is recommended to use ib_setDataset.m wrapper function, as @code
% ib_setDataset('image', dataset, handles); @endcode

% Copyright (C) 20.06.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 20.08.2015, Ilya Belevich, Simplified syntax
% 03.09.2015, Ilya Belevich updated to use imageData.setData3D method
% 18.09.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

result = 0; %#ok<NASGU>
if nargin < 6; options.blockModeSwitch = obj.blockModeSwitch; end;
if nargin < 5; col_channel = NaN; end;
if nargin < 4; orient=NaN; end;

time = 1;

if orient==0 || isnan(orient); orient=obj.orientation; end;

if ~isfield(options, 'blockModeSwitch'); options.blockModeSwitch = obj.blockModeSwitch; end;
if isfield(options, 'y'); options.blockModeSwitch = 1; end;

if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0;  col_channel = 1:size(obj.img,3); end;
end

options.t = [time time];   % define the time point
result = obj.setData3D(type, dataset, time, orient, col_channel, options);
end