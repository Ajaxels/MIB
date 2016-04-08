% --- Executes on key release with focus on im_browser or any of its controls.
function im_browser_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to im_browser (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% if strcmp(eventdata.Key, 'control')
%     radius = str2double(get(handles.segmSpotSizeEdit, 'String'));
%     set(handles.segmSpotSizeEdit, 'string', num2str(radius - max([0 handles.ctrlPressed])));
%     handles = ib_updateCursor(handles, 'dashed');
% end    

% return after use of Control key. handles.ctrlPressed contains change in
% the brush diameter
if handles.ctrlPressed ~= 0;
    radius = str2double(get(handles.segmSpotSizeEdit, 'String'));
    set(handles.segmSpotSizeEdit, 'string', num2str(radius - max([0 handles.ctrlPressed])));
    handles = ib_updateCursor(handles, 'dashed');
end

% return after Alt key press, used together with the mouse wheel to zoom in/out 
if strcmp(eventdata.Key, 'alt')
    warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
    jFig = get(handles.im_browser, 'JavaFrame');
    jFig.requestFocus();
end
handles.ctrlPressed = 0;
guidata(handles.im_browser, handles);
end