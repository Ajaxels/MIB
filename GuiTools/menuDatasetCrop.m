function menuDatasetCrop(hObject, eventdata, handles)
% function menuDatasetCrop(hObject, eventdata, handles)
% a callback to Menu->Dataset->Crop dataset...
% starts the Crop dialog
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


handles = ib_cropGui(handles);
if ~isstruct(handles); return; end;

handles = updateGuiWidgets(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
end