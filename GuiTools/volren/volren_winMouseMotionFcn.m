function volren_winMouseMotionFcn(hObject, ~, handles)
% function volren_winMouseMotionFcn(hObject, ~, handles)
% change cursor shape when cursor is inside the axis
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% handles: structure with handles of im_browser.m

% Copyright (C) 26.04.2016, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

position=get(handles.imageAxes,'currentpoint');
axXLim=get(handles.imageAxes,'xlim');
axYLim=get(handles.imageAxes,'ylim');

x = round(position(1,1));
y = round(position(1,2));

if x>axXLim(1) && x<axXLim(2) && y>axYLim(1) && y<axYLim(2) % mouse pointer within the current axes
    set(hObject,'Pointer','crosshair');
else
    set(handles.im_browser,'Pointer','arrow');
end
end