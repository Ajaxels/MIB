function [totalSize, imSize] = getDatasetSizeInBytes(obj)
% function [totalSize, imSize] = getDatasetSizeInBytes(obj)
% Get size of the loaded dataset in bytes
%
% For checking memory requirements when working with some functions (@b only @b for @b windows!). The amounts of physical memory used by Matlab and total memory available on the computer can be obtained with the following code:
% @code
% [userview, systemview] = memory;
% systemview.PhysicalMemory.Available // total memory
% userview.MemUsedMATLAB              // memory used by Matlab
% @endcode
% Parameters:
%
% Return values:
% totalSize: - total size of all layers in bytes
% imSize: - size of the image layer in bytes

%| 
% @b Examples:
% @code [totalSize, imSize] = imageData.getDatasetSizeInBytes();  // get both total and matlab memory amounts @endcode
% @code [totalSize, imSize] = getDatasetSizeInBytes(obj);   // Call within the class; get both total and matlab memory amounts  @endcode

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, IB, added check for Windows OS
% 21.02.2016, IB, updated for 4D datasets

if ~ispc
    totalSize = NaN;
    imSize = NaN;
    errordlg(sprintf('!!! Error !!!\n\nMemory function is only available for the Windows OS'));
    return;
end

switch class(obj.img)
    case 'uint8'
        memoryMultiplier = 1;   % one byte per pixel
    case 'uint16'
        memoryMultiplier = 2;   % two bytes per pixel
    case 'uint32'
        memoryMultiplier = 4;   % four bytes per pixel
end

imSize = size(obj.img);
if numel(imSize) < 5; imSize(5) = 1; end;
imSize = imSize(1)*imSize(2)*imSize(3)*imSize(4)*imSize(5)*memoryMultiplier;

memoryMultiplier = 1;
otherLayers = 0;
if strcmp(obj.model_type, 'uint6')
    if ~isnan(obj.model(1))
        otherLayers = size(obj.model);
        if numel(otherLayers) < 4; otherLayers(4) = 1; end;
        otherLayers = otherLayers(1)*otherLayers(2)*otherLayers(3)*otherLayers(4);
    end
else    % for uint8 and int8 models - each layer is placed in own container obj.selection, obj.maskImg, obj.model
    if isnan(obj.selection(1))
        otherLayers = 1;
    else
        otherLayers = size(obj.selection);
        if numel(otherLayers) < 4; otherLayers(4) = 1; end;
        if obj.maskExist; memoryMultiplier = memoryMultiplier + 1; end
        if obj.modelExist; memoryMultiplier = memoryMultiplier + 1; end
        otherLayers = otherLayers(1)*otherLayers(2)*otherLayers(3)*otherLayers(4)*memoryMultiplier;
    end
end
totalSize = imSize + otherLayers;
end