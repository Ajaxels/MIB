function im_browser_WindowButtonDownFcn(hObject, eventdata, handles)
% function im_browser_WindowButtonDownFcn(hObject, eventdata, handles)
% this is callback for the press of a mouse button
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles of im_browser.m

% Copyright (C) 20.06.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

handles = guidata(handles.im_browser);  % update handles structure
val = get(handles.seltypePopup,'Value'); % get a selected instrument: filter, magic wand, brush etc
txt = get(handles.seltypePopup,'String');
tool = cell2mat(txt(val));
tool = strtrim(tool);   % remove ending space
switch3d = get(handles.actions3dCheck,'Value');     % use filters in 3d
xy = get(handles.imageAxes, 'currentpoint');
seltype = get(handles.im_browser, 'selectiontype'); 
modifier = get(handles.im_browser,'currentmodifier');
% swap left and right mouse buttons check
if strcmp(get(handles.toolbarSwapMouse,'State'),'on')
    if strcmp(seltype,'normal')
        seltype = 'extend';
    elseif strcmp(seltype,'alt') && isempty(modifier)
        seltype = 'normal';
    end
end

position2 = get(handles.im_browser,'currentpoint');
x2 = round(position2(1,1));
y2 = round(position2(1,2));
separatingPanelPos = get(handles.separatingPanel, 'position');
if x2>separatingPanelPos(1) && x2<separatingPanelPos(1)+separatingPanelPos(3) && y2>separatingPanelPos(2) && y2<separatingPanelPos(2)+separatingPanelPos(4) % mouse pointer within the current axes
    set(handles.im_browser, 'WindowButtonUpFcn', {@im_browser_PanelShiftBtnUpFcn, handles});
    set(handles.im_browser, 'WindowButtonMotionFcn',[]);
    set(handles.im_browser,'Pointer','left');
    return;
end

if strcmp(seltype,'normal') %& strcmp(modifier,'alt')
    %%     % Start the pan mode
    set(handles.im_browser, 'WindowKeyPressFcn' , []);  % turn off callback for the keys during the panning
    
    % check for the mouse inside the image axes
    xlim = get(handles.imageAxes,'xlim');
    ylim = get(handles.imageAxes,'ylim');
    if xy(1,1) < xlim(1) || xy(1,2) < ylim(1) || xy(1,1) > xlim(2) || xy(1,2) > ylim(2); return; end;
    
    if ishandle(handles.cursor)
        set(handles.cursor, 'Visible', 'off');
    end
    
    % get full image:
    if strcmp(get(handles.toolbarFastPanMode, 'state'), 'off')
        rgbOptions.mode = 'full';
        imgRGB = handles.Img{handles.Id}.I.getRGBimage(handles, rgbOptions);
        set(handles.Img{handles.Id}.I.imh,'CData',[],'CData', imgRGB);
        
        % delete shown measurements
        lineObj = findobj(handles.imageAxes,'tag','measurements','-or','tag','roi');
        if ~isempty(lineObj); delete(lineObj); end;     % keep it within if, because it is faster
        % show measurements
        handles = handles.Img{handles.Id}.I.hMeasure.addMeasurementsToPlot(handles, 'full');
        % show ROIs
        handles = handles.Img{handles.Id}.I.hROI.addROIsToPlot(handles, 'full');
        
        if handles.Img{handles.Id}.I.magFactor < 1    % the image is not rescaled if magFactor less than 1
            %set(handles.imageAxes,'xlim',handles.Img{handles.Id}.I.axesX);
            %set(handles.imageAxes,'ylim',handles.Img{handles.Id}.I.axesY);
            set(handles.imageAxes,'xlim',handles.Img{handles.Id}.I.axesX);
            set(handles.imageAxes,'ylim',handles.Img{handles.Id}.I.axesY);
            % modify xy with respect to the magFactor and shifts of the axes
            xy2(1) = xy(1,1)*handles.Img{handles.Id}.I.magFactor+max([handles.Img{handles.Id}.I.axesX(1) 0]);
            xy2(2) = xy(1,2)*handles.Img{handles.Id}.I.magFactor+max([handles.Img{handles.Id}.I.axesY(1) 0]);
        else
            set(handles.imageAxes,'xlim',handles.Img{handles.Id}.I.axesX/handles.Img{handles.Id}.I.magFactor);
            set(handles.imageAxes,'ylim',handles.Img{handles.Id}.I.axesY/handles.Img{handles.Id}.I.magFactor);
            % modify xy with respect to the magFactor and shifts of the axes
            xy2(1) = xy(1,1)+max([handles.Img{handles.Id}.I.axesX(1)/handles.Img{handles.Id}.I.magFactor 0]);
            xy2(2) = xy(1,2)+max([handles.Img{handles.Id}.I.axesY(1)/handles.Img{handles.Id}.I.magFactor 0]);
        end
        imgWidth = size(imgRGB,2);
        imgHeight = size(imgRGB,1);
        
        if get(handles.roiShowCheck, 'value')
            handles.Img{handles.Id}.I.hROI.updateROIScreenPosition('full');
        end
        
        % update ROI of the Measure tool
        if ~isempty(handles.Img{handles.Id}.I.hMeasure.roi.type)
            handles.Img{handles.Id}.I.hMeasure.updateROIScreenPosition('full');
        end
    else
        xdata = get(handles.Img{handles.Id}.I.imh, 'XData');
        ydata = get(handles.Img{handles.Id}.I.imh, 'YData');
        imgWidth = xdata(2);
        imgHeight = ydata(2);
        xy2(1) = xy(1,1);
        xy2(2) = xy(1,2);
    end
    
    set(handles.im_browser, 'WindowButtonDownFcn' , []);  % turn off callback for the mouse key press during the pan mode
    set(handles.im_browser, 'WindowScrollWheelFcn', []); % turn off callback for the mouse wheel during the pan mode
    set(handles.im_browser, 'WindowButtonMotionFcn' , {@im_browser_panAxesFcn, handles, xy2, imgWidth, imgHeight});
    setptr(handles.im_browser, 'closedhand');  % undocumented matlab http://undocumentedmatlab.com/blog/undocumented-mouse-pointer-functions/
    set(handles.im_browser, 'WindowButtonUpFcn', {@im_browser_WindowButtonUpFcn, handles});
elseif strcmp(seltype,'extend') || strcmp(seltype,'alt')   % shift+left mouse, or both mouse buttons
    %% Start segmentation mode
    %y = round(xy(1,2));
    %x = round(xy(1,1));
    if strcmp(handles.preferences.disableSelection, 'yes') && ~strcmp(tool, 'Annotations'); return; end;    % no selection layer
    if xy(1,1) < 1 || xy(1,2) < 1 || xy(1,1) > size(handles.Img{handles.Id}.I.Ishown,2) || xy(1,2) > size(handles.Img{handles.Id}.I.Ishown,1); 
        if ~strcmp(tool, 'Lasso')   % lasso tool can work also when the mouse click was outside the image
            return; 
        end
    end;
    
    % x, y - x/y coordinates of a pixel that was clicked for the full dataset
    %x = xy(1,1)*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesX(1))]);
    %y = xy(1,2)*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesY(1))]);

    if handles.Img{handles.Id}.I.modelExist == 0 && get(handles.segmSelectedOnlyCheck,'Value')  % case when 'selected only' choosen but no model present, remove Selected only switch
        set(handles.segmSelectedOnlyCheck,'Value',0);
        set(handles.segmSelList, 'BackgroundColor', [1, 1, 1]);
    end
    
    switch tool
        case '3D ball'
            % 3D ball: filled shere in 3d with a center at the clicked point
            [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 0);
            handles = ib_segmentation_3dBall(ceil(h), ceil(w), ceil(z), modifier, handles);
        case 'Annotations'
            % add text annotation
            [w, h, z, t] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 0);
            handles = ib_segmentation_Annotation(h, w, z, t, modifier, handles);            
        case {'Brush', 'Smart Watershed'}
            % the Brush mode
            x = round(xy(1,1));
            y = round(xy(1,2));
            set(handles.im_browser, 'WindowScrollWheelFcn', []); % turn off callback for the mouse wheel during the brush selection
            set(handles.im_browser, 'WindowKeyPressFcn' , []);  % turn off callback for the keys during the brush selection
            %set(handles.im_browser, 'WindowKeyPressFcn', {@im_browser_WindowKeyPressFcn_Empty, handles}); % turn ON callback for the keys
            ib_segmentation_Brush(y, x, modifier, handles);
            return;
        case 'BW Thresholding'
            % Black and white thresholding
            return;
        case 'Lasso'
            % Lasso mode
            try
                handles = ib_segmentation_Lasso(modifier, handles);
            catch err
            
            end
        case {'MagicWand-RegionGrowing'}
            % Magic Wand mode
            magicWandRadius = str2double(get(handles.magicWandRadius, 'String'));
            if switch3d
                if handles.Img{handles.Id}.I.blockModeSwitch && magicWandRadius == 0
                    [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'blockmode', 0);
                else
                    [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 0);
                end
                yxzCoordinate = [h, w, z];
            else
                %yxzCoordinate = [yCrop, xCrop];
                if handles.Img{handles.Id}.I.blockModeSwitch && magicWandRadius == 0
                    [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'blockmode', 1);    
                else
                    [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 1);    
                end
                yxzCoordinate = [h, w, z];
            end

            subTool = get(handles.magicwandMethodPopup, 'value');    % magic wand or region growing
            % make new selection with shift and add to the selection
            % without modifiers
            if isempty(modifier); 
                modifier = 'shift'; 
            elseif strcmp(modifier, 'shift')
                modifier = [];
            end;
            
            if subTool == 1
                handles = ib_segmentation_MagicWand(ceil(yxzCoordinate), modifier, handles);
            else
                handles = ib_segmentation_RegionGrowing(ceil(yxzCoordinate), modifier, handles);
            end
        case 'Object Picker'
            % targeted selection from Mask/Models layers
            if switch3d
                [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 0); 
            else
                if handles.Img{handles.Id}.I.blockModeSwitch == 1
                    [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'blockmode', 1); 
                else
                    [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 1); 
                end
            end
            yxzCoordinate = [h,w,z];
            try
                handles = ib_segmentation_ObjectPicker(ceil(yxzCoordinate), modifier, handles);
            catch err
            end
            if get(handles.filterSelectionPopup,'Value') == 6; return; end;     % return when using the Brush tool
        case 'Membrane ClickTracker'
            % Trace membranes
            if switch3d
                [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 0);
            else
                [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 1);
            end
            yxzCoordinate = [h,w,z];
            yx(1) = xy(1,2);
            yx(2) = xy(1,1);
            [output, handles] = ib_segmentation_MembraneClickTraker(ceil(yxzCoordinate), yx, modifier, handles);
            if strcmp(output, 'return'); return; end;
        case 'Spot'
            % The spot mode: draw a circle after mouse click
            [w, h, z] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown', 1);
            handles = ib_segmentation_Spot(ceil(h), ceil(w), modifier, handles);
    end
    guidata(handles.im_browser, handles);
    handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    set(handles.im_browser, 'windowbuttonmotionfcn' , {@im_browser_winMouseMotionFcn, handles});
    set(handles.im_browser, 'windowbuttonupfcn', {@im_browser_WindowButtonUpFcn, handles});
elseif strcmp(seltype, 'open')     % double click
    %disp('open')
end

guidata(handles.im_browser, handles);
%set(handles.im_browser, 'windowbuttonupfcn', {@im_browser_WindowButtonUpFcn, handles});
end