% --- Executes on button press in segmSelectedOnlyCheck.
function segmSelectedOnlyCheck_Callback(hObject, eventdata, handles)
% function segmSelectedOnlyCheck_Callback(hObject, eventdata, handles)
% a callback to the handles.segmSelectedOnlyCheck, allows to toggle state of the 'Fix selection to material'
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



val = get(handles.segmSelectedOnlyCheck, 'value');
if val == 1 % selected only
    set(handles.segmSelList, 'BackgroundColor', [0.3, 0.3, 0.3]);
    set(handles.segmSelectedOnlyCheck, 'backgroundcolor', [1 .6 .784]);
    
    selMaterial = get(handles.segmSelList, 'value');    % do nothing when the All selected
    if selMaterial == 1
        msgbox('Please select material in the Select from list and try again!','Wrong material selection','error');
        set(handles.segmSelList, 'BackgroundColor', [1, 1, 1]);
        set(handles.segmSelectedOnlyCheck, 'backgroundcolor', [0.8310    0.8160    0.7840]);
        set(handles.segmSelectedOnlyCheck, 'value', 0);
        return;
    end
else
    set(handles.segmSelList, 'BackgroundColor', [1, 1, 1]);
    set(handles.segmSelectedOnlyCheck, 'backgroundcolor', [0.8310    0.8160    0.7840]);
end
unFocus(handles.segmSelectedOnlyCheck);   % remove focus from hObject
end