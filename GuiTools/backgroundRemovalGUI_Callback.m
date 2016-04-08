function backgroundRemovalGUI_Callback(hObject,eventdata,handles)
% function backgroundRemovalGUI_Callback(hObject,eventdata,handles)
% a callback to action done with the handles.backgroundPanel
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


tag = get(hObject,'tag');
val = get(hObject,'value');
smoothSw = get(handles.backgroundStrelSmoothingChk, 'value');
set(handles.bgRemoveSubPanel2, 'visible','off');
set(handles.bgRemoveSubPanel1, 'visible','on');
set(handles.backgroundStrelSmoothingChk,'String','Gauss:');
if smoothSw == 0 && ~get(handles.backgroundMorphOpenSw, 'value') ...
        && ~get(handles.backgroundMinimaSw, 'value') && ~get(handles.backgroundLocNormSw, 'value')
    set(handles.backgroundStrelSmoothingChk, 'value',1);
    set(handles.backgroundStrelSmoothingChk,'enable','inactive');
    backgroundStrelSmoothingChk_Callback(handles.backgroundStrelSmoothingChk, NaN, handles);
    return;
end

set(handles.backgroundMorphOpenSw, 'value', 0);
set(handles.backgroundMinimaSw, 'value', 0);
set(handles.backgroundLocNormSw, 'value', 0);
set(handles.backgroundStrelSizeEdit,'enable','off');
set(handles.bgMaxMinimaEdit,'enable','off');
set(handles.backgroundStrelSmoothingChk,'enable','on');

if strcmp(tag,'backgroundMorphOpenSw')  && val == 1
    set(handles.backgroundStrelSizeEdit,'enable','on');
    set(handles.backgroundMorphOpenSw, 'value', 1);
    set(handles.backgroundStrelSmoothingChk,'String','Smoothing:');
elseif strcmp(tag,'backgroundMinimaSw') && val == 1
    set(handles.backgroundMinimaSw, 'value', 1);
    set(handles.backgroundStrelSizeEdit,'enable','on');
    set(handles.bgMaxMinimaEdit,'enable','on');
    set(handles.backgroundStrelSmoothingChk,'String','Smoothing:');
elseif strcmp(tag,'backgroundLocNormSw') && val == 1
    set(handles.backgroundLocNormSw, 'value', 1);
    set(handles.backgroundStrelSmoothingChk, 'value',0);
    set(handles.bgRemoveSubPanel2, 'visible','on');
    set(handles.bgRemoveSubPanel1, 'visible','off');
    smoothSw = 0;
end

if smoothSw == 1
    set(handles.backgroundGaussSize,'enable','on');
    set(handles.backgroundGaussSigmaEdit,'enable','on');
else
    set(handles.backgroundGaussSize,'enable','off');
    set(handles.backgroundGaussSigmaEdit,'enable','off');
end
end
