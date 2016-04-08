function smoothImage_Callback(hObject, eventdata, handles, type)
% function loadModelBtn_Callback(hObject, eventdata, handles)
% a callback to the smooth buttons and menus 
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% type: a type of the layer for the smoothing:
% - ''selection'' - run size exclusion on the 'Selection' layer
% - ''model'' - - run size exclusion on the 'Model' layer
% - ''mask'' - - run size exclusion on the 'Mask' layer

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); 
    warndlg(sprintf('The selection layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The selection layer is disabled','modal');
    return; 
end;

% Smooth Mask, Selection or Model layers
handles = ib_smoothImage(handles, type);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end