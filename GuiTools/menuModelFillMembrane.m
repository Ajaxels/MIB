function menuModelFillMembrane(hObject, eventdata, handles)
% function menuModelFillMembrane(hObject, eventdata, handles)
% a callback to Menu->Model->FillMembrane
% an experimental function to extend membranes such that the membranes are connected between the slices and holes are eliminated
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
% 25.10.2016, IB, updated for segmentation table


if handles.Img{handles.Id}.I.orientation ~= 4;
    msgbox('Please rotate the dataset to the XY orientation!','Error!','error','modal');
    return;
end
userData = get(handles.segmTable,'UserData');
selected = userData.prevMaterial-2;
if selected < 1
    msgbox('Please select a material!','Error!','error','modal');
    return;
end;
%answer = inputdlg('Please enter overlapping value [0-]:','Remove holes parameters',1,{'1'});
answer = mib_inputdlg(handles, 'Please enter overlapping value [0-]:','Remove holes parameters','1');
if size(answer)==0; return; end;
ib_do_backup(handles, 'model', 1);
overlap = str2double(answer{1});
wb = waitbar(0,'Filling membrane holes...','Name','Filling','WindowStyle','modal');
handles.Img{handles.Id}.I.model = ib_fillMembranes(handles.Img{handles.Id}.I.model, selected, overlap);
waitbar(1,wb);
delete(wb);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end