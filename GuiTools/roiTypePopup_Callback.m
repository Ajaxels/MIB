function roiTypePopup_Callback(hObject, eventdata, handles)
% function roiTypePopup_Callback(hObject, eventdata, handles)
% a callback for selection of the handles.roiTypePopup combo box with
% selection of ROI type to add

% Copyright (C) 08.04.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


val = get(handles.roiTypePopup,'Value');

set(handles.roiManualCheck, 'visible','on');
set(handles.manuallyROIText1, 'visible', 'on');
set(handles.manuallyROIText2, 'visible', 'on');
set(handles.roiWidthTxt, 'visible', 'on');
set(handles.roiHeightTxt, 'visible', 'on');
set(handles.roiX1Edit, 'visible', 'on');
set(handles.roiY1Edit, 'visible', 'on');
set(handles.roiWidthEdit, 'visible', 'on');
set(handles.roiHeightEdit, 'visible', 'on');


if val == 1 || val == 2 % rectangle or ellipse
    set(handles.manuallyROIText2,'String','Y1:');
    if get(handles.roiManualCheck, 'value')
        set(handles.roiY1Edit,'Enable','on');
    else
        set(handles.roiY1Edit,'Enable','off');
    end
elseif val == 3 % polyline
    set(handles.manuallyROIText2,'String','Number of vertices:');
    set(handles.roiY1Edit,'String','5');
    set(handles.roiY1Edit,'Enable','on');
    set(handles.roiManualCheck, 'visible','off');
    set(handles.manuallyROIText1, 'visible', 'off');
    set(handles.manuallyROIText2, 'visible', 'on');
    set(handles.roiWidthTxt, 'visible', 'off');
    set(handles.roiHeightTxt, 'visible', 'off');
    set(handles.roiX1Edit, 'visible', 'off');
    set(handles.roiY1Edit, 'visible', 'on');
    set(handles.roiWidthEdit, 'visible', 'off');
    set(handles.roiHeightEdit, 'visible', 'off');
elseif val == 4 % freehand
    set(handles.roiManualCheck, 'visible','off');
    set(handles.manuallyROIText1, 'visible', 'off');
    set(handles.manuallyROIText2, 'visible', 'off');
    set(handles.roiWidthTxt, 'visible', 'off');
    set(handles.roiHeightTxt, 'visible', 'off');
    set(handles.roiX1Edit, 'visible', 'off');
    set(handles.roiY1Edit, 'visible', 'off');
    set(handles.roiWidthEdit, 'visible', 'off');
    set(handles.roiHeightEdit, 'visible', 'off');
end
end