function handles = ib_erodeSelection(handles, sel_switch)
% function handles = ib_erodeSelection(handles, sel_switch)
% Erode (shrink) the 'Selection' layer in 2D or 3D
%
% Parameters:
% handles: structure with handles of im_browser.m
% sel_switch: a string that defines where erosion should be done:
% @li when @b '2D' erode for the currently shown slice
% @li when @b '3D' erode for the currently shown z-stack
% @li when @b '4D' erode for the whole dataset
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
% 30.06.2014: IB, changed from rectangle to circle strel 
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 29.01.2016, IB, updated for 4D; changed sel_switch parameters from 'current'->'2D', 'all'->'3D', , added '4D'

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); return; end;

% tweak when only one time point
if strcmp(sel_switch, '4D') && handles.Img{handles.Id}.I.time == 1
    sel_switch = '3D';
end

switch3d = get(handles.actions3dCheck,'Value');
if switch3d == 1
    button = questdlg(sprintf('You are going to erode the image in 3D!\nContinue?'),'Erode 3D objects','Continue','Cancel','Continue');
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

se_size_txt = get(handles.strelSizeEdit,'String');
semicolon = strfind(se_size_txt,';');
if ~isempty(semicolon)  % when 2 values are provided take them
    se_size(1) = str2double(se_size_txt(1:semicolon(1)-1));     % for y and x
    se_size(2) = str2double(se_size_txt(semicolon(1)+1:end));   % for z (or x in 2d mode)
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

if switch3d         % do in 3D
    wb = waitbar(0,sprintf('Eroding selection...\nStrel size: XY=%d x Z=%d',se_size(1)*2+1,se_size(2)*2+1),'Name','Eroding...','WindowStyle','modal');
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
        selection = imerode(selection, se);
        if diff_switch
            selection = imabsdiff(selection, handles.Img{handles.Id}.I.getData3D('selection', t, 4));
        end
        handles.Img{handles.Id}.I.setData3D('selection',selection, t, 4);
        index = index + 1;
    end
    delete(wb);
else    % do in 2d layer by layer
    %se = strel('disk',[se_size(1) se_size(2)],0);
    %se = strel('rectangle',[se_size(1) se_size(2)]);
    
    se = zeros([se_size(1)*2+1 se_size(2)*2+1],'uint8');
    se(se_size(1)+1,se_size(2)+1) = 1;
    se = bwdist(se); 
    se = uint8(se <= se_size(1));

    if strcmp(sel_switch,'2D')
        eroded_img = imerode(handles.Img{handles.Id}.I.getCurrentSlice('selection'),se);
        if diff_switch   % if 1 will make selection as a difference
            eroded_img = handles.Img{handles.Id}.I.getCurrentSlice('selection')-eroded_img;
        end
        handles.Img{handles.Id}.I.setCurrentSlice('selection', eroded_img);
    else
        wb = waitbar(0,sprintf('Eroding selection...\nStrel size: %dx%d px', se_size(1),se_size(2)),'Name','Eroding...','WindowStyle','modal');
        max_size = size(handles.Img{handles.Id}.I.img,handles.Img{handles.Id}.I.orientation);
        max_size2 = max_size*(t2-t1+1);
        index = 1;
        
        for t=t1:t2
            options.t = [t, t];
            for layer_id=1:max_size
                if mod(layer_id, 10)==0; waitbar(index/max_size2, wb); end;
                slice = handles.Img{handles.Id}.I.getData2D('selection', layer_id, handles.Img{handles.Id}.I.orientation, 0, NaN, options);
                if max(max(slice)) < 1; continue; end;
                eroded_img = imerode(slice, se);
                if diff_switch   % if 1 will make selection as a difference
                    eroded_img = slice - eroded_img;
                end
                handles.Img{handles.Id}.I.setData2D('selection', eroded_img, layer_id, handles.Img{handles.Id}.I.orientation, 0, NaN, options);
                index = index + 1;
            end
        end
        delete(wb);
    end
end
end