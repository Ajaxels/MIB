function varargout = ib_resampleGui(varargin)
% function varargout = ib_resampleGui(varargin)
% ib_resampleGui function is responsible for resampling of datasets.
%
% ib_resampleGui contains MATLAB code for ib_resampleGui.fig

% Copyright (C) 03.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 04.02.2016, IB, updated for 4D datasets
% 25.04.2016, IB, added tformarray method

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ib_resampleGui_OpeningFcn, ...
    'gui_OutputFcn',  @ib_resampleGui_OutputFcn, ...
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

% --- Executes just before ib_resampleGui is made visible.
function ib_resampleGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_resampleGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser
options.blockModeSwitch = 0;
[handles.height, handles.width, handles.color, handles.zstacks] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image',4,NaN,options);
handles.color = numel(handles.color);

set(handles.modelsMethod, 'String', 'nearest');

% update font and size
if get(handles.text9, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text9, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_resampleGui, handles.h.preferences.Font);
end

% Choose default command line output for ib_resampleGui
handles.output = NaN;

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_resampleGui);

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
resetBtn_Callback(hObject, eventdata, handles);
% Make the GUI modal
set(handles.ib_resampleGui,'WindowStyle','modal');

% UIWAIT makes ib_resampleGui wait for user response (see UIRESUME)
uiwait(handles.ib_resampleGui);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_resampleGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.ib_resampleGui);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
handles.output = NaN;
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_resampleGui);

end

% --- Executes on button press in resampleBtn.
function resampleBtn_Callback(hObject, eventdata, handles)
tic
newW = str2double(get(handles.dimX,'String'));
newH = str2double(get(handles.dimY,'String'));
newZ = str2double(get(handles.dimZ,'String'));
maxT = handles.h.Img{handles.h.Id}.I.time;
if newW == handles.width && newH == handles.height && newZ == handles.zstacks
    warndlg('The dimensions were not changed!','Wrong dimensions','modal');
    return;
end

% define resampled ratio for resampling ROIs
resampledRatio = [newW/handles.width, newH/handles.height, newZ/handles.zstacks];

resamplingFunction = get(handles.resamplingFunction,'String');
resamplingFunction = resamplingFunction(get(handles.resamplingFunction,'value'));
methodList = get(handles.imageMethod,'String');
methodValue = get(handles.imageMethod,'Value');
methodImage = methodList{methodValue};
methodList = get(handles.modelsMethod,'String');
methodValue = get(handles.modelsMethod,'Value');
if isa(methodList, 'char')
    modelsMethod = methodList;
else
    modelsMethod = methodList{methodValue};
end
wb = waitbar(0,sprintf('Resampling image...\n[%d %d %d %d]->[%d %d %d %d]', handles.height, handles.width, handles.color, handles.zstacks,newH,newW,handles.color,newZ),'Name','Resampling ...','WindowStyle','modal');
options.blockModeSwitch=0;

imgOut = zeros([newH,newW,handles.color,newZ,maxT], class(handles.h.Img{handles.h.Id}.I.img));   %#ok<ZEROLIKE> % allocate space
options.height = newH;
options.width = newW;
options.depth = newZ;
options.method = methodImage;
for t=1:maxT
    img = handles.h.Img{handles.h.Id}.I.getData3D('image', t, 4, NaN, options);
    waitbar(0.05,wb);
    % resample image
    if strcmp(resamplingFunction, 'interpn')
        options.showWaitbar = 0;
        options.algorithm = 'interpn';
        imgOut(:,:,:,:,t) = mib_resize3d(img(:,:,:,:,t), [], options);
    elseif strcmp(resamplingFunction, 'imresize')
        options.showWaitbar = 0;
        options.algorithm = 'imresize';
        imgOut(:,:,:,:,t) = mib_resize3d(img(:,:,:,:,t), [], options);
    else
        options.showWaitbar = 0;
        options.algorithm = 'tformarray';
        imgOut(:,:,:,:,t) = mib_resize3d(img(:,:,:,:,t), [], options);
    end
end
clear img;
clear imgOut2;
waitbar(0.5,wb);
handles.h.Img{handles.h.Id}.I.setData4D('image', imgOut, 4, NaN, options);
waitbar(0.55,wb);

% update pixel dimensions
handles.h.Img{handles.h.Id}.I.pixSize.x = handles.h.Img{handles.h.Id}.I.pixSize.x/size(imgOut,2)*handles.width;
handles.h.Img{handles.h.Id}.I.pixSize.y = handles.h.Img{handles.h.Id}.I.pixSize.y/size(imgOut,1)*handles.height;
handles.h.Img{handles.h.Id}.I.pixSize.z = handles.h.Img{handles.h.Id}.I.pixSize.z/size(imgOut,4)*handles.zstacks;

% update img_info
resolution = ib_calculateResolution(handles.h.Img{handles.h.Id}.I.pixSize);
handles.h.Img{handles.h.Id}.I.img_info('XResolution') = resolution(1);
handles.h.Img{handles.h.Id}.I.img_info('YResolution') = resolution(2);
handles.h.Img{handles.h.Id}.I.img_info('ResolutionUnit') = 'Inch';

options.method = modelsMethod;

% resample model and mask
if handles.h.Img{handles.h.Id}.I.modelExist
    waitbar(0.75,wb,sprintf('Resampling model...\n[%d %d %d %d]->[%d %d %d %d]', handles.height, handles.width, handles.color, handles.zstacks,newH,newW,handles.color,newZ));
    imgOut = zeros([newH, newW, newZ, maxT],'uint8');
    model = handles.h.Img{handles.h.Id}.I.getData4D('model', 4, NaN, options);  % have to use getData4D, because getData3D returns the cropped model because of already resized image
    matetialsNumber = numel(handles.h.Img{handles.h.Id}.I.modelMaterialNames);
    for t=1:maxT
        if strcmp(resamplingFunction, 'interpn')
            if strcmp(modelsMethod,'nearest')
                options.showWaitbar = 0;
                options.algorithm = 'interpn';
                imgOut(:,:,:,t) = mib_resize3d(model(:,:,:,t), [], options);
            else
                modelTemp = zeros([newH, newW, newZ],'uint8');
                for materialId = 1:matetialsNumber
                    modelTemp2 = zeros(size(model(:,:,:,t)),'uint8');
                    modelTemp2(model(:,:,:,t) == materialId) = 1;
                    modelTemp2 = mib_resize3d(modelTemp2, [], options);
                    modelTemp(modelTemp2>0.33) = materialId;
                end
                imgOut(:,:,:,t) = modelTemp;
            end
        elseif strcmp(resamplingFunction, 'imresize')
            options.showWaitbar = 0;
            options.algorithm = 'imresize';
            imgOut(:,:,:,t) = mib_resize3d(model(:,:,:,t), [], options);
        else
            options.showWaitbar = 0;
            options.algorithm = 'tformarray';
            imgOut(:,:,:,t) = mib_resize3d(model(:,:,:,t), [], options);
        end
    end
    waitbar(0.95,wb);
    handles.h.Img{handles.h.Id}.I.model = zeros(size(imgOut),'uint8');  % reinitialize .model
    handles.h.Img{handles.h.Id}.I.setData4D('model', imgOut, 4, NaN, options);
elseif strcmp(handles.h.Img{handles.h.Id}.I.model_type, 'uint6')     % when no model, reset handles.Img{andles.Id}.I.model variable
    handles.h.Img{handles.h.Id}.I.model = zeros([size(imgOut,1),size(imgOut,2),size(imgOut,4) size(imgOut,5)],'uint8');    % clear the old model
end

% resampling ROIS
handles.h.Img{handles.h.Id}.I.hROI.resample(resampledRatio);

% update the log
log_text = sprintf('Resample [%d %d %d %d %d]->[%d %d %d %d %d], method: %s', ...
    handles.height, handles.width, handles.color, handles.zstacks, maxT, ...
    newH, newW, handles.color, newZ, maxT, methodImage);
handles.h.Img{handles.h.Id}.I.updateImgInfo(log_text);
% remove slice name if number of z-sections has changed
if isKey(handles.h.Img{handles.h.Id}.I.img_info, 'SliceName') && newZ ~= handles.zstacks
    remove(handles.h.Img{handles.h.Id}.I.img_info, 'SliceName');
end

waitbar(1,wb);
handles.output = handles.h;
delete(wb)
toc;
%profile viewer

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_resampleGui);
end

function editbox_Callback(hObject, eventdata, handles)
return;
if get(handles.dimensionsRadio,'Value')
    switch get(hObject,'Tag')
        case 'dimX'
            val = str2double(get(hObject,'String'));
            ratio = handles.width / val;
            set(handles.dimY,'String',floor(handles.height/ratio));
            set(handles.voxX,'String',handles.h.Img{handles.h.Id}.I.pixSize.x*ratio);
            set(handles.voxY,'String',handles.h.Img{handles.h.Id}.I.pixSize.y*ratio);
        case 'dimY'
            val = str2double(get(hObject,'String'));
            ratio = handles.height / val;
            set(handles.dimX,'String',floor(handles.width/ratio));
            set(handles.voxX,'String',handles.h.Img{handles.h.Id}.I.pixSize.x*ratio);
            set(handles.voxY,'String',handles.h.Img{handles.h.Id}.I.pixSize.y*ratio);
        case 'dimZ'
            val = str2double(get(hObject,'String'));
            ratio = handles.zstacks / val;
            set(handles.voxZ,'String',handles.h.Img{handles.h.Id}.I.pixSize.z*ratio);
    end
elseif get(handles.voxelsRadio,'Value')
    switch get(hObject,'Tag')
        case 'voxX'
            val = str2double(get(hObject,'String'));
            ratio = val / handles.h.Img{handles.h.Id}.I.pixSize.x;
            set(handles.dimX,'String',floor(handles.width/ratio));
            set(handles.dimY,'String',floor(handles.height/ratio));
            set(handles.voxY,'String',handles.h.Img{handles.h.Id}.I.pixSize.y*ratio);
        case 'voxY'
            val = str2double(get(hObject,'String'));
            ratio = val / handles.h.Img{handles.h.Id}.I.pixSize.y;
            set(handles.dimX,'String',floor(handles.width/ratio));
            set(handles.dimY,'String',floor(handles.height/ratio));
            set(handles.voxX,'String',handles.h.Img{handles.h.Id}.I.pixSize.x*ratio);
        case 'voxZ'
            val = str2double(get(hObject,'String'));
            ratio = val / handles.h.Img{handles.h.Id}.I.pixSize.z;
            set(handles.dimZ,'String',floor(handles.zstacks/ratio));
    end
elseif get(handles.percXYZRadio,'Value')
    val = str2double(get(handles.percEdit, 'String'));
    set(handles.dimX,'String',floor(handles.width/100*val));
    set(handles.dimY,'String',floor(handles.height/100*val));
    set(handles.dimZ,'String',floor(handles.zstacks/100*val));
    set(handles.voxX,'String',handles.h.Img{handles.h.Id}.I.pixSize.x*handles.width/floor(handles.width/100*val));
    set(handles.voxY,'String',handles.h.Img{handles.h.Id}.I.pixSize.y*handles.height/floor(handles.height/100*val));
    set(handles.voxZ,'String',handles.h.Img{handles.h.Id}.I.pixSize.z*handles.zstacks/floor(handles.zstacks/100*val));
elseif get(handles.percXYRadio,'Value')
    val = str2double(get(handles.percEdit, 'String'));
    set(handles.dimX,'String',floor(handles.width/100*val));
    set(handles.dimY,'String',floor(handles.height/100*val));
    set(handles.voxX,'String',handles.h.Img{handles.h.Id}.I.pixSize.x*handles.width/floor(handles.width/100*val));
    set(handles.voxY,'String',handles.h.Img{handles.h.Id}.I.pixSize.y*handles.height/floor(handles.height/100*val));
end
end

function radio_Callback(hObject, eventdata, handles)
if get(hObject,'value') == 0
    set(hObject,'value',1);
    return;
end;
set(handles.voxX, 'enable','off');
set(handles.voxY, 'enable','off');
set(handles.voxZ, 'enable','off');
set(handles.dimX, 'enable','off');
set(handles.dimY, 'enable','off');
set(handles.dimZ, 'enable','off');
set(handles.percEdit, 'enable','off');

if get(handles.dimensionsRadio,'Value')
    set(handles.dimX, 'enable','on');
    set(handles.dimY, 'enable','on');
    set(handles.dimZ, 'enable','on');
    uicontrol(handles.dimX);
elseif get(handles.voxelsRadio,'Value')
    set(handles.voxX, 'enable','on');
    set(handles.voxY, 'enable','on');
    set(handles.voxZ, 'enable','on');
    uicontrol(handles.voxX);
else
    set(handles.percEdit, 'enable','on');
    uicontrol(handles.percEdit);
end


end


% --- Executes on button press in resetBtn.
function resetBtn_Callback(hObject, eventdata, handles)
set(handles.widthTxt, 'String', num2str(handles.width));
set(handles.heightTxt, 'String', num2str(handles.height));
set(handles.colorsTxt, 'String', num2str(handles.color));
set(handles.zstacksTxt, 'String', num2str(handles.zstacks));

set(handles.pixsizeX, 'String', sprintf('%f %s', handles.h.Img{handles.h.Id}.I.pixSize.x, handles.h.Img{handles.h.Id}.I.pixSize.units));
set(handles.pixsizeY, 'String', sprintf('%f %s', handles.h.Img{handles.h.Id}.I.pixSize.y, handles.h.Img{handles.h.Id}.I.pixSize.units));
set(handles.pixsizeZ, 'String', sprintf('%f %s', handles.h.Img{handles.h.Id}.I.pixSize.z, handles.h.Img{handles.h.Id}.I.pixSize.units));

set(handles.dimX, 'String', num2str(handles.width));
set(handles.dimY, 'String', num2str(handles.height));
set(handles.dimZ, 'String', num2str(handles.zstacks));
set(handles.voxX, 'String', sprintf('%f', handles.h.Img{handles.h.Id}.I.pixSize.x));
set(handles.voxY, 'String', sprintf('%f', handles.h.Img{handles.h.Id}.I.pixSize.y));
set(handles.voxZ, 'String', sprintf('%f', handles.h.Img{handles.h.Id}.I.pixSize.z));
set(handles.percEdit, 'String', '100');

end


% --- Executes on selection change in resamplingFunction.
function resamplingFunction_Callback(hObject, eventdata, handles)
val = get(handles.resamplingFunction, 'value');
if val == 1     % interpn
    methods = {'nearest', 'linear', 'spline', 'cubic'};
    methodsModel = {'nearest', 'linear', 'spline', 'cubic'};
elseif val == 2     % imresize
    methods = {'nearest','box', 'triangle', 'cubic','lanczos2','lanczos3'};
    methodsModel = {'nearest'};
else
    methods = {'nearest', 'linear', 'cubic'};
    methodsModel = {'nearest', 'linear','cubic'};
end
if get(handles.imageMethod, 'value') > numel(methods); set(handles.imageMethod, 'value', 1); end;
if get(handles.modelsMethod, 'value') > numel(methods); set(handles.modelsMethod, 'value', 1); end;
set(handles.imageMethod, 'String', methods);
set(handles.modelsMethod, 'String', methodsModel);
end
