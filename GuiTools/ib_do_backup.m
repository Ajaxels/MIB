function handles = ib_do_backup(handles, type, switch3d, storeOptions)
% function handles = ib_do_backup(handles, type, switch3d, storeOptions)
% Store the dataset for Undo
%
% The dataset is stored in imageUndo class
% 
% Parameters:
% handles: structure with handles of im_browser.m
% type: ''image'', ''selection'', ''mask'', ''model'', 'labels', ''everything'' (for imageData.model_type==''uint6'' only)
% switch3d: - a switch to define a 2D or 3D mode to store the dataset dataset
% - @b 0 - 2D slice
% - @b 1 - 3D dataset
% storeOptions: - an optional structure with extra parameters
% @li .y -> [@em optional], [ymin, ymax] of the part of the dataset to store
% @li .x -> [@em optional], [xmin, xmax] of the part of the dataset to store
% @li .z -> [@em optional], [zmin, zmax] of the part of the dataset to store
% @li .t -> [@em optional], [tmin, tmax] of the part of the dataset to store

% Copyright (C) 19.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 03.09.2015, Ilya Belevich, updated to use imageData.getData3D methods
% 22.01.2016, IB updated for 4D

if strcmp(handles.preferences.undo, 'no'); return; end;

if nargin < 4; storeOptions = struct(); end;

% replace types 'selection','mask','model' to 'everything' for uint6 models
if strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
    if strcmp(type, 'selection') || strcmp(type, 'mask') || strcmp(type, 'model')
        type = 'everything';
    end
end

% return when no mask
if strcmp(type, 'mask') && isnan(handles.Img{handles.Id}.I.maskImg(1));  return;   end;

storeOptions.blockModeSwitch = 0;

% when the block mode is enabled store only information inside the shown
% block, when ROI is not shown
if handles.Img{handles.Id}.I.blockModeSwitch
    if switch3d
        if handles.Img{handles.Id}.I.orientation==1     % xz
            if ~isfield(storeOptions, 'x')
                storeOptions.z = ceil(handles.Img{handles.Id}.I.axesX);
            end
            if ~isfield(storeOptions, 'y')
                storeOptions.x = ceil(handles.Img{handles.Id}.I.axesY);
            end
        elseif handles.Img{handles.Id}.I.orientation==2 % yz
            if ~isfield(storeOptions, 'x')
                storeOptions.z = ceil(handles.Img{handles.Id}.I.axesX);
            end
            if ~isfield(storeOptions, 'y')
                storeOptions.y = ceil(handles.Img{handles.Id}.I.axesY);
            end
        elseif handles.Img{handles.Id}.I.orientation==4 % yx
            if ~isfield(storeOptions, 'x')
                storeOptions.x = ceil(handles.Img{handles.Id}.I.axesX);
            end
            if ~isfield(storeOptions, 'y')
                storeOptions.y = ceil(handles.Img{handles.Id}.I.axesY);
            end
        end
        % make sure that the coordinates within the dimensions of the dataset
        if isfield(storeOptions, 'x')
            storeOptions.x = [max([storeOptions.x(1) 1]) min([storeOptions.x(2) handles.Img{handles.Id}.I.width])];
        end
        if isfield(storeOptions, 'y')
            storeOptions.y = [max([storeOptions.y(1) 1]) min([storeOptions.y(2) handles.Img{handles.Id}.I.height])];
        end
        if isfield(storeOptions, 'z')
            storeOptions.z = [max([storeOptions.z(1) 1]) min([storeOptions.z(2) handles.Img{handles.Id}.I.no_stacks])];
        end
    else
        [blockHeight, blockWidth] = handles.Img{handles.Id}.I.getDatasetDimensions('image', handles.Img{handles.Id}.I.orientation, 0, storeOptions);
        if ~isfield(storeOptions, 'x')
            storeOptions.x = ceil(handles.Img{handles.Id}.I.axesX);
            storeOptions.x = [max([storeOptions.x(1) 1]) min([storeOptions.x(2) blockWidth])];
        end
        if ~isfield(storeOptions, 'y')
            storeOptions.y = ceil(handles.Img{handles.Id}.I.axesY);
            storeOptions.y = [max([storeOptions.y(1) 1]) min([storeOptions.y(2) blockHeight])];
        end
    end
end

% take care about storeOptions.orient field
if ~isfield(storeOptions, 'orient'); 
    if switch3d == 1;
        storeOptions.orient = NaN; % storeOptions.orient = NaN identifies 3D dataset
    else
        storeOptions.orient = handles.Img{handles.Id}.I.orientation; 
    end
else
    if switch3d == 1;
        storeOptions.orient = NaN; % storeOptions.orient = NaN identifies 3D dataset
    end
end;

if ~isfield(storeOptions, 'z') && switch3d==0;
    storeOptions.z = [handles.Img{handles.Id}.I.getCurrentSliceNumber() handles.Img{handles.Id}.I.getCurrentSliceNumber()];
end

if ~isfield(storeOptions, 't')
    storeOptions.t = [handles.Img{handles.Id}.I.getCurrentTimePoint() handles.Img{handles.Id}.I.getCurrentTimePoint()];
end

if switch3d == 1        % 3D mode
    if strcmp(type, 'image')
        handles.U.store(type, handles.Img{handles.Id}.I.getData3D(type, NaN, 4, 0, storeOptions), handles.Img{handles.Id}.I.img_info, storeOptions);
    elseif strcmp(type, 'labels')
        [labels.labelText, labels.labelPosition] = handles.Img{handles.Id}.I.hLabels.getLabels();
        handles.U.store(type, labels, NaN);
    elseif strcmp(type, 'measurements')
        handles.U.store(type, handles.Img{handles.Id}.I.hMeasure.Data, NaN);
    else
        if strcmp(handles.preferences.disableSelection, 'yes'); return; end;    % do not make backups if selection is disabled
        handles.U.store(type, handles.Img{handles.Id}.I.getData3D(type, NaN, 4, NaN, storeOptions), NaN, storeOptions);
    end
else                    % 2D mode
    storeOptions.t = [handles.Img{handles.Id}.I.getCurrentTimePoint(), handles.Img{handles.Id}.I.getCurrentTimePoint()];
    if strcmp(type, 'image')
        handles.U.store(type, handles.Img{handles.Id}.I.getData2D(type, storeOptions.z(1), storeOptions.orient, 0, NaN, storeOptions), handles.Img{handles.Id}.I.img_info, storeOptions);
    elseif strcmp(type, 'labels')
        [labels.labelText, labels.labelPosition] = handles.Img{handles.Id}.I.hLabels.getLabels();
        handles.U.store(type, labels, NaN, storeOptions);
    elseif strcmp(type, 'measurements')
        handles.U.store(type, handles.Img{handles.Id}.I.hMeasure.Data, NaN, storeOptions);
    else
        if strcmp(handles.preferences.disableSelection, 'yes'); return; end;    % do not make backups if selection is disabled
        handles.U.store(type, handles.Img{handles.Id}.I.getData2D(type, storeOptions.z(1), storeOptions.orient, 0, NaN, storeOptions), NaN, storeOptions);
    end
end
%sprintf('Backup: Index=%d, numel=%d, max=%d', handles.U.undoIndex, numel(handles.U.undoList), handles.U.max_steps)
end