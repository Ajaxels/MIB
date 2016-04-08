function menuDatasetBoundingBox(hObject, eventdata, handles)
% function menuDatasetBoundingBox(hObject, eventdata, handles)
% a callback to Menu->Dataset->Bounding Box...
% set manually the parameters for the bounding box
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


output = mib_BoundingBoxDlg(NaN,handles);
if ~isstruct(output); return; end;
handles = output;
handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
end