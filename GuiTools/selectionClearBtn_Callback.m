% --- Executes on button press in selectionClearBtn.
function selectionClearBtn_Callback(hObject, eventdata, handles, sel_switch)
% function selectionClearBtn_Callback(hObject, eventdata, handles,sel_switch)
% a callback to the handles.selectionClearBtn, allows to clear the Selection layer
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% sel_switch: a string to define where selection should be cleared:
% @li when @b '2D' clear selection from the currently shown slice
% @li when @b '3D' clear selection from the currently shown z-stack
% @li when @b '4D' clear selection from the whole dataset

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}
% 29.01.2016, changed sel_switch parameters from 'current'->'2D', 'all'->'3D', , added '4D'

% clear the Selection layer

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); return; end;

modifier = get(handles.im_browser,'currentModifier');
if sum(ismember({'alt','shift'}, modifier)) == 2
    if handles.Img{handles.Id}.I.time == 1
        sel_switch = '3D';
    else
        sel_switch = '4D';
    end
elseif sum(ismember({'alt','shift'}, modifier)) == 1
    sel_switch = '3D';
else
    sel_switch = '2D';
end

if strcmp(sel_switch,'2D')
    ib_do_backup(handles, 'selection', 0);
    handles.Img{handles.Id}.I.clearSelection(handles.Img{handles.Id}.I.slices{1}(1):handles.Img{handles.Id}.I.slices{1}(2),...
        handles.Img{handles.Id}.I.slices{2}(1):handles.Img{handles.Id}.I.slices{2}(2),...
        handles.Img{handles.Id}.I.slices{4}(1):handles.Img{handles.Id}.I.slices{4}(2),...
        handles.Img{handles.Id}.I.slices{5}(1):handles.Img{handles.Id}.I.slices{5}(2));
elseif strcmp(sel_switch,'3D')
    ib_do_backup(handles, 'selection', 1);
    handles.Img{handles.Id}.I.clearSelection(NaN, NaN, NaN, handles.Img{handles.Id}.I.slices{5}(1));
else
    handles.Img{handles.Id}.I.clearSelection();
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end