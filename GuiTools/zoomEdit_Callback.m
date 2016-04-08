function zoomEdit_Callback(~, ~, handles)
% function zoomEdit_Callback(~, ~, handles)
% a callback function for modification of the handles.zoomEdit 
%
% Parameters:
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


zoom = get(handles.zoomEdit,'String');
newMagFactor = 100/str2double(zoom(1:end-1));
handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'zoom', newMagFactor);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end