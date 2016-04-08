function imgOut = getRoiCrop(obj, type, handles, roiNo, options, col_channel)
% function imgOut = getRoiCrop(obj, type, handles, roiNo, options, col_channel)
% Get a 3D dataset from the defined ROI regions.
%
% Returns a @b cell(s) imgOut 3D stacks of the shown ROIs
%
% Parameters:
% type: type of the dataset to retrieve, 'image', 'model', 'mask', 'selection', or 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% handles: handles of im_browser.m
% roiNo: [@em optional] number of ROI to get, when @em omitted or @em NaN (@b default) take the currently selected ROIs. When @b 0
% take all ROIs. Also it is possible to define ROI by its label as string
% of chars.
% options: [@em optional], a structure with extra parameters
% @li .fillBg -> when @em NaN (@b default) -> crops the dataset as a rectangle; when @em a @em number fills the areas out
% of the ROI area with this intensity number
% @li .t -> @b current, time point to get a 3D dataset
% col_channel: [@em optional],
% @li when @b type is 'image', col_channel is a vector with color numbers to take, , when @b NaN [@e default] take the colors
% selected in the imageData.slices{3} variable, when @b 0 - take all colors of the dataset.
% @li when @b type is 'model' col_channel may be @em NaN - to take all materials of the model or an integer to take specific material. In the later case the selected material will have index = 1.
%
% Return values:
% imgOut: a cell array with 3D datasets from each selected ROI

%| 
% @b Examples:
% @code imgOut = imageData.getRoiCrop('image', handles, 2);      // get the whole dataset under ROI 2 as rectangle image @endcode
% @code imgOut = imageData.getRoiCrop('image', handles, 2, options.fillBg=255);  // get the whole dataset under  ROI 2 as rectangle image with areas outside the roi filled with 255 intensity @endcode
% @code imgOut = getRoiCrop(obj, 'model', handles, 0);      // Call within the class; get all ROIs from the Model layer  @endcode
% @attention @b imgOut - is a cell object that can be accessed as @code
% imgOut{index}(1:height,1:width,1:color,1:z) @endcode
% @attention Implemented only for the XY plane
% @attention It is possible to use ib_getDataset.m wrapper function that takes into account shown ROIs

% Copyright (C) 01.07.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 08.04.2014, IB, update to new roiRegion class
% 07.09.2015, IB updated to use imageData.getData3D methods
% 18.09.2016, changed .slices to cells
% 20.01.2016, updated for 4D

if nargin < 6; col_channel = NaN;        end;
if nargin < 5; options = struct();        end;
if nargin < 4; 
    roiNo = NaN;
end;
if ~isfield(options, 'fillBg'); options.fillBg = NaN; end;
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
    if col_channel(1) == 0;  col_channel = 1:size(obj.img,3); end;
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
    if isempty(STATS); continue; end;
    bb = round(STATS.BoundingBox);
    dataset = obj.getData4D(type, NaN, col_channel, options);
    
    imgOut{roiId2} = dataset(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1, :, :); %#ok<AGROW>
    
    clear dataset;
    if ~isnan(options.fillBg)
        mask = mask(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1);
        mask = repmat(mask,[1, 1, colorNo]);
        for layerId = 1:obj.no_stacks
            if strcmp(type, 'image')
                slice = imgOut{roiId2}(:,:,:,layerId);
                slice(~mask) = options.fillBg;
                imgOut{roiId2}(:,:,:,layerId) = slice; %#ok<AGROW>
            else
                slice = imgOut{roiId2}(:,:,layerId);
                slice(~mask) = options.fillBg;
                imgOut{roiId2}(:,:,layerId) = slice; %#ok<AGROW>
            end
        end
    end
    roiId2 = roiId2 + 1;
end
end