function seltypePopup_Callback(hObject, eventdata, handles)
% function seltypePopup_Callback(~, ~, handles)
% a callback to the handles.seltypePopup, allows to select tool for the segmentation
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% Selection of tools for segmentation
val = get(handles.seltypePopup,'Value');
toolsList = get(handles.seltypePopup,'String');
selectedTool = strtrim(toolsList{val});
set(handles.segmMagicPanel,'Visible','off');
set(handles.segmAnnPanel,'Visible','off');
set(handles.segmMaskPanel,'Visible','off');
set(handles.segmSpotPanel,'Visible','off');
set(handles.segmThresPanel,'Visible','off');
set(handles.segmMembTracerPanel,'Visible','off');
set(handles.segmWatershedPanel,'Visible','off');
handles.showBrushCursor = 0;

if ~isempty(find(handles.preferences.lastSegmTool==val,1)) % the selected tool is also a fast access tool for the 'd' shortcut
    set(handles.segmFavToolCheck, 'value', 1);
    set(handles.seltypePopup,'backgroundcolor',[1 .69 .39]);    
else
    set(handles.segmFavToolCheck, 'value', 0);
    set(handles.seltypePopup,'backgroundcolor',[1 1 1]);
end

switch selectedTool
    case 'Annotations'
        set(handles.segmAnnPanel,'Visible','on');
    case 'Lasso'
        set(handles.segmMaskPanel,'Visible','on');
        set(handles.maskRecalcStatsBtn, 'visible', 'off');
        set(handles.objectPickerRadioPanel, 'visible', 'off');
        set(handles.brushText99, 'visible', 'off');
        set(handles.maskBrushSizeEdit, 'visible', 'off');
        list = get(handles.filterSelectionPopup, 'string');
        if numel(list) > 5; % reinitialize the list, because it is shared with Object Picker tool
            list = {'Lasso','Rectangle','Ellipse','Polyline'};
            set(handles.filterSelectionPopup, 'value', 1);
            set(handles.filterSelectionPopup, 'string', list);
        end
    case 'MagicWand-RegionGrowing'
        set(handles.segmMagicPanel,'Visible','on');
    case 'Object Picker'
        set(handles.segmMaskPanel,'Visible','on');
        set(handles.maskRecalcStatsBtn, 'visible', 'on');
        set(handles.objectPickerRadioPanel, 'visible', 'on');
        set(handles.brushText99, 'visible', 'on');
        set(handles.maskBrushSizeEdit, 'visible', 'on');
        list = get(handles.filterSelectionPopup, 'string');
        if numel(list) < 7;     % reinitialize the list, because it is shared with Lasso tool
            list = {'Click','Lasso','Rectangle','Ellipse','Polyline','Brush','Mask within Selection'};
            set(handles.filterSelectionPopup, 'string', list);
            set(handles.filterSelectionPopup, 'value', 1);
        end
        if strcmp(list{get(handles.filterSelectionPopup, 'value')}, 'Brush') && strcmp(handles.preferences.disableSelection,'no'); 
            handles.showBrushCursor = 1;
        end
    case {'Spot', '3D ball'}
        if strcmp(handles.preferences.disableSelection,'no')
            handles.showBrushCursor = 1;
        end
        set(handles.segmSpotPanel,'Visible','on');
        set(handles.brushSuperpixelsCheck, 'visible','off');
        set(handles.brushPanelNText, 'visible','off');
        set(handles.superpixelsNumberEdit, 'visible','off');
        set(handles.brushPanelCompactText, 'visible','off');
        set(handles.superpixelsCompactEdit, 'visible','off');
        set(handles.brushSuperpixelsWatershedCheck, 'visible','off');
    case 'Brush'
        set(handles.segmSpotPanel,'Visible','on');
        if strcmp(handles.preferences.disableSelection,'no')
            handles.showBrushCursor = 1;
        end
        set(handles.brushSuperpixelsCheck, 'visible','on');
        set(handles.brushSuperpixelsWatershedCheck, 'visible','on');
        set(handles.brushPanelNText, 'visible','on');
        set(handles.superpixelsNumberEdit, 'visible','on');
        set(handles.brushPanelCompactText, 'visible','on');
        set(handles.superpixelsCompactEdit, 'visible','on');
    case 'BW Thresholding'
        set(handles.segmThresPanel,'Visible','on');
    case 'Membrane ClickTracker'
        set(handles.segmMembTracerPanel,'Visible','on');
    case 'Smart Watershed'
        set(handles.segmWatershedPanel,'Visible','on');
        if strcmp(handles.preferences.disableSelection,'no')
            handles.showBrushCursor = 1;
        end
end
handles = ib_updateCursor(handles);
guidata(handles.im_browser, handles);
end