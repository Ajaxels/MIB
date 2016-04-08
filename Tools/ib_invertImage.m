function handles = ib_invertImage(handles, col_channel, sel_switch)
% function handles = ib_invertImage(handles, col_channel)
% Invert image
%
% Parameters:
% handles: structure with handles of im_browser.m
% col_channel: [@em optional] a list of color channels to invert; @b 0 to
% invert all color channels, @b NaN to invert shown color channels
% sel_switch: a string that defines part of the dataset to be inverted
% @li when @b '2D' dilate for the currently shown slice
% @li when @b '3D' dilate for the currently shown z-stack
% @li when @b '4D' dilate for the whole dataset
%
% Return values:
% handles: structure with handles of im_browser.m

% Copyright (C) 03.03.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, IB, changed .slices() to .slices{:}; .slicesColor->.slices{3}
% 23.03.2016, IB, updated for 4D datasets

if nargin < 3; sel_switch = '4D'; end;
if nargin < 2; col_channel = NaN; end;
if isnan(col_channel)
    if numel(get(handles.ColChannelCombo,'string'))-1 > numel(handles.Img{handles.Id}.I.slices{3})
        strText = sprintf('Would you like to invert shown or all channels?');
        button = questdlg(strText, 'Invert Image', 'Shown channels', 'All channels', 'Cancel', 'Shown channels');
        if strcmp(button, 'Cancel'); return; end;
        if strcmp(button, 'All channels')
            col_channel = 0;
        end
    end
end
        
maxval = intmax(class(handles.Img{handles.Id}.I.img));

% tweak when only one time point
if strcmp(sel_switch, '4D') && handles.Img{handles.Id}.I.time == 1
    sel_switch = '3D';
end
% do backup
if strcmp(sel_switch, '3D')
    ib_do_backup(handles, 'image', 1);
elseif strcmp(sel_switch, '2D')
    ib_do_backup(handles, 'image', 0);
end

% define the time points
if strcmp(sel_switch, '4D')
    t1 = 1;
    t2 = handles.Img{handles.Id}.I.time;
else    % 2D, 3D
    t1 = handles.Img{handles.Id}.I.slices{5}(1);
    t2 = handles.Img{handles.Id}.I.slices{5}(2);
end

showWaitbar = 0;
if ~strcmp(sel_switch,'2D')
    wb = waitbar(0,sprintf('Inverting image...\nPlease wait...'),'Name','Invert...','WindowStyle','modal');
    start_no=1;
    end_no=size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation);
    showWaitbar = 1;
    max_size2 = (end_no-start_no+1)*(t2-t1+1);
end

index = 1;
for t=t1:t2     % loop across time points
    if ~strcmp(sel_switch, '2D')
        img = ib_getStack('image', handles, t, 4, col_channel);
    else
        getDataOptions.t = [t t];
        img = ib_getSlice('image', handles, handles.Img{handles.Id}.I.getCurrentSliceNumber(), NaN, col_channel, getDataOptions);
    end
    
    for roi = 1:numel(img)  % loop across ROIs
        img{roi} = maxval - img{roi};
    end
    
    if ~strcmp(sel_switch, '2D')
        ib_setStack('image', img, handles, t, 4, col_channel);
    else
        getDataOptions.t = [t t];
        ib_setSlice('image', img, handles, handles.Img{handles.Id}.I.getCurrentSliceNumber(), NaN, col_channel, getDataOptions);
    end
    if showWaitbar==1; waitbar(index/max_size2, wb); end;
end

if isnan(col_channel); col_channel = handles.Img{handles.Id}.I.slices{3}; end;
log_text = sprintf('Invert, ColCh: %s', num2str(col_channel));
handles.Img{handles.Id}.I.updateImgInfo(log_text);
if showWaitbar==1; delete(wb); end;
end