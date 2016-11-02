function handles = ib_sizeExclusionFilter(handles, type)
% function handles = ib_sizeExclusionFilter(handles, type)
% Apply size exclusion filter on selection, model, or mask layers
%
% Parameters:
% handles: structure with handles of im_browser.m
% type: a type of the layer for the size exclusion filter:
% - ''selection'' - run size exclusion on the 'Selection' layer
% - ''mask'' - - run size exclusion on the 'Mask' layer
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
% 21.02.2016, IB, updated for 4D datasets
% 25.10.2016, IB, updated for segmentation table

title = 'Size filtration of objects';
switch type
    case 'selection'
        prompt = {sprintf('Doing for the selection layer\n\nKeep objects larger than, px:'),...
                    'Keep objects smaller than, px:','Current layer only ["1"-current, "0"-3D mode, "NaN"-4D mode]:',sprintf('3d (Put 0 for 2D objects;\n6, 18, or 26 connection options for 3D objects)')};
    case 'model'
        userData = get(handles.segmTable,'UserData');
        sel_model = userData.prevMaterial - 2;
        prompt = {sprintf('Doing for material No: %d\n\nKeep objects larger than, px:',sel_model),...
                    'Keep objects smaller than, px:','Current layer only ["1"-current, "0"-3D mode, "NaN"-4D mode]:',sprintf('3d (Put 0 for 2D objects;\n6, 18, or 26 connection options for 3D objects)')};
    case 'mask'
        prompt = {sprintf('Doing for masked area\n\nKeep objects larger than, px:'),...
                    'Keep objects smaller than, px:','Current layer only ["1"-current, "0"-3D mode, "NaN"-4D mode]:',sprintf('3d (Put 0 for 2D objects;\n6, 18, or 26 connection options for 3D objects)')};
end
answer = inputdlg(prompt,title,[1 30],{'','','1','0'},'on');    
if size(answer) == 0; return; end; 

lo_lim = str2double(answer{1});
hi_lim = str2double(answer{2});
single_layer = str2double(answer{3});

if isnan(single_layer)  % do for 4D dataset
    t1 = 1;
    t2 = handles.Img{handles.Id}.I.time;
    single_layer = 0;
else
    t1 = handles.Img{handles.Id}.I.slices{5}(1);
    t2 = handles.Img{handles.Id}.I.slices{5}(1);
end

par_3d = str2double(answer{4});
if single_layer == 1
    start_no = 1;
    end_no = 1;
    switch3d = 0;
else
    start_no = 1;
    end_no = size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation);
    switch3d = 1;
end

wb = waitbar(0,'Please wait...','Name','Size filtration...','WindowStyle','modal');

if t1 == t2
    ib_do_backup(handles, type, switch3d);
end
options.fillBg = 0;
for t=t1:t2
    if par_3d   % do filter for 3D objects
        selection = ib_getStack(type, handles, t, 4, NaN, options);
        for roi=1:numel(selection)
            if ~isnan(hi_lim)
                selection{roi} = selection{roi} - uint8(bwareaopen(selection{roi}, hi_lim, par_3d));  % remove objects larger than hi_lim
            end
            if ~isnan(lo_lim)
                selection{roi} = uint8(bwareaopen(selection{roi}, lo_lim, par_3d));  % remove all 3d objects smaller than lo_lim
            end
        end
        ib_setStack(type, selection, handles, t, 4);
    else  % do Selection filter in 2D
        if start_no==end_no     % a single slice
            selection = ib_getSlice(type, handles, NaN, NaN, NaN, options);
        else
            selection = ib_getStack(type, handles, t, NaN, NaN, options);
        end
        for roi=1:numel(selection)
            for ind = start_no:end_no
                waitbar(ind/(end_no-start_no),wb);
                if ~isnan(hi_lim)
                    selection{roi}(:,:,ind) = selection{roi}(:,:,ind) - uint8(bwareaopen(selection{roi}(:,:,ind), hi_lim));
                elseif ~isnan(lo_lim)
                    selection{roi}(:,:,ind) = uint8(bwareaopen(selection{roi}(:,:,ind), lo_lim));
                end
            end
        end
        if start_no==end_no     % a single slice
            ib_setSlice(type, selection, handles);
        else
            ib_setStack(type, selection, handles, t, NaN);
        end
    end
end

delete(wb);
end