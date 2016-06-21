function menuModelsSaveAs(hObject, eventdata, handles)
% function menuModelsSaveAs(hObject, eventdata, handles)
% a callback to Menu->Models->Save as
% saves model to a file
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 04.09.2015, Ilya Belevich, adapted to use getData3D method
% 08.01.2016, Ilya Belevich, added export using the STL format
% 11.02.2016, IB, updated for 4D data (only for *.mat)
% 12.04.2016, IB, updated for saving in HDF5 format

if  handles.Img{handles.Id}.I.modelExist == 0 || strcmp(handles.Img{handles.Id}.I.model_type, 'int8'); disp('Cancel: No segmentation model detected'); return; end;
if isnan(handles.Img{handles.Id}.I.model(1,1,1)); errordlg('No model found!','Error!'); return; end;
fn_out = handles.Img{handles.Id}.I.model_fn;
selMaterial = get(handles.segmList,'Value');
if get(handles.seeAllMaterialsCheck, 'value');     selMaterial = 0;  end;
if isempty(fn_out)
    fn_out = handles.mypath;
end

Filters = {'*.mat;',  'Matlab format (*.mat)'; ...
    '*.am;',  'Amira mesh binary RLE compression SLOW (*.am)'; ...
    '*.am;',  'Amira mesh binary (*.am)'; ...
    '*.am;',  'Amira mesh ascii (*.am)'; ...
    '*.h5',   'Hierarchical Data Format (*.h5)'; ...
    '*.mod;',  'Contours for IMOD (*.mod)'; ...
    '*.mrc;',  'Volume for IMOD (*.mrc)'; ...
    '*.nrrd;',  'NRRD for 3D Slicer (*.nrrd)'; ...
    '*.stl',  'Isosurface as binary STL (*.stl)'; ...
    '*.tif;',  'TIF format (*.tif)'; ...
    '*.xml',   'Hierarchical Data Format with XML header (*.xml)'; ...
    '*.*',  'All Files (*.*)'
    };

[filename, path, FilterIndex] = uiputfile(Filters, 'Save model data...', fn_out);
if isequal(filename,0); return; end; % check for cancel
tic

getDataOptions.blockModeSwitch = 0;     % get the full dataset

handles.Img{handles.Id}.I.model_var = strrep(handles.Img{handles.Id}.I.model_var, '-', '_');

if FilterIndex == 1     % matlab file
    %model = permute(handles.Img{handles.Id}.I.model,[2 1 3]); %#ok<NASGU>  % earlier the models were permuted
    %str1 = strcat(handles.Img{handles.Id}.I.model_var, '=model;');
    warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');    % switch off warnings for latex
    curInt = get(0, 'DefaulttextInterpreter');
    set(0, 'DefaulttextInterpreter', 'none');
    wb = waitbar(0,sprintf('%s\nPlease wait...',fullfile(path, filename)),'Name','Saving the model','WindowStyle','modal');
    set(findall(wb,'type','text'),'Interpreter','none');
    waitbar(0, wb);
    str1 = strcat(handles.Img{handles.Id}.I.model_var, '=handles.Img{handles.Id}.I.getData4D(''model'', 4, NaN, getDataOptions);');
    eval(str1);
    material_list = handles.Img{handles.Id}.I.modelMaterialNames; %#ok<NASGU>
    color_list = handles.Img{handles.Id}.I.modelMaterialColors; %#ok<NASGU>
    bounding_box = handles.Img{handles.Id}.I.getBoundingBox(); %#ok<NASGU>
    model_var = handles.Img{handles.Id}.I.model_var; %#ok<NASGU>    % name of a variable that has the dataset
    if handles.Img{handles.Id}.I.hLabels.getLabelsNumber() > 1  % save annotations
        [labelText, labelPosition] = handles.Img{handles.Id}.I.hLabels.getLabels(); %#ok<NASGU,ASGLU>
        str1 = ['save ''' fullfile(path, filename) ''' ' handles.Img{handles.Id}.I.model_var ' material_list color_list bounding_box model_var labelText labelPosition -mat -v7.3'];
    else    % save without annotations
        str1 = ['save ''' fullfile(path, filename) ''' ' handles.Img{handles.Id}.I.model_var ' material_list color_list bounding_box model_var -mat -v7.3'];
    end
    eval(str1);
    handles.Img{handles.Id}.I.model_fn = fullfile(path, filename);
    delete(wb);
    set(0, 'DefaulttextInterpreter', curInt);
else
    [~, filename, ext] = fileparts(filename);
    ext = lower(ext);
    t1 = handles.Img{handles.Id}.I.slices{5}(1);
    t2 = t1;
    
    if handles.Img{handles.Id}.I.time > 1
        if ~ismember(ext, {'.xml', '.h5'})
            button = questdlg(sprintf('!!! Warning !!!\nIt is not possible to save 4D dataset into a single file!\n\nHowever it is possible to save the currently shown Z-stack, or to make a series of files'),'Save model','Save as series of 3D datasets','Save the currently shown Z-stack','Cancel','Save as series of 3D datasets');
            if strcmp(button, 'Cancel'); return; end;
        end
        t1 = 1;
        t2 = handles.Img{handles.Id}.I.time;
    end
    
    showLocalWaitbar = 0;   % switch to show or not wait bar in this function
    if t1 ~= t2
        showLocalWaitbar = 1;
        wb = waitbar(0,sprintf('Saving %s\nPlease wait...',Filters{FilterIndex,2}),'Name','Saving images...','WindowStyle','modal');
        dT = t2-t1+1;
    end
    
    multCoefficient = 1;    % multiply material by this number
    color_list = handles.Img{handles.Id}.I.modelMaterialColors;
    color_list = color_list(1:numel(handles.Img{handles.Id}.I.modelMaterialNames),:);
    modelMaterialNames = handles.Img{handles.Id}.I.modelMaterialNames;
    
    if selMaterial > 0
        button = questdlg(sprintf('You are going to export only material No:%d (%s) !\nProceed?', selMaterial, handles.Img{handles.Id}.I.modelMaterialNames{selMaterial}),'Single material export','Proceed, set as 1','Proceed, set as 255','Cancel','Proceed, set as 1');
        if strcmp(button, 'Cancel'); return; end;
        if strcmp(button, 'Proceed, set as 255')
            if FilterIndex ~= 9; multCoefficient = 255; end;    % do not do that for the STL model type
            color_list = handles.Img{handles.Id}.I.modelMaterialColors(selMaterial,:);
            modelMaterialNames = handles.Img{handles.Id}.I.modelMaterialNames(selMaterial);
        end
    else
        selMaterial = NaN;  % reassign materials to take them all
    end
    
    for t=t1:t2
        if t1~=t2   % generate filename
            fnOut = generateSequentialFilename(filename, t, t2-t1+1, ext);
        else
            fnOut = [filename ext];
        end
        
        model = handles.Img{handles.Id}.I.getData3D('model', t, 4, selMaterial, getDataOptions);
        if multCoefficient > 1      % make intensity of the output model as 255
            model = model*multCoefficient;
        end
        
        if FilterIndex == 2     % Amira mesh binary RLE compression
            bb = handles.Img{handles.Id}.I.getBoundingBox();
            pixStr = handles.Img{handles.Id}.I.pixSize;
            pixStr.minx = bb(1);
            pixStr.miny = bb(3);
            pixStr.minz = bb(5);
            showWaitbar = ~showLocalWaitbar;  % show or not waitbar in bitmap2amiraMesh
            bitmap2amiraLabels(fullfile(path, fnOut), model, 'binaryRLE', pixStr, color_list,modelMaterialNames, 1, showWaitbar);
        elseif FilterIndex == 3     % Amira mesh binary
            bb = handles.Img{handles.Id}.I.getBoundingBox();
            pixStr = handles.Img{handles.Id}.I.pixSize;
            pixStr.minx = bb(1);
            pixStr.miny = bb(3);
            pixStr.minz = bb(5);
            showWaitbar = ~showLocalWaitbar;  % show or not waitbar in bitmap2amiraMesh
            bitmap2amiraLabels(fullfile(path, fnOut), model, 'binary', pixStr, color_list,modelMaterialNames, 1, showWaitbar);
        elseif FilterIndex == 4     % Amira mesh ascii
            bb = handles.Img{handles.Id}.I.getBoundingBox();
            pixStr = handles.Img{handles.Id}.I.pixSize;
            pixStr.minx = bb(1);
            pixStr.miny = bb(3);
            pixStr.minz = bb(5);
            showWaitbar = ~showLocalWaitbar;  % show or not waitbar in bitmap2amiraMesh
            bitmap2amiraLabels(fullfile(path, fnOut), model, 'ascii', pixStr, color_list,modelMaterialNames, 1, showWaitbar);
        elseif FilterIndex == 5 || FilterIndex == 11          % hdf5 format
            if t==t1    % getting parameters for saving dataset
                options = mib_saveHDF5Dlg(handles, handles.preferences.Font);
                if isempty(options);
                    if showLocalWaitbar; delete(wb); end;
                    return;
                end;
                
                if strcmp(options.Format, 'bdv.hdf5')
                    warndlg('Export of models in using the Big Data Viewer format is not implemented!');
                    if showLocalWaitbar; delete(wb); end;
                    return;
                end
                    
                options.filename = fullfile(path, [filename ext]);
                ImageDescription = handles.Img{handles.Id}.I.img_info('ImageDescription');  % initialize ImageDescription
            end
            % permute dataset if needed
            if strcmp(options.Format, 'bdv.hdf5')
                % permute image to swap the X and Y dimensions
                %model = permute(model, [2 1 5 3 4]);
            else
                % permute image to add color dimension to position 3
                model = permute(model, [1 2 4 3]);
            end
            
            if t==t1    % updating parameters for saving dataset
                options.height = size(model,1);
                options.width = size(model,2);
                options.colors = 1;
                if strcmp(options.Format, 'bdv.hdf5')
                    %options.depth = size(model,4);
                else
                    options.depth = size(model,4);
                end
                options.time = handles.Img{handles.Id}.I.time;
                options.pixSize = handles.Img{handles.Id}.I.pixSize;    % !!! check .units = 'um'
                options.showWaitbar = ~showLocalWaitbar;        % show or not waitbar in data saving function
                options.lutColors = handles.Img{handles.Id}.I.modelMaterialColors;    % store LUT colors for materials
                options.ImageDescription = ImageDescription; 
                options.DatasetName = filename; 
                options.overwrite = 1;
                options.ModelMaterialNames = handles.Img{handles.Id}.I.modelMaterialNames; % names for materials
                % saving xml file if needed
                if options.xmlCreate
                    saveXMLheader(options.filename, options);
                end
            end
            options.t = t;
            switch options.Format
                case 'bdv.hdf5'
                    options.pixSize.units = 'µm';
                    saveBigDataViewerFormat(options.filename, model, options);
                case 'matlab.hdf5'
                    options.order = 'yxczt';
                    image2hdf5(fullfile(path, [filename '.h5']), model, options);
            end
            
        elseif FilterIndex == 6     % Contours for IMOD (*.mod)
            if exist('savingOptions', 'var') == 0   % define parameters for the first time use
                prompt = {'Take each Nth point in contours ( > 0):','Show detected points in the selection layer [0-no, 1-yes]:'};
                dlg_title = 'Parameters';
                answer = inputdlg(prompt,dlg_title,1,{'5','0'});
                if size(answer) == 0; return; end;
                savingOptions.pixSize = handles.Img{handles.Id}.I.pixSize;
                savingOptions.xyScaleFactor = str2double(answer{1});
                savingOptions.zScaleFactor = 1;
                savingOptions.generateSelectionSw = str2double(answer{2});
                savingOptions.colorList = color_list;
                savingOptions.showWaitbar = ~showLocalWaitbar;  % show or not waitbar in exportModelToImodModel
            end
            savingOptions.modelFilename = [path fnOut];
            if savingOptions.generateSelectionSw
                [~, selection] = exportModelToImodModel(model, savingOptions);
                handles.Img{handles.Id}.I.setData3D('selection',selection, t, 4, 0, getDataOptions);
            else
                exportModelToImodModel(model, savingOptions);
            end
        elseif FilterIndex == 7     % Volume for IMOD (*.mrc)
            Options.volumeFilename = fullfile(path, fnOut);
            Options.pixSize = handles.Img{handles.Id}.I.pixSize;
            savingOptions.showWaitbar = ~showLocalWaitbar;  % show or not waitbar in exportModelToImodModel
            ib_image2mrc(model, Options);
        elseif FilterIndex == 8     % NRRD for 3D Slicer (*.nrrd)
            bb = handles.Img{handles.Id}.I.getBoundingBox;
            Options.overwrite = 1;
            Options.showWaitbar = ~showLocalWaitbar;  % show or not waitbar in bitmap2nrrd
            bitmap2nrrd(fullfile(path, fnOut), model, bb, Options);
        elseif FilterIndex == 9     % STL isosurface for Blinder (*.stl)
            bounding_box = handles.Img{handles.Id}.I.getBoundingBox();  % get bounding box
            if exist('savingOptions', 'var') == 0   % define parameters for the first time use
                prompt = {'Reduce the volume down to, width pixels [no volume reduction when 0]?',...
                    'Smoothing 3d kernel, width (no smoothing when 0):',...
                    'Maximal number of faces (no limit when 0):'};
                dlg_title = 'Isosurface parameters';
                if handles.Img{handles.Id}.I.width > 500
                    def = {'500','5','300000'};
                else
                    def = {'0','5','300000'};
                end
                answer = inputdlg(prompt,dlg_title,1,def);
                if isempty(answer); return;  end;
                
                savingOptions.reduce = str2double(answer{1});
                savingOptions.smooth = str2double(answer{2});
                savingOptions.maxFaces = str2double(answer{3});
                savingOptions.slice = 0;
            end
            
            if isnan(selMaterial)
                p = ib_renderModel(model, selMaterial, handles.Img{handles.Id}.I.pixSize, bounding_box, handles.Img{handles.Id}.I.modelMaterialColors, NaN, savingOptions);
                for i=1:numel(p)
                    fv = struct('faces', p(i).Faces, 'vertices', p(i).Vertices);
                    stlwrite(fullfile(path, [sprintf('%s_%d', fnOut, i) '.stl']), fv, 'FaceColor', p(i).FaceColor*255);
                end
            else
                p = ib_renderModel(model, 1, handles.Img{handles.Id}.I.pixSize, bounding_box, color_list, NaN, savingOptions);
                fv.faces = p.Faces;
                fv.vertices = p.Vertices;
                stlwrite(fullfile(path, fnOut), fv, 'FaceColor', p.FaceColor*255);
            end
        elseif FilterIndex == 10     % as tif
            ImageDescription = {handles.Img{handles.Id}.I.img_info('ImageDescription')};
            resolution(1) = handles.Img{handles.Id}.I.img_info('XResolution');
            resolution(2) = handles.Img{handles.Id}.I.img_info('YResolution');
            if exist('savingOptions', 'var') == 0   % define parameters for the first time use
                savingOptions = struct('Resolution', resolution, 'overwrite', 1, 'Saving3d', NaN, 'cmap', NaN);
            end
            savingOptions.showWaitbar = ~showLocalWaitbar;  % show or not waitbar in ib_image2tiff
            model = reshape(model,[size(model,1) size(model,2) 1 size(model,3)]);
            [result, savingOptions] = ib_image2tiff(fullfile(path, fnOut), model, savingOptions, ImageDescription);
            if isfield(savingOptions, 'SliceName'); savingOptions = rmfield(savingOptions, 'SliceName'); end; % remove SliceName field when saving series of 2D files
        end
        if showLocalWaitbar;    waitbar(t/dT, wb);    end;
    end
    if showLocalWaitbar; delete(wb); end;
end
disp(['Model: ' fullfile(path, filename) ' has been saved']);
update_filelist(handles, filename);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
toc;
end

% supporting function to generate sequential filenames
function fn = generateSequentialFilename(name, num, files_no, ext)
% name - a filename template
% num - sequential number to generate
% files_no - total number of files in sequence
% ext - string with extension
if files_no == 1
    fn = [name ext];
elseif files_no < 100
    fn = [name '_' sprintf('%02i',num) ext];
elseif files_no < 1000
    fn = [name '_' sprintf('%03i',num) ext];
elseif files_no < 10000
    fn = [name '_' sprintf('%04i',num) ext];
elseif files_no < 100000
    fn = [name '_' sprintf('%05i',num) ext];
elseif files_no < 1000000
    fn = [name '_' sprintf('%06i',num) ext];
elseif files_no < 10000000
    fn = [name '_' sprintf('%07i',num) ext];
end
end