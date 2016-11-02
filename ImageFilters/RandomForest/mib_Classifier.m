function varargout = mib_Classifier(varargin)
% function varargout = mib_Classifier(varargin)
% mib_Classifier function uses random forest classifier for segmentation.
% The function utilize Random Forest for Membrane Detection functions by Verena Kaynig
% see more http://www.kaynig.de/demos.html
%
% mib_Classifier contains MATLAB code for mib_Classifier.fig

% Copyright (C) 18.09.2015 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mib_Classifier_OpeningFcn, ...
                   'gui_OutputFcn',  @mib_Classifier_OutputFcn, ...
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

% --- Executes just before mib_Classifier is made visible.
function mib_Classifier_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_Classifier (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser
% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.mib_Classifier, handles.h.preferences.Font);
end

% % switch off the block mode
if strcmp(get(handles.h.toolbarBlockModeSwitch,'state'),'on')
    warndlg(sprintf('!!! Warning !!!\n\nThe block mode will be disabled!'),'Switch off the block mode');
    set(handles.h.toolbarBlockModeSwitch,'state','off');
end

% superpixelTypeRadio radio button callbacks
set(handles.superpixelTypeRadio, 'SelectionChangeFcn', {@superpixelTypeRadio_Callback, handles});

% Choose default command line output for mib_Classifier
handles.output = hObject;

% set panels
set(handles.trainClassifierPanel, 'parent', get(handles.preprocessPanel, 'parent'));
set(handles.trainClassifierPanel, 'position', get(handles.preprocessPanel, 'position'));
pos = get(handles.mib_Classifier,'position');
pos(3) = 420;
pos(4) = 315;
set(handles.mib_Classifier,'position', pos);

% set types of available classifiers
matVer = ver;
classList{1} = 'Random Forest';
if ~isempty(strfind([matVer.Name], 'Statistics Toolbox')) || ~isempty(strfind([matVer.Name], 'Statistics and Machine Learning Toolbox'))
    classList2 = {'AdaBoostM1'; 'LogitBoost'; 'GentleBoost';'RUSBoost';'Bag';'Support Vector Machine'};
    if ~isempty(strfind([matVer.Name], 'Optimization Toolbox'))
        classList2 = [classList2; 'RobustBoost'; 'LPBoost'; 'TotalBoost'];
    end
    classList2 = sort(classList2);
    classList = [classList; classList2];
end
set(handles.classifierPopup, 'string', classList);

% set some default parameters
handles.maxNumberOfSamplesPerClass = 500; 

handles.slic.slic = [];     % a field for superpixels, [height, width, depth]
handles.slic.noPix = [];    % a field for number of pixels, [depth] for 2d, or a single number for 3d
handles.slic.properties = [];   % a substructure with properties, only for handles.slic.properties(1)
                                %   .bb [xMin xMax yMin yMax zMin zMax]
                                %   .mode '2d' or '3d'
                                %   .binVal, binning values: (xy z)
                                %   .colCh, a color channel used for SLIC
                                %   .spSize, size of superpixels
                                %   .spCompact, compactness of superpixels
handles.FEATURES = [];      % a structure for features
handles.Forest = [];        % classifier

% populating directories
dirOut = fullfile(handles.h.mypath,'RF_Temp');
set(handles.tempDirEdit, 'string', dirOut);

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_Classifier);

dirOut = get(handles.tempDirEdit, 'string');
if exist(dirOut, 'dir') == 0
    res = questdlg('Use the following dialog to select a directory to store temporary data','Select directory','Continue','Cancel','Continue');
    if strcmp(res,'Cancel')
        mib_Classifier_CloseRequestFcn(handles.mib_Classifier, [], handles);
        return;
    end
    tempDirSelectBtn_Callback(handles.tempDirSelectBtn, [], handles);
    dirOut = get(handles.tempDirEdit, 'string');
end

list = handles.h.Img{handles.h.Id}.I.modelMaterialNames;   % list of materials
if handles.h.Img{handles.h.Id}.I.modelExist == 0 || numel(list) < 2
    warndlg(sprintf('!!! Warning !!!\n\nFor a new training a model with at least two materials is needed to proceed further!\n\nPlease create a new model with two materials - one for the objects and another one for the background. After that try again!\n\nIf the classifier was trained earlier, it can be loaded in the Train & Predict section\n\nPlease also refer to the Help section for details'),'Missing the model','modal');
    set(handles.trainClassifierBtn, 'enable', 'off');
    set(handles.predictSlice, 'enable', 'off');
end

updateWidgets(handles);     % update widgets

[~,fn] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
set(handles.classifierFilenameEdit, 'string', fn);

classifierFilenameEdit_Callback(handles.classifierFilenameEdit, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mib_Classifier wait for user response (see UIRESUME)
% uiwait(handles.mib_Classifier);
end

function updateWidgets(handles)     % update widgets
handles.h = guidata(handles.h.im_browser);  % update handles

list = handles.h.Img{handles.h.Id}.I.modelMaterialNames;   % list of materials
userData = get(handles.h.segmTable, 'UserData');
if isempty(list)
    set(handles.objectPopup, 'value', 1);
    set(handles.objectPopup, 'string', 'require 2 materials');
    set(handles.objectPopup, 'backgroundcolor', 'r');
    set(handles.backgroundPopup, 'value', 1);
    set(handles.backgroundPopup, 'string', 'require 2 materials');
    set(handles.backgroundPopup, 'backgroundcolor', 'r');
    set(handles.trainClassifierBtn, 'enable', 'off');
    set(handles.predictSlice, 'enable', 'off');
else
    % populating material lists
    set(handles.backgroundPopup, 'string', list);
    set(handles.backgroundPopup, 'value', 1);
    
    val = userData.prevAddTo-2;
    set(handles.objectPopup, 'string', list);
    set(handles.objectPopup, 'value', max([val 1]));
    set(handles.backgroundPopup, 'BackgroundColor', 'w');
    set(handles.objectPopup, 'BackgroundColor', 'w');
    
    if numel(list) < 2
        set(handles.trainClassifierBtn, 'enable', 'off');
        set(handles.predictSlice, 'enable', 'off');
    else
        set(handles.trainClassifierBtn, 'enable', 'on');
        set(handles.predictSlice, 'enable', 'on');
    end
end

if handles.h.Img{handles.h.Id}.I.no_stacks < 2
    set(handles.mode3dRadio, 'enable', 'off');
    set(handles.mode2dRadio, 'value', 1);
else
    set(handles.mode3dRadio, 'enable', 'on');
end

% updating color channels
colList = get(handles.h.ColChannelCombo, 'string');
set(handles.imageColChPopup, 'string', colList(2:end));
set(handles.imageColChPopup, 'value', max([get(handles.h.ColChannelCombo,'value')-1, 1]));

% populate subarea edit boxes
[height, width, ~, thick] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('selection', 4);
set(handles.xSubareaEdit, 'String', sprintf('%d:%d', 1, width));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', 1, height));
set(handles.zSubareaEdit, 'String', sprintf('%d:%d', 1, thick));

end

% --- Outputs from this function are returned to the command line.
function varargout = mib_Classifier_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isstruct(handles)    % to deal with closing of the figure
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end
end

% --- Executes when user attempts to close mib_Classifier.
function mib_Classifier_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_Classifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
end

function tempDirEdit_Callback(hObject, eventdata, handles)
currTempPath = get(handles.tempDirEdit, 'string');
if exist(currTempPath,'dir') == 0     % make directory
    mkdir(currTempPath);
end 
end

function tempDirSelectBtn_Callback(hObject, eventdata, handles)
currTempPath = get(handles.tempDirEdit, 'string');
if exist(currTempPath,'dir') == 0     % make directory
    mkdir(currTempPath);
end 
currTempPath = uigetdir(currTempPath, 'Select temp directory');
if currTempPath == 0; return; end;   % cancel
set(handles.tempDirEdit, 'string', currTempPath);
end

function classifierFilenameEdit_Callback(hObject, eventdata, handles)
handles.slic.slic = [];     % a field for superpixels, [height, width, depth]
handles.slic.noPix = [];    % a field for number of pixels, [depth] for 2d, or a single number for 3d
handles.slic.properties = [];   % a substructure with properties, only for handles.slic.properties(1)
                                %   .bb [xMin xMax yMin yMax zMin zMax]
                                %   .mode '2d' or '3d'
                                %   .slicSuperpixelsRadio 1-SLIC,0-Watershed
                                %   .binVal, binning values: (xy z)
                                %   .colCh, a color channel used for SLIC
handles.FEATURES = [];      % a structure for features
handles.Forest = [];        % classifier

dirOut = get(handles.tempDirEdit, 'string');
fn = get(handles.classifierFilenameEdit, 'string');
fn = fullfile(dirOut, [fn '.slic']);     % filename with superpixels
if exist(fn,'file') ~= 0
    res = questdlg(sprintf('!!! Warning !!!\n\nAn old project was found!\nProject name:\n%s\n\nLoad its settings and superpixels?', fn),'Load settings','Load','Cancel','Load');
    if strcmp(res,'Load')
        load(fn,'-mat');
        handles.slic = slic;
        clear slic;
        % update Subarea editboxes
        set(handles.xSubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(1), handles.slic.properties(1).bb(2)));
        set(handles.ySubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(3), handles.slic.properties(1).bb(4)));
        set(handles.zSubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(5), handles.slic.properties(1).bb(6)));
        set(handles.binSubareaEdit, 'string', sprintf('%d;%d', handles.slic.properties(1).binVal(1), handles.slic.properties(1).binVal(2)));
        set(handles.imageColChPopup, 'value', handles.slic.properties(1).colCh);
        if strcmp(handles.slic.properties(1).mode, '3d')
            set(handles.mode3dRadio, 'value', 1);
        end
        if handles.slic.properties(1).slicSuperpixelsRadio == 1
            set(handles.slicSuperpixelsRadio, 'value', 1);
            set(handles.watershedSuperpixelsRadio, 'value', 0);
        else
            set(handles.slicSuperpixelsRadio, 'value', 0);
            set(handles.watershedSuperpixelsRadio, 'value', 1);
        end
        superpixelTypeRadio_Callback(hObject, eventdata, handles);
        set(handles.superpixelEdit, 'string', num2str(handles.slic.properties(1).spSize));
        set(handles.superpixelsCompactEdit, 'string', num2str(handles.slic.properties(1).spCompact));
    end
end
guidata(handles.mib_Classifier, handles);
end

function updateLoglist(addText, handles)
status = get(handles.logList, 'string');
c = clock;
if isempty(status);
    status = {sprintf('%d:%02i:%02i  %s', c(4),c(5),round(c(6)),addText)};
else
    status(end+1) = {sprintf('%d:%02i:%02i  %s', c(4),c(5),round(c(6)),addText)};
end
set(handles.logList, 'string', status);
set(handles.logList, 'value', numel(status));
drawnow;
end

function resetDimsBtn_Callback(hObject, eventdata, handles)
[height, width, ~, thick] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('selection', 4);
set(handles.xSubareaEdit, 'String', sprintf('1:%d', width));
set(handles.ySubareaEdit, 'String', sprintf('1:%d', height));
set(handles.zSubareaEdit, 'String', sprintf('1:%d', thick));
set(handles.binSubareaEdit, 'String', '1; 1');
end

function checkDimensions(hObject, eventdata, handles, parameter)
text = get(hObject, 'String');
typedValue = str2num(text);
[height, width, ~, thick] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('selection', 4);
switch parameter
    case 'x'
        maxVal = width;
    case 'y'
        maxVal = height;
    case 'z'
        maxVal = thick;
end
if min(typedValue) < 1 || max(typedValue) > maxVal
    errordlg('Please check the values!','Wrong parameters!');
    set(hObject, 'string', sprintf('1:%d',maxVal));
    return;
end
end

function binSubareaEdit_Callback(hObject, eventdata, handles)
val = str2num(get(hObject, 'string'));
if isempty(val);
    val = [1; 1];
elseif isnan(val(1)) || min(val) <= .5
    val = [1;1];
else
    val = round(val);
end
set(hObject, 'string', sprintf('%d; %d',val(1), val(2)));
end

function subAreaFromSelectionBtn_Callback(hObject, eventdata, handles)
bgColor = get(handles.subAreaFromSelectionBtn, 'backgroundcolor');
set(handles.subAreaFromSelectionBtn, 'backgroundcolor','r');
drawnow;
img = handles.h.Img{handles.h.Id}.I.getData3D('selection', NaN, 4);
STATS = regionprops(img, 'BoundingBox');
if numel(STATS) == 0
    errordlg(sprintf('!!! Error !!!\n\nSelection layer was not found!\nPlease make sure that the Selection layer\n is shown in the Image View panel'),'Missing Selection');
    resetDimsBtn_Callback(hObject, eventdata, handles);
    set(handles.subAreaFromSelectionBtn, 'backgroundcolor',bgColor);
    return;
    %     elseif numel(STATS) > 1
    %         warndlg(sprintf('!!! Warning !!!\n\nThe Selection layer has several 3D objects!\nThe Bounding box of the first object will be used'),'Multiple 3D objects');
end
set(handles.xSubareaEdit, 'String', sprintf('%d:%d', ceil(STATS(1).BoundingBox(1)), ceil(STATS(1).BoundingBox(1))+STATS(1).BoundingBox(4)-1));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', ceil(STATS(1).BoundingBox(2)), ceil(STATS(1).BoundingBox(2))+STATS(1).BoundingBox(5)-1));
set(handles.zSubareaEdit, 'String', sprintf('%d:%d', ceil(STATS(1).BoundingBox(3)), ceil(STATS(1).BoundingBox(3))+STATS(1).BoundingBox(6)-1));
set(handles.subAreaFromSelectionBtn, 'backgroundcolor',bgColor);
end

function currentViewBtn_Callback(hObject, eventdata, handles)
[yMin, yMax, xMin, xMax] = handles.h.Img{handles.h.Id}.I.getCoordinatesOfShownImage();
set(handles.xSubareaEdit, 'String', sprintf('%d:%d', xMin, xMax));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', yMin, yMax));
end

function superpixelsBtn_Callback(hObject, eventdata, handles)
handles = guidata(handles.mib_Classifier);

dirOut = get(handles.tempDirEdit, 'string');
if exist(dirOut,'dir') == 0     % make directory
    mkdir(dirOut);
end 
fnOut = get(handles.classifierFilenameEdit, 'string');
fn = fullfile(dirOut, [fnOut '.slic']);     % filename to keep superpixels
if exist(fn,'file') || ~isempty(handles.slic.slic)
    button = questdlg(sprintf('!!! Warning !!!\n\nFile containing superpixels/supervoxels:\n%s\nalready exist!\nOverwrite?', fn),'Overwrite?','Overwrite','Cancel','Cancel');
    if strcmp(button, 'Cancel'); return; end;
end

handles.slic.slic = [];
handles.slic.noPix = [];

wb = waitbar(0, sprintf('Calculating superpixels/voxels...\nPlease wait...'), 'Name', 'Classifier segmentation');
col_channel = get(handles.imageColChPopup, 'value');
slicSuperpixelsRadio = get(handles.slicSuperpixelsRadio,'value');    % 1 - use SLIC, 0-use watershed
superpixelSize = str2double(get(handles.superpixelEdit,'string'));
superpixelCompact = str2double(get(handles.superpixelsCompactEdit, 'string'));

% get area for processing
width = str2num(get(handles.xSubareaEdit, 'String')); %#ok<ST2NM>
height = str2num(get(handles.ySubareaEdit, 'String'));  %#ok<ST2NM>
thick = str2num(get(handles.zSubareaEdit, 'String'));  %#ok<ST2NM>
% fill structure to use with getSlice and getDataset methods
getDataOptions.x = [min(width) max(width)];
getDataOptions.y = [min(height) max(height)];
getDataOptions.z = [min(thick) max(thick)];

% calculate image size after binning
binVal = str2num(get(handles.binSubareaEdit, 'string'));     % vector to bin the data binVal(1) for XY and binVal(2) for Z
binWidth = ceil((max(width)-min(width)+1)/binVal(1));
binHeight = ceil((max(height)-min(height)+1)/binVal(1));
binThick = ceil((max(thick)-min(thick)+1)/binVal(2));

getSliceOptions.x = getDataOptions.x;
getSliceOptions.y = getDataOptions.y;
if get(handles.mode2dRadio, 'value') % calculate superpixels
    updateLoglist('========= Calculating superpixels... =========', handles);
    mode = '2d';
    depth = getDataOptions.z(2)-getDataOptions.z(1)+1;
    for sliceNo=1:depth
        img = handles.h.Img{handles.h.Id}.I.getSlice('image', getDataOptions.z(1)+sliceNo-1, NaN, col_channel, NaN, getSliceOptions);

        if binVal(1) ~= 1   % bin data
            img = imresize(img, [binHeight binWidth], 'bicubic');
        end
        
        if sliceNo == 1
            % calculate number of supervoxels
            dims = size(img);
            noPix = ceil(dims(1)*dims(2)/superpixelSize);
            slic.slic = zeros([size(img,1),size(img,2),depth]);
            slic.noPix = zeros([depth, 1]);
            
            %noPix2 = ceil(noPix/8);
            %slic.slic2 = zeros([size(img,1),size(img,2), depth]);
            %slic.noPix2 = zeros([depth, 1]);
        end
        
        % stretch image for preview
        if get(handles.h.liveStretchCheck, 'value')
            img = imadjust(img ,stretchlim(img,[0 1]),[]);
        end
        if isa(img, 'uint16') % convert to 8bit
            currViewPort = handles.h.Img{handles.h.Id}.I.viewPort;
            img = imadjust(img,[currViewPort.min(col_channel)/65535 currViewPort.max(col_channel)/65535],[0 1],currViewPort.gamma(col_channel));
            img = uint8(img/255);
        end
        
        if slicSuperpixelsRadio
            [slic.slic(:,:,sliceNo), noPixCurrent] = slicmex(img, noPix, superpixelCompact);
            slic.noPix(sliceNo) = double(noPixCurrent);
            % remove superpixel with 0-index
            slic.slic(:,:,sliceNo) = slic.slic(:,:,sliceNo) + 1;
        
            %[slic.slic2(:,:,sliceNo), noPixCurrent] = slicmex(img, noPix2, superpixelCompact);
            %slic.noPix2(sliceNo) = double(noPixCurrent);
            % % remove superpixel with 0-index
            %slic.slic2(:,:,sliceNo) = slic.slic2(:,:,sliceNo) + 1;
        
            % calculate adjacent matrix for labels
            %slic.STATS{i} = regionprops(slic.slic(:,:,i), img(:,:,i), 'MeanIntensity','BoundingBox');
            %meanVals = [STATS.MeanIntensity];   % get mean intensity
        else
            if superpixelCompact > 0
                img = imcomplement(img);    % convert image that the ridges are white
            end
            
            mask = imextendedmin(img, superpixelSize);
            mask = imimposemin(img, mask);

            mask = watershed(mask);       % generate superpixels
            slic.slic(:,:,sliceNo) = imdilate(mask, ones([3 3]));
            slic.noPix(sliceNo) = max(max(mask));
        end
        waitbar(sliceNo/depth, wb, sprintf('Calculating...\nPlease wait...'));
    end
else        % calculate supervoxels
    updateLoglist('========= Calculating supervoxels... =========', handles);
    img = squeeze(handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, 4, col_channel, getDataOptions));   % get dataset
    mode = '3d';
    % bin dataset
    if binVal(1) ~= 1 || binVal(2) ~= 1
        waitbar(.05, wb, sprintf('Binning the dataset\nPlease wait...'));
        resizeOpt.height = binHeight;
        resizeOpt.width = binWidth;
        resizeOpt.depth = binThick;
        resizeOpt.method = 'bicubic';
        resizeOpt.algorithm = 'imresize';
        img = mib_resize3d(img, [], resizeOpt);
    end
    
    if slicSuperpixelsRadio
        % calculate number of supervoxels
        dims = size(img);
        slic.noPix = ceil(dims(1)*dims(2)*dims(3)/superpixelSize);
    
        % calculate supervoxels
        waitbar(.05, wb, sprintf('Calculating  %d SLIC supervoxels\nPlease wait...', slic.noPix));
        [slic.slic, slic.noPix] = slicsupervoxelmex_byte(img, slic.noPix, superpixelCompact);
        slic.noPix = double(slic.noPix);
    
        % remove superpixel with 0-index
        slic.slic = slic.slic + 1;
    else
        if superpixelCompact > 0
            waitbar(.05, wb, sprintf('Inverting the image\nPlease wait...'));
            img = imcomplement(img);    % convert image that the ridges are white
        end
        waitbar(.25, wb, sprintf('imextendedmin transformation\nPlease wait...'));
        mask = imextendedmin(img, superpixelSize);
        waitbar(.45, wb, sprintf('Imposing minima\nPlease wait...'));
        mask = imimposemin(img, mask);
        waitbar(.55, wb, sprintf('Doing watershed\nPlease wait...'));
        mask = watershed(mask);       % generate superpixels
        waitbar(.9, wb, sprintf('Removing edges\nPlease wait...'));
        slic.slic = imdilate(mask, ones([3 3 3]));
        slic.noPix = max(max(max(mask)));
    end
end
slic.properties(1).bb = [getDataOptions.x getDataOptions.y getDataOptions.z];   % store bounding box of the generated superpixels
slic.properties(1).mode = mode;     % store the mode for the calculated superpixels, 2D or 3D
slic.properties(1).slicSuperpixelsRadio = slicSuperpixelsRadio;     % type of superpixels: 1-SLIC, 0-Watershed
slic.properties(1).binVal = binVal;     % store binning value
slic.properties(1).colCh = col_channel; % store color channel
slic.properties(1).spSize = superpixelSize; % size of superpixels
slic.properties(1).spCompact = superpixelCompact; % compactness of superpixels

waitbar(.95, wb, sprintf('Saving to a file\nPlease wait...'));
updateLoglist(sprintf('Save to: %s', fn), handles);
save(fn, 'slic','-mat', '-v7.3');

handles.slic = slic;
delete(wb);
if get(handles.mode2dRadio, 'value')
    updateLoglist(sprintf('Calculating and saving (average=%d) superpixels: Done!!!', mean(slic.noPix)), handles);
else
    updateLoglist(sprintf('Calculating and saving %d supervoxels: Done!!!', slic.noPix), handles);
end
guidata(handles.mib_Classifier, handles);
end

function previewSuperpixelsBtn_Callback(hObject, eventdata, handles)
if isempty(handles.slic.noPix)
    dirOut = get(handles.tempDirEdit, 'string');
    fnOut = get(handles.classifierFilenameEdit, 'string');
    fn = fullfile(dirOut, [fnOut '.slic']);     % filename with superpixels
    if exist(fn,'file') == 0
        errordlg(sprintf('!!! Error !!!\n\nThe superpixels/supervoxels were not found!\nPlease generate them first using the Claculate superpixels button!'),'Superpixels are missing!')
        return;
    end
    load(fn,'-mat');
    handles.slic = slic;
    clear slic;
end

% fill structure to use with setSlice and setDataset methods
getDataOptions.x = handles.slic.properties(1).bb(1:2);
getDataOptions.y = handles.slic.properties(1).bb(3:4);
getDataOptions.z = handles.slic.properties(1).bb(5:6);

% calculate image size after binning
binVal = handles.slic.properties(1).binVal;     %#ok<ST2NM> % vector to bin the data binVal(1) for XY and binVal(2) for Z

if get(handles.mode2dRadio, 'value') % show superpixels
    if binVal(1) ~= 1   % re-bin mask
        resizeOpt.height = diff(getDataOptions.y)+1;
        resizeOpt.width = diff(getDataOptions.x)+1;
        resizeOpt.depth = diff(getDataOptions.z)+1;
        resizeOpt.method = 'nearest';
        resizeOpt.algorithm = 'imresize';
        L2 = mib_resize3d(handles.slic.slic, [], resizeOpt);
    else
        L2 = handles.slic.slic;
    end
    for i=1:size(L2,3)
        L2(:,:,i) = imdilate(L2(:,:,i),ones([3,3],class(L2))) > L2(:,:,i);
    end
    handles.h.Img{handles.h.Id}.I.setData3D('selection', uint8(L2), NaN, 4, NaN, getDataOptions);   % set dataset
else    % show supervoxels
    if binVal(1) ~= 1 || binVal(2) ~= 1
        resizeOpt.height = diff(getDataOptions.y)+1;
        resizeOpt.width = diff(getDataOptions.x)+1;
        resizeOpt.depth = diff(getDataOptions.z)+1;
        resizeOpt.method = 'nearest';
        resizeOpt.algorithm = 'imresize';
        L2 = mib_resize3d(handles.slic.slic, [], resizeOpt);
    else
        L2 = handles.slic.slic;
    end
    L2 = imdilate(L2,ones([3,3,3])) > L2;
    handles.h.Img{handles.h.Id}.I.setData3D('selection', L2, NaN, 4, NaN, getDataOptions);   % set dataset
end
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
guidata(handles.mib_Classifier, handles);
end

function calcFeaturesBtn_Callback(hObject, eventdata, handles)
if isempty(handles.slic.noPix)
    dirOut = get(handles.tempDirEdit, 'string');
    fnOut = get(handles.classifierFilenameEdit, 'string');
    fn = fullfile(dirOut, [fnOut '.slic']);     % filename with superpixels
    if exist(fn,'file') == 0
        superpixelsBtn_Callback(hObject, eventdata, handles);
        handles = guidata(handles.mib_Classifier);
    else
        load(fn,'-mat');
        handles.slic = slic;
        clear slic;
    end
end
col_channel = get(handles.imageColChPopup, 'value');

wb = waitbar(0, sprintf('Calculating features for superpixels/voxels...\nPlease wait...'), 'Name', 'Getting features');
tic
% update Subarea editboxes
set(handles.xSubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(1), handles.slic.properties(1).bb(2)));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(3), handles.slic.properties(1).bb(4)));
set(handles.zSubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(5), handles.slic.properties(1).bb(6)));
% fill structure to use with getSlice and getDataset methods
getDataOptions.x = handles.slic.properties(1).bb(1:2);
getDataOptions.y = handles.slic.properties(1).bb(3:4);
getDataOptions.z = handles.slic.properties(1).bb(5:6);

% calculate image size after binning
set(handles.binSubareaEdit, 'string', sprintf('%d;%d', handles.slic.properties(1).binVal(1), handles.slic.properties(1).binVal(2)));
binVal = handles.slic.properties(1).binVal;
binWidth = ceil((getDataOptions.x(2)-getDataOptions.x(1)+1)/binVal(1));
binHeight = ceil((getDataOptions.y(2)-getDataOptions.y(1)+1)/binVal(1));
binThick = ceil((getDataOptions.z(2)-getDataOptions.z(1)+1)/binVal(2));

getSliceOptions.x = getDataOptions.x;
getSliceOptions.y = getDataOptions.y;

indexOut = [];  % list of features to exclude, those that are NaN

if get(handles.mode2dRadio, 'value') % calculate features for superpixels
    updateLoglist('======= Calculating features for superpixels... =======', handles);
    waitbar(0, wb, sprintf('Calculating features for superpixels\nPlease wait...'));
    depth = getDataOptions.z(2)-getDataOptions.z(1)+1;
    for sliceNo=1:depth
        img = handles.h.Img{handles.h.Id}.I.getSlice('image', getDataOptions.z(1)+sliceNo-1, NaN, col_channel, NaN, getSliceOptions);
        if binVal(1) ~= 1   % bin data
            img = imresize(img, [binHeight binWidth], 'bicubic');
        end
        
        if sliceNo == 1
            % preallocating space
            FEATURES = struct;
            FEATURES(depth).fm = [];
            FEATURES(depth).BoundingBox = [];
        end
        
        % stretch the image
        minVal = min(min(min(img)));
        img = img - minVal;
        img = img*(255/double(max(max(max(img)))));
    
        STATS = regionprops(handles.slic.slic(:,:,sliceNo), img, 'BoundingBox','MeanIntensity','MaxIntensity','MinIntensity','PixelValues','Centroid','PixelIdxList');
        % store bounding box
        bb = arrayfun(@(ind) STATS(ind).BoundingBox, 1:numel(STATS),'UniformOutput', 0);
        bb = reshape(cell2mat(bb), [4, numel(bb)])';
        FEATURES(sliceNo).BoundingBox = bb;
        
        % get features
        FEATURES(sliceNo).fm(:,1) = [STATS.MeanIntensity];
        FEATURES(sliceNo).fm(:,2) = [STATS.MaxIntensity];
        FEATURES(sliceNo).fm(:,3) = [STATS.MinIntensity];
        
        FEATURES(sliceNo).fm(:,4)=arrayfun(@(ind) var(double(STATS(ind).PixelValues)), 1:numel(STATS),'UniformOutput',1);
        FEATURES(sliceNo).fm(:,5)=arrayfun(@(ind) std(double(STATS(ind).PixelValues)), 1:numel(STATS),'UniformOutput',1);
        FEATURES(sliceNo).fm(:,6)=arrayfun(@(ind) median(double(STATS(ind).PixelValues)), 1:numel(STATS),'UniformOutput',1);
        
        % calculate histogram arranged to 10 bins
        histVal = arrayfun(@(ind) hist(double(STATS(ind).PixelValues),[0:26:255]), 1:numel(STATS),'UniformOutput',0);
        histVal = reshape(cell2mat(histVal), [10, numel(histVal)])';
        [FEATURES(sliceNo).fm(:,7:16)] = histVal;
        
        %         entropyImg = entropyfilt(img);
        %         STATS2 = regionprops(handles.slic.slic(:,:,sliceNo), entropyImg, 'MeanIntensity');
        %         FEATURES(sliceNo).fm(:,17) = [STATS2.MeanIntensity];
        %
        %         L2 = imdilate(handles.slic.slic(:,:,sliceNo), ones([3,3], class(handles.slic.slic(:,:,sliceNo)))) > handles.slic.slic(:,:,sliceNo);
        %         currSlic = handles.slic.slic(:,:,sliceNo);
        %         for j=1:handles.slic.noPix(sliceNo)
        %             val = mean(img(currSlic==j & L2==1));
        %             if ~isnan(val)
        %                 FEATURES(sliceNo).fm(j,17) = val;
        %             else
        %                 FEATURES(sliceNo).fm(j,17) = 1;
        %             end
        %         end
        
        if 0
            shift = 18;
            gap = 0;    % regions are connected, no gap in between
            Edges = imRAG(handles.slic.slic(:,:,sliceNo), gap);
            Edges2 = fliplr(Edges);    % complement for both ways
            Edges = [Edges; Edges2];
            for idx = 1:numel(STATS)
                uInd = Edges(Edges(:,1)==idx,2);
                FEATURES(sliceNo).fm(idx,shift:shift+15) = mean(FEATURES(sliceNo).fm(uInd,1:16));
                FEATURES(sliceNo).fm(idx,shift+16) = std(FEATURES(sliceNo).fm(uInd,1));
            end
        end
        
        % test of downsampling where each pixel is a superpixel
        if 0
            shift2 = size(FEATURES(sliceNo).fm, 2);
            centVec = cat(1, STATS.Centroid);   % vector of centroids
            
            samplingRate = sqrt(handles.slic.properties.spSize/pi);     % get sampling rate for convertion to uniform points
            [xq,yq] = meshgrid(1:samplingRate:size(img,2), 1:samplingRate:size(img,1));
            slicImg = griddata(centVec(:,1),centVec(:,2), FEATURES(sliceNo).fm(:,1), xq, yq, 'nearest');    % FEATURES(sliceNo).fm(:,1) - mean intensity
            slicImg = uint8(slicImg);
            
            % alternatively just resize image to size of the superpixels...
            %slicImg = imresize(img, 1/samplingRate, 'bicubic');
            
            % % checks
            % figure(15)
            % mesh(xq,yq,slicImg);
            % hold on
            % plot3(centVec(:,1),centVec(:,2),meanInt,'o');
            % imtool(slicImg);
            
            % calculate features
            cs = 5; % context size
            ms = 1; % membrane thickness
            csHist = cs;
            fmTemp  = membraneFeatures(slicImg, cs, ms, csHist);
            % fmTemp - feature matrix [h, w, feature_id]
            noExtraFeatures = size(fmTemp,3);
            
            for idx=1:size(centVec,1)
                indX = ceil(centVec(idx,1)/samplingRate);
                indY = ceil(centVec(idx,2)/samplingRate);
                FEATURES(sliceNo).fm(idx,shift2+1:shift2+noExtraFeatures) = squeeze(fmTemp(indY, indX, :));
            end
            % find and remove NaNs
            for idx=shift2+1:shift2+noExtraFeatures
                if ~isempty(find(isnan(FEATURES(sliceNo).fm(:,idx))==1,1))
                    indexOut = [indexOut idx];
                end
            end
        end
        
        if 0
            shift2 = size(FEATURES(sliceNo).fm, 2);
            d_image = double(img);
            f00=[1, 1, 1; 1, -8, 1; 1, 1, 1];
            BETA=5; % to avoid that center pixture is equal to zero
            ALPHA=3; % like a lens to magnify or shrink the difference between neighbors
            
            LOG=conv2(d_image, f00, 'same'); %convolve with f00
            LOG_scaled=atan(ALPHA*LOG./(d_image+BETA)); %perform the tangent scaling
            LOG_norm=255*(LOG_scaled-min(min(LOG_scaled)))/(max(max(LOG_scaled))-min(min(LOG_scaled)));
            
            for idx=1:numel(STATS)
                FEATURES(sliceNo).fm(idx,shift2+1) = mean(LOG_norm(STATS(idx).PixelIdxList));
            end
        end
        
        % test of gabor filters
        if 0
            shift2 = size(FEATURES(sliceNo).fm, 2);
            
            wavelength = 4;
            %orientation = [0 15 30 45 60 75 90];
            orientation = 0:15:180;
            gaborBank = gabor(wavelength,orientation);
            noExtraFeatures = numel(orientation)*numel(wavelength);
%           % opt 1            
%             for idx = 1:numel(STATS)
%                 bb = ceil(FEATURES(sliceNo).BoundingBox(1,:));
%                 imgTemp = img(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1);
%                 imgTemp = imgaborfilt(imgTemp, gaborBank);
%                 for idx2 = 1:noExtraFeatures
%                     absGabor = abs(imgTemp(:,:,idx2));
%                     FEATURES(sliceNo).fm(idx, shift2+idx2) = mean(mean((absGabor-mean(absGabor(:)))/std(absGabor(:))));
%                 end
%             end

            % opt 2
            imgTemp = imgaborfilt(img, gaborBank);
            imgTemp = mean(imgTemp, 3);  % sum all directions
            for idx=1:numel(STATS)
                FEATURES(sliceNo).fm(idx,shift2+1) = mean(imgTemp(STATS(idx).PixelIdxList));
            end

        end
%         
        
        %         if 0    % test to use information from bigger superpixels
        %             [slic2, noPixCurrent] = slicmex(img, ceil(handles.slic.noPix/10), handles.slic.properties.spCompact);
        %             % % remove superpixel with 0-index
        %             slic2 = slic2 + 1;
        %             slic2 = double(slic2);
        %
        %             slic1 = handles.slic.slic(:,:,sliceNo);
        %             occuranceMatrix = zeros([handles.slic.noPix(sliceNo), noPixCurrent]);    % matrix of occurance of small superpixels in bigger superpixels
        %             for sPixId=1:noPixCurrent
        %                 sPixIndices = unique(slic1(slic2==sPixId));
        %                 occuranceMatrix(sPixIndices, sPixId) = histc(slic1(slic2==sPixId),sPixIndices);
        %             end
        %             %[~, FEATURES(1).fm(:,17)] = max(occuranceMatrix,[],2);
        %             [~, occuranceIndex] = max(occuranceMatrix,[],2); % correlates number of each small supervoxel with number of a bigger one
        %
        %             shift = 16;
        %             STATS = regionprops(slic2, img, 'MeanIntensity','PixelValues');
        %             % convert PixelValues to doubles
        %             STATS = arrayfun(@(s) setfield(s,'PixelValues',double(s.PixelValues)),STATS);
        %
        %             FEATURES(sliceNo).fm(:,shift+1) = arrayfun(@(ind) STATS(occuranceIndex(ind)).MeanIntensity, 1:numel(occuranceIndex),'UniformOutput',1);
        %             tempVal = arrayfun(@(ind) var(STATS(ind).PixelValues), 1:numel(STATS),'UniformOutput',1);
        %             FEATURES(sliceNo).fm(:,shift+2)=arrayfun(@(ind) tempVal(occuranceIndex(ind)), 1:numel(occuranceIndex),'UniformOutput',1);
        %
        %             histVal =  arrayfun(@(ind) hist(STATS(ind).PixelValues, [0:26:255]), 1:numel(STATS),'UniformOutput',0);
        %             histVal = reshape(cell2mat(histVal), [10, numel(histVal)])';
        %             histVal = arrayfun(@(ind) histVal(occuranceIndex(ind),:), 1:numel(occuranceIndex),'UniformOutput',0);
        %             histVal = reshape(cell2mat(histVal), [10, numel(histVal)])';
        %             FEATURES(sliceNo).fm(:,shift+3:shift+12)= histVal;
        %         end
        
        
        waitbar(sliceNo/depth, wb, sprintf('Calculating...\nPlease wait...'));
    end
    % remove possible NaNs
    for sliceNo=1:depth
        FEATURES(sliceNo).fm(:,indexOut) = [];
    end
else                                 % calculate features for supervoxels
    updateLoglist('======= Calculating features for supervoxels... =======', handles);
    img = squeeze(handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, 4, col_channel, getDataOptions));   % get dataset
    % bin dataset
    if binVal(1) ~= 1 || binVal(2) ~= 1
        waitbar(.05, wb, sprintf('Binning the dataset\nPlease wait...'));
        resizeOpt.height = binHeight;
        resizeOpt.width = binWidth;
        resizeOpt.depth = binThick;
        resizeOpt.method = 'bicubic';
        resizeOpt.algorithm = 'imresize';
        img = mib_resize3d(img, [], resizeOpt);
    end
    
    % calculate supervoxels
    waitbar(.05, wb, sprintf('Calculating features for %d supervoxels\nPlease wait...', handles.slic.noPix));
    
    % stretch the image
    minVal = min(min(min(img)));
    img = img - minVal;
    img = img*(255/double(max(max(max(img)))));
    
    % preallocating space
    FEATURES = struct;
    
    STATS = regionprops(handles.slic.slic, img, 'BoundingBox','MeanIntensity','MaxIntensity','MinIntensity','PixelValues', 'Centroid');
    % store bounding box
    bb = arrayfun(@(ind) STATS(ind).BoundingBox, 1:numel(STATS),'UniformOutput', 0);
    bb = reshape(cell2mat(bb), [6, numel(bb)])';
    FEATURES(1).BoundingBox = bb;
    
    % get features
    waitbar(.4, wb, sprintf('Calculating MeanIntensity for %d supervoxels\nPlease wait...', handles.slic.noPix));
    FEATURES(1).fm(:,1) = [STATS.MeanIntensity];
    waitbar(.45, wb, sprintf('Calculating MaxIntensity for %d supervoxels\nPlease wait...', handles.slic.noPix));
    FEATURES(1).fm(:,2) = [STATS.MaxIntensity];
    waitbar(.5, wb, sprintf('Calculating MinIntensity for %d supervoxels\nPlease wait...', handles.slic.noPix));
    FEATURES(1).fm(:,3) = [STATS.MinIntensity];
    
    waitbar(.55, wb, sprintf('Calculating Variance for %d supervoxels\nPlease wait...', handles.slic.noPix));
    FEATURES(1).fm(:,4)=arrayfun(@(ind) var(double(STATS(ind).PixelValues)), 1:numel(STATS),'UniformOutput',1);
    waitbar(.6, wb, sprintf('Calculating Std for %d supervoxels\nPlease wait...', handles.slic.noPix));
    FEATURES(1).fm(:,5)=arrayfun(@(ind) std(double(STATS(ind).PixelValues)), 1:numel(STATS),'UniformOutput',1);
    waitbar(.65, wb, sprintf('Calculating Median for %d supervoxels\nPlease wait...', handles.slic.noPix));
    FEATURES(1).fm(:,6)=arrayfun(@(ind) median(double(STATS(ind).PixelValues)), 1:numel(STATS),'UniformOutput',1);
    
    % calculate histogram arranged to 10 bins
    waitbar(.7, wb, sprintf('Calculating Histogram for %d supervoxels\nPlease wait...', handles.slic.noPix));
    histVal = arrayfun(@(ind) hist(double(STATS(ind).PixelValues),[0:26:255]), 1:numel(STATS),'UniformOutput',0);
    histVal = reshape(cell2mat(histVal), [10, numel(histVal)])';
    [FEATURES(1).fm(:,7:16)] = histVal;
    
    % calculate adjacent matrix for labels
    waitbar(.8, wb, sprintf('Calculating adjacent matrix for %d supervoxels\nPlease wait...', numel(STATS)));
    gap = 0;    % regions are connected, no gap in between
    Edges = imRAG(handles.slic.slic, gap);
    Edges2 = fliplr(Edges);    % complement for both ways
    Edges = [Edges; Edges2];
    
    for idx = 1:numel(STATS)
        uInd = Edges(Edges(:,1)==idx,2);
        FEATURES(1).fm(idx,17:32) = mean(FEATURES(1).fm(uInd,1:16));
        FEATURES(1).fm(idx,33) = std(FEATURES(1).fm(uInd,1));
    end
    
    if 0
        shift2 = size(FEATURES(1).fm, 2);
        centVec = cat(1, STATS.Centroid);   % vector of centroids
        
        samplingRate = sqrt(handles.slic.properties.spSize/pi);     % get sampling rate for convertion to uniform points
        [xq,yq,zq] = meshgrid(1:samplingRate:size(img,2), 1:samplingRate:size(img,1),1:samplingRate:size(img,3));
        slicImg = griddata(centVec(:,1),centVec(:,2),centVec(:,3), FEATURES(1).fm(:,1), xq, yq, zq, 'nearest');    % FEATURES(sliceNo).fm(:,1) - mean intensity
        slicImg = uint8(slicImg);
        
        % alternatively just resize image to size of the superpixels...
        %slicImg = imresize(img, 1/samplingRate, 'bicubic');
        
        % % checks
        % figure(15)
        % mesh(xq,yq,slicImg);
        % hold on
        % plot3(centVec(:,1),centVec(:,2),meanInt,'o');
        % imtool(slicImg);
        
        % calculate features
        cs = 5; % context size
        ms = 1; % membrane thickness
        csHist = cs;
        fmTemp  = membraneFeatures(slicImg, cs, ms, csHist);
        % fmTemp - feature matrix [h, w, feature_id]
        noExtraFeatures = size(fmTemp,3);
        
        for idx=1:size(centVec,1)
            indX = ceil(centVec(idx,1)/samplingRate);
            indY = ceil(centVec(idx,2)/samplingRate);
            indZ = ceil(centVec(idx,3)/samplingRate);
            FEATURES(1).fm(idx,shift2+1:shift2+noExtraFeatures) = squeeze(fmTemp(indY, indX, indZ, :));
        end
        % find and remove NaNs
        for idx=shift2+1:shift2+noExtraFeatures
            if ~isempty(find(isnan(FEATURES(1).fm(:,idx))==1,1))
                indexOut = [indexOut idx];
            end
        end
    end
    
    
    %     if 0    % test to use information from bigger supervoxels
    %         [slic2, noPixCurrent] = slicsupervoxelmex_byte(img, ceil(handles.slic.noPix/216), handles.slic.properties.spCompact);
    %         % % remove superpixel with 0-index
    %         slic2 = slic2 + 1;
    %         slic2 = double(slic2);
    %         occuranceMatrix = zeros([handles.slic.noPix, noPixCurrent]);    % matrix of occurance of small superpixels in bigger superpixels
%         for sPixId=1:noPixCurrent
%             sPixIndices = unique(handles.slic.slic(slic2==sPixId));
%             occuranceMatrix(sPixIndices, sPixId) = histc(handles.slic.slic(slic2==sPixId),sPixIndices);
%         end
%         %[~, FEATURES(1).fm(:,17)] = max(occuranceMatrix,[],2);
%         [~, occuranceIndex] = max(occuranceMatrix,[],2); % correlates number of each small supervoxel with number of a bigger one
%         
%         shift = 16;
%         STATS = regionprops(slic2, img, 'MeanIntensity','PixelValues');
%         % convert PixelValues to doubles
%         STATS = arrayfun(@(s) setfield(s,'PixelValues',double(s.PixelValues)),STATS);
%         
%         waitbar(.4, wb, sprintf('Calculating MeanIntensity for %d large supervoxels\nPlease wait...', noPixCurrent));
%         FEATURES(1).fm(:,shift+1) = arrayfun(@(ind) STATS(occuranceIndex(ind)).MeanIntensity, 1:numel(occuranceIndex),'UniformOutput',1);
%         waitbar(.55, wb, sprintf('Calculating Variance for %d large supervoxels\nPlease wait...', handles.slic.noPix));
%         tempVal = arrayfun(@(ind) var(STATS(ind).PixelValues), 1:numel(STATS),'UniformOutput',1);
%         FEATURES(1).fm(:,shift+2)=arrayfun(@(ind) tempVal(occuranceIndex(ind)), 1:numel(occuranceIndex),'UniformOutput',1);
%         
%         histVal =  arrayfun(@(ind) hist(STATS(ind).PixelValues), 1:numel(STATS),'UniformOutput',0);
%         histVal = reshape(cell2mat(histVal), [10, numel(histVal)])';
%         histVal = arrayfun(@(ind) histVal(occuranceIndex(ind),:), 1:numel(occuranceIndex),'UniformOutput',0);
%         histVal = reshape(cell2mat(histVal), [10, numel(histVal)])';
%         FEATURES(1).fm(:,shift+3:shift+12)= histVal;
%     end
    
    waitbar(1, wb, sprintf('Finishing\nPlease wait...'));
end

dirOut = get(handles.tempDirEdit, 'string');
fnOut = get(handles.classifierFilenameEdit, 'string');
fn = fullfile(dirOut, [fnOut '.features']);     % filename with features
save(fn, 'FEATURES','-mat');

handles.FEATURES = FEATURES;
delete(wb);
updateLoglist('Calculating and saving features: Done!!!', handles);
guidata(handles.mib_Classifier, handles);
toc
end

function trainClassifierToggle_Callback(hObject, eventdata, handles)
% hObject    handle to trainClassifierToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trainClassifierToggle
btnTag = get(hObject, 'tag');
switch btnTag
    case 'preprocessToggle'
        set(handles.preprocessPanel, 'visible', 'on');
        set(handles.trainClassifierPanel, 'visible', 'off');
    case 'trainClassifierToggle'
        set(handles.trainClassifierPanel, 'visible', 'on');
        set(handles.preprocessPanel, 'visible', 'off');
        if get(handles.mode2dRadio, 'value') % enable predict the current slice button
            set(handles.predictSlice, 'enable', 'on');
        else        % disable predict the current slice button
            set(handles.predictSlice, 'enable', 'off');
        end
end
end

function trainClassifierBtn_Callback(hObject, eventdata, handles)
% train random forest
bgCol = get(handles.trainClassifierBtn, 'backgroundColor');
set(handles.trainClassifierBtn, 'backgroundColor', [1 0 0]);

handles = guidata(handles.mib_Classifier);  % update handles

% load check required preprocessed data
if isempty(handles.FEATURES)
    dirOut = get(handles.tempDirEdit, 'string');
    fnOut = get(handles.classifierFilenameEdit, 'string');
    fn = fullfile(dirOut, [fnOut '.features']);     % filename to keep features
    if exist(fn,'file') == 0
        calcFeaturesBtn_Callback(hObject, eventdata, handles);
        handles = guidata(handles.mib_Classifier);
    else
        load(fn,'-mat');
        handles.FEATURES = FEATURES;
        clear FEATURES;
    end
end

if isempty(handles.slic.noPix)
    dirOut = get(handles.tempDirEdit, 'string');
    fnOut = get(handles.classifierFilenameEdit, 'string');
    fn = fullfile(dirOut, [fnOut '.slic']);     % filename with superpixels
    if exist(fn,'file') == 0
        superpixelsBtn_Callback(hObject, eventdata, handles);
        handles = guidata(handles.mib_Classifier);
    else
        load(fn,'-mat');
        handles.slic = slic;
        clear slic;
    end
end

set(handles.logList, 'string','');
updateLoglist('======= Starting training... =======', handles);

ib_do_backup(handles.h, 'selection', 1);    % store selection layer
posModel = get(handles.objectPopup, 'value');
negModel = get(handles.backgroundPopup, 'value');

handles.h = guidata(handles.h.im_browser);  % update handles

% update Subarea editboxes
set(handles.xSubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(1), handles.slic.properties(1).bb(2)));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(3), handles.slic.properties(1).bb(4)));
set(handles.zSubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(5), handles.slic.properties(1).bb(6)));
% fill structure to use with getSlice and getDataset methods
getDataOptions.x = handles.slic.properties(1).bb(1:2);
getDataOptions.y = handles.slic.properties(1).bb(3:4);
getDataOptions.z = handles.slic.properties(1).bb(5:6);

% calculate image size after binning
set(handles.binSubareaEdit, 'string', sprintf('%d;%d', handles.slic.properties(1).binVal(1), handles.slic.properties(1).binVal(2)));
binVal = handles.slic.properties(1).binVal;
binWidth = ceil((diff(getDataOptions.x)+1)/binVal(1));
binHeight = ceil((diff(getDataOptions.y)+1)/binVal(1));
binThick = ceil((diff(getDataOptions.z)+1)/binVal(2));

model = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, NaN, getDataOptions);   % get dataset
fmPos = [];
fmNeg = [];

NLearn = str2double(get(handles.classCyclesEdit, 'string'));
classId = get(handles.classifierPopup, 'value');
classType = get(handles.classifierPopup, 'string');
classType = classType{classId};

if get(handles.mode2dRadio, 'value') % train for superpixels
    if binVal(1) ~= 1   % bin data
        model2 = zeros([binHeight, binWidth, size(model,3)], class(model));
        for sliceId=1:size(model, 3)
            model2(:,:,sliceId) = imresize(model(:,:,sliceId), [binHeight binWidth], 'nearest');
        end
        model = model2;
        clear model2;
    end
    depth = size(model,3);
    updateLoglist('Extracting features for object and background...', handles);
    for sliceNo=1:depth
        % find slices with model
        if isempty(find(model(:,:,sliceNo) == posModel, 1)) && isempty(find(model(:,:,sliceNo) == negModel,1))
            continue;
        end
        
        currSlic = handles.slic.slic(:,:,sliceNo);
        posPos = unique(currSlic(model(:,:,sliceNo)==posModel));   % indices of superpixels that belong to the objects
        posNeg = unique(currSlic(model(:,:,sliceNo)==negModel));   % indices of superpixels that belong to the background
        
        % remove from labelBg those that are also found in labelObj
        posNeg(ismember(posNeg, posPos)) = [];
        
        fmPos = [fmPos; handles.FEATURES(sliceNo).fm(posPos,:)];  % get features for positive points, combine with another training slice
        fmNeg = [fmNeg; handles.FEATURES(sliceNo).fm(posNeg,:)];  % get features for negative points
    end
    clear posPos;
    clear posNeg;
else    % train for supervoxels
    % bin dataset
    if binVal(1) ~= 1 || binVal(2) ~= 1
        resizeOpt.height = binHeight;
        resizeOpt.width = binWidth;
        resizeOpt.depth = binThick;
        resizeOpt.method = 'nearest';
        resizeOpt.algorithm = 'imresize';
        model = mib_resize3d(model, [], resizeOpt);
    end
    
    updateLoglist('Extracting features for object and background...', handles);
   
    [posPos, ~, countL] = unique(handles.slic.slic(model==posModel));     % countL can be used to count number of occurances as
    [posNeg, ~, countBg] = unique(handles.slic.slic(model==negModel));       % numel(find(countL==IndexOfSuperpixel)))

    % when two labels intersect in one supervoxel, prefer the one that
    % has larger number of occurances
    [commonVal, bgIdx] = intersect(posNeg, posPos);  % find indices of the intersection supervoxels
    labelIdx = find(ismember(posPos, commonVal));
    for comId = 1:numel(commonVal)
        if numel(find(countL==labelIdx(comId))) > numel(find(countBg==bgIdx(comId)))
            posNeg(posNeg==commonVal(comId)) = [];
        else
            posPos(posPos==commonVal(comId)) = [];
        end
    end
    
    % OLD CODE that gives preference to label
    % % remove from labelBg those that are also found in labelObj
    %posNeg(ismember(posNeg, posPos)) = [];
    
     fmPos = [fmPos; handles.FEATURES(1).fm(posPos,:)];  % get features for positive points, combine with another training slice
     fmNeg = [fmNeg; handles.FEATURES(1).fm(posNeg,:)];  % get features for negative points
end
updateLoglist('Training the classifier...', handles);
y = [zeros(size(fmNeg,1),1);ones(size(fmPos,1),1)];     % generate a vector that defines positive and negative values
x = double([fmNeg; fmPos]);  % generate a matrix with combined features

extra_options.sampsize = [handles.maxNumberOfSamplesPerClass, handles.maxNumberOfSamplesPerClass];
if isempty(x) || isempty(y)
    errordlg(sprintf('!!! Error !!!\n\nThe labels are probably missing!\nMake sure that labels for the object and background are within the selected area!'));
    updateLoglist('Cancelled: missing labels!', handles);
    set(handles.trainClassifierBtn, 'backgroundColor', bgCol);
    return;
end

if classId == 1   % use random forest
    updateLoglist('Type: Random Forest', handles);
    Forest = classRF_train(x, y, 300, 5, extra_options);    % train classifier
else
    updateLoglist(sprintf('Type: %s', classType), handles);
    if strcmp(classType,'Support Vector Machine')
        %Forest = fitcsvm(x,y);
        Forest = fitctree(x,y); 
    else
        Forest = fitensemble(x,y, classType, NLearn, 'Tree', 'Type','classification');
    end
end

dirOut = get(handles.tempDirEdit, 'string');
fnOut = get(handles.classifierFilenameEdit, 'string');
fn = fullfile(dirOut, [fnOut '.forest']);     % filename to keep trained classifier

save(fn, 'Forest','-mat');
handles.Forest = Forest;
updateLoglist('Training the classifier: Done!', handles);
guidata(handles.mib_Classifier, handles);
set(handles.trainClassifierBtn, 'backgroundColor', bgCol);
end

function predictSlice_Callback(hObject, eventdata, handles)
set(handles.predictSlice, 'backgroundColor', [1 0 0]);
sliceNo = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
predictDataset(handles, sliceNo);
set(handles.predictSlice, 'backgroundColor', [0 1 0]);
end

function wipeTempDirBtn_Callback(hObject, eventdata, handles)
tempDir = get(handles.tempDirEdit,'string');
if exist(tempDir,'dir') ~= 0     % remove directory
    button =  questdlg(sprintf('!!! Warning !!!\n\nThe whole directory:\n\n%s\n\nwill be deleted!!!\n\nAre you sure?', tempDir),....
        'Delete directory?','Delete','Cancel','Cancel');
    if strcmp(button, 'Cancel')
        updateLoglist('Canceled!', handles);
        return;
    end
    
    rmdir(tempDir, 's');
    updateLoglist('The temp directory has been deleted', handles);
end

handles.slic.slic = [];     % a field for superpixels, [height, width, depth]
handles.slic.noPix = [];    % a field for number of pixels, [depth] for 2d, or a single number for 3d
handles.slic.properties = [];   % a substructure with properties, only for handles.slic.properties(1)
                                %   .bb [xMin xMax yMin yMax zMin zMax]
                                %   .mode '2d' or '3d'
                                %   .binVal, binning values: (xy z)
handles.FEATURES = [];      % a structure for features
handles.Forest = [];        % classifier

guidata(handles.mib_Classifier, handles);
end

function helpBtn_Callback(hObject, eventdata, handles)
web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_gui_menu_tools_random_forest_superpixels.html'), '-helpbrowser');
end


% --- Executes on button press in predictDatasetBtn.
function predictDatasetBtn_Callback(hObject, eventdata, handles)
% predict dataset using the random forest classifier
handles = guidata(handles.mib_Classifier);  % update handles
handles.h = guidata(handles.h.im_browser);  % update handles

% load check required preprocessed data
% check classifier
if isempty(handles.Forest)
    dirOut = get(handles.tempDirEdit, 'string');
    fnOut = get(handles.classifierFilenameEdit, 'string');
    fn = fullfile(dirOut, [fnOut '.forest']);     % filename to keep trained classifier

    if exist(fn,'file') == 0
        trainClassifierBtn_Callback(handles.trainClassifierBtn, eventdata, handles);
        handles = guidata(handles.mib_Classifier);
    else
        load(fn, '-mat');
        handles.Forest = Forest;
        clear Forest;
    end
end

% check features
if isempty(handles.FEATURES)
    dirOut = get(handles.tempDirEdit, 'string');
    fnOut = get(handles.classifierFilenameEdit, 'string');
    fn = fullfile(dirOut, [fnOut '.features']);     % filename with features

    if exist(fn,'file') == 0
        calcFeaturesBtn_Callback(hObject, eventdata, handles);
        handles = guidata(handles.mib_Classifier);
    else
        load(fn,'-mat');
        handles.FEATURES = FEATURES;
        clear FEATURES;
    end
end
% check superpixels/voxels
if isempty(handles.slic.noPix)
    dirOut = get(handles.tempDirEdit, 'string');
    fnOut = get(handles.classifierFilenameEdit, 'string');
    fn = fullfile(dirOut, [fnOut '.slic']);     % filename to keep superpixels
    if exist(fn,'file') == 0
        superpixelsBtn_Callback(hObject, eventdata, handles);
        handles = guidata(handles.mib_Classifier);
    else
        load(fn,'-mat');
        handles.slic = slic;
        clear slic;
    end
end

% update Subarea editboxes
set(handles.xSubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(1), handles.slic.properties(1).bb(2)));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(3), handles.slic.properties(1).bb(4)));
set(handles.zSubareaEdit, 'String', sprintf('%d:%d', handles.slic.properties(1).bb(5), handles.slic.properties(1).bb(6)));
% fill structure to use with getSlice and getDataset methods
getDataOptions.x = handles.slic.properties(1).bb(1:2);
getDataOptions.y = handles.slic.properties(1).bb(3:4);
getDataOptions.z = handles.slic.properties(1).bb(5:6);

% calculate image size after binning
set(handles.binSubareaEdit, 'string', sprintf('%d;%d', handles.slic.properties(1).binVal(1), handles.slic.properties(1).binVal(2)));
binVal = handles.slic.properties(1).binVal;
binWidth = ceil((diff(getDataOptions.x)+1)/binVal(1));
binHeight = ceil((diff(getDataOptions.y)+1)/binVal(1));
binThick = ceil((diff(getDataOptions.z)+1)/binVal(2));

if nargin == 2
    getDataOptions.z = [getDataOptions.z-sliceNumber+1 getDataOptions.z-sliceNumber+1];
end
%set(handles.logList, 'string','');
updateLoglist('======= Starting prediction... =======', handles);

ib_do_backup(handles.h, 'mask', 1);    % store selection layer

t1 = tic;
if handles.h.Img{handles.h.Id}.I.maskExist == 0
    handles.h.Img{handles.h.Id}.I.clearMask();   % clear or delete mask for uint8 model type
end

negModel = get(handles.backgroundPopup, 'value');

if handles.h.Img{handles.h.Id}.I.modelExist == 0
    createModelBtn_Callback(handles.h.createModelBtn,eventdata, handles.h); % make an empty model
end

if get(handles.mode2dRadio, 'value') % predict in 2D
    getSliceOptions.x = getDataOptions.x;
    getSliceOptions.y = getDataOptions.y;
    for sliceNo = 1:getDataOptions.z(2)-getDataOptions.z(1)+1
        Mask = zeros([size(handles.slic.slic,1), size(handles.slic.slic,2)], 'uint8');
        currSlic = handles.slic.slic(:,:,sliceNo);
        
        updateLoglist(sprintf('Predicting slice: %d...', sliceNo), handles);
        
        if isstruct(handles.Forest)
            [y_h, v] = classRF_predict(handles.FEATURES(sliceNo).fm, handles.Forest);
        else
            y_h = predict(handles.Forest, handles.FEATURES(sliceNo).fm);
        end
        
        %votes = v(:,2);
        %votes = reshape(votes,imsize);
        %votes = double(votes)/max(votes(:));
        indexLabel = find(y_h>0);
        Mask(ismember(double(currSlic), indexLabel)) = 1;
        
        model = handles.h.Img{handles.h.Id}.I.getSlice('model', getDataOptions.z(1)+sliceNo-1, NaN, NaN, NaN, getSliceOptions);
        if binVal(1) ~= 1   % bin data
            model = imresize(model, [binHeight binWidth], 'nearest');
        end
        Mask(model==negModel) = 0;    % remove background pixels
        
        if binVal(1) ~= 1   % bin data
            Mask = imresize(Mask, [diff(getDataOptions.y)+1, diff(getDataOptions.x)+1], 'nearest');
        end
        handles.h.Img{handles.h.Id}.I.setSlice('mask', Mask, getDataOptions.z(1)+sliceNo-1, NaN, NaN, NaN, getSliceOptions);
    end
else                                 % predict in 3D
    Mask = zeros(size(handles.slic.slic), 'uint8');
    updateLoglist('Predicting dataset...', handles);
    
    if isstruct(handles.Forest)
        [y_h, v] = classRF_predict(handles.FEATURES.fm, handles.Forest);
    else
        y_h = predict(handles.Forest, handles.FEATURES.fm);
    end
    
    indexLabel = find(y_h>0);
    Mask(ismember(double(handles.slic.slic), indexLabel)) = 1;
    
    updateLoglist('Removing background pixels...', handles);
    model = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, NaN, getDataOptions);   % get dataset
    % bin dataset
    resizeOpt.height = binHeight;
    resizeOpt.width = binWidth;
    resizeOpt.depth = binThick;
    resizeOpt.method = 'nearest';
    resizeOpt.algorithm = 'imresize';
    if binVal(1) ~= 1 || binVal(2) ~= 1
        model = mib_resize3d(model, [], resizeOpt);
    end
    Mask(model==negModel) = 0;    % remove background pixels
    
    if binVal(1) ~= 1 || binVal(2) ~= 1
        updateLoglist('Re-binning the mask...', handles);
        resizeOpt.height = diff(getDataOptions.y)+1;
        resizeOpt.width = diff(getDataOptions.x)+1;
        resizeOpt.depth = diff(getDataOptions.z)+1;
        Mask = mib_resize3d(Mask, [], resizeOpt);
    end
    handles.h.Img{handles.h.Id}.I.setData3D('mask', Mask, NaN, 4, NaN, getDataOptions);   % set dataset
end

updateLoglist('======= Prediction finished! =======', handles);
resultTOC = toc(t1);
updateLoglist(sprintf('Elapsed time is %f seconds.',resultTOC), handles);
set(handles.h.maskShowCheck, 'value', 1);   % turn on the mask
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
guidata(handles.mib_Classifier, handles);
end


% --- Executes on selection change in classifierPopup.
function classifierPopup_Callback(hObject, eventdata, handles)
val = get(hObject, 'value');
if val > 1
    set(handles.classCyclesEdit, 'enable', 'on');
else
    set(handles.classCyclesEdit, 'enable', 'off');
end
end


% --- Executes on button press in loadClassifierBtn.
function loadClassifierBtn_Callback(hObject, eventdata, handles)
tempDir = get(handles.tempDirEdit, 'string');
[FileName,PathName,FilterIndex] = uigetfile('*.forest','Select trained classifier',tempDir, 'MultiSelect', 'off');
fn = fullfile(PathName, FileName);
res = load(fn, '-mat');
Forest = res.Forest;
handles.Forest = Forest;

% saving the classifier using the current project name
fnOut = get(handles.classifierFilenameEdit, 'string');
fn = fullfile(tempDir, [fnOut '.forest']);     % filename to keep trained classifier

save(fn, 'Forest','-mat');
updateLoglist('Loading the classifier: Done!', handles);
guidata(handles.mib_Classifier, handles);
end


% --- Executes on button press in updateMaterialsBtn.
function updateMaterialsBtn_Callback(hObject, eventdata, handles)
% populating lists of materials
updateWidgets(handles);
end


% --------------------------------------------------------------------
function superpixelTypeRadio_Callback(hObject, eventdata, handles)
if get(handles.slicSuperpixelsRadio, 'value')   % use SLIC superpixels
    set(handles.superpixelText, 'TooltipString', 'number of superpixels, larger number gives more precision, but slower');
    set(handles.superpixelEdit, 'TooltipString', 'number of superpixels, larger number gives more precision, but slower');
    set(handles.superpixelEdit, 'String', '500');
    set(handles.superpixelsCompactText, 'String', 'Compact');
    set(handles.superpixelsCompactText, 'TooltipString', 'compactness factor, the larger the number more square resulting superpixels');
    set(handles.superpixelsCompactEdit, 'TooltipString', 'compactness factor, the larger the number more square resulting superpixels');
else                                            % use Watershed superpixels
    set(handles.superpixelText, 'TooltipString', 'factor to modify size of superpixels, the larger number gives bigger superpixels, use 15 as a starting value');
    set(handles.superpixelEdit, 'TooltipString', 'factor to modify size of superpixels, the larger number gives bigger superpixels, use 15 as a starting value');
    set(handles.superpixelEdit, 'String', '15');
    set(handles.superpixelsCompactText, 'String', 'Black on white');
    set(handles.superpixelsCompactText, 'TooltipString', 'put 0 if objects have bright boundaries or 1 if objects have dark boundaries');
    set(handles.superpixelsCompactEdit, 'TooltipString', 'put 0 if objects have bright boundaries or 1 if objects have dark boundaries');
end

end
