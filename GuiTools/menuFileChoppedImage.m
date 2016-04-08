function menuFileChoppedImage(hObject, eventdata, handles, parameter)
% function menuFileChoppedImage(hObject, eventdata, handles, parameter)
% a callback to Menu->File->Chopped Images, imports/exports large datasets
% from/to smaller datasets
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% parameter: [@em optional] a string that defines image source:
% - 'import', import datasets from files
% - 'export', export dataset to files

% Copyright (C) 13.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


switch parameter
    case 'import'
        mib_rechopDatasetGui(handles);
    case 'export'
        mib_chopDatasetGui(handles);
end

end