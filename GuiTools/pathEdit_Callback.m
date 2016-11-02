function pathEdit_Callback(hObject, eventdata, handles)
% function pathEdit_Callback(hObject, eventdata, handles)
% Callback for selection of directory using an edit box in the Path panel of MIB
%

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


path = get(handles.pathEdit,'String');
if isdir(path)
    handles.mypath = path;
    set(handles.pathEdit,'String',path);
    update_filelist(handles);
    drives = get(handles.drivePopup,'String');
    if ischar(class(drives(1))); drives = cellstr(drives); end;
    if ispc()
        for i = 1:numel(drives)
            if strcmpi(cell2mat(drives(i)),path(1:2))
                set(handles.drivePopup,'Value',i);
                return;
            end
        end
    end
else
    set(handles.pathEdit,'String',handles.mypath);
end
guidata(handles.im_browser, handles);
end