function clearMask(obj, height, width, z, t)
% function clearMask(obj, height, width, z)
% Clear the 'Mask' layer. It is also possible to specify
% the area where the 'Mask' layer should be cleared.
%
% Parameters:
% height: [@em optional] vector of heights, for example [1:imageData.height] or 0 - to initialize space for the new Mask
% width: [@em optional] vector of width, for example [1:imageData.width]
% z: [@em optional] vector of z-values, for example [1:imageData.no_stacks]
% t: [@em optional] vector of t-values, for example [1:imageData.time]
%
% Return values:
%

%| 
% @b Examples:
% @code imageData.clearMask();  // clear the mask layer @endcode
% @code clearMask(obj);   // Call within the class; clear the mask layer @endcode

% Copyright (C) 30.10.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 01.10.2014, added subarea
% 07.04.2016, IB, added 0 switch and the t paramter

if nargin < 5; t = 1:obj.time; end;
if nargin < 4; z = 1:obj.no_stacks; end;
if nargin < 3; width = 1:obj.width; end;

if strcmp(obj.model_type, 'uint6')  % 63 materials model type
    if isnan(obj.model(1)); return; end;    % selection is disabled
    if nargin < 2  % clear whole Mask
        obj.model = bitset(obj.model, 7, 0);
    else % clear part of the Mask
        if height == 0
            obj.model = bitset(obj.model, 7, 0);
            obj.maskExist = 1;
        else
            obj.model(height,width,z,:) = bitset(obj.model(height,width,z,t), 7, 0);
        end
    end
else                                % 255 materials model type
    if nargin < 2 % clear whole Mask
        obj.maskImg = NaN;
        %obj.maskImg = zeros(size(obj.img,1),size(obj.img,2),size(obj.img,4),'uint8');
    else    % clear part of the Mask
        if height == 0
            obj.maskImg = zeros(size(obj.selection),'uint8');
            obj.maskExist = 1;
        else
            obj.maskImg(height, width, z, t) = 0;
        end
    end
end

if nargin < 2  % extra things after clearing the whole Mask
        obj.maskExist = 0;
        [pathstr, fileName] = fileparts(obj.img_info('Filename'));
        obj.maskImgFilename = fullfile(pathstr, ['Mask_' fileName '.mask']);    
end

end