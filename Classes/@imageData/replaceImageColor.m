function handles = replaceImageColor(obj, handles, type)
% function handles = replaceImageColor(obj, handles, type)
% Replace image intensities in the @em Masked or @em Selected areas with new intensity value
%
% The function starts a dialog that asks for a new intensity values to replace either the Masked or Selected areas.
%
% Parameters:
% handles: handles of im_browser.m
% type: specifies which layer to use for color replacement: ''mask'' or ''selection''
%
% Return values:
% handles: handles of im_browser.m

%| 
% @b Examples:
% @code handles = imageData.replaceImageColor(handles, 'mask');  // to replace the Masked areas with new color @endcode
% @code handles = replaceImageColor(obj, handles, 'selection');   // Call within the class; to replace the Selected areas with new color @endcode

% Copyright (C) 07.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.09.2015, IB adapted to use imageData.getData3D method
% 18.01.2016, IB, added fix for memory function on Linux and macOs
% 21.02.2016, IB, updated for 4D datasets

if strcmp(obj.img_info('ColorType'),'indexed')
    msgbox('Can''t work with indexed images!');
    return;
end
prompt = {sprintf('Your are going to replace the *%s* area in the image.\nPlease provide intensity of a new color [0-%d]:',type,intmax(class(obj.img))),'Slice number (0 for all):','Color channels (0 for all):'};
title = 'Replace color';
slice_no = obj.getCurrentSliceNumber();
max_slice = size(obj.img, obj.orientation);
def = {repmat('0;',1,size(obj.img,3)),num2str(slice_no),'1'};
answer = inputdlg(prompt,title,1,def,'on');
if size(answer) == 0; return; end;
tic
color_id = str2num(answer{1}); %#ok<ST2NM>
if numel(color_id) ~= size(obj.img,3)
    color_id = repmat(color_id(1),1,size(obj.img,3))';
end
slice_id = str2double(answer{2});
channel_id = str2double(answer{3});
wb = waitbar(0,sprintf('Replacing color channels\nPlease wait...'),'Name','Replace color','WindowStyle','modal');
if slice_id == 0
    t1 = 1;
    t2 = obj.time;
    if t1==t2
        ib_do_backup(handles, 'image', 1);
    end
    start_no = 1;
    end_no = max_slice;
    if ispc()
        % check available memory, available only on windows
        [~, systemview] = memory;
        totalSize = obj.getDatasetSizeInBytes();
        if systemview.PhysicalMemory.Available - totalSize < 0
            switch3d = 0;   % do slice by slice
        else
            switch3d = 1;
        end
    else
        switch3d = 0;   % do slice by slice
    end
else
    ib_do_backup(handles, 'image', 0);
    start_no = slice_id;
    end_no = slice_id;
    switch3d = 0;
    t1 = obj.slices{5}(1);
    t2 = obj.slices{5}(1);
end
if channel_id == 0
    start_ch = 1;
    end_ch = size(obj.img,3);
else
    start_ch = channel_id;
    end_ch = channel_id;
end
if switch3d == 0  % do for a single slice
    totalnumber = (end_no-start_no)*(t2-t1+1);
    for t=t1:t2
        getDataOptions.t = [t t];
        for sliceNumber = start_no:end_no
            mask_img = obj.getSlice(type, sliceNumber, NaN, 0, NaN, getDataOptions);
            if sum(sum(mask_img)) < 1; continue; end;
            
            curr_img = obj.getSlice('image', sliceNumber, NaN, 0, 0, getDataOptions);            
            for channel = start_ch:end_ch
                img2 = curr_img(:,:,channel);
                img2(mask_img==1) = color_id(channel);
                curr_img(:,:,channel) = img2;
            end
            obj.setSlice('image', curr_img, sliceNumber, NaN, 0, 0, getDataOptions);
            if mod(sliceNumber, 10)==0; waitbar((sliceNumber-start_no)/totalnumber,wb); end;
        end
    end
else                    % do for 3D
    waitbar(0.05, wb);
    for t=t1:t2
        mask_img = obj.getData3D(type, t, 4);
        mask_img = reshape(mask_img, [size(mask_img,1), size(mask_img,2), 1, size(mask_img,3)]);
        if sum(sum(sum(mask_img))) < 1; continue; end;
        
        for channel = start_ch:end_ch
            curr_img = obj.getData3D('image', t, 4, channel);
            curr_img(mask_img==1) = color_id(channel);
            obj.setData3D('image', curr_img, t, 4, channel);
        end
        waitbar(t/t2, wb);
    end
end
waitbar(1,wb);
log_text = ['Color channels: ' num2str(start_ch) ':' num2str(end_ch) ' were replaced with new intensity(s): ' num2str(color_id(start_ch:end_ch)')];
handles.Img{handles.Id}.I.updateImgInfo(log_text);
disp(log_text);
delete(wb);
toc
end