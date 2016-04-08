function changelayerEdit_Callback(~, eventdata, handles)
% function changelayerEdit_Callback(~, eventdata, handles)
% A callback for changing the slices of the 3D dataset by entering the new slice number
% 
% Parameters:
% eventdata: event data structure of Matlab
% handles: handles structure of im_browser.m

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


val = str2double(get(handles.changelayerEdit,'String'));
status = editbox_Callback(handles.changelayerEdit,eventdata,handles,'pint',1,[1 size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation)]);
if status == 0; return; end;
set(handles.changelayerSlider,'Value',val);
changelayerSlider_Callback(handles.changelayerSlider, eventdata, handles);
end