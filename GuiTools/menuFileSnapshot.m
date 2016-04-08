function menuFileSnapshot(hObject, eventdata, handles)
% function menuFileSnapshot(hObject, eventdata, handles)
% a callback to Menu->File->Make snapshot, renders a snapshot of the shown area.
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
% 


if isfield(handles, 'snapshot_fn')
    fn_out = handles.snapshot_fn;
else
    fn_out = fullfile(handles.mypath, 'snapshot.tif');
end
ib_snapshotGui(handles, fn_out);
guidata(handles.im_browser, handles);
end