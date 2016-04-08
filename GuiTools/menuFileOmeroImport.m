function menuFileOmeroImport(hObject, eventdata, handles)
% function menuFileOmeroImport_Callback(hObject, eventdata, handles)
% a callback to Menu->File->OMERO Import, imports data from OMERO server.
%
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
% 2014-10-06, added import from URL

result = ib_importOmero(handles);
if isstruct(result)
    handles = result;
else
    return;
end;
guidata(handles.im_browser, handles);
handles.Img{handles.Id}.I.clearSelection();     % will not resample selection
handles.Img{handles.Id}.I.clearMask();          % will not resample mask
handles = updateGuiWidgets(handles);
handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
end