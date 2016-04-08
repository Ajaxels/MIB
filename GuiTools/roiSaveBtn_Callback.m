function roiSaveBtn_Callback(hObject, eventdata, handles)
% function roiSaveBtn_Callback(hObject, eventdata, handles)
% a callback to the handles.roiSaveBtn, saves roi to a file using matlab
% format
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


if handles.Img{handles.Id}.I.hROI.getNumberOfROI(0) < 1
    msg = {'Create a Region of interest first!'};
    msgbox(msg,'Warning!','warn');
    return;
end

fn_out = handles.Img{handles.Id}.I.img_info('Filename');
if isempty(fn_out)
    fn_out = handles.mypath;
end
dots = strfind(fn_out,'.');
fn_out = fn_out(1:dots(end)-1);
[filename, path] = uiputfile(...
    {'*.roi;',  'Area shape, Matlab format (*.roi)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Save roi data...',fn_out);
if isequal(filename,0); return; end; % check for cancel
fn_out = fullfile(path, filename);
Data = handles.Img{handles.Id}.I.hROI.Data;

save(fn_out, 'Data', '-mat', '-v7.3');
fprintf('MIB: saving ROI to %s -> done!\n', fn_out);
end
