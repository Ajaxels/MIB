function saveModelToolbar_ClickedCallback(hObject, eventdata, handles)
% function saveModelToolbar_ClickedCallback(hObject, eventdata, handles)
% a callback to the handles.saveModelToolbar, saves the model in the matlab
% format to the specified file
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
% 01.02.2016, IB updated for 4D data

% Save model using the Toolbar button
if handles.Img{handles.Id}.I.modelExist == 0 || strcmp(handles.Img{handles.Id}.I.model_type, 'int8'); disp('Cancelled: Can save only segmentation model'); return; end;
%warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');    % switch off warnings for latex
curInt = get(0, 'DefaulttextInterpreter'); 
set(0, 'DefaulttextInterpreter', 'none');

wb = waitbar(0,sprintf('%s\nPlease wait...',handles.Img{handles.Id}.I.model_fn),'Name','Saving the model','WindowStyle','modal');
set(findall(wb,'type','text'),'Interpreter','none');
waitbar(0, wb);
fn_out = handles.Img{handles.Id}.I.model_fn;
%model = permute(handles.Img{handles.Id}.I.model,[2 1 3]); %#ok<NASGU>
% str1 = strcat(handles.Img{handles.Id}.I.model_var, '=model;');
% eval(str1);
% str1 = ['save ''' fn_out ''' ' handles.Img{handles.Id}.I.model_var ' -double'];
% eval(str1);

if strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
    options.blockModeSwitch=0; %#ok<STRNU>
    str1 = strcat(handles.Img{handles.Id}.I.model_var, '=handles.Img{handles.Id}.I.getData4D(''model'', 4, NaN, options);');
else
    str1 = strcat(handles.Img{handles.Id}.I.model_var, '=handles.Img{handles.Id}.I.model;');
end
eval(str1);    
material_list = handles.Img{handles.Id}.I.modelMaterialNames; %#ok<NASGU>
color_list = handles.Img{handles.Id}.I.modelMaterialColors; %#ok<NASGU>
bounding_box = handles.Img{handles.Id}.I.getBoundingBox(); %#ok<NASGU>
model_var = handles.Img{handles.Id}.I.model_var; %#ok<NASGU>
if handles.Img{handles.Id}.I.hLabels.getLabelsNumber() > 1  % save annotations
    [labelText, labelPosition] = handles.Img{handles.Id}.I.hLabels.getLabels(); %#ok<NASGU,ASGLU>
     str1 = ['save ''' fn_out ''' ' handles.Img{handles.Id}.I.model_var ' material_list color_list bounding_box model_var labelText labelPosition -mat -v7.3'];    
else    % save without annotations
    str1 = ['save ''' fn_out ''' ' handles.Img{handles.Id}.I.model_var ' material_list color_list bounding_box model_var -mat -v7.3'];    
end
eval(str1);
disp(['Model: ' fn_out ' has been saved']);
delete(wb);
set(0, 'DefaulttextInterpreter', curInt); 
end