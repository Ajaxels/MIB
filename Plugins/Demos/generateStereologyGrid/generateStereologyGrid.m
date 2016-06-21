function handles = generateStereologyGrid(par1, par2, h_im_browser)
% function handles = generateStereologyGrid(par1, par2, h_im_browser)
% a plugin for Microscopy Image Browser.
% This plugin generates a grid with a user-defined step and places it over
% the image in the Mask layer

% Copyright (C) 29.09.2015 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% Parameters:
% par1, par2 will not be used
% h_im_browser - is a handle to the main program (im_browser)

% get the handles structure of the main program
handles = guidata(h_im_browser);

options.blockModeSwitch = 0;    % turn off the blockmode switch to get dimensions of the whole dataset
[height, width, color, depth, time] = handles.Img{handles.Id}.I.getDatasetDimensions('image', NaN, 0, options);

if handles.Img{handles.Id}.I.maskExist == 1
    button = questdlg(sprintf('!!! Warning !!!\n\nThe existing mask layer will be replaced with the grid!'),'Generate grid','Continue','Cancel','Cancel');
    if strcmp(button, 'Cancel'); return; end;
end
answer = mib_inputdlg(handles, 'Please enter a step for the grid in pixels','Grid step','50');
if size(answer) == 0; return; end;
gridStep = str2double(answer{1});

wb = waitbar(0,sprintf('Generating the grid\nPlease wait...'), 'Name', 'Stereology grid');
% allocate space for the mask
mask = zeros([height, width, depth],'uint8');
waitbar(0.1, wb);

offset = ceil(gridStep/2);

mask(1+offset:gridStep:end,:,:) = 1;
waitbar(0.4, wb);
mask(:,1+offset:gridStep:end,:) = 1;
waitbar(0.8, wb);

% keep mask for the ROI area only
if get(handles.roiShowCheck, 'value')
    roiMask = handles.Img{handles.Id}.I.hROI.returnMask(0);
    for slice=1:size(mask,3)
        mask(:,:,slice) = mask(:,:,slice) & roiMask;
    end
end

handles.Img{handles.Id}.I.setData3D('mask', mask, NaN, NaN, 0, options);
waitbar(0.95, wb);
set(handles.maskShowCheck, 'value', 1);
waitbar(1, wb);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
delete(wb);
warndlg(sprintf('!!! Warning !!!\n\nPlease note that the proper grid is shown only at magnification of 100%% and higher!'),'Grid info','modal');
end
