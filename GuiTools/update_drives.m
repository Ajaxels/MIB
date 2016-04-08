function update_drives(handles,start_path,firsttime)
% function update_drives(handles,start_path,firsttime)
% updates list of available logical disk drives
%
% Parameters:
% handles: structure with handles of im_browser.m
% start_path: a string that defines the starting letter, for example 'c:'
% for Windows, or '/' for Unix
% firsttime: a switch to define that the function is called for the
% first time

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 



% function gets available disk drives from C: to Z:
os = getenv('OS');
if strcmp(os,'Windows_NT')
    if start_path == 0, start_path = 'c:'; end;
    ret = {};
    index=1;
    
    startletter = 'a';
    for i = startletter:'z'
        if exist([i ':\'],'dir') == 7
            ret{end+1} = [i ':']; %#ok<AGROW>
            if cell2mat(ret(end)) == start_path; index = length(ret); end;
        end
    end
    set(handles.drivePopup,'String',ret);
    set(handles.drivePopup,'Value',index);
    if firsttime ~= 1
        handles.mypath=ret{index};
    end;
else        % unix system type
    start_path = '/';
    set(handles.drivePopup,'String', start_path);
    set(handles.drivePopup,'Value', 1);
end
guidata(handles.im_browser, handles);
end