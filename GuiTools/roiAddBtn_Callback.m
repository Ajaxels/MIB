function roiAddBtn_Callback(hObject, eventdata, handles)
% function roiAddBtn_Callback(hObject, eventdata, handles)
% a callback to the handles.roiAddBtn, adds a roi to a dataset
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



type = get(handles.roiTypePopup,'Value');
x1 = str2double(get(handles.roiX1Edit,'String'));
y1 = str2double(get(handles.roiY1Edit,'String'));
width = str2double(get(handles.roiWidthEdit,'String'));
height = str2double(get(handles.roiHeightEdit,'String'));
selected_pos = get(handles.roiList,'Value');
set(handles.roiShowCheck, 'value',1);
disableSelectionSwitch = handles.preferences.disableSelection;    % get current settings
handles.preferences.disableSelection = 'yes'; % disable selection
guidata(handles.im_browser, handles);   % store handles
switch type
    case 1  % rectangle
        if get(handles.roiManualCheck, 'value')     % use entered values
            handles.Img{handles.Id}.I.hROI.addROI(handles, 'imrect', [], [x1 y1 width height]);
        else % place ROI interactively
            handles.Img{handles.Id}.I.hROI.addROI(handles, 'imrect');
        end
    case 2  % ellipse
        if get(handles.roiManualCheck, 'value')     % use entered values
            handles.Img{handles.Id}.I.hROI.addROI(handles,'imellipse', [], [x1 y1 width height]);
        else % place ROI interactively
            handles.Img{handles.Id}.I.hROI.addROI(handles,'imellipse');
        end
    case 3  % polyline
        noPoints = str2double(get(handles.roiY1Edit,'string'));
        handles.Img{handles.Id}.I.hROI.addROI(handles, 'impoly', [], [], noPoints);
    case 4  % imfreehand
        handles.Img{handles.Id}.I.hROI.addROI(handles, 'imfreehand');
end
% restore selected state for the selection
handles.preferences.disableSelection = disableSelectionSwitch;
set(handles.roiShowCheck,'Value',1);

% get number of ROIs
[number, indices] = handles.Img{handles.Id}.I.hROI.getNumberOfROI();
str2 = cell([number+1 1]);
str2(1) = cellstr('All');
for i=1:number
%    str2(i+1) = cellstr(num2str(indices(i)));
    str2(i+1) = handles.Img{handles.Id}.I.hROI.Data(indices(i)).label;
end

set(handles.roiList,'String',str2);
if selected_pos ~= 1
    set(handles.roiList,'Value',numel(str2));
end

roiShowCheck_Callback(handles.roiShowCheck, eventdata, handles);
guidata(handles.im_browser,handles);
end