function handles = ib_segmentation_Lasso(modifier, handles)
% function handles = ib_segmentation_Lasso(modifier, handles)
% Do segmentation using the lasso tool
%
% Parameters:
% modifier: a string, to specify what to do with the generated selection
% - @em empty - makes new selection
% - @em ''control'' - removes selection from the existing one
% handles: a handles structure of im_browser
%
% Return values:
% handles: a handles structure of im_browser

%| @b Examples:
% @code handles = ib_segmentation_Lasso(modifier, handles);  // initialize the lasso tool @endcode

% Copyright (C) 14.05.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 29.03.2016, IB, optimized backup
% 25.10.2016, IB, updated for segmentation table

switch3d = get(handles.actions3dCheck,'Value');     % use tool in 3d
userData = get(handles.segmTable,'UserData');
selcontour = userData.prevMaterial - 2;  % get selected contour
list = get(handles.filterSelectionPopup, 'string');
type = list{get(handles.filterSelectionPopup, 'value')};    % Lasso or Rectangle

set(handles.im_browser,'Pointer','cross');
set(handles.im_browser, 'windowbuttondownfcn', '');

switch type
    case 'Lasso'
        h = imfreehand(handles.imageAxes);
    case 'Rectangle'
        h = imrect(handles.imageAxes); 
    case 'Ellipse'
        h = imellipse(handles.imageAxes);
    case 'Polyline'
        h =  impoly(handles.imageAxes);
end

try
    selected_mask = uint8(h.createMask);
catch err
    return;
end
delete(h);
set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});

set(handles.im_browser,'Pointer','crosshair');
currSelection = handles.Img{handles.Id}.I.getSliceToShow('selection');
selected_mask = imresize(selected_mask, [size(currSelection,1) size(currSelection,2)],'method','nearest');

% calculating bounding box for the backup
CC = regionprops(selected_mask,'BoundingBox');
bb = CC.BoundingBox;
bb(1) = bb(1) + max([1 ceil(handles.Img{handles.Id}.I.axesX(1))])-1;
bb(2) = bb(2) + max([1 ceil(handles.Img{handles.Id}.I.axesY(1))])-1;

if handles.Img{handles.Id}.I.orientation == 4
    backupOptions.y = [ceil(bb(2)) ceil(bb(2))+floor(bb(4))-1];
    backupOptions.x = [ceil(bb(1)) ceil(bb(1))+floor(bb(3))-1];
elseif handles.Img{handles.Id}.I.orientation == 1
    backupOptions.x = [ceil(bb(2)) ceil(bb(2))+floor(bb(4))-1];
    backupOptions.z = [ceil(bb(1)) ceil(bb(1))+floor(bb(3))-1];
elseif handles.Img{handles.Id}.I.orientation == 2
    backupOptions.y = [ceil(bb(2)) ceil(bb(2))+floor(bb(4))-1];
    backupOptions.z = [ceil(bb(1)) ceil(bb(1))+floor(bb(3))-1];
end

options.blockModeSwitch = 1;
if switch3d     % 3d case
    ib_do_backup(handles, 'selection', 1, backupOptions);
    orient = NaN;
    [localHeight, localWidth, localColor, localThick] = handles.Img{handles.Id}.I.getDatasetDimensions('selection', orient, NaN, options);
    selarea = zeros([localHeight localWidth localThick],'uint8');
    currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, NaN, NaN, options);
    for layer_id = 1:size(selarea, 3)
        selarea(:,:,layer_id) = selected_mask;
    end
    
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value')
        options.blockModeSwitch = 1;
        currModel = handles.Img{handles.Id}.I.getData3D('model', NaN, NaN, selcontour, options);
        selarea = bitand(selarea, currModel);
    end
    
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist   % do selection only in the masked areas
        currModel = handles.Img{handles.Id}.I.getData3D('mask', NaN, 4, NaN, options);
        selarea = bitand(selarea, currModel);
    end
    if isempty(modifier) || strcmp(modifier, 'shift')    % combines selections
        handles.Img{handles.Id}.I.setData3D('selection', bitor(selarea, currSelection), NaN, orient, NaN, options);
    elseif strcmp(modifier, 'control')  % subtracts selections
        currSelection(selarea==1) = 0;
        handles.Img{handles.Id}.I.setData3D('selection', currSelection, NaN, orient, NaN, options);
    end
else    % 2d case
    ib_do_backup(handles, 'selection', 0);
    selarea = selected_mask;
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value')
        currModel = handles.Img{handles.Id}.I.getSliceToShow('model', NaN, NaN, selcontour);
        selarea = bitand(selarea, currModel);
    end
    
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist   
        currModel = handles.Img{handles.Id}.I.getSliceToShow('mask');
        selarea = bitand(selarea, currModel);
    end
    
    if isempty(modifier) || strcmp(modifier, 'shift')    % combines selections
        handles.Img{handles.Id}.I.setSliceToShow('selection', bitor(currSelection, selarea));
    elseif strcmp(modifier, 'control')  % subtracts selections
        currSelection(selarea==1) = 0;
        handles.Img{handles.Id}.I.setSliceToShow('selection', currSelection);
    end
end;