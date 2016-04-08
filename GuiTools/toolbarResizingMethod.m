function toolbarResizingMethod(hObject, eventdata, handles, options)
% function toolbarResizingMethod(hObject, eventdata, handles, options)
% Function to set type of image interpolation for the visualization.
%
% When the ''options'' variable is omitted the function works as a standard
% callback and changes the type of image interpolation: ''bicubic'' or ''nearest''.
% However, when ''options'' are specified the function sets the state of
% the button to the currently selected type.
%
% Parameters:
% hObject: a handle of the button, handles. toolbarResizingMethod
% eventdata: eventdata, may be empty - '' ''
% handles: handles structure of im_browser.m
% options: [@em optional], 
% @li when @b ''keepcurrent'' set the state of the button to the currently
% selected type of the interpolation: @em handles.preferences.resize
%
% Return values:
% 

%| @b Examples:
% @code toolbarResizingMethod(handles.toolbarInterpolation, '', handles, 'keepcurrent');     // update the image interpolation button icon @endcode
% @code toolbarResizingMethod(handles.toolbarInterpolation, '', handles); // a callback to the button press @endcode

% Copyright (C) 12.01.2016, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
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
    if strcmp(handles.preferences.resize, 'bicubic')
        handles.preferences.resize = 'nearest';
    else
        handles.preferences.resize = 'bicubic';
    end
end
if strcmp(handles.preferences.resize, 'bicubic')
    filename = 'image_bicubic.res';
    set(handles.toolbarResizingMethod, 'TooltipString', 'bicubic interpolation for the visualization, press for neareast');
else
    filename = 'image_nearest.res';
    set(handles.toolbarResizingMethod, 'TooltipString', 'nearest interpolation for the visualization, press for bicubic');
end

if isdeployed
    img = load(fullfile(pwd, 'Resources', filename), '-mat');  % load icon
else
    img = load(fullfile(fileparts(which('im_browser')), 'Resources', filename), '-mat');  % load icon
end
set(handles.toolbarResizingMethod,'CData', img.image);
if isfield(handles, 'Img')
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);     % redraw the image
else
    guidata(handles.im_browser, handles);       % during init of MIB from im_browser_getDefaultParameters
end
end
