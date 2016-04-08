function custom_img = setFullSlice(obj, type, slice, slice_no, orient, col_channel, custom_img, options)
% function custom_img = setFullSlice(obj, type, slice, slice_no, orient, col_channel, custom_img, options)
% Update the full 2D slice of the dataset
%
% Parameters:
% type: type of the image to update, 'image', 'model', 'mask', 'selection', 'custom', '@e everything' (get model, selection and mask, when imageData.model_type==''uint6'')
% slice: 2D image, for 'image' type: [1:height, 1:width, 1:color], and [1:height, 1:width] for all other layers
% slice_no: [@em optional], number of the slice to set, when @em empty or @em NaN update the current slice
% orient: [@em optional], update the slice in the desired orientation
% - @b 1 - xz
% - @b 2 - yz
% - @b 4 - xy
% - @b NaN - the current orientation
% col_channel: [@em optional], can be @em NaN
% @li when @b type is 'image', col_channel is a vector with color numbers to set, when @b NaN [@e default] update set the
% colors selected in the imageData.slices{3} variable; when @b 0 - update all colors of the dataset.
% @li when @b type is 'model' col_channel may be @em NaN - to update all materials of the model or an integer to update specific material.
% custom_img: [@em optional], can be @e NaN; update a slice not from the imageData class but from this custom_img (3D dataset), requires the 'custom' @b type
% options: [@em optional], a structure with extra parameters
% @li .y -> [@em optional], [ymin, ymax] of the part of the slice to take
% @li .x -> [@em optional], [xmin, xmax] of the part of the slice to take
% @li .t -> [@em optional], [tmin, tmax] the time point of the dataset; default is the currently shown time point
%
% Return values:
% custom_img:
% - a modified 3D stack, for the '@e custom' type, or @b 1 for
% success and @b 0 for an error of the function run

%| 
% @b Examples:
% @code imageData.setFullSlice('image', slice, 5);      // assign slice to the 5-th slice of the current stack orientation  @endcode
% @code imageData.setFullSlice('image', slice, 5, 4, 2); // assign slice to the 5-th slice of the XY-orientation, color channel=2 @endcode
% @code custom_img = imageData.setFullSlice('custom', slice, 5, 1, 2, custom_img); // assign slice to the 5-th slice of the YZ-orientation, color channel=2 to the custom_image @endcode
% @code setFullSlice(obj,'image', slice, NaN, NaN, 2); // Call within the class; assign slice to the current slice of the current orientation, color channel=2 @endcode
% @attention @b not @b sensitive to the @code imageData.blockModeSwitch @endcode
% @attention @b not @b sensitive to the shown ROI
% @attention see also im_setSlice.m a wrapper function.

% Copyright (C) 19.06.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}
% 18.09.2016, changed .slices to cells

if nargin < 8; options = struct(); end;
if nargin < 7; custom_img = NaN; end;
if nargin < 6; col_channel = NaN; end;
if nargin < 5; orient = NaN; end;
if nargin < 4; slice_no=NaN; end;

if isnan(slice_no); slice_no=obj.slices{obj.orientation}(1); end;
if orient==0 || isnan(orient); orient=obj.orientation; end;

if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0; col_channel = 1:size(obj.img,3); end;
end

optionsGetDims.blockModeSwitch = 0;
[height,width] = obj.getDatasetDimensions('image', NaN, NaN, optionsGetDims);
if isfield(options, 'y');
    optionsOut.x(1) = max([options.x(1) 1]);
    optionsOut.x(2) = min([options.x(2) width]);
    optionsOut.y(1) = max([options.y(1) 1]);
    optionsOut.y(2) = min([options.y(2) height]);
else
    optionsOut.x = [1 width];
    optionsOut.y = [1 height];
end
if isfield(options, 't')
    optionsOut.t = options.t;
else
    optionsOut.t = [obj.slices{5}(1), obj.slices{5}(2)];
end

custom_img = obj.setData2D(type, slice, slice_no, orient, col_channel, custom_img, optionsOut);
if isnan(custom_img(1)); custom_img = 1; end;
end