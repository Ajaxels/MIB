function handles = ib_flipDataset(handles, mode)
% function handles = ib_flipDataset(handles, mode)
% Flip dataset horizontally, vertically or in the Z direction
% 
% Flip dataset and other layers in horizontal or vertical direction  
%
% Parameters:
% handles: handles structire of im_browser
% mode: -> a string that defines the flipping mode
%     - ''flipH'' -> horizontal flip
%     - ''flipV'' -> vertical flip
%     - ''flipZ'' -> flip Z direction
%     - ''flipT'' -> flip T direction
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
% 
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 06.02.2016, IB, updated for 4D datasets, added the 'flipT' mode

tic
if handles.Img{handles.Id}.I.no_stacks == 1; return; end;   % no z-flipping for single image

options.blockModeSwitch = 0;    % overwrite blockmode switch
wb = waitbar(0,sprintf('Flipping image\nPlease wait...'),'Name','Flip dataset','WindowStyle','modal');
if handles.Img{handles.Id}.I.time < 2; ib_do_backup(handles, 'image', 1); end;

if strcmp(mode, 'flipT')
    img = handles.Img{handles.Id}.I.getData4D('image', 4, 0, options);   % get dataset (image)
    index = 1;
    for t=handles.Img{handles.Id}.I.time:-1:1
        handles.Img{handles.Id}.I.setData3D('image', img(:,:,:,:,t), index, 4, 0, options);   % get dataset (image)
        waitbar(index/handles.Img{handles.Id}.I.time, wb);
        index = index + 1;
    end
    
    % flip other layers
    if strcmp(handles.Img{handles.Id}.I.model_type, 'uint6') && strcmp(handles.preferences.disableSelection, 'no')
        waitbar(0.5, wb, sprintf('Flipping other layers\nPlease wait...'));
        img = handles.Img{handles.Id}.I.getData4D('everything', 4, 0, options);   % get dataset (image)
        index = 1;
        for t=handles.Img{handles.Id}.I.time:-1:1
            handles.Img{handles.Id}.I.setData3D('everything', img(:,:,:,t), index, 4, 0, options);   % get dataset (image)
            index = index + 1;
            waitbar(index/handles.Img{handles.Id}.I.time, wb);
        end
    elseif strcmp(handles.preferences.disableSelection, 'no')
        % flip selection layer
        waitbar(0.25, wb, sprintf('Flipping the selection layer\nPlease wait...'));
        img = handles.Img{handles.Id}.I.getData4D('selection', 4, 0, options);   % get dataset (image)
        index = 1;
        for t=handles.Img{handles.Id}.I.time:-1:1
            handles.Img{handles.Id}.I.setData3D('selection', img(:,:,:,t), index, 4, 0, options);   % get dataset (image)
            index = index + 1;
            waitbar(index/handles.Img{handles.Id}.I.time, wb);
        end
        
        % flip mask
        if handles.Img{handles.Id}.I.maskExist
            waitbar(0.5, wb, sprintf('Flipping the mask layer\nPlease wait...'));
            img = handles.Img{handles.Id}.I.getData4D('mask', 4, 0, options);   % get dataset (image)
            index = 1;
            for t=handles.Img{handles.Id}.I.time:-1:1
                handles.Img{handles.Id}.I.setData3D('mask', img(:,:,:,t), index, 4, 0, options);   % get dataset (image)
                index = index + 1;
                waitbar(index/handles.Img{handles.Id}.I.time, wb);
            end
        end
        
        % flip model
        if handles.Img{handles.Id}.I.modelExist
            waitbar(0.75, wb, sprintf('Flipping the model layer\nPlease wait...'));
            img = handles.Img{handles.Id}.I.getData4D('model', 4, 0, options);   % get dataset (image)
            index = 1;
            for t=handles.Img{handles.Id}.I.time:-1:1
                handles.Img{handles.Id}.I.setData3D('model', img(:,:,:,t), index, 4, 0, options);   % get dataset (image)
                index = index + 1;
                waitbar(index/handles.Img{handles.Id}.I.time, wb);
            end
        end
    end
    waitbar(1, wb, sprintf('Finishing...'));

    log_text = ['Flip: mode=' mode];
    handles.Img{handles.Id}.I.updateImgInfo(log_text);
    delete(wb);
    toc;
    return;
end

% flip image
for t=1:handles.Img{handles.Id}.I.time
    img = handles.Img{handles.Id}.I.getData3D('image', t, 4, 0, options);   % get dataset (image)
    if handles.matlabVersion < 8.2
        img = flipme(img, mode);
    else
        img = flipmeR2013b(img, mode);
    end
    handles.Img{handles.Id}.I.setData3D('image', img, t, 4, 0, options);   % set dataset (image) back
    waitbar(t/handles.Img{handles.Id}.I.time, wb);
end
clear img;

% flip other layers
if strcmp(handles.Img{handles.Id}.I.model_type, 'uint6') && strcmp(handles.preferences.disableSelection, 'no')
    waitbar(0.5, wb, sprintf('Flipping other layers\nPlease wait...'));
    if handles.Img{handles.Id}.I.time < 2; 
        ib_do_backup(handles, 'everything', 1);  % backup other layers
    end
    for t=1:handles.Img{handles.Id}.I.time
        img = handles.Img{handles.Id}.I.getData3D('everything', t, 4, NaN, options);   % get dataset (image)
        if handles.matlabVersion < 8.2
            img = flipme(img, mode);
        else
            img = flipmeR2013b(img, mode);
        end
        handles.Img{handles.Id}.I.setData3D('everything', img, t, 4, NaN, options);   % set dataset (image) back
        waitbar(t/handles.Img{handles.Id}.I.time, wb);
    end
elseif strcmp(handles.preferences.disableSelection, 'no')
    % flip selection layer
    waitbar(0.25, wb, sprintf('Flipping the selection layer\nPlease wait...'));
    for t=1:handles.Img{handles.Id}.I.time
        img = handles.Img{handles.Id}.I.getData3D('selection', t, 4, NaN, options);   % get dataset (image)
        if handles.matlabVersion < 8.2
            img = flipme(img, mode);
        else
            img = flipmeR2013b(img, mode);
        end
        handles.Img{handles.Id}.I.setData3D('selection', img, t, 4, NaN, options);   % set dataset (image) back
        waitbar(t/handles.Img{handles.Id}.I.time, wb);
    end
    
    % flip mask
    if handles.Img{handles.Id}.I.maskExist
        waitbar(0.5, wb, sprintf('Flipping the mask layer\nPlease wait...'));
        for t=1:handles.Img{handles.Id}.I.time
            img = handles.Img{handles.Id}.I.getData3D('mask', t, 4, NaN, options);   % get dataset (image)
            if handles.matlabVersion < 8.2
                img = flipme(img, mode);
            else
                img = flipmeR2013b(img, mode);
            end
            handles.Img{handles.Id}.I.setData3D('mask', img, t, 4, NaN, options);   % set dataset (image) back
            waitbar(t/handles.Img{handles.Id}.I.time, wb);
        end
    end
    
    % flip model
    if handles.Img{handles.Id}.I.modelExist
        waitbar(0.75, wb, sprintf('Flipping the model layer\nPlease wait...'));
        for t=1:handles.Img{handles.Id}.I.time
            img = handles.Img{handles.Id}.I.getData3D('model', t, 4, NaN, options);   % get dataset (image)
            if handles.matlabVersion < 8.2
                img = flipme(img, mode);
            else
                img = flipmeR2013b(img, mode);
            end
            handles.Img{handles.Id}.I.setData3D('model', img, t, 4, NaN, options);   % set dataset (image) back
            waitbar(t/handles.Img{handles.Id}.I.time, wb);
        end
    end
end
waitbar(1, wb, sprintf('Finishing...'));

log_text = ['Flip: mode=' mode];
handles.Img{handles.Id}.I.updateImgInfo(log_text);

delete(wb);
toc
end

function img = flipme(img, mode)
% flip function
if strcmp(mode, 'flipZ')
    img = flipdim(img, ndims(img));
elseif strcmp(mode, 'flipH')
    img = flipdim(img, 2);
elseif strcmp(mode, 'flipV')
    img = flipdim(img, 1);
end
end

function img = flipmeR2013b(img, mode)
% flip function, for newer releases
if strcmp(mode, 'flipZ')
    img = flip(img, ndims(img));
elseif strcmp(mode, 'flipH')
    img = flip(img, 2);
elseif strcmp(mode, 'flipV')
    img = flip(img, 1);
end
end