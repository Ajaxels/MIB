function varargout = ib_cropGui(varargin)
% function varargout = ib_cropGui(varargin)
% ib_cropGui function is responsible for the crop of dataset.
%
% ib_cropGui contains MATLAB code for ib_cropGui.fig

% Copyright (C) 31.01.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, IB, changed .slices() to .slices{:}; .slicesColor->.slices{3}
% 25.01.2016, IB, updated to 5D


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ib_cropGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_cropGui_OutputFcn, ...
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

% --- Executes just before ib_cropGui is made visible.
function ib_cropGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_cropGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser

set(handles.wEdit, 'String', ['1:' num2str(size(handles.h.Img{handles.h.Id}.I.img,2))]);
set(handles.hEdit, 'String', ['1:' num2str(size(handles.h.Img{handles.h.Id}.I.img,1))]);
set(handles.zEdit, 'String', ['1:' num2str(size(handles.h.Img{handles.h.Id}.I.img,4))]);
set(handles.tEdit, 'String', ['1:' num2str(size(handles.h.Img{handles.h.Id}.I.img,5))]);
handles.roiPos{1} = NaN;

[numberOfROI, indicesOfROI] = handles.h.Img{handles.h.Id}.I.hROI.getNumberOfROI(0);     % get all ROI
if numberOfROI == 0
    set(handles.roiRadio,'enable','off');
end

radio_Callback(handles.manualRadio, eventdata, handles);
if strcmp(handles.h.preferences.disableSelection, 'yes')
    set(handles.interactiveRadio,'enable','off');
    set(handles.manualRadio, 'value', 1);
    set(handles.descriptionText,'String','To enable the interactive crop tool please switch on the selection mode. Set the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) to "no"');
end

list{1} = 'All';
i=2;
for idx = indicesOfROI
    list(i) = handles.h.Img{handles.h.Id}.I.hROI.Data(idx).label; %#ok<AGROW>
    i = i + 1;
end
set(handles.roiPopup, 'String', list);

if numel(list) > 1
    set(handles.roiPopup,'value', max([get(handles.h.roiList, 'value') 2]));
else
    set(handles.roiPopup,'value', 1);
end

% update font and size
if get(handles.descriptionText, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.descriptionText, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_cropGui, handles.h.preferences.Font);
end

% Choose default command line output for ib_cropGui
handles.output = NaN;

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_cropGui);

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

% Make the GUI modal
set(handles.ib_cropGui,'WindowStyle','modal');

% UIWAIT makes ib_cropGui wait for user response (see UIRESUME)
uiwait(handles.ib_cropGui);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_cropGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.ib_cropGui);
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
uiresume(handles.ib_cropGui);
end

% --- Executes on button press in cropBtn.
function cropBtn_Callback(hObject, eventdata, handles)
if get(handles.interactiveRadio, 'value')    % interactive
    set(handles.ib_cropGui,'visible','off');
    set(handles.h.im_browser, 'windowbuttondownfcn', '');
    h =  imrect(handles.h.imageAxes);
    selarea = h.createMask;
    delete(h);
    set(handles.h.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles.h});
    handles.h.Img{handles.h.Id}.I.clearSelection();
    options.blockModeSwitch = 1;
    [height, width, ~, ~] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('selection', NaN, 0, options);
    handles.h.Img{handles.h.Id}.I.setSliceToShow('selection', imresize(uint8(selarea),[height width],'method','nearest'));
    handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
    choice2 = questdlg('Do you want to crop the image to selected area?','Crop options','Yes','Cancel','Cancel');
    if strcmp(choice2,'Cancel');
        handles.h.Img{handles.h.Id}.I.clearSelection(NaN, NaN, handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber());
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
        set(handles.ib_cropGui,'visible','on');
        return;
    end;
    %selarea = handles.h.Img{handles.h.Id}.I.getCurrentSlice('selection');
    selarea = handles.h.Img{handles.h.Id}.I.getFullSlice('selection', handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber);
    STATS = regionprops(selarea, 'BoundingBox');
   
    if handles.h.Img{handles.h.Id}.I.orientation == 4 % xy plane
        crop_factor = [round(STATS.BoundingBox(1:2)) STATS.BoundingBox(3:4) 1 size(handles.h.Img{handles.h.Id}.I.img,4)]; % x1, y1, dx, dy, z1, dz
    elseif handles.h.Img{handles.h.Id}.I.orientation == 1 % xz plane
        crop_factor = [round(STATS.BoundingBox(2)) 1 round(STATS.BoundingBox(4)) size(handles.h.Img{handles.h.Id}.I.img,1) round(STATS.BoundingBox(1)) round(STATS.BoundingBox(3))]; % x1, y1, dx, dy, z1, dz
    elseif handles.h.Img{handles.h.Id}.I.orientation == 2 % yz plane
        crop_factor = [1 round(STATS.BoundingBox(2)) size(handles.h.Img{handles.h.Id}.I.img,2) round(STATS.BoundingBox(4)) round(STATS.BoundingBox(1)) round(STATS.BoundingBox(3))]; % x1, y1, dx, dy, z1, dz
    end
elseif ~isnan(handles.roiPos{1})
    x1 = handles.roiPos{1}(1);
    x2 = handles.roiPos{1}(2);
    y1 = handles.roiPos{1}(3);
    y2 = handles.roiPos{1}(4);
    z1 = handles.roiPos{1}(5);
    z2 = handles.roiPos{1}(6);
    crop_factor = [x1,y1,x2-x1+1,y2-y1+1,z1,z2-z1+1];
else
    msgbox('Oops, not implemented yet!','Multiple ROI crop','warn');
    return;
end

if strcmp(get(hObject, 'tag'), 'croptoBtn')
    bufferId = 8;
    for i=1:8
        if ismac()
            eval(sprintf('bgColor = get(handles.h.bufferToggle%d,''ForegroundColor'');', i));     % make green
        else
            eval(sprintf('bgColor = get(handles.h.bufferToggle%d,''BackgroundColor'');', i));     % make green
        end
        if bgColor(2) ~= 1;
            bufferId = i;
            break;
        end;
    end
    
    answer = mib_inputdlg(handles.h, 'Enter destination buffer number (from 1 to 8) to duplicate the dataset:','Duplicate',num2str(bufferId));
    if isempty(answer); return; end;
    bufferId = str2double(answer{1});
    
    % copy dataset to the destination buffer
    handles.h.Img{bufferId}.I  = copy(handles.h.Img{handles.h.Id}.I);
    handles.h.Img{bufferId}.I.img_info  = containers.Map(keys(handles.h.Img{handles.h.Id}.I.img_info), values(handles.h.Img{handles.h.Id}.I.img_info));  % make a copy of img_info containers.Map
    handles.h.Img{bufferId}.I.hROI  = copy(handles.h.Img{bufferId}.I.hROI);
    handles.h.Img{bufferId}.I.hROI.hImg = handles.h.Img{bufferId}.I;  % need to copy a handle of imageData class to a copy of the roiRegion class
    handles.h.Img{bufferId}.I.hLabels  = copy(handles.h.Img{bufferId}.I.hLabels);
    handles.h.Img{bufferId}.I.hMeasure  = copy(handles.h.Img{bufferId}.I.hMeasure);
else
    bufferId = handles.h.Id;
end

crop_factor = [crop_factor handles.roiPos{1}(7) handles.roiPos{1}(8)-handles.roiPos{1}(7)+1];
handles.h.Img{bufferId}.I.hROI.crop(crop_factor);
handles.h.Img{bufferId}.I.hLabels.crop(crop_factor);

handles.h.Img{bufferId}.I.cropDataset(crop_factor);
if str2double(get(handles.h.changelayerEdit,'String')) > size(handles.h.Img{bufferId}.I.img,handles.h.Img{bufferId}.I.orientation)
    handles.h.Img{bufferId}.I.slices{handles.h.Img{bufferId}.I.orientation} = [size(handles.h.Img{bufferId}.I.img, handles.h.Img{bufferId}.I.orientation) size(handles.h.Img{bufferId}.I.img, handles.h.Img{bufferId}.I.orientation)];
end

% clear selected rectangle when using the interactive mode
if get(handles.interactiveRadio, 'value')    
    handles.h.Img{bufferId}.I.clearSelection(NaN, NaN, handles.h.Img{bufferId}.I.getCurrentSliceNumber());
end

log_text = ['ImCrop: [x1 y1 dx dy z1 dz t1 dt]: [' num2str(crop_factor) ']'];
handles.h.Img{bufferId}.I.updateImgInfo(log_text);
handles.h = handles.h.Img{bufferId}.I.updateAxesLimits(handles.h, 'resize');

if strcmp(get(hObject, 'tag'), 'croptoBtn')
    if ismac()
        eval(sprintf('set(handles.h.bufferToggle%d,''ForegroundColor'',[ 0    1    0]);', bufferId));
    else
        eval(sprintf('set(handles.h.bufferToggle%d,''BackgroundColor'',[ 0    1    0]);', bufferId));
    end
    eval(sprintf('set(handles.h.bufferToggle%d,''TooltipString'', handles.h.Img{%d}.I.img_info(''Filename''));',bufferId, bufferId));     % make a tooltip as filename
    handles.h = updateGuiWidgets(handles.h);
    % clear selection
    handles.h.Img{handles.h.Id}.I.clearSelection(NaN, NaN, handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber());
end

handles.h.Img{bufferId}.I.plotImage(handles.h.imageAxes, handles.h, 1);
handles.output = handles.h;

%profile viewer 
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_cropGui);
end

function radio_Callback(hObject, eventdata, handles)
tag = get(hObject,'tag');
set(hObject,'value',1);
set(handles.roiPopup,'enable','off');
set(handles.wEdit,'enable','off');
set(handles.hEdit,'enable','off');
set(handles.zEdit,'enable','off');
if handles.h.Img{handles.h.Id}.I.time > 1
    set(handles.tEdit, 'enable', 'on');
else
    set(handles.tEdit,'enable','off');    
end
if strcmp(tag,'interactiveRadio')
    text = sprintf('Interactive mode allows to draw a rectangle that will be used for cropping\nTo start, press the Continue button and use the left mouse button to draw a rectangle area');
    editboxes_Callback(hObject, eventdata, handles);
elseif strcmp(tag,'manualRadio')
    set(handles.wEdit,'enable','on');
    set(handles.hEdit,'enable','on');
    set(handles.zEdit,'enable','on');
    text = sprintf('In the manual mode the numbers entered in the edit boxes below will be used for cropping');
    editboxes_Callback(hObject, eventdata, handles);
elseif strcmp(tag,'roiRadio')
    set(handles.roiPopup,'enable','on');
    text = sprintf('Use existing ROIs to crop the image');
    roiPopup_Callback(hObject, eventdata, handles);
end
set(handles.descriptionText,'String', text);
end


% --- Executes on selection change in roiPopup.
function roiPopup_Callback(hObject, eventdata, handles)
val = get(handles.roiPopup,'value') - 1;

str2 = get(handles.tEdit,'String');
tMin = min(str2num(str2)); %#ok<ST2NM>
tMax = max(str2num(str2)); %#ok<ST2NM>
if val == 0
    [number, roiIndices] = handles.h.Img{handles.h.Id}.I.hROI.getNumberOfROI(0);
    i = 1;
    for idx=roiIndices
        handles.roiPos{i} = getBoundingBox(handles, idx);
        handles.roiPos{i}(7:8) = [tMin, tMax];
        i = i + 1;
    end
    set(handles.wEdit,'String','Multi');
    set(handles.hEdit,'String','Multi');
    set(handles.zEdit,'String','Multi');
else
    bb{1} = getBoundingBox(handles, val);
    set(handles.wEdit,'String',[num2str(bb{1}(1)) ':', num2str(bb{1}(2))]);
    set(handles.hEdit,'String',[num2str(bb{1}(3)) ':', num2str(bb{1}(4))]);
    set(handles.zEdit,'String',[num2str(bb{1}(5)) ':', num2str(bb{1}(6))]);
    handles.roiPos{1} = bb{1};
    handles.roiPos{1}(7:8) = [tMin, tMax];
end
guidata(hObject, handles);
end


function bb = getBoundingBox(handles, roiIndex)
% return the bounding box info for the ROI at the current orientation
% BoundingBox format: bb = [minX, maxX, minY, maxY, minZ, maxZ]
% bb = getBoundingBox(obj, 2)
options.blockModeSwitch = 0;
[height, width, color, thick] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image',4,NaN,options);
mask = handles.h.Img{handles.h.Id}.I.hROI.returnMask(roiIndex, NaN, NaN, handles.h.Img{handles.h.Id}.I.hROI.Data(roiIndex).orientation);
STATS = regionprops(mask, 'BoundingBox');
if numel(STATS) == 0; bb(1:6) = [NaN NaN NaN NaN NaN NaN]; return; end

if handles.h.Img{handles.h.Id}.I.hROI.Data(roiIndex).orientation == 4
    bb(1) = ceil(STATS.BoundingBox(1));
    bb(2) = ceil(STATS.BoundingBox(1))+ceil(STATS.BoundingBox(3)) - 1;
    bb(3) = ceil(STATS.BoundingBox(2));
    bb(4) = ceil(STATS.BoundingBox(2))+ceil(STATS.BoundingBox(4)) - 1;
    bb(5) = 1;
    bb(6) = thick;
elseif handles.h.Img{handles.h.Id}.I.hROI.Data(roiIndex).orientation == 1
    bb(5) = ceil(STATS.BoundingBox(1));
    bb(6) = ceil(STATS.BoundingBox(1))+ceil(STATS.BoundingBox(3)) - 1;
    bb(1) = ceil(STATS.BoundingBox(2));
    bb(2) = ceil(STATS.BoundingBox(2))+ceil(STATS.BoundingBox(4)) - 1;
   
    bb(3) = 1;
    bb(4) = height;
elseif handles.h.Img{handles.h.Id}.I.hROI.Data(roiIndex).orientation == 2
    bb(5) = ceil(STATS.BoundingBox(1));
    bb(6) = ceil(STATS.BoundingBox(1))+ceil(STATS.BoundingBox(3)) - 1;
    bb(3) = ceil(STATS.BoundingBox(2));
    bb(4) = ceil(STATS.BoundingBox(2))+ceil(STATS.BoundingBox(4)) - 1;
    bb(1) = 1;
    bb(2) = width;
end
end


% --- Executes on button press in resetBtn.
function resetBtn_Callback(hObject, eventdata, handles)
set(handles.wEdit, 'String', ['1:' num2str(size(handles.h.Img{handles.h.Id}.I.img,2))]);
set(handles.hEdit, 'String', ['1:' num2str(size(handles.h.Img{handles.h.Id}.I.img,1))]);
set(handles.zEdit, 'String', ['1:' num2str(size(handles.h.Img{handles.h.Id}.I.img,4))]);
set(handles.tEdit, 'String', ['1:' num2str(size(handles.h.Img{handles.h.Id}.I.img,5))]);

handles.roiPos{1} = [1, size(handles.h.Img{handles.h.Id}.I.img,2), 1, size(handles.h.Img{handles.h.Id}.I.img,1),...
    1, size(handles.h.Img{handles.h.Id}.I.img,4) 1, size(handles.h.Img{handles.h.Id}.I.img,5)];
radio_Callback(handles.manualRadio, eventdata, handles);
guidata(hObject, handles);
end



function editboxes_Callback(hObject, eventdata, handles)
str2 = get(handles.wEdit,'String');
handles.roiPos{1}(1) = min(str2num(str2)); %#ok<ST2NM>
handles.roiPos{1}(2) = max(str2num(str2)); %#ok<ST2NM>
str2 = get(handles.hEdit,'String');
handles.roiPos{1}(3) = min(str2num(str2)); %#ok<ST2NM>
handles.roiPos{1}(4) = max(str2num(str2)); %#ok<ST2NM>
str2 = get(handles.zEdit,'String');
handles.roiPos{1}(5) = min(str2num(str2)); %#ok<ST2NM>
handles.roiPos{1}(6) = max(str2num(str2)); %#ok<ST2NM>
str2 = get(handles.tEdit,'String');
handles.roiPos{1}(7) = min(str2num(str2)); %#ok<ST2NM>
handles.roiPos{1}(8) = max(str2num(str2)); %#ok<ST2NM>
guidata(hObject, handles);
end
