function menuFileExportImage(hObject, eventdata, handles, parameter)
% function menuFileExportImage(hObject, eventdata, handles, parameter)
% a callback to the handles.menuFileExportImage, exports image and
% meta-data from MIB to the main Matlab workspace or Imaris
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure
% handles: structure with handles of im_browser.m
% parameter: [@em optional] a string that defines target for the image:
% - 'matlab', [default] main workspace of Matlab
% - 'imaris', to imaris, requires ImarisXT

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 05.11.2014, added Imaris

if nargin < 4;     parameter = 'matlab'; end;

colortype = handles.Img{handles.Id}.I.img_info('ColorType');
switch parameter
    case 'matlab'
        title = 'Input variables for export';
        lines = [1 30];
        if strcmp(colortype,'indexed')
            def = {'I','cmap'};
            prompt = {'Variable for the image:','Variable for the colormap:'};
        else
            def = {'I'};
            prompt = {'Variable for the image:'};
        end
        answer = inputdlg(prompt,title,lines,def,'on');
        if size(answer) == 0; return; end;
        assignin('base',answer{1},handles.Img{handles.Id}.I.img);
        I_info = containers.Map(keys(handles.Img{handles.Id}.I.img_info), values(handles.Img{handles.Id}.I.img_info));  % create a copy of the containers.Map
        assignin('base',[answer{1} '_info'], I_info);
        disp(['Image export: created [' answer{1} '] and [' [answer{1} '_info]'] ' variables in the Matlab workspace']);
        if size(answer,1) == 2
            assignin('base',answer{2},handles.Img{handles.Id}.I.img_info('Colormap'));
            disp(['Image export: created variable ' answer{2} ' in the Matlab workspace']);
        end
    case 'imaris'
        handles = ib_setImarisDataset(handles);
        guidata(handles.im_browser, handles);
end
end