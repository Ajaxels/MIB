function pixInfo_cb(hObject, eventdata, parameter)
% center image to defined position
% it is a callback from a popup menu above the pixel information field of
% the Path panel
% 
% Parameters:
% hObject: - a handle to one of the buttons
% eventdata: - eventdata structure
% parameter: - a string that defines options:
% @li ''jump'' - center the viewing window around specified coordinates

% Copyright (C) 23.04.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


handles = guidata(hObject);
switch parameter
    case 'jump'
        prompt = {sprintf('Enter destination in pixels\n\nX (1-%d):', handles.Img{handles.Id}.I.width),...
            sprintf('Y (1-%d):', handles.Img{handles.Id}.I.height),...
            sprintf('Z (1-%d):', handles.Img{handles.Id}.I.no_stacks)};
        def = {num2str(round(handles.Img{handles.Id}.I.width/2)),num2str(round(handles.Img{handles.Id}.I.height/2)),num2str(handles.Img{handles.Id}.I.getCurrentSliceNumber())};
        answer = inputdlg(prompt,'Jump to:',1,def);
        if isempty(answer); return; end;
        if num2str(handles.Img{handles.Id}.I.getCurrentSliceNumber()) ~= str2double(answer{3})
            set(handles.changelayerEdit, 'string', answer{3});
            changelayerEdit_Callback(handles.changelayerEdit, NaN, handles);
        end
        
        if handles.Img{handles.Id}.I.width < str2double(answer{1}) || handles.Img{handles.Id}.I.height < str2double(answer{2}) ||...
            str2double(answer{1}) < 1 || str2double(answer{2}) < 1 || isnan(str2double(answer{1})) || isnan(str2double(answer{2})) || isnan(str2double(answer{3})) 
            errordlg(sprintf('!!! Error !!!\nThe coordinates should be within the image boundaries!'),'Error');
            return;
        end
        
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
        % recenter the view
        handles.Img{handles.Id}.I.moveView(str2double(answer{1}), str2double(answer{2}));
        
        % restore the units
        set(handles.im_browser,'Units', 'points');
        set(handles.imagePanel,'Units', 'points');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
end