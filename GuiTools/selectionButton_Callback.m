function selectionButton_Callback(hObject, eventdata, handles, action)
% function selectionButton_Callback(hObject, eventdata, handles, action)
% a callback to the handles.selectionButton_Callback, allows to add, subtract or replace selection
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% action: a string that defines type of the action:
% @li when @b 'add' add selection to the active material of the model or to the Mask layer
% @li when @b 'subtract' subtract selection from the active material of the model or from the Mask layer
% @li when @b 'replace' replace the active material of the model or the Mask layer with selection

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 29.01.2016, IB, updated for 4D, taken away from im_browser.m to a separate file

if get(handles.segmAddList,'Value') == 1    % Selection to Model
    layerTo = 'mask';
else    % Selection to Mask
    layerTo = 'model';
end

modifier = get(handles.im_browser,'currentModifier');
if sum(ismember({'alt','shift'}, modifier)) == 2
    sel_switch = '4D';
elseif sum(ismember({'alt','shift'}, modifier)) == 1
    sel_switch = '3D';
else
    sel_switch = '2D';
end

switch action
    case 'add'
        ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',layerTo,sel_switch, 'add');
    case 'subtract'
        ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',layerTo,sel_switch, 'remove');
    case 'replace'
        ib_moveLayers(handles.imageAxes, NaN, NaN, 'selection',layerTo,sel_switch, 'replace');
end
end