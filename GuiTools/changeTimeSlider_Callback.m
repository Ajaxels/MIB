function changeTimeSlider_Callback(hObject, eventdata, handles)
% function changeTimeSlider_Callback(~, eventdata, handles)
% A callback function for handles.changeTimeSlider. Responsible for showing next or previous time point of the dataset
%
% Parameters:
% hObject: a handle to the calling object
% eventdata: eventdata structure of Matlab
% handles: handles structure of im_browser.m

% Copyright (C) 20.01.2016, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% update handles, needed for slider listener, initialized in im_browser_getDefaultParameters() 
handles = guidata(hObject);

value = get(handles.changeTimeSlider,'Value');
value_str = sprintf('%.0f',value);
set(handles.changeTimeEdit,'String',value_str);
value = str2double(value_str);

handles.Img{handles.Id}.I.slices{5} = [value, value];
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
%unFocus(hObject);   % remove focus from hObject
end