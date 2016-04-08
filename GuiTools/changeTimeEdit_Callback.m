function changeTimeEdit_Callback(hObject, eventdata, handles)
% function changeTimeEdit_Callback(~, eventdata, handles)
% A callback for changing the time points of the dataset by entering a new time value
% 
% Parameters:
% hObject: a handle to the handles.changeTimeEdit
% eventdata: event data structure of Matlab
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

val = str2double(get(handles.changeTimeEdit,'String'));
status = editbox_Callback(handles.changeTimeEdit,eventdata,handles,'pint',1,[1 handles.Img{handles.Id}.I.time]);
if status == 0; return; end;
set(handles.changeTimeSlider,'Value',val);
changeTimeSlider_Callback(handles.changeTimeSlider, eventdata, handles);

end