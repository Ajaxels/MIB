function im_browser_winMouseMotionFcn(hObject, ~, handles)
% function im_browser_winMouseMotionFcn(hObject, ~, handles)
% returns coordinates and image intensities under the mouse cursor
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices to cells

position=get(handles.imageAxes,'currentpoint');
axXLim=get(handles.imageAxes,'xlim');
axYLim=get(handles.imageAxes,'ylim');

x = round(position(1,1));
y = round(position(1,2));

% get mouse coordinates for the im_browser window to change cursor for
% rescaling of the right panels
position2 = get(handles.im_browser,'currentpoint');
x2 = round(position2(1,1));
y2 = round(position2(1,2));
separatingPanelPos = get(handles.separatingPanel, 'position');

if x>axXLim(1) && x<axXLim(2) && y>axYLim(1) && y<axYLim(2) % mouse pointer within the current axes
    set(hObject,'Pointer','crosshair');
    
    if x > 0 && y > 0 && x<=size(handles.Img{handles.Id}.I.Ishown,2) && y<=size(handles.Img{handles.Id}.I.Ishown,1) && isempty(get(handles.Img{handles.Id}.I.imh, 'UserData')) % mouse pointer inside the image dimensions
        %CData = get(handles.Img{handles.Id}.I.imh,'CData');
        %brightness_coef = get(handles.brightnessSlider,'Value');
        %classMaxVal = double(intmax(class(CData)));
        
        [x,y,sliceNo] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(x, y, 'shown');
        x = ceil(x);
        y = ceil(y);
        %x = ceil(x*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesX(1))]));
        %y = ceil(y*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesY(1))]));
                
        %sprintf('X: %d; Y: %d', x, y)
        %sliceNo = handles.Img{handles.Id}.I.getCurrentSliceNumber();
        
        try
            if handles.Img{handles.Id}.I.orientation == 4   % yx
                colorValues = handles.Img{handles.Id}.I.img(y,x,handles.Img{handles.Id}.I.slices{3},sliceNo, handles.Img{handles.Id}.I.slices{5}(1));
            elseif handles.Img{handles.Id}.I.orientation == 1 % zx
                colorValues = handles.Img{handles.Id}.I.img(sliceNo,y,handles.Img{handles.Id}.I.slices{3},x, handles.Img{handles.Id}.I.slices{5}(1));
            elseif handles.Img{handles.Id}.I.orientation == 2 % zy
                colorValues = handles.Img{handles.Id}.I.img(y,sliceNo,handles.Img{handles.Id}.I.slices{3},x, handles.Img{handles.Id}.I.slices{5}(1));
            end
        catch err
            colorValues = '';
            %err
        end
        
        rI = NaN;
        gI = NaN;
        bI = NaN;
        extI = NaN;
        if ~isempty(colorValues); rI = colorValues(1); end;
        if numel(colorValues) > 1; gI = colorValues(2); end;
        if numel(colorValues) > 2;  bI = colorValues(3);    end;
        R = sprintf('%.0f',rI);
        G = sprintf('%.0f',gI);
        B = sprintf('%.0f',bI);
        
        if numel(colorValues) > 3;  
            extI = colorValues(4);    
            E = sprintf('%.0f',extI);
            txt = [num2str(x) ':' num2str(y) '  (' R ':' G ':' B ':' E ')'];
        else
            txt = [num2str(x) ':' num2str(y) '  (' R ':' G ':' B ')'];
        end;
        set(handles.pixelinfoTxt2,'String',txt);
    else
        %set(handles.pixelinfoTxt2,'String','XXXX:YYYY (RRR:GGG:BBB)');
        txt = [num2str(x) ':' num2str(y) ' (RRR:GGG:BBB)'];
        set(handles.pixelinfoTxt2,'String',txt);
    end
elseif x2>separatingPanelPos(1) && x2<separatingPanelPos(1)+separatingPanelPos(3) && y2>separatingPanelPos(2) && y2<separatingPanelPos(2)+separatingPanelPos(4) % mouse pointer within the current axes
    set(handles.im_browser,'Pointer','left');
else
    set(handles.im_browser,'Pointer','arrow');
    set(handles.pixelinfoTxt2,'String','XXXX:YYYY (RRR:GGG:BBB)');
end

% recalculate brush cursor positions
% possible code to show brush cursor, requires handles.cursor handle for the plot type object
try
    if ishandle(handles.cursor)
        xdata = get(handles.cursor, 'XData');
        ydata = get(handles.cursor, 'YData');
        
        diffX = round(position(1,1))-mean(xdata);
        diffY = round(position(1,2))-mean(ydata);
        
        xv = xdata+diffX;
        yv = ydata+diffY;
        set(handles.cursor, 'XData', xv);
        set(handles.cursor, 'YData', yv);
    end
catch err;
end
end