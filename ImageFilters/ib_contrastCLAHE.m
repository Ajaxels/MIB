function handles = ib_contrastCLAHE(handles, mode)
% function handles = ib_contrastCLAHE(handles, mode)
% Do CLAHE Contrast-limited adaptive histogram equalization for the XY plane of the dataset for the currently shown or
% all slices
%
% Parameters:
% handles: structure with handles of im_browser.m
% mode: mode for use with CLAHE
% - @b 'CLAHE_2D' - apply for the currently shown slice
% - @b 'CLAHE_3D' - apply for the current shown stack
% - @b 'CLAHE_4D' - apply for the whole dataset

%
% Return values:
% handles: structure with handles of im_browser.m

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 08.03.2016, IB, updated for 4D datasets

colCh = get(handles.ColChannelCombo,'Value')-1;
prompt = {sprintf('You are going to change image contrast by Contrast-limited adaptive histogram equalization for color channel:%d\nYou can always undo it with Ctrl-Z\n\nEnter Number of Tiles:', colCh),...
    'Enter Clip Limit in the range [0 1] that specifies a contrast enhancement limit. Higher numbers result in more contrast:',...
    'Enter NBins, a positive integer scalar specifying the number of bins for the histogram used in building a contrast enhancing transformation. Higher values result in greater dynamic range at the cost of slower processing speed',...
    'Enter Distribution [uniform, rayleigh, exponential]:',...
    'Enter Alpha, a nonnegative real scalar specifying a distribution parameter, not for uniform distribution:'};
dlg_title = 'Enter CLAHE parameters';

def = {[num2str(handles.CLAHE.NumTiles(1)) ',' num2str(handles.CLAHE.NumTiles(2))],...
    num2str(handles.CLAHE.ClipLimit),num2str(handles.CLAHE.NBins),...
    handles.CLAHE.Distribution,num2str(handles.CLAHE.Alpha)};

answer = inputdlg(prompt,dlg_title,1,def);
if isempty(answer); return; end;
tic
wb = waitbar(0,'Adjusting contrast with CLAHE...','Name','CLAHE','WindowStyle','modal');
str2 = cell2mat(answer(1));
commas = strfind(str2,',');
handles.CLAHE.NumTiles(1) = str2double(str2(1:commas(end)-1));
handles.CLAHE.NumTiles(2) = str2double(str2(commas(end)+1:end));
handles.CLAHE.ClipLimit = str2double(cell2mat(answer(2)));
handles.CLAHE.NBins = str2double(cell2mat(answer(3)));
handles.CLAHE.Distribution = cell2mat(answer(4));
handles.CLAHE.Alpha = str2double(cell2mat(answer(5)));
pause(.5);

% when only 1 time point replace CLAHE_4D with CLAHE_3D
if strcmp(mode, 'CLAHE_4D') && handles.Img{handles.Id}.I.time ==1
    mode = 'CLAHE_3D';
end

if strcmp(mode, 'CLAHE_4D')
    timeVector = [1, handles.Img{handles.Id}.I.time];
elseif strcmp(mode, 'CLAHE_3D')
    ib_do_backup(handles, 'image', 1);
    timeVector = [handles.Img{handles.Id}.I.getCurrentTimePoint(), handles.Img{handles.Id}.I.getCurrentTimePoint()];
else
    ib_do_backup(handles, 'image', 0);
    timeVector = [handles.Img{handles.Id}.I.getCurrentTimePoint(), handles.Img{handles.Id}.I.getCurrentTimePoint()];
end

Distribution = handles.CLAHE.Distribution;
NumTiles = handles.CLAHE.NumTiles;
ClipLimit = handles.CLAHE.ClipLimit;
NBins = handles.CLAHE.NBins;
Alpha = handles.CLAHE.Alpha;

for t=timeVector(1):timeVector(2)
    if ~strcmp(mode, 'CLAHE_2D')
        img = ib_getStack('image', handles, t, NaN, colCh);
    else
        getDataOptions.t = [t t];
        img = ib_getSlice('image', handles, handles.Img{handles.Id}.I.getCurrentSliceNumber(), NaN, colCh,getDataOptions);        
    end
    
    for ind = 1:numel(img)
        img2 = img{ind};
        parfor z=1:size(img{1},4)
            if strcmp(Distribution,'uniform')
                img2(:,:,1,z) = adapthisteq(img2(:,:,1,z),...
                    'NumTiles',NumTiles,'clipLimit',ClipLimit,'NBins', NBins,...
                    'Distribution',Distribution);
            else
                img2(:,:,1,z) = adapthisteq(img2(:,:,1,z),...
                    'NumTiles',NumTiles,'clipLimit',ClipLimit,'NBins', NBins,...
                    'Distribution',Distribution,'Alpha', Alpha);
            end
        end
        img{ind} = img2;
    end
    
    if ~strcmp(mode, 'CLAHE_2D')
        ib_setStack('image', img, handles, t, NaN, colCh);
    else
        getDataOptions.t = [t t];
        ib_setSlice('image', img, handles, handles.Img{handles.Id}.I.getCurrentSliceNumber(), NaN, colCh,getDataOptions);
    end
    waitbar(t/(timeVector(2)-timeVector(1)),wb);    
end

log_text = ['CLAHE; NumTiles: ' num2str(handles.CLAHE.NumTiles) ';clipLimit: ' num2str(handles.CLAHE.ClipLimit)...
    ';NBins:' num2str(handles.CLAHE.NBins) ';Distribution:' handles.CLAHE.Distribution ';Alpha:' num2str(handles.CLAHE.Alpha) ';ColCh:' num2str(colCh)];
handles.Img{handles.Id}.I.updateImgInfo(log_text);
delete(wb);
toc
end
