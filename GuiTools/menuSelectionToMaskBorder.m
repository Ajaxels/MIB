function menuSelectionToMaskBorder(hObject, eventdata, handles)
% function menuSelectionToMaskBorder(hObject, eventdata, handles)
% a callback to Menu->Selection->Expand to Mask border
% expand selection to borders of the Masked layer
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
% 26.02.2016, IB updated for 4D datasets


% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); 
    warndlg(sprintf('The selection layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The selection layer is disabled','modal');
    return; 
end;

if handles.Img{handles.Id}.I.time == 1
    ib_do_backup(handles, 'selection', 1);
end
wb = waitbar(0, 'Expanding Selection to fit 3D Mask...','WindowStyle','modal');
tic;

for t=1:handles.Img{handles.Id}.I.time
    getDataOptions.blockModeSwitch = 0; % do for the full dataset
    selection = handles.Img{handles.Id}.I.getData3D('selection', t, 4, 0, getDataOptions);
    CC1 = bwconncomp(selection, 26);    % get objects from the selection layer.
    CC2 = bwconncomp(handles.Img{handles.Id}.I.getData3D('mask', t, 4, 0, getDataOptions),26);    % get objects from the mask layer.
    CC2_objects = 1:CC2.NumObjects; % vector that have indices of all mask objects
    handles.Img{handles.Id}.I.clearSelection(NaN, NaN, NaN, t);
    selection = zeros(size(selection), 'uint8');
    
    waitbar_step = round(CC1.NumObjects/10);
    
    for selObj = 1:CC1.NumObjects
        if mod(selObj, waitbar_step)==0; waitbar(selObj/CC1.NumObjects,wb); end;
        pixel_id = CC1.PixelIdxList{selObj}(1); % one index from each selection objects
        %[y,x,z] = ind2sub(size(handles.Img{handles.Id}.I.selection),pixel_id);
        for id = CC2_objects
            if ~isempty(find(CC2.PixelIdxList{id}==pixel_id)) %#ok<EFIND>
                CC2_objects = CC2_objects(CC2_objects ~= selObj);
                selection(CC2.PixelIdxList{id}) = 1;
            end
        end
    end
    handles.Img{handles.Id}.I.setData3D('selection', selection, t, 4, 0, getDataOptions);
    waitbar(t/handles.Img{handles.Id}.I.time, wb);
end
delete(wb);
toc;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
