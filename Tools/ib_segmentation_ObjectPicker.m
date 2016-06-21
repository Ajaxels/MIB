function handles = ib_segmentation_ObjectPicker(yxzCoordinate, modifier, handles)
% handles = ib_segmentation_ObjectPicker(yxzCoordinate, modifier, handles)
% Do a the targeted selection from Mask/Models layers
%
% Parameters:
% yxzCoordinate: a vector with [y,x,z] coodrinates of the starting point,
% for 2d case it is enough to have only [y, x].
% modifier: a string, to specify what to do with the generated selection
% - @em empty - makes new selection
% - @em ''control'' - removes selection from the existing one
% handles: a handles structure of im_browser
%
% Return values:
% handles: a handles structure of im_browser

%| @b Examples:
% @code yxzCoordinate = [50, 75]; @endcode
% @code handles = ib_segmentation_ObjectPicker(yxzCoordinate, modifier, handles);  // start the Object Picker selection tool from position [y,x]=50,75 @endcode

% Copyright (C) 2012 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 14.05.2014, IB, taken to a separate function
% 04.09.2015, IB, updated to imageData.getData3D method
% 23.03.2016, IB, improved picking of 3D objects
% 29.03.2016, IB, optimized backup

tic
switch3d = get(handles.actions3dCheck,'Value');     % use tool in 3d
options.blockModeSwitch = handles.Img{handles.Id}.I.blockModeSwitch;

if get(handles.segmMaskClickModelCheck, 'value')
    type = 'model';
    if handles.Img{handles.Id}.I.modelExist == 0
        msg = [{'No model information found!'}
            {'Please create a model first...'}
            ];
        msgbox(msg,'Error!','error','modal');
        return;
    end
    colchannel = get(handles.segmSelList,'Value') - 2;
else
    type = 'mask';
    if handles.Img{handles.Id}.I.maskExist == 0
        msg = [{'No mask (black/white) information found!'}
            {'Filter the data first with available filters'}
            ];
        msgbox(msg,'Error!','error','modal');
        return;
    end
    colchannel = 0;
end

if switch3d
    h = yxzCoordinate(1);
    w = yxzCoordinate(2);
    z = yxzCoordinate(3);
else
    yCrop = yxzCoordinate(1);
    xCrop = yxzCoordinate(2);
end

switch get(handles.filterSelectionPopup,'Value')
    case 1 % selection with mouse button
        if switch3d
            options.blockModeSwitch = 0;
            
            permuteSwitch = 4;  % get dataset in the XY orientation
            obj_id = handles.Img{handles.Id}.I.maskStat.L(h,w,z);
            if obj_id == 0; return; end;
            
            % define subset of data for selection
            bb = handles.Img{handles.Id}.I.maskStat.bb(obj_id).BoundingBox;
            options.y = [ceil(bb(2)) ceil(bb(2))+floor(bb(5))-1];
            options.x = [ceil(bb(1)) ceil(bb(1))+floor(bb(4))-1];
            options.z = [ceil(bb(3)) ceil(bb(3))+floor(bb(6))-1];
            
            ib_do_backup(handles, 'selection', 1, options);

            % get current selection
            currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, permuteSwitch, NaN, options);
            objSelection = zeros(size(currSelection), 'uint8');
            objSelection(handles.Img{handles.Id}.I.maskStat.L(options.y(1):options.y(2), options.x(1):options.x(2),options.z(1):options.z(2))==obj_id) = 1;
            
            % limit to the selected material of the model
            if get(handles.segmSelectedOnlyCheck,'Value') && strcmp(type, 'mask')
                selcontour = get(handles.segmSelList,'Value') - 2;  % get selected contour
                datasetImage = handles.Img{handles.Id}.I.getData3D('model', NaN, permuteSwitch, selcontour, options);
                objSelection(datasetImage~=1) = 0;
            end
            
            % limit selection to the masked area
            if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist && strcmp(type, 'model')
                datasetImage = handles.Img{handles.Id}.I.getData3D('mask', NaN, permuteSwitch, NaN, options);
                objSelection(datasetImage~=1) = 0;
            end
            
            if isempty(modifier)
                currSelection(objSelection==1) = 1;
                handles.Img{handles.Id}.I.setData3D('selection', currSelection, NaN, permuteSwitch, NaN, options);
            elseif strcmp(modifier, 'control')  % subtracts selections
                currSelection(objSelection==1) = 0;
                handles.Img{handles.Id}.I.setData3D('selection', currSelection, NaN, permuteSwitch, NaN, options);
            end
            return;
        else
            ib_do_backup(handles, 'selection', 0);
            if strcmp(type,'model') && get(handles.segmSelectedOnlyCheck,'value')  % model with selected only switch
                mask = handles.Img{handles.Id}.I.getCurrentSlice(type, colchannel);
            elseif strcmp(type,'model')
                mask = handles.Img{handles.Id}.I.getCurrentSlice(type);     % model
                colchannel = mask(yCrop, xCrop);
                if colchannel == 0; return; end;
                %mask = bitand(mask, colchannel);
                mask = bitand(mask, 63)==colchannel;
            else
                mask = handles.Img{handles.Id}.I.getCurrentSlice(type); % mask
            end
            selarea = uint8(bwselect(mask, xCrop, yCrop, 4));
        end
    case 2 % selection with lasso tool
        set(handles.im_browser,'Pointer','cross');
        set(handles.im_browser, 'windowbuttondownfcn', '');
        h = imfreehand(handles.imageAxes);
        selected_mask = uint8(h.createMask);
        delete(h);
        set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
        set(handles.im_browser,'Pointer','crosshair');
        currMask = handles.Img{handles.Id}.I.getSliceToShow(type, NaN, NaN, colchannel);
        selected_mask = imresize(selected_mask, [size(currMask,1) size(currMask,2)],'method','nearest');
        
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
        
        options.blockModeSwitch = 1;    % to get only the shown part of the dataset
        if switch3d
            ib_do_backup(handles, 'selection', 1, backupOptions);
            permuteSwitch = NaN;    % get dataset in the shown orientation
            maskDataset = handles.Img{handles.Id}.I.getData3D(type, NaN, permuteSwitch, colchannel, options);
            selarea = zeros(size(maskDataset),'uint8');
            for layer_id = 1:size(selarea, 3)
                selarea(:,:,layer_id) = bitand(selected_mask, maskDataset(:,:,layer_id));
            end
        else
            ib_do_backup(handles, 'selection', 0);
            %selarea = selected_mask & currMask;
            selarea = bitand(selected_mask, currMask);
        end;
    case 3 % selection with rectangle tool
        set(handles.im_browser,'Pointer','cross');
        set(handles.im_browser, 'windowbuttondownfcn', '');
        h =  imrect(handles.imageAxes);
        selected_mask = uint8(h.createMask);
        delete(h);
        set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
        set(handles.im_browser,'Pointer','crosshair');
        currMask = handles.Img{handles.Id}.I.getSliceToShow(type, NaN, NaN, colchannel);
        selected_mask = imresize(selected_mask, [size(currMask,1) size(currMask,2)],'method','nearest');
        
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
        if switch3d
            ib_do_backup(handles, 'selection', 1, backupOptions);
            permuteSwitch = NaN;    % get dataset in the shown orientation
            maskDataset = handles.Img{handles.Id}.I.getData3D(type, NaN, permuteSwitch, colchannel, options);
            selarea = zeros(size(maskDataset),'uint8');
            for layer_id = 1:size(selarea, 3)
                selarea(:,:,layer_id) = bitand(selected_mask,  maskDataset(:,:,layer_id));
            end
        else
            ib_do_backup(handles, 'selection', 0);
            selarea = bitand(selected_mask, currMask);
        end;
    case 4 % selection with ellipse tool
        set(handles.im_browser,'Pointer','cross');
        set(handles.im_browser, 'windowbuttondownfcn', '');
        h = imellipse(handles.imageAxes);
        selected_mask = uint8(h.createMask);
        delete(h);
        set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
        set(handles.im_browser,'Pointer','crosshair');
        currMask = handles.Img{handles.Id}.I.getSliceToShow(type, NaN, NaN, colchannel);
        selected_mask = imresize(selected_mask, [size(currMask,1) size(currMask,2)],'method','nearest');
        
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
        if switch3d
            ib_do_backup(handles, 'selection', 1, backupOptions);
            permuteSwitch = NaN;
            maskDataset = handles.Img{handles.Id}.I.getData3D(type, NaN, permuteSwitch, colchannel, options);
            selarea = zeros(size(maskDataset),'uint8');
            for layer_id = 1:size(selarea, 3)
                selarea(:,:,layer_id) = bitand(selected_mask, maskDataset(:,:,layer_id));
            end
        else
            ib_do_backup(handles, 'selection', 0);
            selarea = bitand(selected_mask, currMask);
        end;
    case 5 % selection with polyline tool
        set(handles.im_browser,'Pointer','cross');
        set(handles.im_browser, 'windowbuttondownfcn', '');
        h =  impoly(handles.imageAxes);
        selected_mask = uint8(h.createMask);
        delete(h);
        set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
        set(handles.im_browser,'Pointer','crosshair');
        currMask = handles.Img{handles.Id}.I.getSliceToShow(type, NaN, NaN, colchannel);
        selected_mask = imresize(selected_mask, [size(currMask,1) size(currMask,2)],'method','nearest');
        
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
        if switch3d
            ib_do_backup(handles, 'selection', 1, backupOptions);
            permuteSwitch = NaN;
            maskDataset = handles.Img{handles.Id}.I.getData3D(type, NaN, permuteSwitch, colchannel, options);
            selarea = zeros(size(maskDataset),'uint8');
            for layer_id = 1:size(selarea, 3)
                selarea(:,:,layer_id) = bitand(selected_mask, maskDataset(:,:,layer_id));
            end
        else
            ib_do_backup(handles, 'selection', 0);
            selarea = bitand(selected_mask, currMask);
        end;
    case 6 % selection with brush tool
        ib_do_backup(handles, 'selection', 0);
        radius = str2double(get(handles.maskBrushSizeEdit,'String'));
        handles.Img{handles.Id}.I.brush_prev_xy = NaN;
        if isempty(modifier) || strcmp(modifier, 'shift')    % combines selections
            brush_switch = 'add';
        else   % subtracts selections
            brush_switch = 'subtract';
        end
        %-% handles.Img{handles.Id}.I.brush_selection = logical(zeros([size(handles.Img{handles.Id}.I.Ishown,1) size(handles.Img{handles.Id}.I.Ishown,2)], 'uint8'));
        selection_layer = 'mask';   % select only the mask layer with the brush
        handles.Img{handles.Id}.I.brush_selection = {};
        handles.Img{handles.Id}.I.brush_selection{1} = logical(zeros([size(handles.Img{handles.Id}.I.Ishown,1) size(handles.Img{handles.Id}.I.Ishown,2)], 'uint8')); %#ok<LOGL>
        
        % generate the structural element for the brush
        radius = radius - 1;
        if radius < 1; radius = 0.5; end;
        se_size = round(radius/handles.Img{handles.Id}.I.magFactor);
        structElement = zeros(se_size*2+1,se_size*2+1);
        [xx,yy] = meshgrid(-se_size:se_size,-se_size:se_size);
        ball = sqrt((xx/se_size).^2+(yy/se_size).^2);
        structElement(ball<=1) = 1;
        
        currMask = handles.Img{handles.Id}.I.getSliceToShow(type, NaN, NaN, colchannel);
        currMask = imresize(currMask, [size(handles.Img{handles.Id}.I.Ishown,1) size(handles.Img{handles.Id}.I.Ishown,2)],'method','nearest');
        
        handles = ib_updateCursor(handles, 'solid');   % set the brush cursor in the drawing mode
        set(handles.im_browser, 'windowbuttondownfcn', []);
        set(handles.im_browser, 'pointer', 'custom', 'PointerShapeCData',nan(16),......
            'windowbuttonmotionfcn' , {@im_browser_WindowBrushMotionFcn, handles, selection_layer, structElement, currMask});
        set(handles.im_browser, 'windowbuttonupfcn', {@im_browser_WindowButtonUpFcn, handles, brush_switch});
        return;
    case 7 % Select mask within current Selection layer
        if switch3d==1 | strcmp(modifier, 'shift')==1  %#ok<OR2>
            ib_do_backup(handles, 'selection', 1);
            modifier = 'new';
            permuteSwitch = 4;
            mask = handles.Img{handles.Id}.I.getData3D(type, NaN, permuteSwitch, colchannel, options);
            sel = handles.Img{handles.Id}.I.getData3D('selection', NaN, permuteSwitch, colchannel, options);
            selarea = bitand(mask,  sel);
        else
            ib_do_backup(handles, 'selection', 0);
            currMask = handles.Img{handles.Id}.I.getSlice(type, NaN, NaN, colchannel);
            currSelection = handles.Img{handles.Id}.I.getSlice('selection');
            %selarea = uint8(currMask & currSelection);
            selarea = bitand(currMask,  currSelection);
            modifier = 'new';
        end
end

selcontour = get(handles.segmSelList,'Value') - 2;  % get selected contour
if switch3d
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value') && strcmp(type, 'mask')
        datasetImage = handles.Img{handles.Id}.I.getData3D('model', NaN, permuteSwitch, selcontour, options);
        selarea(datasetImage~=1) = 0;
    end
    
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist && strcmp(type, 'model')
        datasetImage = handles.Img{handles.Id}.I.getData3D('mask', NaN, permuteSwitch, NaN, options);
        selarea(datasetImage~=1) = 0;
    end
    
    if isempty(modifier)
        currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, permuteSwitch, NaN, options);
        handles.Img{handles.Id}.I.setData3D('selection', bitor(currSelection, selarea), NaN, permuteSwitch, NaN, options);
    elseif strcmp(modifier, 'control')  % subtracts selections
        currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, permuteSwitch, NaN, options);
        currSelection(selarea==1) = 0;
        handles.Img{handles.Id}.I.setData3D('selection', currSelection, NaN, permuteSwitch, NaN, options);
    elseif strcmp(modifier, 'new')  % tweak for case 7 % Select mask within current Selection layer
        handles.Img{handles.Id}.I.setData3D('selection', selarea, NaN, permuteSwitch, NaN, options);
    end
else
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value') && strcmp(type, 'mask')
        if options.blockModeSwitch
            currModel = handles.Img{handles.Id}.I.getSliceToShow('model', NaN, NaN, selcontour);
        else
            currModel = handles.Img{handles.Id}.I.getFullSlice('model', NaN, NaN, selcontour);
        end
        selarea = bitand(selarea, currModel);
    end
    
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist && strcmp(type, 'model')
        if options.blockModeSwitch
            currModel = handles.Img{handles.Id}.I.getSliceToShow('mask');
        else
            currModel = handles.Img{handles.Id}.I.getFullSlice('mask');
        end
        selarea = bitand(selarea, currModel);
    end
    
    if options.blockModeSwitch
        if isempty(modifier) % combines selections
            currSelection = handles.Img{handles.Id}.I.getSliceToShow('selection');
            handles.Img{handles.Id}.I.setSliceToShow('selection', bitor(currSelection, selarea));
        elseif strcmp(modifier, 'control')  % subtracts selections
            currSelection = handles.Img{handles.Id}.I.getSliceToShow('selection');
            currSelection(selarea==1) = 0;
            handles.Img{handles.Id}.I.setSliceToShow('selection', currSelection);
        elseif strcmp(modifier, 'new')  % tweak for case 7 % Select mask within current Selection layer
            handles.Img{handles.Id}.I.setSliceToShow('selection', selarea);
        end
    else
        if isempty(modifier) % combines selections
            currSelection = handles.Img{handles.Id}.I.getFullSlice('selection');
            handles.Img{handles.Id}.I.setFullSlice('selection', bitor(currSelection, selarea));
        elseif strcmp(modifier, 'control')  % subtracts selections
            currSelection = handles.Img{handles.Id}.I.getFullSlice('selection');
            currSelection(selarea==1) = 0;
            handles.Img{handles.Id}.I.setFullSlice('selection', currSelection);
        elseif strcmp(modifier, 'new')  % tweak for case 7 % Select mask within current Selection layer
            handles.Img{handles.Id}.I.setFullSlice('selection', selarea);
        end
    end
end
