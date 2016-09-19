function menuFileMakeMovie(hObject, eventdata, handles)
% function menuFileMakeMovie(hObject, eventdata, handles)
% a callback to Menu->File->Make movie, renders a movie file.
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


if isfield(handles, 'video_fn')
    fn_out = handles.video_fn;
else
    fn_out = fullfile(handles.mypath, 'video.avi');
end
result = ib_saveVideoGui(handles, fn_out);
if ~isnan(result)
    handles.video_fn = result;
    [~,fn,fnExt] = fileparts(handles.video_fn);
    update_filelist(handles, [fn, fnExt]);
end;
guidata(handles.im_browser, handles);
end