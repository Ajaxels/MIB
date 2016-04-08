function slice_no = getCurrentSliceNumber(obj)
% function slice_no = getCurrentSliceNumber(obj)
% Get slice number of the currently shown image.
%
% Parameters:
%
% Return values:
% slice_no: index of the currently shown slice

%| 
% @b Examples:
% @code slice_no = imageData.getCurrentSliceNumber();      // take the currently shown image  @endcode
% @code slice_no = getCurrentSliceNumber(obj);      // Call within the class @endcode

% Copyright (C) 30.10.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices to cells

slice_no = obj.slices{obj.orientation}(1);
end