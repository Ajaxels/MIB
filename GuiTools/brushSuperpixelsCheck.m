function brushSuperpixelsCheck(hObject, eventdata, handles)
% function brushSuperpixelsCheck(hObject, eventdata, handles)
% --- Executes on button press in brushSupervoxelsCheck.

% Copyright (C) 05.05.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 04.11.2015 added watershed superpixels

if get(hObject, 'value') == 0
    set(handles.superpixelsNumberEdit, 'enable', 'off');
    set(handles.superpixelsCompactEdit, 'enable', 'off');
else
    set(handles.superpixelsNumberEdit, 'enable', 'on');
    set(handles.superpixelsCompactEdit, 'enable', 'on');
    switch get(hObject, 'tag')
        case 'brushSuperpixelsCheck'                % SLIC superpixels
            set(handles.brushSuperpixelsWatershedCheck, 'value', 0);
            set(handles.brushPanelNText, 'TooltipString', 'number of superpixels, larger number gives more precision, but slower');
            set(handles.superpixelsNumberEdit, 'TooltipString', 'number of superpixels, larger number gives more precision, but slower');
            set(handles.brushPanelCompactText, 'String', 'Compact');
            set(handles.brushPanelCompactText, 'TooltipString', 'compactness factor, the larger the number more square resulting superpixels');
            set(handles.superpixelsCompactEdit, 'TooltipString', 'compactness factor, the larger the number more square resulting superpixels');
            set(handles.superpixelsCompactEdit, 'callback', {@editbox_Callback, guidata(hObject), 'posint', '0', [0,200]});
        case 'brushSuperpixelsWatershedCheck'       % Watershed superpixels
            set(handles.brushSuperpixelsCheck, 'value', 0);
            set(handles.brushPanelNText, 'TooltipString', 'factor to modify size of superpixels, the larger number gives bigger superpixels');
            set(handles.superpixelsNumberEdit, 'TooltipString', 'factor to modify size of superpixels, the larger number gives bigger superpixels');
            set(handles.brushPanelCompactText, 'String', 'Invert');
            set(handles.brushPanelCompactText, 'TooltipString', 'put 0 if objects have bright boundaries or 1 if objects have dark boundaries');
            set(handles.superpixelsCompactEdit, 'TooltipString', 'put 0 if objects have bright boundaries or 1 if objects have dark boundaries');
            set(handles.superpixelsCompactEdit, 'callback', {@editbox_Callback, guidata(hObject), 'posint', '0', [0,1]});
            
    end
end
end