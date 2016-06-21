function handles = updateAxesLimits(obj, handles, mode, newMagFactor)
% function handles = updateAxesLimits(obj, handles, mode, newMagFactor)
% Updates the imageData.axesX and imageData.axesY during fit screen, resize, or new dataset drawing
%
% Parameters:
% handles: handles structure from im_browser
% mode: update mode,
% @li 'resize' -> scale to width/height
% @li 'zoom' -> scale during the zoom
% newMagFactor: a value of the new magnification factor, only for the 'zoom' mode
% Return values:
% handles: handles structure from im_browser

%| 
% @b Examples:
% @code handles = imageData.updateAxesLimits(handles, 'zoom', newMagFactor);     // update the axes using new magnification value @endcode
% @code handles = updateAxesLimits(obj, handles, 'resize'); // Call within the class; to fit the screen @endcode

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% get the scaling coefficient
if obj.orientation == 4     % xy
    coef_z = obj.pixSize.x/obj.pixSize.y;
    Height = obj.height;
    Width = obj.width;
elseif obj.orientation == 1     % xz
    coef_z = obj.pixSize.z/obj.pixSize.x;
    Height = obj.width;
    Width = obj.no_stacks;
elseif obj.orientation == 2     % yz
    coef_z = obj.pixSize.z/obj.pixSize.y;
    Height = obj.height;
    Width = obj.no_stacks;
end

set(handles.imageAxes,'Units','pixels');
axSize = get(handles.imageAxes,'Position');

if isnan(obj.axesX(1)) || strcmp(mode, 'resize') == 1
    if strcmp(get(handles.volrenToolbarSwitch, 'state'), 'off')
        if Height < axSize(4) && Width*coef_z >= axSize(3)     % scale to width
            obj.magFactor = Width*coef_z/axSize(3);
            obj.axesX(1) = 1;
            obj.axesX(2) = Width;
            obj.axesY(1) = Height/2 - axSize(4)/2*obj.magFactor;
            obj.axesY(2) = Height/2 + axSize(4)/2*obj.magFactor;
        elseif Height >= axSize(4) && Width*coef_z < axSize(3)     % scale to height
            obj.magFactor = Height/axSize(4);
            obj.axesX(1) = Width/2 - axSize(3)/2/coef_z*obj.magFactor;
            obj.axesX(2) = Width/2 + axSize(3)/2/coef_z*obj.magFactor;
            obj.axesY(1) = 1;
            obj.axesY(2) = Height;
        else        % scale to the width/height
            if axSize(4)/Height < axSize(3)/(Width*coef_z)   % scale to height
                obj.magFactor = Height/axSize(4);
                obj.axesX(1) = Width/2 - axSize(3)/coef_z/2*obj.magFactor;
                obj.axesX(2) = Width/2 + axSize(3)/2/coef_z*obj.magFactor;
                obj.axesY(1) = 1;
                obj.axesY(2) = Height;
            else % scale to width
                obj.magFactor = Width*coef_z/axSize(3);
                obj.axesX(1) = 1;
                obj.axesX(2) = Width;
                obj.axesY(1) = Height/2 - axSize(4)/2*obj.magFactor;
                obj.axesY(2) = Height/2 + axSize(4)/2*obj.magFactor;
            end
        end
    else
        if Height < axSize(4) && Width*coef_z >= axSize(3)     % scale to width   
            newMagFactor = Width*coef_z/axSize(3);
        elseif Height >= axSize(4) && Width*coef_z < axSize(3)     % scale to height
            newMagFactor = Height/axSize(4);
        else
            if axSize(4)/Height < axSize(3)/(Width*coef_z)   % scale to height
                newMagFactor = Height/axSize(4);
            else % scale to width
                newMagFactor = Width*coef_z/axSize(3);
            end
        end
        scaleRatio = newMagFactor/obj.magFactor;
        obj.magFactor = newMagFactor;
        S = makehgtform('scale', 1/scaleRatio);
        obj.volren.viewer_matrix = S * obj.volren.viewer_matrix;
        set(handles.zoomEdit,'String', [num2str(str2double(sprintf('%.3f', 1/newMagFactor))*100) ' %']);
    end
elseif strcmp(mode, 'zoom')
    if strcmp(get(handles.volrenToolbarSwitch, 'state'), 'off')
        dxHalf = diff(obj.axesX)/2;
        dyHalf = diff(obj.axesY)/2;
        xCenter = obj.axesX(1) + dxHalf;
        yCenter = obj.axesY(1) + dyHalf;
        xLim(1) = xCenter - dxHalf*newMagFactor/obj.magFactor;
        xLim(2) = xCenter + dxHalf*newMagFactor/obj.magFactor;
        yLim(1) = yCenter - dyHalf*newMagFactor/obj.magFactor;
        yLim(2) = yCenter + dyHalf*newMagFactor/obj.magFactor;
        % check for out of image boundaries cases
        if xLim(2) < 1 || xLim(1) > Width
            xLim = xLim - xLim(1);
        end;
        if yLim(2) < 1 || yLim(1) > Height
            yLim = yLim - yLim(1);
        end;
        
        obj.axesX = xLim;
        obj.axesY = yLim;
    else
        scaleRatio = newMagFactor/obj.magFactor;
        S = makehgtform('scale', 1/scaleRatio);
        obj.volren.viewer_matrix = S * obj.volren.viewer_matrix;
    end
    obj.magFactor = newMagFactor;
end

% if strcmp(get(handles.im_browser, 'visible'), 'on') 
%     handles = ib_updateCursor(handles);
% end
end