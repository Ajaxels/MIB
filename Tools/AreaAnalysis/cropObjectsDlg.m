function varargout = cropObjectsDlg(varargin)
% cropObjectsDlg MATLAB code for cropObjectsDlg.fig
%      cropObjectsDlg, by itself, creates a new cropObjectsDlg or raises the existing
%      singleton*.
%
%      H = cropObjectsDlg returns the handle to a new cropObjectsDlg or the handle to
%      the existing singleton*.
%
%      cropObjectsDlg('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in cropObjectsDlg.M with the given input arguments.
%
%      cropObjectsDlg('Property','Value',...) creates a new cropObjectsDlg or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cropObjectsDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cropObjectsDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 16.05.2015 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.03.2016, IB, updated for 4D datasets

% Last Modified by GUIDE v2.5 07-Jul-2016 14:03:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @cropObjectsDlg_OpeningFcn, ...
    'gui_OutputFcn',  @cropObjectsDlg_OutputFcn, ...
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

% --- Executes just before cropObjectsDlg is made visible.
function cropObjectsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cropObjectsDlg (see VARARGIN)

handles.h2 = varargin{1};    % handles of MaskStatsDlg
handles.h2 = rmfield(handles.h2, 'h');    % remove MIB handle
handles.h = varargin{2};    % handles of im_browser

% set default directory for the export
set(handles.dirEdit, 'String', handles.h.mypath);
handles.outputDir = handles.h.mypath;

% radio button callbacks
set(handles.targetPanel, 'SelectionChangeFcn', @targetPanelRadio_Callback);

if handles.h.Img{handles.h.Id}.I.maskExist == 0
    set(handles.cropMaskCheck, 'enable', 'off');
end

if handles.h.Img{handles.h.Id}.I.modelExist == 0
    set(handles.cropModelCheck, 'enable', 'off');
end

% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.cropObjectsDlg, handles.h.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.cropObjectsDlg);

% Choose default command line output for cropObjectsDlg
handles.output = 0;

%% set background color to panels and texts
set(handles.cropObjectsDlg,'Color',[.831 .816 .784]);
tempList = findall(handles.cropObjectsDlg,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.cropObjectsDlg,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.cropObjectsDlg,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.cropObjectsDlg,'Style','radiobutton');    % set color to radiobutton
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.cropObjectsDlg,'Type','uibuttongroup');    % set color to uibuttongroup
set(tempList,'BackgroundColor',[.831 .816 .784]);

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

% UIWAIT makes cropObjectsDlg wait for user response (see UIRESUME)
uiwait(handles.cropObjectsDlg);
end

% --- Executes on button press in distanceRadio.
function targetPanelRadio_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
hObject = eventdata.NewValue;
tagId = get(hObject, 'tag');

switch tagId
    case 'fileRadio'
        set(handles.formatPopup, 'enable','on');
        set(handles.selectDirBtn, 'enable','on');
        set(handles.dirEdit, 'enable','on');
    case 'matlabRadio'
        set(handles.formatPopup, 'enable','off');
        set(handles.selectDirBtn, 'enable','off');
        set(handles.dirEdit, 'enable','off');
end
cropMaskCheck_Callback(handles.cropMaskCheck, eventdata, handles);
cropModelCheck_Callback(handles.cropModelCheck, eventdata, handles)
end

% --- Outputs from this function are returned to the command line.
function varargout = cropObjectsDlg_OutputFcn(hObject, eventdata, handles)
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
guidata(handles.cropObjectsDlg, handles);
cropObjectsDlg_CloseRequestFcn(handles.cropObjectsDlg, eventdata, handles);
end

% --- Executes on button press in selectDirBtn.
function selectDirBtn_Callback(hObject, eventdata, handles)
folder_name = uigetdir(get(handles.dirEdit, 'string'), 'Select directory');
if isequal(folder_name,0); return; end;
set(handles.dirEdit, 'string', folder_name);
handles.outputDir = folder_name;
guidata(hObject, handles);
end


function dirEdit_Callback(hObject, eventdata, handles)
folder_name = get(handles.dirEdit, 'string');
if exist(folder_name, 'dir') == 0
    choice = questdlg(sprintf('!!! Warnging !!!\nThe target directory:\n%s\nis missing!\n\nCreate?', folder_name), ...
        'Create Directory', ...
        'Create','Cancel','Cancel');
    if strcmp(choice, 'Cancel');
        set(handles.dirEdit, 'string', handles.outputDir);
        return;
    end;
    mkdir(folder_name);
end
handles.outputDir = folder_name;
guidata(hObject, handles);
end

% --- Executes when user attempts to close cropObjectsDlg.
function cropObjectsDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to cropObjectsDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
end

% --- Executes on button press in cropBtn.
function cropBtn_Callback(hObject, eventdata, handles)
% generate extension
switch get(handles.formatPopup, 'value')
    case 1
        ext = '.am';
    case 2
        ext = '.mrc';
    case 3
        ext = '.nrrd';
    case 4
        ext = '.tif';
    case 5
        ext = '.tif';
end
[~, fnTemplate] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));

data = get(handles.h2.statTable,'Data');

dimOpt.blockModeSwitch = 0;
[h,w,c,z] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4, NaN, dimOpt);

% set CC structure for identification of the Bounding Box
if get(handles.h2.object2dRadio, 'value') == 1  % 2D mode
    if get(handles.h2.connectivityCombo, 'value') == 1
        CC.Connectivity = 4;
    else
        CC.Connectivity = 8;
    end
    CC.ImageSize = [h, w];
else            % 3D mode
    if get(handles.h2.connectivityCombo, 'value') == 1
        CC.Connectivity = 6;
    else
        CC.Connectivity = 26;
    end
    CC.ImageSize = [h, w, z];
end
CC.NumObjects = 1;

marginXY = str2double(get(handles.marginXYEdit, 'string'));
marginZ = str2double(get(handles.marginZEdit, 'string'));

% find uniqueTime - unique time points and their indices uniqueIndex
selectedIndices = handles.h2.indices(:,1);
[uniqueTime, ~, uniqueIndex] = unique(data(selectedIndices,4));

if handles.h.Img{handles.h.Id}.I.time > 1
    timeDigits = numel(num2str(handles.h.Img{handles.h.Id}.I.time));    % get number of digits for time
end

timeIter = 1;
for t=uniqueTime'   % has to be a horizontal vector
    if get(handles.cropModelCheck, 'value')
        modelImg =  handles.h.Img{handles.h.Id}.I.getData3D('model', t, 4, NaN, dimOpt);
    end
    if get(handles.cropMaskCheck, 'value')
        maskImg =  handles.h.Img{handles.h.Id}.I.getData3D('mask', t, 4, NaN, dimOpt);
    end
    
    curTimeObjIndices = selectedIndices(uniqueIndex==timeIter);     % find indices of objects for the current time point t
    for rowId = 1:numel(curTimeObjIndices)
        objId = data(curTimeObjIndices(rowId), 1);
        
        objectDigits = numel(num2str(numel(curTimeObjIndices)));    % get number of digits for objects
        if get(handles.h2.object2dRadio, 'value') == 1  % 2D mode
            sliceDigits = numel(num2str(z));    % get number of digits for slices
            sliceNumber = data(curTimeObjIndices(rowId), 3); %#ok<NASGU>
            if handles.h.Img{handles.h.Id}.I.time == 1
                cmdText = ['filename = fullfile(handles.outputDir, sprintf(''%s_%0' num2str(sliceDigits) 'd_%0' num2str(objectDigits) 'd%s'',  fnTemplate, sliceNumber, objId, ext));'];
            else
                cmdText = ['filename = fullfile(handles.outputDir, sprintf(''%s_%0' num2str(timeDigits) 'd_%0' num2str(sliceDigits) 'd_%0' num2str(objectDigits) 'd%s'',  fnTemplate, t, sliceNumber, objId, ext));'];
            end
            eval(cmdText);
            
            % recalculate pixelIds from 3D to 2D space
            CC.PixelIdxList{1} = handles.h2.STATS(objId).PixelIdxList-h*w*(sliceNumber-1);
        else
            %filename = fullfile(handles.outputDir, sprintf('%s_%06d%s',  fnTemplate, objId, ext));
            if handles.h.Img{handles.h.Id}.I.time == 1
                cmdText = ['filename = fullfile(handles.outputDir, sprintf(''%s_%0' num2str(objectDigits) 'd%s'',  fnTemplate, objId, ext));'];
            else
                cmdText = ['filename = fullfile(handles.outputDir, sprintf(''%s_%0' num2str(timeDigits) 'd_%0' num2str(objectDigits) 'd%s'',  fnTemplate, t, objId, ext));'];
            end
            eval(cmdText);
            CC.PixelIdxList{1} = handles.h2.STATS(objId).PixelIdxList;
        end
        
        % get bounding box
        S = regionprops(CC,'BoundingBox');
        
        if get(handles.h2.object2dRadio, 'value') == 1  % 2D mode
            xMin = ceil(S.BoundingBox(1))-marginXY;
            yMin = ceil(S.BoundingBox(2))-marginXY;
            xMax = xMin+floor(S.BoundingBox(3))-1+marginXY*2;
            yMax = yMin+floor(S.BoundingBox(4))-1+marginXY*2;
            zMin = sliceNumber;
            zMax = sliceNumber;
        else
            xMin = ceil(S.BoundingBox(1))-marginXY;
            yMin = ceil(S.BoundingBox(2))-marginXY;
            xMax = xMin+floor(S.BoundingBox(4))-1+marginXY*2;
            yMax = yMin+floor(S.BoundingBox(5))-1+marginXY*2;
            zMin = ceil(S.BoundingBox(3))-marginZ;
            zMax = zMin+floor(S.BoundingBox(6))-1+marginZ*2;
        end
        
        xMin = max([xMin 1]);
        yMin = max([yMin 1]);
        zMin = max([zMin 1]);
        xMax = min([xMax w]);
        yMax = min([yMax h]);
        zMax = min([zMax z]);
        
        imOut = handles.h.Img{handles.h.Id}.I.img(yMin:yMax, xMin:xMax, :, zMin:zMax, t);
        imgOut2 = imageData(handles.h, 'uint6', imOut);
        imgOut2.pixSize = handles.h.Img{handles.h.Id}.I.pixSize;
        imgOut2.img_info('ImageDescription') = handles.h.Img{handles.h.Id}.I.img_info('ImageDescription');
        
        % update Bounding Box
        xyzShift = [(xMin-1)*imgOut2.pixSize.x (yMin-1)*imgOut2.pixSize.y (zMin-1)*imgOut2.pixSize.z];
        imgOut2.updateBoundingBox(NaN, xyzShift);
        log_text = sprintf('ObjectCrop: [y1:y2,x1:x2,:,z1:z2,t]: %d:%d,%d:%d,:,%d:%d,%d', yMin,yMax,xMin,xMax, zMin,zMax,t);
        imgOut2.updateImgInfo(log_text);
        
        if get(handles.matlabRadio, 'value') == 1   % export to Matlab
            %matlabVarName = sprintf('%s_%06d%s',  fnTemplate, objId);
            [~,matlabVarName] = fileparts(filename);
            matlabVar.img = imgOut2.img;
            matlabVar.img_info = containers.Map(keys(imgOut2.img_info), values(imgOut2.img_info));
        else
            switch get(handles.formatPopup, 'value')
                case 1  % Amira Mesh
                    savingOptions = struct('overwrite', 1);
                    savingOptions.colors = handles.h.Img{handles.h.Id}.I.lutColors;   % store colors for color channels 0-1;
                    bitmap2amiraMesh(filename, imgOut2.img, ...
                        containers.Map(keys(imgOut2.img_info),values(imgOut2.img_info)), savingOptions);
                case 2 % MRC
                    savingOptions.volumeFilename = filename;
                    savingOptions.pixSize = imgOut2.pixSize;
                    ib_image2mrc(imgOut2.img, savingOptions);
                case 3  % NRRD
                    savingOptions = struct('overwrite', 1);
                    bb = imgOut2.getBoundingBox();
                    bitmap2nrrd(filename, imgOut2.img, bb, savingOptions);
                case {4, 5}  % LZW TIF / uncompressed TIF
                    if get(handles.formatPopup, 'value') == 4
                        compression = 'lzw';
                    else
                        compression = 'none';
                    end
                    colortype = imgOut2.img_info('ColorType');
                    if strcmp(colortype,'indexed')
                        cmap = imgOut2.img_info('Colormap');
                    else
                        cmap = NaN;
                    end
                    
                    ImageDescription = {imgOut2.img_info('ImageDescription')};
                    savingOptions = struct('Resolution', [imgOut2.img_info('XResolution') imgOut2.img_info('YResolution')],...
                        'overwrite', 1, 'Saving3d', 'multi', 'cmap', cmap, 'Compression', compression);
                    ib_image2tiff(filename, imgOut2.img, savingOptions, ImageDescription);
            end
        end
        
        % crop and save model
        if get(handles.cropModelCheck, 'value')
            imgOut2.hLabels = copy(handles.h.Img{handles.h.Id}.I.hLabels);
            % crop labels
            imgOut2.hLabels.crop([xMin, yMin, NaN, NaN, zMin, NaN]);
            
            imOut =  modelImg(yMin:yMax, xMin:xMax, zMin:zMax); %#ok<NASGU>
            
            material_list = handles.h.Img{handles.h.Id}.I.modelMaterialNames; %#ok<NASGU>
            color_list = handles.h.Img{handles.h.Id}.I.modelMaterialColors; %#ok<NASGU>
            if get(handles.matlabRadio, 'value') == 1   % export to Matlab
                matlabVar.Model.model = imOut;
                matlabVar.Model.materials = material_list;
                matlabVar.Model.colors = color_list;
                if handles.h.Img{handles.h.Id}.I.hLabels.getLabelsNumber() > 1  % save annotations
                    [labelText, labelPosition] = handles.h.Img{handles.Id}.I.hLabels.getLabels(); %#ok<NASGU,ASGLU>
                    matlabVar.labelText = labelText;
                    matlabVar.labelPosition = labelPosition;
                end
            else
                % generate filename
                [~, fnModel] = fileparts(filename);
                bounding_box = imgOut2.getBoundingBox(); %#ok<NASGU>
                
                switch get(handles.modelFormatPopup, 'value')
                    case 1  % Matlab format
                        fnModel = ['Labels_' fnModel '.mat']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        if handles.h.Img{handles.h.Id}.I.hLabels.getLabelsNumber() > 1  % save annotations
                            [labelText, labelPosition] = handles.h.Img{handles.Id}.I.hLabels.getLabels(); %#ok<NASGU,ASGLU>
                            save(fnModel, 'imOut', 'material_list', 'color_list', 'bounding_box', 'labelText', 'labelPosition', '-mat', '-v7.3');
                        else    % save without annotations
                            save(fnModel, 'imOut', 'material_list', 'color_list', 'bounding_box', '-mat', '-v7.3');
                        end
                    case 2  % Amira Mesh
                        fnModel = ['Labels_' fnModel '.am']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        pixStr = imgOut2.pixSize;
                        pixStr.minx = bounding_box(1);
                        pixStr.miny = bounding_box(3);
                        pixStr.minz = bounding_box(5);
                        showWaitbar = 0;  % show or not waitbar in bitmap2amiraMesh
                        bitmap2amiraLabels(fnModel, imOut, 'binary', pixStr, color_list, material_list, 1, showWaitbar);
                    case 3 % MRC
                        fnModel = ['Labels_' fnModel '.mrc']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        Options.volumeFilename = fnModel;
                        Options.pixSize = imgOut2.pixSize;
                        savingOptions.showWaitbar = 0;  % show or not waitbar in exportModelToImodModel
                        ib_image2mrc(imOut, Options);
                    case 4  % NRRD
                        fnModel = ['Labels_' fnModel '.nrrd']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        Options.overwrite = 1;
                        Options.showWaitbar = 0;  % show or not waitbar in bitmap2nrrd
                        bitmap2nrrd(fnModel, imOut, bounding_box, Options);
                    case {5, 6}  % LZW TIF / uncompressed TIF
                        fnModel = ['Labels_' fnModel '.tif']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        if get(handles.formatPopup, 'value') == 5
                            compression = 'lzw';
                        else
                            compression = 'none';
                        end
                        ImageDescription = {imgOut2.img_info('ImageDescription')};
                        imOut = reshape(imOut,[size(imOut,1) size(imOut,2) 1 size(imOut,3)]);
                        savingOptions = struct('Resolution', [imgOut2.img_info('XResolution') imgOut2.img_info('YResolution')],...
                            'overwrite', 1, 'Saving3d', 'multi', 'Compression', compression);
                        ib_image2tiff(fnModel, imOut, savingOptions, ImageDescription);
                end
            end
        end
        
        % crop and save mask
        if get(handles.cropMaskCheck, 'value')
            imOut =  maskImg(yMin:yMax, xMin:xMax, zMin:zMax);
            if get(handles.matlabRadio, 'value') == 1   % export to Matlab
                matlabVar.Mask = imOut;
            else
                % generate filename
                [~, fnModel] = fileparts(filename);
                bounding_box = imgOut2.getBoundingBox(); %#ok<NASGU>
                
                switch get(handles.maskFormatPopup, 'value')
                    case 1  % Matlab format
                        fnModel = ['Mask_' fnModel '.mask']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        save(fnModel, 'imOut','-mat', '-v7.3');
                    case 2  % Amira Mesh
                        fnModel = ['Mask_' fnModel '.am']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        pixStr = imgOut2.pixSize;
                        pixStr.minx = bounding_box(1);
                        pixStr.miny = bounding_box(3);
                        pixStr.minz = bounding_box(5);
                        showWaitbar = 0;  % show or not waitbar in bitmap2amiraMesh
                        bitmap2amiraLabels(fnModel, imOut, 'binary', pixStr, handles.h.preferences.maskcolor, cellstr('Mask'), 1, showWaitbar);
                    case 3 % MRC
                        fnModel = ['Mask_' fnModel '.mrc']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        Options.volumeFilename = fnModel;
                        Options.pixSize = imgOut2.pixSize;
                        savingOptions.showWaitbar = 0;  % show or not waitbar in exportModelToImodModel
                        ib_image2mrc(imOut, Options);
                    case 4  % NRRD
                        fnModel = ['Mask_' fnModel '.nrrd']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        Options.overwrite = 1;
                        Options.showWaitbar = 0;  % show or not waitbar in bitmap2nrrd
                        bitmap2nrrd(fnModel, imOut, bounding_box, Options);
                    case {5, 6}  % LZW TIF / uncompressed TIF
                        fnModel = ['Mask_' fnModel '.tif']; %#ok<AGROW>
                        fnModel = fullfile(handles.outputDir, fnModel);
                        
                        if get(handles.formatPopup, 'value') == 5
                            compression = 'lzw';
                        else
                            compression = 'none';
                        end
                        ImageDescription = {imgOut2.img_info('ImageDescription')};
                        imOut = reshape(imOut,[size(imOut,1) size(imOut,2) 1 size(imOut,3)]);
                        savingOptions = struct('Resolution', [imgOut2.img_info('XResolution') imgOut2.img_info('YResolution')],...
                            'overwrite', 1, 'Saving3d', 'multi', 'Compression', compression);
                        ib_image2tiff(fnModel, imOut, savingOptions, ImageDescription);
                end
            end
        end
        
        % export to Matlab
        if get(handles.matlabRadio, 'value')
            answer = mib_inputdlg(handles.h, sprintf('Enter name for the export:\n(it should start with a letter)'),'Variable name:', matlabVarName);
            if isempty(answer); return; end
            matlabVarName = answer{1};
            
            assignin('base', matlabVarName, matlabVar);
            fprintf('MIB: %s was exported to Matlab\n', matlabVarName);
        end
    end
    timeIter = timeIter + 1;
end

handles.output = 1;
guidata(hObject, handles);
delete(handles.cropObjectsDlg);
end


% --- Executes on button press in cropModelCheck.
function cropModelCheck_Callback(hObject, eventdata, handles)
if get(handles.cropModelCheck, 'value') == 1 && get(handles.fileRadio, 'value') == 1
    set(handles.modelFormatPopup,'enable','on');
else
    set(handles.modelFormatPopup,'enable','off');
end
end


% --- Executes on button press in cropMaskCheck.
function cropMaskCheck_Callback(hObject, eventdata, handles)
if get(handles.cropMaskCheck, 'value') == 1 && get(handles.fileRadio, 'value') == 1
    set(handles.maskFormatPopup,'enable','on');
else
    set(handles.maskFormatPopup,'enable','off');
end
end
