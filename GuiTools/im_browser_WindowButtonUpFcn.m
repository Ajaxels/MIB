function mibGUI_WindowButtonUpFcn(hObject, eventdata, handles, brush_switch)
% function im_browser_WindowButtonUpFcn(hObject, eventdata, handles, brush_switch)
% callback for release of the mouse button
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles of im_browser.m
% brush_switch: when ''subtract'' - subtracts the brush selection from the existing selection, needed for return after the brush drawing tool

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% if ~isstruct(handles)
%      handles = guidata(handles);  % update handles structure    
%      handles.Img{handles.Id}.I.brush_selection = handles.Img{handles.Id}.I.getSliceToShow('selection');
% end

%handles = guidata(handles.im_browser);

if iscell(handles.Img{handles.Id}.I.brush_selection)  % return after movement of the brush tool
    if numel(handles.Img{handles.Id}.I.brush_selection) > 1
        handles.Img{handles.Id}.I.brush_selection{1} = handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic;
    end
    currSelection = handles.Img{handles.Id}.I.getSliceToShow('selection');
    handles.Img{handles.Id}.I.brush_selection{1} = imresize(handles.Img{handles.Id}.I.brush_selection{1}, size(currSelection),'method','nearest');
    
    userData = get(handles.segmTable,'UserData');
    selcontour = userData.prevMaterial - 2;
    if get(handles.segmSelectedOnlyCheck,'Value')
        currModel = handles.Img{handles.Id}.I.getSliceToShow('model');
        handles.Img{handles.Id}.I.brush_selection{1}(currModel~=selcontour) = 0;
    end
    if get(handles.maskedAreaCheck,'Value') == 1
        mask = handles.Img{handles.Id}.I.getSliceToShow('mask');
        handles.Img{handles.Id}.I.brush_selection{1}(mask ~= 1) = 0;
    end
    if strcmp(brush_switch,'subtract')
        currSelection(handles.Img{handles.Id}.I.brush_selection{1}==1) = 0;
        handles.Img{handles.Id}.I.setSliceToShow('selection', currSelection);
    else
        handles.Img{handles.Id}.I.setSliceToShow('selection', uint8(currSelection | handles.Img{handles.Id}.I.brush_selection{1}));
    end
end
handles.Img{handles.Id}.I.brush_selection = NaN;    % remove all brush_selection data
handles.Img{handles.Id}.I.brush_prev_xy = NaN;

% update ROI of the Measure tool
if ~isempty(handles.Img{handles.Id}.I.hMeasure.roi.type)
    handles.Img{handles.Id}.I.hMeasure.updateROIScreenPosition('crop');
end

% update ROI of the hROI class
if ~isempty(handles.Img{handles.Id}.I.hROI.roi.type)
    handles.Img{handles.Id}.I.hROI.updateROIScreenPosition('crop');
end

set(hObject, 'pointer', 'crosshair');
set(hObject, 'WindowButtonUpFcn', '');
set(hObject, 'WindowButtonDownFcn', {@im_browser_WindowButtonDownFcn, handles});
set(hObject, 'WindowKeyPressFcn', {@im_browser_WindowKeyPressFcn, handles}); % turn ON callback for the keys
handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
im_browser_winMouseMotionFcn(handles.im_browser, eventdata, handles);
end