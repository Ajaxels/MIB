function handles = ib_segmentation_MagicWand(yxzCoordinate, modifier, handles)
% function handles = ib_segmentation_MagicWand(yxzCoordinate, modifier, handles)
% Do segmentation using the Magic Wand tool
%
% Parameters:
% yxzCoordinate: a vector with [y,x,z] coodrinates of the starting point,
% for 2d case it is enough to have only [y, x].
% modifier: a string, to specify what to do with the generated selection
% - @em empty - makes new selection
% - @em ''shift'' - add selection to the existing one
% - @em ''control'' - removes selection from the existing one
% handles: a handles structure of im_browser
%
% Return values:
% handles: a handles structure of im_browser

%| @b Examples:
% @code yxzCoordinate = [50, 75]; @endcode
% @code handles = ib_segmentation_MagicWand(yxzCoordinate, modifier, handles);  // start the magic wand tool from position [y,x]=50,75 @endcode

% Copyright (C) 2012 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 14.05.2014, taken to a separate function
% 20.06.2014 added effective radius
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 18.09.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}
% 29.03.2016, IB, optimized backup
% 25.10.2016, IB, updated for segmentation table

tic
switch3d = get(handles.actions3dCheck,'Value');     % use tool in 3d
userData = get(handles.segmTable,'UserData');
selcontour = userData.prevMaterial - 2;  % get selected contour
threshold1 = str2double(get(handles.selectiontoolEdit,'String')); % getting low threshold shift for magic wand tool
threshold2 = str2double(get(handles.magicupthresEdit,'String')); % getting up threshold shift for magic wand tool

col_channel = get(handles.ColChannelCombo,'Value')-1;   %
if col_channel == 0;
    msgbox('Please select the color channel!','Error!','error','modal');
    return;
end

if handles.Img{handles.Id}.I.no_stacks < 3; switch3d = 0; end;
magicWandRadius = str2double(get(handles.magicWandRadius, 'String'));

if ~switch3d    % do magic wand in 2d
    x = yxzCoordinate(2);
    y = yxzCoordinate(1);
    ib_do_backup(handles, 'selection', 0);
    if magicWandRadius > 0
        options.x = [x-magicWandRadius x+magicWandRadius];
        options.y = [y-magicWandRadius y+magicWandRadius];
        % recalculate x and y for the obtained cropped image
        x = magicWandRadius + min([options.x(1) 1]);
        y = magicWandRadius + min([options.y(1) 1]);
    else
        options = struct();
    end
    currImage = handles.Img{handles.Id}.I.getSlice('image', NaN, NaN, col_channel, NaN, options);
    val = currImage(y, x); % intensity
    upper = val+threshold2;
    lower = val-threshold1;
    selarea = zeros([size(currImage,1), size(currImage,2)],'uint8')+1;
    
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
    
    selarea(currImage<lower) = 0;
    selarea(currImage>upper) = 0;
    
    if get(handles.magicwandConnectCheck,'Value')   % select connected regions with 8 points connection
        selarea = uint8(bwselect(selarea,x,y, 8));
    elseif get(handles.magicwandConnectCheck4,'Value')  % select connected regions with 4 points connection
        selarea = uint8(bwselect(selarea,x,y, 4));
    end
    
    if magicWandRadius > 0
        distMap =  zeros([size(currImage,1), size(currImage,2)],'uint8');
        distMap(y, x) = 1;
        distMap = bwdist(distMap);
        selarea(distMap>magicWandRadius) = 0;
    end
    
    if strcmp(modifier, 'shift')    % combines selections
        currSelection = handles.Img{handles.Id}.I.getSlice('selection', NaN, NaN, NaN, NaN, options);
        handles.Img{handles.Id}.I.setSlice('selection', bitor(currSelection, selarea), NaN, NaN, NaN, NaN, options);
    elseif strcmp(modifier, 'control')  % subtracts selections
        currSelection = handles.Img{handles.Id}.I.getSlice('selection', NaN, NaN, NaN, NaN, options);
        currSelection(selarea==1) = 0;
        handles.Img{handles.Id}.I.setSlice('selection', currSelection, NaN, NaN, NaN, NaN, options);
    else
        handles.Img{handles.Id}.I.clearSelection(handles.Img{handles.Id}.I.slices{1}(1):handles.Img{handles.Id}.I.slices{1}(2),handles.Img{handles.Id}.I.slices{2}(1):handles.Img{handles.Id}.I.slices{2}(2),handles.Img{handles.Id}.I.slices{4}(1):handles.Img{handles.Id}.I.slices{4}(2));
        handles.Img{handles.Id}.I.setSlice('selection', selarea, NaN, NaN, NaN, NaN, options);
    end
else    % do magic wand in 3d
    wb = waitbar(0, 'Please wait...','name','Doing Magic Wand in 3D');
    orient = 4;
    waitbar(0.05, wb);
    h = yxzCoordinate(1);
    w = yxzCoordinate(2);
    z = yxzCoordinate(3);
    if magicWandRadius > 0  % limit magic wand to smaller area
        options.x = [w-magicWandRadius w+magicWandRadius];  % calculate crop area
        options.y = [h-magicWandRadius h+magicWandRadius];
        options.z = [z-magicWandRadius z+magicWandRadius];
        % recalculate x and y for the obtained cropped image
        w = magicWandRadius + min([options.x(1) 1]);
        h = magicWandRadius + min([options.y(1) 1]);
        z = magicWandRadius + min([options.z(1) 1]);
        
        ib_do_backup(handles, 'selection', 1, options);
    else
        options = struct();
        ib_do_backup(handles, 'selection', 1);
    end
    
    datasetImage = handles.Img{handles.Id}.I.getData3D('image', NaN, orient, col_channel, options);
    
    val = datasetImage(h,w,1,z); % intensity
    upper = val+threshold2;
    lower = val-threshold1;
    selarea = zeros([size(datasetImage,1) size(datasetImage,2) size(datasetImage,4)], 'uint8');
    waitbar(0.3, wb);
    selarea(datasetImage>=lower & datasetImage<=upper) = 1;
    % limit to the selected material of the model
    if get(handles.segmSelectedOnlyCheck,'Value')
        datasetImage = handles.Img{handles.Id}.I.getData3D('model', NaN, orient, selcontour, options);
        selarea(datasetImage~=1) = 0;
        waitbar(0.4, wb);
    end
    % limit selection to the masked area
    if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist
        datasetImage = handles.Img{handles.Id}.I.getData3D('mask', NaN, orient, NaN, options);
        selarea(datasetImage~=1) = 0;
    end
    waitbar(0.5, wb);
    
    id = 0;
    if get(handles.magicwandConnectCheck,'Value') || get(handles.magicwandConnectCheck4,'Value');  % select only connected areas
        if get(handles.magicwandConnectCheck4,'Value')
            CC = bwconncomp(selarea,6); % 6-neighbour points
        else
            CC = bwconncomp(selarea,26); % 26-neighbour points
        end
        if CC.NumObjects == 0
            return;
        end;
        xyz_index = sub2ind(size(selarea),h,w,z);
        find_switch = 1;
        while find_switch
            id = id + 1;
            if id > numel(CC.PixelIdxList); 
                delete(wb);
                return; 
            end;
            if ~isempty(find(CC.PixelIdxList{id}==xyz_index,1,'first'))
                find_switch = 0;
            end
        end
        selarea = zeros(size(selarea), 'uint8');
        selarea(CC.PixelIdxList{id}) = 1;
    end
    
    if magicWandRadius > 0
        distMap =  zeros(size(selarea), 'uint8');
        distMap(h, w, z) = 1;
        distMap = bwdist(distMap);
        selarea(distMap>magicWandRadius) = 0;
    end
    waitbar(0.9, wb);
        
    if isempty(modifier)
        handles.Img{handles.Id}.I.clearSelection();
        handles.Img{handles.Id}.I.setData3D('selection', selarea, NaN, orient, NaN, options);
    elseif strcmp(modifier, 'shift')    % combines selections
        currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, orient, NaN, options);
        handles.Img{handles.Id}.I.setData3D('selection', bitor(currSelection, selarea), NaN, orient, NaN, options);
    elseif strcmp(modifier, 'control')  % subtracts selections
        currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, orient, NaN, options);
        currSelection(selarea==1) = 0;
        handles.Img{handles.Id}.I.setData3D('selection', currSelection, NaN, orient, NaN, options);
    end
    waitbar(1, wb);
    delete(wb);
end
toc
end