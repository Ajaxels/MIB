function varargout = imAdjustments(varargin)
% function varargout = imAdjustments(varargin)
% imAdjustments function allows to adjust contrast and gamma of the shown dataset.
%
% imAdjustments contains MATLAB code for imAdjustments.fig

% Copyright (C) 23.06.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 29.09.2015 - updated the way how the window is reinitialized 
% 24.01.2016 - updated for 4D

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @imAdjustments_OpeningFcn, ...
    'gui_OutputFcn',  @imAdjustments_OutputFcn, ...
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

% --- Executes just before imAdjustments is made visible.
function imAdjustments_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imAdjustments (see VARARGIN)

repositionSwitch = 1; % reposition the figure, when creating a new figure
colorChannelSelection = 99999999;
if numel(varargin) > 1
    handles = guidata(varargin{2});
    colorChannelSelection = get(handles.colorChannelCombo,'Value');     % store selected color channel
    repositionSwitch = 0; % keep the current coordinates when the figure already exist
    handles = rmfield(handles, 'h');
end

% Choose default command line output for imAdjustments
handles.output = hObject;

handles.h = varargin{1};

%% set background color to panels and texts
set(handles.imAdjustments,'Color',[.831 .816 .784]);
tempList = findall(handles.imAdjustments,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.imAdjustments,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.imAdjustments,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.imAdjustments,'Style','radiobutton');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);

handles = updateWidgets(handles, colorChannelSelection);

% update font and size
if get(handles.text4, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text4, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.imAdjustments, handles.h.preferences.Font);
end

% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.imAdjustments);

% Adding listeners if the window is opened for the first time
%if isfield(handles, 'maxSliderListener');  delete(handles.maxSliderListener); end;
if ~isfield(handles, 'maxSliderListener');  
    if handles.h.matlabVersion  < 8.4 % R2014a or earlier
        handles.minSliderListener = handle.listener(handles.minSlider,'ActionEvent',@minSlider_Callback);
        handles.maxSliderListener = handle.listener(handles.maxSlider,'ActionEvent',@maxSlider_Callback);
        handles.gammaSliderListener = handle.listener(handles.gammaSlider,'ActionEvent',@gammaSlider_Callback);
    else
        handles.minSliderListener = addlistener(handles.minSlider,'ContinuousValueChange',@minSlider_Callback);
        handles.maxSliderListener = addlistener(handles.maxSlider,'ContinuousValueChange',@maxSlider_Callback);
        handles.gammaSliderListener = addlistener(handles.gammaSlider,'ContinuousValueChange',@gammaSlider_Callback);
    end
end

% Update handles structure
guidata(hObject, handles);

% Determine the position of the dialog - on a side of the main figure
% if available, else, centered on the main figure
if repositionSwitch
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
end
% UIWAIT makes imAdjustments wait for user response (see UIRESUME)
% uiwait(handles.imAdjustments);
end

function handles = updateWidgets(handles, colorChannelSelection)
if nargin < 2
    colorChannelSelection = get(handles.colorChannelCombo,'Value');
end

% update automatic update of the histogram checkbox
set(handles.autoHistCheck, 'value', handles.h.SwitchAutoHistUpdate);

set(handles.colorChannelCombo,'Value',1);   % the colors of the popup menu are updated in the updateHist function
colorChannelCombo_Callback(handles.colorChannelCombo, [], handles);

if size(handles.h.Img{handles.h.Id}.I.img,3) >= colorChannelSelection
    set(handles.colorChannelCombo,'Value',colorChannelSelection);
end

% when only one color channel is shown select it
if numel(handles.h.Img{handles.h.Id}.I.slices{3}) == 1
    colorChannelSelection = handles.h.Img{handles.h.Id}.I.slices{3};
    set(handles.colorChannelCombo,'Value',colorChannelSelection);
else
    if size(handles.h.Img{handles.h.Id}.I.img,3) >= colorChannelSelection
        set(handles.colorChannelCombo,'Value',colorChannelSelection);
    end
end
handles = updateSliders(handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = imAdjustments_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes when user attempts to close imAdjustments.
function imAdjustments_CloseRequestFcn(hObject, eventdata, handles)
%handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
delete(hObject);
end

function handles = updateSliders(handles)
channel = get(handles.colorChannelCombo,'Value');
min_val = handles.h.Img{handles.h.Id}.I.viewPort.min(channel);
max_val = handles.h.Img{handles.h.Id}.I.viewPort.max(channel);
gamma = handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel);

set(handles.minSlider,'Min',0);
set(handles.minSlider,'Max',max_val);
set(handles.minSlider,'Value',min_val);
set(handles.minEdit,'String',num2str(min_val));

set(handles.maxSlider,'Min',min_val);
set(handles.maxSlider,'Max',double(intmax(class(handles.h.Img{handles.h.Id}.I.img))));
set(handles.maxSlider,'Value',max_val);
set(handles.maxEdit,'String',num2str(max_val));

set(handles.gammaSlider,'Value',gamma);
set(handles.gammaEdit,'String',num2str(gamma));

updateHist(handles);
end

function updateHist(handles)
channel = get(handles.colorChannelCombo,'Value');
logscale = get(handles.logViewCheck,'Value');
img = handles.h.Img{handles.h.Id}.I.getSliceToShow('image', NaN, NaN, channel);
[counts,x] = imhist(img);
%bar(handles.imHist,x,counts);
area(handles.imHist,x(counts>0),counts(counts>0),'linestyle','none');
%stem(handles.imHist,x(counts>0),counts(counts>0), 'Marker', 'none');

set(handles.imHist,'XLim',[min([handles.h.Img{handles.h.Id}.I.viewPort.min(channel)+1 intmax(class(handles.h.Img{handles.h.Id}.I.img))-3]) ...
    max([handles.h.Img{handles.h.Id}.I.viewPort.max(channel)-1 2]) ]);
if logscale
    set(handles.imHist,'YScale','Log');
else
    set(handles.imHist,'YScale','Linear');
end

% update colors in the popup menu
col_channels = cell([size(handles.h.Img{handles.h.Id}.I.img,3), 1]);
colorTableData = get(handles.h.channelMixerTable,'data');
selectedColorChannel = get(handles.colorChannelCombo, 'value');
for col_ch=1:size(handles.h.Img{handles.h.Id}.I.img,3)
    colorTableDataItem = colorTableData{col_ch,3};
    index1 = strfind(colorTableDataItem, 'rgb');
    index2 = strfind(colorTableDataItem, ')');
    colorText = colorTableDataItem(index1:index2);
    if isempty(index1)  % when 'X'
        colorText = 'rgb(0, 0, 0)';
    end
    if col_ch == selectedColorChannel
        selectedColor = colorText;
    end
    col_channels{col_ch} = sprintf('<html><font color=''%s''>Channel %d</Font></html>', colorText, col_ch);
end
set(handles.colorChannelCombo,'String',col_channels);

% update colorChannelPanel1
selectedColor = selectedColor(5:end-1);
commas = strfind(selectedColor, ',');
set(handles.colorChannelPanel1, 'backgroundcolor', [str2double(selectedColor(1:commas(1)-1))/255 str2double(selectedColor(commas(1)+1:commas(2)-1))/255 str2double(selectedColor(commas(2)+1:end))/255]);
end

% --- Executes on slider movement.
function minSlider_Callback(hObject, eventdata, handles)
handles = guidata(hObject);     % update handles for listener
channel = get(handles.colorChannelCombo,'Value');
current_value = get(handles.minSlider,'Value');
max_val = handles.h.Img{handles.h.Id}.I.viewPort.max(channel);
if current_value >= max_val
    set(handles.minSlider,'Value',max_val-3);
    current_value = max_val-3;
end
set(handles.maxSlider,'Min',current_value);

handles = updateSettings(handles);
handles.h = guidata(handles.h.im_browser);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h,0);
set(handles.minEdit,'String',num2str(handles.h.Img{handles.h.Id}.I.viewPort.min(channel)));
updateHist(handles);
end


function minEdit_Callback(hObject, eventdata, handles)
channel = get(handles.colorChannelCombo,'Value');
val = str2double(get(handles.minEdit,'String'));
if isnan(val)
    set(handles.minEdit,'String',num2str(handles.h.Img{handles.h.Id}.I.viewPort.min(channel)));
    return;
end
% if val >= intmax(class(handles.h.Img{handles.h.Id}.I.img))-1
%     val = double(intmax(class(handles.h.Img{handles.h.Id}.I.img))-3);
% end

if val >= handles.h.Img{handles.h.Id}.I.viewPort.max(channel)
    handles.h.Img{handles.h.Id}.I.viewPort.min(channel) = handles.h.Img{handles.h.Id}.I.viewPort.max(channel) - 1;
elseif val < 0
    handles.h.Img{handles.h.Id}.I.viewPort.min(channel) = 0;
else
    handles.h.Img{handles.h.Id}.I.viewPort.min(channel) = val;
end

set(handles.minSlider,'Value',handles.h.Img{handles.h.Id}.I.viewPort.min(channel));
minSlider_Callback(handles.minSlider, eventdata, handles);
end

% --- Executes on slider movement.
function maxSlider_Callback(hObject, eventdata, handles)
handles = guidata(hObject);     % update handles for listener
channel = get(handles.colorChannelCombo,'Value');
current_value = get(handles.maxSlider,'Value');
min_val = handles.h.Img{handles.h.Id}.I.viewPort.min(channel);
if current_value <= min_val
    set(handles.maxSlider,'Value',min_val+3);
    current_value = min_val+3;
end
set(handles.minSlider,'Max',current_value);
handles = updateSettings(handles);
handles.h = guidata(handles.h.im_browser);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h,0);
set(handles.maxEdit,'String',num2str(handles.h.Img{handles.h.Id}.I.viewPort.max(channel)));
updateHist(handles);
end


function maxEdit_Callback(hObject, eventdata, handles)
channel = get(handles.colorChannelCombo,'Value');
val = str2double(get(handles.maxEdit,'String'));
if isnan(val)
    set(handles.maxEdit,'String',num2str(handles.h.Img{handles.h.Id}.I.viewPort.max(channel)));
    return;
end
if val <= handles.h.Img{handles.h.Id}.I.viewPort.min(channel)
    handles.h.Img{handles.h.Id}.I.viewPort.max(channel) = handles.h.Img{handles.h.Id}.I.viewPort.min(channel) + 1;
elseif val >= double(intmax(class(handles.h.Img{handles.h.Id}.I.img)))
    handles.h.Img{handles.h.Id}.I.viewPort.max(channel) = double(intmax(class(handles.h.Img{handles.h.Id}.I.img)));
else
    handles.h.Img{handles.h.Id}.I.viewPort.max(channel) = val;
end
set(handles.maxSlider,'Value',handles.h.Img{handles.h.Id}.I.viewPort.max(channel));
maxSlider_Callback(handles.maxSlider, eventdata, handles);
end



% --- Executes on slider movement.
function gammaSlider_Callback(hObject, eventdata, handles)
handles = guidata(hObject);     % update handles for listener
channel = get(handles.colorChannelCombo,'Value');
handles = updateSettings(handles);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h,0);
set(handles.gammaEdit,'String',num2str(handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel)));
updateHist(handles);
end


function gammaEdit_Callback(hObject, eventdata, handles)
channel = get(handles.colorChannelCombo,'Value');
val = str2double(get(handles.gammaEdit,'String'));
if isnan(val)
    set(handles.gammaEdit,'String',num2str(handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel)));
    return;
end
if val < 0.1
    handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel) = 0.1;
elseif val > 5
    handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel) = 5;
else
    handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel) = val;
end
set(handles.gammaSlider,'Value',handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel));
gammaSlider_Callback(handles.gammaSlider, eventdata, handles);
end

function handles = updateSettings(handles)
% update min, max, and gamma with parameters from sliders/editboxes
if get(handles.linkChannelsCheck, 'value') == 1
    channel = handles.h.Img{handles.h.Id}.I.slices{3};
else
    channel = get(handles.colorChannelCombo,'Value');    
end
handles.h.Img{handles.h.Id}.I.viewPort.min(channel) = get(handles.minSlider,'Value');
handles.h.Img{handles.h.Id}.I.viewPort.max(channel) = get(handles.maxSlider,'Value');
handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel) = get(handles.gammaSlider,'Value');
end

% --- Executes on button press in logViewCheck.
function logViewCheck_Callback(hObject, eventdata, handles)
updateHist(handles);
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function imAdjustments_WindowButtonDownFcn(hObject, eventdata, handles)
xy = get(handles.imHist, 'currentpoint');
seltype = get(handles.imAdjustments, 'selectiontype');
ylims = get(handles.imHist,'YLim');
if xy(1,2) > ylims(2)+diff(ylims)*.2; return; end; % mouse click away from histogram
%modifier = get(handles.imAdjustments,'currentmodifier')
switch seltype
    case 'normal'       % set the min limit
        if xy(1,1) >= str2double(get(handles.maxEdit,'String'))-3; return; end;
        set(handles.minEdit,'String',num2str(xy(1,1)));
        minEdit_Callback(handles.minEdit, eventdata, handles);
    case 'alt'          % set the max limit
        if xy(1,1) <= str2double(get(handles.minEdit,'String'))+3; return; end;
        set(handles.maxEdit,'String',num2str(xy(1,1)));
        maxEdit_Callback(handles.maxEdit, eventdata, handles)
end
end


% --- Executes on selection change in colorChannelCombo.
function colorChannelCombo_Callback(hObject, eventdata, handles)
val = get(handles.colorChannelCombo, 'value');
set(handles.adjustPanel, 'Title',sprintf('Adjust channel %d', val));
handles = updateSliders(handles);
end


% --- Executes on button press in adjHelpBtn.
function adjHelpBtn_Callback(hObject, eventdata, handles)
if isdeployed
    web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_panel_adjustments.html'), '-helpbrowser');
else
    web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_panel_adjustments.html'), '-helpbrowser');
end
end


% --- Executes on button press in findMinBtn.
function findMinBtn_Callback(hObject, eventdata, handles)
colorCh = get(handles.colorChannelCombo, 'value');
minval = min(min(min(handles.h.Img{handles.h.Id}.I.img(:,:,colorCh,:))));
set(handles.minEdit, 'String', num2str(minval));
minEdit_Callback(handles.minEdit, eventdata, handles);
end

% --- Executes on button press in findMaxBtn.
function findMaxBtn_Callback(hObject, eventdata, handles)
colorCh = get(handles.colorChannelCombo, 'value');
maxval = max(max(max(handles.h.Img{handles.h.Id}.I.img(:,:,colorCh,:))));
set(handles.maxEdit, 'String', num2str(maxval));
maxEdit_Callback(handles.maxEdit, eventdata, handles);
end


% --- Executes on button press in updateBtn.
function updateBtn_Callback(hObject, eventdata, handles)
handles.h = guidata(handles.h.im_browser);
handles = updateWidgets(handles);
updateHist(handles);
guidata(handles.imAdjustments, handles);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over minSlider.
function minSlider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to minSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.minSlider, 'value', 0);
minSlider_Callback(handles.minSlider, eventdata, handles);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over maxSlider.
function maxSlider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to maxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.maxSlider, 'value', double(intmax(class(handles.h.Img{handles.h.Id}.I.img))));
maxSlider_Callback(handles.maxSlider, eventdata, handles);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over gammaSlider.
function gammaSlider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to gammaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.gammaSlider, 'value', 1);
gammaSlider_Callback(handles.gammaSlider, eventdata, handles);
end

% --- Executes on button press in applyBtn.
function applyBtn_Callback(hObject, eventdata, handles)
res = questdlg(sprintf('You are going to recalculate intensities of the original image by stretching!\n\nAre you sure?'),'!!! Warning !!!','Proceed','Cancel','Cancel');
if strcmp(res,'Cancel'); return; end;
wb = waitbar(0,'Please wait...','Name','Adjusting...');
maxZ = handles.h.Img{handles.h.Id}.I.no_stacks;
maxT = handles.h.Img{handles.h.Id}.I.time;
if maxT == 1; ib_do_backup(handles.h, 'image', 1); end;
max_int = double(intmax(class(handles.h.Img{handles.h.Id}.I.img)));
channel = get(handles.colorChannelCombo,'Value');
for t=1:maxT
    for i=1:maxZ
        handles.h.Img{handles.h.Id}.I.img(:,:,channel,i,t) = imadjust(handles.h.Img{handles.h.Id}.I.img(:,:,channel,i,t),...
            [handles.h.Img{handles.h.Id}.I.viewPort.min(channel)/max_int handles.h.Img{handles.h.Id}.I.viewPort.max(channel)/max_int],...
            [0 1],handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel));
        if mod(i,10)==0; waitbar(i/(maxZ*maxT),wb); end;   % update waitbar
    end
end

log_text = ['ContrastGamma: Channel:' num2str(channel) ', Min:' num2str(handles.h.Img{handles.h.Id}.I.viewPort.min(channel)) ', Max: ' num2str(handles.h.Img{handles.h.Id}.I.viewPort.max(channel)) ,...
    ', Gamma: ' num2str(handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel))];
handles.h.Img{handles.h.Id}.I.updateImgInfo(log_text);
handles.h.Img{handles.h.Id}.I.viewPort.min(channel) = 0;
handles.h.Img{handles.h.Id}.I.viewPort.max(channel) = max_int;
handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel) = 1;

handles = updateSliders(handles);
delete(wb);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h,0);
end

% --- Executes on button press in stretchCurrent.
function stretchCurrent_Callback(hObject, eventdata, handles)
ib_do_backup(handles.h, 'image', 0);
max_int = double(intmax(class(handles.h.Img{handles.h.Id}.I.img)));
channel = get(handles.colorChannelCombo,'Value');
getDataOptions.blockModeSwitch = 0;
slice = handles.h.Img{handles.h.Id}.I.getData2D('image', NaN, NaN, channel, NaN, getDataOptions);
slice = imadjust(slice,...
    [handles.h.Img{handles.h.Id}.I.viewPort.min(channel)/max_int handles.h.Img{handles.h.Id}.I.viewPort.max(channel)/max_int],...
    [0 1],handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel));
handles.h.Img{handles.h.Id}.I.setData2D('image', slice, NaN, NaN, channel, NaN, getDataOptions);
handles.h.Img{handles.h.Id}.I.viewPort.min(channel) = 0;
handles.h.Img{handles.h.Id}.I.viewPort.max(channel) = max_int;
handles.h.Img{handles.h.Id}.I.viewPort.gamma(channel) = 1;
handles = updateSliders(handles);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h,0);
end


% --- Executes on button press in autoHistCheck.
function autoHistCheck_Callback(hObject, eventdata, handles)
val = get(handles.autoHistCheck, 'value');
% update handles
handles.h = guidata(handles.h.im_browser);
handles.h.SwitchAutoHistUpdate = val;
guidata(handles.h.im_browser, handles.h);   % update main handles
updateHist(handles);
end
