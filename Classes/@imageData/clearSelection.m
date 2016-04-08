function clearSelection(obj, height, width, z, t)
% function clearSelection(obj, height, width, z, t)
% Clear the 'Selection' layer. It is also possible to specify
% the area where the 'Selection' layer should be cleared.
%
% Parameters:
% height: [@em optional], can be @b NaN, a vector of heights, for example [1:imageData.height]
% width: [@em optional], can be @b NaN, a vector of width, for example [1:imageData.width]
% z: [@em optional] a vector of z-values, for example [1:imageData.no_stacks]
% t: [@em optional] a vector of t-values, for example [1:imageData.time]
%
% Return values:

%| 
% @b Examples:
% @code imageData.clearSelection(); // Clear the Selection layer completely @endcode
% @code imageData.clearSelection(1:imageData.height, 1:imageData.width, 1:3); // Clear the Selection layer only in 3 first slices  @endcode
% @code clearSelection(obj);  // Call within the class to clear the Selection layer completely @endcode

% Copyright (C) 12.12.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 20.01.2016, updated for 4D data

if nargin < 5; t = NaN; end;
if nargin < 4; z = NaN; end;
if nargin < 3; width = NaN; end;
if nargin < 2; height = NaN; end;

if isnan(t(1)); t = 1:size(obj.img, 5); end;
if isnan(z(1)); z = 1:size(obj.img, 4); end;
if isnan(width(1)); width = 1:size(obj.img, 2); end;
if isnan(height(1)); height = 1:size(obj.img, 1); end;

if ~strcmp(obj.model_type, 'uint6')
    if nargin < 2
        obj.selection = NaN;
        obj.selection = zeros(size(obj.img,1),size(obj.img,2),size(obj.img,4),size(obj.img,5),'uint8');
    else
        obj.selection(height, width, z, t) = 0;
    end
else
    if isnan(obj.model(1)); return; end;    % selection is disabled
    if nargin < 2
        obj.model = bitset(obj.model, 8, 0);
    else
        obj.model(height, width, z, t) = bitset(obj.model(height, width, z, t), 8, 0);
    end
end
end