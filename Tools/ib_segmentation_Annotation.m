function handles = ib_segmentation_Annotation(y, x, z, t, modifier, handles)
% function handles = ib_segmentation_Annotation(y, x, z, t, modifier, handles)
% Add text annotation to the dataset
%
% Parameters:
% y: y-coordinate of the annotation point
% x: x-coordinate of the annotation point
% z: z-coordinate of the annotation point
% t: t-coordinate of the annotation point
% modifier: a string, to specify what to do with the generated selection
% - @em empty - makes new selection
% - @em ''control'' - removes selection from the existing one
% handles: a handles structure of im_browser
%
% Return values:
% handles: a handles structure of im_browser

%| @b Examples:
% @code handles = ib_segmentation_Annotation(50, 75, 10, '', handles);  // add an annotation to position [y,x,z]=50,75,10 @endcode

% Copyright (C) 14.05.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 25.01.2015 IB, updated for 4D


% do backup

ib_do_backup(handles, 'labels', 0);
if isempty(modifier) || strcmp(modifier, 'shift')  % add label
    %labelText = inputdlg('Type a new annotation:', 'Add annotation');
    noLabels = handles.Img{handles.Id}.I.hLabels.getLabelsNumber();
    labelText = mib_inputdlg(handles, 'Type a new annotation:', 'Add annotation', sprintf('Feature %d',noLabels+1));
    if isempty(labelText); return; end;
    handles.Img{handles.Id}.I.hLabels.addLabels(labelText, [z, x, y, t]);
    set(handles.showAnnotationsCheck, 'value', 1);
elseif strcmp(modifier, 'control')  % remove the closest to the mouse click point label
    [~, labelPositions] = handles.Img{handles.Id}.I.hLabels.getCurrentSliceLabels(handles);
    if isempty(labelPositions); return; end;
    if handles.Img{handles.Id}.I.orientation == 4   % xy
        X1 = [x, y];
        X2 = labelPositions(:,2:3);
    elseif handles.Img{handles.Id}.I.orientation == 1   % zx
        X1 = [z,x];
        X2 = labelPositions(:,1:2);
    elseif handles.Img{handles.Id}.I.orientation == 2   % zy
        X1 = [z,y];
        X2 = labelPositions(:,[1 3]);
    end

    % calculate the distances between the labels and the clicked point
    % taken from here, as analogue of D = pdist2(X2,X1,'euclidean');:
    % http://stackoverflow.com/questions/7696734/pdist2-equivalent-in-matlab-version-7
    distVec = sqrt(bsxfun(@plus, sum(X1.^2,2),sum(X2.^2,2)') - 2*(X1*X2'));
    [~, index] = min(distVec);  % find index
    selectedLabelPos = labelPositions(index, :);
    handles.Img{handles.Id}.I.hLabels.removeLabels(selectedLabelPos);
end

% update the annotation window
windowId = findall(0,'tag','ib_labelsGui');
if ~isempty(windowId)
    hlabelsGui = guidata(windowId);
    cb = get(hlabelsGui.refreshBtn,'callback');
    feval(cb, hlabelsGui.refreshBtn, []);
end
end
