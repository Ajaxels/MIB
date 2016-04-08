function transpose(obj, new_orient)
% function transpose(obj, new_orient)
% Change orientation of the image to the XY, XZ, or YZ plane.
%
% @note This function updates only the imageData.slices and imageData.orientation variables and do not rearrange the actual datasets.
%
% Parameters:
% new_orient: a desired orientation:
% @li @b 1 -> XZ plane
% @li @b 2 -> YZ plane
% @li @b 3 -> YX plane
%
% Return values:

%| 
% @b Examples:
% @code imageData.transpose(1);      // transpose to the XZ plane  @endcode
% @code transpose(obj, 1); // Call within the class; transpose to the XZ plane  @endcode

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}


if obj.orientation == 1 % xz     % remember index of the slice
    obj.current_yxz(1) = obj.slices{1}(1);
elseif obj.orientation == 2 % yz
    obj.current_yxz(2) = obj.slices{2}(1);
elseif obj.orientation == 4 % yx
    obj.current_yxz(3) = obj.slices{4}(1);
end

switch new_orient
    case 4  %'yx'
        obj.orientation = 4; % ('yx';
        obj.slices{1} = [1, obj.height];
        obj.slices{2} = [1, obj.width];
        obj.slices{4} = [obj.current_yxz(3), obj.current_yxz(3)];
    case 1 %'xz'
        obj.orientation = 1; %'xz';
        obj.slices{1} = [obj.current_yxz(1), obj.current_yxz(1)];
        obj.slices{2} = [1, obj.width];
        obj.slices{4} = [1, obj.no_stacks];
    case 2 %'yz'
        obj.orientation = 2; %'yz';
        obj.slices{1} = [1, obj.height];
        obj.slices{2} = [obj.current_yxz(2), obj.current_yxz(2)];
        obj.slices{4} = [1, obj.no_stacks];
end
end