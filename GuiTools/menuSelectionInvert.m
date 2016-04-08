function menuSelectionInvert(hObject, eventdata, handles)
% function menuSelectionInvert(hObject, eventdata, handles)
% a callback for Menu->Selection->Invert
% invert selection layer
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles of im_browser.m

% Copyright (C) 27.08.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
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

ib_do_backup(handles, 'selection', 1);
if ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
    selection = ib_getDataset('selection', handles);
    for roi=1:numel(selection)
        selection{roi} = 1 - selection{roi};
    end
    ib_setDataset('selection', selection, handles);
else
    selection = ib_getDataset('everything', handles);
    for roi=1:numel(selection)
        selection{roi} = bitxor(selection{roi},128);
    end
    ib_setDataset('everything', selection, handles);
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end