function varargout = ib_snapshotGui(varargin)
% function varargout = ib_snapshotGui(varargin)
% ib_snapshotGui function is responsible for making snapshots of the shown dataset.
%
% ib_snapshotGui contains MATLAB code for ib_snapshotGui.fig

% Copyright (C) 21.08.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 19.01.2016 fix of the scale bar during resizing of images
% 19.01.2016 use of rounded values in the scale bar
% 19.04.2016 added split color channels mode

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ib_snapshotGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_snapshotGui_OutputFcn, ...
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


% --- Executes just before ib_snapshotGui is made visible.
function ib_snapshotGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_snapshotGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser
handles.fn_out = varargin{2};     % filename of the output file

% set Size of the window
winPos = get(handles.ib_snapshotGui, 'Position');
set(handles.ib_snapshotGui, 'Position', [winPos(1) winPos(1) 335 winPos(4)]);

set(handles.jpgPanel,'parent', get(handles.tifPanel, 'parent'));
set(handles.bmpPanel,'parent', get(handles.tifPanel, 'parent'));

% set callback for the target radio panel
set(handles.targetRadioPanel,'SelectionChangeFcn',@radioBtns_Callback);
% set callback for the crop radio panel
set(handles.cropPanel,'SelectionChangeFcn',@crop_Callback);

[~, ~, ext] = fileparts(handles.fn_out);
if strcmp(ext(2:end), 'jpg')
    set(handles.fileFormatPopup, 'Value', 2);
    fileFormatPopup_Callback(handles.fileFormatPopup, eventdata, handles);
elseif strcmp(ext(2:end), 'bmp')
    set(handles.fileFormatPopup, 'Value', 1);
    fileFormatPopup_Callback(handles.fileFormatPopup, eventdata, handles);
end
set(handles.outputDir, 'String', handles.fn_out);
options.blockModeSwitch = 1;
[height, width] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, options);
handles.origWidth = width;

if handles.h.Img{handles.h.Id}.I.orientation == 1
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.z/handles.h.Img{handles.h.Id}.I.pixSize.x;
elseif handles.h.Img{handles.h.Id}.I.orientation == 2
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.z/handles.h.Img{handles.h.Id}.I.pixSize.y;
elseif handles.h.Img{handles.h.Id}.I.orientation == 4
    width = width*handles.h.Img{handles.h.Id}.I.pixSize.x/handles.h.Img{handles.h.Id}.I.pixSize.y;
end
set(handles.widthEdit, 'String', num2str(ceil(width)));
set(handles.heightEdit, 'String', num2str(height));

handles.origHeight = height;
handles.resizedWidth = width;

% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_snapshotGui, handles.h.preferences.Font);
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

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_snapshotGui);

% Choose default command line output for ib_snapshotGui
handles.output = NaN;

%% set background color to panels and texts
set(handles.ib_snapshotGui,'Color',[.831 .816 .784]);
tempList = findall(handles.ib_snapshotGui,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);

tempList = findall(handles.ib_snapshotGui,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_snapshotGui,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_snapshotGui,'Style','radiobutton');    % set color to radiobutton
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.ib_snapshotGui,'Type','uibuttongroup');    % set color to uibuttongroup
set(tempList,'BackgroundColor',[.831 .816 .784]);

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

settingsPanelPosition = get(handles.tifPanel, 'Position');
settingsPanelParent = get(handles.tifPanel, 'Parent');

set(handles.jpgPanel, 'Parent', settingsPanelParent);
set(handles.bmpPanel, 'Parent', settingsPanelParent);

set(handles.jpgPanel, 'Position', settingsPanelPosition);
set(handles.bmpPanel, 'Position', settingsPanelPosition);


% Update handles structure
guidata(hObject, handles);

% Make the GUI modal
% set(handles.ib_snapshotGui,'WindowStyle','modal');

% UIWAIT makes ib_snapshotGui wait for user response (see UIRESUME)
% uiwait(handles.ib_snapshotGui);

end

% --- Outputs from this function are returned to the command line.
function varargout = ib_snapshotGui_OutputFcn(hObject, eventdata, handles) 
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
    varargout{1} = NaN;
end

end

function crop_Callback(hObject, eventdata)
handles = guidata(hObject);
handles.h = guidata(handles.h.im_browser);
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
    width =  ceil(STATS.BoundingBox(3));
    height =  ceil(STATS.BoundingBox(4));
else
    [height, width] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, options);
end
handles.origWidth = width;
set(handles.heightEdit, 'String', num2str(height));
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

text_str = scaleBarText;
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
shiftX = 5;     % shift of the scale bar from the left corner
if scaleBarLength+shiftX*2+(numel(text_str)*12) > width
    msgbox(sprintf('Image is too small to put the scale bar!\nSaving image without the scale bar...'),'Scale bar','warn');
    return;
end
for index = 1:numel(text_str)
    model(1:20, scaleBarLength+shiftX*2+(12*index-11):scaleBarLength+shiftX*2+(index*12), :) = repmat(double(imcrop(base,[coord(2,total_index) coord(1,total_index) 11 19]))*max_int, [1, 1, ColorsNumber]);
    total_index = total_index + 1;
end
% add scale
model(10:12, shiftX:shiftX+scaleBarLength-1,:) = repmat(max_int, [3, scaleBarLength, ColorsNumber]);
model(8:14, shiftX,:) = repmat(max_int, [7, 1, ColorsNumber]);
model(8:14, shiftX+scaleBarLength-1,:) = repmat(max_int, [7, 1, ColorsNumber]);

I = cat(1, I, model);
end


% --- Executes on button press in closelBtn.
function closelBtn_Callback(hObject, eventdata, handles)
handles.output = NaN;
% Update handles structure
guidata(hObject, handles);

delete(handles.ib_snapshotGui);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
% uiresume(handles.ib_snapshotGui);
end


function outputDir_Callback(hObject, eventdata, handles)
fn = get(handles.outputDir,'String');
[~, ~, ext] = fileparts(fn);
if isempty(ext)
    formatsList= get(handles.fileFormatPopup,'String');
    formatOut= lower(formatsList{get(handles.fileFormatPopup,'Value')});
    fn = strcat(fn, '.', formatOut);
    set(handles.outputDir,'String', fn);
end
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
formatValue = get(handles.fileFormatPopup, 'Value');
if formatValue == 1
    formatText = {'*.bmp', 'Windows Bitmap (*.bmp)'};
elseif formatValue == 2
    formatText = {'*.jpg', 'JPG format (*.jpg)'};
elseif    formatValue == 3
    formatText = {'*.tif', 'TIF format (*.tif)'};
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

function tifRowsPerStrip_Callback(hObject, eventdata, handles)
val = str2double(get(handles.tifRowsPerStrip,'String'));
if mod(val, 8) ~= 0
    msgbox('The RowsPerStrip parameter should be a multiple of 8!','Wrong parameter','error');
    set(handles.tifRowsPerStrip,'String','8000');
    return;
end
end

% --- Executes on selection change in fileFormatPopup.
function fileFormatPopup_Callback(hObject, eventdata, handles)
value = get(handles.fileFormatPopup, 'Value');
set(handles.tifPanel, 'Visible', 'off');
set(handles.jpgPanel, 'Visible', 'off');
set(handles.bmpPanel, 'Visible', 'off');
fn = get(handles.outputDir, 'String');
[path, fn, ~] = fileparts(fn);
if value == 1
    set(handles.bmpPanel, 'Visible', 'on');
    fn = fullfile(path, [fn '.bmp']);
elseif value == 2
    set(handles.jpgPanel, 'Visible', 'on');
    fn = fullfile(path, [fn '.jpg']);
elseif value == 3
    set(handles.tifPanel, 'Visible', 'on');
    fn = fullfile(path, [fn '.tif']);
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

function radioBtns_Callback(hObject, eventdata)
handles = guidata(hObject);
if get(handles.toFileRadio,'Value')
    set(handles.filePanel,'Visible', 'on');
elseif get(handles.clipboardRadio,'Value')
    set(handles.filePanel,'Visible', 'off');
end
end


% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_gui_menu_file_makesnapshot.html'), '-helpbrowser');
end


% --- Executes on key press with focus on ib_snapshotGui and none of its controls.
function ib_snapshotGui_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ib_snapshotGui (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    cancelBtn_Callback(handles.closelBtn, eventdata, handles);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    continueBtn_Callback(handles.snapshotBtn, eventdata, handles);
end   

end

% --- Executes on button press in snapshotBtn.
function snapshotBtn_Callback(hObject, eventdata, handles)
set(handles.snapshotBtn, 'BackgroundColor', 'r');
drawnow;
% update handles
handles.h = guidata(handles.h.im_browser);

handles.output = get(handles.outputDir,'String');

options.resize = 'no';
options.mode = 'full';
options.markerType = 'both';
if get(handles.shownAreaRadio,'Value')   % saving only the shown area
    options.mode = 'shown';
end

if get(handles.splitChannelsCheck, 'value')
    rowNo = str2double(get(handles.rowNoEdit, 'string'));
    colNo = str2double(get(handles.colsNoEdit, 'string'));
    if numel(handles.h.Img{handles.h.Id}.I.slices{3})+1 > rowNo*colNo
        warndlg(sprintf('!!! Warning !!!\n\nNumber of selected color channels is larger than the number of panels in the resulting image!\nIncrease number of columns or rows and try again'),'Too many color channels');
        return;
    end
    maxImageIndex = min([numel(handles.h.Img{handles.h.Id}.I.slices{3})+1 rowNo*colNo]);
    imageShift = str2double(get(handles.marginEdit, 'string'));    % shift between panels
else
    rowNo = 1;
    colNo = 1;
    maxImageIndex = 1;
end

newWidth = str2double(get(handles.widthEdit, 'String'));
newHeight = str2double(get(handles.heightEdit, 'String'));
colorChannels = handles.h.Img{handles.h.Id}.I.slices{3};    % store selected color channels
lutCheckBox = get(handles.h.lutCheckbox, 'value');          % store lut check box status
wb = waitbar(0, sprintf('Generating images\nPlease wait...'),'Name', 'Making snapshot');
for imageId = 1:maxImageIndex
    if imageId == maxImageIndex
        set(handles.h.lutCheckbox, 'value', lutCheckBox);
        handles.h.Img{handles.h.Id}.I.slices{3} = colorChannels;
        if strcmp(get(handles.h.volrenToolbarSwitch, 'state'), 'off')
            img = handles.h.Img{handles.h.Id}.I.getRGBimage(handles.h, options);
        else
            volrenOpt.ImageSize = [newHeight, newWidth];
            scaleRatio = 1/handles.h.Img{handles.h.Id}.I.magFactor;
            S = makehgtform('scale', 1/scaleRatio);
            volrenOpt.Mview = S * handles.h.Img{handles.h.Id}.I.volren.viewer_matrix;
            
%             target=bsxfun(@plus,volrenOpt.Mview(1:3,1:3), volrenOpt.Mview(1:3,end));
%             source=eye(3);
%             E=absor(source, target, 'doScale', 0);
%             R = E.R;
%             x = radtodeg(atan2(R(3,2), R(3,3)));
%             y = radtodeg(atan2(-R(3,1), sqrt(R(3,2)*R(3,2) + R(3,3)*R(3,3))));
%             z = radtodeg(atan2(R(2,1), R(1,1)));
%             z = mod(z, 90);
%             shiftX1 = newWidth*cosd(z);
%             shiftX2 = newHeight*sind(z);
%             shiftY1 = newHeight*sind(z);
%             shiftY2 = newWidth*cosd(z);
%             volrenOpt.ImageSize = [round(shiftY1+shiftY2)*1.2, round(shiftX1+shiftX2)*1.2];
%            
            timePoint = handles.h.Img{handles.h.Id}.I.slices{5}(1);
            img = getRGBvolume(handles.h.Img{handles.h.Id}.I.getData3D('image', timePoint, 4, 0), volrenOpt, handles.h);
        end
    else
        if get(handles.grayscaleCheck, 'value') == 1
            set(handles.h.lutCheckbox, 'value', 0);
        end
        handles.h.Img{handles.h.Id}.I.slices{3} = colorChannels(imageId);
        img = handles.h.Img{handles.h.Id}.I.getRGBimage(handles.h, options);
    end
    
    if get(handles.measurementsCheck,'value')==1
        hFig = figure(153);
        set(hFig, 'Renderer', 'zbuffer');
        clf;
        warning('off','images:initSize:adjustingMag');
        warning('off','MATLAB:print:DeprecateZbuffer');
        
        imshow(img);
        hold on;
        handles.h = handles.h.Img{handles.h.Id}.I.hMeasure.addMeasurementsToPlot(handles.h, options.mode, gca);
        set(gca, 'xtick', []);
        set(gca, 'ytick', []);
        % export to img
        img2 = export_fig('-native','-zbuffer','-a1');
        
        delete(153);
        warning('on','images:initSize:adjustingMag');
        warning('on','MATLAB:print:DeprecateZbuffer');
        % crop the frame
        if handles.h.matlabVersion < 8.4
            img2 = img2(2:end-1, 2:end-1, :);
        end
        % the resulting image is few pixels larger than the original one
        img = imresize(img2, [size(img,1) size(img,2)],'nearest');
    end
    
    if get(handles.roiRadio, 'value')
        roiList = get(handles.h.roiList, 'string');
        roiImg = handles.h.Img{handles.h.Id}.I.hROI.returnMask(roiList{get(handles.h.roiList, 'value')});
        STATS = regionprops(roiImg, 'BoundingBox');
        img = imcrop(img, STATS.BoundingBox);
    end
    
    scale = newWidth/size(img, 2);
    if newWidth ~= handles.origWidth || newHeight ~= handles.origHeight   % resize the image
        methodVal = get(handles.resizeMethodPopup, 'Value');
        methodList = get(handles.resizeMethodPopup, 'String');
        img = imresize(img, [newHeight newWidth], methodList{methodVal});
    end
    
    if get(handles.scalebarCheck, 'Value')  % add scale bar
        img = addScaleBar(img, handles.h.Img{handles.h.Id}.I.pixSize, scale, handles.h.Img{handles.h.Id}.I.orientation);
    end
    
    if maxImageIndex == 1
        imgOut = img;
    else
        if imageId == 1
            outH = size(img, 1);
            outW = size(img, 2);
            colId = 1;
            rowId = 1;
            imgOut = zeros([outH*rowNo + (rowNo-1)*imageShift, outW*colNo + (colNo-1)*imageShift, size(img, 3)], class(img)); %#ok<ZEROLIKE>
        end
        
        y1 = (rowId-1)*outH+1 + imageShift*(rowId-1);
        y2 = y1 + outH - 1;
        x1 = (colId-1)*outW+1 + imageShift*(colId-1);
        x2 = x1 + outW - 1;
        imgOut(y1:y2,x1:x2,:) = img;
        colId = colId + 1;
        if colId > colNo
            colId = 1;
            rowId = rowId + 1;
        end
    end
    waitbar(imageId/maxImageIndex, wb);
end

if get(handles.toFileRadio,'Value')     % saving to a file
    if exist(handles.output, 'file')
        button = questdlg(sprintf('Warning!\nThe file already exist!\n\nOverwrite?'),...
            'Overwrite?','Overwrite','Cancel','Cancel');
        if strcmp(button, 'Cancel'); set(handles.snapshotBtn, 'BackgroundColor', 'g'); return; end;
    end
    formatId = get(handles.fileFormatPopup, 'Value');
    if formatId == 1 % bmp
        parameters = struct();
        if isa(imgOut,'uint8') == 0    % convert to 8bit
            imgOut = im2uint8(imgOut);
        end
    elseif formatId == 2 % jpg
        if isa(imgOut,'uint8') == 0    % convert to 8bit
            imgOut = im2uint8(imgOut);
        end
        parameters.Quality = str2double(get(handles.jpgQuality, 'String'));
        parameters.Bitdepth = str2double(get(handles.jpgBitdepth, 'String'));
        val = get(handles.jpgMode, 'value');
        list = get(handles.jpgMode, 'String');
        parameters.Mode = list{val};
        parameters.Comment = get(handles.jpgComment, 'String');
    elseif formatId == 3 % tif
        val = get(handles.tifCompression, 'value');
        list = get(handles.tifCompression, 'String');
        parameters.Compression = list{val};
        val = get(handles.tifColor, 'value');
        list = get(handles.tifColor, 'String');
        parameters.ColorSpace = list{val};
        parameters.Resolution = str2double(get(handles.tifResolution, 'String'));
        parameters.RowsPerStrip = str2double(get(handles.tifRowsPerStrip, 'String'));
        parameters.Description = get(handles.tifDescription, 'String');
        parameters.WriteMode = 'overwrite';
    end
    
    ib_imwrite(imgOut, handles.output, parameters);
    handles.h.snapshot_fn = handles.output;
    guidata(handles.h.im_browser, handles.h);
elseif get(handles.clipboardRadio,'Value')  % copy to Clipboard
    waitbar(imageId/maxImageIndex, wb, sprintf('Exporting to clipboard\nPlease wait...'));
    imclipboard('copy', imgOut);
end

delete(wb);

% Update handles structure
guidata(hObject, handles);

set(handles.snapshotBtn, 'BackgroundColor', 'g');

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_snapshotGui);
end


% --- Executes on button press in scalebarCheck.
function scalebarCheck_Callback(hObject, eventdata, handles)
% hObject    handle to scalebarCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of scalebarCheck

% update handles
handles.h = guidata(handles.h.im_browser);
if get(handles.scalebarCheck, 'value') == 1
    handles.h.Img{handles.h.Id}.I.updateParameters();
    guidata(handles.h.im_browser, handles.h);
end
end

% --- Executes on button press in measurementsCheck.
function measurementsCheck_Callback(hObject, eventdata, handles)
if get(handles.measurementsCheck,'value') == 1
    warndlg(sprintf('!!! Warning !!!\nAddition of measurements to the snapshot may add artifacts at the borders of the image (at least in R2014b)!\n\nAfter rendering please make sure that the snapshot is good enough for your purposes!'),'Adding measurements')
    set(handles.measurementsOptions,'enable', 'on');
else
    set(handles.measurementsOptions,'enable', 'off');
end
end


% --- Executes on button press in measurementsOptions.
function measurementsOptions_Callback(hObject, eventdata, handles)
handles.h.Img{handles.h.Id}.I.hMeasure.setOptions();
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end


% --- Executes on button press in bin2Btn.
function bin2Btn_Callback(hObject, eventdata, handles)
switch get(hObject, 'tag')
    case 'bin2Btn'
        xFactor = 2;
    case 'bin4Btn'
        xFactor = 4;
    case 'bin8Btn'
        xFactor = 8;
end
width = str2double(get(handles.widthEdit, 'string'));
height = str2double(get(handles.heightEdit, 'string'));
width = ceil(width/xFactor);
height = ceil(height/xFactor);
set(handles.widthEdit, 'string', num2str(width));
set(handles.heightEdit, 'string', num2str(height));
end


% --- Executes on button press in splitChannelsCheck.
function splitChannelsCheck_Callback(hObject, eventdata, handles)
if get(handles.splitChannelsCheck, 'value') == 1
    set(handles.grayscaleCheck, 'enable', 'on');
    set(handles.colsNoEdit, 'enable', 'on');
    set(handles.rowNoEdit, 'enable', 'on');
    set(handles.marginEdit, 'enable', 'on');
else
    set(handles.grayscaleCheck, 'enable', 'off');
    set(handles.colsNoEdit, 'enable', 'off');
    set(handles.rowNoEdit, 'enable', 'off');  
    set(handles.marginEdit, 'enable', 'off');
end
end
