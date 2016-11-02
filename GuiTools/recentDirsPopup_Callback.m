function recentDirsPopup_Callback(hObject, eventdata, handles)
% function recentDirsPopup_Callback(hObject, eventdata, handles)
% Callback for selection of directory in the recentDirs popup menu in the Path panel of MIB
%

% Copyright (C) 07.10.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

listStr = get(handles.recentDirsPopup, 'String');
if isempty(listStr); return; end;
val = get(handles.recentDirsPopup, 'Value');
selectedDir = listStr{val};
set(handles.pathEdit, 'String', selectedDir);
pathEdit_Callback(handles.pathEdit, eventdata, handles);
end