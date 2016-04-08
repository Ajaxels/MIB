function setRoiCropSlice(obj, type, imgIn, handles, roiNo, sliceNo, orient, options, col_channel)
% function setRoiCropSlice(obj, type, imgIn, handles, roiNo, sliceNo, orient, options, col_channel)
% Update a 2D slice of the ROI regions of the dataset.
%
% @b Note! Requires an array of @b cells as @b imgIn
%
% Parameters:
% type: type of the image to update, 'image', 'model', 'mask', 'selection', or 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% imgIn: a cell array with ROIs 2D slices, @code imgIn{roiNo}(1:height,1:width,1:color) @endcode
% handles: handles of im_browser.m
% roiNo: [@em optional] number of ROI to update, when @em omitted or @em NaN take the currently selected. When @b 0
% take all ROIs. Also it is possible to define ROI by its label as string
% of chars.
% sliceNo: [@em optional], a number of the slice to update, when @em omitted or @em NaN update the current slice
% orient: [@em optional], update a slice in the desired orientation
% - @b 1 - xz
% - @b 2 - yz
% - @b 4 - xy
% - @b NaN - use the current orientation
% options: [@em optional], a structure with extra parameters
% @li .fillBg -> when @b 1 -> keep the background from @b imgIn; when @b NaN [@b default] -> crop @b imgIn with respect to the ROI shape
% col_channel: [@em optional], can be @e NaN
% @li when @b type is 'image', col_channel is a vector with color numbers to update, when @b NaN [@e default] update set the
% colors selected in the imageData.slices{3} variable; when @b 0 - update all colors of the dataset.
% @li when @b type is 'model' col_channel may be @em NaN - to update all materials of the model or an integer to update specific material.
%
% Return values:

%| 
% @b Examples:
% @code handles.Img{handles.Id}.I.setRoiCropSlice('image', imgIn, handles, 2);      // update ROI 2 of the current slice as shaped ROI image.  @endcode
% @code handles.Img{handles.Id}.I.setRoiCropSlice('image', imgIn, handles, 2, NaN, NaN, options.fillBg=1);  // update ROI 2 of the current slice as rectangle image with areas outside the roi filled with image intensity of imgIn. @endcode
% @code obj.setRoiCropSlice('model', imgIn, handles, 0);      // Call within the class; update all ROIs of the current Model layer  @endcode
% @attention @b imgIn - is a cell object: imgIn{index}(1:height,1:width,1:color)
% @attention consider to use ib_setSlice.m wrapper function

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
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

if nargin < 9; col_channel = NaN; end;
if nargin < 8; options.fillBg = NaN; end;
if nargin < 7; orient = obj.orientation; end;
if nargin < 6; sliceNo = obj.getCurrentSliceNumber(); end;
if nargin < 5; roiNo = NaN; end;
% get index of the ROI
if isnan(roiNo); 
    roiList = get(handles.roiList, 'string'); 
    roiNo = get(handles.roiList, 'value'); 
    roiNo = obj.hROI.findIndexByLabel(roiList{roiNo}); 
elseif ischar(roiNo)
    roiNo = obj.hROI.findIndexByLabel(roiNo); 
end;

if isempty(isnan(orient)) || isempty(orient); orient=obj.orientation; end;
if isempty(isnan(sliceNo)) || isempty(sliceNo); sliceNo=obj.slices{orient}(1); end;
if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0;  col_channel = 1:size(obj.img,3); end;
end

if ~iscell(imgIn); imgIn = {imgIn}; end;

% get indices of ROI
if roiNo==0
    [number, indices] = obj.hROI.getNumberOfROI(orient);  % get number of ROI for the selected orientation
else
    indices = roiNo;
end

if strcmp(type, 'image')
    colorNo = numel(col_channel);
else
    colorNo = 1;
end

roiId2 = 1;
for roiId = indices
    mask = obj.hROI.returnMask(roiId);
    STATS = regionprops(mask, 'BoundingBox');
    bb = round(STATS.BoundingBox);
    mask = mask(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1);
    mask = repmat(mask,[1, 1, colorNo]);
    %origSlice = obj.getFullSlice(type, sliceNo, orient, col_channel);
    origSlice = obj.getSlice(type, sliceNo, orient, col_channel);
    if ~isnan(options.fillBg)
        origSlice(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1,:) = imgIn{roiId2}(:,:,:);
    else
        origSliceCrop = origSlice(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1, :);
        modifiedSlice = imgIn{roiId2}(:,:,:);
        origSliceCrop(mask==1) = modifiedSlice(mask==1);
        origSlice(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1,:) = origSliceCrop;
    end
    %obj.setFullSlice(type, origSlice, sliceNo, orient, col_channel);
    obj.setSlice(type, origSlice, sliceNo, orient, col_channel);
    roiId2 = roiId2 + 1;
end
end