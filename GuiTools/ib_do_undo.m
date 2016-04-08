function ib_do_undo(handles, newIndex)
% function ib_do_undo(handles, newIndex)
% Undo the recent changes with Ctrl+Z shortcut
%
% Parameters:
% handles: handles structure of im_browser.m
% newIndex: [@em optional] - index of the dataset to restore, when omitted restore the last stored dataset.
%

% Copyright (C) 19.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 03.09.2015, Ilya Belevich, updated to use imageData.getData3D methods
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}


if nargin < 2; newIndex = NaN; end;

if isnan(newIndex)  % result of Ctrl+Z combination
    newIndex = handles.U.prevUndoIndex;
    newDataIndex = handles.U.undoIndex;
else                % when using arrow button in the toolbar
    if newIndex < handles.U.undoIndex   % shift left in the undo sequence, i.e. do undo
        newDataIndex = newIndex+1;
    else            % shift right in the undo sequence, i.e. do redo
        newDataIndex = newIndex-1;
    end
end

[type, data, img_info, storeOptions] = handles.U.undo(newIndex);
handles.U.prevUndoIndex = newDataIndex;

% get stored info about the new place
[type2, ~, ~, ~] = handles.U.undo(newDataIndex);

% delete data in the stored entry
storeOptions.blockModeSwitch=0;
handles.U.replaceItem(newIndex, NaN, NaN, NaN, storeOptions); %index, type, data, img_info, options
if handles.preferences.max3dUndoHistory <= 1 && isnan(storeOptions.orient)  % tweak for storing a single 3D dataset
    % store the current situation
    if strcmp(type, 'image')
        handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.getData3D(type, storeOptions.t(1), 4, 0, storeOptions), handles.Img{handles.Id}.I.img_info, storeOptions);
    else
        handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.getData3D(type, storeOptions.t(1), 4, NaN, storeOptions), NaN, storeOptions);
    end
else
    % store the current situation
    if isnan(storeOptions.orient)    % 3D case
        if strcmp(type, 'image')
            handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.getData3D(type, storeOptions.t(1), 4, 0, storeOptions), handles.Img{handles.Id}.I.img_info, storeOptions);
        elseif strcmp(type, 'labels')
            [labels.labelText, labels.labelPosition] = handles.Img{handles.Id}.I.hLabels.getLabels();
            handles.U.replaceItem(newDataIndex, type, labels, NaN, storeOptions);
        elseif strcmp(type, 'measurements')
            handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.hMeasure.Data, NaN, storeOptions);
        else
            handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.getData3D(type, storeOptions.t(1), 4, NaN, storeOptions), NaN, storeOptions);
        end
    else        % 2D case
        if strcmp(type, 'image')
            handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.getData2D(type, storeOptions.z(1), storeOptions.orient, 0, NaN, storeOptions), handles.Img{handles.Id}.I.img_info, storeOptions);
            %handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.getData3D(type, storeOptions.t(1), storeOptions.orient, 0, storeOptions), handles.Img{handles.Id}.I.img_info, storeOptions);
        elseif strcmp(type, 'labels')
            [labels.labelText, labels.labelPosition] = handles.Img{handles.Id}.I.hLabels.getLabels();
            handles.U.replaceItem(newDataIndex, type, labels, NaN, storeOptions); 
        elseif strcmp(type, 'measurements')
            handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.hMeasure.Data, NaN, storeOptions);
        else
            handles.U.replaceItem(newDataIndex, type, handles.Img{handles.Id}.I.getData2D(type, storeOptions.z(1), storeOptions.orient, 0, NaN, storeOptions), NaN, storeOptions);
        end
    end
end
handles.U.undoIndex = newIndex;

if isnan(storeOptions.orient)     % 3D case
    switch type
        case 'image'
            handles.Img{handles.Id}.I.setData3D('image', data, storeOptions.t(1), 4, 0, storeOptions);
            handles.Img{handles.Id}.I.img_info = img_info;
            handles.Img{handles.Id}.I.width = img_info('Width');
            handles.Img{handles.Id}.I.height = img_info('Height');
            if handles.Img{handles.Id}.I.colors ~= size(data,3);    % take care about change of the number of color channels
                handles.Img{handles.Id}.I.colors = size(data,3);
                handles.Img{handles.Id}.I.slices{3} = 1:min([size(data,3) 3]);
                handles.Img{handles.Id}.I.updateDisplayParameters();
            end
            handles.Img{handles.Id}.I.no_stacks = img_info('Stacks');
            handles.Img{handles.Id}.I.time = img_info('Time');
            handles = updateGuiWidgets(handles);
        case {'selection', 'mask', 'model','everything'}
            handles.Img{handles.Id}.I.setData3D(type, data, storeOptions.t(1), 4, NaN, storeOptions);
        case 'labels'
            handles.Img{handles.Id}.I.hLabels.replaceLabels(data.labelText, data.labelPosition)
        case 'measurements'
            handles.Img{handles.Id}.I.hMeasure.Data = data;
            
    end
else        % 2D case
    switch type
        case 'image'
            handles.Img{handles.Id}.I.setData2D('image', data, storeOptions.z(1), storeOptions.orient, 0, NaN, storeOptions);
            %handles.Img{handles.Id}.I.setData3D('image', data, storeOptions.t(1), storeOptions.orient, 0, storeOptions);
            handles.Img{handles.Id}.I.img_info = img_info;
            handles.Img{handles.Id}.I.updateDisplayParameters();
        case {'selection', 'mask', 'model','everything'}
            handles.Img{handles.Id}.I.setData2D(type, data, storeOptions.z(1), storeOptions.orient, NaN, NaN, storeOptions);
        case 'labels'
            handles.Img{handles.Id}.I.hLabels.replaceLabels(data.labelText, data.labelPosition);
        case 'measurements'
            handles.Img{handles.Id}.I.hMeasure.Data = data;            
    end
end
% clear selection layer
if ~strcmp(type, 'selection') && strcmp(type2, 'selection') && newIndex > newDataIndex
    if ~isnan(storeOptions.orient)
        handles.Img{handles.Id}.I.clearSelection(handles.Img{handles.Id}.I.slices{1}(1):handles.Img{handles.Id}.I.slices{1}(2),...
                                                 handles.Img{handles.Id}.I.slices{2}(1):handles.Img{handles.Id}.I.slices{2}(2),...
                                                 handles.Img{handles.Id}.I.slices{4}(1):handles.Img{handles.Id}.I.slices{4}(2),...
                                                 handles.Img{handles.Id}.I.slices{5}(1):handles.Img{handles.Id}.I.slices{5}(2));
    else
        handles.Img{handles.Id}.I.clearSelection();
    end
end

% tweak to allow better Membrane Click Tracker work after Undo
if size(handles.Img{handles.Id}.I.trackerYXZ, 2) == 2; handles.Img{handles.Id}.I.trackerYXZ = handles.Img{handles.Id}.I.trackerYXZ(:,1); end;

% update the annotation window
windowId = findall(0,'tag','ib_labelsGui');
if ~isempty(windowId)
    hlabelsGui = guidata(windowId);
    cb = get(hlabelsGui.refreshBtn,'callback');
    feval(cb, hlabelsGui.refreshBtn, []);
end

% update the measurement window
windowId = findall(0,'tag','mib_measureTool');
if ~isempty(windowId)
    hlabelsGui = guidata(windowId);
    cb = get(hlabelsGui.filterPopup,'callback');
    feval(cb, hlabelsGui.filterPopup, []);
end

%sprintf('Undo: Index=%d, numel=%d, max=%d', handles.U.undoIndex, numel(handles.U.undoList), handles.U.max_steps)
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);

end