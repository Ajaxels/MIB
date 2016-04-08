function setRoiCrop(obj, type, imgIn, handles, roiNo, options, col_channel)
% function setRoiCrop(obj, type, imgIn, handles, roiNo, options, col_channel)
% Update a full 3D dataset from the defined ROI regions.
%
% @b Note! Requires an array of @b cells as @b imgIn
%
% Parameters:
% type: type of the image to update, 'image', 'model', 'mask', 'selection', or 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% imgIn: a cell array with ROIs 3D volumes, @code imgIn{roiNo}(1:height,1:width,1:color,1:thickness) @endcode
% handles: handles of im_browser.m
% roiNo: [@em optional] number of ROI to update, when @em omitted or @em NaN take the currently selected. When @b 0
% update all ROIs. Also it is possible to define ROI by its label as string
% of chars.
% options: [@em optional], a structure with extra parameters
% @li .fillBg -> when @b 1 -> keep the background from @b imgIn; when @b NaN [@b default] -> crop @b imgIn with respect to the ROI shape
% @li .t -> @b current, time point to get a 3D dataset
% col_channel: [@em optional], can be @em NaN;
% @li when @b type is 'image', col_channel is a vector with color numbers to update, when @b NaN [@e default] update set the
% colors selected in the imageData.slices{3} variable; when @b 0 - update all colors of the dataset.
% @li when @b type is 'model' col_channel may be @em NaN - to update all materials of the model or an integer to update specific material.
%
% Return values:

%| 
% @b Examples:
% @code imageData.setRoiCrop('image', imgIn, handles, 2);      // update whole dataset under ROI 2 as shaped ROI image.  @endcode
% @code imageData.setRoiCrop('image', imgIn, handles, 2, NaN, NaN, options.fillBg=1);  // update whole dataset under ROI 2 as rectangle image with areas outside the roi filled with image intensity of imgIn. @endcode
% @code setRoiCrop(obj, 'model', imgIn, handles, 0);      // Call within the class; update whole Model dataset under all ROIs @endcode
% @attention @b imgIn - is a cell object: @code imgIn{index}(1:height,1:width,1:color,1:z) @endcode
% @attention Implemented only for the XY plane
% @attention consider to use ib_setDataset.m wrapper function

% Copyright (C) 01.07.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 08.04.2014, update to new roiRegion class
% 07.09.2015, update to imageData.getData3D method
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

if nargin < 7; col_channel = NaN; end;
if nargin < 6; options = struct(); end;
if nargin < 5; roiNo = NaN; end;

if ~isfield(options, 'fillBg'); options.fillBg = 0; end;
if ~isfield(options, 't'); 
    options.t = [handles.Img{handles.Id}.I.slices{5}(1) handles.Img{handles.Id}.I.slices{5}(2)]; 
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
    [number, indices] = obj.hROI.getNumberOfROI();  % get number of ROI for the selected orientation
else
    indices = roiNo;
end

if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0; col_channel = 1:size(obj.img,3); end;
end

if strcmp(type, 'image')
    colorNo = numel(col_channel);
else
    colorNo = 1;
end

dataset = obj.getData4D(type, NaN, col_channel, options);  % existing dataset
for roiId = indices
    mask = obj.hROI.returnMask(roiId);
    STATS = regionprops(mask, 'BoundingBox');
    if isempty(STATS); continue; end;
    bb = round(STATS.BoundingBox);
    mask = mask(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1);
    mask = repmat(mask,[1, 1, colorNo]);
    
    if strcmp(type, 'image')
        for layerId = 1:size(dataset, ndims(dataset))
            if ~isnan(options.fillBg)
                dataset(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1,:,layerId) = modifiedSlice;
            else
                origSlice = dataset(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1,:,layerId);
                modifiedSlice = imgIn{roiId}(:,:,:,layerId);
                origSlice(mask==1) = modifiedSlice(mask==1);
                dataset(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1,:,layerId) = origSlice;
            end
        end
    else
        for layerId = 1:size(dataset, ndims(dataset))
            if ~isnan(options.fillBg)
                dataset(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1, layerId) = modifiedSlice;
            else
                origSlice = dataset(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1,layerId);
                modifiedSlice = imgIn{roiId}(:,:,layerId);
                origSlice(mask==1) = modifiedSlice(mask==1);
                dataset(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1, layerId) = origSlice;
            end
        end
    end
end
obj.setData4D(type, dataset, NaN, col_channel, options);
end