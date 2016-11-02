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
% 25.10.2016, IB, updated for segmentation table

% Remove material from the model
unFocus(hObject);   % remove focus from hObject

userData = get(handles.segmTable,'UserData');
if userData.prevMaterial < 3; return; end;  % can't delete Mask/Exterior

modelMaterialNames = handles.Img{handles.Id}.I.modelMaterialNames;    % list of materials of the model
value = userData.prevMaterial - 2;

msg = sprintf('You are going to delete material "%s"\nwhich has a number: %d\n\nAre you sure?', modelMaterialNames{value}, value);
button =  questdlg(msg,'Delete contour?','Yes','Cancel','Cancel');
if strcmp(button, 'Cancel') == 1; return; end;

options.blockModeSwitch=0;
model = handles.Img{handles.Id}.I.getData3D('model',NaN, 4, NaN, options);

model(model==value) = 0;
model(model>value) = model(model>value) - 1;
handles.Img{handles.Id}.I.modelMaterialColors(value,:) = [];  % remove color of the removed material
handles.Img{handles.Id}.I.setData3D('model', model, NaN, 4, NaN, options);

index = 1;
handles.Img{handles.Id}.I.modelMaterialNames = {};
for i=1:numel(modelMaterialNames)
    if i ~= value
        handles.Img{handles.Id}.I.modelMaterialNames(index,1) = modelMaterialNames(i);
        index = index + 1;
    end
end
updateSegmentationTable(handles);
handles.lastSegmSelection = 1;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end