function handles = ib_segmentation_SmartWatershed(modifier, handles)
% handles = ib_segmentation_SmartWatershed(modifier, handles)
% Do segmentation using the smart watershed. This function is a stripped
% version of the Watershed segmentation tool available from
% @em Menu->Tools->Watershed segmentation.
%
% Parameters:
% modifier: a string with a key modifier:
% - '' - empty, no modifier, do watershed for the current slice only or for
% the whole volume, when the 3D checkbox (Selection panel) is checked.
% - 'shift', do for all slices in the 2D mode.
% handles: a handles structure of im_browser
%
% Return values:
% handles: a handles structure of im_browser

%| @b Examples:
% @code handles = ib_segmentation_SmartWatershed(handles);  // do smart watershed @endcode
% @attention @b sensitive to the @code imageData.blockModeSwitch @endcode
% @attention @b sensitive to the shown ROI

% Copyright (C) 10.10.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% most of the following code is adapted from ib_watershedGui.m
col_channel = get(handles.ColChannelCombo, 'value')-1;
if col_channel == 0
    errordlg('Please select color channel to use in the Color channel combobox of the Selection panel and try again','Select color channel!');
    return;
end

bgColor = get(handles.segmWatershedSegmBtn, 'backgroundcolor');
set(handles.segmWatershedSegmBtn, 'backgroundcolor', 'r');
drawnow;
wb = waitbar(0, sprintf('Smart watershed...\nPlease wait...'), 'Name', 'Smart watershed');
bgMaterialId = get(handles.segmWatershedBgPopup, 'value');    % index of the background label
seedMaterialId = get(handles.segmWatershedSignalPopup, 'value');    % index of the signal label 
noMaterials = numel(get(handles.segmWatershedBgPopup, 'string'));    % number of materials in the model
invertImage = get(handles.segmWatershedSignalTypePopup, 'value');    % if == 1 image should be inverted, black-on-white

% define type of the mode to use
startSlice = handles.Img{handles.Id}.I.getCurrentSliceNumber();
endSlice = startSlice;
if strcmp(modifier, 'shift')
    startSlice = 1;
    [~,~,~,endSlice] = handles.Img{handles.Id}.I.getDatasetDimensions('image', 4);
    
end

if get(handles.actions3dCheck, 'value') == 1    % do watershed in 3D
    ib_do_backup(handles, 'mask', 1);
    img = ib_getDataset('image', handles, 4, col_channel);   % get dataset
    seedImg = ib_getDataset('model', handles, 4, NaN);   % get seeds
    W = cell([numel(img) 1]);
    for roiId = 1:numel(img)
        if invertImage == 1
            waitbar(.1, wb, sprintf('Inverting the image\nPlease wait...'));
            img{roiId} = imcomplement(squeeze(img{roiId}));
        else
            img{roiId} = squeeze(img{roiId});
        end
        
        if noMaterials > 2  % when more than 2 materials present keep only background and color
            seedImg{roiId}(seedImg{roiId}~=seedMaterialId & seedImg{roiId}~=bgMaterialId) = 0;
        end
        
        % modify the image so that the background pixels and the extended
        % maxima pixels are forced to be the only local minima in the image.
        waitbar(.2, wb, sprintf('Imposing minima\nPlease wait...'));
        W{roiId} = imimposemin(img{roiId}, seedImg{roiId});
        waitbar(.3, wb, sprintf('Computing the watershed\nPlease wait...'));
        W{roiId} = watershed(W{roiId});
        waitbar(.7, wb, sprintf('Removing background\nPlease wait...'));
        bgIndex = unique(W{roiId}(seedImg{roiId}==bgMaterialId));   % indeces of the background in the watershed
        W{roiId}(ismember(W{roiId}, bgIndex)) = 0; % make background 0
        W{roiId}(W{roiId}>1) = 1; % make objects
        waitbar(.9, wb, sprintf('Filling gaps between objects\nPlease wait...'));
        % fill the gaps between the objects
        se = ones([3 3 3]);
        W{roiId} = imdilate(W{roiId}, se);
        W{roiId} = imerode(W{roiId}, se);
    end
    ib_setDataset('mask', W, handles, 4);   % set mask
else    % do watershed in 2D
    if startSlice==endSlice
        ib_do_backup(handles, 'mask', 0);
    else
        ib_do_backup(handles, 'mask', 1);
    end
    
    for sliceId = startSlice:endSlice
        img = ib_getSlice('image', handles, sliceId, NaN, col_channel);   % get slice
        seedImg = ib_getSlice('model', handles, sliceId);   % get slice
        W = cell([numel(img) 1]);
        for roiId=1:numel(img)
            if max(max(seedImg{roiId})) < 1; W{roiId} = zeros(size(seedImg{roiId}),'uint8'); continue; end;
            
            if invertImage == 1
                img{roiId} = imcomplement(squeeze(img{roiId}));
            end
            
            if noMaterials > 2  % when more than 2 materials present keep only background and color
                seedImg{roiId}(seedImg{roiId}~=seedMaterialId & seedImg{roiId}~=bgMaterialId) = 0;
            end
           
            % modify the image so that the background pixels and the extended
            % maxima pixels are forced to be the only local minima in the image.
            W{roiId} = imimposemin(img{roiId}, seedImg{roiId});
            
            W{roiId} = watershed(W{roiId});
            
            bgIndex = unique(W{roiId}(seedImg{roiId}==bgMaterialId));   % indeces of the background in the watershed
            W{roiId}(ismember(W{roiId}, bgIndex)) = 0; % make background 0
            W{roiId}(W{roiId}>1) = 1; % make objects

            % fill the gaps between the objects
            se = strel('rectangle', [3 3]);
            W{roiId} = imdilate(W{roiId}, se);
            W{roiId} = imerode(W{roiId}, se);
        end
        ib_setSlice('mask', W, handles, sliceId);   % get slice
        waitbar((sliceId-startSlice)/(endSlice-startSlice));
    end
end


set(handles.maskShowCheck, 'value', 1);     % switch on show mask
waitbar(1, wb);
set(handles.segmWatershedSegmBtn, 'backgroundcolor', bgColor);
delete(wb);

guidata(handles.im_browser, handles);
handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
set(handles.im_browser, 'windowbuttonmotionfcn' , {@im_browser_winMouseMotionFcn, handles});
set(handles.im_browser, 'windowbuttonupfcn', {@im_browser_WindowButtonUpFcn, handles});
