function handles = ib_segmentation_Spot(y, x, modifier, handles)
% handles = ib_segmentation_Spot(y, x, modifier, handles)
% Do segmentation using the spot tool
%
% Parameters:
% y: y-coordinate of the spot center
% x: x-coordinate of the spot center
% modifier: a string, to specify what to do with the generated selection
% - @em empty - makes new selection
% - @em ''control'' - removes selection from the existing one
% handles: a handles structure of im_browser
%
% Return values:
% handles: a handles structure of im_browser

%| @b Examples:
% @code handles = ib_segmentation_Spot(50, 75, '', handles);  // add a spot to the shown slice at position y=50, x=75 @endcode

% Copyright (C) 2012 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 15.05.2014, taken to a separate function
% 20.06.2014, updated to improve performance
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 29.03.2016, IB, optimized backup
% 25.10.2016, IB, updated for segmentation table

switch3d = get(handles.actions3dCheck,'Value');     % use tool in 3d
userData = get(handles.segmTable,'UserData');
selcontour = userData.prevMaterial - 2;  % get selected contour
radius = str2double(get(handles.segmSpotSizeEdit,'String'))-1;
radius = radius - 1;
if radius < 1; radius = 0.5; end;
radius = round(radius);
options.x = [x-radius x+radius];
options.y = [y-radius y+radius];
% recalculate x and y for the obtained cropped image
x = radius + min([options.x(1) 1]);
y = radius + min([options.y(1) 1]);

currSelection = handles.Img{handles.Id}.I.getSlice('selection', NaN, NaN, NaN, NaN, options);
currSelection2 = zeros(size(currSelection),'uint8');
currSelection2(y,x) = 1;
currSelection2 = bwdist(currSelection2); 
currSelection2 = uint8(currSelection2 <= radius);

if switch3d
    if handles.Img{handles.Id}.I.orientation == 4
        backupOptions.y = options.y;
        backupOptions.x = options.x;
    elseif handles.Img{handles.Id}.I.orientation == 1
        backupOptions.x = options.y;
        backupOptions.z = options.x;
    elseif handles.Img{handles.Id}.I.orientation == 2
        backupOptions.y = options.y;
        backupOptions.z = options.x;
    end
    
    ib_do_backup(handles, 'selection', 1, backupOptions);
    orient = NaN;
    [localHeight, localWidth, localColor, localThick] = handles.Img{handles.Id}.I.getDatasetDimensions('selection', orient, NaN, options);
    selarea = zeros([size(currSelection,1), size(currSelection,2), localThick],'uint8');
    options.z = [1, localThick];
    for layer_id = 1:size(selarea, 3)
        selarea(:,:,layer_id) = currSelection2;
    end
    
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value')
        currSelection = handles.Img{handles.Id}.I.getData3D('model', NaN, orient, selcontour, options);
        selarea = bitand(selarea, currSelection);
    end
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist   % do selection only in the masked areas
        currSelection = handles.Img{handles.Id}.I.getData3D('mask', NaN, orient, selcontour, options);
        selarea = bitand(selarea, currSelection);
    end
    
    currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, orient, NaN, options);
    if isempty(modifier) || strcmp(modifier, 'shift')    % combines selections
        handles.Img{handles.Id}.I.setData3D('selection', bitor(selarea, currSelection), NaN, orient, NaN, options);
    elseif strcmp(modifier, 'control')  % subtracts selections
        currSelection(selarea==1) = 0;
        handles.Img{handles.Id}.I.setData3D('selection', currSelection, NaN, orient, NaN, options);
    end
else
    ib_do_backup(handles, 'selection', 0, options);
    selarea = currSelection2;
    
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value')
        currModel = handles.Img{handles.Id}.I.getSlice('model', NaN, NaN, selcontour, NaN, options);
        selarea = bitand(selarea, currModel);
    end
    
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist
        currModel = handles.Img{handles.Id}.I.getSlice('mask', NaN, NaN, NaN, NaN, options);
        selarea = bitand(selarea, currModel);
    end
    
    if isempty(modifier) || strcmp(modifier, 'shift')    % combines selections
        handles.Img{handles.Id}.I.setSlice('selection', bitor(currSelection, selarea), NaN, NaN, NaN, NaN, options);
    elseif strcmp(modifier, 'control')  % subtracts selections
        currSelection(selarea==1) = 0;
        handles.Img{handles.Id}.I.setSlice('selection', currSelection, NaN, NaN, NaN, NaN, options);
    end
end
