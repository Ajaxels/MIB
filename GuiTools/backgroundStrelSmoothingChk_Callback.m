% --- Executes on button press in backgroundStrelSmoothingChk.
function backgroundStrelSmoothingChk_Callback(hObject, eventdata, handles)
% function backgroundStrelSmoothingChk_Callback(hObject, eventdata, handles)
% a callback to the handles.backgroundStrelSmoothingChk
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if get(handles.backgroundStrelSmoothingChk,'Value')
    set(handles.bgRemoveSubPanel2, 'visible','off');
    set(handles.bgRemoveSubPanel1, 'visible','on');
    set(handles.backgroundGaussTxt,'Enable','on');
    set(handles.backgroundGaussSize,'Enable','on');
    set(handles.backgroundGaussSigmaTxt,'Enable','on');
    set(handles.backgroundGaussSigmaEdit,'Enable','on');
    set(handles.bgMaxMinimaEdit,'Enable','off');
    set(handles.backgroundLocNormSw,'value',0);
else
    set(handles.backgroundGaussTxt,'Enable','off');
    set(handles.backgroundGaussSize,'Enable','off');
    set(handles.backgroundGaussSigmaTxt,'Enable','off');
    set(handles.backgroundGaussSigmaEdit,'Enable','off');
end
end