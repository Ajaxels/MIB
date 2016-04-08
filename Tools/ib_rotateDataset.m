function handles = ib_rotateDataset(handles, mode)
% function handles = ib_rotateDataset(handles, mode)
% Rotate dataset in 90 or -90 degrees
% 
% Rotate dataset in 90 or -90 degrees
%
% Parameters:
% handles: handles structure of im_browser
% mode: -> a string that defines the rotation
%     - ''rot90'' -> rotate dataset to 90 degrees clock-wise
%     - ''rot-90'' -> rotate dataset to 90 degrees anti clock-wise
%
% Return values:
% handles: handles structure of im_browser

% Copyright (C) 25.06.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 04.02.2016, IB, updated for 4D datasets

options.blockModeSwitch = 0;    % overwrite blockmode switch

wb = waitbar(0,sprintf('Rotating image\nPlease wait...'),'Name','Rotate dataset','WindowStyle','modal');

% rotate image
[hMax, wMax, cMax, zMax, tMax] = handles.Img{handles.Id}.I.getDatasetDimensions('image', 4, NaN, options);
cMax = numel(cMax);

imgOut = zeros([wMax, hMax, cMax, zMax, tMax], class(handles.Img{handles.Id}.I.img)); %#ok<ZEROLIKE>
% rotate image
for t=1:tMax
    img = handles.Img{handles.Id}.I.getData3D('image', t, 4, 0, options);   % get z-stack (image)
    imgOut(:,:,:,:,t) = rotateme(img, mode);
    waitbar(t/tMax, wb);
end
handles.Img{handles.Id}.I.setData4D('image', imgOut, 4, 0, options);   % set dataset (image) back
clear imgOut;

% rotate other layers
if strcmp(handles.Img{handles.Id}.I.model_type, 'uint6') && strcmp(handles.preferences.disableSelection, 'no')
    waitbar(0.5, wb, sprintf('Rotating other layers\nPlease wait...'));
    img = handles.Img{handles.Id}.I.model;  % get everything
    handles.Img{handles.Id}.I.model = zeros([wMax, hMax, zMax, tMax], 'uint8');
    for t=1:tMax
        handles.Img{handles.Id}.I.setData3D('everything', rotateme(img(:,:,:,t), mode), t, 4, NaN, options);   % set dataset (everything) back
        waitbar(t/tMax, wb);
    end
elseif  strcmp(handles.preferences.disableSelection, 'no')
    % Rotate selection layer
    waitbar(0.25, wb, sprintf('Rotating the selection layer\nPlease wait...'));
    img = handles.Img{handles.Id}.I.selection;  % get selection
    handles.Img{handles.Id}.I.selection = zeros([wMax, hMax, zMax, tMax], 'uint8');
    for t=1:tMax
        handles.Img{handles.Id}.I.setData3D('selection', rotateme(img(:,:,:,t), mode), t, 4, NaN, options);   % set dataset (everything) back
        waitbar(t/tMax, wb);
    end
    
    % Rotate mask
    if handles.Img{handles.Id}.I.maskExist
        waitbar(0.5, wb, sprintf('Rotating the mask layer\nPlease wait...'));
        img = handles.Img{handles.Id}.I.maskImg;  % get mask
        handles.Img{handles.Id}.I.selection = zeros([wMax, hMax, zMax, tMax], 'uint8');
        for t=1:tMax
            handles.Img{handles.Id}.I.setData3D('mask', rotateme(img(:,:,:,t), mode), t, 4, NaN, options);   % set dataset (everything) back
            waitbar(t/tMax, wb);
        end
    end
    
    % Rotate model
    if handles.Img{handles.Id}.I.modelExist
        waitbar(0.75, wb, sprintf('Rotating the model layer\nPlease wait...'));
        img = handles.Img{handles.Id}.I.model;  % get model
        handles.Img{handles.Id}.I.model = zeros([wMax, hMax, zMax, tMax], 'uint8');
        for t=1:tMax
            handles.Img{handles.Id}.I.setData3D('model', rotateme(img(:,:,:,t), mode), t, 4, NaN, options);   % set dataset (everything) back
            waitbar(t/tMax, wb);
        end
    end
end
waitbar(1, wb, sprintf('Finishing...'));
clear img;

% swap pixSize.x and pixSize.y
dummy = handles.Img{handles.Id}.I.pixSize.x;
handles.Img{handles.Id}.I.pixSize.x = handles.Img{handles.Id}.I.pixSize.y;
handles.Img{handles.Id}.I.pixSize.y = dummy;

% update the bounding box
bb = handles.Img{handles.Id}.I.getBoundingBox();    % get current bounding box
dummy = bb(1:2);
bb(1:2) = bb(3:4);
bb(3:4) = dummy;
handles.Img{handles.Id}.I.updateBoundingBox(bb);  % update bounding box

log_text = ['Rotate: mode=' mode];
handles.Img{handles.Id}.I.updateImgInfo(log_text);
delete(wb);
end

function imgOut = rotateme(img, mode)
% rotate function
if ndims(img) == 4  % for image
    imgOut = zeros([size(img,2), size(img,1), size(img,3), size(img,4)], class(img)); %#ok<ZEROLIKE>
    colorNo = size(img,3);
    for slice = 1:size(img, 4)
        if strcmp(mode, 'rot90')
            for color = 1:colorNo
                imgOut(:,:,color,slice) = rot90(img(:,:,color,slice), 3);
            end
        elseif strcmp(mode, 'rot-90')
            for color = 1:colorNo
                imgOut(:,:,color,slice) = rot90(img(:,:,color,slice));
            end
        end
    end
else    % for other layers
    imgOut = zeros([size(img,2), size(img,1), size(img,3)], class(img)); %#ok<ZEROLIKE>
    for slice = 1:size(img, 3)
        if strcmp(mode, 'rot90')
            imgOut(:,:,slice) = rot90(img(:,:,slice), 3);
        elseif strcmp(mode, 'rot-90')
            imgOut(:,:,slice) = rot90(img(:,:,slice));
        end
    end
end
end