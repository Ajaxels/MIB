function toolbarPlaneToggle(hObject, eventdata, handles, moveMouseSw)
% function toolbarPlaneToggle(hObject, eventdata, handles, moveMouseSw)
% a callback to the change orientation buttons in the toolbar of MIB; it toggles viewing plane: xy, zx, or zy direction
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% moveMouseSw: [@em optional] -> when 1, moves the mouse to the point where the the plane orientation has ben changed

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 25.08.2015, ib, modified to keep the current magnification when moveMouseSw==1

if nargin < 4;     moveMouseSw = 0; end;

set(handles.zyPlaneToggle, 'state', 'off');
set(handles.xyPlaneToggle, 'state', 'off');
set(handles.zxPlaneToggle, 'state', 'off');

if handles.Img{handles.Id}.I.no_stacks == 1
    set(handles.xyPlaneToggle, 'state', 'on');
    return;
end;
set(hObject,'State','on');

% when volume rendering is enabled
if strcmp(get(handles.volrenToolbarSwitch, 'state'), 'on')
    
    switch get(hObject,'Tag')
        case 'xyPlaneToggle'
              R = [0 0 0];  % 'yx'
        case 'zxPlaneToggle'
             R = [90 0 90]; % 'xz'
        case 'zyPlaneToggle'
             R = [90 90 0]; % 'yz'
    end
    S = [1*handles.Img{handles.Id}.I.magFactor,...
                   1*handles.Img{handles.Id}.I.magFactor,...
                   1*handles.Img{handles.Id}.I.pixSize.x/handles.Img{handles.Id}.I.pixSize.z*handles.Img{handles.Id}.I.magFactor];  
    T = [0 0 0];               
    handles.Img{handles.Id}.I.volren.viewer_matrix = makeViewMatrix(R, S, T);
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    return;
end

switch get(hObject,'Tag')
    case 'xyPlaneToggle'
        handles.Img{handles.Id}.I.transpose(4);  % 'yx'
    case 'zxPlaneToggle'
        handles.Img{handles.Id}.I.transpose(1); % 'xz'
    case 'zyPlaneToggle'
        handles.Img{handles.Id}.I.transpose(2); % 'yz'
end
oldMagFactor = handles.Img{handles.Id}.I.magFactor;
handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
handles = updateGuiWidgets(handles);

handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);

if moveMouseSw
    % move the mouse to the point of the plane change
    import java.awt.Robot;
    mouse = Robot;
    
    % set units to pixels
    set(handles.im_browser,'Units','pixels');   % they were in points
    set(handles.imagePanel,'Units','pixels');
    
    % get pisition
    pos1 = get(handles.im_browser,'Position');
    pos2 = get(handles.imagePanel,'Position');
    pos3 = get(handles.imageAxes,'Position');
    screenSize = get(0, 'screensize');
    % an old code for recalculated coordinates for the rescaled-to-fit dataset
    %axesX = get(handles.imageAxes,'xlim');
    %axesY = get(handles.imageAxes,'ylim');
    
    x = 1;
    y = 1;
    switch get(hObject,'Tag')
        case 'xyPlaneToggle'
            % an old code that recalculate coordinates for the rescaled-to-fit dataset
            %x = pos1(1) + pos2(1) + pos3(1) + pos3(3)/diff(axesX)*(handles.Img{handles.Id}.I.current_yxz(2)/handles.Img{handles.Id}.I.magFactor-axesX(1));
            %y = screenSize(4) - (pos1(2) + pos2(2) + pos3(2) + pos3(4)/diff(axesY)*(axesY(2) - handles.Img{handles.Id}.I.current_yxz(1)/handles.Img{handles.Id}.I.magFactor));
            
            x = handles.Img{handles.Id}.I.current_yxz(2);
            y = handles.Img{handles.Id}.I.current_yxz(1);
        case 'zxPlaneToggle'
            % an old code that recalculate coordinates for the rescaled-to-fit dataset
            %x = pos1(1) + pos2(1) + pos3(1) + pos3(3)/diff(axesX)*(handles.Img{handles.Id}.I.current_yxz(3)/handles.Img{handles.Id}.I.magFactor-axesX(1));
            %y = screenSize(4) - (pos1(2) + pos2(2) + pos3(2) + pos3(4)/diff(axesY)*(axesY(2) - handles.Img{handles.Id}.I.current_yxz(2)/handles.Img{handles.Id}.I.magFactor));
            
            x = handles.Img{handles.Id}.I.current_yxz(3);
            y = handles.Img{handles.Id}.I.current_yxz(2);
        case 'zyPlaneToggle'
            % an old code that recalculate coordinates for the rescaled-to-fit dataset
            %x = pos1(1) + pos2(1) + pos3(1) + pos3(3)/diff(axesX)*(handles.Img{handles.Id}.I.current_yxz(3)/handles.Img{handles.Id}.I.magFactor-axesX(1));
            %y = screenSize(4) - (pos1(2) + pos2(2) + pos3(2) + pos3(4)/diff(axesY)*(axesY(2) - handles.Img{handles.Id}.I.current_yxz(1)/handles.Img{handles.Id}.I.magFactor));
            
            x = handles.Img{handles.Id}.I.current_yxz(3);
            y = handles.Img{handles.Id}.I.current_yxz(1);
    end
    % an old code that moves mouse to the recalculated coordinates for the rescaled-to-fit dataset
    %mouse.mouseMove(x, y);
    
    % recenter the view
    handles.Img{handles.Id}.I.moveView(x, y);
    
    % restore the units
    set(handles.im_browser,'Units', 'points');
    set(handles.imagePanel,'Units', 'points');

    % change zoom
    set(handles.zoomEdit,'String', [num2str(str2double(sprintf('%.3f',1/oldMagFactor))*100) ' %']);
    zoomEdit_Callback(handles.zoomEdit,eventdata, handles);
    
    % calculate position of the imageAxes center in pixels (for coordinates of the monitor)
    xMouse = pos1(1) + pos2(1) + pos3(1) + pos3(3)/2;
    yMouse = screenSize(4) - (pos1(2) + pos2(2) + pos3(2) + pos3(4)/2);
    mouse.mouseMove(xMouse, yMouse);    % move the mouse
end
im_browser_winMouseMotionFcn(handles.im_browser, NaN, handles);
guidata(handles.im_browser, handles);
end