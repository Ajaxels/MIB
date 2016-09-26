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
% 26.09.2016, improved backup for the shape interpolation method

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); 
    warndlg(sprintf('The selection layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The selection layer is disabled','modal');
    return; 
end;
tic
selection = handles.Img{handles.Id}.I.getData3D('selection');

wb = waitbar(0,'Please wait...','Name','Interpolating...','WindowStyle','modal');
if strcmp(handles.preferences.interpolationType,'shape')    % shape interpolation
    [selection, bb] = ib_interpolateShapes(selection, handles.preferences.interpolationNoPoints);
    if isempty(bb)
        delete(wb);
        return;
    end
    storeOptions.y = [bb(3), bb(4)];
    storeOptions.x = [bb(1), bb(2)];
    storeOptions.z = [bb(5), bb(6)];
    ib_do_backup(handles, 'selection', 1, storeOptions);
else    % line interpolation
    ib_do_backup(handles, 'selection', 1);
    selection = ib_interpolateLines(selection, handles.preferences.interpolationNoPoints, handles.preferences.interpolationLineWidth);
end

handles.Img{handles.Id}.I.setData3D('selection',selection);
waitbar(1,wb);
delete(wb);
toc
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end