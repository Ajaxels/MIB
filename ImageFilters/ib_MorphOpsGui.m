function varargout = ib_MorphOpsGui(varargin)
% IB_MORPHOPSGUI MATLAB code for ib_MorphOpsGui.fig
%      IB_MORPHOPSGUI, by itself, creates a new IB_MORPHOPSGUI or raises the existing
%      singleton*.
%
%      H = IB_MORPHOPSGUI returns the handle to a new IB_MORPHOPSGUI or the handle to
%      the existing singleton*.
%
%      IB_MORPHOPSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IB_MORPHOPSGUI.M with the given input arguments.
%
%      IB_MORPHOPSGUI('Property','Value',...) creates a new IB_MORPHOPSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ib_MorphOpsGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ib_MorphOpsGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 31.01.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 19.10.2015, fixed ib_getDataset/ib_setDataset


% Edit the above text to modify the response to help ib_MorphOpsGui

% Last Modified by GUIDE v2.5 31-Jan-2014 14:51:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ib_MorphOpsGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_MorphOpsGui_OutputFcn, ...
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

% --- Executes just before ib_MorphOpsGui is made visible.
function ib_MorphOpsGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_MorphOpsGui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser
handles.type = varargin{2};    % type of morphological operation to perform

% set panel positions
set(handles.ulterPanel, 'parent', get(handles.iterPanel, 'parent'));
set(handles.ulterPanel, 'position', get(handles.iterPanel, 'position'));

% highlight desired operation in the list
list = get(handles.morphOpsPopup, 'String');
for i=1:numel(list)
    if strcmp(list{i}, handles.type)
        set(handles.morphOpsPopup, 'value', i);
        continue;
    end
end
morphOpsPopup_Callback(handles.morphOpsPopup, eventdata, handles);

% update font and size
if get(handles.infoText, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.infoText, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_MorphOpsGui, handles.h.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_MorphOpsGui);

% Choose default command line output for ib_MorphOpsGui
handles.output = NaN;

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
set(handles.ib_MorphOpsGui,'WindowStyle','modal');

% UIWAIT makes ib_MorphOpsGui wait for user response (see UIRESUME)
uiwait(handles.ib_MorphOpsGui);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_MorphOpsGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.ib_MorphOpsGui);
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
uiresume(handles.ib_MorphOpsGui);
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
contents = cellstr(get(handles.morphOpsPopup,'String'));
selected = contents{get(handles.morphOpsPopup,'Value')};
if get(handles.sliceRadio, 'value') == 1
    switch3d = 0;
else
    switch3d = 1;
end
if strcmp(selected, 'bwulterode')
    conn = get(handles.auxPopup1, 'String');
    conn = str2double(conn{get(handles.auxPopup1, 'value')});
    method = get(handles.auxPopup2, 'String');
    method = method{get(handles.auxPopup2, 'value')};
else
    if get(handles.limitToRadio, 'value') == 1
        iterNo = str2double(get(handles.iterEdit,'String'));
    else
        iterNo = 'Inf';
    end
end

wb = waitbar(0,sprintf('Performing: %s\nPlease wait...',selected),'Name','Morph Ops','WindowStyle','modal');
ib_do_backup(handles.h, 'selection', switch3d);
tic
if strcmp(selected, 'bwulterode')
    if get(handles.radioBtn3D, 'value')     % 3D mode
        selection = ib_getDataset('selection', handles.h, 4);
        for roiId=1:numel(selection)
            selection{roiId} = bwulterode(selection{roiId}, method, conn);
        end
        ib_setDataset('selection', selection, handles.h, 4);
    elseif switch3d                         % 2D mode, whole dataset
        selection = ib_getDataset('selection', handles.h, 0);
        maxVal = numel(selection)*size(selection{1}, 3);
        for roiId=1:numel(selection)
            for layer = 1:size(selection{roiId}, 3)
                if max(max(selection{roiId}(:,:,layer))) == 0; continue; end;   % tweak to skip inversion, i.e. [0 0 0] -> [1 1 1] during normal use
                selection{roiId}(:,:,layer) = bwulterode(selection{roiId}(:,:,layer), method, conn);
                if mod(layer, 10)==0; waitbar(layer*roiId/maxVal, wb); end;
            end
        end
        ib_setDataset('selection', selection, handles.h, 0);
    else                                    % 2D mode, single slice
        selection = ib_getSlice('selection', handles.h);
        for roiId=1:numel(selection)
            if max(max(selection{roiId})) == 0; continue; end;   % tweak to skip inversion, i.e. [0 0 0] -> [1 1 1] during normal use
            selection{roiId} = bwulterode(selection{roiId}, method, conn);
            waitbar(roiId/numel(selection), wb);
        end
        ib_setSlice('selection', selection, handles.h);
    end
else    % branchpoints, diag, endpoints, skel, spur, thin
    if switch3d
        selection = ib_getDataset('selection', handles.h, 0);
        maxVal = numel(selection)*size(selection{1}, 3);
        for roiId=1:numel(selection)
            for layer = 1:size(selection{roiId}, 3)
                selection{roiId}(:,:,layer) = bwmorph(selection{roiId}(:,:,layer), selected, iterNo);
                %selection{roiId}(:,:,layer) = gather(bwmorph(gpuArray(logical(selection{roiId}(:,:,layer))),selected, iterNo));     % alternative version to use with GPU
                if mod(layer, 10)==0; waitbar(layer*roiId/maxVal, wb); end;
            end
        end
        ib_setDataset('selection', selection, handles.h, 0);
    else
        selection = ib_getSlice('selection', handles.h);
        for roiId=1:numel(selection)
            selection{roiId} = bwmorph(selection{roiId}, selected, iterNo);
            waitbar(roiId/numel(selection), wb);
        end
        ib_setSlice('selection', selection, handles.h);
    end
end
delete(wb);
toc
handles.output = handles.h;
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_MorphOpsGui);
end

% --- Executes on selection change in morphOpsPopup.
function morphOpsPopup_Callback(hObject, eventdata, handles)
contents = cellstr(get(handles.morphOpsPopup,'String'));
selected = contents{get(handles.morphOpsPopup,'Value')};

set(handles.ulterPanel, 'visible', 'off');
set(handles.iterPanel, 'visible', 'on');

switch strtrim(selected)
    case 'branchpoints'
        textString = sprintf('Find branch points of skeleton');
        set(handles.infoText, 'String', textString);
    case 'bwulterode'
        textString{1} = 'The ultimate erosion computesthe ultimate erosion of the selection';
        textString{2} = '0 1 1 1  ->  0 0 0 0'; 
        textString{3} = '0 1 1 1  ->  0 0 1 0'; 
        textString{4} = '0 1 1 1  ->  0 0 0 0'; 
        textString{5} = '0 0 0 0  ->  0 0 0 0'; 
        set(handles.infoText, 'String', textString);
        set(handles.iterPanel, 'visible', 'off');
        set(handles.ulterPanel, 'visible', 'on');
    case 'diag'
        textString{1} = 'Uses diagonal fill to eliminate 8-connectivity of the background. For example:';
        textString{2} = '1 0 0 0  ->  1 1 0 0'; 
        textString{3} = '0 1 0 0  ->  1 1 1 0'; 
        textString{4} = '0 0 1 0  ->  0 1 1 0'; 
        textString{5} = '0 0 1 0  ->  1 0 1 0'; 
        set(handles.infoText, 'String', textString);
    case 'endpoints'
        textString{1} = 'Finds end points of skeleton. For example:';
        textString{2} = '1 0 0 0  ->  1 0 0 0'; 
        textString{3} = '0 1 0 0  ->  0 0 0 0'; 
        textString{4} = '0 0 1 0  ->  0 0 1 0'; 
        textString{5} = '0 0 0 0  ->  1 0 0 0'; 
        set(handles.infoText, 'String', textString);
    case 'skel'
        textString{1} = 'With Iterations = Inf, removes pixels on the boundaries of objects but does not allow objects to break apart.';
        textString{2} = 'The pixels remaining make up the image skeleton. This option preserves the Euler number.'; 
        set(handles.infoText, 'String', textString);
    case 'spur'
        textString{1} = 'Removes spur pixels. For example:';
        textString{2} = '0 0 0 0  ->  0 0 0 0'; 
        textString{3} = '0 0 1 0  ->  0 0 0 0'; 
        textString{4} = '0 1 0 0  ->  0 1 0 0'; 
        textString{5} = '1 1 0 0  ->  1 1 0 0'; 
        set(handles.infoText, 'String', textString);
    case 'thin'
        textString{1} = 'With Iterations = Inf, thins objects to lines. It removes pixels so that an object without holes shrinks to a minimally connected stroke, and an object with holes shrinks to a connectedring halfway between each hole and the outer boundary.';
        textString{2} = 'This option preserves the Euler number.'; 
        set(handles.infoText, 'String', textString);
end
end

function applyToRadio_Callback(hObject, eventdata, handles)
%tag = get(hObject,'tag');
set(hObject,'value',1);
end

function iterationsRadio_Callback(hObject, eventdata, handles)
tag = get(hObject,'tag');
set(hObject,'value',1);
if strcmp(tag,'limitToRadio')
    set(handles.iterEdit, 'Enable', 'on');
else
    set(handles.iterEdit, 'Enable', 'off');
end

end

% --- Executes on button press in radioBtn2D.
function radioBtn2D_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 0
    set(hObject, 'value', 1);
    return;
end;
if get(handles.radioBtn3D, 'value')     % 3D mode
    set(handles.auxPopup1, 'value', 1);
    set(handles.auxPopup1, 'string', [{'6'},{'18'},{'26'}]);
    set(handles.datasetRadio, 'value', 1);
    set(handles.sliceRadio, 'enable','off');
else    % 2D mode
    set(handles.sliceRadio, 'enable','on');
    set(handles.auxPopup1, 'value', 1);
    set(handles.auxPopup1, 'string', [{'4'},{'8'}]);
end

end


% --- Executes on key press with focus on ib_MorphOpsGui and none of its controls.
function ib_MorphOpsGui_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ib_MorphOpsGui (see GCBO)
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
