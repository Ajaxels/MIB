% --- Executes on button press in maskShowCheck.
function maskShowCheck_Callback(hObject, eventdata, handles)
% function maskShowCheck_Callback(hObject, eventdata, handles)
% a callback to the handles.maskShowCheck, allows to toggle visualization of the mask layer
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



if handles.Img{handles.Id}.I.maskExist == 0; % isnan(handles.Img{handles.Id}.I.maskImg(1,1,1)) | handles.Img{handles.Id}.I.maskImg(1,1,1)=='';  %#ok<OR2>
    set(handles.maskShowCheck,'Value',0);
    return;
end;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end