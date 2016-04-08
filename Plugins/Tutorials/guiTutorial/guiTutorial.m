function varargout = guiTutorial(varargin)
% GUITUTORIAL MATLAB code for guiTutorial.fig
%      GUITUTORIAL, by itself, creates a new GUITUTORIAL or raises the existing
%      singleton*.
%
%      H = GUITUTORIAL returns the handle to a new GUITUTORIAL or the handle to
%      the existing singleton*.
%
%      GUITUTORIAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUITUTORIAL.M with the given input arguments.
%
%      GUITUTORIAL('Property','Value',...) creates a new GUITUTORIAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiTutorial_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiTutorial_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 16.04.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% Last Modified by GUIDE v2.5 07-Apr-2016 20:17:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiTutorial_OpeningFcn, ...
                   'gui_OutputFcn',  @guiTutorial_OutputFcn, ...
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


% --- Executes just before guiTutorial is made visible.
function guiTutorial_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiTutorial (see VARARGIN)

%! get the handle of the main im_browser window 
h_im_browser = varargin{3};

%! get the handles structure of the main program (im_browser):
% handles.[tag] - give access to all widgets of the plugin window, while
% handles.h.[tag] - give access to all widgets of im_browser
handles.h = guidata(h_im_browser);

% update font and size of the GUI window, required for better visualization
% of the GUI on different operating systems.
% Remember, that the Units of widgets and the main window should be points!

% NOTE 1: you may need to replace "handles.textInfo" with a text field tag of your own GUI
if get(handles.textInfo, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.textInfo, 'fontname'), handles.h.preferences.Font.FontName)
    
    % call a function to update font name and size
    % NOTE 2: you have to replace "handles.guiTutorial" with tag of
    % your own GUI
    ib_updateFontSize(handles.guiTutorial, handles.h.preferences.Font);
end

% resize all elements x1.5 times for macOS and x1.25 for Linux
% NOTE 3: you have to replace "handles.guiTutorial" with tag of
% your own GUI
mib_rescaleWidgets(handles.guiTutorial);

% update information about dataset dimensions in pixels
options.blockModeSwitch=0;  
[height, width, ~, no_stacks, time] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4, 0, options);
% force to switch off the BlockMode to make sure that dimensions of the whole dataset will be returned
% 'image' - indicates type of the layer to get dimensions (other options: 'model','mask','selection')
% 4 - forces to return dimensions of the dataset in the original (XY) orientation.
% 0 - requires to return number of all color channels of the dataset (not important in this routine)

% generate information string
infoString = sprintf('%d x %d x %d x %d', width, height, no_stacks, time);  
% place the information string to the textInfo2 field
set(handles.textInfo2, 'string', infoString);   

% update widthEdit and heightEdit with width and height parameters of the dataset
set(handles.widthEdit, 'string', num2str(width));
set(handles.heightEdit, 'string', num2str(height));

% Choose default command line output for guiTutorial
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiTutorial wait for user response (see UIRESUME)
% uiwait(handles.guiTutorial);


% --- Outputs from this function are returned to the command line.
function varargout = guiTutorial_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.guiTutorial);    % delete the window


function widthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to widthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of widthEdit as text
%        str2double(get(hObject,'String')) returns contents of widthEdit as a double

% get dataset dimensions
% force to switch off the BlockMode switch, to get dimensions of the whole dataset
options.blockModeSwitch=0;  
[height, width, ~, ~] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4, 0, options);

% get entered new width
newWidth = str2double(get(handles.widthEdit,'string')); 
% calculate height/width ratio
ratio = height/width;
% calculate new height
newHeight = round(newWidth*ratio);

% update the height edit box to preserve the ratio
set(handles.heightEdit, 'string', num2str(newHeight)); 


function heightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to heightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of heightEdit as text
%        str2double(get(hObject,'String')) returns contents of heightEdit as a double

% get dataset dimensions
% force to switch off the BlockMode switch, to get dimensions of the whole dataset
options.blockModeSwitch=0;  
[height, width, ~, ~] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4, NaN, options);

% get entered new height
newHeight = str2double(get(handles.heightEdit,'string'));
% calculate height/width ratio
ratio = height/width;
% calculate new width
newWidth = round(newHeight/ratio);
% update the height edit box to preserve the ratio
set(handles.widthEdit, 'string', num2str(newWidth));


% --- Executes on button press in cropRadio.
function buttonGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to cropRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cropRadio

% get identifier of the radio button
tag = get(hObject, 'tag');

% disable all elements
set(handles.widthEdit,'enable', 'off');
set(handles.heightEdit,'enable', 'off');
set(handles.xminEdit,'enable', 'off');
set(handles.yminEdit,'enable', 'off');
set(handles.convertPopup,'enable', 'off');

% tweak some of gui to visualize only required elements of GUI
switch tag
    case 'cropRadio'
        set(handles.widthEdit,'enable', 'on');
        set(handles.heightEdit,'enable', 'on');
        set(handles.xminEdit,'enable', 'on');
        set(handles.yminEdit,'enable', 'on');  
        set(handles.textWidth, 'String', 'X max:');
        set(handles.textHeight, 'String', 'Y max:');
    case 'resizeRadio'
        set(handles.widthEdit,'enable', 'on');
        set(handles.heightEdit,'enable', 'on');        
        set(handles.textWidth, 'String', 'Image width:');
        set(handles.textHeight, 'String', 'Image height:');
    case 'convertRadio'
        set(handles.convertPopup,'enable', 'on');
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
% hObject    handle to continueBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get parameters from the gui
xmin = str2double(get(handles.xminEdit,'string'));
ymin = str2double(get(handles.yminEdit,'string'));
width = str2double(get(handles.widthEdit,'string'));
height = str2double(get(handles.heightEdit,'string'));
list = get(handles.convertPopup,'string');
listValue = get(handles.convertPopup,'value');
convertTo = list{listValue};

% start functions that perform required actions
% the function can be inside this file of stored in the plugin directory
if get(handles.convertRadio, 'value')   % convert image
    convertImage(handles, convertTo);
elseif get(handles.resizeRadio,'value') % resize image
    resizeImage(handles, width, height);
elseif get(handles.cropRadio, 'value')  % crop image
    cropDataset(handles, xmin, ymin, width, height)
end


function convertImage(handles, convertTo)
% convert dataset to a different image class

% get the whole dataset
% the 'image' parameter defines that the image is required
% The function returns a cell array with the image(s);
% since the whole dataset should be converted, so the blockModeSwitch should be forced to be 0
options.blockModeSwitch = 0; 
img = ib_getDataset('image', handles.h, 4, 0, options);

classFrom = class(img{1});  % get current image class
if strcmp(convertTo, 'uint16')  % convert to uint16 class
    % calculate stretching coefficient
    coef = double(intmax('uint16')) / double(intmax(class(img{1})));
    
    % convert stretch dataset to uint16
    img{1} = uint16(img{1})*coef;
    
else                            % convert to uint8 class
    % calculate stretching coefficient
    coef = double(intmax('uint8')) / double(intmax(class(img{1})));
    
    % convert stretch dataset to uint16
    img{1} = uint8(img{1}*coef);
end

% update dataset in im_browser
ib_setDataset('image', img, handles.h, 4, 0, options);

% when the image class has been changed it is important to update the handles.h.Img{handles.h.Id}.I.viewPort structure.
handles.h.Img{handles.h.Id}.I.updateDisplayParameters();

% generate log text with description of the performed actions, the log can be accessed with the Log button in the Path
% panel
log_text = sprintf('Converted from %s to %s', classFrom, class(img{1}));
handles.h.Img{handles.h.Id}.I.updateImgInfo(log_text);

% update widgets in the im_browser GUI
handles.h = updateGuiWidgets(handles.h);

% redraw image in the im_browser axes
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 1);

% close guiTutorial window
delete(handles.guiTutorial);

function resizeImage(handles, width, height)
% resize dataset and all other layers

% get the whole dataset
% the 'image' parameter defines that the image is required
% The function returns a cell with the image, because
% complete dataset should be resized, the blockModeSwitch is forced to be 0
options.blockModeSwitch = 0; 
img = ib_getDataset('image', handles.h, NaN, 0, options);

% allocate memory for the output dataset
imgOut = zeros([height, width, size(img{1},3),size(img{1},4) size(img{1},5)], class(img{1}));

% loop the time dimension
for t=1:size(img{1},5)
    % loop the depth dimension
    for slice = 1:size(img{1},4)
        imgOut(:,:,:,slice,t) = imresize(img{1}(:,:,:,slice,t),[height, width],'bicubic');
    end
end

% update the image, the image should be sent as a cell
ib_setDataset('image', {imgOut}, handles.h, NaN, 0, options);

% in addition it is needed to resize the other existing layers (Selection, Mask and Model).
% it can be done in a single step when the uint6 type of the model is used (handles.h.Img{handles.h.Id}.I.model_type=='uint6') or one by one
% when it is uint8 type (handles.h.Img{handles.h.Id}.I.model_type=='uint8').
if strcmp(handles.h.Img{handles.h.Id}.I.model_type, 'uint6')
    % get everything, i.e. it take in one step all three layers
    img = ib_getDataset('everything', handles.h, NaN, NaN, options);
    % allocate memory for the output dataset
    imgOut = zeros([height, width, size(img{1},3),size(img{1},4)], class(img{1}));
    for t=1:size(img{1},4)
        for slice = 1:size(img{1},3)
            % it is important to use nearest resizing method for these layers
            imgOut(:,:,slice,t) = imresize(img{1}(:,:,slice,t),[height, width],'nearest');
        end
    end
    % update the service layers, the image should be sended as a cell
    ib_setDataset('everything', {imgOut}, handles.h, NaN, NaN, options);
else    % when the uint8 type of model
    list = {'selection','model','mask'}; % generate list of layers
    for layer = 1:numel(list)
        if strcmp(list{layer},'mask') && handles.h.Img{handles.h.Id}.I.maskExist == 0;
            % skip when no mask
            continue;
        end
        if strcmp(list{layer},'model') && handles.h.Img{handles.h.Id}.I.modelExist == 0;
            % skip when no model
            continue;
        end
        % do resizing
        img = ib_getDataset(list{layer}, handles.h, NaN, NaN, options);
        % allocate memory for the output dataset
        imgOut = zeros([height, width, size(img{1},3),size(img{1},4)], 'uint8');
        for t=1:size(img{1},4)
            for slice = 1:size(img{1},3)
                % it is important to use nearest resizing method for these layers
                imgOut(:,:,slice,t) = imresize(img{1}(:,:,slice,t),[height, width],'nearest');
            end
        end
        % update the layer, the image should be sended as a cell
        ib_setDataset(list{layer}, {imgOut}, handles.h, NaN, NaN, options);
    end
end

% generate log text with description of the performed actions, the log can be accessed with the Log button in the Path
% panel
log_text = sprintf('Resized to (height x width) %d x %d', height, width);
handles.h.Img{handles.h.Id}.I.updateImgInfo(log_text);

% update pixel size for the x and y. The z was not changed
handles.h.Img{handles.h.Id}.I.pixSize.x = ...
    handles.h.Img{handles.h.Id}.I.pixSize.x/height*size(img{1},1);
handles.h.Img{handles.h.Id}.I.pixSize.y = ...
    handles.h.Img{handles.h.Id}.I.pixSize.y/height*size(img{1},1);
handles.h.Img{handles.h.Id}.I.pixSize.z = ...
    handles.h.Img{handles.h.Id}.I.pixSize.z;

% update img_info XResolution and YResolution
resolution = ib_calculateResolution(handles.h.Img{handles.h.Id}.I.pixSize);
handles.h.Img{handles.h.Id}.I.img_info('XResolution') = resolution(1);
handles.h.Img{handles.h.Id}.I.img_info('YResolution') = resolution(2);
handles.h.Img{handles.h.Id}.I.img_info('ResolutionUnit') = 'Inch';

% update widgets in the im_browser GUI
handles.h = updateGuiWidgets(handles.h);

% because the dataset was resized the image axes should be updated!
handles.h = handles.h.Img{handles.h.Id}.I.updateAxesLimits(handles.h, 'resize');

% redraw image in the im_browser axes
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 1);

% close guiTutorial window
delete(handles.guiTutorial);

function cropDataset(handles, xmin, ymin, xmax, ymax)
% crop the dataset in xy dimension keeping the number of stacks intact


% get the whole dataset
% the 'image' parameter defines that the image is required
% The function returns a cell with the image, because
% complete dataset should be cropped, the blockModeSwitch is forced to be 0
options.blockModeSwitch = 0; 
img = ib_getDataset('image', handles.h, NaN, 0, options);

% crop the dataset
img{1} = img{1}(ymin:ymax, xmin:xmax, : , :, :);

% update the image layer
ib_setDataset('image', img, handles.h, NaN, 0, options);

% in addition it is needed to resize the other existing layers
% (Selection, Mask and Model).
% it can be done in a single step when the uint6 type of the model 
% is used (handles.h.Img{handles.h.Id}.I.model_type=='uint6') or one by one
% when it is uint8 type (handles.h.Img{handles.h.Id}.I.model_type=='uint8').
if strcmp(handles.h.Img{handles.h.Id}.I.model_type, 'uint6')
    % get everything, i.e. it take in one step all three layers (selection, mask, model)
    img = ib_getDataset('everything', handles.h, NaN, NaN, options);
    img{1} = img{1}(ymin:ymax, xmin:xmax, :, :);
    % update the layers
    ib_setDataset('everything', img, handles.h, NaN, NaN, options);
else    % when the uint8 type of model
    list = {'selection','model','mask'};
    for layer = 1:numel(list)
        if strcmp(list{layer},'mask') && handles.h.Img{handles.h.Id}.I.maskExist == 0;
            % skip when no mask
            continue;
        end
        if strcmp(list{layer},'model') && handles.h.Img{handles.h.Id}.I.modelExist == 0;
            % skip when no model
            continue;
        end
        % do crop
        img = ib_getDataset(list{layer}, handles.h, NaN, NaN, options);
        
        img{1} = img{1}(ymin:ymax, xmin:xmax, :, :);
        
        % update the layer, the image should be sended as a cell
        ib_setDataset(list{layer}, img, handles.h, NaN, NaN, options);
    end
end

% update the log text
log_text = sprintf('Crop: [x1 x2 y1 y2]: %d %d %d %d', xmin, xmax, ymin, ymax);
handles.h.Img{handles.h.Id}.I.updateImgInfo(log_text);

% during the crop the BoundingBox is changed, so it should be fixed.
% calculate the shift of the coordinates in the dataset units
%xyzShift = [xmin-1 ymin-1 0];

% shift of the bounding box in X
xyzShift(1) = (xmin-1)*handles.h.Img{handles.h.Id}.I.pixSize.x; 
% shift of the bounding box in Y
xyzShift(2) = (ymin-1)*handles.h.Img{handles.h.Id}.I.pixSize.y; 
% shift of the bounding box in Z
xyzShift(3) = 0;   
% update BoundingBox Coordinates
handles.h.Img{handles.h.Id}.I.updateBoundingBox(NaN, xyzShift);    

% because the dataset was resized the image axes should be updated!
handles.h = handles.h.Img{handles.h.Id}.I.updateAxesLimits(handles.h, 'resize');

% redraw image in the im_browser axes
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 1);

% close guiTutorial window
delete(handles.guiTutorial);
