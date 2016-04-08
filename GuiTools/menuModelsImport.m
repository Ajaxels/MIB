function menuModelsImport(hObject, eventdata, handles)
% function menuModelsImport(~, eventdata, handles)
% a callback to Menu->Models->Import
% imports the Model layer from the main Matlab workspace
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
% 02.02.2016, Ilya Belevich, updated for 4D datasets, modified to use loadModelBtn_Callback

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes');
    warndlg(sprintf('The model layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The models are disabled','modal');
    return;
end;

prompt = sprintf('Enter the name of the model variable.\nIt may be a matrix (1:height,1:width,1:z,1:t)\nor a structure with "model" and "materials" fields');
title = 'Import from Matlab';
%answer = inputdlg(prompt,title,1,{'O'},'on');
answer = mib_inputdlg(NaN,prompt,title,'O');
if size(answer) == 0; return; end;

if (~isempty(answer{1}))
    try
        varIn = evalin('base',answer{1});
    catch exception
        errordlg(sprintf('The variable was not found in the Matlab base workspace:\n\n%s', exception.message),'Misssing variable!','modal');
        return;
    end
    
    options = struct();
    if isstruct(varIn)
        model = varIn.model;
        if isfield(varIn, 'materials'); options.material_list = varIn.materials; end;
        if isfield(varIn, 'colors');
            %material_colors = varIn.colors;
            options.color_list = varIn.colors;
        end;
    else
        model = varIn;
    end
    loadModelBtn_Callback(hObject, eventdata, handles, model, options);
end
