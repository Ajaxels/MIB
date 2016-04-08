function handles = ib_linearContrast(handles)
% function handles = ib_linearContrast(handles)
% Linear Contrast adjustment for all or only shown image(s)
%
% Parameters:
% handles: structure with handles of im_browser.m
%
% Return values:
% handles: structure with handles of im_browser.m

% Copyright (C) 13.02.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 08.03.2016, IB, updated for use with 4D datasets


colorChannel = get(handles.ColChannelCombo,'Value') - 1;
if colorChannel == 0
    msgbox(sprintf('Please select the color channel!\n\nSelection Panel->Color channel'),'Error!','error','modal');
    return;
end

answer = questdlg(sprintf('!!! WARNING !!!\nThis function will recalculate intensities of the images!!!\nIf you want to adjust contrast without modification of intensities, please use the Display button in the View Settings panel!\n\nSelected color channel: %d\n\nWould you like to proceed for all or only selected images?', colorChannel),...
    'Contrast settings','Complete stack','Shown image','Cancel','Complete stack');
time_pnt = handles.Img{handles.Id}.I.getCurrentTimePoint();

switch answer
    case 'Complete stack'
        img = ib_getStack('image', handles, time_pnt, 4, colorChannel);
        start_no = 1;
        finish_no = size(img{1}, 4);
        switch3d = 1;
        sliceNo = handles.Img{handles.Id}.I.getCurrentSliceNumber();
    case 'Shown image'
        getDataOptions.t = [time_pnt, time_pnt];
        sliceNo = handles.Img{handles.Id}.I.getCurrentSliceNumber();
        img = ib_getSlice('image', handles, sliceNo, NaN, colorChannel, getDataOptions);
        start_no = 1;
        finish_no = start_no;
        switch3d = 0;
    case 'Cancel'
        return;
end
for roi=1:numel(img)
    min_val(roi) = min(min(min(min(img{roi})))); %#ok<AGROW>
    max_val(roi) = max(max(max(max(img{roi})))); %#ok<AGROW>
end
min_val = min(min_val);
max_val = max(max_val);
answer = inputdlg({sprintf('Enter new contrast values\nfor channel %d\n\nMinimum value:',colorChannel),'Maximum value'},sprintf('Channel %d Contrast',colorChannel),1,{num2str(min_val),num2str(max_val)});
if isempty(answer); return; end;
min_val = round(str2double(cell2mat(answer(1))));
max_val = round(str2double(cell2mat(answer(2))));
if min_val < 0 || max_val < 0
    msgbox(sprintf('Error!\nNumbers should be positive integers!\nPlease try again...'),'Error!','error','modal');
    return;
end
ib_do_backup(handles, 'image', switch3d);

wb = waitbar(0,'Adjusting Contrast...','Name','Contrast','WindowStyle','modal');
max_int = double(intmax(class(handles.Img{handles.Id}.I.img)));

if start_no==finish_no          % single slice
    for ind = 1:numel(img)
        img{ind} = imadjust(img{ind},[min_val/max_int max_val/max_int],[0 1]);
    end
    ib_setSlice('image', img, handles, sliceNo, NaN, colorChannel, getDataOptions);
else        % volume
    maxIndex = numel(img)*(finish_no-start_no);
    index = 1;
    for ind = 1:numel(img)
        for i=start_no:finish_no
            img{ind}(:,:,:,i) = imadjust(img{ind}(:,:,:,i),[min_val/max_int max_val/max_int],[0 1]);
            if mod(index,25)==0; waitbar(index/maxIndex,wb); end;
            index = index + 1;
        end
    end
    ib_setStack('image', img, handles, time_pnt, 4, colorChannel);
end
delete(wb);
log_text = ['LinContrast; Min:' num2str(min_val) '; Max:' num2str(max_val),'; ColCh:' num2str(colorChannel)];
handles.Img{handles.Id}.I.updateImgInfo(log_text);
end