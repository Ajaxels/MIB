function toolbarInterpolation(hObject, eventdata, handles, options)
% function toolbarInterpolation(hObject, eventdata, handles, options)
% Function to set the state of the interpolation button in the toolbar.
%
% When the ''options'' variable is omitted the function works as a standard
% callback and changes the type of interpolation: ''shape'' or ''line''.
% However, when ''options'' are specified the function sets the state of
% the button to the currently selected type.
%
% Parameters:
% hObject: a handle of the button, handles.toolbarInterpolation
% eventdata: eventdata, may be empty - '' ''
% handles: handles structure of im_browser.m
% options: [@em optional], 
% @li when @b ''keepcurrent'' set the state of the button to the currently
% selected type of the interpolation.
%
% Return values:
% 

%| @b Examples:
% @code toolbarInterpolation(handles.toolbarInterpolation, '', handles, 'keepcurrent');     // update the interpolation button icon @endcode
% @code toolbarInterpolation(handles.toolbarInterpolation, '', handles); // a callback to the button press @endcode

% Copyright (C) 27.02.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if nargin == 4  % when options are available
    if strcmp(options, 'keepcurrent')
        0;
    end
else
    if strcmp(handles.preferences.interpolationType, 'shape')
        handles.preferences.interpolationType = 'line';
    else
        handles.preferences.interpolationType = 'shape';
    end
end
if strcmp(handles.preferences.interpolationType, 'line')
    filename = 'line_interpolation.res';
    set(handles.toolbarInterpolation, 'TooltipString', 'Use LINE interpolation');
    set(handles.menuSelectionInterpolate, 'label', 'Interpolate as Line (I)');
else
    filename = 'shape_interpolation.res';
    set(handles.toolbarInterpolation, 'TooltipString', 'Use SHAPE interpolation');
    set(handles.menuSelectionInterpolate, 'label', 'Interpolate as Shape (I)');
end

img = load(fullfile(handles.pathMIB, 'Resources', filename), '-mat');  % load icon
set(handles.toolbarInterpolation,'CData', img.image);
guidata(handles.im_browser, handles);
end
