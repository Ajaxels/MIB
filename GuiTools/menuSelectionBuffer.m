function menuSelectionBuffer(hObject, eventdata, handles, parameter)
% function menuSelectionBuffer(hObject, eventdata, handles, parameter)
% a callback to Menu->Selection to Buffer...
% Copy/Paste/Clear of the selection of the shown layer
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure
% handles: structure with handles of im_browser.m
% parameter: a string that defines image source:
% - ''copy'', store the selection from the current layer to a buffer
% - ''paste'', paste the selection from the buffer to the current layer
% - ''clear'', clear selection buffer

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
if strcmp(handles.preferences.disableSelection, 'yes'); return; end;

switch parameter
    case 'copy'
        handles.Img{handles.Id}.I.storedSelection = handles.Img{handles.Id}.I.getFullSlice('selection');
    case 'paste'
        if isnan(handles.Img{handles.Id}.I.storedSelection);
            msgbox(sprintf('Error!\nThe buffer is empty!'),'Error!','error','modal');
            return;
        end;
        currSelection = handles.Img{handles.Id}.I.getFullSlice('selection');
        if min(size(currSelection) == size(handles.Img{handles.Id}.I.storedSelection)) == 1
            ib_do_backup(handles, 'selection', 0);
            handles.Img{handles.Id}.I.setFullSlice('selection', bitor(handles.Img{handles.Id}.I.storedSelection, currSelection));
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        else
            msgbox(sprintf('Error!\nThe size of the buffered and current selections mismatch!\nTry to change the orientation of the dataset...'),'Error!','error','modal');
        end
    case 'clear'
        handles.Img{handles.Id}.I.storedSelection = NaN;
end
guidata(handles.im_browser, handles);
end