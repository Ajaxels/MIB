function ib_setSlice(type, slice, handles, slice_no, orient, col_channel, options)
% function ib_setSlice(type, slice, handles, slice_no, orient, col_channel, options)
% Update the 2D slice of the dataset, the wrapper function
%
% This is a wrapper function, it uses the functions of the imageData class to update a slice of the dataset. When ROIs
% regions are shown in the axes (@em handles.roiShowCheck checkbox) the function updates only those ROI areas.
% @attention The input value is an array of cells!
%
% type: a type of the image to update, ''image'', ''model'', ''selection'', ''mask'', ''everything'' (for imageData.model_type==''uint6'' only)
% slice: a cell array with the slice slice{roiId}(1:height, 1:width, 1:color); @em roiId=1 when one or no ROI
% handles: handles structure of im_browser.m
% slice_no: [@em optional], a number of the slice to update, when @em empty or @em NaN update the currently shown slice
% orient: [@em optional], update a slice of the desired orientation
% - @b 0 (@b default) updates the slice transposed from the current orientation (obj.orientation)
% - @b 1 - xz
% - @b 2 - yz
% - @b 4 - xy
% - @b NaN - the current orientation
% col_channel: [@em optional],
% @li when @em type is 'image', col_channel is a vector with color numbers to update, when @b NaN [@e default] update set the
            % colors selected in the imageData.slices{3} variable; when @b 0 - update all colors of the dataset.
% @li when @em type is 'model' col_channel may be 0 - to update all materioals of the model or an integer to update specific material. 
% options: a structure with extra parameters
% @li .blockModeSwitch -> override the block mode switch imageData.blockModeSwitch @b 0 update full dataset / @b 1 - update cropped dataset
% @li .fillBg -> when @b NaN (@em default) -> crop slice with respect to the roi shape; when .@em fillBg is @b 1 update as a
% rectangle area
% @li .roiId -> @b index of roi to use, when @b 0 - update all shown ROIs. Also it is possible to define ROI by its label as string
% @li .t -> [@em optional], [tmin, tmax] the time point of the dataset; default is the currently shown time point

%| @b Examples:
% @code ib_setSlice('image', slice, handles, 5);      // update the 5-th slice of the current stack orientation  @endcode
% @code ib_setSlice('image', slice, handles, 5, 4, 2); // update the 5-th slice of the XY-orientation, color channel=2 @endcode
% @code ib_setSlice('model', slice, handles, 5, NaN, NaN, options.blockModeSwitch=1); // update the cropped to the viewing window 5-th slice of the current orientation, color channel=2 from the model @endcode
% @code ib_getSlice('model', slice, handles, 5, NaN, NaN, options.roiId=1);      // when handles.roiShowCheck enabled - update a slice that contains image under ROI number 1  @endcode

% Copyright (C) 13.02.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 08.04.2014, update to new roiRegion class
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

if nargin < 7; options = struct(); end
if nargin < 6; col_channel = NaN; end;
if nargin < 5; orient = NaN; end;
if nargin < 4; slice_no = NaN; end;

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
if isnan(orient) || orient==0; orient = handles.Img{handles.Id}.I.orientation; end;
if isnan(slice_no); slice_no = handles.Img{handles.Id}.I.getCurrentSliceNumber(); end;

if iscell(slice)
    if get(handles.roiShowCheck,'value') == 1   % do only for selected roi(s)
        handles.Img{handles.Id}.I.setRoiCropSlice(type, slice, handles, options.roiId, slice_no, orient, options, col_channel);
    else
        %handles.Img{handles.Id}.I.setSlice(type, slice{1}, slice_no, orient, col_channel, NaN, options);
        handles.Img{handles.Id}.I.setData2D(type, slice{1}, slice_no, orient, col_channel, NaN, options);
    end
else
    if get(handles.roiShowCheck,'value') == 1   % do only for selected roi(s)
        handles.Img{handles.Id}.I.setRoiCropSlice(type, {slice}, handles, options.roiId, slice_no, orient, options, col_channel);
    else
        %handles.Img{handles.Id}.I.setSlice(type, slice, slice_no, orient, col_channel, NaN, options);
        handles.Img{handles.Id}.I.setData2D(type, slice, slice_no, orient, col_channel, NaN, options);
    end
end

end