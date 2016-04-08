function selectionErBtn_Callback(hObject, eventdata, handles, sel_switch)
% function selectionErBtn_Callback(~, ~, handles,sel_switch)
% a callback to the handles.selectionErBtn, shrinks the selection layer
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% sel_switch: [@em optional] a string that defines where erosion should be done:
% @li when @b '2D' fill holes for the currently shown slice
% @li when @b '3D' fill holes for the currently shown z-stack
% @li when @b '4D' fill holes for the whole dataset

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 29.01.2016, changed sel_switch parameters from 'current'->'2D', 'all'->'3D', added '4D'

if nargin < 4
    modifier = get(handles.im_browser,'currentModifier');
    if sum(ismember({'alt','shift'}, modifier)) == 2
        sel_switch = '4D';
    elseif sum(ismember({'alt','shift'}, modifier)) == 1
        sel_switch = '3D';
    else
        sel_switch = '2D';
    end
end
% Erode the selection layer
handles = ib_erodeSelection(handles, sel_switch);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end