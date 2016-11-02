function handles = ib_dilateSelection(handles, sel_switch)
% function handles = ib_dilateSelection(handles, sel_switch)
% Dilate (expand) the 'Selection' layer in 2D or 3D
%
% Parameters:
% handles: structure with handles of im_browser.m
% sel_switch: a string that defines where dilation should be done:
% @li when @b '2D' dilate for the currently shown slice
% @li when @b '3D' dilate for the currently shown z-stack
% @li when @b '4D' dilate for the whole dataset
%
% Return values:
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 30.06.2014, IB, changed from rectangle to circle strel
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 29.01.2016, IB, updated for 4D; changed sel_switch parameters from 'current'->'2D', 'all'->'3D', , added '4D'
% 25.10.2016, IB, updated for segmentation table

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); return; end;

% tweak when only one time point
if strcmp(sel_switch, '4D') && handles.Img{handles.Id}.I.time == 1
    sel_switch = '3D';
end

switch3d = get(handles.actions3dCheck,'Value');
if switch3d == 1
    button = questdlg(sprintf('You are going to dilate the image in 3D!\nContinue?'),'Dilate 3D objects','Continue','Cancel','Continue');
    if strcmp(button, 'Cancel'); return; end;
end

if (switch3d && ~strcmp(sel_switch, '4D') ) || strcmp(sel_switch, '3D')
    ib_do_backup(handles, 'selection', 1);
else
    ib_do_backup(handles, 'selection', 0);
end
diff_switch = get(handles.selDiffErDilCheck,'Value');   % if 1 will make selection as a difference

% define the time points
if strcmp(sel_switch, '4D')
    t1 = 1;
    t2 = handles.Img{handles.Id}.I.time;
else    % 2D, 3D
    t1 = handles.Img{handles.Id}.I.slices{5}(1);
    t2 = handles.Img{handles.Id}.I.slices{5}(2);
end

adapt_coef = str2double(get(handles.dilateAdaptCoefEdit,'String'));
sel_col_ch = get(handles.ColChannelCombo,'Value') - 1;
if sel_col_ch == 0 && get(handles.AdaptiveDilateCheck,'Value') == 1
    msgbox('Please select the color channel!','Error!','error','modal');
    return;
end
selected = NaN;
if get(handles.segmSelectedOnlyCheck,'Value')  % area for dilation is taken only from selected contour
    userData = get(handles.segmTable,'UserData');
    selected = userData.prevMaterial - 2;
end;

width = size(handles.Img{handles.Id}.I.img,2);
height = size(handles.Img{handles.Id}.I.img,1);
extraSmoothing = get(handles.adaptiveSmoothCheck, 'Value');

se_size_txt = get(handles.strelSizeEdit,'String');
semicolon = strfind(se_size_txt,';');
if ~isempty(semicolon)  % when 2 values are provided take them
    se_size(1) = str2double(se_size_txt(1:semicolon(1)-1));     % for x and y
    se_size(2) = str2double(se_size_txt(semicolon(1)+1:end));   % for z
else                    % when only 1 value - calculate the second from the pixSize
    if switch3d
        se_size(1) = str2double(se_size_txt); % for y and x
        se_size(2) = round(se_size(1)*handles.Img{handles.Id}.I.pixSize.x/handles.Img{handles.Id}.I.pixSize.z); % for z
    else
        se_size(1) = str2double(se_size_txt); % for y
        se_size(2) = se_size(1);    % for x
    end
end

if se_size(1) == 0 || se_size(2) == 0
    msgbox('Strel size should be larger than 0','Wrong strel size','error','modal');
    return;
end

if switch3d         % do in 3d
    wb = waitbar(0,sprintf('Dilating selection...\nStrel width: XY=%d x Z=%d',se_size(1)*2+1,se_size(2)*2+1),'Name','Dilating...','WindowStyle','modal');
    se = zeros(se_size(1)*2+1,se_size(1)*2+1,se_size(2)*2+1);    % do strel ball type in volume
    [x,y,z] = meshgrid(-se_size(1):se_size(1),-se_size(1):se_size(1),-se_size(2):se_size(2));
    %ball = sqrt(x.^2+y.^2+(se_size(2)/se_size(1)*z).^2);
    %se(ball<sqrt(se_size(1)^2+se_size(2)^2)) = 1;
    ball = sqrt((x/se_size(1)).^2+(y/se_size(1)).^2+(z/se_size(2)).^2);
    se(ball<=1) = 1;
    
    index = 1;
    tMax = t2-t1+1;
    for t=t1:t2
        waitbar(index/tMax, wb);
        selection = handles.Img{handles.Id}.I.getData3D('selection', t, 4);
        if isnan(selected)  % dilate to all pixels around selection
            selection = imdilate(selection, se);
        else                % dilate using pixels only from the selected countour
            model = handles.Img{handles.Id}.I.getData3D('model', t, 4, selected);
            selection = bitand(imdilate(selection,se), model);
        end
        if get(handles.AdaptiveDilateCheck,'Value')
            %selection = imdilate(handles.Img{handles.Id}.I.selection, se);
            img = handles.Img{handles.Id}.I.getData3D('image', t, 4, sel_col_ch);
            existingSelection = handles.Img{handles.Id}.I.getData3D('selection', t, 4);
            mean_val = mean2(img(existingSelection==1));
            std_val = std2(img(existingSelection==1))*adapt_coef;
            diff_mask = imabsdiff(selection, existingSelection); % get difference to see only added mask
            updated_mask = zeros(size(selection), 'uint8');
            img(~diff_mask) = 0;
            low_limit = mean_val-std_val;%-thres_down;
            high_limit = mean_val+std_val;%+thres_up;
            if low_limit < 1; low_limit = 1; end;
            if high_limit > 255; high_limit = 255; end;
            updated_mask(img>=low_limit & img<=high_limit) = 1;
            selection = existingSelection;
            selection(updated_mask==1) = 1;
            CC = bwconncomp(selection,18);  % keep it connected to the largest block
            [~, idx] = max(cellfun(@numel,CC.PixelIdxList));
            selection = zeros(size(selection),'uint8');
            selection(CC.PixelIdxList{idx}) = 1;
        end
        if diff_switch
            selection = imabsdiff(uint8(selection), handles.Img{handles.Id}.I.getData3D('selection', t, 4));
        end
        handles.Img{handles.Id}.I.setData3D('selection',selection, t, 4);
    end
else                % do in 2d
    %se = strel('rectangle',[se_size(1)*2+1 se_size(2)*2+1]);
    %se = strel('rectangle',[se_size(1) se_size(2)]);
    
    se = zeros([se_size(1)*2+1 se_size(2)*2+1],'uint8');
    se(se_size(1)+1,se_size(2)+1) = 1;
    se = bwdist(se);
    se = uint8(se <= se_size(1));
    
    connect8 = get(handles.magicwandConnectCheck,'Value');
    if strcmp(sel_switch,'2D')
        start_no = handles.Img{handles.Id}.I.getCurrentSliceNumber();
        end_no = start_no;
    else
        wb = waitbar(0,sprintf('Dilating selection...\nStrel size: %dx%d px', se_size(1),se_size(2)),'Name','Dilating...','WindowStyle','modal');
        start_no=1;
        end_no=size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation);
    end
    
    max_size2 = (end_no-start_no+1)*(t2-t1+1);
    index = 1;
    
    for t=t1:t2
        options.t = [t, t];
        for layer_id=start_no:end_no
            if t1 ~= t2 && mod(layer_id, 10)==0; waitbar(index/max_size2, wb); end;
            selection = handles.Img{handles.Id}.I.getData2D('selection', layer_id, handles.Img{handles.Id}.I.orientation, 0, NaN, options);
            if max(max(selection)) < 1; continue; end;
            if ~isnan(selected)
                model = handles.Img{handles.Id}.I.getData2D('model', layer_id, handles.Img{handles.Id}.I.orientation, selected, NaN, options);
            end

            if get(handles.AdaptiveDilateCheck,'Value')
                img = handles.Img{handles.Id}.I.getData2D('image', layer_id, handles.Img{handles.Id}.I.orientation, sel_col_ch, NaN, options);
                remember_selection = selection;
                STATS = regionprops(logical(remember_selection), 'BoundingBox','PixelList');    % get all original objects before dilation
                sel = zeros(size(selection),'uint8');
                
                for object=1:numel(STATS)   % cycle through the objects
                    bb =  floor(STATS(object).BoundingBox);
                    coordXY =  STATS(object).PixelList(1,:);    % coordinate of a pixel that belongs to selected object
                    coordXY(1) = coordXY(1)-max([1 bb(1)-ceil(se_size(2)/2)])+1;
                    coordXY(2) = coordXY(2)-max([1 bb(2)-ceil(se_size(1)/2)])+1;
                    
                    cropImg = img(max([1 bb(2)-ceil(se_size(1)/2)]):min([height bb(2)+bb(4)+ceil(se_size(1)/2)]), max([1 bb(1)-ceil(se_size(2)/2)]):min([width bb(1)+bb(3)+ceil(se_size(2)/2)])); % crop image
                    cropRemembered = remember_selection(max([1 bb(2)-ceil(se_size(1)/2)]):min([height bb(2)+bb(4)+ceil(se_size(1)/2)]), max([1 bb(1)-ceil(se_size(2)/2)]):min([width bb(1)+bb(3)+ceil(se_size(2)/2)])); % crop selection to an area around the object
                    if connect8
                        cropRemembered = bwselect(cropRemembered, coordXY(1),coordXY(2), 8);   % pickup only the object
                    else
                        cropRemembered = bwselect(cropRemembered, coordXY(1),coordXY(2), 4);   % pickup only the object
                    end
                    
                    if isnan(selected) % dilate to all pixels around selection
                        cropSelection = imdilate(cropRemembered,se);
                    else                % dilate using pixels only from the selected countour
                        cropModel = model(max([1 bb(2)-ceil(se_size(1)/2)]):min([height bb(2)+bb(4)+ceil(se_size(1)/2)]), max([1 bb(1)-ceil(se_size(2)/2)]):min([width bb(1)+bb(3)+ceil(se_size(2)/2)])); % crop model
                        cropSelection = imdilate(cropRemembered,se) & (cropModel==1 | cropRemembered);
                    end
                    
                    mean_val = mean2(cropImg(cropRemembered==1));
                    std_val = std2(cropImg(cropRemembered==1))*adapt_coef;
                    diff_mask = cropSelection - cropRemembered; % get difference to see only added mask
                    cropImg(~diff_mask) = 0;
                    low_limit = mean_val-std_val;
                    high_limit = mean_val+std_val;
                    if low_limit < 1; low_limit = 1; end;
                    if high_limit > 255; high_limit = 255; end;
                    newCropSelection = zeros(size(cropRemembered),'uint8');
                    newCropSelection(cropImg>=low_limit & cropImg<=high_limit) = 1;
                    newCropSelection(cropRemembered==1) = 1;    % combine original and new selection
                    
                    if extraSmoothing
                        se2 = strel('rectangle',[handles.adaptiveSmoothingFactor handles.adaptiveSmoothingFactor]);
                        newCropSelection = imdilate(imerode(newCropSelection,se2),se2);
                        newCropSelection(cropImg<low_limit & cropImg>high_limit) = 0;
                        newCropSelection(cropRemembered==1) = 1;    % combine original and new selection
                    end
                    if connect8
                        newCropSelection = bwselect(newCropSelection,coordXY(1),coordXY(2),8);   % get only a one connected object, removing unconnected components
                    else
                        newCropSelection = bwselect(newCropSelection,coordXY(1),coordXY(2),4);   % get only a one connected object, removing unconnected components
                    end
                    sel(max([1 bb(2)-ceil(se_size(1)/2)]):min([height bb(2)+bb(4)+ceil(se_size(1)/2)]), max([1 bb(1)-ceil(se_size(2)/2)]):min([width bb(1)+bb(3)+ceil(se_size(2)/2)])) = ...
                        newCropSelection | sel(max([1 bb(2)-ceil(se_size(1)/2)]):min([height bb(2)+bb(4)+ceil(se_size(1)/2)]), max([1 bb(1)-ceil(se_size(2)/2)]):min([width bb(1)+bb(3)+ceil(se_size(2)/2)]));
                end
                if diff_switch
                    sel = sel-remember_selection;
                end
            else
                if diff_switch  % result of dilation is only expantion of the area
                    if isnan(selected)  % dilate to all pixels around selection
                        sel = imdilate(selection,se)-selection;
                    else                % dilate using pixels only from the selected countour
                        sel = imdilate(selection,se) & model==selected;
                    end
                else            % result of dilation is object's area + expantion of that area
                    if isnan(selected)  % dilate to all pixels around selection
                        sel = imdilate(selection,se);
                    else                % dilate using pixels only from the selected countour
                        sel = imdilate(selection,se) & bitor(model, selection);
                    end
                end
            end
            handles.Img{handles.Id}.I.setData2D('selection', sel, layer_id, handles.Img{handles.Id}.I.orientation, 0, NaN, options);
        end
    end
end
if exist('wb','var'); delete(wb); end;

end