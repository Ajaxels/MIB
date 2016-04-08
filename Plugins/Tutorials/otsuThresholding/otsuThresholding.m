function handles = otsuThresholding(par1, par2, h_im_browser)
% par1, par2 will not be used
% h_im_browser - is a handle to the main program (im_browser)

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 06.04.2016, IB, changed .slices() to .slices{:}; .slicesColor->.slices{3} and updated the text

% Please refer to the description of the process available from here:
% http://mib.helsinki.fi/tutorials_programming.html

% get the handles structure of the main program
% using this structure it is possible to obtain status of widgets within MIB GUI:
%    for example the following command returns the status of the show mask
%    checkbox: 1-checked, 0-unchecked:
%        value = get(handles.h.maskShowCheck,'value'); 
% and also get access to the classes that have dataset (see below)
handles.h = guidata(h_im_browser);

% get number of displayed color channels
% it is stored in the slices variables of handles.h.Img{handles.h.Id}.I
% class
col_channels = handles.h.Img{handles.h.Id}.I.slices{3};
if numel(col_channels) ~= 1;
    msgbox(sprintf('Warning!\nYou need to select a color channel for the thresholding.\nPlease keep only one channel in the View Settings Panel->Colors...'),'Wrong number of color channels!','Error');
    return;
end

% ask whether to threshold a single slice or a whole dataset
button = questdlg('Would you like to threshold a whole dataset or a single slice?','Otsu thresholding','Whole dataset','Single slice','Cancel','Whole dataset');
if strcmp(button, 'Cancel'); return; end;   % cancel and return

% preallocate space for the mask if it is not present
% maskExist variable keep information whether mask exist (1) or not (0)
if handles.h.Img{handles.h.Id}.I.maskExist == 0     
    % allocate space and set maskExist switch to 1
    handles.h.Img{handles.h.Id}.I.clearMask(0);      
else
    % store the existing Mask, so that the thresholding may be undone with Ctrl+Z
    handles.h = ib_do_backup(handles.h, 'mask', 1);
end

% threshold the current slice
if strcmp(button, 'Single slice')
    img = ib_getSlice('image', handles.h);
    % the 'image' parameter defines that the image is required, alternatively 
    % it can be: 'model', 'mask', or 'selection'
    % when other parameters omitted the function call will take the 
    % currently shown slice. The function returns a cell with image or 
    % an array with cells when several ROIs present.
    
    % do the Otsu thresholding, 
    % the for-loop is needed because the image is return as a cell-array.
    % When ROIs are shown number of elements in the array is equial to
    % number of ROIs. When ROIs are not present the cell-array has only one
    % element.
    for roi=1:numel(img)
        level = graythresh(img{roi});  
        % use the same variable to store the thresholded image
        img{roi} = im2bw(img{roi}, level);
    end
    
    % update the Mask layer with a new mask
    ib_setSlice('mask', img, handles.h);
end

% threshold the whole dataset

% since it may take time, lets add a waitbar to show the progress of the
% operation
wb = waitbar(0, 'Please wait...','Name','Otsu thresholding');
% calculate the number of sections to process
maxIndex = ...
    handles.h.Img{handles.h.Id}.I.time*handles.h.Img{handles.h.Id}.I.no_stacks;
% create a counter
counter = 1;

if strcmp(button, 'Whole dataset')
    % do the loop via the time dimension
    % if you never plan to work with the time dimension this loop
    % can be omitted
    for t=1:handles.h.Img{handles.h.Id}.I.time
        % ---------------- Method A ---------------------------
        % Method A, get copy of the complete dataset
        % if you want to use this method, comment the method B
        
        % get 3D stack
        img = ib_getStack('image', handles.h, t);
        
        % loop across number of ROI,
        % when ROIs are not shown the loop is one element only
        for roi=1:numel(img)
            for slice = 1:size(img{roi},4)
                % do the Otsu thresholding
                level = graythresh(img{roi}(:,:,:,slice));
                % use the same variable to store the thresholded image
                img{roi}(:,:,:,slice) = im2bw(img{roi}(:,:,:,slice),level);
                waitbar(counter/maxIndex, wb);  % update the waitbar
                counter = counter + 1;  % increase the counter
            end
            
            % at the end we should squeeze dataset, because dimensions of
            % the mask are [height, width, depth, time]
            % and convert it to 8bit (because you might threshold the
            % 16bit image
            img{roi} = squeeze(uint8(img{roi}));
        end
        % return stack to the Mask layer
        ib_setStack('mask', img, handles.h, t);
        
        % ---------------- Method A end of comment ---------------------------
        
                
        % ---------------- Method B ---------------------------
        % Method B, threshold not the whole dataset but slice by slice. It is slower but requres less memory
        % if you want to use this method, comment the method A
        
        % define orientation to use: 1, 2 or 4 (xy)
        orientation = 4;    
        
        % define the time point of the Z-stack, it is not needed when when the t-loop is omitted
        options.t = [t t];  
        
        % make a loop across slices of Z-stacks
        for slice = 1:handles.h.Img{handles.h.Id}.I.no_stacks
            % get slice
            img = ib_getSlice('image', handles.h, slice, orientation, NaN, options);
            
            % loop across number of ROI,
            % when ROIs are not shown the loop is one element only
            for roi=1:numel(img)
                % do the Otsu thresholding
                level = graythresh(img{roi});
                img{roi} = im2bw(img{roi}, level);
            end
            
            ib_setSlice('mask', img, handles.h, slice, orientation, NaN, options);
            waitbar(counter/maxIndex, wb);  % update the waitbar
            counter = counter + 1;  % increase the counter
        end
        % ---------------- Method B end of comment ---------------------------
    end
delete(wb);     % delete the waitbar
end

% set the Show Mask check box. Or it may be pressed manually
set(handles.h.maskShowCheck,'value',1);

% update widgets in the im_browser GUI
handles.h = updateGuiWidgets(handles.h);

% redraw the im_browser 
handles.h = handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);


