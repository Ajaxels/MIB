function varargout = ib_saveVideoGui(varargin)
% function varargout = ib_saveVideoGui(varargin)
% ib_saveVideoGui function is responsible for saving video files of the datasets.
%
% ib_saveVideoGui contains MATLAB code for ib_saveVideoGui.fig

% Copyright (C) 21.08.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 19.01.2016 use of rounded values in the scale bar
% 03.02.2016, updated for 4D datasets

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ib_saveVideoGui_OpeningFcn, ...
    'gui_OutputFcn',  @ib_saveVideoGui_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT


% --- Executes just before ib_saveVideoGui is made visible.
function ib_saveVideoGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_saveVideoGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser
handles.fn_out = varargin{2};     % filename of the output file

[~, ~, ext] = fileparts(handles.fn_out);
if strcmp(ext(2:end), 'avi')
    set(handles.codecPopup, 'Value', 2);
elseif strcmp(ext(2:end), 'mj2')
    set(handles.codecPopup, 'Value', 3);
elseif strcmp(ext(2:end), 'mp4')
    set(handles.codecPopup, 'Value', 4);
end
set(handles.outputDir, 'String', handles.fn_out);
options.blockModeSwitch = 1;
[height, width, ~, z] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, options);
set(handles.heightEdit, 'String', num2str(height));
set(handles.lastFrameEdit, 'String', num2str(z));
handles.origWidth = width;
if handles.h.Img{handles.h.Id}.I.orientation == 1
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.z/handles.h.Img{handles.h.Id}.I.pixSize.x;
elseif handles.h.Img{handles.h.Id}.I.orientation == 2
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.z/handles.h.Img{handles.h.Id}.I.pixSize.y;
elseif handles.h.Img{handles.h.Id}.I.orientation == 4
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.x/handles.h.Img{handles.h.Id}.I.pixSize.y;
end
set(handles.widthEdit, 'String', num2str(ceil(width)));

handles.origHeight = height;
handles.resizedWidth = width;

if handles.h.Img{handles.h.Id}.I.time > 1
    set(handles.directionPopup, 'enable', 'on');
end

% disable ROI mode
if strcmp(get(handles.h.toolbarShowROISwitch,'state'),'off')
    set(handles.roiRadio, 'enable', 'off');
elseif numel(get(handles.h.roiList,'string')) == 1
    set(handles.roiRadio, 'enable', 'off');
elseif numel(get(handles.h.roiList,'string')) > 2 && get(handles.h.roiList,'value') < 2
    set(handles.roiRadio, 'enable', 'off');
else
    roiShowCheck_Callback(NaN, NaN, handles.h);
end

% update font and size
if get(handles.text25, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text25, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_saveVideoGui, handles.h.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_saveVideoGui);

% Choose default command line output for ib_saveVideoGui
handles.output = NaN;

%% set background color to panels and texts
set(handles.ib_saveVideoGui,'Color',[.831 .816 .784]);
tempList = findall(handles.ib_saveVideoGui,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_saveVideoGui,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_saveVideoGui,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_saveVideoGui,'Style','radiobutton');    % set color to radiobutton
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_saveVideoGui,'Type','uibuttongroup');    % set color to uibuttongroup
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

% Make the GUI modal
% set(handles.ib_saveVideoGui,'WindowStyle','modal');

% UIWAIT makes ib_saveVideoGui wait for user response (see UIRESUME)
% uiwait(handles.ib_saveVideoGui);

end

% --- Outputs from this function are returned to the command line.
function varargout = ib_saveVideoGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

if isstruct(handles)
    varargout{1} = handles.output;
    % The figure can be deleted now
    % delete(handles.ib_saveVideoGui);
else
    varargout{1} = NaN;
end

end

function crop_Callback(hObject, eventdata, handles)
if get(handles.fullImageRadio,'Value') == 1
    options.blockModeSwitch = 0; % full image
elseif get(handles.shownAreaRadio,'Value') == 1
    options.blockModeSwitch = 1; % the shown image
elseif get(handles.roiRadio,'Value') == 1
    options.blockModeSwitch = 0; % full image
else
    set(hObject, 'value', 1);
    return;
end

if get(handles.roiRadio,'Value')
    roiList = get(handles.h.roiList, 'string');
    roiImg = handles.h.Img{handles.h.Id}.I.hROI.returnMask(roiList{get(handles.h.roiList, 'value')});
    STATS = regionprops(roiImg, 'BoundingBox');
    width =  STATS.BoundingBox(3);
    height =  STATS.BoundingBox(4);
else
    [height, width] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, options);
end

set(handles.heightEdit, 'String', num2str(height));
handles.origWidth = width;
if handles.h.Img{handles.h.Id}.I.orientation == 1
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.z/handles.h.Img{handles.h.Id}.I.pixSize.x;
elseif handles.h.Img{handles.h.Id}.I.orientation == 2
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.z/handles.h.Img{handles.h.Id}.I.pixSize.y;
elseif handles.h.Img{handles.h.Id}.I.orientation == 4
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.x/handles.h.Img{handles.h.Id}.I.pixSize.y;
end
set(handles.widthEdit, 'String', num2str(ceil(width)));
handles.origHeight = height;
handles.resizedWidth = width;
% Update handles structure
guidata(hObject, handles);
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
set(handles.continueBtn, 'BackgroundColor', 'r');
drawnow;
% update handles
handles.h = guidata(handles.h.im_browser);

handles.output = get(handles.outputDir,'String');

codecList = get(handles.codecPopup,'String');
codec = codecList{get(handles.codecPopup,'Value')};
quality = str2double(get(handles.qualityEdit,'String'));
frame_rate = str2double(get(handles.framerateEdit,'String'));

options.resize = 'no';
options.mode = 'full';
if get(handles.shownAreaRadio,'Value')   % saving only the shown area
    options.mode = 'shown';
end

if exist(handles.output, 'file')
    button = questdlg(sprintf('Warning!\nThe file already exist!\n\nOverwrite?'),...
        'Overwrite?','Overwrite','Cancel','Cancel');
    if strcmp(button, 'Cancel');
        set(handles.continueBtn, 'BackgroundColor', 'g');
        return;
    end;
end

try
    writerObj = VideoWriter(handles.output, codec);
catch err
    msgbox(sprintf('Can''t create the video file, it might be opened elsewhere...\n\n%s',err.identifier),'Error!','error','modal');
    set(handles.continueBtn, 'BackgroundColor', 'g');
    return;
end

%warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');    % switch off warnings for latex
curInt = get(0, 'DefaulttextInterpreter');
set(0, 'DefaulttextInterpreter', 'none');

wb = waitbar(0,sprintf('%s\nPlease wait...',handles.output),'Name','Rendering the movie...','WindowStyle','modal');
waitbar(0, wb);

writerObj.FrameRate = frame_rate;
if ~strcmp(codec, 'Archival') && ~strcmp(codec, 'Uncompressed AVI') && ~strcmp(codec, 'Motion JPEG 2000')
    writerObj.Quality=quality;
end

newWidth = str2double(get(handles.widthEdit, 'String'));
newHeight = str2double(get(handles.heightEdit, 'String'));

methodVal = get(handles.resizeMethodPopup, 'Value');
methodList = get(handles.resizeMethodPopup, 'String');
scalebarSwitch = get(handles.scalebarCheck, 'Value');

startPoint = str2double(get(handles.firstFrameEdit, 'String'));
lastPoint = str2double(get(handles.lastFrameEdit, 'String'));

if get(handles.directionPopup, 'value') == 1    % z-stack
    if handles.h.Img{handles.h.Id}.I.orientation == 4
        maxZ = handles.h.Img{handles.h.Id}.I.no_stacks;
    elseif handles.h.Img{handles.h.Id}.I.orientation == 1
        maxZ = handles.h.Img{handles.h.Id}.I.height;
    elseif handles.h.Img{handles.h.Id}.I.orientation == 2
        maxZ = handles.h.Img{handles.h.Id}.I.width;
    end
    zStackSwitch = 1;
    timePoint = handles.h.Img{handles.h.Id}.I.slices{5}(1);
else
    maxZ = handles.h.Img{handles.h.Id}.I.time;
    zStackSwitch = 0;
    sliceNo = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
end
if maxZ<lastPoint
    msgbox(sprintf('Please check the last frame number!\nIt should be not larger than %d', maxZ),'Error!','error','modal');
    set(handles.continueBtn, 'BackgroundColor', 'g');
    delete(wb);
    return;
end
noFrames = lastPoint-startPoint+1;

tic
open(writerObj);
if get(handles.roiRadio, 'value')
    roiList = get(handles.h.roiList, 'string');
    roiImg = handles.h.Img{handles.h.Id}.I.hROI.returnMask(roiList{get(handles.h.roiList, 'value')});
    STATS = regionprops(roiImg, 'BoundingBox');
end
options.markerType = 'both';

% generate the frame indices
framePnts = startPoint:lastPoint;
if get(handles.backandforthCheck, 'value')  % add reverse direction
    framePnts = [framePnts lastPoint:-1:startPoint];
end
noFrames = numel(framePnts);

index = 1;
for frame = framePnts
    if zStackSwitch
        options.sliceNo = frame;
        options.t = [timePoint timePoint];
    else
        options.sliceNo = sliceNo;
        options.t = [frame frame];
    end
    img = handles.h.Img{handles.h.Id}.I.getRGBimage(handles.h, options);
    if get(handles.roiRadio, 'value')
        img = imcrop(img, STATS.BoundingBox);
    end
    
    scale = newWidth/size(img, 2);
    if newWidth ~= handles.origWidth || newHeight ~= handles.origHeight   % resize the image
        img = imresize(img, [newHeight newWidth], methodList{methodVal});
    end
    
    % convert to uint8
    if isa(img, 'uint16')
        img = uint8(img/255);
    end
    
    if index == 1
        if scalebarSwitch  % add scale bar
            img2 = addScaleBar(img, handles.h.Img{handles.h.Id}.I.pixSize, scale, handles.h.Img{handles.h.Id}.I.orientation);
            scaleBar = img2(size(img2,1)-(size(img2,1)-size(img,1)-1):size(img2,1),:,:);
            img = img2;
        end
    else
        if scalebarSwitch  % add scale bar
            img = cat(1, img, scaleBar);
        end
    end
    writeVideo(writerObj,im2frame(img));
    if mod(frame,10)==0; waitbar(index/noFrames, wb); end;
    index = index + 1;
end
% % add reverse direction
% if get(handles.backandforthCheck, 'value')
%     for frame = lastPoint:-1:startPoint
%         options.sliceNo = frame;
%         img = handles.h.Img{handles.h.Id}.I.getRGBimage(handles.h, options);
%         if get(handles.roiRadio, 'value')
%             img = imcrop(img, STATS.BoundingBox);
%         end
%         
%         scale = newWidth/size(img, 2);
%         if newWidth ~= handles.origWidth || newHeight ~= handles.origHeight   % resize the image
%             img = imresize(img, [newHeight newWidth], methodList{methodVal});
%         end
%         
%         if scalebarSwitch  % add scale bar
%             img = cat(1, img, scaleBar);
%         end
%         
%         writeVideo(writerObj,im2frame(img));
%         if mod(frame,10)==0; waitbar((frame-startPoint)/noFrames, wb); end;
%     end
% end
toc
close(writerObj);
disp(['im_browser: save movie ' handles.output]);
delete(wb);
set(0, 'DefaulttextInterpreter', curInt);

set(handles.continueBtn, 'BackgroundColor', 'g');

% Update handles structure
guidata(hObject, handles);
[~,fn,ext] = fileparts(handles.output);
update_filelist(handles.h, [fn ext]);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_saveVideoGui);
end

function I = addScaleBar(I, pixSize, scale, orientation)
% Fuse text into an image I
% based on original code by by Davide Di Gloria
% http://www.mathworks.com/matlabcentral/fileexchange/26940-render-rgb-text-over-rgb-or-grayscale-image
% I=renderText(I, text)
% text -> cell with text

base=uint8(1-logical(imread('chars.bmp')));
table='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890''?!"?$%&/()=?^?+???,.-<\|;:_>????*@#[]{} ';

if orientation == 4
    pixelSize = pixSize.x/scale;
elseif orientation == 1
    pixelSize = pixSize.x/scale;
elseif orientation == 2
    pixelSize = pixSize.y/scale;
end

width = size(I,2);
height = size(I,1);

%scaleBarText = sprintf('%.3f %s',width*pixelSize/10, pixSize.units);
%scaleBarLength = round(width/10);

targetStep = width*pixelSize/10;  % targeted length of the scale bar in units
mag = floor(log10(targetStep));     % magnitude of the scale bar
magPow = power(10, mag);
magDigit = floor(targetStep/magPow + 0.5);
roundStep = magDigit*magPow;    % rounded step
if mag < 0
    strText = ['scaleBarText = sprintf(''%.' num2str(abs(mag)) 'f %s'', roundStep, pixSize.units);'];
    eval(strText);
else
    scaleBarText = sprintf('%d %s', roundStep, pixSize.units);
end
scaleBarLength = round(roundStep/pixelSize);

shiftX = 5;     % shift of the scale bar from the left corner
text_str = scaleBarText;
if scaleBarLength+shiftX*2+(numel(text_str)*12) > width
    scaleBarText = sprintf('%.2f %s',width*pixelSize/10, pixSize.units);
    scaleBarLength = round(width/10);
    shiftX = 5;     % shift of the scale bar from the left corner
    text_str = scaleBarText;
end

n = numel(text_str);
ColorsNumber = size(I, 3);

coord(2,n)=0;
for i=1:n
    coord(:,i)= [0 find(table == text_str(i))-1];
end
m = floor(coord(2,:)/26);
coord(1,:) = m*20+1;
coord(2,:) = (coord(2,:)-m*26)*13+1;

model = zeros(22,size(I,2),size(I,3), class(I));
total_index = 1;
max_int = double(intmax(class(I)));

if scaleBarLength+shiftX*2+(numel(text_str)*12) > width
    %msgbox(sprintf('Image is too small to put the scale bar!\nSaving image without the scale bar...'),'Scale bar','warn');
    return;
end
for index = 1:numel(text_str)
    model(1:20, scaleBarLength+shiftX*2+(12*index-11):scaleBarLength+shiftX*2+(index*12), :) = repmat(imcrop(base,[coord(2,total_index) coord(1,total_index) 11 19])*max_int, [1, 1, ColorsNumber]);
    total_index = total_index + 1;
end
% add scale
model(10:12, shiftX:shiftX+scaleBarLength-1,:) = repmat(max_int, [3, scaleBarLength, ColorsNumber]);
model(8:14, shiftX,:) = repmat(max_int, [7, 1, ColorsNumber]);
model(8:14, shiftX+scaleBarLength-1,:) = repmat(max_int, [7, 1, ColorsNumber]);

I = cat(1, I, model);
end


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
handles.output = NaN;

% store filename for video file
handles.h = guidata(handles.h.im_browser);
handles.h.video_fn = get(handles.outputDir,'String');
guidata(handles.h.im_browser, handles.h);

% Update handles structure
guidata(hObject, handles);

delete(handles.ib_saveVideoGui);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
% uiresume(handles.ib_saveVideoGui);
end


function outputDir_Callback(hObject, eventdata, handles)
fn = get(handles.outputDir,'String');
if isequal(fn, 0);
    set(handles.outputDir,'String', handles.fn_out);
    return;
end

if exist(fn, 'file')
    button = questdlg(sprintf('Warning!\nThe file already exist!\n\nOverwrite?'),...
        'Overwrite?','Cancel','Overwrite','Cancel');
    if strcmp(button, 'Cancel'); return; end;
end
handles.fn_out = fn;
% Update handles structure
guidata(hObject, handles);
end

% --- Executes on button press in selectFileBtn.
function selectFileBtn_Callback(hObject, eventdata, handles)
formatValue = get(handles.codecPopup, 'Value');
if formatValue == 1
    formatText = {'*.mj2', 'Motion JPEG 2000 file with lossless compression (*.mj2)'};
elseif formatValue == 2
    formatText = {'*.avi', 'Compressed AVI file using Motion JPEG codec (*.avi)'};
elseif    formatValue == 3
    formatText = {'*.mj2', 'Compressed Motion JPEG 2000 file (*.mj2)'};
elseif    formatValue == 4
    formatText = {'*.mp4', 'Compressed MPEG-4 file with H.264 encoding (Windows 7 systems only) (*.mp4)'};
elseif    formatValue == 5
    formatText = {'*.avi', 'Uncompressed AVI file with RGB24 video (*.avi)'};
end
%[FileName,PathName,FilterIndex] = uiputfile(cellstr(formatText), ''Windows Bitmap (*.bmp)'''}, 'Select filename', handles.fn_out);
[FileName,PathName,FilterIndex] = ...
    uiputfile(formatText, 'Select filename', handles.fn_out);
if isequal(FileName,0) || isequal(PathName,0); return; end;

handles.fn_out = fullfile(PathName, FileName);
set(handles.outputDir,'String', handles.fn_out);

% Update handles structure
guidata(hObject, handles);
end

% --- Executes on selection change in codecPopup.
function codecPopup_Callback(hObject, eventdata, handles)
value = get(handles.codecPopup, 'Value');
fn = get(handles.outputDir, 'String');
[path, fn, ~] = fileparts(fn);
set(handles.qualityEdit, 'enable', 'on');
if value == 1 || value == 3
    fn = fullfile(path, [fn '.mj2']);
    set(handles.qualityEdit, 'enable', 'off');
elseif value == 4
    fn = fullfile(path, [fn '.mp4']);
elseif value == 5   % uncomressed AVI
    fn = fullfile(path, [fn '.avi']);
    set(handles.qualityEdit, 'enable', 'off');
elseif value == 2   % Motion JPEG AVI
    fn = fullfile(path, [fn '.avi']);
end
set(handles.outputDir, 'String', fn);
handles.fn_out = fn;

% Update handles structure
guidata(hObject, handles);
end

function widthEdit_Callback(hObject, eventdata, handles)
newWidth = str2double(get(handles.widthEdit, 'String'));
ratio = handles.origHeight/handles.resizedWidth;
newHeight = round(newWidth*ratio);
set(handles.heightEdit, 'String',num2str(newHeight));
end

function heightEdit_Callback(hObject, eventdata, handles)
newHeight = str2double(get(handles.heightEdit, 'String'));
ratio = handles.origHeight/handles.resizedWidth;
newWidth = round(newHeight/ratio);
set(handles.widthEdit, 'String',num2str(newWidth));
end



function framerateEdit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if val < 1
    set(hObject,'String','5');
    msgbox('The frame rate should be a positive number','Error!','error','modal');
end
end

function qualityEdit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if val < 1 || val > 100
    set(hObject,'String','85');
    msgbox('The frame rate should be a positive from 0 through 100.','Error!','error','modal');
end
end


% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_gui_menu_file_makevideo.html'), '-helpbrowser');
end



function firstFrameEdit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val); set(hObject, 'String','1'); return; end;
options.blockModeSwitch = 1;
[~, ~, ~, z] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, options);
if val < 1 || val > z
    msgbox(sprintf('Wrong number of the starting frame\nit should be in range: %d - %d', 1, z-1), 'Error', 'error');
    set(hObject, 'String','1');
    return;
end
end


function lastFrameEdit_Callback(hObject, eventdata, handles)
handles.h = guidata(handles.h.im_browser);
val = str2double(get(hObject, 'String'));
options.blockModeSwitch = 1;
[~, ~, ~, z] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, options);
if isnan(val); set(hObject, 'String',num2str(z)); return; end;
if val < 1 || val > z
    msgbox(sprintf('Wrong number of the last frame\nit should be in range: %d - %d', 2, z), 'Error', 'error');
    set(hObject, 'String',num2str(z));
    return;
end
end


% --- Executes on key press with focus on ib_saveVideoGui and none of its controls.
function ib_saveVideoGui_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ib_saveVideoGui (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    cancelBtn_Callback(handles.cancelBtn, eventdata, handles);
end

if isequal(get(hObject,'CurrentKey'),'return')
    continueBtn_Callback(handles.continueBtn, eventdata, handles)
end
end

% --- Executes on button press in scalebarCheck.
function scalebarCheck_Callback(hObject, eventdata, handles)
handles.h = guidata(handles.h.im_browser);
if get(handles.scalebarCheck, 'value') == 1
    handles.h.Img{handles.h.Id}.I.updateParameters();
    guidata(handles.h.im_browser, handles.h);
end

end


% --- Executes on selection change in directionPopup.
function directionPopup_Callback(hObject, eventdata, handles)
val = get(handles.directionPopup, 'value');
if val == 1     % make video of a z-stack
    set(handles.lastFrameEdit, 'string', num2str(handles.h.Img{handles.h.Id}.I.no_stacks));
else            % make video of a time series
    set(handles.lastFrameEdit, 'string', num2str(handles.h.Img{handles.h.Id}.I.time));
end
end