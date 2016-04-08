function menuSelectionInterpolate(hObject, eventdata, handles)
% function menuSelectionInterpolate(hObject, eventdata, handles)
% a callback to the Menu->Selection->Interpolate;
% interpolates shapes of the selection layer
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
% 04.09.2015, adapted to use imageData.getData3D method

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); 
    warndlg(sprintf('The selection layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The selection layer is disabled','modal');
    return; 
end;

ib_do_backup(handles, 'selection', 1);
selection = handles.Img{handles.Id}.I.getData3D('selection');

wb = waitbar(0,'Please wait...','Name','Interpolating...','WindowStyle','modal');
if strcmp(handles.preferences.interpolationType,'shape')    % shape interpolation
    selection = ib_interpolateShapes(selection, handles.preferences.interpolationNoPoints);
else    % line interpolation
    selection = ib_interpolateLines(selection, handles.preferences.interpolationNoPoints, handles.preferences.interpolationLineWidth);
end

handles.Img{handles.Id}.I.setData3D('selection',selection);
waitbar(1,wb);
delete(wb);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end