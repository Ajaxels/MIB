function menuToolsMeasure(hObject, eventdata, handles, type)
% function menuToolsMeasure(hObject, eventdata, handles, type)
% a callback to Menu->Tools->Measure length
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% type: a string that defines a type of measurements
% - 'line', a straight line
% - 'freehand', a curved line
% - 'tool', starts a Measure Tool

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% measure the distances

switch type
    case 'tool'
        mib_measureTool(handles);
        return;
    case 'line'
        ib_do_backup(handles, 'selection', 0);
        set(handles.im_browser, 'windowbuttondownfcn', '');
        roi = imline(handles.imageAxes);
    case 'freehand'
        ib_do_backup(handles, 'selection', 0);
        set(handles.im_browser, 'windowbuttondownfcn', '');
        roi = imfreehand(handles.imageAxes,'Closed','false');
end
resume(roi);
pos = roi.getPosition();
pos(:,1) = pos(:,1)*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesX(1))]);
pos(:,2) = pos(:,2)*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesY(1))]);
delete(roi);
guidata(hObject, handles);
set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});

helpSubString ='';
if strcmp(handles.preferences.disableSelection, 'no'); 
    img = handles.Img{handles.Id}.I.getCurrentSlice('selection');
    img = ib_connectPoints(img, pos);
    handles.Img{handles.Id}.I.setCurrentSlice('selection', img);
    %handles.Img{handles.Id}.I.setCurrentSlice('selection', handles.Img{handles.Id}.I.getCurrentSlice('selection') | selected_mask);
    helpSubString = 'Use the "C"-key shortcut to clear the measured path';
end

if handles.Img{handles.Id}.I.orientation == 4   % xy plane
    x = handles.Img{handles.Id}.I.pixSize.x;
    y = handles.Img{handles.Id}.I.pixSize.y;
elseif handles.Img{handles.Id}.I.orientation == 1   % xz plane
    x = handles.Img{handles.Id}.I.pixSize.z;
    y = handles.Img{handles.Id}.I.pixSize.x;
elseif handles.Img{handles.Id}.I.orientation == 2   % yz plane
    x = handles.Img{handles.Id}.I.pixSize.z;
    y = handles.Img{handles.Id}.I.pixSize.y;
end
distance = 0;
for i=2:size(pos,1)
    distance = distance + sqrt(((pos(i,1)-pos(i-1,1))*x)^2 + ((pos(i,2)-pos(i-1,2))*y)^2);
end
str2 = ['Distance = ' num2str(distance) ' ' handles.Img{handles.Id}.I.pixSize.units];
msgbox(sprintf('%s\n%s', str2, helpSubString), 'Measure...', 'help');
disp(str2);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end