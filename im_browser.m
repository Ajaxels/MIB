function varargout = im_browser(varargin)
% @mainpage Microscopy Image Browser
% @section intro Introduction
% @b Microscopy @b Image @b Browser is is a high-performance software package for advanced image processing, segmentation and visualization of multidimentional (2D-4D) datasets.
% Microscopy Image Browser is written in Matlab, but has a user friendly graphical interface that does not requre knowledge of Matlab and can be used by anybody.
% @section features Key Features
% - Works as a Matlab program under Windows/Linux/MacOS Matlab, or as a standalone application (Windows 64bit);
% - Open source, no license/fee required;
% - Extendable with custom plugins;
% - Generation of multidimentional image stacks;
% - Alignment of 3D stacks and images within these stacks;
% - Brightness, contrast, gamma, image mode adjustments, resize, crop functions;
% - Automatic/manual image segmentation with help of filters and interpolation in XY, XZ, or YZ planes;
% - Quantification and statistics for 2D/3D objects;
% - Export of images or models to Matlab, Amira, IMOD, TIF, NRRD formats;
% - Direct 3D visualization using Matlab isosurfaces or Fiji 3D viewer;
% - Log of performed actions;
% - Customizable Undo option
% - Colorblind friendly default color modeling scheme
% @section description Description
% Recent years witnessed a rapid development of 3D electron microscopy
% imaging techniques applied for the life science research. In addition to electron tomography
% (ET) that is effective on a subcellular level, several other alternative methods that extend the
% imaging up to the tissue level have been developed. Among these are new scanning electron microscopy (SEM)
% techniques that allow automated sequential imaging of a freshly cut block face of resin-embedded specimens
% using a back scatter detector. A fresh block face is created by an ultramicrotome inserted in the imaging
% chamber (Serial-Block Face SEM) or by focused ion beam (FIB-SEM). As a result, the amount and volumes of
% 3D datasets increases extensively raising a question of effective image processing and modeling.
% With development of Microscopy Image Browser (MIB) we address this problem and present a free,
% open-source software package, which can be used for image processing, analysis, segmentation and
% visualization of multidimensional datasets.
%
% @page install Download and installbination
% Please follow instructions on Microscopy Image Browser web page:
% http://mib.helsinki.fi

% Copyright (C) 2010-2015 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @im_browser_OpeningFcn, ...
    'gui_OutputFcn',  @im_browser_OutputFcn, ...
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

function im_browser_OpeningFcn(hObject, eventdata, handles, varargin)
% function im_browser_OpeningFcn(hObject, eventdata, handles, varargin)
% Opening function of im_browser
%
% Parameters:
% hObject: handle to figure
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
% varargin: command line arguments to im_browser (see VARARGIN)
%
% Return values:

% add path to other directories
if ~isdeployed
    func_name='im_browser.m';
    func_dir=which(func_name);
    func_dir=fileparts(func_dir);
    addpath(func_dir);
    addpath(fullfile(func_dir, 'Classes'));
    addpath(fullfile(func_dir, 'GuiTools'));
    addpath(fullfile(func_dir, 'GuiTools', 'volren'));
    addpath(fullfile(func_dir, 'ImageFilters'));
    addpath(fullfile(func_dir, 'ImageFilters', 'Coherence_filter'));
    addpath(fullfile(func_dir, 'ImageFilters', 'Coherence_filter','functions'));
    addpath(fullfile(func_dir, 'ImageFilters', 'Coherence_filter','functions2D'));
    addpath(fullfile(func_dir, 'ImageFilters', 'Coherence_filter','functions3D'));
    addpath(fullfile(func_dir, 'ImageFilters', 'FastMarching'));
    addpath(fullfile(func_dir, 'ImageFilters', 'FastMarching','functions'));
    addpath(fullfile(func_dir, 'ImageFilters', 'FastMarching','shortestpath'));
    addpath(fullfile(func_dir, 'ImageFilters', 'Frangi'));
    addpath(fullfile(func_dir, 'ImageFilters', 'RandomForest'));
    addpath(fullfile(func_dir, 'ImageFilters', 'RandomForest','RF_Class_C'));
    addpath(fullfile(func_dir, 'ImageFilters', 'RandomForest','RF_Reg_C'));
    addpath(fullfile(func_dir, 'ImageFilters', 'RandomForest','MembraneDetection'));
    addpath(fullfile(func_dir, 'ImageFilters', 'Supervoxels'));
    addpath(fullfile(func_dir, 'ImportExportTools'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'BioFormats'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'export_fig'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'Fiji'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'HDF5'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'Imaris'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'MatTomo'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'MatTomo', 'Utils'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'nrrd'));
    addpath(fullfile(func_dir, 'ImportExportTools', 'Omero'));
    addpath(fullfile(func_dir, 'Misc_func'));
    addpath(fullfile(func_dir, 'Misc_func', 'imclipboard'));
    addpath(fullfile(func_dir, 'techdoc'));
    addpath(fullfile(func_dir, 'Tools'));
    addpath(fullfile(func_dir, 'Tools', 'Align'));
    addpath(fullfile(func_dir, 'Tools', 'AreaAnalysis'));
    addpath(fullfile(func_dir, 'Tools', 'RegionGrowing'));
end

% get the current version of matlab; keep this variable to be faster and
% not call ver function
v = ver('matlab');
handles.matlabVersion = str2double(v(1).Version);
if handles.matlabVersion >= 8.4 % R2014b
    set(handles.im_browser,'GraphicsSmoothing','off');  % turn off smoothing and turn opengl renderer
    set(handles.im_browser, 'Renderer','opengl');
    set(handles.imageAxes,'FontSmoothing','off');
else
    %set(handles.im_browser,'Renderer','painters');
    set(handles.im_browser,'Renderer','opengl');
end

dateTag = 'ver. 1.22 / 22.08.2016'; % ATTENTION! it is important to have the version number between "ver." and "/"
%dateTag = ''; % it is important to have the version number between "ver." and "/"
title = ['Microscopy Image Browser ' dateTag];

if isdeployed; title = [title ' deployed version']; end;
set(handles.im_browser,'Name',title);

% show splash screen
try
    if isdeployed
        if isunix()
            %[~, user_name] = system('whoami');
            %pathName = fullfile('./Users', user_name(1:end-1), 'Documents/MIB');
            [status, result] = system('path');
            pathName = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
            
            % the code above does not work on Mac OS X Yosemite and R2016a
            % so fix MIB location 
            if isempty(pathName)
                pathName = '/Applications/MIB/application/';
            end
        else
            %pathName = pwd;
%             USERPROFILE_PATH = getenv('USERPROFILE');
%             mibDataPath = fullfile(USERPROFILE_PATH, 'AppData', 'Local', 'Microscopy Image Browser');
%             if isdir(mibDataPath) == 0
%                 mkdir(mibDataPath);
%             end
            [status, result] = system('path');
            pathName = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
        end
        handles.pathMIB = pathName;
        img = imread(fullfile(handles.pathMIB, 'Resources', 'splash'));  % load splash screen
        
        % get numbers for the brush size change
        handles.brushSizeNumbers = 1-imread(fullfile(handles.pathMIB, 'Resources', 'numbers.png'));   % height=16, letter size = 8, +1 pixel border
        handles.dejavufont = 1-imread(fullfile(handles.pathMIB, 'Resources', 'DejaVuSansMono.png'));   % table with DejaVu font, Pt = 8, 10, 12, 14, 16, 18, 20
    else
        handles.pathMIB = fileparts(which('im_browser'));
        img = imread(fullfile(handles.pathMIB, 'Resources', 'splash'));  % load splash screen
        
        % get numbers for the brush size change
        handles.brushSizeNumbers = 1-imread(fullfile(handles.pathMIB, 'Resources', 'numbers.png'));   % height=16, letter size = 8, +1 pixel border
        handles.dejavufont = 1-imread(fullfile(handles.pathMIB, 'Resources', 'DejaVuSansMono.png'));   % table with DejaVu font, Pt = 8, 10, 12, 14, 16, 18, 20
    end
    %dateTagCrop = dateTag(strfind(dateTag, 'ver.')+5:end);
    %img = rendertext(img, dateTagCrop,[255 255 255], [30, 392],'bnd','right');
    addTextOptions.color = [1 1 0];
    addTextOptions.fontSize = 2;
    addTextOptions.markerText = 'text';
    img = ib_addText2Img(img, dateTag, [1,425], handles.dejavufont, addTextOptions);
    
%     if handles.matlabVersion >= 8.4 && isdeployed && ~ismac() % R2014b
%         % do not show the splash screen
%     else
        jimg = im2java(img);
        frame = javax.swing.JFrame;
        frame.setUndecorated(true);
        icon = javax.swing.ImageIcon(jimg);
        label = javax.swing.JLabel(icon);
        frame.getContentPane.add(label);
        frame.pack;
        imgSize = size(img);
        frame.setSize(imgSize(2),imgSize(1));
        screenSize = get(0,'ScreenSize');
        frame.setLocation((screenSize(3)-imgSize(2))/2,...
            (screenSize(4)-imgSize(1))/2);
        frame.show;
%    end
catch err
    sprintf('%s', err.identifier);
end

%% Adding listeners, using Yair Altman, suggestion:
% http://undocumentedmatlab.com/blog/continuous-slider-callback/#Event_Listener
% to change layer slider

% % keep the code under im_browser
if handles.matlabVersion  < 8.4 % R2014a or earlier
    % for z-slider
    handles.changelayerSliderListener = handle.listener(handles.changelayerSlider,'ActionEvent',@changelayerSlider_Callback);
    handles.changelayerSliderListener.Enabled = 'off';  % disactivate the listener for Z=1;
    % for t-slider
    handles.changeTimeSliderListener = handle.listener(handles.changeTimeSlider,'ActionEvent',@changeTimeSlider_Callback);
    handles.changeTimeSliderListener.Enabled = 'off';  % disactivate the listener for Z=1;
    % to transparency sliders
    handles.modelTransSliderListener = handle.listener(handles.modelTransSlider,'ActionEvent',@imageRedraw);
    handles.modelmaskTransSliderListener = handle.listener(handles.maskTransSlider,'ActionEvent',@imageRedraw);
    handles.selectionTransparencySliderListener = handle.listener(handles.selectionTransparencySlider,'ActionEvent',@imageRedraw);
    % to the LowLim and HighLim sliders of the BW thresholding
    handles.segmLowSliderListener = handle.listener(handles.segmLowSlider,'ActionEvent',@segmBW_Update);
    handles.segmHighSliderListener = handle.listener(handles.segmHighSlider,'ActionEvent',@segmBW_Update);
else
    % for z-slider
    handles.changelayerSliderListener = addlistener(handles.changelayerSlider,'ContinuousValueChange',@changelayerSlider_Callback);
    handles.changelayerSliderListener.Enabled = 0;  % disactivate the listener for Z=1;
    % for t-slider
    handles.changeTimeSliderListener = addlistener(handles.changeTimeSlider,'ContinuousValueChange',@changeTimeSlider_Callback);
    handles.changeTimeSliderListener.Enabled = 0;  % disactivate the listener for Z=1;
    % to transparency sliders
    handles.modelTransSliderListener = addlistener(handles.modelTransSlider,'ContinuousValueChange',@imageRedraw);
    handles.modelmaskTransSliderListener = addlistener(handles.maskTransSlider,'ContinuousValueChange',@imageRedraw);
    handles.selectionTransparencySliderListener = addlistener(handles.selectionTransparencySlider,'ContinuousValueChange',@imageRedraw);
    % to the LowLim and HighLim sliders of the BW thresholding
    handles.segmLowSliderListener = addlistener(handles.segmLowSlider,'ContinuousValueChange',@segmBW_Update);
    handles.segmHighSliderListener = addlistener(handles.segmHighSlider,'ContinuousValueChange',@segmBW_Update);
end

% Choose default command line output for im_browser
handles.output = hObject;

% get default or load last session parameters
[handles, start_path] = im_browser_getDefaultParameters(handles);
handles.U = imageUndo(handles.preferences.maxUndoHistory, handles.preferences.max3dUndoHistory);    % create instanse for keeping undo information
% initializa image buffer with dummy images
handles.Id = 1;   % number of the selected buffer
for i=1:8
    if handles.preferences.uint8
        handles.Img{i}.I = imageData(handles, 'uint8');    % create instanse for keeping images;
    else
        handles.Img{i}.I = imageData(handles, 'uint6');    % create instanse for keeping images;
    end
    handles = handles.Img{i}.I.updateAxesLimits(handles, 'resize');
end;
if strcmp(handles.preferences.undo, 'no')
    handles.U.enableSwitch = 0;
else
    handles.U.enableSwitch = 1;
end

% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.im_browser);

% % adding menus to some widgets
% adding context menu for filesListbox
handles.filesListbox_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.filesListbox_cm, 'Label', 'Combine selected datasets...', 'Callback', {@filesListboxContext_cb, 'load'});
uimenu(handles.filesListbox_cm, 'Label', 'Load part of the dataset (*.am only)...', 'Callback', {@filesListboxContext_cb, 'loadPart'});
uimenu(handles.filesListbox_cm, 'Label', 'Load each N-th dataset...', 'Callback', {@filesListboxContext_cb, 'nth'});
uimenu(handles.filesListbox_cm, 'Label', 'Insert into the open dataset...', 'Callback', {@filesListboxContext_cb, 'insertData'});
uimenu(handles.filesListbox_cm, 'Label', 'Combine files as color channels...', 'Separator', 'on', 'Callback', {@filesListboxContext_cb, 'combinecolors'});
uimenu(handles.filesListbox_cm, 'Label', 'Add as a new color channel...', 'Callback', {@filesListboxContext_cb, 'addchannel'});
uimenu(handles.filesListbox_cm, 'Label', 'Add each N-th dataset as a new color channel...', 'Callback', {@filesListboxContext_cb, 'addchannel_nth'});
uimenu(handles.filesListbox_cm, 'Label', 'Rename selected file...', 'Separator', 'on', 'Callback', {@filesListboxContext_cb, 'rename'});
uimenu(handles.filesListbox_cm, 'Label', 'Delete selected files...', 'Callback', {@filesListboxContext_cb, 'delete'});
uimenu(handles.filesListbox_cm, 'Label', 'File properties', 'Separator', 'on', 'Callback', {@filesListboxContext_cb, 'file_properties'});
set(handles.filesListbox,'uicontextmenu',handles.filesListbox_cm);
% adding context menu for buffer toggles
for i=1:8
    eval(sprintf('handles.bufferToggle%d_cm = uicontextmenu(''Parent'', handles.im_browser);', i));
    eval(sprintf('uimenu(handles.bufferToggle%d_cm, ''Label'', ''Duplicate dataset'', ''Callback'', {@bufferToggles_cb, ''duplicate'',%d});', i, i));
    eval(sprintf('uimenu(handles.bufferToggle%d_cm, ''Label'', ''Sync view (x,y) with...'', ''Separator'',''on'',''Callback'', {@bufferToggles_cb, ''sync_xy'',%d});', i, i));
    eval(sprintf('uimenu(handles.bufferToggle%d_cm, ''Label'', ''Sync view (x,y,z) with...'', ''Callback'', {@bufferToggles_cb, ''sync_xyz'',%d});', i, i));
    eval(sprintf('uimenu(handles.bufferToggle%d_cm, ''Label'', ''Sync view (x,y,z,t) with...'', ''Callback'', {@bufferToggles_cb, ''sync_xyzt'',%d});', i, i));
    eval(sprintf('uimenu(handles.bufferToggle%d_cm, ''Label'', ''Clear dataset'', ''Separator'',''on'',''Callback'', {@bufferToggles_cb, ''clear'',%d});', i, i));
    eval(sprintf('uimenu(handles.bufferToggle%d_cm, ''Label'', ''Clear all stored datasets'', ''Callback'', {@bufferToggles_cb, ''clearAll'',%d});', i, i));
    eval(sprintf('set(handles.bufferToggle%d,''uicontextmenu'',handles.bufferToggle%d_cm);', i, i));
end

% adding context menu to ROI List
handles.roiList_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.roiList_cm, 'Label', 'Rename', 'Callback', {@roiList_cm_Callback, 'rename'});
uimenu(handles.roiList_cm, 'Label', 'Edit', 'Callback', {@roiList_cm_Callback, 'edit'});
uimenu(handles.roiList_cm, 'Label', 'Remove', 'Callback', {@roiList_cm_Callback, 'remove'}, 'Separator','on');
set(handles.roiList,'uicontextmenu',handles.roiList_cm);

% adding context menu to pixel information
handles.pixInfo_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.pixInfo_cm, 'Label', 'Jump to...', 'Callback', {@pixInfo_cb, 'jump'});
set(handles.pixelinfoTxt2,'uicontextmenu',handles.pixInfo_cm);
set(handles.pixelinfoTxt,'uicontextmenu',handles.pixInfo_cm);

% adding context menus for Change layer slider
handles.changelayer_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.changelayer_cm, 'Label', 'Default', 'Callback', {@changelayerSliderContext_cb, 'def'});
uimenu(handles.changelayer_cm, 'Label', 'Set step...', 'Callback', {@changelayerSliderContext_cb, 'set'});
set(handles.changelayerSlider,'uicontextmenu',handles.changelayer_cm);

% adding context menus for Min and Max threshold sliders
handles.threshold_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.threshold_cm, 'Label', 'Default', 'Callback', {@changeThresholdValueContext_cb, 'def'});
uimenu(handles.threshold_cm, 'Label', 'Set step...', 'Callback', {@changeThresholdValueContext_cb, 'set'});
set(handles.segmLowSlider,'uicontextmenu',handles.threshold_cm);
set(handles.segmHighSlider,'uicontextmenu',handles.threshold_cm);

% adding context menus for Contrast adjustment
handles.contrast_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.contrast_cm, 'Label', 'Show histogram', 'Callback', {@mib_contrastContext_cb, 'showhist'});
uimenu(handles.contrast_cm, 'Label', 'Contrast-limited adaptive histogram equalization for shown slice', 'Callback', {@mib_contrastContext_cb, 'CLAHE_2D'});
uimenu(handles.contrast_cm, 'Label', 'Contrast-limited adaptive histogram equalization for current stack', 'Callback', {@mib_contrastContext_cb, 'CLAHE_3D'});
uimenu(handles.contrast_cm, 'Label', 'Contrast-limited adaptive histogram equalization for complete volume', 'Callback', {@mib_contrastContext_cb, 'CLAHE_4D'});
set(handles.contrastBtn,'uicontextmenu',handles.contrast_cm);

% adding context menus for Mask Do it button
handles.mask_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.mask_cm, 'Label', 'Do new mask', 'Callback', {@maskGenBtn_Callback, NaN, 'new'});
uimenu(handles.mask_cm, 'Label', 'Generate new mask and add it to the existing mask', 'Callback', {@maskGenBtn_Callback, NaN, 'add'});
set(handles.maskGenBtn,'uicontextmenu',handles.mask_cm);

% adding context menus for Materials list
handles.model_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.model_cm, 'Label', 'Rename...', 'Callback', {@model_cm_Callback, 'rename'});
uimenu(handles.model_cm, 'Label', 'Set color...', 'Callback', {@model_cm_Callback, 'set color'});
uimenu(handles.model_cm, 'Label', 'Smooth...', 'Callback', {@model_cm_Callback, 'smooth'});
uimenu(handles.model_cm, 'Label', 'Get statistics...', 'Callback', {@model_cm_Callback, 'statistics'});
uimenu(handles.model_cm, 'Label', 'Show isosurface (Matlab)...', 'Callback', {@model_cm_Callback, 'isosurface'});
uimenu(handles.model_cm, 'Label', 'Show as volume (Fiji)...', 'Callback', {@model_cm_Callback, 'volumeFiji'});
uimenu(handles.model_cm, 'Label', 'Sync all lists', 'Callback', {@syncModelLists_Callback, 'material'}, 'Separator','on');
set(handles.segmList,'uicontextmenu',handles.model_cm);

% adding context menu for Select from list
handles.modelSel_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.modelSel_cm, 'Label', 'Set this material as Mask', 'Callback', {@ib_moveLayers, NaN, 'model','mask','3D','replace'});
uimenu(handles.modelSel_cm, 'Label', 'NEW Selection (CURRENT)', 'Separator','on', 'Callback', {@ib_moveLayers, NaN,'model','selection','2D','replace'});
uimenu(handles.modelSel_cm, 'Label', 'ADD to Selection (CURRENT)', 'Callback', {@ib_moveLayers, NaN, 'model','selection','2D','add'});
uimenu(handles.modelSel_cm, 'Label', 'REMOVE Material from Selection (CURRENT)', 'Callback', {@ib_moveLayers, NaN,'model','selection','2D','remove'});
uimenu(handles.modelSel_cm, 'Label', 'NEW Selection (ALL)','Separator','on', 'Callback', {@ib_moveLayers, NaN,'model','selection','3D','replace'});
uimenu(handles.modelSel_cm, 'Label', 'ADD to Selection (ALL)', 'Callback', {@ib_moveLayers, NaN,'model','selection','3D','add'});
uimenu(handles.modelSel_cm, 'Label', 'REMOVE Material from Selection (ALL)', 'Callback', {@ib_moveLayers, NaN,'model','selection','3D','remove'});
uimenu(handles.modelSel_cm, 'Label', 'Sync all lists', 'Callback', {@syncModelLists_Callback, 'selectfrom'}, 'Separator','on');
set(handles.segmSelList,'uicontextmenu',handles.modelSel_cm);

% adding context menu for Color channels table
handles.channelMixerTable_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.channelMixerTable_cm, 'Label', 'Insert empty channel', 'Callback', {@ib_channelMixerTable_Callback, NaN, 'insert'});
uimenu(handles.channelMixerTable_cm, 'Label', 'Copy channel', 'Callback', {@ib_channelMixerTable_Callback, NaN, 'copy'});
uimenu(handles.channelMixerTable_cm, 'Label', 'Invert channel', 'Callback', {@ib_channelMixerTable_Callback, NaN, 'invert'});
uimenu(handles.channelMixerTable_cm, 'Label', 'Rotate channel', 'Callback', {@ib_channelMixerTable_Callback, NaN, 'rotate'});
uimenu(handles.channelMixerTable_cm, 'Label', 'Swap channels', 'Callback', {@ib_channelMixerTable_Callback, NaN, 'swap'});
uimenu(handles.channelMixerTable_cm, 'Label', 'Delete channel', 'Callback', {@ib_channelMixerTable_Callback, NaN, 'delete'});
uimenu(handles.channelMixerTable_cm, 'Label', 'Set LUT color', 'Callback', {@ib_channelMixerTable_Callback, NaN, 'set color'}, 'Separator','on');
set(handles.channelMixerTable,'uicontextmenu',handles.channelMixerTable_cm);

% adding context menu for Add to list
handles.modelAdd_cm = uicontextmenu('Parent',handles.im_browser);
uimenu(handles.modelAdd_cm, 'Label', 'Get statistics...', 'Callback', {@menuMaskStats_Callback, handles});
uimenu(handles.modelAdd_cm, 'Label', 'Sync all lists', 'Callback', {@syncModelLists_Callback, 'addto'},'Separator','on');
set(handles.segmAddList,'uicontextmenu',handles.modelAdd_cm);

% set callback for the mode selection in the Mask Generator panel
set(handles.maskGenPanelModeRadioPanel,'SelectionChangeFcn',@maskGenPanelModeRadioPanel_Callback);

set(0,'CurrentFigure',handles.im_browser);
update_drives(handles,start_path,1);  % get available disk drives
update_filelist(handles);

handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
handles = updateGuiWidgets(handles);
handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
%guidata(handles.im_browser, handles);

%handles.changelayerSliderListener = addlistener(handles.changelayerSlider,'Value','PostSet', @(s,e) changelayerSlider_Callback(handles.changelayerSlider, [], handles));
set(handles.im_browser,'Visible','on');
% remove focus from the menu
uicontrol(handles.updatefilelistBtn);    

if exist('frame','var')     % put again to the top
    frame.show;
    frame.toFront();
end
pause(0.1);

% add double click callbacks for the sliders of the widgets,
% see more http://undocumentedmatlab.com/blog/setting-listbox-mouse-actions
try
    jFilesListbox = findjobj(handles.filesListbox); % jScrollPane
    jFilesListbox = jFilesListbox.getVerticalScrollBar;
    jFilesListbox = handle(jFilesListbox, 'CallbackProperties');
    set(jFilesListbox, 'MousePressedCallback',{@scrollbarClick_Callback, handles.filesListbox, 1});
catch err
end

if exist('frame','var')     % close splash window
    frame.hide;
    clear frame;
end

% UIWAIT makes im_browser wait for user response (see UIRESUME)
%uiwait(handles.im_browser);
end

% --- Outputs from this function are returned to the command line.
function varargout = im_browser_OutputFcn(~, ~, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
end

function drivePopup_Callback(hObject, eventdata, handles)
% change the logical drive
drives = get(handles.drivePopup,'String');
if ischar(class(drives(1))); drives = cellstr(drives); end;
value = get(handles.drivePopup,'Value');
handles.mypath = cell2mat(drives(value));
set(handles.pathEdit,'String',drives(value));
update_filelist(handles);
end

function pathEdit_Callback(hObject, eventdata, handles)
% manual directory selection
%switchShortcutsOn(hObject, eventdata, handles);
path = get(handles.pathEdit,'String');
if isdir(path)
    handles.mypath = path;
    set(handles.pathEdit,'String',path);
    update_filelist(handles);
    drives = get(handles.drivePopup,'String');
    if ischar(class(drives(1))); drives = cellstr(drives); end;
    if ispc()
        for i = 1:numel(drives)
            if strcmpi(cell2mat(drives(i)),path(1:2))
                set(handles.drivePopup,'Value',i);
                return;
            end
        end
    end
else
    set(handles.pathEdit,'String',handles.mypath);
end
guidata(handles.im_browser, handles);
end

function folderselectBtn_Callback(~, ~, handles)
% directory selection via GUI tool
dirname = uigetdir(get(handles.pathEdit, 'String'),'Choose Directory');
if ischar(dirname)
    handles.mypath = dirname;
    set(handles.pathEdit,'String',dirname);
    update_filelist(handles);
    drives = get(handles.drivePopup,'String');
    if ischar(class(drives(1))); drives = cellstr(drives); end;
    
    if ispc()
        for i = 1:numel(drives)
            if strcmpi(cell2mat(drives(i)),dirname(1:2))
                set(handles.drivePopup,'Value',i);
                return;
            end
        end
    end
end
guidata(handles.im_browser, handles);
end


function updatefilelistBtn_Callback(~, ~, handles)
% manually update the list of file in the current directory
update_filelist(handles);
guidata(handles.im_browser, handles);
end

function im_filterPopup_Callback(~, ~, handles)
% Filter the files with a new selected extension
update_filelist(handles);
end

function segmShowTypePopup_Callback(~, ~, handles)
% Toggle model shape: filled/countour
if strcmp(handles.Img{handles.Id}.I.model_type,'uint8') || strcmp(handles.Img{handles.Id}.I.model_type,'uint6')
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
end

function segmSelList_Callback(hObject, ~, handles)
% remembers the last selected object
val = get(handles.segmSelList,'Value');
if val == 1;
    set(handles.segmSelectedOnlyCheck, 'value', 0);
    segmSelectedOnlyCheck_Callback(handles.segmSelectedOnlyCheck, NaN, handles);
end
if val ~= 2
    handles.lastSegmSelection = get(handles.segmSelList,'Value');
    guidata(handles.im_browser, handles);
end;
unFocus(hObject);   % remove focus from hObject
end


% can't take to a separate file due to imageRedraw function
function addMaterialBtn_Callback(hObject, eventdata, handles)
% Add a new object to a model
unFocus(hObject); % remove focus from hObject

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes');
    warndlg(sprintf('The models are switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The models are disabled');
    return;
end;

list = cellstr(get(handles.segmList,'String'));
if isempty(list{1}); list = cell(0); end;    % remove empty entry from the list
number = numel(list);
answer = mib_inputdlg(handles, sprintf('Please add a new name for this material:'),'Rename material', num2str(number+1));
if ~isempty(answer)
    list(end+1,1) = cellstr(answer(1));
else
    return;
end
    
if ~handles.Img{handles.Id}.I.modelExist
    createModelBtn_Callback(handles.createModelBtn,eventdata, handles); % make an empty model
end

handles.Img{handles.Id}.I.modelMaterialNames = list;

updateSegmentationLists(handles);

handles.Img{handles.Id}.I.generateModelColors();
% if get(handles.modelShowCheck,'Value') % if model is shown, update the segmList as well
%     set(handles.segmList,'String',[cellstr('all'); list(2:end)]);
% end
set(handles.segmAddList, 'value', numel(list)+2);
imageRedraw(hObject, NaN, handles);
guidata(handles.im_browser, handles);
end


function magicwandConnectCheck_Callback(~, ~, handles)
% --- Executes on button press in magicwandConnectCheck.
set(handles.magicwandConnectCheck4,'Value',0);
end

% --- Executes on selection change in filterTypePopup.
function filterTypePopup_Callback(~, ~, handles)
pos = get(handles.filterTypePopup,'Value');
fulllist = get(handles.filterTypePopup,'String');
text_str = fulllist{pos};
set(handles.maskGeneratorsPanel,'Visible','off');
set(handles.corrPanel,'Visible','off');
set(handles.fijiPanel,'Visible','off');
set(handles.backgroundPanel,'Visible','off');
set(handles.imageFiltersPanel,'Visible','off');

switch text_str
    case 'Image Filters'
        set(handles.imageFiltersPanel,'Visible','on');
    case 'Mask generators'
        set(handles.maskGeneratorsPanel,'Visible','on');
    case 'Correlation analysis'
        set(handles.corrPanel,'Visible','on');
    case 'Fiji connect'  % connect to Fiji
        set(handles.fijiPanel,'Visible','on');
    case 'Background removal'  % background removal
        set(handles.backgroundPanel,'Visible','on');
end
end

function mainPanPopup_Callback(~, ~, handles)
% update panels after mainPanPopup change
pos = get(handles.mainPanPopup,'Value');
switch pos
    case 1  % Segmentation
        set(handles.segmentationPanel,'Visible','on');
        set(handles.roiPanel,'Visible','off');
    case 2  % ROI
        set(handles.segmentationPanel,'Visible','off');
        set(handles.roiPanel,'Visible','on');
end
end

function brightnessBtn_Callback(~, ~, handles)
% Auto brightness Rment
handles = ib_autoBrightness(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

function roiList_Callback(~, eventdata, handles)
% show selected ROI
set(handles.roiShowCheck,'Value',1);
roiShowCheck_Callback(handles.roiShowCheck, eventdata, handles);
end

function bioformatsCheck_Callback(~, ~, handles)
% Bioformats that can be read with loci toolbox
val = get(handles.bioformatsCheck,'Value');
position = handles.im_filterLast;
handles.im_filterLast = get(handles.im_filterPopup,'Value');
if val == 1     % use bioformats reader
    extentions = {'mov','pic','ics','ids','lei','stk','nd','nd2','sld','pict'...
        ,'lsm','mdb','psd','img','hdr','svs','dv','r3d','dcm','dicom','fits','liff'...
        ,'jp2','lif','l2d','mnc','mrc','oib','oif','pgm','zvi','gel','ims','dm3','naf'...
        ,'seq','xdce','ipl','mrw','mng','nrrd','ome','am','amiramesh','labels','fli'...
        ,'arf','al3d','sdt','czi','c01','flex','ipw','raw','ipm','xv','lim','nef','apl','mtb'...
        ,'tnb','obsep','cxd','vws','xys','xml','dm4','tif'};
    extentions = ['all known',sort(extentions)];
    set(handles.im_filterPopup,'String',extentions);
    set(handles.im_filterPopup,'Value',position);
else
    image_formats = imformats;  % get readable image formats
    if handles.matlabVersion < 8.0
        video_formats = mmreader.getFileFormats(); %#ok<DMMR> % get readable image formats
    else
        video_formats = VideoReader.getFileFormats(); % get readable image formats
    end
    extentions = ['all known' sort([image_formats.ext 'mrc' 'rec' 'am' 'nrrd' 'h5' 'xml' 'st' 'preali' {video_formats.Extension}])];
    set(handles.im_filterPopup,'String',extentions);
    set(handles.im_filterPopup,'Value',position);
end
update_filelist(handles);
guidata(handles.im_browser, handles);
end


function AdaptiveDilateCheck_Callback(~, ~, handles)
% Enable/disable adaptive coefficient edit box
if get(handles.AdaptiveDilateCheck,'Value') == 1
    set(handles.dilateAdaptCoefEdit,'Enable','on');
    set(handles.adaptiveSmoothCheck,'Enable','on');
else
    set(handles.dilateAdaptCoefEdit,'Enable','off');
    set(handles.adaptiveSmoothCheck,'Enable','off');
end
end


function changelayerSliderContext_cb(hObject, ~, parameter)
handles = guidata(hObject);
switch parameter
    case 'def'  % set brightness on the screen to be the same as in the image
        handles.sliderStep = 1;     % parameters for slider movement
        handles.sliderShiftStep = 10;
    case 'set'
        prompt = {'Enter step for use with arrows or Q/W buttons:','Enter step for use with Shift+arrows or Shift+Q/W buttons:'};
        def = {num2str(handles.sliderStep),num2str(handles.sliderShiftStep)};
        answer = inputdlg(prompt,'Set step...',1,def);
        if isempty(answer); return; end;
        handles.sliderStep = round(str2double(cell2mat(answer(1))));     % parameters for slider movement
        handles.sliderShiftStep = round(str2double(cell2mat(answer(2))));
end
guidata(handles.im_browser, handles);
end

function changeThresholdValueContext_cb(hObject, ~, parameter)
handles = guidata(hObject);
switch parameter
    case 'def'  % set brightness on the screen to be the same as in the image
        set(handles.segmLowSlider, 'SliderStep', [0.01 0.1]);
        set(handles.segmHighSlider, 'SliderStep', [0.01 0.1]);
    case 'set'
        sliderStep = get(handles.segmLowSlider, 'SliderStep');
        prompt = {'Enter step the step for the slider:'};
        maxVal = double(intmax(class(handles.Img{handles.Id}.I.img)));
        defaultAnswer = {num2str(round(sliderStep(1)*maxVal))};
        %answer = inputdlg(prompt,'Set step...',1,defaultAnswer);
        answer = mib_inputdlg(handles, prompt, 'Set step...', defaultAnswer);
        if isempty(answer); return; end;
        if str2double(answer{1})/maxVal > 1 || str2double(answer{1}) <= 0
            errordlg(sprintf('The step should be between 1 and %d!', maxVal),'Wrong step!');
            return;
        end
        set(handles.segmLowSlider, 'SliderStep', [str2double(answer{1})/maxVal str2double(answer{1})/maxVal*10]);
        set(handles.segmHighSlider, 'SliderStep', [str2double(answer{1})/maxVal str2double(answer{1})/maxVal*10]);
end
end

function magicwandConnectCheck4_Callback(~, ~, handles)
% --- Executes on button press in magicwandConnectCheck4.
set(handles.magicwandConnectCheck,'Value',0);
end


function contrastBtn_Callback(~, ~, handles)
% Contrast button callback
handles = ib_linearContrast(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

function backgroundProfileChk_Callback(~, ~, handles)
% defines whether to show a profile after background removal for a certatin row
if get(handles.backgroundProfileChk,'Value')
    set(handles.backgroundProfileLineEdit,'Enable','on');
    val = str2double(get(handles.backgroundProfileLineEdit,'String'));
    if val > size(handles.Img{handles.Id}.I.img,1)
        val = size(handles.Img{handles.Id}.I.img,1)/2;
        set(handles.backgroundProfileLineEdit,'String',num2str(val));
    end;
else
    set(handles.backgroundProfileLineEdit,'Enable','off');
end
end

% --- Executes on button press in backgroundRemoveBtn.
function backgroundRemoveBtn_Callback(~, ~, handles)
if handles.Img{handles.Id}.I.orientation ~= 4;
    msgbox('Please rotate the dataset to the XY orientation!','Error!','error','modal');
    return;
end
handles = ib_removeBackground(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end

function bwFilterGridCheck_Callback(hObject, ~, handles)
% black and white filter grid check callback
val = get(hObject, 'value');
set(handles.bwConversionCoefTxt,'Visible','off');
set(handles.bwConversionCoefEdit,'Visible','off');
if strcmp(get(hObject,'tag'),'bwFilterGridCheck') && val == 1
    set(handles.bwConversionCoefTxt,'Visible','on');
    set(handles.bwConversionCoefEdit,'Visible','on');
    set(handles.bwFilterThrasMinEdit,'String', '0');
    set(handles.bwFilterThrasMaxEdit,'String', '0');
    set(handles.bwFilterManGridCheck,'Value',0);
elseif strcmp(get(hObject,'tag'),'bwFilterManGridCheck') && val == 1
    set(handles.bwFilterGridCheck,'Value',0);
end
if val == 1
    %answer = inputdlg('Input square grid size, px','Grid settings',1,cellstr(num2str(handles.corrGridrunSize)));
    answer = mib_inputdlg(handles, 'Input square grid size, px', 'Grid settings', num2str(handles.corrGridrunSize));
    if isempty(answer)
        set(handles.corrGridrunCheck,'Value',0);
        return;
    end
    handles.corrGridrunSize = str2double(cell2mat(answer));
end
guidata(handles.im_browser, handles);
end

function menuSelectionSizeFilter(~, ~, handles, type)
% - Run size exclusion filter -
% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes');
    warndlg(sprintf('The selection layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The selection layer is disabled','modal');
    return;
end;
handles = ib_sizeExclusionFilter(handles, type);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

function syncModelLists_Callback(hObject, ~, type)
% sync all the list in the segmentation panel
% type: 'material', 'selectfrom', 'addto'
handles = guidata(hObject);
if isempty(handles.Img{handles.Id}.I.modelMaterialNames); return; end;
switch type
    case 'material'
        val = get(handles.segmList, 'value');
    case 'selectfrom'
        val = get(handles.segmSelList, 'value');
        if val < 2; return; end;
        val = val - 2;
    case 'addto'
        val = get(handles.segmAddList, 'value');
        if val < 2; return; end;
        val = val - 2;
end
set(handles.segmList, 'value', val);
set(handles.segmSelList, 'value', val+2);
set(handles.segmAddList, 'value', val+2);
end

function imAdjustBtn_Callback(~, ~, handles)
% Open image adjustments dialog
if strcmp(handles.Img{handles.Id}.I.img_info('ColorType'),'indexed')
    msgbox(sprintf('Please convert to grayscale or truecolor data format first!\nMenu->Image->Mode->'),'Change format!','error','modal');
    return;
end
imAdjustments(handles);
guidata(handles.im_browser, handles);
end

% --- Executes on button press in backgroundLocNormSw.
function backgroundLocNormSw_Callback(hObject, eventdata, handles)
if get(handles.backgroundLocNormSw,'Value')
    
else
    set(handles.backgroundStrelSmoothingChk,'Value',1);
    backgroundStrelSmoothingChk_Callback(handles.backgroundStrelSmoothingChk, NaN, handles);
end
end


function anDiffDoBtn_Callback(~, ~, handles)
% Filter image with coherence filter, anisotropic diffusion
handles = ib_anisotropicDiffusion(handles, 'coherence_filter');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end


function handles = anDiffOptionsBtn_Callback(~, ~, handles)
% Update Paramters for Coherence filter, anisotropic diffusion
anDiffOptionsDlg('options', NaN);
end

function anDiffTestrunBtn_Callback(~, ~, handles)
% Do a test run of image filtering with coherence filter, anisotropic diffusion
handles = ib_anisotropicDiffusion(handles, 'coherence_filter_test');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

function corrModeCombo_Callback(~, ~, handles)
% --- Executes on selection change in corrModeCombo.
contents = cellstr(get(handles.corrModeCombo,'String'));
selmode = contents{get(handles.corrModeCombo,'Value')};
if strcmp(selmode,'Absolute')
    set(handles.corrAbsvsEdit,'Enable','on');
    set(handles.vsText,'Enable','on');
else
    set(handles.corrAbsvsEdit,'Enable','off');
    set(handles.vsText,'Enable','off');
end;
end

function corrManualRadio_Callback(hObject, ~, handles)
% --- Executes on button press in corrManualRadio.
val = get(handles.corrManualRadio,'Value');
if val == 1
    set(handles.corrManualThresEdit,'Enable','on');
else
    set(handles.corrManualThresEdit,'Enable','off');
end
if get(hObject,'Value') == 0
    set(hObject,'Value',1);
end
end


function corrCalculateButton_Callback(~, ~, handles)
% Calculate correlation coefficients between
handles = ib_calcCorrelation(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end


% --- Executes on button press in corrGridCheck.
function corrGridCheck_Callback(~, ~, handles)
val = get(handles.corrGridCheck,'Value');
if val == 1
    %answer = inputdlg('Input square grid size, px','Grid settings',1,cellstr(num2str(handles.corrGridrunSize)));
    answer = mib_inputdlg(handles, 'Input square grid size, px', 'Grid settings', num2str(handles.corrGridrunSize));
    if isempty(answer)
        set(handles.corrGridrunCheck,'Value',0);
        return;
    end
    handles.corrGridrunSize = str2double(cell2mat(answer));
end
guidata(handles.im_browser, handles);
end


function corrTypeCombo_Callback(~, ~, handles)
% --- Executes on selection change in corrTypeCombo.
selected = get(handles.corrTypeCombo,'Value');
list_of_options = get(handles.corrTypeCombo,'String');
if strcmp(list_of_options{selected}, 'Image Displacement')
    set(handles.corrMaskRadio,'Enable','off');
    set(handles.corrAutoRadio,'Enable','off');
    set(handles.corrManualRadio,'Value',1);
    set(handles.corrManualThresEdit,'Enable','on');
else
    set(handles.corrMaskRadio,'Enable','on');
    set(handles.corrAutoRadio,'Enable','on');
end
end

function corrAbsvsEdit_Callback(~, eventdata, handles)
% --- Executes on selection change in corrAbsvsEdit_Callback.
status = editbox_Callback(handles.corrAbsvsEdit,eventdata,handles,'pint','1',[1 handles.Img{handles.Id}.I.no_stacks]);
if status == 0
    return;
end;
end

function handles = getMaskStats(handles)
% calculate statistics of objects in the Mask/Model layers
wb = waitbar(0, 'Calculating statistics, please wait...','WindowStyle','modal');
getDataOptions.blockModeSwitch = 0;
if get(handles.segmMaskClickModelCheck, 'value')
    type = 'model';
    colchannel = get(handles.segmSelList,'Value') - 2;
    if colchannel < 0;  % do not continue when All is selected
        msgbox(sprintf('Please select Material in the ''Select from list'' and press the ''Recalc.'' button in the Segmentation panel, Object Picker tool again!'),'Warning!','warn');
        delete(wb);
        return;
    end
else
    type = 'mask';
    colchannel = 0;
end
if get(handles.magicwandConnectCheck4,'Value')
    connectionType = 6; % 6-neighbour points
else
    connectionType = 26; % 26-neighbour points
end
handles.Img{handles.Id}.I.maskStat = bwconncomp(handles.Img{handles.Id}.I.getData3D(type, NaN, 4, colchannel, getDataOptions), connectionType); 
handles.Img{handles.Id}.I.maskStat.L = labelmatrix(handles.Img{handles.Id}.I.maskStat);     % create a label matrix for fast search of the indices
handles.Img{handles.Id}.I.maskStat.bb = regionprops(handles.Img{handles.Id}.I.maskStat, 'BoundingBox');     % create a label matrix for fast search of the indices
handles.Img{handles.Id}.I.maskStat = rmfield(handles.Img{handles.Id}.I.maskStat, 'PixelIdxList');   % remove PixelIdxList it is not needed anymore
guidata(handles.im_browser, handles);
delete(wb);
end


function maskRecalcStatsBtn_Callback(~, ~, handles)
% recalculate Mask statistics for right mouse selection
tic
getMaskStats(handles);
toc
end

function maskGenTypePopup_Callback(~, ~, handles)
% --- Executes on selection change in maskGenTypePopup.
pos = get(handles.maskGenTypePopup,'Value');
fulllist = get(handles.maskGenTypePopup,'String');
text_str = fulllist{pos};
set(handles.frangiPanel,'Visible','off');
set(handles.strelPanel,'Visible','off');
set(handles.bwFilterPanel,'Visible','off');
set(handles.morphPanel,'Visible','off');
set(handles.maskGenPanel3DAllRadio, 'enable', 'on');
switch text_str
    case 'Frangi filter'
        set(handles.maskGeneratorsPanel,'Title','Mask generators (Frangi filter)');
        set(handles.frangiPanel,'Visible','on');
    case 'Strel filter'
        set(handles.maskGeneratorsPanel,'Title','Mask generators (Strel filter)');
        set(handles.strelPanel,'Visible','on');
    case 'BW thresholding'
        set(handles.maskGeneratorsPanel,'Title','Mask generators (BW threshold filter)');
        set(handles.bwFilterPanel,'Visible','on');
        set(handles.maskGenPanel3DAllRadio, 'enable', 'off');
        set(handles.maskGenPanel2DCurrentRadio, 'value', 1);
    case 'Morphological filters'
        set(handles.maskGeneratorsPanel,'Title','Mask generators (Morphological filters)');
        set(handles.morphPanel,'Visible','on');
end
end


function maskGenBtn_Callback(hObject, ~, ~, type)
% Automatic generation of the Mask layer
handles = guidata(hObject);
handles = ib_maskGenerator(handles, type);
handles.Img{handles.Id}.I.maskExist = 1;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
listing = get(handles.seltypePopup,'String');
if strcmp(listing(get(handles.seltypePopup,'Value')),'Mask');
    getMaskStats(handles);    % get shapes statistics
end;

end

function logBtn_Callback(~, ~, handles)
% Show Log list window
logList(handles);
guidata(handles.im_browser, handles);
end

% --- Executes on button press in adaptiveSmoothCheck.
function adaptiveSmoothCheck_Callback(hObject, eventdata, handles)
if get(handles.adaptiveSmoothCheck, 'Value')
    %answer = inputdlg('Enter the smoothing factor value, (>2)','Smoothing factor',1,{num2str(handles.adaptiveSmoothingFactor)});
    answer = mib_inputdlg(handles, 'Enter the smoothing factor value, (>2)', 'Smoothing factor', num2str(handles.adaptiveSmoothingFactor));
    if isempty(answer); return; end;
    handles.adaptiveSmoothingFactor = str2double(answer{1});
    guidata(handles.im_browser, handles);
end
end

% --- Executes when entered data in editable cell(s) in channelMixerTable.
function channelMixerTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to channelMixerTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.channelMixerTable,'Data');

selected = find(cell2mat(data(:,2))==1)';
if isempty(selected);
    data{eventdata.Indices(1), 2} = eventdata.PreviousData;
    set(handles.channelMixerTable,'Data', data);
    return;
end;
if strcmp(get(handles.im_browser,'currentModifier'), 'control') % toggle between two color channels using the Ctrl modifier
    for i=1:size(data,1);        data{i,2} = 0;    end;    % clear selected channels
    data{eventdata.Indices(1,1),2} = 1;
    set(handles.channelMixerTable,'data', data);
end
handles.Img{handles.Id}.I.slices{3} = find(cell2mat(data(:,2))==1)';
if numel(handles.Img{handles.Id}.I.slices{3}) == 1
    set(handles.ColChannelCombo, 'value', handles.Img{handles.Id}.I.slices{3}+1);    % update color channel combo box in the Selection panel
end
redrawChannelMixerTable(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

% --- Executes on button press in segmTrackStraightChk.
function segmTrackStraightChk_Callback(hObject, eventdata, handles)
val = get(handles.segmTrackStraightChk, 'Value');
if val == 1
    set(handles.segmTracScaleEdit, 'Enable', 'off');
    set(handles.segmTrackBlackChk, 'Enable', 'off');
else
    set(handles.segmTracScaleEdit, 'Enable', 'on');
    set(handles.segmTrackBlackChk, 'Enable', 'on');
end
end

% --- Executes during object deletion, before destroying properties.
function im_browser_DeleteFcn(hObject, eventdata, handles)
global running;
running = 0;
end

% --- Executes on button press in lastSliceBtn.
function lastSliceBtn_Callback(hObject, eventdata, handles)
if handles.Img{handles.Id}.I.orientation == 4   % xy
    maxZ = handles.Img{handles.Id}.I.no_stacks;
elseif handles.Img{handles.Id}.I.orientation == 1   % xz
    maxZ = handles.Img{handles.Id}.I.height;
elseif handles.Img{handles.Id}.I.orientation == 2   % yz
    maxZ = handles.Img{handles.Id}.I.width;
end
set(handles.changelayerEdit, 'String', num2str(maxZ));
changelayerEdit_Callback(0, eventdata, handles);
end

% --- Executes on button press in firstSliceBtn.
function firstSliceBtn_Callback(hObject, eventdata, handles)
set(handles.changelayerEdit, 'String', num2str(1));
changelayerEdit_Callback(0, eventdata, handles);
end

% --- Executes on button press in firstTimeBtn.
function firstTimeBtn_Callback(hObject, eventdata, handles)
switch get(hObject, 'tag')
    case 'firstTimeBtn'
        set(handles.changeTimeEdit, 'String', num2str(1));
    case 'lastTimeBtn'
        set(handles.changeTimeEdit, 'String', num2str(handles.Img{handles.Id}.I.time));
end
changeTimeEdit_Callback(0, eventdata, handles);
end

% has to be in the main function, otherwise starts a new instance of
% im_browser after each update of the edit box
function status = editbox_Callback(hObject, eventdata, handles, chtype, default_val, variation)
% check for entrance in the edit box and switch the focus to handles.updatefilelistBtn
% chtype:
%     'int' -> positive and negative integers
%     'pint' -> positive integers
%     'float' -> positive and negative floats
%     'pfloat' -> positive floats and zero
%     'intrange' -> range of integers without zero
%     'posintx2'   -> two integers separated with comma

if nargin < 6
    variation = [-intmax('int32') intmax('int32')];   % variation of the entered value
end
if nargin < 5
    default_val = '1';  % default value to enter
end
if isnan(variation(1))
    variation(1) = - intmax('int32');
end
if isnan(variation(2))
    variation(2) = intmax('int32');
end

status = 1;
txt = get(hObject,'String');
err_str = '';
switch chtype
    case 'int'
        template = '[-0-9]';
        err_str = 'This value should be a positive/negative integer but not a zero';
    case 'pint'
        template = '[0-9]';
        err_str = 'This value should be a positive integer';
    case 'float'
        template = '[0-9.-]';
        err_str = 'This value should be a float number';
    case 'pfloat'
        template = '[0-9.]';
        err_str = 'This value should be a positive float number';
    case 'intrange'
        template = '[-0-9]';
        err_str = 'This value should be a positive integer range ex: 1-6';
    case 'posintx2'
        template = '[0-9;]';
        err_str = 'This value should be one or two positive integers separated with a semicolon';
        
end
if ~strcmp(err_str,'')
    num = regexp(txt,template);
    if length(num) ~= length(txt)
        msgbox(err_str,'Error!','error','modal');
        set(hObject,'String',default_val);
        status = 0;
    end
end
if isempty(txt)
    msgbox('Please enter a value!','Error!','error','modal');
    set(hObject,'String',default_val);
    status = 0;
end
if ~isnan(variation) & status == 1
    entered_val = str2double(txt);
    if entered_val < variation(1) || entered_val > variation(2)
        str2 = ['The value should be in range:' num2str(variation(1)) '-' num2str(variation(2))];
        msgbox(str2,'Error!','error','modal');
        set(hObject,'String',default_val);
        status = 0;
    end
end

if status == 0
    set(hObject,'Selected','on');
    set(hObject,'BackgroundColor',[1 0 0]);
else
    set(hObject,'Selected','off');
    set(hObject,'BackgroundColor',[1 1 1]);
    unFocus(hObject);   % remove focus from hObject
end
end

function maskedAreaCheck_Callback(hObject, eventdata, handles)
% --- Executes on button press in maskedAreaCheck.
unFocus(hObject);
if handles.Img{handles.Id}.I.maskExist == 0
    set(handles.maskedAreaCheck, 'value', 0);
    set(hObject, 'backgroundcolor', [0.8310    0.8160    0.7840]);
    return;
end

val = get(hObject,'Value'); % returns toggle state of maskedAreaCheck
if val
    set(hObject, 'backgroundcolor', [1 .6 .784]);
else
    set(hObject, 'backgroundcolor', [0.8310    0.8160    0.7840]);
end
end

% --- Executes on selection change in segmList.
function segmList_Callback(hObject, eventdata, handles)
unFocus(hObject);   % remove focus from hObject
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

% --- Executes on selection change in segmAddList.
function segmAddList_Callback(hObject, eventdata, handles)
unFocus(hObject);   % remove focus from hObject
end

% select stored dataset
function bufferToggle_Callback(hObject, eventdata, handles)
oldId = handles.Id; % get index of the previously selected buffer
tag = get(hObject,'tag');
buttonID = str2double(tag(end));
handles.Id = buttonID;
set(hObject, 'value', 1);

%handles.Img{handles.Id}.I.imh = 0;
handles.Img{handles.Id}.I.imh = matlab.graphics.primitive.Image('CData',[], 'UserData', 'new');

handles.U.clearContents();  % clear undo history

% turn off volume rendering
set(handles.volrenToolbarSwitch, 'state', 'off');

if ~isempty(fileparts(handles.Img{handles.Id}.I.img_info('Filename')))
    handles.mypath = fileparts(handles.Img{handles.Id}.I.img_info('Filename'));
end
set(handles.pathEdit, 'String', handles.mypath);        % update the current path
pathEdit_Callback(NaN, NaN, handles);
bgColor = get(hObject, 'BackgroundColor');   % get bg color of the target buffer
if bgColor(2) == 1
    [~, name, ext] = fileparts(handles.Img{handles.Id}.I.img_info('Filename'));
else
    [~, name, ext] = fileparts(handles.Img{oldId}.I.img_info('Filename'));
end

update_filelist(handles, [name ext]);     % update list of files, use filename to highlight the saved file
handles = updateGuiWidgets(handles);
handles = guidata(handles.im_browser);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

% --- Executes on button press in actions3dCheck.
function actions3dCheck_Callback(hObject, eventdata, handles)
if get(handles.actions3dCheck,'value')
    set(handles.maskRecalcStatsBtn,'enable','on');
else
    set(handles.maskRecalcStatsBtn,'enable','off');
end
end

% --- Executes on button press in importFijiBtn.
function importFijiBtn_Callback(hObject, eventdata, handles)
% import dataset from Fiji
ib_importFromFiji(handles);
end


% --- Executes on button press in exportFijiBtn.
function exportFijiBtn_Callback(hObject, eventdata, handles)
% export dataset to Fiji
ib_exportToFiji(handles);
end

% --- Executes on button press in fijirunmacroBtn.
function fijirunmacroBtn_Callback(hObject, eventdata, handles)
% run Fiji macro
ib_runFijiMacro(handles);
end


% --- Executes on button press in fijiSelectFileBtn.
function fijiSelectFileBtn_Callback(hObject, eventdata, handles)
% Select a text file with list of macro functions for Fiji
[filename, path] = uigetfile(...
    {'*.txt;',  'Text file (*.txt)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select file...',handles.mypath);
if isequal(filename,0); return; end; % check for cancel
set(handles.fijimacroEdit, 'string', fullfile(path, filename));
end

% --- Executes on selection change in filterSelectionPopup.
function filterSelectionPopup_Callback(hObject, eventdata, handles)
list = get(handles.filterSelectionPopup, 'String');
item = list{get(handles.filterSelectionPopup, 'value')};
if strcmp(item, 'Brush')
    handles.showBrushCursor = 1;
    handles = ib_updateCursor(handles);
end
end

% --- Executes on button press in lutCheckbox.
function lutCheckbox_Callback(hObject, eventdata, handles)
val = get(handles.lutCheckbox, 'value');
if val==1 && strcmp(handles.Img{handles.Id}.I.img_info('ColorType'), 'indexed')
    errordlg(sprintf('LUTs are not implemented for the indexed images!\n\nPlease convert the image to the RGB color to use LUT:\nMenu->Image->Mode->RGB Color'),'Color type error!')
    set(handles.lutCheckbox, 'value', 0);
    return;
end
% update handles.channelMixerTable
redrawChannelMixerTable(handles);
% redraw image in the im_browser axes
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
unFocus(hObject);   % remove focus from hObject
end

% --- Executes on button press in fileinfoBtn.
function fileinfoBtn_Callback(hObject, eventdata, handles)
% Show the dataset info window
ib_datasetInfoGui(handles);
guidata(handles.im_browser, handles);
end


% --- Executes on button press in segmFavToolCheck.
function segmFavToolCheck_Callback(hObject, eventdata, handles)
toolId = get(handles.seltypePopup, 'value');
favId = get(handles.segmFavToolCheck, 'value');
if favId == 1 % add the selected tool to the list of fast access tools
    handles.preferences.lastSegmTool(end+1) = toolId;
    set(handles.seltypePopup,'backgroundcolor',[1 .69 .39]);
else    % remove the selected tool to the list of fast access tools
    pos = handles.preferences.lastSegmTool(find(handles.preferences.lastSegmTool == toolId,1));
    handles.preferences.lastSegmTool = handles.preferences.lastSegmTool(handles.preferences.lastSegmTool~=pos);
    set(handles.seltypePopup,'backgroundcolor',[1 1 1]);
end
handles.preferences.lastSegmTool = sort(handles.preferences.lastSegmTool);
guidata(handles.im_browser, handles);
end


function liveStretchCheck_Callback(hObject, eventdata, handles)
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

% --- Executes on button press in seeAllMaterialsCheck.
function seeAllMaterialsCheck_Callback(hObject, eventdata, handles)
segmList_Callback(handles.segmList, eventdata, handles);
end

function showAnnotationsCheck_Callback(hObject, eventdata, handles)
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

% --- Executes on button press in annMarkerCheck.
function annMarkerCheck_Callback(hObject, eventdata, handles)
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

% NOTE: this function can't be taken to a separate file!!!
function imageRedraw(hObject, eventdata, handles)
% function imageRedraw(hObject, ~, handles)
% redraw the shown image after change of transparency values for Model,
% Mask or Selection layers
%
% Parameters:
% hObject: a handle to the calling object
% eventdata: eventdata structure of Matlab
% handles: handles structure of im_browser.m

handles = guidata(hObject);     % get handles for listeners
handles.preferences.alphaSelection = get(handles.selectionTransparencySlider,'value');
handles.preferences.alphaMask = get(handles.maskTransSlider,'value');
handles.preferences.alphaModel = get(handles.modelTransSlider,'value');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

function menuModelAnnRemoveAll_Callback(hObject, eventdata, handles)
ib_do_backup(handles, 'labels', 0);
handles.Img{handles.Id}.I.hLabels.removeLabels();
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
windowId = findall(0,'tag','ib_labelsGui');
if ~isempty(windowId)
    hlabelsGui = guidata(windowId);
    cb = get(hlabelsGui.refreshBtn,'callback');
    feval(cb, hlabelsGui.refreshBtn, []);
end
end

function labelsBtn_Callback(hObject, eventdata, handles)
windowList = findall(0,'Type','figure');
winStarted = 0;
for i=1:numel(windowList) % re-initialize the window with keeping existing settings
    if strcmp(get(windowList(i),'tag'),'ib_labelsGui') % update imAdjustment window
        handles = ib_labelsGui(handles, windowList(i));
        winStarted = 1;
    end
end
if winStarted == 0  % re-initialize the window completely
    handles = ib_labelsGui(handles);
end

guidata(handles.im_browser, handles);
end

function maskGenPanelModeRadioPanel_Callback(hObject, eventdata)
handles = guidata(hObject);
% update settings for the filters
% Frangi
set(handles.frangiBeta3, 'enable', 'off');
set(handles.frangiBeta1, 'ToolTipString', 'Frangi correction constant, default 0.5');
set(handles.frangiBeta2, 'ToolTipString', 'Second Frangi correction constant, default 15');
set(handles.frangiBeta1, 'String', '0.9');
set(handles.frangiBeta2, 'String', '15');

switch get(eventdata.NewValue,'tag')
    case 'maskGenPanel2DCurrentRadio'
        set(handles.morphPanelConnectivityEdit, 'string', '4');
    case 'maskGenPanel2DAllRadio'
        set(handles.morphPanelConnectivityEdit, 'string', '4');
    case 'maskGenPanel3DAllRadio'
        % Frangi
        set(handles.frangiBeta3, 'enable', 'on');
        set(handles.frangiBeta1, 'ToolTipString', 'Frangi vesselness constant, 0 - a line (vessel) or 1 - a plane like structure, default 0.5');
        set(handles.frangiBeta2, 'ToolTipString', 'Frangi vesselness constant, which determines the deviation from a blob like structure, default .5;');
        set(handles.frangiBeta1, 'String', '0');
        set(handles.frangiBeta2, 'String', '1');
        set(handles.morphPanelConnectivityEdit, 'string', '6');
        
end
end

function segmWatershedSegmBtn_Callback(hObject, eventdata, handles)
modifier = get(handles.im_browser,'currentModifier');   % get key modifier
handles = ib_segmentation_SmartWatershed(modifier, handles);
end


% --- Executes on selection change in morphPanelTypeSelectPopup.
function morphPanelTypeSelectPopup_Callback(hObject, eventdata, handles)
popupList = get(handles.morphPanelTypeSelectPopup,'string');
switch popupList{get(handles.morphPanelTypeSelectPopup,'value')}
    case {'Extended-maxima transform','Extended-minima transform'}
        set(handles.morphPanelThresholdEdit, 'enable', 'on');
    case {'Regional maxima','Regional minima'}
        set(handles.morphPanelThresholdEdit, 'enable', 'off');
end
end

function eraserEdit_Callback(hObject, eventdata, handles)
val = str2double(get(handles.eraserEdit, 'string'));
handles.preferences.eraserRadiusFactor = val;
guidata(handles.im_browser, handles);
end

% --- Executes on button press in roiManualCheck.
function roiManualCheck_Callback(hObject, eventdata, handles)
if get(handles.roiManualCheck, 'value')
    set(handles.roiX1Edit,'enable','on');
    set(handles.roiY1Edit,'enable','on');
    set(handles.roiWidthEdit,'enable','on');
    set(handles.roiHeightEdit,'enable','on');
else
    set(handles.roiX1Edit,'enable','off');
    set(handles.roiY1Edit,'enable','off');
    set(handles.roiWidthEdit,'enable','off');
    set(handles.roiHeightEdit,'enable','off');
end
end

% --- Executes on button press in roiOptionsBtn.
function roiOptionsBtn_Callback(hObject, eventdata, handles)
handles.Img{handles.Id}.I.hROI.updateOptions();
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

%% ------------------------ MENU CALLBACKS --------------------------
% see corresonding functions for details

%% File Menu --------------------------------------------------------
% ---- Import image from... --------------------------------------------------------
function menuFileImportImage_Callback(hObject, eventdata, handles, parameter)
menuFileImportImage(hObject, eventdata, handles, parameter);
end
% ---- OMERO Import... --------------------------------------------------------
function menuFileOmeroImport_Callback(hObject, eventdata, handles)
menuFileOmeroImport(hObject, eventdata, handles);
end
% ------ Chopped images mode ------------------------------------------------------
function menuFileChoppedImage_Callback(hObject, eventdata, handles, parameter)
menuFileChoppedImage(hObject, eventdata, handles, parameter);
end

% ---- Export image to... --------------------------------------------------------
function menuFileExportImage_Callback(hObject, eventdata, handles, parameter)
menuFileExportImage(hObject, eventdata, handles, parameter);
end
% ---- Save image as... --------------------------------------------------------
function menuFileSaveImageAs_Callback(hObject, eventdata, handles)
menuFileSaveImageAs(hObject, eventdata, handles);
end
% ---- Make movie --------------------------------------------------------
function menuFileMakeMovie_Callback(hObject, eventdata, handles)
menuFileMakeMovie(hObject, eventdata, handles);
end
% ---- Make snapshot --------------------------------------------------------
function menuFileSnapshot_Callback(hObject, eventdata, handles)
menuFileSnapshot(hObject, eventdata, handles);
end
% ---- Render Volume (with Fiji) --------------------------------------------------------
function menuFileRenderFiji_Callback(hObject, eventdata, handles)
img = handles.Img{handles.Id}.I.getData3D('image', NaN, 4);
ib_renderVolumeWithFiji(img, handles.Img{handles.Id}.I.pixSize);
end
% ---- Preferences --------------------------------------------------------
function menuFilePreferences_Callback(hObject, eventdata, handles)
menuFilePreferences(hObject, eventdata, handles);
end

%% Dataset menu --------------------------------------------------------
% ---- Alignment tool --------------------------------------------------------
function menuDatasetAlignDatasets_Callback(hObject, eventdata, handles)
menuDatasetAlignDatasets(hObject, eventdata, handles);
end
% ---- Crop dataset --------------------------------------------------------
function menuDatasetCrop_Callback(hObject, eventdata, handles)
menuDatasetCrop(hObject, eventdata, handles);
end
% ---- Resample... --------------------------------------------------------
function menuDatasetResample_Callback(hObject, eventdata, handles)
if strcmp(get(handles.toolbarBlockModeSwitch,'State'),'on')
    warndlg(sprintf('Please switch off the Block-mode!\n\nUse the corresponding button in the toolbar'),'Block-mode is detected');
    return;
end
menuDatasetResample(hObject, eventdata, handles);
end
% ---- Transform... --------------------------------------------------------
function menuDatasetTrasform_Callback(hObject, eventdata, handles, parameter)
menuDatasetTransform(hObject, eventdata, handles, parameter);
end
% ---- Slice --------------------------------------------------------
function menuDatasetSlice_Callback(hObject, eventdata, handles, parameter)
menuDatasetSlice(hObject, eventdata, handles, parameter);
end
% ---- Scale bar --------------------------------------------------------
function menuDatasetScalebar_Callback(hObject, eventdata, handles)
    mib_calibrateScaleBar(handles);
end
% ---- Bounding Box --------------------------------------------------------
function menuDatasetBoundingBox_Callback(hObject, eventdata, handles)
menuDatasetBoundingBox(hObject, eventdata, handles);
end
% ---- Parameters --------------------------------------------------------
function menuDatasetParameters_Callback(hObject, eventdata, handles)
handles.Img{handles.Id}.I.updateParameters();
handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
end


%% Image Menu --------------------------------------------------------
% ---- Mode --------------------------------------------------------
function menuImageMode_Callback(hObject, eventdata, handles)
menuImageMode(hObject, eventdata, handles);
end
% ---- Color channels --------------------------------------------------------
function menuImageColorCh_Callback(hObject, eventdata, handles, parameter)
menuImageColorCh(hObject, eventdata, handles, parameter);
end
% ---- Contrast --------------------------------------------------------
function menuImageContrast_Callback(hObject, eventdata, handles, parameter)
menuImageContrast(hObject, eventdata, handles, parameter);
end
% ---- Invert --------------------------------------------------------
function menuImageInvert_Callback(hObject, eventdata, handles, par1)
handles = ib_invertImage(handles, NaN, par1);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
% ---- Morphological Operations --------------------------------------------------------
function menuImageMorphOps_Callback(~, ~, handles, type)
handles = guidata(handles.im_browser);
handles = ib_imageMorphOpsGui(handles, type);
if ~isstruct(handles); return; end;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
% ---- Intensity Profile --------------------------------------------------------
function menuImageIntensity_Callback(hObject, eventdata, handles, parameter)
menuImageIntensity(hObject, eventdata, handles, parameter);
end
% ---- Histogram --------------------------------------------------------
function menuImageHistogram_Callback(~, eventdata, handles)
mib_contrastContext_cb(handles.contrastBtn,eventdata,'showhist');
end

%% Models menu --------------------------------------------------------
% ---- New model --------------------------------------------------------
function menuModelsNew_Callback(hObject, eventdata, handles)
createModelBtn_Callback(hObject, eventdata, handles);
end
% ---- Load model --------------------------------------------------------
function menuModelsLoad_Callback(~, eventdata, handles)
loadModelBtn_Callback(handles.loadModelBtn, eventdata, handles);
end
% ---- Import --------------------------------------------------------
function menuModelsImport_Callback(hObject, eventdata, handles)
menuModelsImport(hObject, eventdata, handles);
end
% ---- Export --------------------------------------------------------
function menuModelsExport_Callback(hObject, eventdata, handles, parameter)
menuModelsExport(hObject, eventdata, handles, parameter);
end
% ---- Save model --------------------------------------------------------
function menuModelsSave_Callback(~, eventdata, handles)
saveModelToolbar_ClickedCallback(handles.menuModelsSave,eventdata,handles);
end
% ---- Save model as --------------------------------------------------------
function menuModelsSaveAs_Callback(hObject, eventdata, handles)
menuModelsSaveAs(hObject, eventdata, handles);
end
% ---- Render the model with Matlab --------------------------------------------------------
function menuModelsRender_Callback(hObject, eventdata, handles, type)
switch type
    case 'matlab'
        model_cm_Callback(hObject,eventdata,'isosurface');
    case 'fiji'
        model_cm_Callback(hObject,eventdata,'volumeFiji');
    case 'imaris'
        handles = ib_renderModelImaris(handles);
        guidata(handles.im_browser, handles);
end
end
% ---- Fill membrane --------------------------------------------------------
function menuModelFillMembrane_Callback(hObject, eventdata, handles)
menuModelFillMembrane(hObject, eventdata, handles)
end
% ---- Annotations --------------------------------------------------------
function menuModelAnn_Callback(hObject, eventdata, handles, parameter)
switch parameter
    case 'list'
        labelsBtn_Callback(hObject, eventdata, handles);
    case 'delete'
        menuModelAnnRemoveAll_Callback(hObject, eventdata, handles);
end
end
% ---- Model statistics --------------------------------------------------------
function menuModelsStatistics_Callback(hObject, eventdata, handles)
model_cm_Callback(hObject, eventdata, handles);
end

%% Mask menu --------------------------------------------------------
% ---- ...->Selection --------------------------------------------------------
function menuMask2Sel_Callback(hObject, eventdata, handles, p1, p2, p3, p4)
ib_moveLayers(hObject, eventdata, handles, p1, p2, p3, p4);
end
% ---- Clear Mask --------------------------------------------------------
function menuMaskClear_Callback(~, eventdata, handles)
ib_do_backup(handles, 'mask', 1);
handles.Img{handles.Id}.I.clearMask();
set(handles.maskShowCheck, 'value', 0);
maskedAreaCheck_Callback(handles.maskedAreaCheck, eventdata, handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
% ---- Load mask --------------------------------------------------------
function menuMaskLoad_Callback(hObject, eventdata, handles)
menuMaskLoad(hObject, eventdata, handles);
end
% ---- Import mask --------------------------------------------------------
function menuMaskImport_Callback(hObject, eventdata, handles)
menuMaskImport(hObject, eventdata, handles);
end
% ---- Export Mask --------------------------------------------------------
function menuMaskExport_Callback(~, ~, handles)
prompt = {'Variable for the mask image:'};
title = 'Input variables for export';
answer = mib_inputdlg(handles, prompt, title, 'M');
if size(answer) == 0; return; end;
options.blockModeSwitch = 0;
assignin('base',answer{1},handles.Img{handles.Id}.I.getData4D('mask', 4, NaN, options));
disp(['Mask export: created variable ' answer{1} ' in the Matlab workspace']);
end
% ---- Save Mask as --------------------------------------------------------
function menuMaskSaveAs_Callback(hObject, eventdata, handles)
menuMaskSaveAs(hObject, eventdata, handles);
end
% ---- Invert Mask --------------------------------------------------------
function menuMaskInvert_Callback(hObject, eventdata, handles)
menuMaskInvert(hObject, eventdata, handles);
end
% ---- Size exclusion filter --------------------------------------------------------
function menuMaskSizeFilter_Callback(hObject, eventdata, handles)
menuSelectionSizeFilter(hObject, eventdata, handles,'mask');
end
% ---- Replace dataset in the masked areas --------------------------------------------------------
function menuMaskImageReplace_Callback(~, ~, handles)
% will replace masked areas with the provided color intensity
handles = handles.Img{handles.Id}.I.replaceImageColor(handles, 'mask');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
% ---- Smooth mask --------------------------------------------------------
function menuMaskSmooth_Callback(hObject, eventdata, handles, parameter)
smoothImage_Callback(hObject, eventdata, handles, parameter);
end
% ---- Mask statistics --------------------------------------------------------
function menuMaskStats_Callback(hObject, ~, handles)
handles = guidata(handles.im_browser);
if handles.Img{handles.Id}.I.orientation ~= 4;
    msgbox('Please rotate the dataset to the XY orientation!','Error!','error','modal');
    return;
end
windowList = findall(0,'Type','figure');
winStarted = 0;
for i=1:numel(windowList) % re-initialize the window with keeping existing settings
    if strcmp(get(windowList(i),'tag'),'maskStatsDlg') % update imAdjustment window
        handles = MaskStatsDlg(handles, 'Mask', windowList(i));
        winStarted = 1;
    end
end
if winStarted == 0  % re-initialize the window completely
    handles = MaskStatsDlg(handles,'Mask');
end
guidata(handles.im_browser, handles);
end

%% Selection menu --------------------------------------------------------
% ---- Selection to buffer --------------------------------------------------------
function menuSelectionBuffer_Callback(hObject, eventdata, handles, parameter)
menuSelectionBuffer(hObject, eventdata, handles, parameter);
end
% ---- Selection to Mask --------------------------------------------------------
function menuSelection2Mask_Callback(hObject, eventdata, handles, p1, p2, p3, p4)
ib_moveLayers(hObject, eventdata, handles, p1, p2, p3, p4);
end
% ---- Morphological 2D/3D operations --------------------------------------------------------
function menuSelectionMorphOps_Callback(hObject,~,~, type)
% perform morphological operations on binary images using bwmorph function
handles = guidata(hObject);

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes');
    warndlg(sprintf('The selection layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The selection layer is disabled','modal');
    return;
end;
handles = ib_MorphOpsGui(handles, type);
if ~isstruct(handles); return; end;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
% ---- Expand to Mask border --------------------------------------------------------
function menuSelectionToMaskBorder_Callback(hObject, eventdata, handles)
menuSelectionToMaskBorder(hObject, eventdata, handles);
end
% ---- Interpolate --------------------------------------------------------
function menuSelectionInterpolate_Callback(hObject, eventdata, handles)
menuSelectionInterpolate(hObject, eventdata, handles);
end
% ---- Size exclusion filter --------------------------------------------------------
function menuSelectionSizeFilter_Callback(hObject, eventdata, handles)
menuSelectionSizeFilter(hObject, eventdata, handles,'selection');
end
% ---- Replace selected areas in the image --------------------------------------------------------
function menuSelectionImageReplace_Callback(~, ~, handles)
% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes');
    warndlg(sprintf('The selection layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The selection layer is disabled','modal');
    return;
end;

handles = handles.Img{handles.Id}.I.replaceImageColor(handles, 'selection');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
% ---- Invert selection --------------------------------------------------------
function menuSelectionInvert_Callback(hObject, eventdata, handles)
menuSelectionInvert(hObject, eventdata, handles);
end

%% Tools menu --------------------------------------------------------
% ---- Measure length --------------------------------------------------------
function menuToolsMeasure_Callback(hObject, eventdata, handles, parameter)
menuToolsMeasure(hObject, eventdata, handles, parameter);
end

% ---- Do stereology analysis --------------------------------------------------------
function menuToolsStereology_Callback(hObject, eventdata, handles)
res = mib_stereologyGui(handles);
end

% ---- Random Forest Classifier for membranes -----------------------------------
function menuToolsClassifiersMembrane_Callback(hObject, eventdata, handles)
ib_MembraneDetection(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

% ---- Random Forest Classifier for superpixels/voxels ---------------------------
function menuToolsClassifiersSuperpixels_Callback(hObject, eventdata, handles)
mib_Classifier(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

% ---- Watershed --------------------------------------------------------
function menuToolsWatershed_Callback(hObject, eventdata, handles)
if strcmp(get(handles.toolbarBlockModeSwitch,'State'),'on')
    warndlg(sprintf('Please switch off the Block-mode!\n\nUse the corresponding button in the toolbar'),'Block-mode is detected');
    return;
end
ib_watershedGui(handles);
guidata(handles.im_browser, handles);
end
%% Help menu  --------------------------------------------------------
% ---- Help  --------------------------------------------------------
function menuHelpHelp_Callback(hObject, eventdata, handles, page)
if isdeployed
    web(fullfile(handles.pathMIB, sprintf('techdoc/html/%s.html', page)), '-helpbrowser');
else
    if handles.matlabVersion < 8
        if strcmp(page, 'im_browser_product_page')
            docsearch '"Microscopy Image Browser"'
        elseif strcmp(page, 'im_browser_license')
            docsearch '"Microscopy Image Browser License"'
        end
    else
        web(fullfile(handles.pathMIB,'techdoc','html',[page '.html']));
    end
end
end
% --- Executes on button press in segmPanelHelpBtn.
function helpBtn_Callback(hObject, eventdata, handles, type)
if isdeployed
    switch type
        case 'backRem_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_bg_removal.html'), '-helpbrowser');
        case 'classref';            
            if isdir(fullfile(handles.pathMIB, 'techdoc', 'ClassReference'))
                web(fullfile(handles.pathMIB, 'techdoc/ClassReference/index.html'), '-helpbrowser');
            else
                web('http://mib.helsinki.fi/help/api/index.html', '-helpbrowser');
            end
        case 'coherence_filter';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_filters_coherence.html'), '-helpbrowser');
        case 'corr_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_corr.html'), '-helpbrowser');
        case 'dir_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_dir.html'), '-helpbrowser');
        case 'fiji_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_fiji_connect.html'), '-helpbrowser');
        case 'imfilt_panel';             web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_image_filters.html'), '-helpbrowser');
        case 'mask_gen';             web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_mask_generators.html'), '-helpbrowser');
        case 'model_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_model.html'), '-helpbrowser');
        case 'path_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_path.html'), '-helpbrowser');
        case 'roi_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_roi.html'), '-helpbrowser');
        case 'segm_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_segm.html'), '-helpbrowser');
        case 'segmAn_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_segm_analysis.html'), '-helpbrowser');
        case 'sel_panel';            web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_selection.html'), '-helpbrowser');
        case 'view_settings_panel';             web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_view_settings.html'), '-helpbrowser');
    end
else
    switch type
        case 'backRem_panel';   web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_bg_removal.html'), '-helpbrowser'); %docsearch '"Background Removal Panel"';
        case 'classref';
            if isdir(fullfile(handles.pathMIB, 'techdoc', 'ClassReference'))
                web(fullfile(handles.pathMIB, 'techdoc/ClassReference/index.html'), '-helpbrowser');
            else
                web('http://mib.helsinki.fi/help/api/index.html', '-helpbrowser');
            end
        case 'coherence_filter';    web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_filters_coherence.html'), '-helpbrowser');
        case 'corr_panel';      web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_corr.html'), '-helpbrowser');
        case 'dir_panel';       web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_dir.html'), '-helpbrowser');
        case 'fiji_panel';       web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_fiji_connect.html'), '-helpbrowser');
        case 'imfilt_panel';     web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_image_filters.html'), '-helpbrowser');
        case 'mask_gen';        web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_mask_generators.html'), '-helpbrowser');
        case 'model_panel';     web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_model.html'), '-helpbrowser');
        case 'path_panel';      web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_path.html'), '-helpbrowser');
        case 'roi_panel';       web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_roi.html'), '-helpbrowser');
        case 'segm_panel';      web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_segm.html'), '-helpbrowser');
        case 'segmAn_panel';    web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_segm_analysis.html'), '-helpbrowser');
        case 'sel_panel';       web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_selection.html'), '-helpbrowser');
        case 'view_settings_panel';   web(fullfile(handles.pathMIB, 'techdoc/html/ug_panel_view_settings.html'), '-helpbrowser');
    end
end
end
% ---- Check for update --------------------------------------------------------
function menuHelpUpdate_Callback(hObject, eventdata, handles)
result = ib_checkUpdate(handles);
if result == 1  % update available
    im_browser_CloseRequestFcn(hObject, eventdata, handles);    % close im_browser
end
end
% ---- About --------------------------------------------------------
function menuHelpAbout_Callback(~, ~, handles)
ib_aboutDlg(handles);
end
% ---- END OF MENU CALLBACKS SECTION ------------

%% ----------- TOOLBAR BUTTONS CALLBACKS -------------------------
% ------------ Zoom in, 1:1, fit to screen, zoom out ----------------------------------------
function zoomToolbar_ClickedCallback(hObject, eventdata, handles)
toolbar_zoomBtn(hObject, eventdata, handles);
end
% ------------ Undo ------------------------------------------------------
function toolbarUndo_ClickedCallback(hObject, eventdata, handles)
index = handles.U.undoIndex - 1;
if index == 0; return; end;
ib_do_undo(handles, index);
end
% ------------ Redo ------------------------------------------------------
function toolbarRedo_ClickedCallback(hObject, eventdata, handles)
index = handles.U.undoIndex + 1;
if index > numel(handles.U.undoList); return; end;
ib_do_undo(handles, index);
end
% ------------ Play dataset in movie player ----------------------------------
function toolbarMovie_ClickedCallback(~, ~, handles)
img = handles.Img{handles.Id}.I.getData3D('image', NaN, NaN);     % permute the dataset
implay(img, 4);
end
% ------------- Change viewing plane ----------------------------------------------
function toolbarPlaneToggle_ClickedCallback(hObject, eventdata, handles)
toolbarPlaneToggle(hObject, eventdata, handles);
end
% -------------- Type of interpolator to use ----------------------------------
function toolbarInterpolation_ClickedCallback(hObject, eventdata, handles)
toolbarInterpolation(hObject, eventdata, handles);
end

% -------------- Type of image interpolation for the visualization ----------------------------------
function toolbarResizingMethod_ClickedCallback(hObject, eventdata, handles)
toolbarResizingMethod(hObject, eventdata, handles);
end

% --------------- Block mode switch --------------------------
function toolbarBlockModeSwitch_ClickedCallback(hObject, eventdata, handles)
if strcmp(get(handles.toolbarBlockModeSwitch,'State'),'off')   % change slices
    handles.Img{handles.Id}.I.blockModeSwitch = 0;
else
    handles.Img{handles.Id}.I.blockModeSwitch = 1;
end
guidata(handles.im_browser, handles);
end
% ---------------- Show ROI  ----------------------------------
function toolbarShowROISwitch_ClickedCallback(hObject, eventdata, handles)
if strcmp(get(handles.toolbarShowROISwitch,'State'),'on')
    set(handles.roiShowCheck,'Value',1);
else
    set(handles.roiShowCheck,'Value',0);
end
roiShowCheck_Callback(handles.roiShowCheck, eventdata, handles);
end

function toolbarParProcBtn_ClickedCallback(~, ~, handles) %#ok<*DEFNU>
% ---------------- Turn on parallel processing ----------------
if handles.matlabVersion < 8.4
    cores = matlabpool('size'); %#ok<DPOOL>
    if cores == 0
        matlabpool(feature('numCores')); %#ok<DPOOL>
        set(handles.toolbarParProcBtn, 'selected', 'on');
    else
        matlabpool close; %#ok<DPOOL>
        set(handles.toolbarParProcBtn, 'selected', 'off');
        %disp(['Already connected to ' num2str(cores) ' cores!']);
        %disp('To terminate the existing session, use: "matlabpool close"');
    end
else
    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(poolobj)
        parpool(feature('numCores'));
        set(handles.toolbarParProcBtn, 'State', 'on');
    else
        poolobj.delete();
        set(handles.toolbarParProcBtn, 'State', 'off');
    end
end
end
% ----------------- Swap mouse buttons ----------------------------
function toolbarSwapMouse_ClickedCallback(hObject, eventdata, handles)
if strcmp(get(hObject,'State'), 'on')
    handles.preferences.mouseButton = 'select';
else
    handles.preferences.mouseButton = 'pan';
end
guidata(handles.im_browser, handles);
end
% ------------------ Swap mouse wheel actions -------------------------------
function mouseWheelToolbarSw_ClickedCallback(hObject, eventdata, handles)
if strcmp(get(hObject,'State'), 'on')
    handles.preferences.mouseWheel = 'scroll';
else
    handles.preferences.mouseWheel = 'zoom';
end
guidata(handles.im_browser, handles);
end


function segmBW_Update(hObject, eventdata, handles)
% function segmBW_Update(hObject, ~, handles)
% interactive black/white thresholding with BW Threshold segmentation tool
%
% Parameters:
% hObject: a handle to the calling object
% eventdata: eventdata structure of Matlab
% handles: handles structure of im_browser.m

% 21.05.2014, Ilya Belevich, ilya.belevich @ helsinki.fi
% NOTE! Keep inside im_browser.m

handles = guidata(hObject);
if strcmp(get(hObject, 'tag'), 'segmBWthres4D')
    if get(hObject, 'value') == 1
        button = questdlg(sprintf('!!! Warning !!!\n\nYou are going to do black-and-white thresholding over complete dataset\nThis may take a lot of time, are you sure?'),'Warning','Continue','Cancel','Cancel');
        if strcmp(button, 'Cancel'); set(hObject, 'value', 0); return; end;
    end
end
% uncheck the 3D box
if strcmp(get(hObject, 'tag'), 'segmBWthres3D') && get(handles.segmBWthres4D, 'value') == 1 && get(hObject, 'value') == 1
    set(handles.segmBWthres4D, 'value', 0);
end

handles = ib_segmentBlackWhiteThreshold(handles, hObject);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
unFocus(hObject);   % remove focus from hObject
end

function brushSuperpixelsCheck_Callback(hObject, eventdata, handles)
brushSuperpixelsCheck(hObject, eventdata, handles);
end

function devTest_ClickedCallback(hObject, eventdata, handles)
% mib_Classifier(handles);

%guidata(handles.im_browser, handles);

% % click point test: use mouse to select a point, and check conversion
% [xData,yData,zData, xClick, yClick] = getClickPoint(handles,[]);
% permuteSw = 1;
% %xClick = 456.5;
% %yClick = 553.7;
% [xData,yData,zData] = handles.Img{handles.Id}.I.convertMouseToDataCoordinates(xClick, yClick, 'full',permuteSw);
% sprintf('xData=%f,yData=%f,zData=%f, xClick=%f, yClick=%f', xData,yData,zData, xClick, yClick)
% %[xOut,yOut] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(xData,yData, 'shown');
% [xOut,yOut] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(xData,yData, 'shown');
% sprintf('x=%.3f, y=%.3f', xOut,yOut)

% if exist('MIJ','class') == 8
%     if ~isempty(ij.gui.Toolbar.getInstance)
%         ij_instance = char(ij.gui.Toolbar.getInstance.toString);
%         % -> ij.gui.Toolbar[canvas1,3,41,548x27,invalid]
%         if numel(strfind(ij_instance, 'invalid')) > 0    % instance already exist, but not shown
%             ij.ImageJ([], 1);     % show imageJ
%         end
%     else
%         MIJ.start();     % wrapper to Miji.m file
%     end
% else
%    msgbox(sprintf('MIJ.jar was not found!!!\n\nPlease'),...
%         'Missing Miji!','error');
%     return;
% end
% I = handles.Img{handles.Id}.I.getSliceToShow('image');
% MIJ.createColor('test_uint8', I, 1);

% handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);

%pos = arrayfun(@(h) get(h,'position'), h, 'UniformOutput', false);  % get positions
%pos2 = cellfun(@(x) x*0.75, pos,'UniformOutput', false);            % scale positions

% hGui = handles.im_browser;
% scaleFactor = 0.75;
% list = {'uipanel','uicontrol','axes','uitable','uibuttongroup','uitab','uitabgroup','figure'};
%
% for j=1:numel(list)
%     h = findall(hGui, 'type', list{j});
%     for i=1:numel(h)
%         set(h(i),'position', get(h(i),'position')*scaleFactor);
%     end
% end
end
