function setCurrentSlice(obj, type, slice, color_id)
% function setCurrentSlice(obj, type, slice, color_id)
% Update the currently shown slice of the dataset.
%
% Parameters:
% type: type of the dataset to update, 'image', 'model', 'mask', 'selection', 'everything'('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% slice: a new 2D slice, for the ''image'' type [1:height,1:width, 1:color], for other latyers [1:height,1:width]
% color_id: [optional],
% @li when @b type is 'image', color_id is a vector with color numbers to set, otherwise will update the colors selected in the imageData.slices{3} variable
% @li when @b type is 'model' color_id may be 0 - to update all materials of the model or an integer to update specific material.
%
% Return values:

%| 
% @b Examples:
% @code imageData.setCurrentSlice('image', slice);      // update the currently shown image with data in slice @endcode
% @code imageData.setCurrentSlice('model', slice, 4); // replace material 4 with contents of slice @endcode
% @code slice = imageData.getCurrentSlice('model', 4); // get material 4 @endcode
% @code imageData.setCurrentSlice('model', slice, 1); // set it as material 1 @endcode
% @code setCurrentSlice(obj, 'model', slice, 1); // Call within the class; set it as material 1 @endcode
% @attention @b sensitive to the @code imageData.blockModeSwitch @endcode
% @attention @b not @b sensitive to the shown ROI
% @attention for normal calls it is recommended to use ib_setSlice.m wrapper function, as @code
% ib_setSlice('image', slice, handles); @endcode

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}


slice_no = obj.slices{obj.orientation}(1);
if nargin == 4
    col_channel = color_id;
else
    if strcmp(type,'image')
        col_channel=obj.slices{3};
    else
        col_channel = NaN;    % take complete model with all objects
    end
end
setSlice(obj, type, slice, slice_no, obj.orientation, col_channel);
end