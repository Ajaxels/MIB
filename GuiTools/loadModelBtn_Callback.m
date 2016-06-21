function loadModelBtn_Callback(hObject, eventdata, handles, model, options)
% function loadModelBtn_Callback(hObject, eventdata, handles, model, options)
% a callback to the handles.loadModelBtn, loads model to MIB from
% a file
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure
% handles: structure with handles of im_browser.m
% model: [@em optional], a matrix contaning a model to load [1:obj.height, 1:obj.width, 1:obj.color, 1:obj.no_stacks, 1:obj.time]
% options: [@em optional], a structure with additional parameters:
% @li .material_list - cell array with list of materials
% @li .colors - a matrix with colors for materials

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 03.09.2015 Ilya Belevich, updated to use imageData.setData4D method
% 17.02.2016, IB, modified the function to get inputs from menuModelsImport, updated for 4D datasets

tic
setDataOptions.blockModeSwitch = 0;
if nargin < 4   % model and options are not provided
    % load Model from a file
    unFocus(hObject);   % remove focus from hObject
    [filename, path] = uigetfile(...
        {'*.mat;',  'Matlab format (*.mat)'; ...
        '*.am;',  'Amira mesh format (*.am)'; ...
        '*.h5',   'Hierarchical Data Format (*.h5)'; ...
        '*.nrrd;',  'NRRD format (*.nrrd)'; ...
        '*.tif;',  'TIF format (*.tif)'; ...
        '*.xml',   'Hierarchical Data Format with XML header (*.xml)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Open model data...',handles.mypath,'MultiSelect','on');
    if isequal(filename, 0); return; end; % check for cancel
    if ischar(filename); filename = cellstr(filename); end;     % convert to cell type
    
    % create a new model if it is not yet created
    if handles.Img{handles.Id}.I.modelExist == 0
        createModelBtn_Callback(handles.createModelBtn,eventdata, handles);
    end
    
    wb = waitbar(0,sprintf('%s\nPlease wait...',filename{1}),'Name','Loading model','WindowStyle','modal');
    set(findall(wb,'type','text'),'Interpreter','none');
    waitbar(0, wb);
    options = struct();
    
    for fnId = 1:numel(filename)
        if strcmp(filename{fnId}(end-2:end),'mat') % loading model in the matlab format
            res = load([path filename{fnId}]);
            options.model_fn = fullfile([path filename{1}]);
            Fields = fieldnames(res);
            % find a field name for the data
            if ismember('model_var', Fields)
                options.model_var = res.(Fields{ismember(Fields, 'model_var')});
            else
                for field = 1:numel(Fields)
                    if ~strcmp(Fields{field},'material_list') && ~strcmp(Fields{field},'labelText') && ~strcmp(Fields{field},'labelPosition') && ~strcmp(Fields{field},'color_list') && ~strcmp(Fields{field},'bounding_box')
                        options.model_var = Fields{field};
                    end
                end
            end
            model = res.(options.model_var);
            if isfield(res, 'material_list')
                options.material_list = res.material_list;
            else    % was using permute earlier to to match height and width with the image
                model = permute(model,[2 1 3 4]); %#ok<NODEF>
            end
            if isfield(res, 'color_list')
                options.color_list = res.color_list; %#ok<NASGU>
            end
            
            % add labels labels
            if isfield(res, 'labelText')
                options.labelText = res.labelText;
                options.labelPosition = res.labelPosition;
            end
            clear res;
        elseif strcmp(filename{fnId}(end-1:end),'am') % loading amira mesh
            model = amiraLabels2bitmap(fullfile([path filename{fnId}]));
            options.model_fn = fullfile([path filename{1}(1:end-2) 'mat']);
            options.model_var = 'amira_mesh';
        elseif strcmp(filename{fnId}(end-1:end),'h5') || strcmp(filename{fnId}(end-2:end),'xml')  % loading model in hdf5 format
            options.bioformatsCheck = 0;
            options.progressDlg = 0;
            [model, img_info, ~] = ib_loadImages({fullfile(path, filename{fnId})}, options, handles);
            model = squeeze(model);
            options.model_fn = fullfile([path filename{1}(1:end-2) 'mat']);
            options.model_var = 'hdf5';
            if isKey(img_info, 'material_list')     % add list of material names
                options.material_list = img_info('material_list');
            end
            if isKey(img_info, 'color_list')     % add list of colors for materials
                options.color_list = img_info('color_list');
            end
            delete(img_info);
        elseif strcmp(filename{fnId}(end-3:end),'nrrd') % loading model in tif format
            model = nrrdLoadWithMetadata(fullfile([path filename{fnId}]));
            model =  uint8(permute(model.data, [2 1 3]));
            options.model_fn = fullfile([path filename{fnId}(1:end-2) 'mat']);
            options.model_var = 'nrrd_model';
        else        % loading model in tif format and other standard formats
            options.bioformatsCheck = 0;
            options.progressDlg = 0;
            [model, ~, ~] = ib_loadImages({fullfile(path, filename{fnId})}, options, handles);
            model =  squeeze(model);
            options.model_fn = fullfile(path, [filename{1}(1:end-3) 'mat']);
            options.model_var = 'tif_model';
        end
        
        % check H/W/Z dimensions
        if size(model,1) ~= handles.Img{handles.Id}.I.height || size(model,2) ~= handles.Img{handles.Id}.I.width || size(model,3) ~= handles.Img{handles.Id}.I.no_stacks
            if exist('wb','var'); delete(wb); end;
            msgbox(sprintf('Model and image dimensions mismatch!\nImage (HxWxZ) = %d x %d x %d pixels\nModel (HxWxZ) = %d x %d x %d pixels',...
                handles.Img{handles.Id}.I.height, handles.Img{handles.Id}.I.width, handles.Img{handles.Id}.I.no_stacks, size(model,1), size(model,2), size(model,3)),'Error!','error','modal');
            return;
        end
        
        if size(model, 4) > 1 && size(model, 4) == handles.Img{handles.Id}.I.time   % update complete 4D dataset
            handles.Img{handles.Id}.I.setData4D('model', model, 4, NaN, setDataOptions);
        elseif size(model, 4) == 1 && size(model,3) == handles.Img{handles.Id}.I.no_stacks  % update complete 3D dataset
            if numel(filename) > 1
                handles.Img{handles.Id}.I.setData3D('model', model, fnId, 4, NaN, setDataOptions);
            else
                handles.Img{handles.Id}.I.setData3D('model', model, NaN, 4, NaN, setDataOptions);
            end
        elseif size(model, 3) == 1
            if numel(filename) > 1
                handles.Img{handles.Id}.I.setData2D('model', model, fnId, 4, NaN, NaN, setDataOptions);
            else
                handles.Img{handles.Id}.I.setData2D('model', model, NaN, 4, NaN, NaN, setDataOptions);
            end
        end
        waitbar(fnId/numel(filename),wb);
    end
else
    wb = waitbar(0,sprintf('Importing a model\nPlease wait...'),'Name','Loading model','WindowStyle','modal');
    if nargin < 5
        options = struct();
    end
    [pathTemp,fnTemplate] = fileparts(handles.Img{handles.Id}.I.img_info('Filename'));
    if ~isfield(options, 'model_fn')
        options.model_fn = fullfile(pathTemp, ['Labels_' fnTemplate '.mat']);
    end
    if ~isfield(options, 'model_var')
        options.model_var = ['Labels_' fnTemplate];
    end
    
    % check H/W/Z dimensions
    if size(model,1) ~= handles.Img{handles.Id}.I.height || size(model,2) ~= handles.Img{handles.Id}.I.width || size(model,3) ~= handles.Img{handles.Id}.I.no_stacks
        if exist('wb','var'); delete(wb); end;
        msgbox(sprintf('Model and image dimensions mismatch!\nImage (HxWxZ) = %d x %d x %d pixels\nModel (HxWxZ) = %d x %d x %d pixels',...
                handles.Img{handles.Id}.I.height, handles.Img{handles.Id}.I.width, handles.Img{handles.Id}.I.no_stacks, size(model,1), size(model,2), size(model,3)),'Error!','error','modal');
        return;
    end
    
    if size(model, 4) > 1 && size(model, 4) == handles.Img{handles.Id}.I.time   % update complete 4D dataset
        handles.Img{handles.Id}.I.setData4D('model', model, 4, NaN, setDataOptions);
    elseif size(model, 4) == 1 && size(model,3) == handles.Img{handles.Id}.I.no_stacks  % update complete 3D dataset
        handles.Img{handles.Id}.I.setData3D('model', model, NaN, 4, NaN, setDataOptions);
    elseif size(model, 3) == 1
        handles.Img{handles.Id}.I.setData2D('model', model, NaN, 4, NaN, NaN, setDataOptions);
    else
        
    end
end

if isfield(options, 'material_list')
    handles.Img{handles.Id}.I.modelMaterialNames = options.material_list;
    max_color = numel(options.material_list);
else
    max_color = max(max(max(max(model))));
    if max_color > 0
        for i=1:max_color
            handles.Img{handles.Id}.I.modelMaterialNames(i,1) = cellstr(num2str(i));
        end
    end
end
if isfield(options, 'color_list')
    handles.Img{handles.Id}.I.modelMaterialColors = options.color_list;
end
% adding extra colors if needed
if max_color > size(handles.Img{handles.Id}.I.modelMaterialColors,1)
    minId = size(handles.Img{handles.Id}.I.modelMaterialColors,1)+1;
    maxId = max_color;
    handles.Img{handles.Id}.I.modelMaterialColors = [handles.Img{handles.Id}.I.modelMaterialColors; rand([maxId-minId+1,3])];
end
% add annotations
if isfield(options, 'labelText');
    handles.Img{handles.Id}.I.hLabels.addLabels(options.labelText, options.labelPosition);
end;

handles.Img{handles.Id}.I.model_fn = options.model_fn;
handles.Img{handles.Id}.I.model_var = options.model_var;

updateSegmentationLists(handles);
handles.lastSegmSelection = 1;
waitbar(1,wb);
set(handles.modelShowCheck, 'value', 1);
modelShowCheck_Callback(handles.modelShowCheck, eventdata, handles);

delete(wb);
toc
% do not put guidata here! guidata(handles.im_browser, handles);
end