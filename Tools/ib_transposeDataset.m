function handles = ib_transposeDataset(handles, mode)
% function handles = ib_transposeDataset(handles, mode)
% Transpose dataset physically between dimensions
%
% Parameters:
% handles: handles structure of im_browser
% mode: -> a string that defines the transpose dimension
%     - ''xy2zx'' -> transpose so that XY dimension becomes ZX
%     - ''xy2zy'' -> transpose so that XY dimension becomes ZY
%     - ''zx2zy'' -> transpose so that ZX dimension becomes ZY
%     - ''z2t'' -> transpose so that Z-dimension becomes T-dimension
%
% Return values:
% handles: handles structure of im_browser

% Copyright (C) 04.07.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 04.02.2016, IB, updated for 4D datasets, added z->t mode

options.blockModeSwitch = 0;    % overwrite blockmode switch
tic
handles.U.clearContents(); % clear undo history

[yMax, xMax, cMax, zMax, tMax] = handles.Img{handles.Id}.I.getDatasetDimensions('image', 4, NaN, options);
cMax = numel(cMax);
switch mode
    case 'xy2zx'
        imgOut = zeros([zMax, xMax, cMax, yMax, tMax], class(handles.Img{handles.Id}.I.img)); %#ok<ZEROLIKE>
    case 'xy2zy'
        imgOut = zeros([yMax, zMax, cMax, xMax tMax], class(handles.Img{handles.Id}.I.img)); %#ok<ZEROLIKE>
    case 'zx2zy'
        imgOut = zeros([yMax, xMax, cMax, zMax, tMax], class(handles.Img{handles.Id}.I.img)); %#ok<ZEROLIKE>
    case 'z2t'
        handles = convertZ2T(handles);
        log_text = 'Rotate: mode=Z->T';
        handles.Img{handles.Id}.I.updateImgInfo(log_text);
        handles = updateGuiWidgets(handles);
        
        % Update handles structure
        guidata(handles.im_browser, handles);
        toc;
        return;
end
wb = waitbar(0,sprintf('Transposing the image\nPlease wait...'),'Name',sprintf('Transpose dataset [%s]', mode),'WindowStyle','modal');

outputDims = size(imgOut);
% transpose the image layer
for t=1:tMax
    img = handles.Img{handles.Id}.I.getData3D('image', t, 4, 0, options);   % get z-stack (image)
    imgOut(:,:,:,:,t) = transposeme(img, mode);
    waitbar(t/tMax, wb)
end
handles.Img{handles.Id}.I.setData4D('image', imgOut, 4, 0, options);   % set dataset (image) back
clear imgOut;

% transpose other layers
if strcmp(handles.Img{handles.Id}.I.model_type, 'uint6') && strcmp(handles.preferences.disableSelection, 'no')
    waitbar(0.5, wb, sprintf('Transposing other layers\nPlease wait...'));
    img = handles.Img{handles.Id}.I.model;  % get everything
    handles.Img{handles.Id}.I.model = zeros([outputDims(1), outputDims(2), outputDims(4), outputDims(5)], 'uint8');
    for t=1:tMax
        handles.Img{handles.Id}.I.setData3D('everything', transposeme(img(:,:,:,t), mode), t, 4, NaN, options);   % set dataset (everything) back
        waitbar(t/tMax, wb);
    end
elseif  strcmp(handles.preferences.disableSelection, 'no')
    % transpose selection layer
    waitbar(0.25, wb, sprintf('Transposing the selection layer\nPlease wait...'));
    img = handles.Img{handles.Id}.I.selection;  % get selection
    handles.Img{handles.Id}.I.selection = zeros([outputDims(1), outputDims(2), outputDims(4), outputDims(5)], 'uint8');
    for t=1:tMax
        handles.Img{handles.Id}.I.setData3D('selection', transposeme(img(:,:,:,t), mode), t, 4, NaN, options);   % set dataset (everything) back
        waitbar(t/tMax, wb);
    end
    
    % transpose mask
    if handles.Img{handles.Id}.I.maskExist
        waitbar(0.5, wb, sprintf('Transposing the mask layer\nPlease wait...'));
        img = handles.Img{handles.Id}.I.maskImg;  % get mask
        handles.Img{handles.Id}.I.maskImg = zeros([outputDims(1), outputDims(2), outputDims(4), outputDims(5)], 'uint8');
        for t=1:tMax
            handles.Img{handles.Id}.I.setData3D('mask', transposeme(img(:,:,:,t), mode), t, 4, NaN, options);   % set dataset (everything) back
            waitbar(t/tMax, wb);
        end
    end
    
    % transpose model
    if handles.Img{handles.Id}.I.modelExist
        waitbar(0.75, wb, sprintf('Transposing the model layer\nPlease wait...'));
        img = handles.Img{handles.Id}.I.model;  % get model
        handles.Img{handles.Id}.I.model = zeros([outputDims(1), outputDims(2), outputDims(4), outputDims(5)], 'uint8');
        for t=1:tMax
            handles.Img{handles.Id}.I.setData3D('model', transposeme(img(:,:,:,t), mode), t, 4, NaN, options);   % set dataset (everything) back
            waitbar(t/tMax, wb);
        end
    end
end
waitbar(1, wb, sprintf('Finishing...'));
clear img;

% % update the bounding box
bb = handles.Img{handles.Id}.I.getBoundingBox();    % get current bounding box

switch mode
    case 'xy2zx'
        % swap pixSize.y and pixSize.z
        dummy = handles.Img{handles.Id}.I.pixSize.y;
        handles.Img{handles.Id}.I.pixSize.y = handles.Img{handles.Id}.I.pixSize.z;
        handles.Img{handles.Id}.I.pixSize.z = dummy;
        % update the bounding box
        dummy = bb(3:4);
        bb(3:4) = bb(5:6);
        bb(5:6) = dummy;
    case 'xy2zy'
        % swap pixSize.x and pixSize.z
        dummy = handles.Img{handles.Id}.I.pixSize.x;
        handles.Img{handles.Id}.I.pixSize.x = handles.Img{handles.Id}.I.pixSize.z;
        handles.Img{handles.Id}.I.pixSize.z = dummy;
        % update the bounding box
        dummy = bb(1:2);
        bb(1:2) = bb(5:6);
        bb(5:6) = dummy;
    case 'zx2zy'
        % swap pixSize.y and pixSize.x
        dummy = handles.Img{handles.Id}.I.pixSize.x;
        handles.Img{handles.Id}.I.pixSize.x = handles.Img{handles.Id}.I.pixSize.y;
        handles.Img{handles.Id}.I.pixSize.y = dummy;
        % update the bounding box
        dummy = bb(1:2);
        bb(1:2) = bb(3:4);
        bb(3:4) = dummy;
end
handles.Img{handles.Id}.I.updateBoundingBox(bb);  % update bounding box

log_text = ['Transpose: mode=' mode];
handles.Img{handles.Id}.I.updateImgInfo(log_text);

delete(wb);
toc;
end

function img = transposeme(img, mode)
% transpose function
%     - ''xy2zx'' -> transpose so that XY dimension becomes ZX
%     - ''xy2zy'' -> transpose so that XY dimension becomes ZY
%     - ''zx2zy'' -> transpose so that ZX dimension becomes ZY

if ndims(img) == 4  % for image
    switch mode
        case 'xy2zx'
            img = permute(img,[4, 2, 3, 1]);
        case 'xy2zy'
            img = permute(img,[1, 4, 3, 2]);
        case 'zx2zy'
            img = permute(img,[2, 1, 3, 4]);
    end
else     % for other layers
    switch mode
        case 'xy2zx'
            img = permute(img,[3, 2, 1]);
        case 'xy2zy'
            img = permute(img,[1, 3, 2]);
        case 'zx2zy'
            img = permute(img,[2, 1, 3]);
    end
end
end

function handles = convertZ2T(handles)
% convert Z to T 
wb = waitbar(0,sprintf('Transposing the image\nPlease wait...'),'Name','Transpose dataset [Z->T]','WindowStyle','modal');
options.blockModeSwitch = 0;    % overwrite blockmode switch
img = handles.Img{handles.Id}.I.getData4D('image', 4, 0, options);   % get dataset (image)
img = permute(img,[1, 2, 3, 5, 4]);
handles.Img{handles.Id}.I.setData4D('image', img, 4, 0, options);   % get dataset (image)
% transpose other layers
if strcmp(handles.Img{handles.Id}.I.model_type, 'uint6') && strcmp(handles.preferences.disableSelection, 'no')
    waitbar(0.5, wb, sprintf('Transposing other layers\nPlease wait...'));
    img = handles.Img{handles.Id}.I.model;   % get dataset (image)
    handles.Img{handles.Id}.I.model = zeros([size(img, 1), size(img, 2), size(img, 4), size(img, 3)], 'uint8');
    img = permute(img,[1, 2, 4, 3]);
    handles.Img{handles.Id}.I.setData4D('everything', img, 4, 0, options);   % get dataset (image)
elseif strcmp(handles.preferences.disableSelection, 'no')
    waitbar(0.25, wb, sprintf('Transposing the selection layer\nPlease wait...'));
    img = handles.Img{handles.Id}.I.selection;   % get dataset (image)
    handles.Img{handles.Id}.I.selection = zeros([size(img, 1), size(img, 2), size(img, 4), size(img, 3)], 'uint8');
    img = permute(img,[1, 2, 4, 3]);
    handles.Img{handles.Id}.I.setData4D('selection', img, 4, 0, options);   % get dataset (image)
    
    if handles.Img{handles.Id}.I.maskExist
        waitbar(0.5, wb, sprintf('Transposing the mask layer\nPlease wait...'));
        img = handles.Img{handles.Id}.I.maskImg;   % get dataset (image)
        handles.Img{handles.Id}.I.maskImg = zeros([size(img, 1), size(img, 2), size(img, 4), size(img, 3)], 'uint8');
        img = permute(img,[1, 2, 4, 3]);
        handles.Img{handles.Id}.I.setData4D('mask', img, 4, 0, options);   % get dataset (image)
    end
    
    if handles.Img{handles.Id}.I.modelExist
        waitbar(0.75, wb, sprintf('Transposing the model layer\nPlease wait...'));
        img = handles.Img{handles.Id}.I.model;   % get dataset (image)
        handles.Img{handles.Id}.I.model = zeros([size(img, 1), size(img, 2), size(img, 4), size(img, 3)], 'uint8');
        img = permute(img,[1, 2, 4, 3]);
        handles.Img{handles.Id}.I.setData4D('model', img, 4, 0, options);   % get dataset (image)
    end
end
waitbar(1, wb, sprintf('Finishing...'));
clear img;
delete(wb);

end