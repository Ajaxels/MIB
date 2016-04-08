function slice = ib_getSlice(type, handles, slice_no, orient, col_channel, options)
% function slice = ib_getSlice(type, handles, slice_no, orient, col_channel, options)
% Get the 2D slice from the dataset, the wrapper function
%
% This is a wrapper function, it uses the functions of the imageData class to get a slice from the dataset. When ROIs
% regions are shown in the axes (@em handles.roiShowCheck checkbox) the function returns array of cells of only those ROI areas.
% @attention The return value is an array of cells!
%
% Parameters:
% type: a type of the image to update, ''image'', ''model'', ''selection'', ''mask'', ''everything'' (for imageData.model_type==''uint6'' only)
% handles: handles structure of im_browser.m
% slice_no: [@em optional], a number of the slice to get, when @em empty or @em NaN get the currently shown slice
% orient: [@em optional], get a slice in the desired orientation
% - @b 0 (@b default) gets the slice transposed to the current orientation (obj.orientation)
% - @b 1 - xz
% - @b 2 - yz
% - @b 4 - xy
% - @b NaN - the current orientation
% col_channel: [@em optional],
% @li when @em type is ''image'', col_channel is a vector with color numbers to obtain, when @b NaN [@e default] take the colors
            % selected in the imageData.slices{3} variable, when @b 0 - take all colors of the dataset.
% @li when @em type is ''model'' col_channel may be @em NaN - to take all materials of the model or an integer to take specific material. In the later case the selected object will have index = 1.
% options: a structure with extra parameters
% @li .blockModeSwitch -> override the block mode switch imageData.blockModeSwitch - @b 0 get full dataset / @b 1 - get dataset crop
% @li .fillBg -> @b NaN->get ROI as a square; when .@em fillBg is an integer number, the script use this number to fill areas outside the ROI shape
% @li .roiId -> an @b index of ROI to use, when @b 0 - get all shown ROIs. Also it is possible to define ROI by its label as string
% @li .t -> [@em optional], [tmin, tmax] the time point of the dataset; default is the currently shown time point
%
% Return values:
% slice: an array of cells with 2D slices, format - slice{roiId}(1:height, 1:width, 1:color); @em roiId=1 when one or no ROI

% @b Examples:
% @code slice = ib_getSlice('image', handles, 5);      // get the 5-th slice of the current stack orientation  @endcode
% @code slice = ib_getSlice('image', handles, 5, 4, 2); // get the 5-th slice of the XY-orientation, color channel=2 @endcode
% @code slice = ib_getSlice('model', handles, 5, NaN, NaN, options.blockModeSwitch=1); // get the cropped to the viewing window 5-th slice of the current orientation, color channel=2 from the model @endcode
% @code slice = ib_getSlice('model', handles, 5, NaN, NaN, options.roiId=1);      // when handles.roiShowCheck enabled - return a slice that contains image under ROI number 1  @endcode

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 08.04.2014, update to new roiRegion class
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

if nargin < 6; options = struct(); end
if nargin < 5; col_channel = NaN; end;
if nargin < 4; orient = NaN; end;
if nargin < 3; slice_no = NaN; end;

if ~isfield(options, 'blockModeSwitch'); options.blockModeSwitch = handles.Img{handles.Id}.I.blockModeSwitch; end;
if ~isfield(options, 'fillBg'); options.fillBg = NaN; end;
if ~isfield(options, 'roiId'); 
    roiList = get(handles.roiList, 'string'); 
    roiNo = get(handles.roiList, 'value'); 
    options.roiId = handles.Img{handles.Id}.I.hROI.findIndexByLabel(roiList{roiNo});  
end;
if isfield(options, 't')
    options.t = options.t;
else
    options.t = [handles.Img{handles.Id}.I.slices{5}(1), handles.Img{handles.Id}.I.slices{5}(2)];
end

if strcmp(type,'image')
    if isnan(col_channel); col_channel=handles.Img{handles.Id}.I.slices{3}; end;
    if col_channel(1) == 0;  col_channel = 1:size(handles.Img{handles.Id}.I.img,3); end;
end
if isnan(orient) || orient == 0; orient = handles.Img{handles.Id}.I.orientation; end;
if isnan(slice_no); slice_no = handles.Img{handles.Id}.I.getCurrentSliceNumber(); end;

if get(handles.roiShowCheck,'value') == 1   % do only for selected roi(s)
    slice = handles.Img{handles.Id}.I.getRoiCropSlice(type, handles, options.roiId, slice_no, orient, options, col_channel);
else                                                  
    %slice = {handles.Img{handles.Id}.I.getSlice(type, slice_no, orient, col_channel, NaN, options)};   % old call
    slice = {handles.Img{handles.Id}.I.getData2D(type, slice_no, orient, col_channel, NaN, options)};
end
end