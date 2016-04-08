function handles = ib_segmentBlackWhiteThreshold(handles, hObject)
% function handles = ib_segmentBlackWhiteThreshold(handles, hObject)
% Perform black and white thresholding for @em BW @em Threshold tool of the 'Segmentation
% panel'
%
% Parameters:
% handles: structure with handles of im_browser.m
% hObject: a handle of the calling object
% - ''segmLowEdit'' - callback after enter a new value to the handles.segmLowEdit editbox
% - ''segmHighEdit'' - callback after enter a new value to the handles.segmHighEdit editbox
% - ''segmLowSlider'' - callback after interacting with the handles.segmLowSlider slider
% - ''segmHighSlider'' - callback after interacting with the handles.segmHighSlider slider
%
% Return values:
% handles: structure with handles of im_browser.m

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 25.01.2016, IB, updated for 4D

% do black and white thresholding for segmentation
switch get(hObject,'tag')
    case 'segmLowEdit';
        val = round(str2double(get(handles.segmLowEdit,'String')));
        if val > intmax(class(handles.Img{handles.Id}.I.img))
            val = intmax(class(handles.Img{handles.Id}.I.img));
            set(hObject,'String', num2str(val));
        end
        set(handles.segmLowSlider,'Value',val);
    case 'segmHighEdit'
        val = round(str2double(get(handles.segmHighEdit,'String')));
        if val > intmax(class(handles.Img{handles.Id}.I.img))
            val = intmax(class(handles.Img{handles.Id}.I.img));
            set(hObject,'String', num2str(val));
        end
        set(handles.segmHighSlider,'Value',val);
    case 'segmLowSlider'
        val = round(get(handles.segmLowSlider,'Value'));
        if val > intmax(class(handles.Img{handles.Id}.I.img))
            val = intmax(class(handles.Img{handles.Id}.I.img));
            set(hObject,'Value', val);
        end
        set(handles.segmLowEdit,'String',num2str(val));
    case 'segmHighSlider'
        val = round(get(handles.segmHighSlider,'Value'));
        if val > intmax(class(handles.Img{handles.Id}.I.img))
            val = intmax(class(handles.Img{handles.Id}.I.img));
            set(hObject,'Value', val);
        end
        set(handles.segmHighEdit,'String',num2str(val));
end
val1 = round(get(handles.segmLowSlider,'Value'));
val2 = round(get(handles.segmHighSlider,'Value'));

selected = get(handles.segmSelectedOnlyCheck,'Value');  % do only for selected material
masked = get(handles.maskedAreaCheck, 'value');     % do only for masked material
model_id = get(handles.segmSelList,'Value')-2;
color_channel = get(handles.ColChannelCombo,'Value') - 1;
if color_channel == 0
    msgbox('Please select the color channel!','Wrong color channel!','error');
    return;
end
backgroundColor = get(hObject,'BackgroundColor');

if get(handles.segmBWthres3D,'Value') || get(handles.segmBWthres4D,'Value') % do segmentation for the whole dataset
    if get(handles.segmBWthres4D, 'value') == 1
        t1 = 1;
        t2 = handles.Img{handles.Id}.I.time;
    else
        t1 = handles.Img{handles.Id}.I.slices{5}(1);
        t2 = handles.Img{handles.Id}.I.slices{5}(1);
        ib_do_backup(handles, 'selection', 1);
    end
    handles.Img{handles.Id}.I.clearSelection(NaN, NaN, NaN, [t1, t2]);
    set(hObject,'BackgroundColor',[1 0 0]);
    drawnow;
    for t=t1:t2
        img = handles.Img{handles.Id}.I.getData3D('image', t, 4, color_channel);  % get dataset
        selection = zeros(size(img,1),size(img,2),size(img,4),'uint8');  % generate new selection
        
        if masked == 1
            mask = handles.Img{handles.Id}.I.getData3D('mask', t, 4);    % get mask
            STATS = regionprops(uint8(mask), 'BoundingBox');    % calculate the bounding box for the mask
            if numel(STATS) == 0; continue; end;
            BBox = round(STATS.BoundingBox);
            if numel(BBox) == 4
                BBox = [BBox(1) BBox(2) 1 BBox(3) BBox(4) 1];
            end
            
            indeces(1,:) = [BBox(2), BBox(2)+BBox(5)-1];
            indeces(2,:) = [BBox(1), BBox(1)+BBox(4)-1];
            indeces(3,:) = [1, size(handles.Img{handles.Id}.I.img,3)];
            indeces(4,:) = [BBox(3), BBox(3)+BBox(6)-1];
            % crop image to the masked area
            img = img(indeces(1,1):indeces(1,2),indeces(2,1):indeces(2,2),color_channel,indeces(4,1):indeces(4,2));
            % crop the mask
            mask = mask(indeces(1,1):indeces(1,2),indeces(2,1):indeces(2,2),indeces(4,1):indeces(4,2));
            
            % generate cropped selection
            selection2 = zeros(size(img,1),size(img,2),size(img,4),'uint8');
            selection2(img>=val1 & img <= val2) = 1;
            selection2 = selection2 & mask;
            
            if selected
                if handles.Img{handles.Id}.I.blockModeSwitch
                    if handles.Img{handles.Id}.I.orientation==1     % xz
                        shiftX = max([ceil(handles.Img{handles.Id}.I.axesY(1)) 0]);
                        shiftY = 0;
                        shiftZ = max([ceil(handles.Img{handles.Id}.I.axesX(1)) 0]);
                    elseif handles.Img{handles.Id}.I.orientation==2 % yz
                        shiftX = 0;
                        shiftY = max([ceil(handles.Img{handles.Id}.I.axesY(1)) 0]);
                        shiftZ = max([ceil(handles.Img{handles.Id}.I.axesX(1)) 0]);
                    elseif handles.Img{handles.Id}.I.orientation==4 % yx
                        shiftX = max([ceil(handles.Img{handles.Id}.I.axesX(1)) 0]);
                        shiftY = max([ceil(handles.Img{handles.Id}.I.axesY(1)) 0]);
                        shiftZ = 0;
                    end
                else
                    shiftX = 0;
                    shiftY = 0;
                    shiftZ = 0;
                end
                Options.x = [indeces(2,1), indeces(2,2)]+shiftX;
                Options.y = [indeces(1,1), indeces(1,2)]+shiftY;
                Options.z = [indeces(4,1), indeces(4,2)]+shiftZ;
                model = handles.Img{handles.Id}.I.getData3D('model', NaN, 4, model_id, Options);
                selection2(model ~= 1) = 0;
            end
            selection(indeces(1,1):indeces(1,2),indeces(2,1):indeces(2,2),indeces(4,1):indeces(4,2)) = selection2;
        else
            selection(img>=val1 & img <= val2) = 1;
            
            if selected
                model = handles.Img{handles.Id}.I.getData3D('model', t, 4, model_id);
                selection = selection & model;
            end
        end
        handles.Img{handles.Id}.I.setData3D('selection', selection, t, 4);
    end
else    % do segmentation for the current slice only
    ib_do_backup(handles, 'selection', 0);
    img = handles.Img{handles.Id}.I.getCurrentSlice('image', color_channel);
    selection = zeros(size(img,1),size(img,2),size(img,4),'uint8');  % generate new selection
    selection(img>=val1 & img <= val2) = 1;
    if masked == 1
        mask = handles.Img{handles.Id}.I.getCurrentSlice('mask');
        selection(mask ~= 1) = 0;
    end
    if selected
        model = handles.Img{handles.Id}.I.getCurrentSlice('model');
        selection(model ~= model_id) = 0;
    end
    handles.Img{handles.Id}.I.setCurrentSlice('selection', selection);
end
set(hObject,'BackgroundColor',backgroundColor);

end