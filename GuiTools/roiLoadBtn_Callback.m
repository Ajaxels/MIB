function roiLoadBtn_Callback(hObject, eventdata, handles)
% function roiLoadBtn_Callback(hObject, eventdata, handles)
% a callback to the handles.roiLoadBtn, loads roi from a file to MIB
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



% load ROI from a file
if isempty(handles.Img{handles.Id}.I.img_info('Filename'))
    path = get(handles.pathEdit,'String');
else
    path = fileparts(handles.Img{handles.Id}.I.img_info('Filename'));
end
[filename, path] = uigetfile(...
    {'*.roi',  'Area shape, Matlab format (*.roi)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Open ROI shape file...',path);
if isequal(filename,0); return; end; % check for cancel

res = load(fullfile(path, filename),'-mat');
handles.Img{handles.Id}.I.hROI.Data = res.Data;
set(handles.roiShowCheck,'Value',1);
set(handles.roiList,'value',1);

% get number of ROIs
[number, indices] = handles.Img{handles.Id}.I.hROI.getNumberOfROI();
str2 = cell([number+1 1]);
str2(1) = cellstr('All');
for i=1:number
%    str2(i+1) = cellstr(num2str(indices(i)));
    str2(i+1) = handles.Img{handles.Id}.I.hROI.Data(indices(i)).label;
end
set(handles.roiList,'String',str2);
roiShowCheck_Callback(handles.roiShowCheck, eventdata, handles);
fprintf('MIB: loading ROI from %s -> done!\n', fullfile(path, filename));
end