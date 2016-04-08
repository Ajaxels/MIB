function handles = setMaterialNames(obj, modelMaterialNames, handles)
% function handles = setMaterialNames(obj, modelMaterialNames, handles)
% Set names for materials of the model
%
% Parameters:
% modelMaterialNames: a cell array with names for materials
% handles: handles structure from im_browser
%
% Return values:
% handles: handles structure from im_browser

%| 
% @b Example:
% @code modelMaterialNames = {'Material 1','Material 2', 'Material 3'};   // define names for materials @endcode
% @code handles = imageData.setMaterialNames(modelMaterialNames);     // set material names  @endcode
% @code handles = setMaterialNames(obj, modelMaterialNames); // Call within the class; set material names @endcode

% Copyright (C) 14.11.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if nargin < 2; 
    modelMaterialNames = NaN; 
elseif ~iscell(modelMaterialNames)
    errordlg(sprintf('The variable "modelMaterialNames" should contain a cell array with names of materials...'),'Wrong variable');
    return;
end;

if obj.modelExist == 0
    errordlg(sprintf('Model is missing...\nPlease create a new model first!\n\nPress the "Create" button in the Segmentation panel'),'Missing model');
    return;
end

getDataOptions.blockModeSwitch = 0;
model = obj.getData3D('model', NaN, 4, NaN, getDataOptions);  % get existing model
numberOfMaterials = max(max(max(max(model))));  % calculate maximal index for materials

if ~iscell(modelMaterialNames(1))   % generate the list
    obj.modelMaterialNames = cell([numberOfMaterials 1]);
    for i=1:numberOfMaterials
        obj.modelMaterialNames{i} = sprintf('Material %d', i);
    end
else                                % use provided list
    if size(modelMaterialNames,1) < size(modelMaterialNames,2)  % convert to column
        modelMaterialNames = modelMaterialNames';
    end
    if numel(modelMaterialNames) < numberOfMaterials
        warndlg(sprintf('!!! Warning !!!\n\nThere are more materials in the existing model than the number of materials provided!'),'Wrong number of names');
        obj.modelMaterialNames = modelMaterialNames;
        for i=numel(modelMaterialNames)+1:numberOfMaterials
            obj.modelMaterialNames{i} = sprintf('Material %d', i);
        end
    else
        obj.modelMaterialNames = modelMaterialNames;
    end
end
% add colors for color channels
if size(obj.modelMaterialColors,1) < numel(obj.modelMaterialNames)
    for i=size(obj.modelMaterialColors,1)+1:numel(obj.modelMaterialNames)
        obj.modelMaterialColors(i,:) = [rand(1) rand(1) rand(1)];
    end
end

updateSegmentationLists(handles);

% store handles structure
guidata(handles.im_browser, handles);
end