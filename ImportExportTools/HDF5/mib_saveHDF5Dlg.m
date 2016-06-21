function varargout = mib_saveHDF5Dlg(varargin)
% MIB_SAVEHDF5DLG MATLAB code for mib_saveHDF5Dlg.fig
%      MIB_SAVEHDF5DLG, by itself, creates a new MIB_SAVEHDF5DLG or raises the existing
%      singleton*.
%
%      H = MIB_SAVEHDF5DLG returns the handle to a new MIB_SAVEHDF5DLG or the handle to
%      the existing singleton*.
%
%      MIB_SAVEHDF5DLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIB_SAVEHDF5DLG.M with the given input arguments.
%
%      MIB_SAVEHDF5DLG('Property','Value',...) creates a new MIB_SAVEHDF5DLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mib_saveHDF5Dlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mib_saveHDF5Dlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mib_saveHDF5Dlg

% Last Modified by GUIDE v2.5 12-Apr-2016 09:51:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mib_saveHDF5Dlg_OpeningFcn, ...
                   'gui_OutputFcn',  @mib_saveHDF5Dlg_OutputFcn, ...
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

% --- Executes just before mib_saveHDF5Dlg is made visible.
function mib_saveHDF5Dlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_saveHDF5Dlg (see VARARGIN)

% get handles structure
handles.h = varargin{1};


% Choose default command line output for mib_saveHDF5Dlg
handles.output = {};

% get MIB font size
Font = varargin{2};

% update font and size
if get(handles.text1, 'fontsize') ~= Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), Font.FontName)
    ib_updateFontSize(handles.mib_saveHDF5Dlg, Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_saveHDF5Dlg);

options.blockModeSwitch = 0;
[height, width, ~, depth] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4, 0, options); 

chunk(1) = min([height, 64]);
chunk(2) = min([width, 64]);
chunk(3) = min([depth, 64]);
set(handles.chunkEdit, 'string', sprintf('%d, %d, %d;', chunk(1), chunk(2), chunk(3)));

templatePopup_Callback(hObject, eventdata, handles);

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

pos = get(handles.mib_saveHDF5Dlg, 'position');
handles.dialogHeight = pos(4);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mib_saveHDF5Dlg wait for user response (see UIRESUME)
uiwait(handles.mib_saveHDF5Dlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = mib_saveHDF5Dlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = {};
else
    varargout{1} = handles.output;
end
delete(hObject);
end

% --- Executes when user attempts to close mib_saveHDF5Dlg.
function mib_saveHDF5Dlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_saveHDF5Dlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
handles.output = struct();
list = get(handles.templatePopup, 'string');
selEntry = strtrim(list{get(handles.templatePopup, 'value')});
switch selEntry
    case 'Fiji Big Data Viewer'
        handles.output.Format = 'bdv.hdf5';
    case 'Ordinary HDF5'
        handles.output.Format = 'matlab.hdf5';
end
handles.output.SubSampling = str2num(get(handles.subsamplingEdit, 'string'))'; %#ok<ST2NM>
if get(handles.chunkCheckbox, 'value')
    handles.output.ChunkSize = str2num(get(handles.chunkEdit, 'string'))'; %#ok<ST2NM>
end
handles.output.Deflate = str2double(get(handles.deflateEdit, 'string')); 
handles.output.xmlCreate = get(handles.xmlCheck, 'value'); 

% Update handles structure
guidata(hObject, handles);

uiresume(handles.mib_saveHDF5Dlg);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
delete(handles.mib_saveHDF5Dlg);
end

% --- Executes on selection change in templatePopup.
function templatePopup_Callback(hObject, eventdata, handles)
list = get(handles.templatePopup, 'string');
selEntry = strtrim(list{get(handles.templatePopup, 'value')});
switch selEntry
    case 'Fiji Big Data Viewer'
        set(handles.chunkCheckbox, 'enable', 'off');
        set(handles.chunkCheckbox, 'value', 1);
        set(handles.xmlCheck, 'enable', 'off');
        set(handles.xmlCheck, 'value', 1);
        set(handles.infoText,'String', sprintf('Export for Fiji Big Data Viewer:\n1. resulting images are 16-bit\n2. additional processing for data conversion to Java classes'));
        set(handles.subsamplingEdit, 'enable', 'on');
    case 'Ordinary HDF5'
        set(handles.chunkCheckbox, 'enable', 'on');
        set(handles.xmlCheck, 'enable', 'on');
        set(handles.infoText,'String', sprintf('Export as ordinary HDF5:\nno limitations'));
        set(handles.subsamplingEdit, 'enable', 'off');
end
end


% --- Executes on button press in chunkCheckbox.
function chunkCheckbox_Callback(hObject, eventdata, handles)
if get(handles.chunkCheckbox, 'value')
    set(handles.chunkEdit, 'enable', 'on');
else
    set(handles.chunkEdit, 'enable', 'off');
end
end



function deflateEdit_Callback(hObject, eventdata, handles)
val = str2double(get(handles.deflateEdit, 'string'));
if val < 0 || val > 9
    errordlg(sprintf('!!! Error !!!\n\nThe value for compression should be between 0 (no compression) and 9 (maximal)'),'Wrong value');
    set(handles.deflateEdit, 'string', '6');
end
end
