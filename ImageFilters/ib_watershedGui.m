function varargout = ib_watershedGui(varargin)
% function varargout = ib_watershedGui(varargin)
% ib_watershedGui function is responsible for watershed operations.
%
% ib_watershedGui contains MATLAB code for ib_watershedGui.fig

% Copyright (C) 29.09.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 25.10.2016, IB, updated for segmentation table


% Edit the above text to modify the response to help ib_watershedGui

% Last Modified by GUIDE v2.5 11-May-2016 12:58:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ib_watershedGui_OpeningFcn, ...
    'gui_OutputFcn',  @ib_watershedGui_OutputFcn, ...
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

% --- Executes just before ib_watershedGui is made visible.
function ib_watershedGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_watershedGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser
set(handles.ib_watershedGui,'position',[389.25 594.0 256 450.75]);

% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_watershedGui, handles.h.preferences.Font);
end

% radio button callbacks
set(handles.watershedSourcePanel, 'SelectionChangeFcn', @distanceRadio_Callback);

updateWidgets(handles);     % update widgets of the watershed window

% update parent and position for the superpixelsStepsPanel
set(handles.superpixelsStepsPanel, 'parent', get(handles.preprocPanel, 'parent'));
set(handles.superpixelsStepsPanel, 'position', get(handles.preprocPanel, 'position'));

% variable for data preprocessing
handles.preprocImg = NaN;
graphcut.slic = [];     % SLIC labels for the graph cut workflow
graphcut.noPix = [];    % number of superpixels/supervoxels for the graph cut workflow
graphcut.Graph{1} = [];    % graph for the graph cut workflow
%graphcut.PixelIdxList{1} = [];  % position of pixels in each supervoxels

setappdata(handles.ib_watershedGui, 'graphcut', graphcut);  % store graphcut using setappdata because of some strange memory leaks 

% define the current mode
handles.mode = 'mode2dCurrentRadio';
set(handles.mode2dCurrentRadio,'value',1);

% Choose default command line output for ib_watershedGui
handles.output = hObject;

% set background color to panels and texts
set(handles.ib_watershedGui,'Color',[.831 .816 .784]);
tempList = findall(handles.ib_watershedGui,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_watershedGui,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_watershedGui,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_watershedGui,'Style','radiobutton');    % set color to radiobuttons
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_watershedGui,'Type','uibuttongroup');    % set color to uibuttongroups
set(tempList,'BackgroundColor',[.831 .816 .784]);


% Place panels
pos = get(handles.imageSegmentationPanel,'position');
set(handles.objectSeparationPanel, 'position', pos);

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_watershedGui);

% Determine the position of the dialog - on a side of the main figure
% if available, else, centered on the main figure
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
    screenSize = get(0,'ScreenSize');
    if GCBFPos(1)-FigWidth > 0 % put figure on the left side of the main figure
        FigPos(1:2) = [GCBFPos(1)-FigWidth-10 GCBFPos(2)+GCBFPos(4)-FigHeight];
    elseif GCBFPos(1) + GCBFPos(3) + FigWidth < screenSize(3) % put figure on the right side of the main figure
        FigPos(1:2) = [GCBFPos(1)+GCBFPos(3)+10 GCBFPos(2)+GCBFPos(4)-FigHeight];
    else
        FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
            (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
    end
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Update handles structure
guidata(hObject, handles);

% select graphcut segmentation
set(handles.graphCutToggle, 'value', 1);
graphCutToggle_Callback(handles.graphCutToggle, eventdata, handles);

% UIWAIT makes ib_watershedGui wait for user response (see UIRESUME)
% uiwait(handles.ib_watershedGui);
end

% --- Executes on button press in updateMaterialsBtn.
function updateMaterialsBtn_Callback(hObject, eventdata, handles)
% populating lists of materials
list = handles.h.Img{handles.h.Id}.I.modelMaterialNames;
if handles.h.Img{handles.h.Id}.I.modelExist == 0 || isempty(list)
    set(handles.modelRadio, 'enable', 'off');
    set(handles.selectedMaterialPopup, 'enable', 'off');
    set(handles.seedsModelRadio, 'enable', 'off');
    set(handles.seedsSelectedMaterialPopup, 'enable', 'off');
    set(handles.backgroundMateriaPopup, 'string', 'Please create a model with 2 materials: background and object and restart the watershed tool');
    set(handles.backgroundMateriaPopup, 'backgroundcolor', 'r');
    set(handles.signalMateriaPopup, 'string', 'Please create a model with 2 materials: background and object and restart the watershed tool');
    set(handles.signalMateriaPopup, 'backgroundcolor', 'r');
    
else
    userData = get(handles.h.segmTable,'UserData');
    list = handles.h.Img{handles.h.Id}.I.modelMaterialNames;
    set(handles.backgroundMateriaPopup, 'value', 1);
    set(handles.backgroundMateriaPopup, 'string', list);
    set(handles.backgroundMateriaPopup, 'BackgroundColor', 'w');
    set(handles.signalMateriaPopup, 'value', numel(list));
    set(handles.signalMateriaPopup, 'string', list);
    set(handles.signalMateriaPopup, 'BackgroundColor', 'w');
    val = userData.prevMaterial - 2;
    set(handles.selectedMaterialPopup, 'string', list);
    set(handles.selectedMaterialPopup, 'value', max([val 1]));
    set(handles.seedsSelectedMaterialPopup, 'string', list);
    set(handles.seedsSelectedMaterialPopup, 'value', max([val 1]));
end
end



function updateWidgets(handles)
handles.h = guidata(handles.h.im_browser);  % update handles
% populate aspect ratio edit box
minVal = min([handles.h.Img{handles.h.Id}.I.pixSize.x handles.h.Img{handles.h.Id}.I.pixSize.y handles.h.Img{handles.h.Id}.I.pixSize.z]);
aspect(1) = handles.h.Img{handles.h.Id}.I.pixSize.x/minVal;
aspect(2) = handles.h.Img{handles.h.Id}.I.pixSize.y/minVal;
aspect(3) = handles.h.Img{handles.h.Id}.I.pixSize.z/minVal;
set(handles.aspectRatio, 'string', sprintf('%.3f %.3f %.3f', aspect(1), aspect(2), aspect(3)));

if handles.h.Img{handles.h.Id}.I.no_stacks < 2
    set(handles.mode3dRadio, 'enable', 'off');
    set(handles.aspectRatio, 'enable', 'off');
    set(handles.mode2dCurrentRadio, 'value', 1);
else
    set(handles.mode3dRadio, 'enable', 'on');
    set(handles.aspectRatio, 'enable', 'on');
end

% updating color channels
colList = get(handles.h.ColChannelCombo, 'string');
set(handles.imageColChPopup, 'string', colList(2:end));
set(handles.imageIntensityColorCh, 'string', colList(2:end));
set(handles.imageColChPopup, 'value', max([get(handles.h.ColChannelCombo,'value')-1, 1]));
set(handles.imageIntensityColorCh, 'value', max([get(handles.h.ColChannelCombo,'value')-1, 1]));


% populating lists of materials
updateMaterialsBtn_Callback(NaN, NaN, handles);

if handles.h.Img{handles.h.Id}.I.maskExist == 0
    set(handles.maskRadio, 'enable', 'off');
    set(handles.maskRadio,'value', 0);
    set(handles.selectionRadio,'value', 1);
    set(handles.seedsMaskRadio, 'enable', 'off');
    set(handles.seedsMaskRadio, 'value', 0);
    set(handles.seedsSelectionRadio, 'value', 1);
else
    set(handles.maskRadio, 'enable', 'on');
    set(handles.seedsMaskRadio, 'enable', 'on');
end

% populate subarea edit boxes
[height, width, ~, thick] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('selection', 4);
set(handles.xSubareaEdit, 'String', sprintf('%d:%d', 1, width));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', 1, height));
set(handles.zSubareaEdit, 'String', sprintf('%d:%d', 1, thick));
guidata(handles.ib_watershedGui, handles);  % store handles
end


% --- Outputs from this function are returned to the command line.
function varargout = ib_watershedGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to closeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button = questdlg(sprintf('You are going to close the Graphcut/Watershed segmentation tool\nAre you sure?'),'Close Graphcut/Watershed','Close','Cancel','Cancel');
if strcmp(button, 'Cancel'); return; end;
delete(handles.ib_watershedGui);
end

% --- Executes on button press in imageSegmentationToggle.
function imageSegmentationToggle_Callback(hObject, eventdata, handles)
bgColor = get(handles.resetDimsBtn, 'backgroundcolor');
set(hObject,'Value',1);
set(handles.imageSegmentationToggle, 'value', 1);
set(handles.objectSeparationToggle, 'value', 0);
set(handles.graphCutToggle, 'value', 0);
set(handles.imageSegmentationPanel, 'visible', 'on');
set(handles.objectSeparationPanel, 'visible', 'off');
set(handles.imageSegmentationToggle, 'backgroundcolor', 'g');
set(handles.objectSeparationToggle, 'backgroundcolor', bgColor);
set(handles.graphCutToggle, 'backgroundcolor', bgColor);
set(handles.superpixelsStepsPanel, 'visible', 'off');
set(handles.preprocPanel, 'visible', 'on');

updateWidgets(handles);     % update widgets of the watershed window
end

% --- Executes on button press in objectSeparationToggle.
function objectSeparationToggle_Callback(hObject, eventdata, handles)
bgColor = get(handles.resetDimsBtn, 'backgroundcolor');
set(hObject,'Value',1);
set(handles.imageSegmentationToggle, 'value', 0);
set(handles.objectSeparationToggle, 'value', 1);
set(handles.graphCutToggle, 'value', 0);
set(handles.imageSegmentationPanel, 'visible', 'off');
set(handles.objectSeparationPanel, 'visible', 'on');
set(handles.imageSegmentationToggle, 'backgroundcolor', bgColor);
set(handles.objectSeparationToggle, 'backgroundcolor', 'g');
set(handles.graphCutToggle, 'backgroundcolor', bgColor);
updateWidgets(handles);     % update widgets of the watershed window
end

% --- Executes on button press in graphCutToggle.
function graphCutToggle_Callback(hObject, eventdata, handles)
bgColor = get(handles.resetDimsBtn, 'backgroundcolor');
set(hObject,'Value',1);
set(handles.imageSegmentationToggle, 'value', 0);
set(handles.objectSeparationToggle, 'value', 0);
set(handles.graphCutToggle, 'value', 1);
set(handles.imageSegmentationPanel, 'visible', 'on');
set(handles.objectSeparationPanel, 'visible', 'off');
set(handles.imageSegmentationToggle, 'backgroundcolor', bgColor);
set(handles.objectSeparationToggle, 'backgroundcolor', bgColor);
set(handles.graphCutToggle, 'backgroundcolor', 'g');
set(handles.superpixelsStepsPanel, 'visible', 'on');
set(handles.preprocPanel, 'visible', 'off');

%if ~isa(handles.h.Img{handles.h.Id}.I.img, 'uint8');
%    msgbox(sprintf('!!! Warning !!!\n\nPlease convert dataset to the 8-bit mode!'));
%end

updateWidgets(handles);     % update widgets of the watershed window
end

% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_gui_menu_tools_watershed.html'), '-helpbrowser');
end


function aspectRatio_Callback(hObject, eventdata, handles)
val = get(handles.aspectRatio, 'string');
val = str2num(val); %#ok<ST2NM>
if isempty(val) || numel(val) ~= 3 || min(val)<=0
    errordlg(sprintf('Wrong aspect ratio!\nPlease enter 3 numbers above 0 and try again!'),'Error!');
    minVal = min([handles.h.Img{handles.h.Id}.I.pixSize.x handles.h.Img{handles.h.Id}.I.pixSize.y handles.h.Img{handles.h.Id}.I.pixSize.z]);
    aspect(1) = handles.h.Img{handles.h.Id}.I.pixSize.x/minVal;
    aspect(2) = handles.h.Img{handles.h.Id}.I.pixSize.y/minVal;
    aspect(3) = handles.h.Img{handles.h.Id}.I.pixSize.z/minVal;
    set(handles.aspectRatio, 'string', sprintf('%.3f %.3f %.3f', aspect(1), aspect(2), aspect(3)));
    return;
end
end

% --- Executes on button press in clearPreprocessBtn.
function clearPreprocessBtn_Callback(hObject, eventdata, handles)
% variable for data preprocessing
graphcut = getappdata(handles.ib_watershedGui, 'graphcut');

handles.preprocImg = NaN;
graphcut.slic = [];     % SLIC labels for the graph cut workflow
graphcut.noPix = [];    % number of superpixels/supervoxels for the graph cut workflow
graphcut.Graph = [];    % graph for the graph cut workflow
graphcut.Graph{1} = [];    % graph for the graph cut workflow
%graphcut.PixelIdxList = [];  % position of pixels in each supervoxels
%graphcut.PixelIdxList{1} = [];  % position of pixels in each supervoxels

setappdata(handles.ib_watershedGui, 'graphcut', graphcut);

bgcol = get(handles.clearPreprocessBtn, 'backgroundcolor');
set(handles.preprocessBtn, 'backgroundcolor', bgcol);
set(handles.superpixelsBtn, 'backgroundcolor', bgcol);
set(handles.superpixelsCountText, 'string', sprintf('Superpixels count: 0'));

% Update handles structure
guidata(handles.ib_watershedGui, handles);
end

% --- Executes on button press in mode2dRadio.
function mode2dRadio_Callback(hObject, eventdata, handles)
graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
if ~isnan(handles.preprocImg(1)) || ~isempty(graphcut.noPix)
    button =  questdlg(sprintf('!!! Attention !!!\n\nThe pre-processed data will be removed!'),'Warning!','Continue','Cancel','Cancel');
    if strcmp(button,'Cancel');
        set(handles.(handles.mode),'value', 1);
        return;
    end;
    clearPreprocessBtn_Callback(handles.clearPreprocessBtn, 0, handles);    % clear preprocessed data
end
handles.mode = get(hObject,'tag');
switch handles.mode
    case 'mode3dRadio'
        set(handles.chopXedit, 'enable', 'on');
        set(handles.chopYedit, 'enable', 'on');
    otherwise
        set(handles.chopXedit, 'enable', 'off');
        set(handles.chopYedit, 'enable', 'off');
end

set(hObject,'value',1);
% Update handles structure
guidata(hObject, handles);
end

function eigenSigmaEdit_Callback(hObject, eventdata, handles)
eigenSigma = str2double(get(handles.eigenSigmaEdit, 'string'));
if eigenSigma < 1 && ~strcmp(handles.mode,'mode3dRadio')
    warndlg('Sigma should be larger than 1!','Wrong Sigma');
    set(handles.eigenSigmaEdit, 'string', '1.6');
end
end

function xSubareaEdit_Callback(hObject, eventdata, handles)
checkDimensions(hObject, handles, 'x');
end


function ySubareaEdit_Callback(hObject, eventdata, handles)
checkDimensions(hObject, handles, 'y');
end


function zSubareaEdit_Callback(hObject, eventdata, handles)
checkDimensions(hObject, handles, 'z');
end

function checkDimensions(hObject, handles, parameter)
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
clearPreprocessBtn_Callback(handles.clearPreprocessBtn, 0, handles);    % clear preprocessed data
end

% --- Executes on button press in resetDimsBtn.
function resetDimsBtn_Callback(hObject, eventdata, handles)
[height, width, ~, thick] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('selection', 4);
set(handles.xSubareaEdit, 'String', sprintf('1:%d', width));
set(handles.ySubareaEdit, 'String', sprintf('1:%d', height));
set(handles.zSubareaEdit, 'String', sprintf('1:%d', thick));
set(handles.binSubareaEdit, 'String', '1; 1');
clearPreprocessBtn_Callback(handles.clearPreprocessBtn, 0, handles);    % clear preprocessed data
end

% --- Executes on button press in currentViewBtn.
function currentViewBtn_Callback(hObject, eventdata, handles)
[yMin, yMax, xMin, xMax] = handles.h.Img{handles.h.Id}.I.getCoordinatesOfShownImage();
set(handles.xSubareaEdit, 'String', sprintf('%d:%d', xMin, xMax));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', yMin, yMax));
clearPreprocessBtn_Callback(handles.clearPreprocessBtn, 0, handles);    % clear preprocessed data
end


% --- Executes on button press in subAreaFromSelectionBtn.
function subAreaFromSelectionBtn_Callback(hObject, eventdata, handles)
bgColor = get(handles.subAreaFromSelectionBtn, 'backgroundcolor');
set(handles.subAreaFromSelectionBtn, 'backgroundcolor','r');
drawnow;
if strcmp(handles.mode, 'mode2dCurrentRadio')
    img = handles.h.Img{handles.h.Id}.I.getFullSlice('selection');
    STATS = regionprops(img, 'BoundingBox');
    if numel(STATS) == 0
        errordlg(sprintf('!!! Error !!!\n\nSelection layer was not found!\nPlease make sure that the Selection layer\nis shown in the Image View panel'),'Missing Selection');
        resetDimsBtn_Callback(hObject, eventdata, handles);
        set(handles.subAreaFromSelectionBtn, 'backgroundcolor',bgColor);
        return;
    end
    set(handles.xSubareaEdit, 'String', sprintf('%d:%d', ceil(STATS(1).BoundingBox(1)), ceil(STATS(1).BoundingBox(1))+STATS(1).BoundingBox(3)-1));
    set(handles.ySubareaEdit, 'String', sprintf('%d:%d', ceil(STATS(1).BoundingBox(2)), ceil(STATS(1).BoundingBox(2))+STATS(1).BoundingBox(4)-1));
else
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
end
clearPreprocessBtn_Callback(handles.clearPreprocessBtn, eventdata, handles);    % clear preprocessed data
set(handles.subAreaFromSelectionBtn, 'backgroundcolor',bgColor);
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
clearPreprocessBtn_Callback(handles.clearPreprocessBtn, eventdata, handles);    % clear preprocessed data
end

% --- Executes on button press in useSeedsCheck.
function useSeedsCheck_Callback(hObject, eventdata, handles)
val = get(handles.useSeedsCheck, 'value');
if val == 1
    set(handles.seedsPanel, 'visible', 'on');
    set(handles.reduiceOversegmCheck, 'visible', 'off');
else
    set(handles.seedsPanel, 'visible', 'off');
    set(handles.reduiceOversegmCheck, 'visible', 'on');
end
end

% --- Executes on selection change in selectedMaterialPopup.
function selectedMaterialPopup_Callback(hObject, eventdata, handles)
set(handles.modelRadio, 'value', 1);
end


% --- Executes on selection change in seedsSelectedMaterialPopup.
function seedsSelectedMaterialPopup_Callback(hObject, eventdata, handles)
set(handles.seedsModelRadio, 'value', 1);
end

% --- Executes on button press in distanceRadio.
function distanceRadio_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
hObject = eventdata.NewValue;
tagId = get(hObject, 'tag');
curVal = get(hObject, 'value');
if curVal == 0; set(hObject, 'value', 1); return; end;
set(handles.watSourceTxt1, 'visible', 'off');
set(handles.watSourceTxt2, 'visible', 'off');
set(handles.imageIntensityColorCh, 'visible', 'off');
set(handles.imageIntensityInvert, 'visible', 'off');

if strcmp(tagId, 'intensityRadio')
    set(handles.watSourceTxt1, 'visible', 'on');
    set(handles.watSourceTxt2, 'visible', 'on');
    set(handles.imageIntensityColorCh, 'visible', 'on');
    set(handles.imageIntensityInvert, 'visible', 'on');
end
end

% --- Executes on button press in preprocessBtn.
function preprocessBtn_Callback(hObject, eventdata, handles)
col_channel = get(handles.imageColChPopup, 'value');
gradientSw = get(handles.gradientCheck, 'value');
eigenSw = get(handles.eigenvalueCheck, 'value');

% no options are selected for preprocessing
if gradientSw == 0 && eigenSw == 0
    return;
end

eigenSigma = str2double(get(handles.eigenSigmaEdit, 'string'));
invertImage = get(handles.signalPopup, 'value');    % if == 1 image should be inverted, black-on-white

% get area for processing
width = str2num(get(handles.xSubareaEdit, 'String'));
height = str2num(get(handles.ySubareaEdit, 'String'));
thick = str2num(get(handles.zSubareaEdit, 'String'));
% fill structure to use with getSlice and getDataset methods
getDataOptions.x = [min(width) max(width)];
getDataOptions.y = [min(height) max(height)];
getDataOptions.z = [min(thick) max(thick)];

% calculate image size after binning
binVal = str2num(get(handles.binSubareaEdit, 'string'));     % vector to bin the data binVal(1) for XY and binVal(2) for Z
binWidth = ceil((max(width)-min(width)+1)/binVal(1));
binHeight = ceil((max(height)-min(height)+1)/binVal(1));
binThick = ceil((max(thick)-min(thick)+1)/binVal(2));

wb = waitbar(0, 'Please wait...', 'Name', 'Pre-processing...');

hy = fspecial('sobel'); % for gradient filter
hx = hy';               % for gradient filter
switch handles.mode
    case 'mode2dRadio'
        img = squeeze(handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, NaN, col_channel, getDataOptions));   % get dataset
        if binVal(1) ~= 1   % bin data
            img = resizeVolume(img, [binHeight, binWidth, max(thick)-min(thick)+1], 'bicubic');
        end
        if invertImage == 1
            img = imcomplement(img);
        end
        handles.preprocImg = zeros([size(img,1), size(img,2),size(img,3)], 'uint8');
        no_stacks = size(img,3);
        
        for sliceId=1:no_stacks
            if gradientSw == 1 && eigenSw == 1
                Iy = imfilter(double(img(:,:,sliceId)), hy, 'replicate');
                Ix = imfilter(double(img(:,:,sliceId)), hx, 'replicate');
                gradImg = sqrt(Ix.^2 + Iy.^2);
                img(:,:,sliceId) = uint8(gradImg/max(max(max(gradImg)))*255);   % convert to 8bit
                
                [Dxx, Dxy, Dyy] = Hessian2D(double(img(:,:,sliceId)), eigenSigma);
                [~,Lambda1,~,~]=eig2image(Dxx, Dxy, Dyy);
                minVal = min(min(Lambda1));
                maxVal = max(max(Lambda1));
                img(:,:,sliceId) = uint8((Lambda1-minVal)/(maxVal-minVal)*255);
                invertImage = 1;
            elseif gradientSw == 1 && eigenSw == 0
                Iy = imfilter(double(img(:,:,sliceId)), hy, 'replicate');
                Ix = imfilter(double(img(:,:,sliceId)), hx, 'replicate');
                gradImg = sqrt(Ix.^2 + Iy.^2);
                img(:,:,sliceId) = uint8(gradImg/max(max(max(gradImg)))*255);   % convert to 8bit
                invertImage = 0;
            elseif gradientSw == 0 && eigenSw == 1
                [Dxx, Dxy, Dyy] = Hessian2D(double(img(:,:,sliceId)), eigenSigma);
                [~,Lambda1,~,~]=eig2image(Dxx, Dxy, Dyy);
                minVal = min(min(Lambda1));
                maxVal = max(max(Lambda1));
                img(:,:,sliceId) = uint8((Lambda1-minVal)/(maxVal-minVal)*255);
                invertImage = abs(invertImage - 1);
            end
            if invertImage == 1
                img = imcomplement(img);
            end
            
            waitbar(sliceId/no_stacks, wb);
        end
    case 'mode2dCurrentRadio'
        img = squeeze(handles.h.Img{handles.h.Id}.I.getSlice('image', NaN, NaN, col_channel, NaN, getDataOptions));   % get slice
        if binVal(1) ~= 1   % bin data
            img = imresize(img, [binHeight binWidth], 'bicubic');
        end
        
        handles.preprocImg = zeros(size(img), 'uint8');
        
        if gradientSw == 1 && eigenSw == 1
            Iy = imfilter(double(img), hy, 'replicate');
            Ix = imfilter(double(img), hx, 'replicate');
            gradImg = sqrt(Ix.^2 + Iy.^2);
            img = uint8(gradImg/max(max(max(gradImg)))*255);   % convert to 8bit
            
            [Dxx, Dxy, Dyy] = Hessian2D(double(img), eigenSigma);
            [~,Lambda1,~,~]=eig2image(Dxx, Dxy, Dyy);
            minVal = min(min(Lambda1));
            maxVal = max(max(Lambda1));
            img = uint8((Lambda1-minVal)/(maxVal-minVal)*255);
            invertImage = 1;
        elseif gradientSw == 1 && eigenSw == 0
            Iy = imfilter(double(img), hy, 'replicate');
            Ix = imfilter(double(img), hx, 'replicate');
            gradImg = sqrt(Ix.^2 + Iy.^2);
            img = uint8(gradImg/max(max(max(gradImg)))*255);   % convert to 8bit
            invertImage = 0;
        elseif gradientSw == 0 && eigenSw == 1
            [Dxx, Dxy, Dyy] = Hessian2D(double(img), eigenSigma);
            [~,Lambda1,~,~]=eig2image(Dxx, Dxy, Dyy);
            minVal = min(min(Lambda1));
            maxVal = max(max(Lambda1));
            img = uint8((Lambda1-minVal)/(maxVal-minVal)*255);
            invertImage = abs(invertImage - 1);
        end
        
        if invertImage == 1
            img = imcomplement(img);
        end
        waitbar(.8, wb);
    case 'mode3dRadio'
        img = squeeze(handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, 4, col_channel, getDataOptions));   % get dataset
        if binVal(1) ~= 1 || binVal(2) ~= 1
            img = resizeVolume(img, [binHeight, binWidth, binThick], 'bicubic');
        end
        
        handles.preprocImg = zeros(size(img), 'uint8');
        waitbar(0.05, wb);
        if gradientSw == 1 && eigenSw == 1
            waitbar(0.05, wb, sprintf('Calculating gradient image...\nPlease wait...'));
            [Ix,Iy,Iz] = gradient(double(img));
            img = sqrt(Ix.^2 + Iy.^2 + Iz.^2);
            %img = uint8(img/max(max(max(img)))*255);   % convert to 8bit
            waitbar(0.45, wb, sprintf('Calculating Hessian 3D...\nPlease wait...'));
            
            [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(img, eigenSigma);
            waitbar(0.75, wb, sprintf('Calculation of eigen values...\nPlease wait...'));
            [~,~,Lambda3]=eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
            minVal = min(min(min(Lambda3)));
            maxVal = max(max(max(Lambda3)));
            img = uint8((Lambda3-minVal)/(maxVal-minVal)*255);
            invertImage = 1;
        elseif gradientSw == 1 && eigenSw == 0
            waitbar(0.05, wb, sprintf('Calculating gradient image...\nPlease wait...'));
            [Ix,Iy,Iz] = gradient(double(img));
            img = sqrt(Ix.^2 + Iy.^2 + Iz.^2);
            img = uint8(img/max(max(max(img)))*255);   % convert to 8bit
            invertImage = 0;
        elseif gradientSw == 0 && eigenSw == 1
            waitbar(0.45, wb, sprintf('Calculating Hessian 3D...\nPlease wait...'));
            [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(double(img), eigenSigma);
            waitbar(0.75, wb, sprintf('Calculation of eigen values...\nPlease wait...'));
            [~,~,Lambda3]=eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
            minVal = min(min(min(Lambda3)));
            maxVal = max(max(max(Lambda3)));
            img = uint8((Lambda3-minVal)/(maxVal-minVal)*255);
            invertImage = abs(invertImage - 1);
        end
        
        waitbar(0.8, wb);
        if invertImage == 1
            img = imcomplement(img);
        end
        waitbar(0.9, wb);
end

handles.preprocImg = img;

if get(handles.previewCheck,'value')
    if size(handles.preprocImg,3) == 1
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 1, handles.preprocImg);
    else
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 1, handles.preprocImg(:,:,handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber()));
    end
end

if get(handles.exportPreprocessCheck,'value')
    assignin('base','preprocImg',handles.preprocImg);
    text1 = sprintf('MIB-Watershed: a variable "preprocImg" [%d x %d x %d] with the preprocessed data has been created!', size(handles.preprocImg,1), size(handles.preprocImg,2), size(handles.preprocImg,3));
    disp(text1);
end

set(handles.preprocessBtn, 'backgroundcolor', 'g');
waitbar(1, wb);
delete(wb);
% Update handles structure
guidata(hObject, handles);
end

function imgOut = resizeVolume(img, newDims, method)
% function imgOut = resizeVolume(img, newDims, method)
% Function to resize the volume
% Parameters:
% img: original 3D volume [1:height, 1:width, 1:thickness]
% newDims: a vector with new dimensions [height, width, z]
% method: method to use: 'nearest', 'linear', 'bicubic'
% Return values:
% imgOut: resized 3D volume [1:newDims(1), 1:newDims(2), 1:newDims(3)]


newH = newDims(1);
newW = newDims(2);
newZ = newDims(3);

currH = size(img,1);
currW = size(img,2);
currZ = size(img,3);

imgOut = zeros(newH, newW, newZ, class(img));

% resize xy dimension
if newW ~= currW || newH ~= currH
    imgOut2 = zeros([newH, newW, currZ], class(img));
    for zIndex = 1:currZ
        imgOut2(:, :, zIndex) = imresize(img(:, :, zIndex), [newH newW], method);
    end
end
if newZ ~= currZ
    if exist('imgOut2','var') == 0
        imgOut2 = img;
    end;
    if size(imgOut2, 1)*1.82 < size(imgOut2, 2)
        for hIndex = 1:newH
            imgOut(hIndex,:,:) = imresize(squeeze(imgOut2(hIndex, :, :)), [newW newZ], method);
        end
    else
        for wIndex = 1:newW
            imgOut(:,wIndex,:) = imresize(squeeze(imgOut2(:, wIndex, :)), [newH newZ], method);
        end
    end
else
    imgOut = imgOut2;
end

end


% --- Executes on button press in watershedBtn.
function watershedBtn_Callback(hObject, eventdata, handles)
% do backup
tic
% define type of the objects to backup
handles.h = guidata(handles.h.im_browser);
if get(handles.imageSegmentationToggle, 'value') || get(handles.graphCutToggle, 'value')
    type = 'mask';
else
    type = 'selection';
end

% backup current data
if ~strcmp(handles.mode, 'mode2dCurrentRadio')
    ib_do_backup(handles.h, type, 1);
else
    ib_do_backup(handles.h, type, 0);
end

% select and start watershed
if get(handles.imageSegmentationToggle, 'value')
    doImageSegmentation(handles);
    handles.h.Img{handles.h.Id}.I.maskExist = 1;
    set(handles.h.maskShowCheck, 'value', 1);
elseif get(handles.graphCutToggle, 'value')
    doGraphcutSegmentation(handles);
    handles.h.Img{handles.h.Id}.I.maskExist = 1;
    set(handles.h.maskShowCheck, 'value', 1);
else
    doObjectSeparation(handles);
end
toc
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end

function doGraphcutSegmentation(handles)
% get super pixels and graph
graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
if isempty(graphcut.noPix)
    superpixelsBtn_Callback(handles.superpixelsBtn, [], handles);
    graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
end

wb = waitbar(0, sprintf('Graphcut segmentation...\nPlease wait...'), 'Name', 'Maxflow/Mincut');
bgMaterialId = get(handles.backgroundMateriaPopup, 'value');    % index of the background label
seedMaterialId = get(handles.signalMateriaPopup, 'value');    % index of the signal label
noMaterials = numel(get(handles.signalMateriaPopup, 'string'));    % number of materials in the model

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

if handles.h.Img{handles.h.Id}.I.maskExist == 0
    handles.h.Img{handles.h.Id}.I.clearMask();   % clear or delete mask for uint8 model type
end

if get(handles.mode2dCurrentRadio, 'value')
    seedImg = handles.h.Img{handles.h.Id}.I.getSlice('model', NaN, NaN, NaN, NaN, getDataOptions);   % get slice
    
    % tweak to work also with a current view mode
    if size(graphcut.slic, 3) > 1
        sliceNo = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
        currSlic = graphcut.slic(:,:,sliceNo);
    else
        currSlic = graphcut.slic;
        sliceNo = 1;
    end
    
    if binVal(1) ~= 1   % bin data
        seedImg = imresize(seedImg, [binHeight binWidth], 'nearest');
    end
    
%     if noMaterials > 2  % when more than 2 materials present keep only background and color
%         seedImg(seedImg~=seedMaterialId & seedImg~=0) = bgMaterialId;
%     end
    
    labelObj = unique(currSlic(seedImg==seedMaterialId));
    if isempty(labelObj); delete(wb); return; end;
    labelBg = unique(currSlic(seedImg==bgMaterialId));
    
    if graphcut.superPixType == 2 && strcmp(graphcut.dilateMode, 'post')  % watershed
        % remove 0 indices
        labelObj(labelObj==0) = [];
        labelBg(labelBg==0) = [];
    end
    
    % generate data term
    waitbar(.45, wb, sprintf('Generating data term\nPlease wait...'));
    T = zeros([graphcut.noPix(sliceNo), 2])+0.5;
    % remove from labelBg those that are also found in labelObj
    labelBg(ismember(labelBg, labelObj)) = [];
    
    T(labelObj, 1) = 0;        T(labelObj, 2) = 99999;
    T(labelBg,  1) = 99999;      T(labelBg,  2) = 0;
    
    T=sparse(T);
    
    %hView = view(biograph(handles.graphcut.Graph{sliceNo},[],'ShowArrows','off','ShowWeights','on'));
    %set(hView.Nodes(labelObj), 'color',[0 1 0]);
    %set(hView.Nodes(labelBg), 'color',[1 0 0]);
    
    [~, labels] = maxflow_v222(graphcut.Graph{sliceNo}, T);
    
    Mask = zeros(size(seedImg),'uint8');
    % % using ismembc instead of ismember because it is a bit faster
    % % however, the vertcut with known indeces of pixels is ~x10 times
    % faster!
    % indexLabel = find(labels>0);
    % Mask(ismember(double(currSlic), indexLabel)) = 1;
    if isfield(graphcut, 'PixelIdxList')
        Mask(vertcat(graphcut.PixelIdxList{1}{labels>0})) = 1;
    else
        indexLabel = find(labels>0);
        if isa(currSlic, 'uint8')
            indexLabel = uint8(indexLabel);
        elseif isa(currSlic, 'uint16')
            indexLabel = uint16(indexLabel);
        else
            indexLabel = uint32(indexLabel);
        end
        %Mask(ismembc(currSlic, indexLabel)) = 1;
        Mask(ismember(currSlic, indexLabel)) = 1;
    end
    Mask(seedImg==bgMaterialId) = 0;    % remove background pixels
    
    % remove boundaries between superpixels
    if graphcut.superPixType == 2 && strcmp(graphcut.dilateMode, 'post')  % watershed
        Mask = imdilate(Mask, ones(3));
    end
    
    if binVal(1) ~= 1   % bin data
        Mask = imresize(Mask, [max(height)-min(height)+1, max(width)-min(width)+1], 'nearest');
    end
    handles.h.Img{handles.h.Id}.I.setSlice('mask', Mask, NaN, NaN, NaN, NaN, getDataOptions);   % set slice
elseif get(handles.mode2dRadio, 'value')
    index = 1;
    startIndex = min(thick);
    endIndex = max(thick);
    total = endIndex-startIndex+1;
    for sliceNo = startIndex:endIndex
        seedImg = handles.h.Img{handles.h.Id}.I.getSlice('model', sliceNo, NaN, NaN, NaN, getDataOptions);   % get slice
        
        if binVal(1) ~= 1   % bin data
            seedImg = imresize(seedImg, [binHeight binWidth], 'nearest');
        end
        %if noMaterials > 2  % when more than 2 materials present keep only background and color
        %    seedImg(seedImg~=seedMaterialId & seedImg~=bgMaterialId) = 0;
        %end
        currSlic = graphcut.slic(:,:,index);
        labelObj = unique(currSlic(seedImg==seedMaterialId));
        if isempty(labelObj); index = index + 1; continue; end;
        labelBg = unique(currSlic(seedImg==bgMaterialId));
        
        if graphcut.superPixType == 2 && strcmp(graphcut.dilateMode, 'post')  % watershed
            % remove 0 indices
            labelObj(labelObj==0) = [];
            labelBg(labelBg==0) = [];
        end
        
        % remove from labelBg those that are also found in labelObj
        labelBg(ismember(labelBg, labelObj)) = [];
        
        % generate data term
        T = zeros([graphcut.noPix(index), 2])+0.5;
        T(labelObj, 1) = 0;
        T(labelObj, 2) = 99999;
        T(labelBg, 1) = 99999;
        T(labelBg, 2) = 0;
        T=sparse(T);
        
        %[~, labels] = maxflow(graphcut.Graph{index}, T);
        [~, labels] = maxflow_v222(graphcut.Graph{index}, T);
        
        Mask = zeros(size(seedImg),'uint8');
        % % using ismembc instead of ismember because it is a bit faster
        % % however, the vertcut with known indeces of pixels is ~x10 times
        % faster!
        % indexLabel = find(labels>0);
        % Mask(ismember(double(currSlic), indexLabel)) = 1;
        if isfield(graphcut, 'PixelIdxList')
            Mask(vertcat(graphcut.PixelIdxList{index}{labels>0})) = 1;
        else
            indexLabel = find(labels>0);
            if isa(currSlic, 'uint8')
                indexLabel = uint8(indexLabel);
            elseif isa(currSlic, 'uint16')
                indexLabel = uint16(indexLabel);
            else
                indexLabel = uint32(indexLabel);
            end
            %Mask(ismembc(currSlic, indexLabel)) = 1;
            Mask(ismember(currSlic, indexLabel)) = 1;
        end
        
        Mask(seedImg==bgMaterialId) = 0;    % remove background pixels
        
        % remove boundaries between superpixels
        if graphcut.superPixType == 2 && strcmp(graphcut.dilateMode, 'post')  % watershed
            Mask = imdilate(Mask, ones(3));
        end
        
        if binVal(1) ~= 1   % bin data
            Mask = imresize(Mask, [max(height)-min(height)+1, max(width)-min(width)+1], 'nearest');
        end
        handles.h.Img{handles.h.Id}.I.setSlice('mask', Mask, sliceNo, NaN, NaN, NaN, getDataOptions);   % set slice
        waitbar(index/total, wb, sprintf('Calculating...\nPlease wait...'));
        index = index + 1;
    end
else        % do it for 3D
    seedImg = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, NaN, getDataOptions);   % get dataset
    if binVal(1) ~= 1 || binVal(2) ~= 1
        waitbar(.05, wb, sprintf('Binning the labels\nPlease wait...'));
        seedImg = resizeVolume(seedImg, [binHeight, binWidth, binThick], 'nearest');
    end
    
%     if noMaterials > 2  % when more than 2 materials present keep only background and color
%         seedImg(seedImg~=seedMaterialId & seedImg~=0) = bgMaterialId;
%     end
    
    % define labeled object
    waitbar(.35, wb, sprintf('Definfing the labels\nPlease wait...'));
    [labelObj, ~, countL] = unique(graphcut.slic(seedImg==seedMaterialId));     % countL can be used to count number of occurances as
    [labelBg, ~, countBg] = unique(graphcut.slic(seedImg==bgMaterialId));       % numel(find(countL==IndexOfSuperpixel)))
    
     if graphcut.superPixType == 2 && strcmp(graphcut.dilateMode, 'post')   % watershed
        % remove 0 indices
        labelObj(labelObj==0) = [];
        labelBg(labelBg==0) = [];
    end
    
    % when two labels intersect in one supervoxel, prefer the one that
    % has larger number of occurances
    [commonVal, bgIdx] = intersect(labelBg, labelObj);  % find indices of the intersection supervoxels
    labelIdx = find(ismember(labelObj, commonVal));
    
    for comId = 1:numel(commonVal)
        if numel(find(countL==labelIdx(comId))) > numel(find(countBg==bgIdx(comId)))
            labelBg(labelBg==commonVal(comId)) = [];
        else
            labelObj(labelObj==commonVal(comId)) = [];
        end
    end
    
    % OLD CODE that gives preference to label
    % remove from labelBg those that are also found in labelObj
    %labelBg(ismember(labelBg, labelObj)) = [];
    
    % generate data term
    waitbar(.45, wb, sprintf('Generating data term\nPlease wait...'));
    T = zeros([graphcut.noPix, 2])+0.5;
    T(labelObj, 1) = 0;
    T(labelObj, 2) = 999999;
    T(labelBg, 1) = 999999;
    T(labelBg, 2) = 0;
    
    %T(labelObj, 2) = 0;
    %T(labelObj, 1) = 999999;
    %T(labelBg, 2) = 999999;
    %T(labelBg, 1) = 0;
       
    T=sparse(T);   
%     % testing BK_matlab
%     T = T';
%     h = BK_Create();
%     BK_AddVars(h, graphcut.noPix);
%     BK_SetNeighbors(h, graphcut.Graph{1});
%     BK_SetUnary(h, T);
%     e = BK_Minimize(h);
%     labels = BK_GetLabeling(h);
%     BK_Delete(h);
    
    waitbar(.55, wb, sprintf('Doing maxflow/mincut\nPlease wait...'));
    %[~, labels] = maxflow(graphcut.Graph{1}, T);
    [~, labels] = maxflow_v222(graphcut.Graph{1}, T);
        
    waitbar(.75, wb, sprintf('Generating the mask\nPlease wait...'));
    
    Mask = zeros(size(seedImg),'uint8');
    % % alternative ~35% slower
    %indexLabel = find(labels>0);
    %Mask(ismember(double(graphcut.slic), find(labels>0))) = 1;
    
    % % using ismembc instead of ismember because it is a bit faster
    % % however, the vertcut with known indeces of pixels is ~x10 times
    % faster!
    % unfortunately it takes a lot of space to keep the indices of
    % supervoxels
    if isfield(graphcut, 'PixelIdxList')
        Mask(vertcat(graphcut.PixelIdxList{1}{labels>0})) = 1;
    else
        indexLabel = find(labels>0);
        %indexLabel = find(labels==1); % test of BK_matlab
        if isa(graphcut.slic, 'uint8')
            indexLabel = uint8(indexLabel);
        elseif isa(graphcut.slic, 'uint16')
            indexLabel = uint16(indexLabel);
        else
            indexLabel = uint32(indexLabel);
        end
        %Mask(ismembc(graphcut.slic, indexLabel)) = 1;
        Mask(ismember(graphcut.slic, indexLabel)) = 1;
    end
    
    % remove boundaries between superpixels
    if graphcut.superPixType == 2 && strcmp(graphcut.dilateMode, 'post')  % watershed
        Mask = imdilate(Mask, ones([3 3 3]));
    end
    
    %Mask(seedImg==bgMaterialId) = 0;    % remove background pixels
    %Mask(seedImg==seedMaterialId) = 1;    % add label pixels
        
    if binVal(1) ~= 1 || binVal(2) ~= 1
        waitbar(.95, wb, sprintf('Re-binning the mask\nPlease wait...'));
        Mask = resizeVolume(Mask, [max(height)-min(height)+1, max(width)-min(width)+1, max(thick)-min(thick)+1], 'nearest');
    end
    handles.h.Img{handles.h.Id}.I.setData3D('mask', Mask, NaN, 4, NaN, getDataOptions);   % set dataset
end
delete(wb);
end

function doImageSegmentation(handles)
wb = waitbar(0, sprintf('Image segmentation...\nPlease wait...'), 'Name', 'Image segmentation');
col_channel = get(handles.imageColChPopup, 'value');
bgMaterialId = get(handles.backgroundMateriaPopup, 'value');    % index of the background label
seedMaterialId = get(handles.signalMateriaPopup, 'value');    % index of the signal label
noMaterials = numel(get(handles.signalMateriaPopup, 'string'));    % number of materials in the model
preprocImgNaN = 0;  % switch to remove temporary preprocImg later
invertImage = get(handles.signalPopup, 'value');    % if == 1 image should be inverted, black-on-white

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

if handles.h.Img{handles.h.Id}.I.maskExist == 0
    handles.h.Img{handles.h.Id}.I.clearMask();   % clear or delete mask for uint8 model type
end

switch handles.mode
    case 'mode2dCurrentRadio'
        if isnan(handles.preprocImg(1)) % get image is it was not pre-processed
            img = handles.h.Img{handles.h.Id}.I.getSlice('image', NaN, NaN, col_channel, NaN, getDataOptions);   % get slice
            if binVal(1) ~= 1   % bin data
                img = imresize(img, [binHeight binWidth], 'bicubic');
            end
            waitbar(.1, wb);
            if invertImage == 1
                img = imcomplement(img);
            end
            preprocImgNaN = 1;  % switch to remove temporary preprocImg later
            handles.preprocImg = squeeze(img);
            clear img;
        end
        %seedImg = ib_getSlice('model', handles.h, NaN, NaN);   % get model of labels
        seedImg = handles.h.Img{handles.h.Id}.I.getSlice('model', NaN, NaN, NaN, NaN, getDataOptions);   % get slice
        
        if binVal(1) ~= 1   % bin data
            seedImg = imresize(seedImg, [binHeight binWidth], 'nearest');
        end
        
        if noMaterials > 2  % when more than 2 materials present keep only background and color
            seedImg(seedImg~=seedMaterialId & seedImg~=bgMaterialId) = 0;
        end
        waitbar(.2, wb);
        % modify the image so that the background pixels and the extended
        % maxima pixels are forced to be the only local minima in the image.
        W = imimposemin(handles.preprocImg, seedImg);
        
        waitbar(.4, wb);
        W = watershed(W);
        if isa(W,'dip_image')
            warndlg(sprintf('!!! Warning !!!\n\nThis tool requires watershed function of Matlab. It seems that the currenly used function is coming from the dip-lib library!\n\nTo fix, place the dip-lib directory to the bottom of the Matlab path:\nMatlab->Home->Set path->Highlight directories containing DIPimage->Move to Bottom->Save'),'Wrong watershed');
            delete(wb);
            return;
        end
        waitbar(.5, wb);
        
        bgIndex = unique(W(seedImg==bgMaterialId));   % indeces of the background in the watershed regions
        W(ismember(W, bgIndex)) = 0; % make background 0
        W(W>1) = 1; % make objects
        if isa(W,'uint8') == 0;
            W = uint8(W);
        end;   % convert to 8bit if neeeded
        waitbar(.7, wb);
        % fill the gaps between the objects
        se = strel('rectangle', [3 3]);
        W = imdilate(W, se);
        W = imerode(W, se);
        waitbar(.9, wb);
        if binVal(1) ~= 1   % bin data
            W = imresize(W, [max(height)-min(height)+1, max(width)-min(width)+1], 'nearest');
        end
        handles.h.Img{handles.h.Id}.I.setSlice('mask', W, NaN, NaN, NaN, NaN, getDataOptions);   % set slice
    case 'mode2dRadio'
        if isnan(handles.preprocImg(1)) % get image is it was not pre-processed
            img = handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, NaN, col_channel, getDataOptions);   % get dataset
            if binVal(1) ~= 1   % bin data
                img2 = zeros([binHeight, binWidth, 1, size(img,4)],class(img));
                for sliceId=1:size(img, 4)
                    img2(:,:,:,sliceId) = imresize(img(:,:,:,sliceId), [binHeight binWidth], 'bicubic');
                end
                img = img2;
                clear img2;
            end
            if invertImage == 1
                img = imcomplement(img);
            end
            preprocImgNaN = 1;  % switch to remove temporary preprocImg later
            handles.preprocImg = squeeze(img);
            clear img;
        end
        seedImg = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, NaN, NaN, getDataOptions);   % get dataset
        if binVal(1) ~= 1   % bin model
            img2 = zeros([binHeight, binWidth, size(seedImg,3)],class(seedImg));
            for sliceId=1:size(seedImg, 3)
                img2(:,:,sliceId) = imresize(seedImg(:,:,sliceId), [binHeight binWidth], 'nearest');
            end
            seedImg = img2;
            clear img2;
        end
        
        if noMaterials > 2  % when more than 2 materials present keep only background and color
            seedImg(seedImg~=seedMaterialId & seedImg~=bgMaterialId) = 0;
        end
        
        no_stacks = size(handles.preprocImg,3);
        realSliceIndex = getDataOptions.z(1):getDataOptions.z(2);   % generate list of slice indeces
        for sliceId=1:no_stacks
            % skip if seeds are not present
            if max(max(seedImg(:,:,sliceId))) == 0;  continue; end;
            
            % modify the image so that the background pixels and the extended
            % maxima pixels are forced to be the only local minima in the image.
            W = imimposemin(handles.preprocImg(:,:,sliceId), seedImg(:,:,sliceId));
            W = watershed(W);
            
            bgIndex = unique(W(seedImg(:,:,sliceId)==bgMaterialId));   % indeces of the background in the watershed regions
            W(ismember(W, bgIndex)) = 0; % make background 0
            W(W>1) = 1; % make objects
            if isa(W,'uint8') == 0; W = uint8(W); end;   % convert to 8bit if neeeded
            
            % fill the gaps between the objects
            se = strel('rectangle', [3 3]);
            W = imdilate(W, se);
            W = imerode(W, se);
            if binVal(1) ~= 1   % re-bin mask
                W = imresize(W, [max(height)-min(height)+1, max(width)-min(width)+1], 'nearest');
            end
            handles.h.Img{handles.h.Id}.I.setSlice('mask', W, realSliceIndex(sliceId), NaN, NaN, NaN, getDataOptions);   % set slice
            waitbar(sliceId/no_stacks, wb);
        end
    case 'mode3dRadio'
        if isnan(handles.preprocImg(1)) % get image is it was not pre-processed
            img = squeeze(handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, 4, col_channel, getDataOptions));   % get dataset
            % bin dataset
            if binVal(1) ~= 1 || binVal(2) ~= 1
                waitbar(.05, wb, sprintf('Binning the image\nPlease wait...'));
                img = resizeVolume(img, [binHeight, binWidth, binThick], 'bicubic');
            end
            
            if invertImage == 1
                waitbar(.1, wb, sprintf('Inverting the image\nPlease wait...'));
                img = imcomplement(img);
            end
            preprocImgNaN = 1;  % switch to remove temporary preprocImg later
            handles.preprocImg = img;
            clear img;
        end
        seedImg = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, NaN, getDataOptions);   % get dataset
        if binVal(1) ~= 1 || binVal(2) ~= 1
            waitbar(.15, wb, sprintf('Binning the labels\nPlease wait...'));
            seedImg = resizeVolume(seedImg, [binHeight, binWidth, binThick], 'nearest');
        end
        
        if noMaterials > 2  % when more than 2 materials present keep only background and color
            seedImg(seedImg~=seedMaterialId & seedImg~=bgMaterialId) = 0;
        end
        
        % modify the image so that the background pixels and the extended
        % maxima pixels are forced to be the only local minima in the image.
        waitbar(.2, wb, sprintf('Imposing minima\nPlease wait...'));
        W = imimposemin(handles.preprocImg, seedImg);
        waitbar(.3, wb, sprintf('Computing the watershed regions\nPlease wait...'));
        W = watershed(W);
        waitbar(.7, wb, sprintf('Removing background\nPlease wait...'));
        bgIndex = unique(W(seedImg==bgMaterialId));   % indeces of the background in the watershed regions
        W(ismember(W, bgIndex)) = 0; % make background 0
        W(W>1) = 1; % make objects
        if isa(W,'uint8')==0; W = uint8(W); end;   % convert to 8bit if neeeded
        
        waitbar(.9, wb, sprintf('Filling gaps between objects\nPlease wait...'));
        % fill the gaps between the objects
        se = ones([3 3 3]);
        W = imdilate(W, se);
        W = imerode(W, se);
        if binVal(1) ~= 1 || binVal(2) ~= 1
            waitbar(.95, wb, sprintf('Re-binning the mask\nPlease wait...'));
            W = resizeVolume(W, [max(height)-min(height)+1, max(width)-min(width)+1, max(thick)-min(thick)+1], 'nearest');
        end
        handles.h.Img{handles.h.Id}.I.setData3D('mask', W, NaN, 4, NaN, getDataOptions);   % set dataset
end
waitbar(1, wb);
% restore handles.preprocImg state
if preprocImgNaN
    handles.preprocImg = NaN;
end
delete(wb);
end


function doObjectSeparation(handles)
wb = waitbar(0, sprintf('Object separation\nPlease wait...'), 'Name', 'Object separation...');
aspect = str2num(get(handles.aspectRatio, 'string')); %#ok<ST2NM>
col_channel = get(handles.imageIntensityColorCh, 'value');
invertImage = get(handles.imageIntensityInvert, 'value');    % if == 1 image should be inverted, black-on-white

% get area for processing
width = str2num(get(handles.xSubareaEdit, 'String')); %#ok<ST2NM>
height = str2num(get(handles.ySubareaEdit, 'String'));  %#ok<ST2NM>
thick = str2num(get(handles.zSubareaEdit, 'String'));  %#ok<ST2NM>
% fill structure to use with getSlice and getDataset methods
getDataOptions.x = [min(width) max(width)];
getDataOptions.y = [min(height) max(height)];
getDataOptions.z = [min(thick) max(thick)];
if strcmp(handles.mode, 'mode2dCurrentRadio')   % limit z for the current slice only mode
    currentSliceIndex = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
    getDataOptions.z = [currentSliceIndex currentSliceIndex];
end

% calculate image size after binning
binVal = str2num(get(handles.binSubareaEdit, 'string'));     %#ok<ST2NM> % vector to bin the data binVal(1) for XY and binVal(2) for Z
binWidth = ceil((max(width)-min(width)+1)/binVal(1));
binHeight = ceil((max(height)-min(height)+1)/binVal(1));
binThick = ceil((max(thick)-min(thick)+1)/binVal(2));

% define source of the objects and seeds
modelId = NaN;
seedModelId = NaN;
if get(handles.selectionRadio, 'value') == 1
    inputType = 'selection';
elseif get(handles.maskRadio, 'value') == 1
    inputType = 'mask';
elseif get(handles.modelRadio, 'value') == 1
    inputType = 'model';
    modelId = get(handles.selectedMaterialPopup, 'value');
end

if get(handles.seedsSelectionRadio, 'value') == 1
    seedType = 'selection';
elseif get(handles.seedsMaskRadio, 'value') == 1
    seedType = 'mask';
elseif get(handles.seedsModelRadio, 'value') == 1
    seedType = 'model';
    seedModelId = get(handles.seedsSelectedMaterialPopup, 'value');
end

if get(handles.useSeedsCheck, 'value')  % use seeded watershed, modified from http://blogs.mathworks.com/steve/2006/06/02/cell-segmentation/
    if strcmp(handles.mode, 'mode3dRadio')  % do watershed for 3D objects
        img = handles.h.Img{handles.h.Id}.I.getData3D(inputType, NaN, 4, modelId, getDataOptions);   % get image with objects to watershed
        seedImg = squeeze(handles.h.Img{handles.h.Id}.I.getData3D(seedType, NaN, 4, seedModelId, getDataOptions));   % get image with seeds
        if get(handles.intensityRadio, 'value')
            intImg = squeeze(handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, 4, col_channel, getDataOptions));   % get image of the specified color channel to use instead of distance map
        end
        % bin dataset
        if binVal(1) ~= 1 || binVal(2) ~= 1
            waitbar(.05, wb, sprintf('Binning the data\nPlease wait...'));
            img = resizeVolume(img, [binHeight, binWidth, binThick], 'nearest');
            seedImg = resizeVolume(seedImg, [binHeight, binWidth, binThick], 'nearest');
            if exist('intImg', 'var')
                intImg = resizeVolume(intImg, [binHeight, binWidth, binThick], 'bicubic');
            end
            aspect(1) = aspect(1)*binVal(1);
            aspect(2) = aspect(2)*binVal(1);
            aspect(3) = aspect(3)*binVal(2);
        end
        % invert image with intensities
        if invertImage == 1 && get(handles.intensityRadio, 'value')
            waitbar(.07, wb, sprintf('Complementing the image\nPlease wait...'));
            intImg = imcomplement(intImg); % complement the image so that the peaks become valleys.
        end
        
        if get(handles.intensityRadio, 'value')
            waitbar(.1, wb, sprintf('Updating local minima\nPlease wait...'));
            W = imimposemin(intImg, ~img | seedImg);
            clear intImg;
        else
            waitbar(.1, wb, sprintf('Computing the distance transform\nPlease wait...'));
            W = bwdistsc(~img, aspect);
            waitbar(.3, wb, sprintf('Complementing the image\nPlease wait'));
            W = -W;
            
            waitbar(.35, wb, sprintf('Generating the local minima\nPlease wait...'));
            % replace the following to eliminate 1 pixel shrinkage of
            % the objects. Use: W = imimposemin(W, seedImg);
            % W = imimposemin(W, ~img | seedImg);
            W = imimposemin(W, seedImg);
        end
        waitbar(.5, wb, sprintf('Computing the watershed regions\nPlease wait...'));
        W = watershed(W);
        
        waitbar(.7, wb, sprintf('Removing background\nPlease wait...'));
        W(~img) = 0;
        
        % have to calculate the connected components because some objects without
        % the seeds have indeces equal to those that have seeds
        waitbar(.75, wb, sprintf('Relabeling the objects\nPlease wait...'));
        W = bwlabeln(W);
        
        waitbar(.85, wb, sprintf('Generating resulting image\nPlease wait...'));
        objInd = unique(W(seedImg~=0));
        W = uint8(ismember(W,objInd));
        
        if binVal(1) ~= 1 || binVal(2) ~= 1
            %waitbar(.95, wb, sprintf('Re-binning the mask\nPlease wait...'));
            W = resizeVolume(W, [max(height)-min(height)+1, max(width)-min(width)+1, max(thick)-min(thick)+1], 'nearest');
        end
        handles.h.Img{handles.h.Id}.I.setData3D('selection', W, NaN, 4, NaN, getDataOptions);   % set dataset
        waitbar(1, wb, sprintf('Done!'));
    else
        noSlices = getDataOptions.z(2)-getDataOptions.z(1)+1;
        for sliceId=getDataOptions.z(1):getDataOptions.z(2)
            img = handles.h.Img{handles.h.Id}.I.getSlice(inputType, sliceId, NaN, modelId, NaN, getDataOptions);   % get slice with objects to watershed
            seedImg = handles.h.Img{handles.h.Id}.I.getSlice(seedType, sliceId, NaN, seedModelId, NaN, getDataOptions);   % get slice with objects to watershed
            if max(max(seedImg)) == 0; continue; end;    % skip when no seeds
            if get(handles.intensityRadio, 'value')
                intImg = handles.h.Img{handles.h.Id}.I.getSlice('image', sliceId, NaN, col_channel, NaN, getDataOptions);   % get slice with objects to watershed
            end
            
            % bin dataset if needed
            if binVal(1) ~= 1 || binVal(2) ~= 1
                %waitbar(.15, wb, sprintf('Binning the labels\nPlease wait...'));
                img = imresize(img, [binHeight binWidth], 'nearest');
                seedImg = imresize(seedImg, [binHeight binWidth], 'nearest');
                if exist('intImg', 'var')
                    intImg = imresize(intImg, [binHeight binWidth], 'bicubic');
                end
            end
            
            
            % invert image with intensities
            if invertImage == 1 && get(handles.intensityRadio, 'value')
                % waitbar(.05, wb, sprintf('Complementing image\nPlease wait'));
                intImg = imcomplement(intImg); % complement the image so that the peaks become valleys.
            end
            if get(handles.intensityRadio, 'value')
                W = imimposemin(intImg, ~img | seedImg);
                %W = imimposemin(intImg, seedImg);
            else
                W = bwdistsc(~img, [aspect(1) aspect(2)]);
                W = -W;
                
                % replace the following to eliminate 1 pixel shrinkage of
                % the objects. Use: W = imimposemin(W, seedImg);
                %W = imimposemin(W, ~img | seedImg);
                W = imimposemin(W, seedImg);
            end
            W = watershed(W);
            W(~img) = 0;
            
            % have to calculate the connected components because some objects without
            % the seeds have indeces equal to those that have seeds
            W = bwlabeln(W);
            
            objInd = unique(W(seedImg~=0));
            W = uint8(ismember(W,objInd));
            
            if binVal(1) ~= 1   % re-bin mask
                W = imresize(W, [max(height)-min(height)+1, max(width)-min(width)+1], 'nearest');
            end
            handles.h.Img{handles.h.Id}.I.setSlice('selection', W, sliceId, NaN, NaN, NaN, getDataOptions);   % set slice
            waitbar((sliceId-getDataOptions.z(1))/noSlices, wb, sprintf('Please wait...'));
        end
        
    end
else    % standard shape watershed
    reduiceOversegmCheck = get(handles.reduiceOversegmCheck, 'value');
    if strcmp(handles.mode, 'mode3dRadio')  % do watershed for 3D objects
        img = squeeze(handles.h.Img{handles.h.Id}.I.getData3D(inputType, NaN, 4, modelId, getDataOptions));   % get image with objects to watershed
        % bin dataset
        if binVal(1) ~= 1 || binVal(2) ~= 1
            waitbar(.05, wb, sprintf('Binning the dataset\nPlease wait...'));
            img = resizeVolume(img, [binHeight, binWidth, binThick], 'nearest');
            aspect(1) = aspect(1)*binVal(1);
            aspect(2) = aspect(2)*binVal(1);
            aspect(3) = aspect(3)*binVal(2);
        end
        waitbar(.2, wb, sprintf('Computing the distance transform\nPlease wait...'));
        D = bwdistsc(~img, aspect);   % compute the distance transform of the complement of the binary image.
        D = -D;     % complement the distance transform
        
        if reduiceOversegmCheck
            waitbar(.4, wb, sprintf('Reducing oversegmentation\nPlease wait...'));
            % few extra steps to reduce oversegmentation, suggested at
            % http://blogs.mathworks.com/steve/2013/11/19/watershed-transform-question-from-tech-support/
            mask = imextendedmin(D,2);
            D = imimposemin(D,mask);
        end
        
        waitbar(.6, wb, sprintf('Computing the watershed regions\nPlease wait...'));
        D = uint8(watershed(D)); % do watershed
        
        waitbar(.85, wb, sprintf('Generating resulting image\nPlease wait...'));
        D(~img) = 0;
        D(D>1) = 1;     % flatten the result
        if binVal(1) ~= 1 || binVal(2) ~= 1
            %waitbar(.95, wb, sprintf('Re-binning the mask\nPlease wait...'));
            D = resizeVolume(D, [max(height)-min(height)+1, max(width)-min(width)+1, max(thick)-min(thick)+1], 'nearest');
        end
        handles.h.Img{handles.h.Id}.I.setData3D('selection', D, NaN, 4, NaN, getDataOptions);   % set dataset
        waitbar(1, wb, sprintf('Done!'));
    else
        noSlices = getDataOptions.z(2)-getDataOptions.z(1)+1;
        for sliceId=getDataOptions.z(1):getDataOptions.z(2)
            img = handles.h.Img{handles.h.Id}.I.getSlice(inputType, sliceId, NaN, modelId, NaN, getDataOptions);   % get slice with objects to watershed
            if binVal(1) ~= 1 || binVal(2) ~= 1
                %waitbar(.15, wb, sprintf('Binning the labels\nPlease wait...'));
                img = imresize(img, [binHeight binWidth], 'nearest');
            end
            
            % calculate distance transform
            W = bwdistsc(~img, [aspect(1) aspect(2)]);
            W = -W;     % complement the distance transform
            
            if reduiceOversegmCheck
                % few extra steps to reduce oversegmentation, suggested at
                % http://blogs.mathworks.com/steve/2013/11/19/watershed-transform-question-from-tech-support/
                mask = imextendedmin(W,2);
                W = imimposemin(W,mask);
            end
            
            W = uint8(watershed(W)); % do watershed
            W(~img) = 0;
            W(W>1) = 1;     % flatten the result
            
            if binVal(1) ~= 1   % re-bin mask
                W = imresize(W, [max(height)-min(height)+1, max(width)-min(width)+1], 'nearest');
            end
            handles.h.Img{handles.h.Id}.I.setSlice('selection', W, sliceId, NaN, NaN, NaN, getDataOptions);   % set slice
            waitbar((sliceId-getDataOptions.z(1))/noSlices, wb, sprintf('Please wait...'));
        end
    end
end
delete(wb);
end


% --- Executes on button press in importBtn.
function importBtn_Callback(hObject, eventdata, handles)
%options.Resize='on';
%answer = inputdlg({'Enter variable containing preprocessed image (h:w:color:index):'},'Import image',1,{'I'},options);
answer = mib_inputdlg(handles.h, 'Enter variable containing preprocessed image (h:w:color:index):', 'Import image', 'I');
if size(answer) == 0; return; end;

try
    img = evalin('base',answer{1});
catch exception
    errordlg(sprintf('The variable was not found in the Matlab base workspace:\n\n%s', exception.message),'Misssing variable!','modal');
    return;
end
if isstruct(img); img = img.data; end;  % check for Amira structures

% check dimensions
% get area for processing
width = str2num(get(handles.xSubareaEdit, 'String'));
height = str2num(get(handles.ySubareaEdit, 'String'));
thick = str2num(get(handles.zSubareaEdit, 'String'));

% calculate image size after binning
binVal = str2num(get(handles.binSubareaEdit, 'string'));     % vector to bin the data binVal(1) for XY and binVal(2) for Z
binWidth = ceil((max(width)-min(width)+1)/binVal(1));
binHeight = ceil((max(height)-min(height)+1)/binVal(1));
binThick = ceil((max(thick)-min(thick)+1)/binVal(2));

[~, ~, ~, t] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4);
% convert to 3D
% get desired color channel
col_channel = get(handles.imageColChPopup, 'value');
if ndims(img) == 4 && size(img, 3) > 1
    img = squeeze(img(:,:,col_channel,:));
elseif ndims(img) == 4 && size(img, 3) == 1
    img = squeeze(img);
elseif size(img, 3) > 1 && t==1
    img = img(:, :, col_channel);
end

% take a single slice from 3D stack
if size(img, 3) ~= 1 && strcmp(handles.mode,'mode2dCurrentRadio')
    currentSliceNumber = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
    img = img(:,:,currentSliceNumber);
    binThick = 1;
    thick = 1;
end

% check dimensions
if size(img,1) ~= binHeight || size(img,2) ~= binWidth || size(img,3) ~= binThick
    try
        img = img(height(1):height(end), width(1):width(end),thick(1):thick(end));
    catch err
        errordlg('Wrong dimensions!','Error');
        return;
    end
    % resize the volume
    switch handles.mode
        case 'mode2dRadio'
            if binVal(1) ~= 1   % bin data
                img = resizeVolume(img, [binHeight, binWidth, max(thick)-min(thick)+1], 'bicubic');
            end
        case 'mode2dCurrentRadio'
            if binVal(1) ~= 1   % bin data
                img = imresize(img, [binHeight binWidth], 'bicubic');
            end
        case 'mode3dRadio'
            if binVal(1) ~= 1 || binVal(2) ~= 1
                img = resizeVolume(img, [binHeight, binWidth, binThick], 'bicubic');
            end
    end
end

% invert image
invertImage = get(handles.signalPopup, 'value');    % if == 1 image should be inverted, black-on-white
if invertImage == 1
    img = imcomplement(img);
end

handles.preprocImg = img;
set(handles.preprocessBtn, 'backgroundcolor', 'g');
guidata(handles.ib_watershedGui, handles);  % store handles
end


% --- Executes on button press in superpixelsBtn.
function superpixelsBtn_Callback(hObject, eventdata, handles)
tic
superPixType = get(handles.superpixTypePopup,'value');  % 1-SLIC, 2-Watershed
if superPixType == 1
    wb = waitbar(0, sprintf('Initiating...\nPlease wait...'), 'Name', 'SLIC superpixels/supervoxels');
else
    wb = waitbar(0, sprintf('Initiating...\nPlease wait...'), 'Name', 'Watershed superpixels/supervoxels');
end
clearPreprocessBtn_Callback(handles.clearPreprocessBtn, eventdata, handles);
handles = guidata(handles.ib_watershedGui);

col_channel = get(handles.imageColChPopup, 'value');
superpixelSize = str2double(get(handles.superpixelEdit,'string'));
superpixelCompact = str2double(get(handles.superpixelsCompactEdit, 'string'));
blackOnWhite = get(handles.signalPopup, 'value');       % black ridges over white background
watershedReduce = str2double(get(handles.superpixelsReduceEdit,'string'));  % factor to reduce oversegmentation by watershed

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

graphcut.dilateMode = 'post'; 

tilesX =  str2double(get(handles.chopXedit, 'String'));  % calculate supervoxels for the chopped datasets
tilesY =  str2double(get(handles.chopYedit, 'String'));

% check for autosave
if get(handles.supervoxelsAutosaveCheck, 'value')
    fn_out = handles.h.Img{handles.h.Id}.I.img_info('Filename');
    dotIndex = strfind(fn_out,'.');
    if ~isempty(dotIndex)
        fn_out = fn_out(1:dotIndex(end)-1);
    end
    if isempty(strfind(fn_out,'/')) && isempty(strfind(fn_out,'\'))
        fn_out = fullfile(handles.mypath, fn_out);
    end
    if isempty(fn_out)
        fn_out = handles.mypath;
    end
    Filters = {'*.graph;',  'Matlab format (*.graph)'};
    
    [filename, path, FilterIndex] = uiputfile(Filters, 'Save Graph...',fn_out); %...
    if isequal(filename,0); delete(wb); return; end; % check for cancel
    fn_out = fullfile(path, filename);
end

switch handles.mode
    case 'mode2dCurrentRadio'
        img = handles.h.Img{handles.h.Id}.I.getSlice('image', NaN, NaN, col_channel, NaN, getDataOptions);   % get slice
        if binVal(1) ~= 1   % bin data
            img = imresize(img, [binHeight binWidth], 'bicubic');
        end
        
        % convert to 8bit
        currViewPort = handles.h.Img{handles.h.Id}.I.viewPort;
        if isa(img, 'uint16')
            if get(handles.h.liveStretchCheck, 'value')   % on fly mode
                img = imadjust(img ,stretchlim(img,[0 1]),[]);
            else
                img = imadjust(img, [currViewPort.min(col_channel)/65535 currViewPort.max(col_channel)/65535],[0 1],currViewPort.gamma(col_channel));
            end
            img = uint8(img/255);
        else
            if currViewPort.min(col_channel) > 1 || currViewPort.max(col_channel) < 255
                img = imadjust(img, [currViewPort.min(col_channel)/255 currViewPort.max(col_channel)/255],[0 1],currViewPort.gamma(col_channel));
            end
        end
        
        dims = size(img);
        if superPixType == 1     % generate SLIC superpixels 
            waitbar(.05, wb, sprintf('Calculating SLIC superpixels...\nPlease wait...'));
            % calculate number of supervoxels
            graphcut.noPix = ceil(dims(1)*dims(2)/superpixelSize);
        
            [graphcut.slic, graphcut.noPix] = slicmex(img, graphcut.noPix, superpixelCompact);
            graphcut.noPix = double(graphcut.noPix);
            % remove superpixel with 0-index
            graphcut.slic = graphcut.slic + 1;
            % a new procedure imRAG that is few times faster
            %STATS = regionprops(graphcut.slic, img, 'MeanIntensity','PixelIdxList');
            STATS = regionprops(graphcut.slic, img, 'MeanIntensity');
            gap = 0;    % regions are connected, no gap in between
            graphcut.Edges{1} = imRAG(graphcut.slic, gap);
            graphcut.Edges{1} = double(graphcut.Edges{1});
            
            graphcut.EdgesValues{1} = zeros([size(graphcut.Edges{1},1), 1]);
            meanVals = [STATS.MeanIntensity];
            
            for i=1:size(graphcut.Edges{1},1)
                %EdgesValues(i) = 255/(abs(meanVals(Edges(i,1))-meanVals(Edges(i,2)))+.00001);     % should be low (--> 0) at the edges of objects
                graphcut.EdgesValues{1}(i) = abs(meanVals(graphcut.Edges{1}(i,1))-meanVals(graphcut.Edges{1}(i,2)));     % should be low (--> 0) at the edges of objects
            end
            
            waitbar(.9, wb, sprintf('Calculating weights for boundaries...\nPlease wait...'));
            setappdata(handles.ib_watershedGui, 'graphcut', graphcut);
            recalcGraph_Callback(hObject, eventdata, handles);
            graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
        else    % generate WATERSHED superpixels
            if blackOnWhite == 1
                img = imcomplement(img);    % convert image that the ridges are white
            end
            
            mask = imextendedmin(img, watershedReduce);
            mask = imimposemin(img, mask);

            graphcut.slic = watershed(mask);       % generate superpixels
            [graphcut.Edges{1}, edgeIndsList] = imRichRAG(graphcut.slic);
            % calculate mean of intensities at the borders between each superpixel
            graphcut.EdgesValues{1} = cell2mat(cellfun(@(idx) mean(img(idx)), edgeIndsList, 'UniformOutput', 0)); 
           
            setappdata(handles.ib_watershedGui, 'graphcut', graphcut);
            recalcGraph_Callback(hObject, eventdata, handles);
            graphcut = getappdata(handles.ib_watershedGui, 'graphcut');

            graphcut.noPix = max(graphcut.slic(:));
            % two modes for dilation: 'pre' and 'post'
            % in 'pre' the superpixels are dilated before the graphcut
            % segmentation, i.e. in this function
            % in 'post' the superpixels are dilated after the graphcut
            % segmentation
            graphcut.dilateMode = 'post';  
            if strcmp(graphcut.dilateMode, 'pre')
                graphcut.slic = imdilate(graphcut.slic, ones(3));
            end
            %STATS = regionprops(graphcut.slic, 'PixelIdxList');
        end
        %graphcut.PixelIdxList{1} = {STATS.PixelIdxList};
    case 'mode2dRadio'
        img = handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, NaN, col_channel, getDataOptions);   % get dataset
        if binVal(1) ~= 1   % bin data
            waitbar(.05, wb, sprintf('Binning the images\nPlease wait...'));
            img2 = zeros([binHeight, binWidth, 1, size(img,4)],class(img));
            for sliceId=1:size(img, 4)
                img2(:,:,:,sliceId) = imresize(img(:,:,:,sliceId), [binHeight binWidth], 'bicubic');
            end
            img = img2;
            clear img2;
        end
        img = squeeze(img);
        
        % convert to 8bit and adjust contrast
        currViewPort = handles.h.Img{handles.h.Id}.I.viewPort;
        if isa(img, 'uint16')
            if get(handles.h.liveStretchCheck, 'value')   % on fly mode
                for sliceId=1:size(img, 3)
                    img(:,:,sliceId) = imadjust(img(:,:,sliceId) ,stretchlim(img(:,:,sliceId),[0 1]),[]);
                end
            else
                for sliceId=1:size(img, 3)
                    img(:,:,sliceId) = imadjust(img(:,:,sliceId), [currViewPort.min(col_channel)/65535 currViewPort.max(col_channel)/65535],[0 1],currViewPort.gamma(col_channel));
                end
            end
            img = uint8(img/255);
        else
            if currViewPort.min(col_channel) > 1 || currViewPort.max(col_channel) < 255
                for sliceId=1:size(img, 3)
                    img(:,:,sliceId) = imadjust(img(:,:,sliceId), [currViewPort.min(col_channel)/255 currViewPort.max(col_channel)/255],[0 1],currViewPort.gamma(col_channel));
                end   
            end
        end
        
        % calculate number of superpixels
        dims = size(img);
        if numel(dims) == 2; dims(3) = 1; end;
        graphcut.slic = zeros(size(img));
        graphcut.noPix = zeros([size(img,3), 1]);
        if superPixType == 1     % generate SLIC superpixels
            noPix = ceil(dims(1)*dims(2)/superpixelSize);
            
            for i=1:dims(3)
                [graphcut.slic(:,:,i), noPixCurrent] = slicmex(img(:,:,i), noPix, superpixelCompact);
                graphcut.noPix(i) = double(noPixCurrent);
                % remove superpixel with 0-index
                graphcut.slic(:,:,i) = graphcut.slic(:,:,i) + 1;
                
                % a new procedure imRAG that is few times faster
                %STATS = regionprops(graphcut.slic(:,:,i), img(:,:,i), 'MeanIntensity','PixelIdxList');
                STATS = regionprops(graphcut.slic(:,:,i), img(:,:,i), 'MeanIntensity');
                gap = 0;    % regions are connected, no gap in between
                Edges = imRAG(graphcut.slic(:,:,i), gap);
                Edges = double(Edges);
                
                EdgesValues = zeros([size(Edges,1), 1]);
                meanVals = [STATS.MeanIntensity];
            
                for j=1:size(Edges,1)
                    %EdgesValues(i) = 255/(abs(meanVals(Edges(i,1))-meanVals(Edges(i,2)))+.00001);     % should be low (--> 0) at the edges of objects
                    EdgesValues(j) = abs(meanVals(Edges(j,1))-meanVals(Edges(j,2)));     % should be low (--> 0) at the edges of objects
                end
                
                graphcut.Edges{i} = Edges;
                graphcut.EdgesValues{i} = EdgesValues;
                waitbar(i/dims(3), wb, sprintf('Calculating...\nPlease wait...'));
            end
            
            setappdata(handles.ib_watershedGui, 'graphcut', graphcut);
            recalcGraph_Callback(hObject, eventdata, handles);
            graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
            
        else % generate WATERSHED superpixels
            if blackOnWhite == 1
                img = imcomplement(img);    % convert image that the ridges are white
            end
            for i=1:dims(3)
                currImg = img(:,:,i);
                mask = imextendedmin(currImg, watershedReduce);
                mask = imimposemin(currImg, mask);
                graphcut.slic(:,:,i) = watershed(mask);       % generate superpixels
                
                % this call seems to be faster for 2D than using 
                % [Edges, EdgesValues] = imRichRAG(graphcut.slic(:,:,i), 1, currImg);
                [graphcut.Edges{i}, edgeIndsList] = imRichRAG(graphcut.slic(:,:,i));
                % calculate mean of intensities at the borders between each superpixel
                graphcut.EdgesValues{i} = cell2mat(cellfun(@(idx) mean(currImg(idx)), edgeIndsList, 'UniformOutput', 0)); 
                graphcut.Edges{i} = double(graphcut.Edges{i});
                graphcut.noPix(i) = double(max(max(graphcut.slic(:,:,i))));
                
                % two modes for dilation: 'pre' and 'post'
                % in 'pre' the superpixels are dilated before the graphcut
                % segmentation, i.e. in this function
                % in 'post' the superpixels are dilated after the graphcut
                % segmentation
                graphcut.dilateMode = 'post';  
                if strcmp(graphcut.dilateMode, 'pre')
                    graphcut.slic = imdilate(graphcut.slic(:,:,i), ones(3));
                end
                waitbar(i/dims(3), wb, sprintf('Calculating...\nPlease wait...'));
            end
            setappdata(handles.ib_watershedGui, 'graphcut', graphcut);
            recalcGraph_Callback(hObject, eventdata, handles);
            graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
        end
    case 'mode3dRadio'
        img = squeeze(handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, 4, col_channel, getDataOptions));   % get dataset
        % bin dataset
        if binVal(1) ~= 1 || binVal(2) ~= 1
            waitbar(.05, wb, sprintf('Binning the dataset\nPlease wait...'));
            img = resizeVolume(img, [binHeight, binWidth, binThick], 'bicubic');
        end
        
        % convert to 8bit
        currViewPort = handles.h.Img{handles.h.Id}.I.viewPort;
        if isa(img, 'uint16')
            if get(handles.h.liveStretchCheck, 'value')   % on fly mode
                for sliceId=1:size(img, 3)
                    img(:,:,sliceId) = imadjust(img(:,:,sliceId) ,stretchlim(img(:,:,sliceId),[0 1]),[]);
                end
            else
                for sliceId=1:size(img, 3)
                    img(:,:,sliceId) = imadjust(img(:,:,sliceId), [currViewPort.min(col_channel)/65535 currViewPort.max(col_channel)/65535],[0 1],currViewPort.gamma(col_channel));
                end
            end
            img = uint8(img/255);
        else
            if currViewPort.min(col_channel) > 1 || currViewPort.max(col_channel) < 255
                for sliceId=1:size(img, 3)
                    img(:,:,sliceId) = imadjust(img(:,:,sliceId), [currViewPort.min(col_channel)/255 currViewPort.max(col_channel)/255],[0 1],currViewPort.gamma(col_channel));
                end
            end
        end
        
        % calculate number of supervoxels
        dims = size(img);
        if superPixType == 1     % generate SLIC superpixels 
            graphcut.noPix = ceil(dims(1)*dims(2)*dims(3)/superpixelSize);
        
            % calculate supervoxels
            waitbar(.05, wb, sprintf('Calculating  %d SLIC supervoxels\nPlease wait...', graphcut.noPix));
            
            if tilesX > 1 || tilesY > 1
                [height, width, depth] = size(img);
                graphcut.slic = zeros([height width depth], 'int32');
                noPix = 0;
                
                xStep = ceil(width/tilesX);
                yStep = ceil(height/tilesY);    
                for x=1:tilesX
                    for y=1:tilesY
                        yMin = (y-1)*yStep+1;
                        yMax = min([(y-1)*yStep+yStep, height]);
                        xMin = (x-1)*xStep+1;
                        xMax = min([(x-1)*xStep+xStep, width]);
                       
                        [slicChop, noPixChop] = slicsupervoxelmex_byte(img(yMin:yMax, xMin:xMax, :), round(graphcut.noPix/(tilesX*tilesY)), superpixelCompact);    
                        graphcut.slic(yMin:yMax, xMin:xMax, :) = slicChop + noPix + 1;   % +1 to remove zero supervoxels
                        noPix = noPixChop + noPix;
                    end
                end
                graphcut.noPix = double(noPix);
            else
                [graphcut.slic, graphcut.noPix] = slicsupervoxelmex_byte(img, graphcut.noPix, superpixelCompact);    
                graphcut.noPix = double(graphcut.noPix);
                % remove superpixel with 0-index
                graphcut.slic = graphcut.slic + 1;
            end
        
            % calculate adjacent matrix for labels
            waitbar(.25, wb, sprintf('Calculating MeanIntensity for labels\nPlease wait...'));
            %STATS = regionprops(graphcut.slic, img, 'MeanIntensity','BoundingBox','PixelIdxList');
            STATS = regionprops(graphcut.slic, img, 'MeanIntensity');
        
            waitbar(.3, wb, sprintf('Calculating adjacent matrix for labels\nPlease wait...'));

            % a new procedure imRAG that is up to 10 times faster
            gap = 0;    % regions are connected, no gap in between
            graphcut.Edges{1} = imRAG(graphcut.slic, gap);
            graphcut.Edges{1} = double(graphcut.Edges{1});
            
            graphcut.EdgesValues{1} = zeros([size(graphcut.Edges{1},1), 1]);
            meanVals = [STATS.MeanIntensity];
            
            for i=1:size(graphcut.Edges{1},1)
%                 knownId = 2088;
%                 if i==knownId
%                     0;
%                     vInd = find(Edges(:,1)==knownId);   % indices of edges
%                     vInd2 = find(Edges(:,2)==knownId);   % indices of edges
%                     vInd = sort([vInd; vInd2]);
%                     [vInd, Edges(vInd,1), Edges(vInd,2)];  % connected superpixels
%                 end
                graphcut.EdgesValues{1}(i) = abs(meanVals(graphcut.Edges{1}(i,1))-meanVals(graphcut.Edges{1}(i,2)));     % should be low (--> 0) at the edges of objects
            end
            setappdata(handles.ib_watershedGui, 'graphcut', graphcut);
            recalcGraph_Callback(hObject, eventdata, handles);
            graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
        else    % generate WATERSHED supervoxels
            if blackOnWhite == 1
                waitbar(.05, wb, sprintf('Complementing the image\nPlease wait...'));
                img = imcomplement(img);    % convert image that the ridges are white
            end
            waitbar(.1, wb, sprintf('Extended-minima transform\nPlease wait...'));
            if watershedReduce > 0
                mask = imextendedmin(img, watershedReduce);
                waitbar(.15, wb, sprintf('Impose minima\nPlease wait...'));
                mask = imimposemin(img, mask);
                waitbar(.2, wb, sprintf('Calculating watershed\nPlease wait...'));
                graphcut.slic = watershed(mask);       % generate supervoxels
            else
                waitbar(.2, wb, sprintf('Calculating watershed\nPlease wait...'));
                graphcut.slic = watershed(img);       % generate supervoxels
            end
            waitbar(.7, wb, sprintf('Calculating adjacency graph\nPlease wait...'));
            
            % calculate adjacency matrix and mean intensity between each
            % two adjacent supervoxels
            [graphcut.Edges{1}, graphcut.EdgesValues{1}] = imRichRAG(graphcut.slic, 1, img);   
            graphcut.noPix = double(max(max(max(graphcut.slic))));
            
            waitbar(.9, wb, sprintf('Generating the final graph\nPlease wait...'));
            % two modes for dilation: 'pre' and 'post'
            % in 'pre' the superpixels are dilated before the graphcut
            % segmentation, i.e. in this function
            % in 'post' the superpixels are dilated after the graphcut
            % segmentation
            graphcut.dilateMode = 'pre';  
            if strcmp(graphcut.dilateMode, 'pre')
                graphcut.slic = imdilate(graphcut.slic, ones([3 3 3]));
            end
            %STATS = regionprops(graphcut.slic, 'PixelIdxList');
            setappdata(handles.ib_watershedGui, 'graphcut', graphcut);
            recalcGraph_Callback(hObject, eventdata, handles);
            graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
        end
end

% convert to a proper class, to uint8 if below 255
if max(graphcut.noPix) < 256
    graphcut.slic = uint8(graphcut.slic);
elseif max(graphcut.noPix) < 65536
    graphcut.slic = uint16(graphcut.slic);
elseif max(graphcut.noPix) < 4294967295
    graphcut.slic = uint32(graphcut.slic);
end

graphcut.bb = [getDataOptions.x getDataOptions.y getDataOptions.z];   % store bounding box of the generated superpixels
graphcut.mode = handles.mode;     % store the mode for the calculated superpixels
graphcut.binVal = binVal;     % store the mode for the calculated superpixels
graphcut.colCh = col_channel;     % store color channel
graphcut.spSize = superpixelSize; % size of superpixels
graphcut.spCompact = superpixelCompact; % compactness of superpixels
graphcut.superPixType = superPixType;   % type of superpixels, 1-SLIC, 2-Watershed
graphcut.blackOnWhite = blackOnWhite;   % 1-when black ridges over white background
graphcut.watershedReduce = watershedReduce; % factor to reduce oversegmentation by watershed

if exist('fn_out', 'var')
    % autosaving results
    waitbar(.98, wb, sprintf('Saving Graphcut to a file\nPlease wait...'),'Name','Saving to a file');
    %Graphcut = rmfield(graphcut, 'PixelIdxList');   %#ok<NASGU> % remove the PixelIdxList to make save fast
    %Graphcut = graphcut; %#ok<NASGU>
    
    % remove of the Graph field for 2542540 supervoxels
    % makes saving faster by 5% and files smaller by 20%
    Graphcut = rmfield(graphcut, 'Graph');   %#ok<NASGU> % remove the PixelIdxList to make save fast
    save(fn_out, 'Graphcut', '-mat', '-v7.3');
    fprintf('MIB: saving graphcut structure to %s -> done!\n', fn_out);
end

waitbar(1, wb, sprintf('Done!'));
set(handles.superpixelsBtn, 'backgroundcolor', 'g');
set(handles.superpixelsCountText, 'string', sprintf('Superpixels count: %d', max(graphcut.noPix)));
guidata(handles.ib_watershedGui, handles);
setappdata(handles.ib_watershedGui, 'graphcut', graphcut);
delete(wb);
toc
end

% --- Executes on button press in exportSuperpixelsBtn.
function exportSuperpixelsBtn_Callback(hObject, eventdata, handles)
Graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
if isempty(Graphcut.noPix); return; end;

button =  questdlg(sprintf('Would you like to export preprocessed data to a file or the main Matlab workspace?'),'Export/Save SLIC','Save to a file','Export to Matlab','Cancel','Save to a file');
if strcmp(button, 'Cancel'); return; end;
if strcmp(button, 'Export to Matlab')
    title = 'Input variable to export';
    def = 'Graphcut';
    prompt = {'A variable for the measurements structure:'};
    answer = mib_inputdlg(handles.h, prompt,title,def);
    if size(answer) == 0; return; end;
    assignin('base', answer{1}, Graphcut);
    fprintf('MIB: export superpixel data ("%s") to Matlab -> done!\n', answer{1});
    return;
end
fn_out = handles.h.Img{handles.h.Id}.I.img_info('Filename');
dotIndex = strfind(fn_out,'.');
if ~isempty(dotIndex)
    fn_out = fn_out(1:dotIndex(end)-1);
end
if isempty(strfind(fn_out,'/')) && isempty(strfind(fn_out,'\'))
    fn_out = fullfile(handles.mypath, fn_out);
end
if isempty(fn_out)
    fn_out = handles.mypath;
end
Filters = {'*.graph;',  'Matlab format (*.graph)'};

[filename, path, FilterIndex] = uiputfile(Filters, 'Save Graph...',fn_out); %...
if isequal(filename,0); return; end; % check for cancel
fn_out = fullfile(path, filename);
wb = waitbar(0, sprintf('Saving Graphcut to a file\nPlease wait...'),'Name','Saving to a file');
tic

%Graphcut = rmfield(graphcut, 'PixelIdxList');   %#ok<NASGU> % remove the PixelIdxList to make save fast
Graphcut = rmfield(Graphcut, 'Graph');   %#ok<NASGU> % remove the PixelIdxList to make save fast
save(fn_out, 'Graphcut', '-mat', '-v7.3');

fprintf('MIB: saving graphcut structure to %s -> done!\n', fn_out);
toc
delete(wb);
end

% --- Executes on button press in importSuperpixelsBtn.
function importSuperpixelsBtn_Callback(hObject, eventdata, handles)
button =  questdlg(sprintf('Would you like to import Graphcut data from a file or from the main Matlab workspace?'),'Import/Load measurements','Load from a file','Import from Matlab','Cancel','Load from a file');
switch button
    case 'Cancel'
        return;
    case 'Import from Matlab'
        title = 'Input variables for import';
        prompt = 'A variable that contains compatible structure:';
        def = 'Graphcut';
        answer = mib_inputdlg(handles.h, prompt,title,def);
        if size(answer) == 0; return; end;
        tic;
        clearPreprocessBtn_Callback(handles.clearPreprocessBtn, 0, handles);
        
        try
            graphcut = evalin('base',answer{1});
        catch exception
            errordlg(sprintf('The variable was not found in the Matlab base workspace:\n\n%s', exception.message),'Missing variable!','modal');
            return;
        end
    case 'Load from a file'
        [filename, path] = uigetfile(...
            {'*.graph;',  'Matlab format (*.graph)'}, ...
            'Load Graphcut data...',handles.h.mypath);
        if isequal(filename, 0); return; end; % check for cancel
        wb = waitbar(0.05,sprintf('Loading preprocessed Graphcut\nPlease wait...'));
        tic;
        clearPreprocessBtn_Callback(handles.clearPreprocessBtn, 0, handles);
        
        res = load(fullfile(path, filename),'-mat');
        graphcut = res.Graphcut;
%           % comment this for a while due to bad memory performance with
%           large datasets
%         if ~isfield(graphcut, 'PixelIdxList')
%             % calculate PixelIdxList, to be fast during segmentation
%             waitbar(0.5, wb, sprintf('Calculating positions of superpixels\nPlease wait...'));
%             switch graphcut.mode
%                 case {'mode3dRadio', 'mode2dCurrentRadio'}
%                     STATS = regionprops(graphcut.slic, 'PixelIdxList');     
%                     graphcut.PixelIdxList{1} = {STATS.PixelIdxList};
%                 case 'mode2dRadio'
%                     for i=1:size(graphcut.slic,3)
%                         STATS = regionprops(graphcut.slic(:,:,i), 'PixelIdxList');    
%                         graphcut.PixelIdxList{i} = {STATS.PixelIdxList};
%                     end
%             end
%         end
        waitbar(.99, wb, sprintf('Finishing...\nPlease wait...'));
        delete(wb);
end

set(handles.xSubareaEdit, 'String', sprintf('%d:%d', graphcut.bb(1), graphcut.bb(2)));
set(handles.ySubareaEdit, 'String', sprintf('%d:%d', graphcut.bb(3), graphcut.bb(4)));
set(handles.zSubareaEdit, 'String', sprintf('%d:%d', graphcut.bb(5), graphcut.bb(6)));
set(handles.binSubareaEdit, 'string', sprintf('%d;%d', graphcut.binVal(1), graphcut.binVal(2)));
set(handles.imageColChPopup, 'value', graphcut.colCh);
if strcmp(graphcut.mode, 'mode3dRadio')
    set(handles.mode3dRadio, 'value', 1);
    handles.mode = 'mode3dRadio';
elseif strcmp(graphcut.mode, 'mode2dRadio')
    set(handles.mode2dRadio, 'value', 1);
    handles.mode = 'mode2dRadio';
else
    set(handles.mode2dCurrentRadio, 'value', 1);
    handles.mode = 'mode2dCurrentRadio';
end
if isfield(graphcut, 'scaleFactor'); set(handles.edgeFactorEdit, 'string', num2str(graphcut.scaleFactor)); end;

set(handles.superpixelEdit, 'string', num2str(graphcut.spSize));
set(handles.superpixelsCompactEdit, 'string', num2str(graphcut.spCompact));
if ~isfield(graphcut, 'superPixType'); graphcut.superPixType=1; end;
set(handles.superpixTypePopup,'value', graphcut.superPixType);  
if ~isfield(graphcut, 'blackOnWhite'); graphcut.blackOnWhite=1; end;
set(handles.signalPopup, 'value', graphcut.blackOnWhite);       
if ~isfield(graphcut, 'watershedReduce'); graphcut.watershedReduce=15; end;
set(handles.superpixelsReduceEdit,'string', num2str(graphcut.watershedReduce));  

setappdata(handles.ib_watershedGui, 'graphcut', graphcut);

% recalculate the Graph
if ~isfield(graphcut, 'Graph')
    recalcGraph_Callback(hObject, eventdata, handles, 1);
end

set(handles.superpixelsBtn, 'backgroundcolor', 'g');
set(handles.superpixelsCountText, 'string', sprintf('Superpixels count: %d', max(graphcut.noPix)));
superpixTypePopup_Callback(hObject, eventdata, handles, 'keep');
guidata(handles.ib_watershedGui, handles);  % store handles
toc
end


% --- Executes on button press in superpixelsPreviewBtn.
function superpixelsPreviewBtn_Callback(hObject, eventdata, handles)
graphcut = getappdata(handles.ib_watershedGui, 'graphcut');
if isempty(graphcut.noPix)
    return;
end

% get area for processing
width = str2num(get(handles.xSubareaEdit, 'String'));
height = str2num(get(handles.ySubareaEdit, 'String'));
thick = str2num(get(handles.zSubareaEdit, 'String'));
% fill structure to use with getSlice and getDataset methods
getDataOptions.x = [min(width) max(width)];
getDataOptions.y = [min(height) max(height)];
getDataOptions.z = [min(thick) max(thick)];

% calculate image size after binning
binVal = str2num(get(handles.binSubareaEdit, 'string'));     %#ok<ST2NM> % vector to bin the data binVal(1) for XY and binVal(2) for Z
binWidth = ceil((max(width)-min(width)+1)/binVal(1));
binHeight = ceil((max(height)-min(height)+1)/binVal(1));
binThick = ceil((max(thick)-min(thick)+1)/binVal(2));

switch handles.mode
    case 'mode2dCurrentRadio'
        if size(graphcut.slic, 3) > 1
            currSlic = graphcut.slic(:,:,handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber());
        else
            currSlic = graphcut.slic;
        end
        if binVal(1) ~= 1   % re-bin mask
            L2 = imresize(currSlic, [max(height)-min(height)+1, max(width)-min(width)+1], 'nearest');
            L2 = imdilate(L2,ones([3,3])) > L2;
        else
            L2 = imdilate(currSlic,ones([3,3])) > currSlic;
        end
        handles.h.Img{handles.h.Id}.I.setSlice('selection', L2, NaN, NaN, NaN, NaN, getDataOptions);   % set slice
    case 'mode2dRadio'
        if binVal(1) ~= 1   % re-bin mask
            L2 = resizeVolume(graphcut.slic, [max(height)-min(height)+1, max(width)-min(width)+1, max(thick)-min(thick)+1], 'nearest');
        else
            L2 = graphcut.slic;
        end
        for i=1:size(L2,3)
            L2(:,:,i) = imdilate(L2(:,:,i),ones([3,3],class(L2))) > L2(:,:,i);
        end
        handles.h.Img{handles.h.Id}.I.setData3D('selection', uint8(L2), NaN, 4, NaN, getDataOptions);   % set dataset
    case 'mode3dRadio'
        % [gx, gy, gz] = gradient(double(graphcut.slic));
        % L2 = zeros(size(graphcut.slic))+1;
        % L2((gx.^2+gy.^2+gz.^2)==0) = 0;
        
        %L2 = imdilate(graphcut.slic,ones([3,3,3])) > imerode(graphcut.slic,ones([1,1,1]));
        
        if binVal(1) ~= 1 || binVal(2) ~= 1
            L2 = resizeVolume(graphcut.slic, [max(height)-min(height)+1, max(width)-min(width)+1, max(thick)-min(thick)+1], 'nearest');
        else
            L2 = graphcut.slic;
        end
        
        L2 = imdilate(L2,ones([3,3,3])) > L2;
        handles.h.Img{handles.h.Id}.I.setData3D('selection', L2, NaN, 4, NaN, getDataOptions);   % set dataset
end
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end

function superpixelEdit_Callback(hObject, eventdata, handles)
clearPreprocessBtn_Callback(handles.clearPreprocessBtn, 0, handles);    % clear preprocessed data
end


% --- Executes on selection change in superpixTypePopup.
function superpixTypePopup_Callback(hObject, eventdata, handles, parameter)
if nargin < 4; parameter = 'clear'; end;     % clear preprocessed data
popupVal = get(handles.superpixTypePopup, 'value');
popupText = get(handles.superpixTypePopup, 'string');
set(handles.chopXedit, 'enable', 'off');
set(handles.chopYedit, 'enable', 'off');
if strcmp(popupText{popupVal}, 'SLIC')      % SLIC superpixels
    set(handles.compactnessText, 'enable', 'on');
    set(handles.superpixelsCompactEdit, 'enable', 'on');
    set(handles.superpixelSize, 'enable', 'on');
    set(handles.superpixelEdit, 'enable', 'on');
    set(handles.superpixelsReduceText, 'enable', 'off');
    set(handles.superpixelsReduceEdit, 'enable', 'off');
    if get(handles.mode3dRadio, 'value')
        set(handles.chopXedit, 'enable', 'on');
        set(handles.chopYedit, 'enable', 'on');
    end
else                                        % Watershed superpixels
    set(handles.compactnessText, 'enable', 'off');
    set(handles.superpixelsCompactEdit, 'enable', 'off');
    set(handles.superpixelSize, 'enable', 'off');
    set(handles.superpixelEdit, 'enable', 'off');
    set(handles.superpixelsReduceText, 'enable', 'on');
    set(handles.superpixelsReduceEdit, 'enable', 'on');
end
if ~strcmp(parameter, 'keep')
    clearPreprocessBtn_Callback(handles.clearPreprocessBtn, 0, handles);    % clear preprocessed data
end
end


% --- Executes on button press in recalcGraph.
function recalcGraph_Callback(hObject, eventdata, handles, showWaitbar)
% hObject    handle to recalcGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin < 4;    showWaitbar = 0; end;
graphcut = getappdata(handles.ib_watershedGui, 'graphcut');

if ~isfield(graphcut, 'EdgesValues')
    errordlg(sprintf('!!! Error !!!\n\nThe edges are missing!\nPlease press the Superpixels/Graph button to calculate them'));
    return;
end

if showWaitbar; wb = waitbar(0, sprintf('Calculating weights for boundaries...\nPlease wait...')); end;

graphcut.scaleFactor = str2double(get(handles.edgeFactorEdit, 'string'));
if showWaitbar; waitbar(.1, wb); end;

for i=1:numel(graphcut.EdgesValues)
    edgeMax = max(graphcut.EdgesValues{i});
    edgeMin = min(graphcut.EdgesValues{i});
    edgeVar = edgeMax-edgeMin;
    normE = graphcut.EdgesValues{i}/edgeVar;   % scale to 0-1 range
    EdgesValues = exp(-normE*graphcut.scaleFactor);  % should be low (--> 0) at the edges of objects

    if showWaitbar; waitbar(.5, wb); end;

    Edges2 = fliplr(graphcut.Edges{i});    % complement for both ways
    Edges = double([graphcut.Edges{i}; Edges2]);
    graphcut.Graph{i} = sparse(Edges(:,1), Edges(:,2), [EdgesValues EdgesValues]);
    if showWaitbar; waitbar(i/numel(graphcut.EdgesValues), wb); end;
end

if showWaitbar; waitbar(.9, wb); end;

setappdata(handles.ib_watershedGui, 'graphcut', graphcut);
if showWaitbar;     waitbar(1, wb);     delete(wb);  end;
end
