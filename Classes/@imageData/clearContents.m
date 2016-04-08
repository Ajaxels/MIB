function clearContents(obj, img)
% function clearContents(obj)
% Set all elements of the class to default values
%
% Parameters:
% img - @b [optional], image to use to initialize imageData class
%
% Return values:

%| 
% @b Examples:
% @code imageData.clearContents(); @endcode
% @code clearContents(obj); // Call within the class @endcode

% Copyright (C) 30.10.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 18.09.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

obj.model_fn = '';    % filename for an model image
obj.model_var = 'Amira_SemImage_cell_labels_pure_mat'; % variable name in the model mat-file
obj.modelMaterialNames = {};
obj.maskStat = struct();    %%% TO DO
obj.maskImgFilename = NaN;
obj.modelExist = 0;
obj.maskExist = 0;
obj.hLabels = Labels();     % initialize labels class
obj.hMeasure = Measure(obj);     % initialize measure class
obj.hROI = roiRegion(obj); % instanse to keep ROI data

if nargin < 2
    obj.img = imread('im_browser_dummy.jpg'); % dummy image
else
    obj.img = img; % dummy image
end
if strcmp(obj.model_type, 'uint8')
    obj.maskImg = zeros([size(obj.img,1) size(obj.img,2) 1],'uint8'); % bw filter data
    obj.selection = zeros([size(obj.img,1) size(obj.img,2) 1],'uint8'); % selection mask image
    obj.model = NaN; % model image
elseif strcmp(obj.model_type, 'uint6')
    obj.model = zeros([size(obj.img,1) size(obj.img,2) 1],'uint8');
    obj.maskImg = NaN;
    obj.selection = NaN;
elseif strcmp(obj.model_type, 'int8')
    obj.maskImg = zeros([size(obj.img,1) size(obj.img,2) 1],'int8'); %
    obj.selection = zeros([size(obj.img,1) size(obj.img,2) 1],'uint8'); % selection mask image
    obj.model = NaN; % model image
end

obj.no_stacks = size(obj.img,4);    % number of stacks in the dataset
obj.width = size(obj.img,2);
obj.height = size(obj.img,1);
obj.colors = size(obj.img,3);
obj.time = size(obj.img, 5);
obj.imh = 0;    % handle for image object
obj.pixSize.x = 0.087;
obj.pixSize.y = 0.087;
obj.pixSize.z = 0.087;
obj.pixSize.t = 1;
obj.pixSize.tunits = 's';
obj.pixSize.units = 'um';
obj.orientation = 4;
obj.current_yxz = [1 1 1];
obj.brush_prev_xy = NaN;
obj.brush_selection = NaN;
obj.viewPort = struct('min',0,'max',double(intmax(class(obj.img))),'gamma',1);
obj.model_diff_max = 255;
obj.trackerYXZ = [NaN;NaN;NaN];
obj.slices{1} = [1, size(obj.img,1)];   % height [min, max]
obj.slices{2} = [1, size(obj.img,2)];   % width [min, max]
obj.slices{3} = 1:size(obj.img,3);      % list of shown color channels [1, 2, 3, 4...]
obj.slices{4} = [1, 1];                 % z-values, [min, max]
obj.slices{5} = [1, 1];                 % time points, [min, max]
obj.axesX = [NaN NaN];
obj.axesY = [NaN NaN];
obj.magFactor = 1;
obj.blockModeSwitch = 0;
obj.storedSelection = NaN;

keySet = {'ColorType', 'ImageDescription','Height','Width','Stacks','Time','XResolution','YResolution','ResolutionUnit','Filename'};
valueSet = {'grayscale', sprintf('|'),obj.height,obj.width,obj.no_stacks,obj.time,1,1,'Inch','none.tif'};
obj.img_info = containers.Map(keySet,valueSet);
if obj.colors > 1
    obj.img_info('ColorType') = 'truecolor';
end

obj.Ishown = repmat(obj.img,[1 1 3]);   % data image RGB

% 
% if nargin == 2
%     handles = obj.replaceDataset(obj.img, handles);
% end
end