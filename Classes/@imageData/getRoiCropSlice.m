function imgOut = getRoiCropSlice(obj, type, handles, roiNo, sliceNo, orient, options, col_channel)
% function imgOut = getRoiCropSlice(obj, type, handles, roiNo, sliceNo, orient, options, col_channel)
% Get a 2D slice of the ROI regions only.
%
% Returns a @b cell(s) imgOut with 2D stacks of the shown ROIs.
%
% Parameters:
% type: type of the dataset to retrieve, 'image', 'model', 'mask', 'selection', or 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% handles: handles of im_browser.m
% roiNo: [@em optional] number of ROI to get, when @em omitted or @em NaN (@b default) take the currently selected ROIs. When @b 0
% take all ROIs. Also it is possible to define ROI by its label as string
% of chars.
% sliceNo: [@em optional], number of the slice to get, when @em omitted or @em NaN returns the current slice
% orient: [@em optional], get a slice in the desired orientation
% - @b 1 - xz
% - @b 2 - yz
% - @b 4 - xy
% - @b NaN - currently selected orientation
% options: [@em optional], a structure with extra parameters
% @li .fillBg -> when @em NaN (@b default) -> crops the dataset as a rectangle; when @em a @em number fills the areas out
% of the ROI area with this intensity number.
% col_channel: [@em optional],
% @li when @b type is 'image', col_channel is a vector with color numbers to take, when @b NaN [@e default] take the colors
% selected in the imageData.slices{3} variable, when @b 0 - take all colors of the dataset.
% @li when @b type is 'model' col_channel may be @em NaN - to take all materials of the model or an integer to take specific material. In the later case the selected material will have index = 1.
%
% Return values:
% imgOut: a cell array containing 3D images of ROIs. For the 'image' type: [1:height, 1:width, 1:colors]; for all other types: [1:height, 1:width]

%| 
% @b Examples:
% @code imgOut = handles.Img{handles.Id}.I.getRoiCropSlice('image', handles, 2);      // get ROI 2 as rectangle image, from the current slice.  @endcode
% @code imgOut = handles.Img{handles.Id}.I.getRoiCropSlice('image', handles, 2, NaN, NaN, options.fillBg=255);  // get ROI 2 as rectangle image with areas outside the roi filled with 255 intensity, from the current slice. @endcode
% @code imgOut = obj.getRoiCropSlice('model', handles, 0);      // Call within the class; get all ROIs from the currently shown Model layer  @endcode
% @attention @b imgOut - is a cell object that can be accessed as @code imgOut{index}(1:height,1:width,1:color)
% @endcode
% @attention It is possible to use ib_getSlice.m wrapper function that takes into account shown ROIs

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 08.04.2014, update to new roiRegion class
% 03.09.2015, fixed when ROI is bigger than the image
% 18.09.2016, changed .slices to cells

if nargin < 8;
    col_channel = NaN;
end;
if nargin < 7
    options.fillBg = NaN;
end;
if nargin < 6; orient = NaN; end;
if nargin < 5; sliceNo = NaN; end;
if nargin < 4;
    roiNo = NaN; 
end;

if isempty(isnan(orient)) || isempty(orient); orient=obj.orientation; end;
if isempty(isnan(sliceNo)) || isempty(sliceNo); sliceNo=obj.slices{orient}(1); end;
if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0;  col_channel = 1:size(obj.img,3); end;
end

% get index of the ROI
if isnan(roiNo); 
    roiList = get(handles.roiList, 'string'); 
    roiNo = get(handles.roiList, 'value'); 
    roiNo = obj.hROI.findIndexByLabel(roiList{roiNo});
elseif ischar(roiNo)
    roiNo = obj.hROI.findIndexByLabel(roiNo); 
end;

% get indices of ROI
if roiNo==0
    [number, indices] = obj.hROI.getNumberOfROI(orient);  % get number of ROI for the selected orientation
else
    indices = roiNo;
end

if strcmp(type, 'image')
    colorNo = numel(obj.slices{3});   % number of colors
else
    colorNo = 1;
end
roiId2 = 1;
for roiId = indices
    mask = obj.hROI.returnMask(roiId);
    STATS = regionprops(mask, 'BoundingBox');
    bb = round(STATS.BoundingBox);
    %slice = obj.getFullSlice(type, sliceNo, orient, col_channel);
    slice = obj.getSlice(type, sliceNo, orient, col_channel);
    slice = slice(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1, :);
    if ~isnan(options.fillBg)
        mask = mask(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1);
        mask = repmat(mask,[1, 1, colorNo]);
        slice(~mask) = options.fillBg;
    end
    imgOut{roiId2} = slice; %#ok<AGROW>
    roiId2 = roiId2 + 1;
end
end