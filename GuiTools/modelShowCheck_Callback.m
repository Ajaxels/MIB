function modelShowCheck_Callback(hObject, eventdata, handles)
% function modelShowCheck_Callback(hObject, ~, handles)
% Toggle the Model layer on/off
%
% Parameters:
% hObject: a handle to the calling object
% eventdata: eventdata structure of Matlab
% handles: handles structure of im_browser.m

% Copyright (C) 21.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if handles.Img{handles.Id}.I.modelExist == 0
    set(handles.modelShowCheck,'Value', 0);
    return;
end
handles.Img{handles.Id}.I.generateModelColors();

% move focus to the main window
set(hObject, 'Enable', 'off');
drawnow;
set(hObject, 'Enable', 'on');

handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
