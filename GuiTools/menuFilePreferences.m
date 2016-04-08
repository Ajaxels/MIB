function menuFilePreferences(hObject, eventdata, handles)
% function menuFilePreferences(hObject, eventdata, handles)
% a callback to Menu->File->Preferences, opens the Preferences dialog
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


handles.preferences.modelMaterialColors = handles.Img{handles.Id}.I.modelMaterialColors;
handles.preferences.lutColors = handles.Img{handles.Id}.I.lutColors;
preferences = preferencesDlg(handles.preferences, handles.im_browser);
if ~isstruct(preferences); return; end;
if handles.preferences.uint8 ~= preferences.uint8   % convert the model
    handles.Img{handles.Id}.I.convertModel();
end
handles.preferences = preferences;
handles.Img{handles.Id}.I.modelMaterialColors = handles.preferences.modelMaterialColors;
handles.Img{handles.Id}.I.lutColors = handles.preferences.lutColors;
if strcmp(preferences.undo, 'no')
    handles.U.clearContents();
    handles.U.enableSwitch = 0;
else
    handles.U.enableSwitch = 1;
end
if strcmp(preferences.disableSelection, 'no')
    if isnan(handles.Img{handles.Id}.I.selection(1)) && ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
        handles.Img{handles.Id}.I.clearSelection();
    elseif strcmp(handles.Img{handles.Id}.I.model_type, 'uint6') && isnan(handles.Img{handles.Id}.I.model(1))
        handles.Img{handles.Id}.I.model = zeros(size(handles.Img{handles.Id}.I.img,1),size(handles.Img{handles.Id}.I.img,2),size(handles.Img{handles.Id}.I.img,4),'uint8');
    end
%     val = get(handles.seltypePopup,'Value');
%     toolsList = get(handles.seltypePopup,'String');
%     selectedTool = strtrim(toolsList{val});
%     switch selectedTool
%         case {'Spot', 'Brush', '3D ball', 'Smart Watershed'}
%             handles.showBrushCursor = 1;
%         case {'Object Picker'}
%             list = get(handles.filterSelectionPopup, 'string');
%             if strcmp(list{get(handles.filterSelectionPopup, 'value')}, 'Brush')
%                 handles.showBrushCursor = 1;
%             end
%         otherwise
%             handles.showBrushCursor = 0;
%     end
else
    if strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
        handles.Img{handles.Id}.I.model = NaN;    
        handles.Img{handles.Id}.I.modelExist = 0;
    else
        handles.Img{handles.Id}.I.selection = NaN;    
    end
    handles.U.clearContents();  % delete backup history
end

% remove the brush cursor
seltypePopup_Callback(hObject, eventdata, handles);
handles = guidata(handles.im_browser);

handles = updateGuiWidgets(handles);
toolbarInterpolation(handles.toolbarInterpolation, '', handles, 'keepcurrent');     % update the interpolation button icon
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end