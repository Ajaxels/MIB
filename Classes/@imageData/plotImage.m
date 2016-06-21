function handles = plotImage(obj, axes, handles, resize, sImgIn)
% function handles = plotImage(obj, axes, handles, resize, sImgIn)
% Plot image to the axes. The main drawing function
%
% Parameters:
% axes: handle to axes, use @b handles.imageAxes
% handles: handles structure from im_browser
% resize:
% - when @b 1 resize image to fit the screen
% - when @b 0 keep the current vieweing settings
% sImgIn: a custom 2D image to show in the axes that should be targeted to
% the axes. Use resize=0 to show 'sImgIn' in the same scale/position as the
% currently shown dataset, or resize=1 to show 'sImgIn' in full resolution
%
% Return values:
% handles: - handles of im_browser.m

%| 
% @b Examples:
% @code imageData.plotImage(handles.imageAxes, handles, 1);     // plot image in the handles.imageAxes axes and resize it @endcode
% @code handles = plotImage(obj, handles.imageAxes, handles, 1);// Call within the class; plot image in the handles.imageAxes axes and resize it @endcode

% Copyright (C) 06.09.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

rgbOptions.mode = 'shown';
if nargin < 5   % generate Ishown from the dataset
    if strcmp(get(handles.volrenToolbarSwitch, 'state'), 'off')
        obj.Ishown = getRGBimage(obj, handles, rgbOptions);
    else
        imPanPos = get(handles.imageAxes, 'position');
        options.Mview = obj.volren.viewer_matrix;
        options.ImageSize = [floor(imPanPos(4)), floor(imPanPos(3))];
        options.ShearInterp = 'nearest';
        %options.AlphaTable = [1 0 0 0 1];

        timePoint = handles.Img{handles.Id}.I.slices{5}(1);
        if obj.volren.showFullRes == 1
            obj.Ishown =  getRGBvolume(obj.img(:,:,:,:,timePoint), options, handles);
        else
            obj.Ishown = getRGBvolume(obj.volren.previewImg, options, handles);
        end
                
        if obj.imh == 0 || ~isempty(get(handles.Img{handles.Id}.I.imh,'UserData'))
            obj.imh = image(obj.Ishown, 'parent', axes);
        else
           set(obj.imh, 'CData',[],'CData', obj.Ishown);
        end
        
        set(handles.imageAxes, 'DataAspectRatioMode',' manual');
        set(handles.imageAxes, 'PlotBoxAspectRatioMode',' manual');
        set(handles.imageAxes, 'DataAspectRatio',[1 1 1]);
        set(handles.imageAxes, 'PlotBoxAspectRatio',[imPanPos(3)/imPanPos(4)  1    1]);
        
        set(handles.imageAxes, ...
            'box'             , 'on', ...
            'xtick'           , [], ...
            'ytick'           , [], ...
            'interruptible'   , 'off', ...
            'busyaction'      , 'queue', ...
            'handlevisibility', 'callback');
        
        guidata(handles.im_browser, handles);
        return;
    end
else    % use for Ishown the image provided in the sImgIn
    if resize == 1
        rgbOptions.resize = 'no';   % show the provided image in full resolution 
    else
        rgbOptions.resize = 'yes';  % resize the provided image, to fit the current settings of the vieweing panel  
    end
    obj.Ishown = getRGBimage(obj, handles, rgbOptions, sImgIn);
end

if obj.orientation == 4
    coef_z = obj.pixSize.x/obj.pixSize.y;
elseif obj.orientation == 1
    coef_z = obj.pixSize.z/obj.pixSize.x;
elseif obj.orientation == 2
    coef_z = obj.pixSize.z/obj.pixSize.y;
end

if obj.imh == 0 || ~isempty(get(handles.Img{handles.Id}.I.imh,'UserData'))
    obj.imh = image(obj.Ishown, 'parent', axes);
    set(obj.imh, 'UserData', []);
else
    set(obj.imh,'CData',[],'CData', obj.Ishown);
    % delete measurements & roi
    lineObj = findobj(handles.imageAxes,'tag','measurements','-or','tag','roi');
    if ~isempty(lineObj); delete(lineObj); end;     % keep it within if, because it is faster
end

handles = ib_updateCursor(handles);

set(obj.imh,'HitTest','off'); % If HitTest is off, clicking this object selects the object below it (which is usually the axes containing it)
set(handles.im_browser, 'WindowButtonMotionFcn',{@im_browser_winMouseMotionFcn, handles});
set(handles.im_browser, 'WindowScrollWheelFcn', {@im_browser_scrollWheelFcn, handles});
set(handles.imageAxes, ...
    'box'             , 'on', ...
    'xtick'           , [], ...
    'ytick'           , [], ...
    'interruptible'   , 'off', ...
    'busyaction'      , 'queue', ...
    'handlevisibility', 'callback');

if exist('sImgIn', 'var') && resize == 1  % deal with case when the image is provided with the plotImage function
    set(handles.imageAxes, 'DataAspectRatioMode',' manual');
    set(handles.imageAxes, 'PlotBoxAspectRatioMode',' manual');
    set(handles.imageAxes, 'DataAspectRatio',[1 coef_z 1]);
    imPanPos = get(handles.imagePanel,'Position');  % size of the image panel
    set(handles.imageAxes, 'PlotBoxAspectRatio',[imPanPos(3)/imPanPos(4)  1    1]);
    set(handles.imageAxes, 'ylim',[1 size(obj.Ishown,1)]);
    set(handles.imageAxes, 'xlim',[1 size(obj.Ishown,2)]); 
else
    if resize == 1
        % set aspect ratio
        set(handles.imageAxes, 'DataAspectRatioMode',' manual');
        set(handles.imageAxes, 'PlotBoxAspectRatioMode',' manual');
        set(handles.imageAxes, 'DataAspectRatio',[1 coef_z 1]);
        imPanPos = get(handles.imagePanel,'Position');  % size of the image panel
        set(handles.imageAxes, 'PlotBoxAspectRatio',[imPanPos(3)/imPanPos(4)  1    1]);
        set(handles.zoomEdit, 'string', sprintf('%d %%',round(1/obj.magFactor*100)));
        set(handles.imageAxes, 'ylim',[obj.axesY(1)/obj.magFactor obj.axesY(2)/obj.magFactor]);
        set(handles.imageAxes, 'xlim',[obj.axesX(1)/obj.magFactor obj.axesX(2)/obj.magFactor]);
    else
        set(handles.imageAxes,'Units','pixels');
        set(handles.zoomEdit, 'string', sprintf('%d %%',round(1/obj.magFactor*100)));
        xl(1) = min([obj.axesX(1)/obj.magFactor 0]);
        
        if obj.axesX(2) > size(obj.Ishown,2)*obj.magFactor;
            if obj.axesX(1) < 0
                xl(2) = obj.axesX(2)/obj.magFactor;
            else
                xl(2) = obj.axesX(2)/obj.magFactor - obj.axesX(1)/obj.magFactor;
            end
        else
            xl(2) = size(obj.Ishown,2);
        end
        
        yl(1) = min([obj.axesY(1)/obj.magFactor 0]);
        if obj.axesY(2) > size(obj.Ishown,1)*obj.magFactor;
            if obj.axesY(1) < 0
                yl(2) = obj.axesY(2)/obj.magFactor;
            else
                yl(2) = obj.axesY(2)/obj.magFactor - obj.axesY(1)/obj.magFactor;
            end
        else
            yl(2) = size(obj.Ishown,1);
        end

        set(handles.imageAxes, 'ylim',yl);
        set(handles.imageAxes, 'xlim',[xl(1) xl(2)]);
    end
   
    % show ROIs
    if get(handles.roiShowCheck,'Value')
        handles = handles.Img{handles.Id}.I.hROI.addROIsToPlot(handles, 'shown');
    end
    
    % show measurements
    if get(handles.showAnnotationsCheck,'value')==1
        handles = handles.Img{handles.Id}.I.hMeasure.addMeasurementsToPlot(handles, 'shown');
    end
end

guidata(handles.im_browser, handles);
% update the histogram in the imAdjustment window
if handles.SwitchAutoHistUpdate
    windowId = findall(0,'Type','figure','tag','imAdjustments');
    if ~isempty(windowId)
        hlabelsGui = guidata(windowId);
        cb = get(hlabelsGui.updateBtn,'callback');
        feval(cb, hlabelsGui.updateBtn, []);
    end
end

end