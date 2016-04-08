function ib_setDataset(type, dataset, handles, orient, col_channel, options)
% function ib_setDataset(type, dataset, handles, orient, col_channel, options)
% Update complete 4D volume of the dataset, a wrapper function
%
% This is a wrapper function, it uses the functions of the imageData class to update the whole volume in the dataset. When ROIs
% regions are shown in the axes (@em handles.roiShowCheck checkbox) the function updates only those ROI areas.
% @attention The input value is an array of cells!
%
% Parameters:
% type: a type of the image to update, ''image'', ''model'', ''selection'', ''mask'', ''everything'' (for imageData.model_type==''uint6'' only)
% dataset: a cell array with the datasets dataset{roiId}(1:height, 1:width, 1:color, 1:z); @em roiId=1 when one or no ROI
% handles: handles structure of im_browser.m
% orient: [@em optional], can be @em NaN or @em empty
% @li when @b 0 (@b default) returns the dataset transposed to the current orientation (obj.orientation)
% @li when @b 1 returns transposed dataset to the zx configuration: [y,x,c,z] -> [x,z,c,y]
% @li when @b 2 returns transposed dataset to the zy configuration: [y,x,c,z] -> [y,z,c,y]
% @li when @b 3 not used
% @li when @b 4 returns original dataset to the yx configuration: [y,x,c,z]
% @li when @b 5 not used
% col_channel: [@em optional],
% @li when @em type is 'image', col_channel is a vector with color numbers to update, when @b NaN [@e default] update set the
            % colors selected in the imageData.slices{3} variable; when @b 0 - update all colors of the dataset.
% @li when @em type is 'model' col_channel may be @em NaN - to update all materials of the model or an integer to update specific material. 
% options: a structure with extra parameters
% @li .blockModeSwitch -> override the block mode switch imageData.blockModeSwitch  @b 0 update full dataset / @b 1 - update cropped dataset
% @li .fillBg -> when @b NaN (@em default) -> crop slice with respect to the roi shape; when .@em fillBg is @b 1 update as a
% rectangle area
% @li .roiId -> @b index of roi to use; when @b 0 - update all shown ROIs. Also it is possible to define ROI by its label as string
% @li .t -> @b current, time point to get a 3D dataset

%| @b Examples:
% @code ib_setDataset('image', dataset, handles);      // update the whole stack in the shown orientation @endcode
% @code ib_setDataset('image', dataset, handles, 4, 2); // update the whole stack in yx orientation for color channel=2 @endcode
% @code ib_setDataset('model', dataset, handles, NaN, NaN, options.blockModeSwitch=1); // update the part of the whole model stack visible in the viewing window @endcode
% @code ib_setDataset('model', dataset, handles, NaN, NaN, NaN, options.roiId=1);      // when handles.roiShowCheck enabled - update the part of the whole model stack visible under ROI number 1  @endcode

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
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

if nargin < 6; options = struct(); end
if nargin < 5; col_channel = NaN; end;
if nargin < 4; orient = NaN; end;

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
if isempty(isnan(orient)) || isempty(orient) || isnan(orient); orient=handles.Img{handles.Id}.I.orientation; end;
if ~iscell(dataset); dataset = {dataset}; end;

if get(handles.roiShowCheck,'value') == 1   % do only for selected roi(s)
    handles.Img{handles.Id}.I.setRoiCrop(type, dataset, handles, options.roiId, options, col_channel);
else
    handles.Img{handles.Id}.I.setData4D(type, dataset{1}, orient, col_channel, options);
end
end