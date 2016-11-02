function selectionFillBtn_Callback(hObject, eventdata, handles, sel_switch)
% function selectionFillBtn_Callback(~, eventdata, handles, sel_switch)
% a callback to the handles.selectionFillBtn, allows to fill holes for the Selection layer
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% sel_switch: a string that defines where filling of holes should be done:
% @li when @b '2D' fill holes for the currently shown slice
% @li when @b '3D' fill holes for the currently shown z-stack
% @li when @b '4D' fill holes for the whole dataset

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 29.01.2016, IB, updated for 4D
% 25.10.2016, IB, updated for segmentation table

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); return; end;
tic;
userData = get(handles.segmTable,'UserData');
selContour = userData.prevMaterial-2;
selectedOnly = get(handles.segmSelectedOnlyCheck,'Value');
if nargin < 4
    modifier = get(handles.im_browser,'currentModifier');
    if sum(ismember({'alt','shift'}, modifier)) == 2
        sel_switch = '4D';
    elseif sum(ismember({'alt','shift'}, modifier)) == 1
        sel_switch = '3D';
    else
        sel_switch = '2D';
    end
end
% tweak when only one time point
if strcmp(sel_switch, '4D') && handles.Img{handles.Id}.I.time == 1
    sel_switch = '3D';
end

if strcmp(sel_switch,'2D')
    ib_do_backup(handles, 'selection', 0);
    filled_img = imfill(handles.Img{handles.Id}.I.getCurrentSlice('selection'),'holes');
    if selectedOnly
        filled_img = filled_img & handles.Img{handles.Id}.I.getCurrentSlice('model', selContour);
    end
    handles.Img{handles.Id}.I.setCurrentSlice('selection', filled_img);
else 
    if strcmp(sel_switch,'3D') 
        ib_do_backup(handles, 'selection', 1);
        t1 = handles.Img{handles.Id}.I.slices{5}(1);
        t2 = handles.Img{handles.Id}.I.slices{5}(2);
        wb = waitbar(0,'Filling holes in 2D for a whole Z-stack...','WindowStyle','modal');
    else
        t1 = 1;
        t2 = handles.Img{handles.Id}.I.time;
        wb = waitbar(0,'Filling holes in 2D for a whole dataset...','WindowStyle','modal');
    end
    max_size = size(handles.Img{handles.Id}.I.img,handles.Img{handles.Id}.I.orientation);
    max_size2 = max_size*(t2-t1+1);
    index = 1;
    
    for t=t1:t2
        options.t = [t, t];
        for layer_id=1:max_size
            if mod(index, 10)==0; waitbar(layer_id/max_size2, wb); end;
            slice = handles.Img{handles.Id}.I.getData2D('selection', layer_id, handles.Img{handles.Id}.I.orientation, 0, NaN, options);
            if max(max(slice)) < 1; continue; end;
            slice = imfill(slice,'holes');
            if selectedOnly
                slice = slice & handles.Img{handles.Id}.I.getData2D('model', layer_id, handles.Img{handles.Id}.I.orientation, selContour, NaN, options);
            end
            handles.Img{handles.Id}.I.setData2D('selection', slice, layer_id, handles.Img{handles.Id}.I.orientation, 0, NaN, options);
            index = index + 1;
        end
    end
    delete(wb);
    toc
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end