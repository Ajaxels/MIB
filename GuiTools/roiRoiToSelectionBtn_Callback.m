% --- Executes on button press in roiRoiToSelectionBtn.
function roiRoiToSelectionBtn_Callback(hObject, eventdata, handles)
% function roiRoiToSelectionBtn_Callback(hObject, eventdata, handles)
% a callback from the ROI to Selection button in the ROI panel to copy areas under the shown ROIs to the Selection layer
%
% Parameters:
% hObject:    handle to roiRoiToSelectionBtn (see GCBO)
% eventdata:  reserved - to be defined in a future version of MATLAB
% handles:    structure with handles and user data (see GUIDATA)

% Copyright (C) 31.05.2016, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
%

% get index of the ROI
roiList = get(handles.roiList, 'string');
roiNo = get(handles.roiList, 'value');
roiNo = handles.Img{handles.Id}.I.hROI.findIndexByLabel(roiList{roiNo});
if isempty(roiNo)
    warndlg(sprintf('!!! Warning !!!\n\nNo ROIs were detected!\nAdd a new ROI area and try again.'),'ROI is missing');
    return;
end
backupOptions.blockModeSwitch = 0;
[Height, Width, ~, Depth] = handles.Img{handles.Id}.I.getDatasetDimensions('image', NaN, NaN, backupOptions);

index = 1;
for roiId = roiNo
    if index == 1
        selected_mask = handles.Img{handles.Id}.I.hROI.returnMask(roiId, Height, Width, NaN, backupOptions.blockModeSwitch);
    else
        selected_mask = bitor(selected_mask, handles.Img{handles.Id}.I.hROI.returnMask(roiId, Height, Width, NaN, backupOptions.blockModeSwitch));
    end
    index = index + 1;
end

% calculating bounding box for the backup
CC = regionprops(selected_mask,'BoundingBox');
bb = CC.BoundingBox;

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
selected_mask = selected_mask(backupOptions.y(1):backupOptions.y(2), backupOptions.x(1):backupOptions.x(2));

% propagate in 3D
if get(handles.actions3dCheck,'Value')
    ib_do_backup(handles, 'selection', 1, backupOptions);
    currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, NaN, NaN, backupOptions);
    selarea = zeros(size(currSelection),'uint8');
    for layer_id = 1:size(selarea, 3)
        selarea(:,:,layer_id) = selected_mask;
    end
    
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value')
        selcontour = get(handles.segmSelList,'Value') - 2;  % get selected contour
        currModel = handles.Img{handles.Id}.I.getData3D('model', NaN, NaN, selcontour, backupOptions);
        selarea = bitand(selarea, currModel);
    end
    
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist   % do selection only in the masked areas
        currModel = handles.Img{handles.Id}.I.getData3D('mask', NaN, 4, NaN, backupOptions);
        selarea = bitand(selarea, currModel);
    end
    handles.Img{handles.Id}.I.setData3D('selection', bitor(selarea, currSelection), NaN, NaN, NaN, backupOptions);
else
    ib_do_backup(handles, 'selection', 0);
    currSelection = handles.Img{handles.Id}.I.getData2D('selection', NaN, NaN, NaN, NaN, backupOptions);
    
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value')
        selcontour = get(handles.segmSelList,'Value') - 2;  % get selected contour
        currModel = handles.Img{handles.Id}.I.getData2D('model', NaN, NaN, selcontour, NaN, backupOptions);
        selected_mask = bitand(selected_mask, currModel);
    end
    
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist
        currModel = handles.Img{handles.Id}.I.getData2D('mask', NaN, NaN, NaN, NaN, backupOptions);
        selected_mask = bitand(selected_mask, currModel);
    end
    handles.Img{handles.Id}.I.setData2D('selection', bitor(currSelection, selected_mask), NaN, NaN, NaN, NaN, backupOptions);
end

handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end