function menuImageColorCh(hObject, eventdata, handles, parameter)
% function menuImageColorCh(hObject, eventdata, handles, parameter)
% a callback to Menu->Image->Color Channels
% do actions with individual color channels
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% parameter: a string that defines image source:
% - 'insert', insert an empty color channel to the specified position
% - 'copy', copy color channel to a new position
% - 'invert', invert color channel
% - 'rotate', rotate color channel
% - 'swap', swap two color channels
% - 'delete', delete color channel from the dataset

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 04.02.2016, IB, added insert empty color channel option

switch parameter
    case 'insert'
        handles.Img{handles.Id}.I.insertEmptyColorChannel();
        handles = updateGuiWidgets(handles);
    case 'copy'
        handles.Img{handles.Id}.I.copyColorChannel();
        handles = updateGuiWidgets(handles);
    case 'invert'
        if handles.Img{handles.Id}.I.time < 2; ib_do_backup(handles, 'image', 1); end;
        handles.Img{handles.Id}.I.invertColorChannel();
    case 'rotate'
        if handles.Img{handles.Id}.I.time < 2; ib_do_backup(handles, 'image', 1); end;
        handles.Img{handles.Id}.I.rotateColorChannel();        
    case 'swap'
        if handles.Img{handles.Id}.I.time < 2; ib_do_backup(handles, 'image', 1); end;
        handles.Img{handles.Id}.I.swapColorChannels();
    case 'delete'
        handles.Img{handles.Id}.I.deleteColorChannel();
        handles = updateGuiWidgets(handles);
end    
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
end