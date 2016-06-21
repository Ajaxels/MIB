function menuModelsExport(hObject, eventdata, handles, parameter)
% function menuModelsExport(~, eventdata, handles, parameter)
% a callback to Menu->Models->Export
% export the Model layer to the main Matlab workspace
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% parameter: destination for the export: 'matlab', 'imaris'

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 04.09.2015, Ilya Belevich, updated to getData3D method
% 01.02.2016, IB, updated for 4D

if strcmp(parameter, 'matlab')
    prompt = {'Variable for the structure to keep the model:'};
    title = 'Input a destination variable for export';
    answer = mib_inputdlg(handles, prompt,title,'O');
    if size(answer) == 0; return; end;
    options.blockModeSwitch = 0;
    O.model = handles.Img{handles.Id}.I.getData4D('model', 4, NaN, options);

    O.materials = handles.Img{handles.Id}.I.modelMaterialNames;
    O.colors = handles.Img{handles.Id}.I.modelMaterialColors;

    if handles.Img{handles.Id}.I.hLabels.getLabelsNumber() > 1  % save annotations
        [O.labelText, O.labelPosition] = handles.Img{handles.Id}.I.hLabels.getLabels(); %#ok<NASGU,ASGLU>
    end
    
    assignin('base',answer{1},O);
    disp(['Model export: created structure ' answer{1} ' in the Matlab workspace']);
else
    options.type = 'model';
    if get(handles.seeAllMaterialsCheck, 'value') == 0
        options.modelIndex = get(handles.segmList, 'value');
    else
        options.modelIndex = NaN;   % render all materials
    end
    
    handles = ib_setImarisDataset(handles, options);
    guidata(handles.im_browser, handles);
end
end