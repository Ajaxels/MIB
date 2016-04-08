function menuSelectionBufferCopy_Callback(hObject, eventdata, handles)
% function menuSelectionBufferCopy_Callback(hObject, eventdata, handles)
% store the selection from the current layer to a buffer
%

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

handles.Img{handles.Id}.I.storedSelection = handles.Img{handles.Id}.I.getFullSlice('selection');
guidata(handles.im_browser, handles);
end