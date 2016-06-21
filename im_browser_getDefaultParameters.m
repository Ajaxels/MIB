function [handles, start_path] = im_browser_getDefaultParameters(handles)
% function [handles, start_path] = im_browser_getDefaultParameters(handles)
% Set default and stored from the previous session parameters of im_browser.m
%
% This function runs during initialization of im_browser.m
%
% Parameters:
% handles: handle structure of im_browser
%
% Return values:
% handles: -> handle structure of im_browser
% start_path: -> starting logical drive
% @change{1,1,ib,2013-05-01} test of change function
% @new{1,1,ib,2013-05-01} test of new function
% title = 'Microscopy Image Browser';

% Copyright (C) 02.09.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');    % switch off warnings for latex
curInt = get(handles.im_browser, 'DefaulttextInterpreter');
set(handles.im_browser, 'DefaulttextInterpreter', 'none');

%% Restore preferences from the last time
os = getenv('OS');
if strcmp(os,'Windows_NT')
    handles.mypath='c:\';
    start_path = 'c:';
    fn = 'c:\temp\im_browser.mat';
    if exist(fn,'file') ~= 0
        load(fn);
        disp(['MIB: parameters file: ', fn]);
    else    % check the windows temp folder (C:\Users\User-name\AppData\Local\Temp\)
        fn = fullfile(tempdir, 'im_browser.mat');
        if exist(fn,'file') ~= 0
            load(fn);
            disp(['MIB: parameters file: ', fn]);
        end
    end
else
    handles.mypath='/';
    start_path = '/';
    
    if exist([fileparts(which('im_browser.m')) filesep 'im_browser.mat'],'file') ~= 0
        fn = [fileparts(which('im_browser.m')) filesep 'im_browser.mat'];
        load(fn);
        disp(['MIB: parameters file: ', fn]);
    else % try Linux temp folder (/tmp)
        fn = fullfile(tempdir, 'im_browser.mat');
        if exist(fn,'file') ~= 0
            load(fn);
            disp(['MIB: parameters file: ', fn]);
        end
    end
end

%% Omero check
if exist('loadOmero.m','file') == 2;         loadOmero_wrapper;     end;

% add Imaris and BioFormats java libraries to Java path;
if ~isdeployed
    javapath = javaclasspath('-all');
    
%     %% now adding Imaris lib
%     %% this code does not really work :( it works when started from IceImarisConnector
%     if ~isunix()    
%         imarisPath = getenv('IMARISPATH');
%         if ~isempty(imarisPath)
%             if ~exist(imarisPath, 'dir');
%                 fprintf('Warning: Imaris Path (%s) is wrong!\nPlease change the system environment variable IMARISPATH:\nStart->Computer->right mouse click->Properties->Advanced system settings->Environment Variables...->New....\n', imarisPath);
%             else
%                 if ispc()
%                     libPath = fullfile(imarisPath, 'XT', 'matlab', 'ImarisLib.jar');
%                 elseif ismac()
%                     libPath = fullfile(imarisPath, 'Contents', 'SharedSupport', ...
%                         'XT', 'matlab', 'ImarisLib.jar');
%                 end
%                 
%                 % Check whether the ImarisLib jar package exists
%                 if ~exist(libPath, 'file')
%                     fprintf('Warning: Could not find the ImarisLib jar file:\n%s', libPath);
%                 else
%                     % Add the ImarisLib.jar package to the java class path
%                     % (if not there yet)
%                     if all(cellfun(@isempty, strfind(javapath, 'ImarisLib.jar')))
%                         javaaddpath(libPath, '-end');
%                         disp(['MIB: adding "' libPath '" to Matlab java path']);
%                     end
%                 end
%             end
%         end
%     end
    
    % add bio-formats java libraries
    if all(cellfun(@isempty, strfind(javapath, 'bioformats_package.jar')))
        % if isempty(cell2mat(strfind(javapath, 'bioformats_package.jar'))); % this call is a bit slower
        lociPath = fullfile(fileparts(mfilename('fullpath')),'ImportExportTools','BioFormats','bioformats_package.jar');
        javaaddpath(lociPath, '-end');
        disp(['MIB: adding "' lociPath '" to Matlab java path']);
    end
    
%     if all(cellfun(@isempty, strfind(javapath, 'mij.jar')))
%         path = 'c:\MATLAB\Scripts\im_browser\ImportExportTools\Fiji\mij.jar';
%         javaaddpath(path, '-end');
%         disp(['MIB: adding "' path '" to Matlab java path']);
%     end
%     
%     if all(cellfun(@isempty, strfind(javapath, 'ij-1.49j.jar')))
%         path = 'c:\Tools\Science\Fiji.app\jars\ij-1.49j.jar';
%         javaaddpath(path, '-end');
%         disp(['MIB: adding "' path '" to Matlab java path']);
%     end
    
    % add Fiji Java libraries
%     fijiJavaPath = 0;
%     javaPathfn = fullfile(fileparts(mfilename('fullpath')), 'mib_java_path.txt');
%     if exist(javaPathfn,'file') ~= 2
%         msgbox(sprintf('A path-file for Java libraries was not found!\n\nPlease add "mib_java_path.txt" file with the list of JAR directories (for example: "C:\\Fiji\\jars") to the im_browser directory (%s)', javaPathfn),'Missing Fiji JARs','error');
%     else
%         fid = fopen(javaPathfn);
%         tline = fgetl(fid);
%         while ischar(tline)
%             if ~isempty(strfind(lower(tline), 'fiji'))
%                 fijiJavaPath = tline;
%             end
%             tline = fgetl(fid);
%         end
%         fclose(fid);
%         
%         if exist(fijiJavaPath,'dir') ~= 7    % not a folder
%             sprintf('Fiji path was not correct!\n\nPlease fix it (for example: "C:\\Fiji\\") in "mib_java_path.txt" file at the im_browser directory (%s)', javaPathfn);
%         else
%             add_to_classpath(javapath, fullfile(fijiJavaPath,'jars'));
%             add_to_classpath(javapath, fullfile(fijiJavaPath,'plugins'));
%         end
%     end
   
end

% set units of text to points
tempList = findall(handles.im_browser,'Style','text');
for i=1:numel(tempList)
    set(tempList(i),'FontUnits','points');
end

% set the global preferences
handles.preferences.mouseWheel = 'scroll';  % type of the mouse wheel action, 'scroll': change slices; 'zoom': zoom in/out
handles.preferences.mouseButton = 'select'; % swap the left and right mouse wheel actions, 'select': pick or draw with the left mouse button; 'pan': to move the image with the left mouse button
handles.preferences.undo = 'yes';   % enable undo
handles.preferences.resize = 'bicubic'; % image resizing method for zooming
handles.preferences.disableSelection = 'no';    % disable selection with the mouse
handles.preferences.maskcolor = [255 0 255]/255;    % color for the mask layer
handles.preferences.selectioncolor = [0 255 0]/255; % color for the selection layer
handles.preferences.modelMaterialColors = [166 67 33;       % default colors for the materials of models
    71 178 126;
    79 107 171;
    150 169 213;
    26 51 111;
    255 204 102 ]/255;
handles.preferences.alphaSelection = .75;       % transparency of the selection layer
handles.preferences.alphaMask = .75;            % transparency of the mask layer
handles.preferences.alphaModel = .75;           % transparency of the model layer
handles.preferences.maxUndoHistory = 8;         % number of steps for the Undo history
handles.preferences.max3dUndoHistory = 3;       % number of steps for the Undo history for whole dataset
handles.preferences.uint8 = 0;                  % type of the model: uint6 with 63 maximal number of materials
handles.preferences.fontSizeDir = get(handles.filesListbox, 'fontsize');        % font size for files and directories
handles.preferences.lastSegmTool = [3, 4];  % fast access to the selection type tools with the 'd' shortcut
handles.preferences.annotationColor = [1 1 0];  % color for annotations
handles.preferences.annotationFontSize = 2;     % font size for annotations
handles.preferences.interpolationType = 'shape';    % type of the interpolator to use
handles.preferences.interpolationNoPoints = 200;     % number of points to use for the interpolation
handles.preferences.interpolationLineWidth = 4;      % line width for the 'line' interpotator
handles.preferences.lutColors = [       % add colors for color channels
    1 0 0     % red
    0 1 0     % green
    0 0 1     % blue
    1 0 1     % purple
    1 1 0     % yellow
    1 .65 0]; % orange
handles.preferences.eraserRadiusFactor = 1.4;   % magnifying factor for the eraser
% define font structure
handles.preferences.Font.FontName = get(handles.text6,'FontName');
handles.preferences.Font.FontUnits = get(handles.text6,'Units');
handles.preferences.Font.FontSize = get(handles.text6,'FontSize');

% define keyboard shortcuts
maxShortCutIndex = 27;  % total number of shortcuts
handles.preferences.KeyShortcuts.shift(1:maxShortCutIndex) = 0;
handles.preferences.KeyShortcuts.control(1:maxShortCutIndex) = 0;
handles.preferences.KeyShortcuts.alt(1:maxShortCutIndex) = 0;

handles.preferences.KeyShortcuts.Key{1} = '1';
handles.preferences.KeyShortcuts.Action{1} = 'Switch dataset to XY orientation';
handles.preferences.KeyShortcuts.alt(1) = 1;

handles.preferences.KeyShortcuts.Key{2} = '2';
handles.preferences.KeyShortcuts.Action{2} = 'Switch dataset to ZY orientation';
handles.preferences.KeyShortcuts.alt(2) = 1;

handles.preferences.KeyShortcuts.Key{3} = '3';
handles.preferences.KeyShortcuts.Action{3} = 'Switch dataset to ZX orientation';
handles.preferences.KeyShortcuts.alt(3) = 1;

handles.preferences.KeyShortcuts.Key{4} = 'i';
handles.preferences.KeyShortcuts.Action{4} = 'Interpolate selection';

handles.preferences.KeyShortcuts.Key{5} = 'i';
handles.preferences.KeyShortcuts.Action{5} = 'Invert image';
handles.preferences.KeyShortcuts.control(5) = 1;

handles.preferences.KeyShortcuts.Key{6} = 'a';
handles.preferences.KeyShortcuts.Action{6} = 'Add to selection to material';

handles.preferences.KeyShortcuts.Key{7} = 's';
handles.preferences.KeyShortcuts.Action{7} = 'Subtract from material';

handles.preferences.KeyShortcuts.Key{8} = 'r';
handles.preferences.KeyShortcuts.Action{8} = 'Replace material with current selection';

handles.preferences.KeyShortcuts.Key{9} = 'c';
handles.preferences.KeyShortcuts.Action{9} = 'Clear selection';

handles.preferences.KeyShortcuts.Key{10} = 'f';
handles.preferences.KeyShortcuts.Action{10} = 'Fill the holes in the Selection layer';

handles.preferences.KeyShortcuts.Key{11} = 'z';
handles.preferences.KeyShortcuts.Action{11} = 'Erode the Selection layer';

handles.preferences.KeyShortcuts.Key{12} = 'x';
handles.preferences.KeyShortcuts.Action{12} = 'Dilate the Selection layer';

handles.preferences.KeyShortcuts.Key{13} = 'q';
handles.preferences.KeyShortcuts.Action{13} = 'Zoom out/Previous slice';

handles.preferences.KeyShortcuts.Key{14} = 'w';
handles.preferences.KeyShortcuts.Action{14} = 'Zoom in/Next slice';

handles.preferences.KeyShortcuts.Key{15} = 'downarrow';
handles.preferences.KeyShortcuts.Action{15} = 'Previous slice';

handles.preferences.KeyShortcuts.Key{16} = 'uparrow';
handles.preferences.KeyShortcuts.Action{16} = 'Next slice';

handles.preferences.KeyShortcuts.Key{17} = 'space';
handles.preferences.KeyShortcuts.Action{17} = 'Show/hide the Model layer';

handles.preferences.KeyShortcuts.Key{18} = 'space';
handles.preferences.KeyShortcuts.Action{18} = 'Show/hide the Mask layer';
handles.preferences.KeyShortcuts.control(18) = 1;

handles.preferences.KeyShortcuts.Key{19} = 'space';
handles.preferences.KeyShortcuts.Action{19} = 'Fix selection to material';
handles.preferences.KeyShortcuts.shift(19) = 1;

handles.preferences.KeyShortcuts.Key{20} = 's';
handles.preferences.KeyShortcuts.Action{20} = 'Save image as...';
handles.preferences.KeyShortcuts.control(20) = 1;

handles.preferences.KeyShortcuts.Key{21} = 'c';
handles.preferences.KeyShortcuts.Action{21} = 'Copy to buffer selection from the current slice';
handles.preferences.KeyShortcuts.control(21) = 1;

handles.preferences.KeyShortcuts.Key{22} = 'v';
handles.preferences.KeyShortcuts.Action{22} = 'Paste buffered selection to the current slice';
handles.preferences.KeyShortcuts.control(22) = 1;

handles.preferences.KeyShortcuts.Key{23} = 'e';
handles.preferences.KeyShortcuts.Action{23} = 'Toggle between the selected material and exterior';

handles.preferences.KeyShortcuts.Key{24} = 'd';
handles.preferences.KeyShortcuts.Action{24} = 'Loop through the list of favourite segmentation tools';

handles.preferences.KeyShortcuts.Key{25} = 'leftarrow';
handles.preferences.KeyShortcuts.Action{25} = 'Previous time point';
handles.preferences.KeyShortcuts.alt(25) = 1;

handles.preferences.KeyShortcuts.Key{26} = 'rightarrow';
handles.preferences.KeyShortcuts.Action{26} = 'Next time point';
handles.preferences.KeyShortcuts.shift(26) = 1;

handles.preferences.KeyShortcuts.Key{maxShortCutIndex} = 'z';
handles.preferences.KeyShortcuts.Action{maxShortCutIndex} = 'Undo/Redo last action';
handles.preferences.KeyShortcuts.control(maxShortCutIndex) = 1;

% update preferences
if exist('im_browser_pars','var') && isfield(im_browser_pars,'preferences')
    realFields = fieldnames(handles.preferences);
    loadedFields = fieldnames(im_browser_pars.preferences);
    % check difference between loaded and needed preferences
    if numel(setdiff(loadedFields, realFields)) + numel(setdiff(realFields, loadedFields)) == 0
        % check the font name
        fontList = listfonts();    % get available fonts
        if all(cellfun(@isempty, strfind(fontList, im_browser_pars.preferences.Font.FontName)))   % font does not exist
            fontName = handles.preferences.Font.FontName;
        else        % font exist exist
            fontName = im_browser_pars.preferences.Font.FontName;
        end
        handles.preferences = im_browser_pars.preferences;
        handles.preferences.Font.FontName = fontName;
    end
end

set(handles.eraserEdit, 'string', num2str(handles.preferences.eraserRadiusFactor));

% set a variable to deal with the increase of the brush size during the
% erasing action. Ctrl+left mouse button
% handles.ctrlPressed:
% handles.ctrlPressed == 0; - indicates the normal brush mode, i.e. when the control button is not pressed
% handles.ctrlPressed > 0; - the control button is pressed and handles.ctrlPressed indicates increase of the brush radius
% handles.ctrlPressed == -1; - a tweak to deal with Ctrl+Mouse wheel action to change size of the brush. -1 indicates that the brush size change mode was triggered
% see in functions:
%    im_browser_WindowKeyPressFcn, im_browser_WindowKeyReleaseFcn, im_browser_scrollWheelFcn
handles.ctrlPressed = 0;

% add extra parameters
toolbarInterpolation(handles.toolbarInterpolation, '', handles, 'keepcurrent');     % update the interpolation button icon
toolbarResizingMethod(handles.toolbarResizingMethod, '', handles, 'keepcurrent');     % update the image interpolation button icon

if ~isempty(find(handles.preferences.lastSegmTool == 3,1))  % set background for the brush when it is fast access tool
    set(handles.segmFavToolCheck, 'value',1);
    set(handles.seltypePopup,'backgroundcolor',[1 .69 .39]);
end

%% restore last used directory
if exist('im_browser_pars','var') && isfield(im_browser_pars,'lastpath')
    if exist(im_browser_pars.lastpath,'dir')
        handles.mypath = im_browser_pars.lastpath;
        if numel(handles.mypath) > 1
            start_path = im_browser_pars.lastpath(1:2);
        else
            start_path = im_browser_pars.lastpath(1);
        end
    end
end

% set variable for the brush cursor
handles.cursor = [];            % a handle to the plot type, that has the shape of the brush cursor
handles.showBrushCursor = 1;    % a switch that defines whether the brush cursor has to be shown

% default value for autoupdate of histogram in the imAdjustment window
handles.SwitchAutoHistUpdate = 0;

% default parameters for CLAHE
handles.CLAHE.NumTiles = [8 8];
handles.CLAHE.ClipLimit = 0.01;
handles.CLAHE.NBins = 256;
handles.CLAHE.Distribution = 'uniform';
handles.CLAHE.Alpha = 0.4;

% update transparency sliders
set(handles.selectionTransparencySlider,'value', handles.preferences.alphaSelection)
set(handles.maskTransSlider,'value', handles.preferences.alphaMask);
set(handles.modelTransSlider,'value', handles.preferences.alphaModel);

handles.lastSegmSelection = 1; % switch for last selected contour, for fast switch with 'e' button
handles.corrGridrunSize = 30;   % default size of the grid for correlation calculation

handles.sliderStep = 1;     % parameters for slider movement
handles.sliderShiftStep = 10;

handles.im_filterLast = 1;  % last selected file extention for use when swap bio/standard file reader

% defauld parameter for adaptive dilation smoothing
handles.adaptiveSmoothingFactor = 4;

% filling filters
image_formats = imformats;  % get readable image formats

if handles.matlabVersion < 8.0
    video_formats = mmreader.getFileFormats(); %#ok<DMMR> % get readable image formats
else
    video_formats = VideoReader.getFileFormats(); % get readable image formats
end
extentions = ['all known' sort([image_formats.ext 'am' 'mrc' 'rec' 'nrrd' 'xml' 'h5' 'preali' 'st' {video_formats.Extension}])];
set(handles.im_filterPopup,'String',extentions);
set(handles.pathEdit,'String',handles.mypath);


% adding buffers as empty structures
for buffer = 1:6
    handles.buffers{buffer}.I = NaN;
end

%% Placing panels
set(handles.roiPanel,'parent',get(handles.segmentationPanel,'parent'));
set(handles.strelPanel,'parent',get(handles.frangiPanel,'parent'));
set(handles.bwFilterPanel,'parent',get(handles.frangiPanel,'parent'));
set(handles.morphPanel,'parent',get(handles.frangiPanel,'parent'));
set(handles.corrPanel,'parent',get(handles.imageFiltersPanel,'parent'));
set(handles.fijiPanel,'parent',get(handles.imageFiltersPanel,'parent'));
set(handles.backgroundPanel,'parent',get(handles.imageFiltersPanel,'parent'));
set(handles.maskGeneratorsPanel,'parent',get(handles.imageFiltersPanel,'parent'));

set(handles.bgRemoveSubPanel2, 'parent',get(handles.bgRemoveSubPanel1, 'parent'));
set(handles.bgRemoveSubPanel2, 'Position',get(handles.bgRemoveSubPanel1, 'Position'));

frangiPos = get(handles.frangiPanel,'Position');
imageFiltersPos = get(handles.imageFiltersPanel,'Position');

set(handles.strelPanel,'Position',frangiPos);
set(handles.bwFilterPanel,'Position',frangiPos);
set(handles.morphPanel,'Position',frangiPos);
set(handles.corrPanel,'Position',imageFiltersPos);
set(handles.fijiPanel,'Position',imageFiltersPos);
set(handles.backgroundPanel,'Position',imageFiltersPos);
set(handles.maskGeneratorsPanel,'Position',imageFiltersPos);

% segmentation tools panels
pos = get(handles.segmSpotPanel,'Position');
set(handles.segmMaskPanel,'Parent',handles.segmToolsPanel);
set(handles.segmMaskPanel,'Position',pos);
set(handles.segmAnnPanel,'Parent',handles.segmToolsPanel);
set(handles.segmAnnPanel,'Position',pos);
set(handles.segmMagicPanel,'Parent',handles.segmToolsPanel);
set(handles.segmMagicPanel,'Position',pos);
set(handles.segmThresPanel,'Parent',handles.segmToolsPanel);
set(handles.segmThresPanel,'Position',pos);
set(handles.segmMembTracerPanel,'Parent',handles.segmToolsPanel);
set(handles.segmMembTracerPanel,'Position',pos);
set(handles.segmWatershedPanel,'Parent',handles.segmToolsPanel);
set(handles.segmWatershedPanel,'Position',pos);

% updating positions of childs of pathSubPanel to normalized
childrenPans = get(handles.pathSubPanel, 'children');
for i=1:numel(childrenPans)
    set(childrenPans(i), 'units', 'normalized');
end
%% add plugins to the menu
func_dir = fullfile(handles.pathMIB, 'Plugins');

addpath(func_dir);
customContents1 = dir(func_dir);
if numel(customContents1) > 2
    for customDirIdx = 3:numel(customContents1)
        if customContents1(customDirIdx).isdir
            hSubmenu = uimenu(handles.menuPlugins,'Label', customContents1(customDirIdx).name);
            custom_dir = fullfile(func_dir, customContents1(customDirIdx).name);
            customContents2 = dir(custom_dir);
            
            if numel(customContents2) > 2
                for customDirIdx2 = 3:numel(customContents2)
                    if customContents2(customDirIdx2).isdir
                        custom_dir2 = fullfile(custom_dir, customContents2(customDirIdx2).name);
                        if ~isdeployed
                            addpath(custom_dir2);
                        end
                        uimenu(hSubmenu,'Label', customContents2(customDirIdx2).name,'Callback', {customContents2(customDirIdx2).name, handles.im_browser});
                    end
                end
            end
            %uimenu(handles.menuPlugins,'Label', customContents(customDirIdx).name,'Callback', {@customContents(customDirIdx).name, handles.im_browser});
        end
    end
end

%% set background for last and first slice buttons of the image view panel
bg = get(handles.lastSliceBtn, 'background');
btn1 = ones([6 5 3]);
btn2 = ones([6 5 3]);
for color=1:3
    btn1(:,:,color) = btn1(:,:,color).*bg(color);
    btn2(:,:,color) = btn2(:,:,color).*bg(color);
end
btn1(6,1,:) = [0 0 0]; btn1(3,1,:) = [0 0 0];
btn1(5,2,:) = [0 0 0]; btn1(2,2,:) = [0 0 0];
btn1(4,3,:) = [0 0 0]; btn1(1,3,:) = [0 0 0];
btn1(5,4,:) = [0 0 0]; btn1(2,4,:) = [0 0 0];
btn1(6,5,:) = [0 0 0]; btn1(3,5,:) = [0 0 0];

btn2(1,1,:) = [0 0 0]; btn2(4,1,:) = [0 0 0];
btn2(2,2,:) = [0 0 0]; btn2(5,2,:) = [0 0 0];
btn2(3,3,:) = [0 0 0]; btn2(6,3,:) = [0 0 0];
btn2(2,4,:) = [0 0 0]; btn2(5,4,:) = [0 0 0];
btn2(1,5,:) = [0 0 0]; btn2(4,5,:) = [0 0 0];

set(handles.lastSliceBtn,'cdata',btn1);
set(handles.firstSliceBtn,'cdata',btn2);

%% Add icons to menu
pause(.1);
ib_addIcons(handles);
% Disable items in the menu that are not available in the deployed version
if isdeployed
    set(handles.menuFileImportImageMatlab, 'enable', 'off');
    set(handles.menuFileExportImageMatlab, 'enable', 'off');
    set(handles.menuModelsImport, 'enable', 'off');
    set(handles.menuModelsExport, 'enable', 'off');
    set(handles.menuMaskImport, 'enable', 'off');
    set(handles.menuMaskExport, 'enable', 'off');
    set(handles.menuFileImportImageImaris, 'enable', 'off');
    set(handles.menuFileExportImageImaris, 'enable', 'off');
    set(handles.menuModelsRenderImaris, 'enable', 'off');
end
%% set background color to panels and texts
tempList = findall(handles.im_browser,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.im_browser,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.im_browser,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.im_browser,'Style','radiobutton');    % set color to radiobuttons
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.im_browser,'Type','uibuttongroup');    % set color to uibuttongroup
set(tempList,'BackgroundColor',[.831 .816 .784]);

defaultFontSize = get(handles.text6, 'fontsize');
defaultFontName = get(handles.text6, 'fontname');

if defaultFontSize ~= handles.preferences.Font.FontSize || ...
        ~strcmp(defaultFontName, handles.preferences.Font.FontName)
    ib_updateFontSize(handles.im_browser, handles.preferences.Font);
end

% %% set font size for all widgets
% tempList = findall(0);
% for i=1:numel(tempList)
%     props = get(tempList(i));
%     if isfield(props, 'FontSize')
%         if strcmp(props.Type, 'uipanel'); continue; end;    % do not change font size for the panels
%         set(tempList(i), 'FontSize', 10);
%     end
% end

% Setting the font sizes
set(handles.filesListbox, 'fontsize', handles.preferences.fontSizeDir);

%% Diplib check
if ~isdeployed
    if exist('dipinit','file') == 2
        dip_initialise();
    elseif exist('dipstart','file') == 2
        dipstart;
    else
        filterList = {'Gaussian','Gaussian 3D','Perona Malik anisotropic diffusion','Average',...
            'Disk','Gradient 2D', 'Gradient 3D','Frangi 2D','Frangi 3D','Laplacian','Log','Motion','Unsharp','Median 2D','Wiener 2D','Edge Enhancing Coherence Filter'};
        set(handles.imageFilterPopup,'String',filterList);
        disp('DipLib library was not found');
    end
end

set(0, 'DefaulttextInterpreter', curInt);
end

function add_to_classpath(classpath, directory)
% Get all .jar files in the directory
test = dir(strcat([directory filesep '*.jar']));
path_= cell(0);
for i = 1:length(test)
    if not_yet_in_classpath(classpath, test(i).name)
        path_{length(path_) + 1} = strcat([directory filesep test(i).name]);
    end
end

% Add them to the classpath
if ~isempty(path_)
    try
        javaaddpath(path_, '-end');
    catch err
        sprintf('%s', err.identifier);
    end
end
end

function test = not_yet_in_classpath(classpath, filename)
% Test whether the library was already imported
%expression = strcat([filesep filename '$']);
%test = isempty(cell2mat(regexp(classpath, expression)));
expression = strcat([filesep filename]);
test = isempty(cell2mat(strfind(classpath, expression)));
end