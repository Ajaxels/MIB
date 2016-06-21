function handles = ib_updateCursor(handles, mode)
% handles = ib_updateCursor(handles, mode)
% Update brush cursor
%
% Parameters:
% handles: handles of im_browser
% mode: @b [optional] a string, a mode to use with the brush cursor: @b 'dashed' (default) - show dashed cursor, @b 'solid' -
% show solid cursor when painting.
%
% Return values:
% handles: handles of im_browser

% Copyright (C) 27.08.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 20.10.2014, updated to remove findall function and improve performance

if nargin < 2; mode = 'dashed'; end;

xy=get(handles.imageAxes,'currentpoint');
x = round(xy(1,1));
y = round(xy(1,2));

% when 1, show the brush cursor
if handles.showBrushCursor 
    toolsList = get(handles.seltypePopup, 'string');
    selectedTool = toolsList{get(handles.seltypePopup, 'value')};
    if strcmp(selectedTool, 'Object Picker')
        radius = str2double(get(handles.maskBrushSizeEdit, 'String'))-1;
    else
        radius = str2double(get(handles.segmSpotSizeEdit, 'String'))-1;
    end
    
    if radius == 0
        se_size = round(1/handles.Img{handles.Id}.I.magFactor/2);
    else
        se_size = round(radius/handles.Img{handles.Id}.I.magFactor);
    end
    se_size(2) = se_size(1);
    
    if strcmp(mode, 'dashed')
        lineStyle = ':';
    else
        lineStyle = '-';
    end
    
%     % to correct aspect ratio
%     pixSize = handles.Img{handles.Id}.I.pixSize;
%     if handles.Img{handles.Id}.I.orientation == 1 
%         se_size(2) = se_size(1)/(pixSize.x/pixSize.z);
%     elseif handles.Img{handles.Id}.I.orientation == 2
%         se_size(2) = se_size(1)/(pixSize.y/pixSize.z);
%     elseif handles.Img{handles.Id}.I.orientation == 4
%         se_size(2) = se_size(1)/(pixSize.x/pixSize.y);
%     end
    
    % set brush cursor
    theta = linspace(0,2*pi,16);
    xv = cos(theta)*se_size(1) + x;
    yv = sin(theta)*se_size(2) + y;
    hold(handles.imageAxes, 'on');
    if ishandle(handles.cursor) 
        %oldversion handles.cursor = plot(handles.imageAxes, xv,yv,'color',handles.preferences.selectioncolor/2,'linewidth',1,'linestyle',':');
        set(handles.cursor, 'XData', xv,'YData', yv,'linewidth', 2, 'linestyle', lineStyle, 'color', handles.preferences.selectioncolor/2);
    else
        handles.cursor = plot(handles.imageAxes, xv,yv,'color',handles.preferences.selectioncolor/2,'linewidth',2,'linestyle', lineStyle);
        set(handles.cursor, 'tag', 'brushcursor');
    end
    set(handles.cursor, 'visible', 'on');
    hold(handles.imageAxes, 'off');
else
    if ishandle(handles.cursor) 
        set(handles.cursor, 'visible', 'off');
        %set(handles.cursor, 'XData', [],'YData', []);
    elseif isfield(handles, 'cursor')   % to fix situation when pressing the Buffer toggle when cursor is not shown
        hold(handles.imageAxes, 'on');
        handles.cursor = plot(handles.imageAxes, [],[]);
        hold(handles.imageAxes, 'off');
    end
end

guidata(handles.im_browser, handles);
end