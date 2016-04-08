function dataset = ib_getDataset(type, handles, orient, col_channel, options)
% function dataset = ib_getDataset(type, handles, orient, col_channel, options)
% Get complete 4D volume of the dataset, a wrapper function
%
% This is a wrapper function, it uses the functions of the imageData class to get the whole 3D dataset at once. When ROIs
% regions are shown in the axes (@em handles.roiShowCheck checkbox) the function returns the ROI areas.
% @attention The output value is an array of cells!
%
% Parameters:
% type: a type of the image to get, ''image'', ''model'', ''selection'', ''mask'', ''everything'' (for imageData.model_type==''uint6'' only)
% handles: handles structure of im_browser.m
% orient: [@em optional], can be @em NaN
% @li when @b 0 (@b default) returns the dataset transposed to the current orientation (obj.orientation)
% @li when @b 1 returns transposed dataset to the zx configuration: [y,x,c,z] -> [x,z,c,y]
% @li when @b 2 returns transposed dataset to the zy configuration: [y,x,c,z] -> [y,z,c,y]
% @li when @b 3 not used
% @li when @b 4 returns original dataset to the yx configuration: [y,x,c,z]
% @li when @b 5 not used
% col_channel: [@em optional],
% @li when @em type is ''image'', col_channel is a vector with color numbers to get, when @b NaN [@e default] take the colors
            % selected in the imageData.slices{3} variable, when @b 0 - take all colors of the dataset.
% @li when @em type is ''model'' col_channel may be 0 - to get all materials of the model or an integer to get specific material. 
% options: a structure with extra parameters
% @li .blockModeSwitch -> override the block mode switch imageData.blockModeSwitch  @b 0 get full dataset / @b 1 - get dataset crop
% to the shown area
% @li .fillBg -> @b NaN (@b default) -> get ROI as a square; when .@em fillBg is an integer number, the script will use this number to fill areas outside the ROI shape
% @li .roiId -> an @b index of ROI to use, when @b 0 - use all shown ROIs. Also it is possible to define ROI by its label as string
% of chars.
% @li .t -> @b current, time point to get a 3D dataset
%
% Return values:
% dataset: a cell array with the dataset, format - dataset{roiId}(1:height, 1:width, 1:color, 1:z, 1:t); @em roiId=1 when one or no ROI
% selected.

%| @b Examples:
% @code dataset = ib_getDataset('image', handles);      // get the whole Image stack in yx orientation @endcode
% @code dataset = ib_getDataset('image', handles, NaN, 4, 2); // get the whole Image stack in yx orientation for color channel=2 @endcode
% @code dataset = ib_setDataset('model', handles, NaN, NaN, NaN, options.blockModeSwitch=1); // get the part of the whole model stack visible in the viewing window @endcode
% @code dataset = ib_getDataset('model', handles, NaN, NaN, NaN, options.roiId=1);      // when handles.roiShowCheck enabled - get the part of the whole model stack visible under ROI number 1  @endcode

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 08.04.2014, update to new roiRegion class
% 03.09.2015, Ilya Belevich, updated to use imageData.getData3D methods
% 18.09.2016, changed .slices to cells

if nargin < 5; options = struct(); end
if nargin < 4; col_channel = NaN; end;
if nargin < 3; orient = 0; end;

if ~isfield(options, 'blockModeSwitch'); options.blockModeSwitch = handles.Img{handles.Id}.I.blockModeSwitch; end;
if ~isfield(options, 'fillBg'); options.fillBg = NaN; end;
if ~isfield(options, 'roiId'); 
    roiList = get(handles.roiList, 'string'); 
    roiNo = get(handles.roiList, 'value'); 
    options.roiId = handles.Img{handles.Id}.I.hROI.findIndexByLabel(roiList{roiNo}); 
end;

if strcmp(type,'image')
    if isnan(col_channel); col_channel=handles.Img{handles.Id}.I.slices{3}; end;
    if col_channel(1) == 0;  col_channel = 1:size(handles.Img{handles.Id}.I.img,3); end;
end

if orient==0 || isnan(orient); orient=handles.Img{handles.Id}.I.orientation; end;

if get(handles.roiShowCheck,'value') == 1   % do only for selected roi(s)
    dataset = handles.Img{handles.Id}.I.getRoiCrop(type, handles, options.roiId, options, col_channel);
else
    dataset = {handles.Img{handles.Id}.I.getData4D(type, orient, col_channel, options)};
end
end