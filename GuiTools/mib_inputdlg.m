function varargout = mib_inputdlg(varargin)
% function output = mib_inputdlg(NaN, dlgText, dlgTitle, defAnswer)
% custom input dialog
%
%
% Parameters:
% handles:  handles structure of im_browser (preferable) or NaN
% dlgText:  dialog test, a string
% dlgTitle: dialog title, a string
% defAnswer:    default answer, a string
%
% Return values:
% output: a cell with the entered value, or an empty cell, when cancelled

%| 
% @b Examples:
% @code answer = mib_inputdlg(NaN,'Please enter a number in the edit box below','Test title','123');
%       if size(answer) == 0; return; end; @endcode

% Copyright (C) 04.03.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mib_inputdlg_OpeningFcn, ...
                   'gui_OutputFcn',  @mib_inputdlg_OutputFcn, ...
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

% --- Executes just before mib_inputdlg is made visible.
function mib_inputdlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_inputdlg (see VARARGIN)

if nargin < 7
    inputStr = get(handles.textEdit,'String');
else
    inputStr = varargin{4};
end

if nargin < 6
    titleStr = get(handles.mib_inputdlg,'Name');
else
    titleStr = varargin{3};
end
textString = varargin{2};

handles.h = varargin{1};

set(handles.mib_inputdlg,'Name', titleStr);
set(handles.textString,'String', textString);
set(handles.textEdit,'String', inputStr);

% Choose default command line output for mib_inputdlg
handles.output = {inputStr};

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_inputdlg);

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

pos = get(handles.mib_inputdlg, 'position');
handles.dialogHeight = pos(4);

% add icon
if isstruct(handles.h)
    [IconData, IconCMap] = imread(fullfile(handles.h.pathMIB, 'Resources','mib_quest.gif'));        
else
    if isdeployed % Stand-alone mode.
        [~, result] = system('path');
        currentDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    else % MATLAB mode.
        currentDir = fileparts(which('im_browser'));
    end
    [IconData, IconCMap] = imread(fullfile(currentDir, 'Resources','mib_quest.gif'));    
end

Img=image(IconData, 'Parent', handles.axes1);
IconCMap(IconData(1,1)+1,:) = get(handles.mib_inputdlg, 'Color');   % replace background color
set(handles.mib_inputdlg, 'Colormap', IconCMap);

set(handles.axes1, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );

% update WindowKeyPressFcn
set(handles.mib_inputdlg, 'WindowKeyPressFcn', {@mib_inputdlg_KeyPressFcn, handles});

% Make the GUI modal
set(handles.mib_inputdlg,'WindowStyle','modal')

% Update handles structure
guidata(hObject, handles);

set(handles.mib_inputdlg,'Visible','on');
drawnow;

% highlight text in the edit box
uicontrol(handles.textEdit);

% UIWAIT makes mib_inputdlg wait for user response (see UIRESUME)
uiwait(handles.mib_inputdlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = mib_inputdlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = guidata(handles.mib_inputdlg);

% Get default command line output from handles structure
if isempty(handles.output)
    varargout{1} = {};
else
    varargout{1} = {get(handles.textEdit,'String')};
end
%varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.mib_inputdlg);

end

% --- Executes when user attempts to close mib_inputdlg.
function mib_inputdlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_inputdlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    cancelBtn_Callback(hObject, eventdata, handles);
    % The GUI is still in UIWAIT, us UIRESUME
    %uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
end

% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

drawnow;     % needed to fix callback after the key press
handles.output = {get(handles.textEdit,'String')};

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_inputdlg);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = {};

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_inputdlg);
end

% --- Executes on key press over mib_inputdlg with no controls selected.
function mib_inputdlg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to mib_inputdlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin < 3;    handles = guidata(hObject); end;

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    cancelBtn_Callback(hObject, eventdata, handles);
end    
if isequal(get(hObject,'CurrentKey'),'return')
    okBtn_Callback(hObject, eventdata, handles);
end    
end


function textEdit_Callback(hObject, eventdata, handles)
% hObject    handle to textEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textEdit as text
%        str2double(get(hObject,'String')) returns contents of textEdit as a double
end


% --- Executes when mib_inputdlg is resized.
function mib_inputdlg_ResizeFcn(hObject, eventdata, handles)
if isfield(handles, 'dialogHeight')     % to skip this part during initialization of the dialog
    pos = get(handles.mib_inputdlg, 'position');
    pos(4) = handles.dialogHeight;
    set(handles.mib_inputdlg, 'position',pos);
end
end
