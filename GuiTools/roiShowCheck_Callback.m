function roiShowCheck_Callback(~, ~, handles, parameter)
% function roiShowCheck_Callback(~, ~, handles)
% toggle show/hide state of ROIs, as callback of handles.roiShowCheck
%
% Parameters:
% handles: structure with handles of im_browser.m
% parameter: a string: when 'noplot' do not redraw the image (used from updateGuiWidgets function)

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.04.2015, Ilya Belevich, ilya.belevich @ helsinki.fi

if nargin < 4; parameter = ''; end;

if numel(get(handles.roiList,'String')) == 1;
    set(handles.roiShowCheck, 'value', 0);
    set(handles.toolbarShowROISwitch,'State','off');
    if ~strcmp(parameter, 'noplot')
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    end
    return;
end
val = get(handles.roiShowCheck,'Value');

if val == 1
    set(handles.toolbarShowROISwitch,'State','on');
else
    set(handles.toolbarShowROISwitch,'State','off');
end
if ~strcmp(parameter, 'noplot')
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

end