function varargout = ib_imageMorphOpsGui(varargin)
% function varargout = ib_imageMorphOpsGui(varargin)
% ib_imageMorphOpsGui function is responsible for morphological operations done with images.
%
% ib_imageMorphOpsGui contains MATLAB code for ib_imageMorphOpsGui.fig

% Copyright (C) 30.10.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 26.02.2016, IB, updated for 4D datasets


% Edit the above text to modify the response to help ib_imageMorphOpsGui

% Last Modified by GUIDE v2.5 30-Oct-2014 23:56:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ib_imageMorphOpsGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_imageMorphOpsGui_OutputFcn, ...
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

% --- Executes just before ib_imageMorphOpsGui is made visible.
function ib_imageMorphOpsGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_imageMorphOpsGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser
handles.type = varargin{2};    % type of morphological operation to perform

% define the current mode
handles.mode = 'mode2d_Slice'; % other modes mode2d_Stack, mode2d_Dataset, mode3d_Stack, mode3d_Dataset
handles.conn = 4;
handles.action = 'noneRadio';

% define radio buttons callbacks
set(handles.connectivityPanel, 'SelectionChangeFcn', @connectivityPanel_Callback);
set(handles.actionPanel, 'SelectionChangeFcn', @actionPanel_Callback);

% highlight desired operation in the list
list = get(handles.morphOpsPopup, 'String');
for i=1:numel(list)
    if strcmp(list{i}, handles.type)
        set(handles.morphOpsPopup, 'value', i);
        continue;
    end
end

% update font and size
if get(handles.infoText, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.infoText, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_imageMorphOpsGui, handles.h.preferences.Font);
end


% set background color to panels and texts
set(handles.ib_imageMorphOpsGui,'Color',[.831 .816 .784]);
tempList = findall(handles.ib_imageMorphOpsGui,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_imageMorphOpsGui,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_imageMorphOpsGui,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_imageMorphOpsGui,'Style','radiobutton');    % set color to radiobuttons
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_imageMorphOpsGui,'Type','uibuttongroup');    % set color to uibuttongroups
set(tempList,'BackgroundColor',[.831 .816 .784]);

updateWidgets(handles);
handles = guidata(handles.ib_imageMorphOpsGui);

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_imageMorphOpsGui);

% Choose default command line output for ib_imageMorphOpsGui
handles.output = NaN;

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
        FigPos(1:2) = [GCBFPos(1)-FigWidth-10 GCBFPos(2)+GCBFPos(4)-FigHeight+59];
    elseif GCBFPos(1) + GCBFPos(3) + FigWidth < screenSize(3) % put figure on the right side of the main figure
        FigPos(1:2) = [GCBFPos(1)+GCBFPos(3)+10 GCBFPos(2)+GCBFPos(4)-FigHeight+59];
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

% UIWAIT makes ib_imageMorphOpsGui wait for user response (see UIRESUME)
uiwait(handles.ib_imageMorphOpsGui);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_imageMorphOpsGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isstruct(handles)
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.ib_imageMorphOpsGui);
else
    varargout{1} = NaN;
end
end


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
handles.output = NaN;
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_imageMorphOpsGui);
end


% --- Executes on selection change in morphOpsPopup.
function morphOpsPopup_Callback(hObject, eventdata, handles)
list = get(handles.morphOpsPopup, 'string');
operationName = list{get(handles.morphOpsPopup, 'value')};
set(handles.strelShapePopup,'enable','on');
set(handles.strelSizeEdit,'enable','on');
set(handles.radio6, 'enable', 'off');
set(handles.radio18, 'enable', 'off');
set(handles.radio26, 'enable', 'off');
set(handles.modePopup, 'value', 1);
set(handles.modePopup, 'enable', 'off');

switch operationName
    case 'Bottom-hat filtering'
        infoText = 'Computes the morphological closing of the image (using imclose`) and then subtracts the result from the original image';
        handles.operationName = 'imbothat';
        set(handles.strelShapePopup, 'enable','on');
        set(handles.strelSizeEdit, 'enable','on');
    case 'Clear border'
        infoText = 'Suppresses light structures connected to image border';
        handles.operationName = 'imclearborder';
        set(handles.radio6, 'enable', 'on');
        set(handles.radio18, 'enable', 'on');
        set(handles.radio26, 'enable', 'on');
        set(handles.strelShapePopup,'enable','off');
        set(handles.strelSizeEdit,'enable','off');
        set(handles.modePopup, 'enable', 'on');
    case 'Morphological closing'
        infoText = 'Morphologically close image: a dilation followed by an erosion';
        handles.operationName = 'imclose';
    case 'Dilate image'
        infoText = 'Dilate image';
        handles.operationName = 'imdilate';
    case 'Erode image'
        infoText = 'Erode image';
        handles.operationName = 'imerode';
    case 'Fill regions'
        infoText = 'Fills holes in the image, where a hole is defined as an area of dark pixels surrounded by lighter pixels';
        handles.operationName = 'imfill';
        set(handles.modePopup, 'value', 1);
        set(handles.strelShapePopup,'enable','off');
        set(handles.strelSizeEdit,'enable','off');
    case 'H-maxima transform'
        infoText = 'Suppresses all maxima in the image whose height is less than H';
        handles.operationName = 'imhmax';
        set(handles.radio6, 'enable', 'on');
        set(handles.radio18, 'enable', 'on');
        set(handles.radio26, 'enable', 'on');
        set(handles.modePopup, 'enable', 'on');
    case 'H-minima transform'
        infoText = 'Suppresses all minima in the image whose depth is less than H';
        handles.operationName = 'imhmin';
        set(handles.radio6, 'enable', 'on');
        set(handles.radio18, 'enable', 'on');
        set(handles.radio26, 'enable', 'on');
        set(handles.modePopup, 'enable', 'on');
    case 'Morphological opening'
        infoText = 'Morphologically open image: an erosion followed by a dilation';
        handles.operationName = 'imopen';
    case 'Top-hat filtering'
        infoText = 'Computes the morphological opening of the image (using imopen) and then subtracts the result from the original image';
        handles.operationName = 'imtophat';
end
set(handles.infoText, 'string',infoText);
% load preview image
img = imread(fullfile(handles.h.pathMIB, 'Resources', [handles.operationName '.jpg']));  
image(img, 'parent', handles.previewAxes);
set(handles.previewAxes, ...
    'box'             , 'off', ...
    'xtick'           , [], ...
    'ytick'           , []);

guidata(handles.ib_imageMorphOpsGui, handles);
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end

function modePanel_Callback(hObject, eventdata, handles)
datasetPopupString = get(handles.datasetPopup, 'string');
datasetPopup = datasetPopupString{get(handles.datasetPopup, 'value')};

switch datasetPopup
    case '2D, Slice'
        handles.mode = '_Slice';
        set(handles.modePopup, 'value', 1);
    case '3D, Stack'
        handles.mode = '_Stack';
    case '4D, Dataset'
        handles.mode = '_Dataset';
end

modePopupString = get(handles.modePopup, 'string');
if iscell(modePopupString)
    modePopup = modePopupString{get(handles.modePopup, 'value')};
else
    modePopup = modePopupString;
end

if strcmp(modePopup, '2D')
    set(handles.radio6, 'String', '4');
    set(handles.radio18, 'String', '8');
    set(handles.radio26, 'Visible', 'off');
    set(handles.previewBtn, 'Enable', 'on');
    set(handles.smoothWidth, 'enable', 'on');
    set(handles.smoothSigma, 'enable', 'on');
    set(handles.autoPreviewCheck, 'enable','on');
    handles.mode = ['mode2d' handles.mode];
else
    set(handles.radio6, 'String', '6');
    set(handles.radio18, 'String', '18');
    set(handles.radio26, 'Visible', 'on');
    set(handles.previewBtn, 'Enable', 'off');
    set(handles.smoothWidth, 'enable', 'off');
    set(handles.smoothSigma, 'enable', 'off');
    set(handles.autoPreviewCheck, 'value',0);
    set(handles.autoPreviewCheck, 'enable','off');
    handles.mode = ['mode3d' handles.mode];
end

% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
guidata(hObject, handles);
end

function connectivityPanel_Callback(hObject, eventdata)
handles = guidata(hObject);
value = get(eventdata.NewValue, 'string');
handles.conn = str2double(value);
guidata(hObject, handles);   
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end

end

function actionPanel_Callback(hObject, eventdata)
handles = guidata(hObject);
handles.action = get(eventdata.NewValue, 'tag');
guidata(hObject, handles);   

% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end


function smoothWidth_Callback(hObject, eventdata, handles)
val = str2double(get(handles.smoothWidth, 'string'));
set(handles.smoothSigma,'string', num2str(val/5));
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end


function updateWidgets(handles)
handles.h = guidata(handles.h.im_browser);  % update handles 

% update the Mode panel
if handles.h.Img{handles.h.Id}.I.no_stacks < 2
    set(handles.radio26, 'visible', 'off');
    set(handles.datasetPopup, 'value', 1);
    set(handles.modePopup, 'value', 1);
    set(handles.modePopup, 'string', '2D');
else
    set(handles.radio26, 'enable', 'on');
end

% updating color channels
colList = get(handles.h.ColChannelCombo, 'string');
set(handles.colorChannelPopoup, 'string', colList(2:end));
set(handles.colorChannelPopoup, 'value', get(handles.h.ColChannelCombo, 'value')-1);

morphOpsPopup_Callback(handles.morphOpsPopup, NaN, handles);
end

function se = getStrelElement(handles)
strelShape = get(handles.strelShapePopup, 'value');     % 1-rectangle; 2-disk
se_size = str2num(get(handles.strelSizeEdit, 'string')); %#ok<ST2NM>

% when only 1 value - calculate the second from the pixSize
if ~isempty(strfind(handles.mode, 'mode3d_'))
    if numel(se_size) == 1
        se_size(2) = max([round(se_size(1)*handles.h.Img{handles.h.Id}.I.pixSize.x/handles.h.Img{handles.h.Id}.I.pixSize.z) 1]); % for z
    end
elseif numel(se_size) == 1
    se_size(2) = se_size(1);
end

if strelShape == 1  % rectangle
    if ~isempty(strfind(handles.mode, 'mode3d_'))
        se = ones([se_size(1), se_size(1), se_size(2)]);
    else
        se = strel('rectangle', [se_size(1), se_size(2)]);
    end
else                % disk
    if ~isempty(strfind(handles.mode, 'mode3d_'))
        se = zeros(se_size(1)*2+1,se_size(1)*2+1,se_size(2)*2+1);    % do strel ball type in volume
        [x,y,z] = meshgrid(-se_size(1):se_size(1),-se_size(1):se_size(1),-se_size(2):se_size(2));
        ball = sqrt((x/se_size(1)).^2+(y/se_size(1)).^2+(z/se_size(2)).^2);
        se(ball<=1) = 1;
    else
        se = strel('disk', se_size(1), 0);
    end
end
end

% --- Executes on selection change in colorChannelPopoup.
function colorChannelPopoup_Callback(hObject, eventdata, handles)
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end

function strelShapePopup_Callback(hObject, eventdata, handles)
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end

function strelSizeEdit_Callback(hObject, eventdata, handles)
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end

function multiplyEdit_Callback(hObject, eventdata, handles)
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end

function smoothSigma_Callback(hObject, eventdata, handles)
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end

function autoPreviewCheck_Callback(hObject, eventdata, handles)
% use auto preview
if get(handles.autoPreviewCheck, 'value') == 1
    previewBtn_Callback(hObject, eventdata, handles);
end
end

% --- Executes on button press in previewBtn.
function previewBtn_Callback(hObject, eventdata, handles)
colChannel = get(handles.colorChannelPopoup, 'value');
se = getStrelElement(handles);
hValue = str2num(get(handles.strelSizeEdit, 'string')); %#ok<ST2NM>
multiplyFactor = str2double(get(handles.multiplyEdit,'string'));
smoothWidth = str2double(get(handles.smoothWidth, 'string'));
smoothSigma = str2double(get(handles.smoothSigma, 'string'));

handles.h = guidata(handles.h.im_browser);

img = handles.h.Img{handles.h.Id}.I.getSliceToShow('image', NaN, NaN, colChannel);
switch handles.operationName
    case 'imbothat'
        Iout = imbothat(img,se);
    case 'imclearborder'
        Iout = imclearborder(img,handles.conn);
    case 'imclose'
        Iout = imclose(img,se);
    case 'imdilate'
        Iout = imdilate(img,se);
    case 'imerode'
        Iout = imerode(img,se);
    case 'imfill'
        Iout = imfill(img);
    case 'imhmax'
        Iout = imhmax(img,hValue(1),handles.conn);
    case 'imhmin'
        Iout = imhmin(img,hValue(1),handles.conn);
    case 'imopen'
        Iout = imopen(img,se);
    case 'imtophat'
        Iout = imtophat(img,se);
end

if smoothWidth > 0  % do gaussian filtering
    filter2d = fspecial('gaussian', smoothWidth, smoothSigma);
    Iout = imfilter(Iout, filter2d, 'replicate');     
end

switch handles.action
    case 'noneRadio'
        img = Iout*multiplyFactor;
    case 'addRadio'
        img = img + Iout*multiplyFactor;
    case 'subtractRadio'
        img = img - Iout*multiplyFactor;
end
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0, img);
end

function continueBtn_Callback(hObject, eventdata, handles)
wb = waitbar(0,'Please wait...','Name',[handles.operationName ' filter']);
colChannel = get(handles.colorChannelPopoup, 'value');
se = getStrelElement(handles);
hValue = str2num(get(handles.strelSizeEdit, 'string')); %#ok<ST2NM>
multiplyFactor = str2double(get(handles.multiplyEdit,'string'));
smoothWidth = str2double(get(handles.smoothWidth, 'string'));
smoothSigma = str2double(get(handles.smoothSigma, 'string'));

handles.h = guidata(handles.h.im_browser);

% backup current data
if strcmp(handles.mode, 'mode2d_Slice')
    ib_do_backup(handles.h, 'image', 0);
elseif isempty(strfind(handles.mode, '_Dataset')) || handles.h.Img{handles.h.Id}.I.time == 1
    ib_do_backup(handles.h, 'image', 1);
end

if ~isempty(strfind(handles.mode, '_Slice'))
    t1 = handles.h.Img{handles.h.Id}.I.slices{5}(1);
    t2 = t1;
    maxIndex = 1;
elseif ~isempty(strfind(handles.mode, '_Stack'))
    t1 = handles.h.Img{handles.h.Id}.I.slices{5}(1);
    t2 = t1;
    maxIndex = handles.h.Img{handles.h.Id}.I.no_stacks;
elseif ~isempty(strfind(handles.mode, '_Dataset'))
    t1 = 1;
    t2 = handles.h.Img{handles.h.Id}.I.time;
    maxIndex = handles.h.Img{handles.h.Id}.I.no_stacks*handles.h.Img{handles.h.Id}.I.time;
end

index = 0;
for t=t1:t2
    getDataOptions.t = [t t];
    if ~isempty(strfind(handles.mode,'mode3d'))
        img = ib_getStack('image', handles.h, t, 4, colChannel, getDataOptions);
        
        Iout = cell([numel(img),1]);
        for roiId=1:numel(img)
            switch handles.operationName
                case 'imbothat'
                    Iout{roiId} = imbothat(img{roiId},se);
                case 'imclearborder'
                    Iout{roiId} = imclearborder(img{roiId},handles.conn);
                case 'imclose'
                    Iout{roiId} = imclose(img{roiId},se);
                case 'imdilate'
                    Iout{roiId} = imdilate(img{roiId},se);
                case 'imerode'
                    Iout{roiId} = imerode(img{roiId},se);
                case 'imfill'
                    Iout{roiId} = imfill(img{roiId});
                case 'imhmax'
                    Iout{roiId} = imhmax(img{roiId},hValue(1),handles.conn);
                case 'imhmin'
                    Iout{roiId} = imhmin(img{roiId},hValue(1),handles.conn);
                case 'imopen'
                    Iout{roiId} = imopen(img{roiId},se);
                case 'imtophat'
                    Iout{roiId} = imtophat(img{roiId},se);
            end
            switch handles.action
                case 'noneRadio'
                    img{roiId} = Iout{roiId}*multiplyFactor;
                case 'addRadio'
                    img{roiId} = img{roiId} + Iout{roiId}*multiplyFactor;
                case 'subtractRadio'
                    img{roiId} = img{roiId} - Iout{roiId}*multiplyFactor;
            end
        end
        waitbar(index/maxIndex,wb);
        index = index + handles.h.Img{handles.h.Id}.I.no_stacks;
        ib_setStack('image', img, handles.h, t, 4, colChannel, getDataOptions);
    else
        startSlice = 1;
        endSlice = size(handles.h.Img{handles.h.Id}.I.img, handles.h.Img{handles.h.Id}.I.orientation);
        if strcmp(handles.mode,'mode2d_Slice')
            startSlice = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
            endSlice = startSlice;
        end
        
        if smoothWidth > 0  % do gaussian filtering
            filter2d = fspecial('gaussian', smoothWidth, smoothSigma);
        end
        noSlices = endSlice-startSlice+1;
        for sliceId = startSlice:endSlice
            img = ib_getSlice('image', handles.h, sliceId, NaN, colChannel, getDataOptions);
            Iout = cell([numel(img),1]);
            for roiId=1:numel(img)
                switch handles.operationName
                    case 'imbothat'
                        Iout{roiId} = imbothat(img{roiId},se);
                    case 'imclearborder'
                        Iout{roiId} = imclearborder(img{roiId},handles.conn);
                    case 'imclose'
                        Iout{roiId} = imclose(img{roiId},se);
                    case 'imdilate'
                        Iout{roiId} = imdilate(img{roiId},se);
                    case 'imerode'
                        Iout{roiId} = imerode(img{roiId},se);
                    case 'imfill'
                        Iout{roiId} = imfill(img{roiId});
                    case 'imhmax'
                        Iout{roiId} = imhmax(img{roiId},hValue(1),handles.conn);
                    case 'imhmin'
                        Iout{roiId} = imhmin(img{roiId},hValue(1),handles.conn);
                    case 'imopen'
                        Iout{roiId} = imopen(img{roiId},se);
                    case 'imtophat'
                        Iout{roiId} = imtophat(img{roiId},se);
                end
                
                if smoothWidth > 0  % do gaussian filtering
                    Iout{roiId} = imfilter(Iout{roiId}, filter2d, 'replicate');
                end
                
                switch handles.action
                    case 'noneRadio'
                        img{roiId} = Iout{roiId}*multiplyFactor;
                    case 'addRadio'
                        img{roiId} = img{roiId} + Iout{roiId}*multiplyFactor;
                    case 'subtractRadio'
                        img{roiId} = img{roiId} - Iout{roiId}*multiplyFactor;
                end
            end
            ib_setSlice('image', img, handles.h, sliceId, NaN, colChannel, getDataOptions);
            waitbar(index/maxIndex,wb);
            index = index + 1;
        end
    end
end


strelShape = get(handles.strelShapePopup, 'string');     
strelShape = strelShape{get(handles.strelShapePopup, 'value')};
se_size = get(handles.strelSizeEdit, 'string'); %#ok<ST2NM>

% update log
if ~isempty(strfind(handles.mode,'mode2d_Slice'))
    mode = sprintf('mode2d_Slice,Z=%d,T=%d',startSlice,t1);
elseif ~isempty(strfind(handles.mode,'_Stack'))
    mode = sprintf('%s,T=%d',handles.mode, t1);
else
    mode = handles.mode;
end

log_text = ['imageMorphOps: Operation=' handles.operationName ',Mode=' mode ',ColCh=', num2str(colChannel) ...
    ',Strel=' strelShape '/' se_size ',Conn=' num2str(handles.conn) ',Multiply=' num2str(multiplyFactor) ...
                    ',Smoothing=' num2str(smoothWidth) '/' num2str(smoothSigma) ',action=' handles.action ',orient=' num2str(handles.h.Img{handles.h.Id}.I.orientation)];
handles.h.Img{handles.h.Id}.I.updateImgInfo(log_text);
waitbar(1,wb);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
delete(wb);
end
