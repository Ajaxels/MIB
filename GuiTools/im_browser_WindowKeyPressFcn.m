% --- Executes on key release with focus on im_browser or any of its controls.
function im_browser_WindowKeyPressFcn(hObject, eventdata, handles)
%function im_browser_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to im_browser (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
%disp(eventdata.Key);
%disp(eventdata.Character);
%disp(eventdata.Modifier);

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 03.11.2015, IB, compatible with handles.preferences.KeyShortcuts structure
% 18.09.2016, changed .slices to cells


% return when editing the edit boxes
if ~isempty(strfind(get(get(hObject,'CurrentObject'),'tag'), 'Edit'));
    return;
end;

char=eventdata.Key;

if strcmp(char, 'alt'); return; end;
modifier = eventdata.Modifier;

handles = guidata(handles.im_browser);
xyString = get(handles.pixelinfoTxt2,'string');
colon = strfind(xyString, ':');
bracket = strfind(xyString, '(');
x = str2double(xyString(1:colon(1)-1));
y = str2double(xyString(colon(1)+1:bracket(1)-1));
inImage = str2double(xyString(bracket+1));  % when inImage is a number the mouse cursor is above the image
inAxes = 1;
if xyString(1) == 'X'; inAxes = 0; end;     % whem inAxes is 1, the mouse cursor above the image axes

% % testing the shortcut system
if strcmp(char, 'i')
    0;
end

% find a shortcut action
controlSw = 0;
shiftSw = 0;
altSw = 0;
if ismember('control', modifier); controlSw = 1; end;
if ismember('shift', modifier); 
    if ismember(char, handles.preferences.KeyShortcuts.Key(6:16))   % override the Shift state for actions that work for all slices
        shiftSw = 0;  
    else
        shiftSw = 1; 
    end
end;
if ismember('alt', modifier); 
    % override the Alt state for previous/next time point
    % 'a', 's', 'r', 'c', 'z', 'x'
    if ismember(char, handles.preferences.KeyShortcuts.Key([7:12 13:14]))  
        altSw = 0;
    elseif ismember(char, handles.preferences.KeyShortcuts.Key(6)) && ismember('shift', modifier)
        % to care about Alt+A
        altSw = 0;
    else
        altSw = 1; 
    end
end;
ActionId = ismember(handles.preferences.KeyShortcuts.Key, char) & ismember(handles.preferences.KeyShortcuts.control, controlSw) & ...
    ismember(handles.preferences.KeyShortcuts.shift, shiftSw) & ismember(handles.preferences.KeyShortcuts.alt, altSw);
ActionId = find(ActionId>0);    % action id is the index of the action, handles.preferences.KeyShortcuts.Action(ActionId)

if ~isempty(ActionId) % find in the list of existing shortcuts
    switch handles.preferences.KeyShortcuts.Action{ActionId}
        case 'Switch dataset to XY orientation'         % default 'Alt + 1'
            if handles.Img{handles.Id}.I.orientation == 4 || isnan(inImage) %|| x < 1 || x > handles.Img{handles.Id}.I.no_stacks;
                return;
            elseif handles.Img{handles.Id}.I.orientation == 1 || handles.Img{handles.Id}.I.orientation == 2;
                handles.Img{handles.Id}.I.current_yxz(3) = x;
                moveMouseSw = 1;   % move the mouse cursor to the point where the plane was changed
                toolbarPlaneToggle(handles.xyPlaneToggle, NaN, handles, moveMouseSw);
            end
        case 'Switch dataset to ZX orientation'         % default 'Alt + 2'
            if handles.Img{handles.Id}.I.orientation == 1 || isnan(inImage);
                return;
            elseif handles.Img{handles.Id}.I.orientation == 2
                handles.Img{handles.Id}.I.current_yxz(1) = y;
                handles.Img{handles.Id}.I.current_yxz(2) = handles.Img{handles.Id}.I.slices{2}(1);
                handles.Img{handles.Id}.I.current_yxz(3) = x;
            elseif handles.Img{handles.Id}.I.orientation == 4;
                handles.Img{handles.Id}.I.current_yxz(1) = y;
                handles.Img{handles.Id}.I.current_yxz(2) = x;
                handles.Img{handles.Id}.I.current_yxz(3) = handles.Img{handles.Id}.I.slices{4}(1);
            end
            moveMouseSw = 1;   % move the mouse cursor to the point where the plane was changed
            toolbarPlaneToggle(handles.zxPlaneToggle, NaN, handles, moveMouseSw);
        case 'Switch dataset to ZY orientation'         % default 'Alt + 3'
            if handles.Img{handles.Id}.I.orientation == 2 || isnan(inImage);
                return;
            elseif handles.Img{handles.Id}.I.orientation == 1;
                handles.Img{handles.Id}.I.current_yxz(1) = handles.Img{handles.Id}.I.slices{1}(1);
                handles.Img{handles.Id}.I.current_yxz(2) = y;
                handles.Img{handles.Id}.I.current_yxz(3) = x;
            elseif handles.Img{handles.Id}.I.orientation == 4;
                handles.Img{handles.Id}.I.current_yxz(1) = y;
                handles.Img{handles.Id}.I.current_yxz(2) = x;
                handles.Img{handles.Id}.I.current_yxz(3) = handles.Img{handles.Id}.I.slices{4}(1);
            end
            moveMouseSw = 1;   % move the mouse cursor to the point  where the plane was changed
            toolbarPlaneToggle(handles.zyPlaneToggle, NaN, handles, moveMouseSw);
        case 'Interpolate selection'            % default 'i'
            menuSelectionInterpolate(NaN, NaN, handles);
        case 'Invert image'                     % default 'Ctrl + i'
            handles = ib_invertImage(handles);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        case 'Add to selection to material'     % default 'a'/'Shift+a'
            % do nothing is selection is disabled
            if strcmp(handles.preferences.disableSelection, 'yes'); return; end;
            
            if get(handles.segmAddList,'Value') == 1    % Selection to Model
                selectionTo = 'mask';
            else    % Selection to Mask
                selectionTo = 'model';
            end
            if sum(ismember({'alt','shift'}, modifier)) == 2
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'4D','add');
            elseif sum(ismember({'alt','shift'}, modifier)) == 1
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'3D','add');
            else
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'2D','add');
            end
        case 'Subtract from material'   % default 's'/'Shift+s'
            % do nothing is selection is disabled
            if strcmp(handles.preferences.disableSelection, 'yes'); return; end;
            
            if get(handles.segmAddList,'Value') == 1    % Selection to Model
                selectionTo = 'mask';
            else    % Selection to Mask
                selectionTo = 'model';
            end
            if sum(ismember({'alt','shift'}, modifier)) == 2
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'4D','remove');
            elseif sum(ismember({'alt','shift'}, modifier)) == 1
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'3D','remove');
            else
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'2D','remove');
            end
        case 'Replace material with current selection'  % default 'r'/'Shift+r'
            % do nothing is selection is disabled
            if strcmp(handles.preferences.disableSelection, 'yes'); return; end;
        
            if get(handles.segmAddList,'Value') == 1    % Selection to Model
                selectionTo = 'mask';
            else    % Selection to Mask
                selectionTo = 'model';
            end
            if sum(ismember({'alt','shift'}, modifier)) == 2
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'4D','replace');
            elseif sum(ismember({'alt','shift'}, modifier)) == 1
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'3D','replace');
            else
                ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',selectionTo,'2D','replace');
            end
        case 'Clear selection'  % default 'c'/'Shift+c'
            % do nothing is selection is disabled
            if strcmp(handles.preferences.disableSelection, 'yes'); return; end;
            
            if sum(ismember({'alt','shift'}, modifier)) == 2
                selectionClearBtn_Callback(handles.selectionClearBtn,eventdata, handles, '4D');
            elseif sum(ismember({'alt','shift'}, modifier)) == 1
                selectionClearBtn_Callback(handles.selectionClearBtn,eventdata, handles, '3D');
            else
                selectionClearBtn_Callback(handles.selectionClearBtn,eventdata, handles, '2D');
            end
        case 'Fill the holes in the Selection layer'   % default 'f'/'Shift+f'
            if strcmp(handles.Img{handles.Id}.I.model_type, 'uint8')
                if isnan(handles.Img{handles.Id}.I.selection(1)); return; end;
            end;
            
            if sum(ismember({'alt','shift'}, modifier)) == 2
                selectionFillBtn_Callback(handles.selectionFillBtn,eventdata, handles, '4D');
            elseif sum(ismember({'alt','shift'}, modifier)) == 1
                selectionFillBtn_Callback(handles.selectionFillBtn,eventdata, handles, '3D');
            else
                selectionFillBtn_Callback(handles.selectionFillBtn,eventdata, handles, '2D');
            end
        case 'Erode the Selection layer'    % default 'z'/'Shift+z'
            if isnan(handles.Img{handles.Id}.I.selection(1)) && strcmp(handles.Img{handles.Id}.I.model_type, 'uint8'); return; end;
            selectionErBtn_Callback(handles.selectionErBtn, eventdata, handles);
        case 'Dilate the Selection layer'   % default 'x'/'Shift + x'
            if isnan(handles.Img{handles.Id}.I.selection(1)) && strcmp(handles.Img{handles.Id}.I.model_type, 'uint8'); return; end;
            selectionDilateBtn_Callback(handles.selectionDilateBtn,eventdata,handles);
        case {'Zoom out/Previous slice','Previous slice'}       % default 'q' / 'downarrow'
            % do nothing if the mouse not above the image
            if (strcmp(char, 'leftarrow') && inAxes == 0) || (strcmp(char, 'downarrow') && inAxes == 0)
                return;
            end
            if strcmp(handles.preferences.KeyShortcuts.Action{ActionId}, 'Previous slice')
                changeSliceSwitch = 1;
            else
                changeSliceSwitch = strcmp(get(handles.mouseWheelToolbarSw,'State'),'off');
            end
            if changeSliceSwitch == 1   % change slices
                if strcmp(modifier, 'alt')  % change time
                    if handles.Img{handles.Id}.I.time == 1; return; end;   % check for a single time point
                    shift = 1;
                    new_index = handles.Img{handles.Id}.I.slices{5}(1) - shift;
                    if new_index < 1;  new_index = 1; end;
                    handles.Img{handles.Id}.I.slices{5} = [1, 1];
                    set(handles.changeTimeSlider,'Value', new_index);
                    changeTimeSlider_Callback(handles.changeTimeSlider, eventdata, handles);
                else    % change Z
                    if handles.Img{handles.Id}.I.no_stacks == 1; return; end;   % check for a single image
                    if strcmp(modifier,'shift')  % 10 frames shift
                        shift = handles.sliderShiftStep;
                    else
                        shift = handles.sliderStep;
                    end
                    new_index = handles.Img{handles.Id}.I.slices{handles.Img{handles.Id}.I.orientation}(1) - shift;
                    if new_index < 1;  new_index = 1; end;
                    handles.Img{handles.Id}.I.slices{handles.Img{handles.Id}.I.orientation} = [1, 1];
                    set(handles.changelayerSlider,'Value', new_index);
                    changelayerSlider_Callback(handles.changelayerSlider, eventdata, handles);
                end
            else    % zoom out with Q
                recenter = 1;
                toolbar_zoomBtn(handles.zoomoutPush, eventdata, handles, recenter);
            end
        case {'Zoom in/Next slice', 'Next slice'}       % default 'w' / 'uparrow'
            % do nothing if the mouse not above the image
            if (strcmp(char, 'leftarrow') && inAxes == 0) || (strcmp(char, 'downarrow') && inAxes == 0)
                return;
            end
            if strcmp(handles.preferences.KeyShortcuts.Action{ActionId}, 'Next slice')
                changeSliceSwitch = 1;
            else
                changeSliceSwitch = strcmp(get(handles.mouseWheelToolbarSw,'State'),'off');
            end
            
            if changeSliceSwitch == 1   % change slices
                if strcmp(modifier, 'alt')  % change time
                    if handles.Img{handles.Id}.I.time == 1; return; end;   % check for a single time point
                    shift = 1;
                    new_index = handles.Img{handles.Id}.I.slices{5}(1) + shift;
                    if new_index > handles.Img{handles.Id}.I.time;  new_index = handles.Img{handles.Id}.I.time; end;
                    handles.Img{handles.Id}.I.slices{5} = [new_index, new_index];
                    set(handles.changeTimeSlider,'Value', new_index);
                    changeTimeSlider_Callback(handles.changeTimeSlider, eventdata, handles);
                else    % change Z
                    if handles.Img{handles.Id}.I.no_stacks == 1; return; end;   % check for a single image
                    if strcmp(modifier,'shift')  % 10 frames shift
                        shift = handles.sliderShiftStep;
                    else
                        shift = handles.sliderStep;
                    end
                    new_index = handles.Img{handles.Id}.I.slices{handles.Img{handles.Id}.I.orientation}(1) + shift;
                    if new_index > size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation)
                        new_index = size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation);
                    end
                    handles.Img{handles.Id}.I.slices{handles.Img{handles.Id}.I.orientation} = [new_index, new_index];
                    set(handles.changelayerSlider,'Value',new_index);
                    changelayerSlider_Callback(handles.changelayerSlider, eventdata, handles);
                end
            else   % zoom in with W
                recenter = 1;
                toolbar_zoomBtn(handles.zoominPush, eventdata, handles, recenter); % zoomoutPush zoominPush
            end
        case 'Show/hide the Model layer'    % default 'space'
            val = get(handles.modelShowCheck,'Value');
            set(handles.modelShowCheck,'Value',abs(val-1));
            modelShowCheck_Callback(handles.modelShowCheck, eventdata, handles);
        case 'Show/hide the Mask layer'     % default 'Ctrl + space'
            val = get(handles.maskShowCheck,'Value');
            set(handles.maskShowCheck,'Value',abs(val-1));
            maskShowCheck_Callback(hObject, eventdata, handles);
        case 'Fix selection to material'
            selCheck = get(handles.segmSelectedOnlyCheck,'Value');
            set(handles.segmSelectedOnlyCheck,'Value', abs(selCheck-1));
            segmSelectedOnlyCheck_Callback(hObject, eventdata, handles);
        case 'Save image as...' % default 'Ctrl + s'
            menuFileSaveImageAs(hObject, eventdata, handles);
        case 'Copy to buffer selection from the current slice'  % default 'Ctrl + c'
            menuSelectionBuffer(handles.menuSelectionBufferCopy, eventdata, handles, 'copy');
        case 'Paste buffered selection to the current slice'    % default 'Ctrl + v'
            menuSelectionBuffer(handles.menuSelectionBufferCopy, eventdata, handles, 'paste');
        case 'Toggle between the selected material and exterior' % default 'e'
            val = get(handles.segmSelList,'Value');
            if val == 2
                set(handles.segmSelList,'Value',handles.lastSegmSelection);
            else
                set(handles.segmSelList,'Value',2);
            end
            guidata(handles.im_browser, handles);
        case 'Loop through the list of favourite segmentation tools'    % default 'd'
            if numel(handles.preferences.lastSegmTool) == 0
                errordlg(sprintf('The selection tools for the fast access with the "D" shortcut are not difined!\n\nPlease use the "D" button in the Segmentation panel to select them!'),'No tools defined!');
                return;
            end
            toolId = get(handles.seltypePopup, 'value');
            nextTool = handles.preferences.lastSegmTool(find(handles.preferences.lastSegmTool>toolId, 1));
            if isempty(nextTool)
                nextTool = handles.preferences.lastSegmTool(1);
            end;
            toolList = get(handles.seltypePopup, 'String');
            
            fittext = annotation(handles.im_browser,'textbox',...
                'Position',[0.44    0.6964    0.3    0.0534],...
                'BackgroundColor',[0.8706 0.9216 0.9804],...
                'Color',[0 0 0],...
                'FitHeightToText','off',...
                'FontAngle','italic',...
                'FontName','Arial',...
                'FontSize',20,...
                'FontWeight','bold',...
                'HorizontalAlignment','center',...
                'VerticalAlignment', 'middle',...
                'String',toolList(nextTool));
            pause(.1);
            set(handles.seltypePopup,'Value',nextTool);
            seltypePopup_Callback(handles.seltypePopup, eventdata, handles);
            delete(fittext);
        case 'Undo/Redo last action'    % default 'Ctrl + z'
            if strcmp(handles.preferences.undo, 'no'); return; end
            if handles.U.prevUndoIndex == 0; return; end;
            ib_do_undo(handles);
        case 'Previous time point'
            if handles.Img{handles.Id}.I.time == 1; return; end;   % check for a single time point
            shift = 1;
            new_index = handles.Img{handles.Id}.I.slices{5}(1) - shift;
            if new_index < 1;  new_index = 1; end;
            handles.Img{handles.Id}.I.slices{5} = [1, 1];
            set(handles.changeTimeSlider,'Value', new_index);
            changeTimeSlider_Callback(handles.changeTimeSlider, eventdata, handles);
        case 'Next time point'
            if handles.Img{handles.Id}.I.time == 1; return; end;   % check for a single time point
            shift = 1;
            new_index = handles.Img{handles.Id}.I.slices{5}(1) + shift;
            if new_index > handles.Img{handles.Id}.I.time;  new_index = handles.Img{handles.Id}.I.time; end;
            handles.Img{handles.Id}.I.slices{5} = [new_index, new_index];
            set(handles.changeTimeSlider,'Value', new_index);
            changeTimeSlider_Callback(handles.changeTimeSlider, eventdata, handles);
    end
else    % all other possible shortcuts
    switch char
        case 'escape'
            % detect escape when modifying the measurements, see Measure.drawROI method
            if ~isempty(handles.Img{handles.Id}.I.hMeasure.roi.imroi)
                if isvalid(handles.Img{handles.Id}.I.hMeasure.roi.imroi)
                    % changing the color to red to detect the Esc key in the Measure.drawROI method
                    handles.Img{handles.Id}.I.hMeasure.roi.imroi.setColor('r');
                    resume(handles.Img{handles.Id}.I.hMeasure.roi.imroi);
                end;
            end;
            
            % detect escape when modifying the ROIs, see roiRegion.drawROI method
            if ~isempty(handles.Img{handles.Id}.I.hROI.roi.imroi)
                if isvalid(handles.Img{handles.Id}.I.hROI.roi.imroi)
                    % changing the color to red to detect the Esc key in the roiRegion.drawROI method
                    handles.Img{handles.Id}.I.hROI.roi.imroi.setColor('r');
                    resume(handles.Img{handles.Id}.I.hROI.roi.imroi);
                end;
            end;
        case 'a'    % Select the Mask or Material (when mask is not shown) layer 
            if strcmp(modifier,'control') | strcmp(modifier,'alt') %#ok<OR2>    
                if ~strcmp(handles.Img{handles.Id}.I.model_type,'int8')
                    mask_switch = get(handles.maskShowCheck,'Value');
                    if strcmp(modifier,'alt')
                        if mask_switch==1 % select only mask
                            ib_moveLayers(handles.imageAxes, NaN, NaN, 'mask','selection','3D','replace');
                        elseif handles.Img{handles.Id}.I.modelExist     % select only model
                            ib_moveLayers(handles.imageAxes, NaN, NaN, 'model','selection','3D','replace');
                        else    % make a combination of both mask and model
                            %ib_moveLayers(handles.imageAxes, NaN, NaN, 'model','selection','3D','replace');
                            %handles.Img{handles.Id}.I.selection = handles.Img{handles.Id}.I.maskImg & handles.Img{handles.Id}.I.selection;
                        end;
                    else
                        if mask_switch==1     % select only mask
                            ib_moveLayers(handles.imageAxes, NaN, NaN, 'mask','selection','2D','replace');
                        elseif handles.Img{handles.Id}.I.modelExist    % select only model
                            ib_moveLayers(handles.imageAxes, NaN, NaN, 'model','selection','2D','replace');
                        else    % make a combination of both mask and model
                            % ib_moveLayers(handles.imageAxes, NaN, NaN, 'model','selection','2D','replace');
                            %handles.Img{handles.Id}.I.selection(handles.Img{handles.Id}.I.slices{1}(1):handles.Img{handles.Id}.I.slices{1}(2),handles.Img{handles.Id}.I.slices{2}(1):handles.Img{handles.Id}.I.slices{2}(2),handles.Img{handles.Id}.I.slices{4}(1):handles.Img{handles.Id}.I.slices{4}(2)) = ...
                            %    handles.Img{handles.Id}.I.maskImg(handles.Img{handles.Id}.I.slices{1}(1):handles.Img{handles.Id}.I.slices{1}(2),handles.Img{handles.Id}.I.slices{2}(1):handles.Img{handles.Id}.I.slices{2}(2),handles.Img{handles.Id}.I.slices{4}(1):handles.Img{handles.Id}.I.slices{4}(2)) & handles.Img{handles.Id}.I.selection(handles.Img{handles.Id}.I.slices{1}(1):handles.Img{handles.Id}.I.slices{1}(2),handles.Img{handles.Id}.I.slices{2}(1):handles.Img{handles.Id}.I.slices{2}(2),handles.Img{handles.Id}.I.slices{4}(1):handles.Img{handles.Id}.I.slices{4}(2));
                        end;
                    end
                end
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            end
        case 'control'  % increase the radius of the brush for the erase tool
            if strcmp(modifier{1}, 'control') && handles.ctrlPressed == 0
                if handles.preferences.eraserRadiusFactor == 1; return; end;
                handles = guidata(handles.im_browser);
                radius = str2double(get(handles.segmSpotSizeEdit, 'String'));
                handles.ctrlPressed = max([floor(radius*handles.preferences.eraserRadiusFactor - radius) 1]);
                set(handles.segmSpotSizeEdit, 'string', num2str(radius+handles.ctrlPressed));
                ib_updateCursor(handles, 'dashed');
            end
    end
end

%-- do not put guidata here!
% or add first
%handles = guidata(handles.im_browser);
%guidata(handles.im_browser, handles);
%--
end  % ------ end of im_browser_WindowKeyPressFcn
