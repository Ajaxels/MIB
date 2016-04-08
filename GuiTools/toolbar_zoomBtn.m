function toolbar_zoomBtn(hObject, eventdata, handles, recenterSwitch)
% function toolbar_zoomBtn(hObject, eventdata, handles, recenterSwitch)
% modifies magnification using the buttons in the toolbar of MIB
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure
% handles: structure with handles of im_browser.m
% recenterSwitch: [@em optional], defines whether the image should be
% recentered after zoom/unzoom. Default=0

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 



if nargin < 4; recenterSwitch = 0; end;
% zoom buttons
xy = get(handles.imageAxes, 'currentpoint');
%xy2(1) = ceil(xy(1,1)*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesX(1))]));
%xy2(2) = ceil(xy(1,2)*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesY(1))]));

[xy2(1),xy2(2)] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xy(1,1), xy(1,2), 'shown');
xy2 = ceil(xy2);

name = get(hObject,'Tag');

switch name
    case 'one2onePush'
        set(handles.zoomEdit,'String', '100 %');
        zoomEdit_Callback(handles.zoomEdit,eventdata, handles);
    case 'fitPush'
        handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
    case 'zoominPush'
        if recenterSwitch
            % recenter the view
            handles.Img{handles.Id}.I.moveView(xy2(1), xy2(2));
            % recenter the mouse
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
            x = pos1(1) + pos2(1) + pos3(1) + pos3(3)/2;
            y = screenSize(4) - (pos1(2) + pos2(2) + pos3(2) + pos3(4)/2);
            mouse.mouseMove(x, y);
            
            % restore the units
            set(handles.im_browser,'Units', 'points');
            set(handles.imagePanel,'Units', 'points');
        end
        % change zoom
        zoom = get(handles.zoomEdit,'String');
        zoom = str2double(strrep(zoom, '%', ''))/100;
        set(handles.zoomEdit,'String', [num2str(str2double(sprintf('%.3f',zoom*1.5))*100) ' %']);
        zoomEdit_Callback(handles.zoomEdit,eventdata, handles);
    case 'zoomoutPush'
        % change zoom
        zoom = get(handles.zoomEdit,'String');
        zoom = str2double(strrep(zoom, '%', ''))/100;
        set(handles.zoomEdit,'String', [num2str(str2double(sprintf('%.2f',zoom/1.5))*100) ' %']);
        if recenterSwitch
            % recenter the view
            handles.Img{handles.Id}.I.moveView(xy2(1), xy2(2));
            
            % recenter the mouse
            import java.awt.Robot;
            mouse = Robot;
            
            % set units to pixels
            set(handles.im_browser,'Units','pixels');   % they were in points
            set(handles.imagePanel,'Units','pixels');
            
            pos1 = get(handles.im_browser,'Position');
            pos2 = get(handles.imagePanel,'Position');
            pos3 = get(handles.imageAxes,'Position');
            screenSize = get(0, 'screensize');
            x = pos1(1) + pos2(1) + pos3(1) + pos3(3)/2;
            y = screenSize(4) - (pos1(2) + pos2(2) + pos3(2) + pos3(4)/2);
            mouse.mouseMove(x, y);
            
            % restore the units
            set(handles.im_browser,'Units', 'points');
            set(handles.imagePanel,'Units', 'points');
        end
        zoomEdit_Callback(handles.zoomEdit,eventdata, handles);
end
% update ROI of the hMeasure class
if ~isempty(handles.Img{handles.Id}.I.hMeasure.roi.type)
    handles.Img{handles.Id}.I.hMeasure.updateROIScreenPosition('crop');
end

% update ROI of the hROI class
if ~isempty(handles.Img{handles.Id}.I.hROI.roi.type)
    handles.Img{handles.Id}.I.hROI.updateROIScreenPosition('crop');
end

end