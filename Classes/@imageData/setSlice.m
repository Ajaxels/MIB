function custom_img = setSlice(obj, type, slice, slice_no, orient, col_channel, custom_img, options)
% function custom_img = setSlice(obj, type, slice, slice_no, orient, col_channel, custom_img, options)
% Update the 2D slice of the dataset
%
% Parameters:
% type: type of the image to update, 'image', 'model', 'mask', 'selection', or 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% slice: 2D image, for 'image' as [1:height,1:width,1:color]; for other layers as [1:height,1:width]
% slice_no: [@em optional] an index of the slice to update, when @em empty or @em NaN updates the current slice
% orient: [@em optional] update a slice in the desired orientation
% - @b 1 - xz
% - @b 2 - yz
% - @b 4 - xy
% - @b NaN - use the current orientation
% col_channel: [@em optional], can be @em NaN
% @li when @b type is 'image', col_channel is a vector with color numbers to update, when @b NaN [@e default] update set the
% colors selected in the imageData.slices{3} variable; when @b 0 - update all colors of the dataset.
% @li when @b type is 'model' col_channel may be @em NaN - to update all materials of the model or an integer to update specific material.
% custom_img:  [@em optional], can be @e NaN; update a slice not from the imageData class but from this custom_img (3D stack), requires the 'custom' @b type
% options: [@em optional], a structure with extra parameters
% @li .y -> [@em optional], [ymin, ymax] of the part of the slice to take
% @li .x -> [@em optional], [xmin, xmax] of the part of the slice to take
% @li .t -> [@em optional], [tmin, tmax] indicate the time point to take, when missing update the currently selected time point
%
% Return values:
% custom_img: a modified 3D stack, for the 'custom' type; or a
% status of the function run: @b - success, @b - fail.

%| 
% @b Examples:
% @code imageData.setSlice('image', slice, 5);      // set the 5-th slice of the current stack orientation  @endcode
% @code imageData.setSlice('image', slice, 5, 4, 2); // set the 5-th slice of the XY-orientation, color channel=2 @endcode
% @code custom_img = imageData.setSlice('custom', slice, 5, 1, 2, custom_img); // set the 5-th slice of the YZ-orientation, color channel=2 to the custom_image @endcode
% @code setSlice(obj, 'model', slice, 5, NaN, 2); // Call within the class; set the 5-th slice of the current orientation as the material 2 @endcode
% @attention @b sensitive to the @code imageData.blockModeSwitch @endcode
% @attention @b not @b sensitive to the shown ROI
% @attention consider to use ib_setSlice.m wrapper function

% Copyright (C) 20.06.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

if nargin < 8; options = struct();   end;
if nargin < 7; custom_img = NaN; end;
if nargin < 6; col_channel = NaN; end;
if nargin < 5; orient = NaN; end;
if nargin < 4; slice_no = NaN; end;

if isnan(slice_no); slice_no=obj.slices{obj.orientation}(1); end;
if isnan(orient); orient=obj.orientation; end;
if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0; col_channel = 1:size(obj.img,3); end;
end

if obj.blockModeSwitch == 0 && ~isfield(options, 'y')    % get the full size image
    if isnan(custom_img(1))
        setFullSlice(obj, type, slice, slice_no, orient, col_channel, custom_img, options);
        custom_img = 1;
    else
        custom_img = setFullSlice(obj, type, slice, slice_no, orient, col_channel, custom_img, options);
    end
else
    if isnan(custom_img(1))
        setSliceToShow(obj, type, slice, slice_no, orient, col_channel, custom_img, options);
        custom_img = 1;
    else
        custom_img = setSliceToShow(obj, type, slice, slice_no, orient, col_channel, custom_img, options);
    end
end
end