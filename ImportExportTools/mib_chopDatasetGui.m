function varargout = mib_chopDatasetGui(varargin)
% MIB_CHOPDATASETGUI MATLAB code for mib_chopDatasetGui.fig
%      MIB_CHOPDATASETGUI, by itself, creates a new MIB_CHOPDATASETGUI or raises the existing
%      singleton*.
%
%      H = MIB_CHOPDATASETGUI returns the handle to a new MIB_CHOPDATASETGUI or the handle to
%      the existing singleton*.
%
%      MIB_CHOPDATASETGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIB_CHOPDATASETGUI.M with the given input arguments.
%
%      MIB_CHOPDATASETGUI('Property','Value',...) creates a new MIB_CHOPDATASETGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mib_chopDatasetGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mib_chopDatasetGui_OpeningFcn via varargin.
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
% 25.01.2016, updated for 4D

% Edit the above text to modify the response to help mib_chopDatasetGui

% Last Modified by GUIDE v2.5 16-May-2015 16:17:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mib_chopDatasetGui_OpeningFcn, ...
    'gui_OutputFcn',  @mib_chopDatasetGui_OutputFcn, ...
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

% --- Executes just before mib_chopDatasetGui is made visible.
function mib_chopDatasetGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_chopDatasetGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser

% get dataset dimensions
options.blockModeSwitch = 0;    % disable the blockmode
[h, w, c, z] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4, NaN, options);

set(handles.textInfo, 'string', sprintf('xmin-xmax: 1 - %d\nymin-ymax: 1 - %d\nzmin-zmax: 1 - %d\n',...
    w, h, z));

% get voxel size
pixSizeX = handles.h.Img{handles.h.Id}.I.pixSize.x;
pixSizeY = handles.h.Img{handles.h.Id}.I.pixSize.y;
pixSizeZ = handles.h.Img{handles.h.Id}.I.pixSize.z;
set(handles.pixSizeText, 'string', sprintf('X: %g\nY: %g\nZ: %g\n',...
    pixSizeX, pixSizeY,pixSizeZ));

% disable checkboxes, if needed
if handles.h.Img{handles.h.Id}.I.modelExist == 0
    set(handles.chopModelCheck, 'enable', 'off');
end
if handles.h.Img{handles.h.Id}.I.maskExist == 0
    set(handles.chopMaskCheck, 'enable', 'off');
end

% set default directory for the export
set(handles.dirEdit, 'String', handles.h.mypath);
handles.outputDir = handles.h.mypath;

% set template
[path, filename, ext] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
set(handles.filenameTemplate, 'string', [filename '_chop']);

% update font and size
if get(handles.textInfo, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.textInfo, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.mib_chopDatasetGui, handles.h.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_chopDatasetGui);

% Choose default command line output for mib_BoundingBoxDlg
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

% UIWAIT makes mib_chopDatasetGui wait for user response (see UIRESUME)
uiwait(handles.mib_chopDatasetGui);
end

% --- Outputs from this function are returned to the command line.
function varargout = mib_chopDatasetGui_OutputFcn(hObject, eventdata, handles)
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

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
handles.output = 0;
guidata(handles.mib_chopDatasetGui, handles);
mib_chopDatasetGui_CloseRequestFcn(handles.mib_chopDatasetGui, eventdata, handles);
end

% --- Executes when user attempts to close mib_chopDatasetGui.
function mib_chopDatasetGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_chopDatasetGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
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

% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
if isdeployed
    if isunix()
        [~, user_name] = system('whoami');
        pathName = fullfile('./Users', user_name(1:end-1), 'Documents/MIB');
        web(fullfile(pathName, 'techdoc/html/ug_gui_menu_file_chop.html'), '-helpbrowser');
    else
        web(fullfile(pwd, 'techdoc/html/ug_gui_menu_file_chop.html'), '-helpbrowser');
    end
else
    web(fullfile(fileparts(which('im_browser')),'techdoc','html','ug_gui_menu_file_chop.html'));
end
end

% --- Executes on button press in chopBtn.
function chopBtn_Callback(hObject, eventdata, handles)
tilesX = str2double(get(handles.xTilesEdit, 'string'));
tilesY = str2double(get(handles.yTilesEdit, 'string'));
tilesZ = str2double(get(handles.zTilesEdit, 'string'));

outputDir = handles.outputDir;
fnTemplate = get(handles.filenameTemplate, 'string');
switch get(handles.formatPopup, 'value');
    case 1  % amira mesh
        ext = '.am';
    case 2  % nrrd
        ext = '.nrrd';
    case 3  % tif
        ext = '.tif';
end

% get dataset dimensions
options.blockModeSwitch = 0;    % disable the blockmode
[height, width, color, stacks] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4, NaN, options);

xStep = ceil(width/tilesX);
yStep = ceil(height/tilesY);
zStep = ceil(stacks/tilesZ);

timePnt = handles.h.Img{handles.h.Id}.I.slices{5}(1);
for z=1:tilesZ
    for x=1:tilesX
        for y=1:tilesY
            yMin = (y-1)*yStep+1;
            yMax = min([(y-1)*yStep+yStep, height]);
            xMin = (x-1)*xStep+1;
            xMax = min([(x-1)*xStep+xStep, width]);
            zMin = (z-1)*zStep+1;
            zMax = min([(z-1)*zStep+zStep, stacks]);
            
            %fprintf('Y: %d-%d\tX: %d-%d\tZ: %d-%d\n', yMin, yMax,xMin, xMax,zMin, zMax);
            options.y = [yMin, yMax];
            options.x = [xMin, xMax];
            options.z = [zMin, zMax];
            imOut = handles.h.Img{handles.h.Id}.I.getData3D('image', timePnt, 4, 0, options);
            imgOut2 = imageData(handles.h, 'uint6', imOut);
            imgOut2.pixSize = handles.h.Img{handles.h.Id}.I.pixSize;
            imgOut2.img_info('ImageDescription') = handles.h.Img{handles.h.Id}.I.img_info('ImageDescription');
            
            % update Bounding Box
            xyzShift = [(xMin-1)*imgOut2.pixSize.x (yMin-1)*imgOut2.pixSize.y (zMin-1)*imgOut2.pixSize.z];
            imgOut2.updateBoundingBox(NaN, xyzShift);
            
            log_text = sprintf('Chop: [y1:y2,x1:x2,:,z1:z2,t]: %d:%d,%d:%d,:,%d:%d,%d:%d', yMin,yMax,xMin,xMax, zMin,zMax, timePnt);
            imgOut2.updateImgInfo(log_text);
            
            % generate filename
            fn = sprintf('%s_Z%.2d-X%.2d-Y%.2d%s', fnTemplate, z, x, y, ext);
            filename = fullfile(outputDir, fn);
            imgOut2.img_info('Filename') = filename;
            
            switch ext
                case '.am'  % Amira Mesh
                    savingOptions = struct('overwrite', 1);
                    savingOptions.colors = handles.h.Img{handles.h.Id}.I.lutColors;   % store colors for color channels 0-1;
                    bitmap2amiraMesh(filename, imgOut2.img, ...
                        containers.Map(keys(imgOut2.img_info),values(imgOut2.img_info)), savingOptions);
                case '.nrrd'  % NRRD
                    savingOptions = struct('overwrite', 1);
                    bb = imgOut2.getBoundingBox();
                    bitmap2nrrd(filename, imgOut2.img, bb, savingOptions);
                case '.tif' % uncompressed TIF
                    compression = 'none';
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
            
            % crop and save model
            if get(handles.chopModelCheck, 'value')
                fn = sprintf('Labels_%s_Z%.2d-X%.2d-Y%.2d.mat', fnTemplate, z, x, y);
                fnModel = fullfile(outputDir, fn);
                
                imgOut2.hLabels = copy(handles.h.Img{handles.h.Id}.I.hLabels);
                % crop labels
                imgOut2.hLabels.crop([xMin, yMin, NaN, NaN, zMin, NaN]);
                
                imOut = handles.h.Img{handles.h.Id}.I.getData3D('model', timePnt, 4, 0, options); %#ok<NASGU>
                material_list = handles.h.Img{handles.h.Id}.I.modelMaterialNames; %#ok<NASGU>
                color_list = handles.h.Img{handles.h.Id}.I.modelMaterialColors; %#ok<NASGU>
                
                bounding_box = imgOut2.getBoundingBox(); %#ok<NASGU>
                
                if handles.h.Img{handles.h.Id}.I.hLabels.getLabelsNumber() > 1  % save annotations
                    [labelText, labelPosition] = handles.h.Img{handles.Id}.I.hLabels.getLabels(); %#ok<NASGU,ASGLU>
                    save(fnModel, 'imOut', 'material_list', 'color_list', 'bounding_box', 'labelText', 'labelPosition', '-mat', '-v7.3');
                else    % save without annotations
                    save(fnModel, 'imOut', 'material_list', 'color_list', 'bounding_box', '-mat', '-v7.3');
                end
            end
            
            % crop and save mask
            if get(handles.chopMaskCheck, 'value')
                fn = sprintf('%s_Z%.2d-X%.2d-Y%.2d.mask', fnTemplate, z, x, y);
                fnModel = fullfile(outputDir, fn);
                imOut = handles.h.Img{handles.h.Id}.I.getData3D('mask', timePnt, 4, 0, options); %#ok<NASGU>
                save(fnModel, 'imOut','-mat', '-v7.3');
            end
        end
    end
end

disp('MIB: the dataset was chopped!')

handles.output = 1;
guidata(hObject, handles);
mib_chopDatasetGui_CloseRequestFcn(handles.mib_chopDatasetGui, eventdata, handles);
end
