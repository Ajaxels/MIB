function roiShowCheck_Callback(~, ~, handles)
% function roiShowCheck_Callback(~, ~, handles)
% toggle show/hide state of ROIs, as callback of handles.roiShowCheck
%
% Parameters:
% handles: structure with handles of im_browser.m

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.04.2015, Ilya Belevich, ilya.belevich @ helsinki.fi

if numel(get(handles.roiList,'String')) == 1;
    set(handles.roiShowCheck, 'value', 0);
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    return;
end
val = get(handles.roiShowCheck,'Value');

if val == 1
    set(handles.toolbarShowROISwitch,'State','on');
else
    set(handles.toolbarShowROISwitch,'State','off');
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end