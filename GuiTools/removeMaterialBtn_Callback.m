function removeMaterialBtn_Callback(hObject, eventdata, handles)
% function removeMaterialBtn_Callback(hObject, eventdata, handles)
% a callback to the handles.removeMaterialBt, removes selected material from the model
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
% 07.09.2015, IB updated to use imageData.getData3D methods

% Remove material from the model
unFocus(hObject);   % remove focus from hObject
list = cellstr(get(handles.segmSelList,'String'));
list = list(2:end); % trim the list to remove the 1st element ('All')
value = get(handles.segmSelList,'Value')-1;
number = numel(list);
if value < 2; return; end;

msg = sprintf('You are going to delete material "%s"\nwhich has a number: %d\n\nAre you sure?',handles.Img{handles.Id}.I.modelMaterialNames{value-1},value-1);
button =  questdlg(msg,'Delete contour?','Yes','Cancel','Cancel');
if strcmp(button, 'Cancel') == 1; return; end;

options.blockModeSwitch=0;
model = handles.Img{handles.Id}.I.getData3D('model',NaN, 4, NaN, options);

model(model==value-1) = 0;
model(model>value-1) = model(model>value-1) - 1;
handles.Img{handles.Id}.I.modelMaterialColors(value-1,:) = [];  % remove color of the removed material
handles.Img{handles.Id}.I.setData3D('model', model, NaN, 4, NaN, options);
modelMaterialNames = handles.Img{handles.Id}.I.modelMaterialNames;
index = 1;
handles.Img{handles.Id}.I.modelMaterialNames = {};
for i=1:numel(modelMaterialNames)
    if i ~= value-1
        handles.Img{handles.Id}.I.modelMaterialNames(index,1) = modelMaterialNames(i);
        index = index + 1;
    end
end
updateSegmentationLists(handles);
handles.lastSegmSelection = 1;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end