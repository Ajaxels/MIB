function varargout = mib_rechopDatasetGui(varargin)
% MIB_RECHOPDATASETGUI MATLAB code for mib_rechopDatasetGui.fig
%      MIB_RECHOPDATASETGUI, by itself, creates a new MIB_RECHOPDATASETGUI or raises the existing
%      singleton*.
%
%      H = MIB_RECHOPDATASETGUI returns the handle to a new MIB_RECHOPDATASETGUI or the handle to
%      the existing singleton*.
%
%      MIB_RECHOPDATASETGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIB_RECHOPDATASETGUI.M with the given input arguments.
%
%      MIB_RECHOPDATASETGUI('Property','Value',...) creates a new MIB_RECHOPDATASETGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mib_rechopDatasetGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mib_rechopDatasetGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 18.05.2015 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
%

% Last Modified by GUIDE v2.5 19-Aug-2016 09:32:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mib_rechopDatasetGui_OpeningFcn, ...
    'gui_OutputFcn',  @mib_rechopDatasetGui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before mib_rechopDatasetGui is made visible.
function mib_rechopDatasetGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_rechopDatasetGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser

% check for the existing dataset

if ismac()
    eval(sprintf('bgColor = get(handles.h.bufferToggle%d,''ForegroundColor'');', handles.h.Id));     % get color
else
    eval(sprintf('bgColor = get(handles.h.bufferToggle%d,''BackgroundColor'');', handles.h.Id));     % get color
end
if bgColor(2) == 1
    button = questdlg(...
        sprintf('!!! Warning !!!\n\nIf you select "Generate new stack" and "Images" in the following dialog, the currenly opened in the buffer %d dataset will be replaced!\n\nAre you sure?\n\nAlternatively, select an empty buffer (the buttons in the upper part of the Directory contents panel) and try again...', handles.h.Id),'!! Warning !!','OK','Cancel','Cancel');
    if strcmp(button, 'Cancel'); mib_rechopDatasetGui_CloseRequestFcn(hObject, eventdata, handles); return; end;
end

% set default directory for the export
handles.outputDir = handles.h.mypath;
handles.filenames = [];     % list of selected files
% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.mib_rechopDatasetGui, handles.h.preferences.Font);
end
% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_rechopDatasetGui);

% Choose default command line output for mib_rechopDatasetGui
handles.output = 0;

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);
    
    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
        (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mib_rechopDatasetGui wait for user response (see UIRESUME)
uiwait(handles.mib_rechopDatasetGui);
end


% --- Outputs from this function are returned to the command line.
function varargout = mib_rechopDatasetGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
    % The figure can be deleted now
    % delete(handles.ib_snapshotGui);
else
    varargout{1} = 0;
end
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
handles.output = 0;
guidata(handles.mib_rechopDatasetGui, handles);
mib_rechopDatasetGui_CloseRequestFcn(handles.mib_rechopDatasetGui, eventdata, handles);
end

% --- Executes when user attempts to close mib_rechopDatasetGui.
function mib_rechopDatasetGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_rechopDatasetGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
end

% --- Executes on button press in selectFilesBtn.
function selectFilesBtn_Callback(hObject, eventdata, handles)
imgSw = get(handles.imagesCheck, 'value');
modelSw = get(handles.modelsCheck, 'value');
maskSw = get(handles.masksCheck, 'value');

if imgSw == 0 && modelSw == 0 && maskSw == 0
    errordlg('Please select type of the layer to combine and try again!','Missing the layers');
    return;
end

if imgSw == 1 && (modelSw == 1 || maskSw == 1)
    button = questdlg(sprintf('!!! Attention !!!\n\nPlease select only image files\nDo not select model nor mask files!'),'Attention!', 'Continue','Cancel','Continue');
    if strcmp(button, 'Cancel'); return; end;
end

if imgSw == 1;
    fileFormats = {'*.am;',  'Amira mesh binary (*.am)'; ...
        '*.nrrd;',  'NRRD for 3D Slicer (*.nrrd)'; ...
        '*.tif;',  'TIF format (*.tif)'; ...
        '*.xml',   'Hierarchical Data Format with XML header (*.xml)'; ...
        '*.*',  'All Files (*.*)'};
else
    if maskSw == 1
        fileFormats = {'*.mask',  'Masks (*.mask)'; ...
            '*.*',  'All Files (*.*)'};
    elseif modelSw == 1
        val = get(handles.modelsFormatPopup, 'value');
        switch val
            case 1
                fileFormats = {'*.mat;',  'Matlab format (*.mat)'};
            case 2
                fileFormats = {'*.am;',  'Amira mesh binary (*.am)'};
            case 3
                fileFormats = {'*.nrrd;',  'NRRD for 3D Slicer (*.nrrd)'};
            case 4
                fileFormats = {'*.tif;',  'TIF format (*.tif)'};
            case 5
                fileFormats = {'*.xml',   'Hierarchical Data Format with XML header (*.xml)'};
        end
    end
end;

[FileName, PathName, FilterIndex] = uigetfile(fileFormats,'Select chopped files',handles.outputDir,'MultiSelect','on');
if isequal(FileName,0);    return;  end;
set(handles.selectedFilesList, 'string', FileName);
handles.filenames = fullfile(PathName, FileName);

if ischar(handles.filenames)
    handles.filenames = cellstr(handles.filenames);
end
guidata(handles.mib_rechopDatasetGui, handles);
end

% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_gui_menu_file_chop.html'), '-helpbrowser');
end


% --- Executes on button press in combineBtn.
function combineBtn_Callback(hObject, eventdata, handles)
imgSw = get(handles.imagesCheck, 'value');
modelSw = get(handles.modelsCheck, 'value');
maskSw = get(handles.masksCheck, 'value');

if imgSw == 0 && modelSw == 0 && maskSw == 0
    errordlg('Please select type of the layer to combine and try again!','Missing the layers');
    return;
end

no_files = numel(handles.filenames);
if no_files < 1
    errordlg('Please select the files and try again!','Missing the files');
    return;
end

% get extension for the models
%if imgSw==0
val = get(handles.modelsFormatPopup, 'value');
switch val
    case 1
        modelExt = '.mat';
    case 2
        modelExt = '.am';
    case 3
        modelExt = '.nrrd';
    case 4
        modelExt = '.tif';
    case 5
        modelExt = '.xml';
end
%else
%    [~, ~, modelExt] = fileparts(handles.filenames{1});
%end

%files = struct();   % structure that keeps info about each file in the series
% .object_type -> 'movie', 'hdf5_image', 'image'
% .seriesName -> name of the series for HDF5
% .height
% .width
% .color
% .noLayers -> number of image frames in the file
% .imgClass -> class of the image

if get(handles.newRadio, 'Value')   % generate new stack mode
    % detect grid
    Zno = zeros([no_files 1]);
    Xno = zeros([no_files 1]);
    Yno = zeros([no_files 1]);
    options.waitbar = 1;
    for fnId=1:no_files
        [path, fn, ext] = fileparts(handles.filenames{fnId});
        Zind = strfind(fn, 'Z');
        Yind = strfind(fn, 'Y');
        Xind = strfind(fn, 'X');
        Zno(fnId) = str2double(fn(Zind(end)+1:Zind(end)+2));
        Yno(fnId) = str2double(fn(Yind(end)+1:Yind(end)+2));
        Xno(fnId) = str2double(fn(Xind(end)+1:Xind(end)+2));
        if imgSw
            options.matlabVersion = handles.h.matlabVersion;
            options.Font = handles.h.preferences.Font;
            [img_info{fnId}, files{fnId}, pixSize{fnId}] = getImageMetadata(handles.filenames(fnId), options);
        end
    end
    tilesZ = max(Zno);
    tilesY = max(Yno);
    tilesX = max(Xno);
    
    if imgSw    % combine images
        % get dimensions of the output dataset
        stacks = 0;
        for i=1:tilesZ
            id = find(Zno==i, 1);
            stacks = stacks + files{id}.noLayers;
        end
        height = 0;
        for i=1:tilesY
            id = find(Yno==i, 1);
            height = height + files{id}.height;
        end
        width = 0;
        for i=1:tilesX
            id = find(Xno==i, 1);
            width = width + files{id}.width;
        end
        
        % get the step size
        yStep = files{find(Yno==1, 1)}.height;
        xStep = files{find(Xno==1, 1)}.width;
        zStep = files{find(Zno==1, 1)}.noLayers;
        
        imgOut = zeros([height, width, files{1}.color, stacks], files{1}.imgClass);
        
        for fnId=1:no_files
            [img, img_info{fnId}] = ib_getImages(files{fnId}, img_info{fnId});
            
            yMin = (Yno(fnId)-1)*yStep+1;
            yMax = min([(Yno(fnId)-1)*yStep+yStep, height]);
            xMin = (Xno(fnId)-1)*xStep+1;
            xMax = min([(Xno(fnId)-1)*xStep+xStep, width]);
            zMin = (Zno(fnId)-1)*zStep+1;
            zMax = min([(Zno(fnId)-1)*zStep+zStep, stacks]);
            
            imgOut(yMin:yMax, xMin:xMax, :, zMin:zMax) = img;
        end
        
        % update img_info
        img_info{1}('Height') = height;
        img_info{1}('Width') = width;
        img_info{1}('Stacks') = stacks;
        
        handles.h = handles.h.Img{handles.h.Id}.I.replaceDataset(imgOut, handles.h, img_info{1});
        % update the bounding box
        bb = handles.h.Img{handles.h.Id}.I.getBoundingBox();
        bb(2) = bb(1) + (width-1)*pixSize{1}.x;
        bb(4) = bb(3) + (height-1)*pixSize{1}.y;
        bb(6) = bb(5) + (stacks-1)*pixSize{1}.z;
        handles.h.lastSegmSelection = 1;  % last selected contour for use with the 'e' button
        
        handles.h.Img{handles.h.Id}.I.updateBoundingBox(bb);
        handles.h.Img{handles.h.Id}.I.updateAxesLimits(handles.h, 'resize');
    end
    
    height = handles.h.Img{handles.h.Id}.I.height;
    width = handles.h.Img{handles.h.Id}.I.width;
    stacks = handles.h.Img{handles.h.Id}.I.no_stacks;
    
    if modelSw    % combine models
        wb = waitbar(0, 'Combining the models');
        handles.h.Img{handles.h.Id}.I.createModel();
        imgOut = zeros([height, width, stacks], 'uint8');
        material_list = cellstr('');
        for fnId=1:no_files
            [path, fn, ext] = fileparts(handles.filenames{fnId});
            if isempty(strfind(fn, 'Labels'))
                fn = fullfile(path, ['Labels_' fn modelExt]);     % Add Labels_ to the filename and change extension
            else
                fn = fullfile(path, [fn modelExt]);     % change extension
            end
            
            % load models
            R = loadModels(fn, handles);
            handles.h.Img{handles.h.Id}.I.model_fn = fn;
            handles.h.Img{handles.h.Id}.I.model_var = 'rechopped';

            if numel(R.material_list) > numel(material_list)
                material_list = R.material_list;
            end
            
            if isfield(R, 'color_list')
                if fnId == 1
                    color_list = R.color_list;
                    imgDim = size(R.imOut);
                elseif size(R.color_list,1) > size(color_list,1)
                    color_list = R.color_list;
                end
            end
            
            yMin = (Yno(fnId)-1)*imgDim(1)+1;
            yMax = min([(Yno(fnId)-1)*imgDim(1)+imgDim(1), height]);
            xMin = (Xno(fnId)-1)*imgDim(2)+1;
            xMax = min([(Xno(fnId)-1)*imgDim(2)+imgDim(2), width]);
            zMin = (Zno(fnId)-1)*imgDim(3)+1;
            zMax = min([(Zno(fnId)-1)*imgDim(3)+imgDim(3), stacks]);
            
            imgOut(yMin:yMax, xMin:xMax, zMin:zMax) = R.imOut;
            waitbar(fnId/no_files, wb);
        end
        opt.blockModeSwitch = 0;
        handles.h.Img{handles.h.Id}.I.setData3D('model', imgOut, NaN, 4, NaN, opt);
        delete(wb);
    end
    
    if maskSw    % combine masks
        wb = waitbar(0, 'Combining the masks');
        handles.h.Img{handles.h.Id}.I.clearMask();
        handles.h.Img{handles.h.Id}.I.maskExist = 1;
        imgOut = zeros([height, width, stacks], 'uint8');
        
        for fnId=1:no_files
            [path, fn, ext] = fileparts(handles.filenames{fnId});
            fn = fullfile(path, [fn '.mask']);     % Change extension
            if exist(fn, 'file') == 0
                errordlg(sprintf('!!! Error !!!\n\nThe file for the Mask:\n%s\nwas not found!\nPlease check the filenames or unselect the Masks checkbox!', fn),'Missing the mask files');
                delete(wb);
                return;
            end
            
            R = load(fn, '-mat');
            
            if fnId == 1
                imgDim = size(R.imOut);
            end
            
            yMin = (Yno(fnId)-1)*imgDim(1)+1;
            yMax = min([(Yno(fnId)-1)*imgDim(1)+imgDim(1), height]);
            xMin = (Xno(fnId)-1)*imgDim(2)+1;
            xMax = min([(Xno(fnId)-1)*imgDim(2)+imgDim(2), width]);
            zMin = (Zno(fnId)-1)*imgDim(3)+1;
            zMax = min([(Zno(fnId)-1)*imgDim(3)+imgDim(3), stacks]);
            
            imgOut(yMin:yMax, xMin:xMax, zMin:zMax) = R.imOut;
            waitbar(fnId/no_files, wb);
        end
        opt.blockModeSwitch = 0;
        handles.h.Img{handles.h.Id}.I.setData3D('mask', imgOut, NaN, 4, NaN, opt);
        delete(wb);
    end
else                                % fuse to existing
    if maskSw == 1 && modelSw == 0 && imgSw == 0
        errordlg('The fusing mode is implemented only for the images and models that have the Bounding Box information!','Missing the images');
        return;
    end
    
    if imgSw == 0 && modelSw == 1
        ib_do_backup(handles.h, 'model', 1);
    else
        ib_do_backup(handles.h, 'image', 1);
    end
    
    opt.blockModeSwitch = 0;
    options.waitbar = 0;
    
    if modelSw    % fuse into the model
        if handles.h.Img{handles.h.Id}.I.modelExist == 0
            handles.h.Img{handles.h.Id}.I.createModel();
        end
        material_list = handles.h.Img{handles.h.Id}.I.modelMaterialNames;
        color_list = handles.h.Img{handles.h.Id}.I.modelMaterialColors;
    end
    wb = waitbar(0, 'Please wait...', 'Name', 'Fusing the datasets');
    for fnId=1:no_files
        if imgSw == 1
            options.matlabVersion = handles.h.matlabVersion;
            options.Font = handles.h.preferences.Font;
            [img_info{fnId}, files{fnId}, pixSize{fnId}] = getImageMetadata(handles.filenames(fnId), options);
            if isKey(img_info{fnId}, 'ImageDescription') == 0
                errordlg('In order to fuse the images the Bounding Box information should be present in the ImageDescription field!','Missing the ImageDescription');
                return;
            end
            curr_text = img_info{fnId}('ImageDescription');             % get current bounding box x1,y1,z1
            bb_info_exist = strfind(curr_text,'BoundingBox');
            if bb_info_exist == 0   % use information from the BoundingBox
                errordlg('In order to fuse the images the Bounding Box information should be present in the ImageDescription field!','Missing the ImageDescription');
                delete(wb);
                return;
            end
            spaces = strfind(curr_text,' ');
            if numel(spaces) < 7; spaces(7) = numel(curr_text); end;
            tab_pos = strfind(curr_text,sprintf('|'));
            pos = min([spaces(7) tab_pos]);
            bb = str2num(curr_text(spaces(1):pos-1)); %#ok<ST2NM>
            
            if strcmp(sprintf('%.6f',pixSize{fnId}.x), sprintf('%.6f', handles.h.Img{handles.h.Id}.I.pixSize.x)) == 0 || ...
                    strcmp(sprintf('%.6f',pixSize{fnId}.y), sprintf('%.6f', handles.h.Img{handles.h.Id}.I.pixSize.y)) == 0
                errordlg(sprintf('!!! Error !!!\nPixel sizes mismatch!\n\nFilename: %s', handles.filenames{fnId}), 'Pixel sizes mismatch!');
                delete(wb);
                return;
            end
            % find shifts
            currBB = handles.h.Img{handles.h.Id}.I.getBoundingBox();    % get current Bounding Box
            
            x1 = max([1 ceil((bb(1)-currBB(1))/handles.h.Img{handles.h.Id}.I.pixSize.x + 0.000000001)]);    % need to add a small number due to floats
            y1 = max([1 ceil((bb(3)-currBB(3))/handles.h.Img{handles.h.Id}.I.pixSize.y + 0.000000001)]);
            z1 = max([1 ceil((bb(5)-currBB(5))/handles.h.Img{handles.h.Id}.I.pixSize.z + 0.000000001)]);
            
            if x1 < 1 || y1 < 1 || z1 < 1
                errordlg(sprintf('!!! Error !!!\nWrong minimal coordinate of the bounding box!\n\nFilename: %s', handles.filenames{fnId}), 'Wrong bounding box!');
                delete(wb);
                return;
            end
            
            x2 = min([x1+files{fnId}.width-1 handles.h.Img{handles.h.Id}.I.width]);
            y2 = min([y1+files{fnId}.height-1 handles.h.Img{handles.h.Id}.I.height]);
            z2 = min([z1+files{fnId}.noLayers-1 handles.h.Img{handles.h.Id}.I.no_stacks]);
            
            if x2 > handles.h.Img{handles.h.Id}.I.width || y2 > handles.h.Img{handles.h.Id}.I.height || z2 > handles.h.Img{handles.h.Id}.I.no_stacks
                errordlg(sprintf('!!! Error !!!\nWrong maximal coordinate of the  bounding box!\n\nFilename: %s', handles.filenames{fnId}), 'Wrong bounding box!');
                delete(wb);
                return;
            end
            
            [img, img_info{fnId}] = ib_getImages(files{fnId}, img_info{fnId});
            %handles.h.Img{handles.h.Id}.I.img(y1:y2, x1:x2,1:files{fnId}.color, z1:z2) = img;
            
            opt.x = [x1 x2];
            opt.y = [y1 y2];
            opt.z = [z1 z2];
            handles.h.Img{handles.h.Id}.I.setData3D('image', img, NaN, 4, NaN, opt);
            
            if modelSw    % fuse into the model
                [path, fn, ext] = fileparts(handles.filenames{fnId});
                if isempty(strfind(fn, 'Labels'))
                    fn = fullfile(path, ['Labels_' fn modelExt]);     % Add Labels_ to the filename and change extension
                else
                    fn = fullfile(path, [fn modelExt]);     % change extension
                end
                
                % load models
                R = loadModels(fn, handles);
                
                if numel(R.material_list) > numel(material_list)
                    material_list = R.material_list;
                end
                
                if isfield(R, 'color_list')
                    if fnId == 1
                        color_list = R.color_list;
                    elseif size(R.color_list,1) > size(color_list,1)
                        color_list = R.color_list;
                    end
                end
                
                opt.x = [x1 x2];
                opt.y = [y1 y2];
                opt.z = [z1 z2];
                handles.h.Img{handles.h.Id}.I.setData3D('model', R.imOut, NaN, 4, NaN, opt);
            end
            
            if maskSw    % fuse into the mask
                [path, fn, ext] = fileparts(handles.filenames{fnId});
                fn = fullfile(path, [fn '.mask']);     % Change extension
                
                if exist(fn, 'file') == 0
                    errordlg(sprintf('!!! Error !!!\n\nThe file for the Mask:\n%s\nwas not found!\nPlease check the filenames or unselect the Masks checkbox!', fn),'Missing the mask files');
                    delete(wb);
                    return;
                end
                
                R = load(fn, '-mat');
                fieldsId = fieldnames(R);
                opt.x = [x1 x2];
                opt.y = [y1 y2];
                opt.z = [z1 z2];
                handles.h.Img{handles.h.Id}.I.setData3D('mask', R.(fieldsId{1}), NaN, 4, NaN, opt);
            end
        elseif modelSw == 1     % get only the model, without image
            fn = handles.filenames{fnId};
            
            % load models
            R = loadModels(fn, handles);
            
            if numel(R.material_list) > numel(material_list)
                material_list = R.material_list;
            end
            
            if isfield(R, 'color_list')
                if fnId == 1
                    color_list = R.color_list;
                elseif size(R.color_list,1) > size(color_list,1)
                    color_list = R.color_list;
                end
            end
            
            if isfield(R, 'bounding_box') == 0
                errordlg(sprintf('!!! Error !!!\n\nThe bounding box is missing!'),'Error');
                delete(wb);
                return;
            end
            bb = R.bounding_box;
            
            % find shifts
            currBB = handles.h.Img{handles.h.Id}.I.getBoundingBox();    % get current Bounding Box
            x1 = ceil((bb(1)-currBB(1))/handles.h.Img{handles.h.Id}.I.pixSize.x + 1);
            y1 = ceil((bb(3)-currBB(3))/handles.h.Img{handles.h.Id}.I.pixSize.y + 1);
            z1 = ceil((bb(5)-currBB(5))/handles.h.Img{handles.h.Id}.I.pixSize.z + 1);
            
            if x1 < 1 || y1 < 1 || z1 < 1
                errordlg(sprintf('!!! Error !!!\nWrong minimal coordinate of the bounding box!\n\nFilename: %s', handles.filenames{fnId}), 'Wrong bounding box!');
                delete(wb);
                return;
            end
            
            if ~isfield(R, 'model_var')
                R.model_var = 'imOut';
            end
            
            x2 = x1+size(R.(R.model_var),2)-1;
            y2 = y1+size(R.(R.model_var),1)-1;
            z2 = z1+size(R.(R.model_var),3)-1;
            
            if x2 > handles.h.Img{handles.h.Id}.I.width || y2 > handles.h.Img{handles.h.Id}.I.height || z2 > handles.h.Img{handles.h.Id}.I.no_stacks
                errordlg(sprintf('!!! Error !!!\nWrong maximal coordinate of the  bounding box!\n\nFilename: %s', handles.filenames{fnId}), 'Wrong bounding box!');
                delete(wb);
                return;
            end
            
            opt.x = [x1 x2];
            opt.y = [y1 y2];
            opt.z = [z1 z2];
            handles.h.Img{handles.h.Id}.I.setData3D('model', R.(R.model_var), NaN, 4, NaN, opt);
        end

        waitbar(fnId/no_files, wb);
    end
    delete(wb);
end

if modelSw == 1
    handles.h.Img{handles.h.Id}.I.modelMaterialNames = material_list;
    handles.h.Img{handles.h.Id}.I.modelMaterialColors = color_list;
    set(handles.h.modelShowCheck, 'value', 1);
end

if maskSw == 1
    set(handles.h.maskShowCheck, 'value', 1);
    handles.h.Img{handles.h.Id}.I.maskExist = 1;
end

updateGuiWidgets(handles.h);
handles.h = guidata(handles.h.im_browser);

handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
mib_rechopDatasetGui_CloseRequestFcn(handles.mib_rechopDatasetGui, eventdata, handles);
end


function R = loadModels(fn, handles)
R = struct();
if exist(fn, 'file') == 0
    errordlg(sprintf('!!! Error !!!\n\nThe file for the Model:\n%s\nwas not found!\nPlease check the filenames or unselect the Models checkbox!', fn),'Missing the model files');
    delete(wb);
    return;
end
[~, ~, modelExt] = fileparts(fn);

getMetaOpt.matlabVersion = handles.h.matlabVersion;
getMetaOpt.Font = handles.h.preferences.Font;
switch modelExt
    case '.mat'
        R = load(fn);
        if isfield(R, 'model_var') && ~isfield(R, 'imOut')
            R.imOut = R.(R.model_var);
            R = rmfield(R, R.model_var);
            R.model_var = 'imOut';
        end
    case '.am'
        getMetaOpt.waitbar = 0;
        img_info = getImageMetadata({fn}, getMetaOpt);
        keysList = keys(img_info);
        for keyId=1:numel(keysList)
            strfindResult = strfind(keysList{keyId}, 'Materials_');
            if ~isempty(strfindResult)
                materialInfo = img_info(keysList{keyId});
                dummyIndex = strfind(materialInfo, 'Color');
                materialIndex = str2double(materialInfo(1:dummyIndex-1));
                materialColor = str2num(materialInfo(dummyIndex+6:end)); %#ok<ST2NM>
                R.color_list(materialIndex, :) = materialColor(1:3);
                dummyIndex = strfind(keysList{keyId}, '_');
                R.material_list{materialIndex, :} = keysList{keyId}(dummyIndex(1)+1:dummyIndex(2)-1);
            end
        end
        R.imOut = amiraLabels2bitmap(fn);
    case '.nrrd'
        getMetaOpt.waitbar = 0;
        img_info = getImageMetadata({fn}, getMetaOpt);
        R.imOut = nrrdLoadWithMetadata(fn);
        R.imOut =  uint8(permute(R.imOut.data, [2 1 3]));
    case '.tif'
        getDataOpt.bioformatsCheck = 0;
        getDataOpt.progressDlg = 1;
        [R.imOut, img_info, ~] = ib_loadImages({fn}, getDataOpt, handles.h);
        R.imOut =  squeeze(R.imOut);
    case '.xml'
        getDataOpt.bioformatsCheck = 0;
        getDataOpt.progressDlg = 0;
        [R.imOut, img_info] = ib_loadImages({fn}, getDataOpt, handles.h);
        R.imOut = squeeze(R.imOut);
        if isKey(img_info, 'material_list')     % add list of material names
            R.material_list = img_info('material_list');
        end
        if isKey(img_info, 'color_list')     % add list of colors for materials
            R.color_list = img_info('color_list');
        end
end

% get bounding box
if exist('img_info','var')
    if isKey(img_info, 'ImageDescription')
        curr_text = img_info('ImageDescription');             % get current bounding box x1,y1,z1
        bb_info_exist = strfind(curr_text,'BoundingBox');
        if bb_info_exist == 1   % use information from the BoundingBox parameter for pixel sizes if it is exist
            spaces = strfind(curr_text,' ');
            if numel(spaces) < 7; spaces(7) = numel(curr_text); end;
            tab_pos = strfind(curr_text,sprintf('|'));
            pos = min([spaces(7) tab_pos]);
            R.bounding_box = str2num(curr_text(spaces(1):pos-1)); %#ok<ST2NM>
        end
    end
end

% generate material names and colors
if ~isfield(R, 'material_list')
    nMaterials = max(R.imOut(:));
    for matId = 1:nMaterials
        R.material_list(matId, :) = {num2str(matId)};
        if matId <= size(handles.h.Img{handles.h.Id}.I.modelMaterialColors,1)
            R.color_list(matId, :) = handles.h.Img{handles.h.Id}.I.modelMaterialColors(matId,:);
        else
            R.color_list(matId, :) = [rand(1) rand(1) rand(1)];
        end
    end
end

end
