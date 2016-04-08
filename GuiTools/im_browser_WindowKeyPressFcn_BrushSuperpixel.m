% --- Executes on key release with focus on im_browser or any of its controls.
function im_browser_WindowKeyPressFcn_BrushSuperpixel(hObject, eventdata, handles)
% function im_browser_WindowKeyPressFcn_BrushSuperpixel(hObject, eventdata, handles)
% a function to check key callbacks when using the Brush in the Superpixel mode
% hObject    handle to im_browser (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
%disp(eventdata.Key);
%disp(eventdata.Character);
%disp(eventdata.Modifier);

% Copyright (C) 01.04.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% return when editing the edit boxes
%if strcmp(get(get(hObject,'CurrentObject'),'style'), 'edit'); return; end;

char=eventdata.Key;
if strcmp(char, 'alt'); return; end;
modifier = eventdata.Modifier;
handles = guidata(handles.im_browser);

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
if ismember('alt', modifier); altSw = 1; end;
ActionId = ismember(handles.preferences.KeyShortcuts.Key, char) & ismember(handles.preferences.KeyShortcuts.control, controlSw) & ...
    ismember(handles.preferences.KeyShortcuts.shift, shiftSw) & ismember(handles.preferences.KeyShortcuts.alt, altSw);
ActionId = find(ActionId>0);    % action id is the index of the action, handles.preferences.KeyShortcuts.Action(ActionId)

if ~isempty(ActionId) % find in the list of existing shortcuts
    switch handles.preferences.KeyShortcuts.Action{ActionId}
        case 'Undo/Redo last action'
            if numel(handles.Img{handles.Id}.I.brush_selection{2}.selectedSlicIndices) == 0
                return;
            end
            removeId = handles.Img{handles.Id}.I.brush_selection{2}.selectedSlicIndices(end);
            handles.Img{handles.Id}.I.brush_selection{2}.selectedSlicIndices(end) = [];
            handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic(handles.Img{handles.Id}.I.brush_selection{2}.slic == removeId) = 0;
            
            CData = handles.Img{handles.Id}.I.brush_selection{2}.CData;
            CData(handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic==1) = intmax(class(handles.Img{handles.Id}.I.Ishown))*.4;
            set(handles.Img{handles.Id}.I.imh,'CData',CData);
    end
end
%-- do not put guidata here!
% or add first
%handles = guidata(handles.im_browser);
%guidata(handles.im_browser, handles);
%--
end  % ------ end of im_browser_WindowKeyPressFcn_BrushSuperpixel
