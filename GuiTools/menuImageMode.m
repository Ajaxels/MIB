function menuImageMode(hObject, eventdata, handles)
% function menuImageMode(hObject,eventdata,handles)
% a callback to the Menu->Image->Mode, convert image to different formats
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

if handles.Img{handles.Id}.I.time < 2; ib_do_backup(handles, 'image', 1); end;

switch get(hObject,'tag')
    case 'menuImageGrayscale'
        [handles, ~] = handles.Img{handles.Id}.I.convertImage('grayscale', handles);
    case 'menuImageRGBColor'
        [handles, ~] = handles.Img{handles.Id}.I.convertImage('truecolor',handles);
    case 'menuImageHSVColor'
        [handles, ~] = handles.Img{handles.Id}.I.convertImage('hsvcolor',handles);        
    case 'menuImageIndexed'
        [handles, ~] = handles.Img{handles.Id}.I.convertImage('indexed',handles);
    case 'menuImage8bit'
        [handles, ~] = handles.Img{handles.Id}.I.convertImage('uint8',handles);
    case 'menuImage16bit'
        [handles, ~] = handles.Img{handles.Id}.I.convertImage('uint16',handles);
    case 'menuImage32bit'
        [handles, ~] = handles.Img{handles.Id}.I.convertImage('uint32',handles);
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end