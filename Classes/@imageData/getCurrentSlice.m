function slice = getCurrentSlice(obj, type, countour_id)
% function slice = getCurrentSlice(obj, type, countour_id)
% Get currently shown slice.
%
% Parameters:
% type: a string with type of the dataset to retrieve, 'image', 'model', 'mask', 'selection'
% countour_id: - [@em optional],
% - when @b type is 'image', @b countour_id is a vector with color numbers to take, otherwise will take the colors selected in the imageData.slices{3} variable
% - when @b type is 'model' @b countour_id may be @em NaN - to take all material of the model or an integer to take specific material. In the later case the selected material in @b slice will have index = 1.
%
% Return values:
% slice: 3D image with dimensions [1:height, 1:width, 1:color]

%| 
% @b Examples
% @code slice = handles.Img{handles.Id}.I.getCurrentSlice('image');      // take the currently shown image  @endcode
% @code slice = handles.Img{handles.Id}.I.getCurrentSlice('model', 4); // Get object 4 from the model @endcode
% @code slice = obj.getCurrentSlice('image');      // Call within the class @endcode
% @attention @b sensitive to the imageData.blockModeSwitch
% @attention @b not @b sensitive to the shown ROI
% @attention for normal calls it is recommended to use ib_getSlice.m wrapper function, as @code
% slice = ib_getSlice('image', handles) @endcode

% Copyright (C) 30.10.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 03.09.2015, Ilya Belevich, updated to use the imageData.getData2D method
% 18.09.2016, changed .slices to cells

slice_no = obj.slices{obj.orientation}(1);
orient = obj.orientation;

if nargin == 3
    col_channel = countour_id;
else
    if strcmp(type,'image')
        col_channel=obj.slices{3};
    else
        col_channel = NaN;    % take complete model with all objects
    end
end
slice = obj.getData2D(type, slice_no, orient, col_channel);
end