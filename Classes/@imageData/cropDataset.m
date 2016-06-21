function cropDataset(obj, cropF)
% function cropDataset(obj, cropF)
% Crop image and all corresponding layers of the opened dataset
%
% Parameters:
% cropF: a vector [x1, y1, dx, dy, z1, dz, t1, dt] with parameters of the crop. @b Note! The units are pixels!
%
% Return values:

%| 
% @b Examples:
% @code cropF = [100 512 200 512 5 20];  // define parameters of the crop.  @endcode
% @code imageData.cropDataset(cropF);  // do the crop @endcode
% @code cropDataset(obj, cropF);   // Call within the class; do the crop @endcode

% Copyright (C) 30.10.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 18.09.2016, IB, changed .slices to cells
% 25.01.2016, IB, updated to 5D 

wb = waitbar(0,'Please wait...','Name','Cropping...');

% define time points
if numel(cropF) < 7; cropF(7:8) = [1, obj.time]; end;

%newI = zeros([cropF(4),cropF(3),size(obj.img,3),cropF(6) cropF(8)],class(obj.img));
waitbar(.05, wb);
%[x1, y1, dx, dy, z1, dz, t1, dt]
obj.img = obj.img(cropF(2):cropF(2)+cropF(4)-1, cropF(1):cropF(1)+cropF(3)-1, :, ...
            cropF(5):cropF(5)+cropF(6)-1, cropF(7):cropF(7)+cropF(8)-1);
waitbar(.4, wb);
clear newI;
if ~strcmp(obj.model_type, 'uint6')
    if obj.modelExist % crop model
        obj.model = obj.model(cropF(2):cropF(2)+cropF(4)-1, cropF(1):cropF(1)+cropF(3)-1, ...
            cropF(5):cropF(5)+cropF(6)-1, cropF(7):cropF(7)+cropF(8)-1);
    end
    waitbar(.7, wb);
    if obj.maskExist     % crop mask
        obj.maskImg = obj.maskImg(cropF(2):cropF(2)+cropF(4)-1, cropF(1):cropF(1)+cropF(3)-1, ...
            cropF(5):cropF(5)+cropF(6)-1, cropF(7):cropF(7)+cropF(8)-1);
    end
elseif ~isnan(obj.model(1))     % crop model/selectio/mask layer
    obj.model = obj.model(cropF(2):cropF(2)+cropF(4)-1, cropF(1):cropF(1)+cropF(3)-1, ...
            cropF(5):cropF(5)+cropF(6)-1, cropF(7):cropF(7)+cropF(8)-1);
end
waitbar(.9, wb);
obj.height = cropF(4);
obj.width = cropF(3);
obj.no_stacks = cropF(6);
obj.time = cropF(8);

current_layer = obj.slices{obj.orientation}(1);
obj.slices{1} = [1, obj.height];
obj.slices{2} = [1, obj.width];
obj.slices{4} = [1, obj.no_stacks];
obj.slices{5} = [min([obj.slices{5} obj.time]) min([obj.slices{5} obj.time])];
obj.slices{obj.orientation} = [current_layer, current_layer];

if obj.height < obj.current_yxz(1); obj.current_yxz(1) = obj.height; end;
if obj.width < obj.current_yxz(2); obj.current_yxz(2) = obj.width; end;
if obj.no_stacks < obj.current_yxz(3); obj.current_yxz(3) = obj.no_stacks; end;

obj.img_info('Height') = cropF(4);
obj.img_info('Width') = cropF(3);
obj.img_info('Stacks') = obj.no_stacks;
obj.img_info('Time') = obj.time;

% update name of slices if present
if isKey(obj.img_info, 'SliceName')
    sliceNames = obj.img_info('SliceName');
    if numel(obj.img_info('SliceName')) > 1
        obj.img_info('SliceName') = sliceNames(cropF(5):cropF(5)+cropF(6)-1);
    end
end

xyzShift = [(cropF(1)-1)*obj.pixSize.x (cropF(2)-1)*obj.pixSize.y (cropF(5)-1)*obj.pixSize.z];
% update BoundingBox Coordinates
obj.updateBoundingBox(NaN, xyzShift);
waitbar(1, wb);
delete(wb);
end