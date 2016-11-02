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
% 25.10.2016, IB updated for the segmentation table

val = get(handles.segmSelectedOnlyCheck, 'value');
if val == 1 % selected only
    set(handles.segmSelectedOnlyCheck, 'backgroundcolor', [1 .6 .784]);
else
    set(handles.segmSelectedOnlyCheck, 'backgroundcolor', [0.8310    0.8160    0.7840]);
    userData = get(handles.segmTable,'UserData');
    if userData.unlink == 0
        userData.prevAddTo = userData.prevMaterial;
        set(handles.segmTable,'UserData',userData);
    end
end
updateSegmentationTable(handles);

unFocus(handles.segmSelectedOnlyCheck);   % remove focus from hObject
end