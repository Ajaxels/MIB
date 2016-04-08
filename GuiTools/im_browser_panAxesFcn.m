function im_browser_panAxesFcn(~, ~, handles, xy, imgWidth, imgHeight)
% function im_browser_panAxesFcn(~, ~, handles, xy, imgWidth, imgHeight)
% This function is responsible for moving image during panning
%
% Parameters:
% handles: handles structure of im_browser.m
% xy: coordinates of the mouse when the mouse button was pressed
% imgWidth: width of the shown image
% imgHeight: height of the shown image

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if strcmp(get(handles.toolbarFastPanMode, 'state'), 'off')
    fastPanMode = 0;        % slow pan mode, and showing the full image
else
    fastPanMode = 1;        % fast pan mode, but showing the currently shown piece
end
pt = get(handles.imageAxes, 'currentpoint');

Xlim = get(handles.imageAxes, 'xlim');
Ylim = get(handles.imageAxes, 'ylim');

newXLim = Xlim + (xy(1)-(pt(1,1)+pt(2,1))/2);
newYLim = Ylim + (xy(2)-(pt(1,2)+pt(2,2))/2);

% check for out of image shifts
outSwitch = 0;
if newXLim(2) < 1 || newXLim(1) > imgWidth; outSwitch = 1; end;
if newYLim(2) < 1 || newYLim(1) > imgHeight; outSwitch = 1; end;

if outSwitch == 0
    if fastPanMode
        magFactorFixed = handles.Img{handles.Id}.I.magFactor;
    else
        if handles.Img{handles.Id}.I.magFactor < 1   % the image is not rescaled if magFactor less than 1
            magFactorFixed = 1;
        else
            magFactorFixed = handles.Img{handles.Id}.I.magFactor;
        end
    end
    set(handles.imageAxes, 'xlim', newXLim, 'ylim', newYLim);
        
    handles.Img{handles.Id}.I.axesX = handles.Img{handles.Id}.I.axesX + (xy(1)-(pt(1,1)+pt(2,1))/2)*magFactorFixed;
    handles.Img{handles.Id}.I.axesY = handles.Img{handles.Id}.I.axesY + (xy(2)-(pt(1,2)+pt(2,2))/2)*magFactorFixed;
end
end