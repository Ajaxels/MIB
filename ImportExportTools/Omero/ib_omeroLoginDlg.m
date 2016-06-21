function varargout = ib_omeroLoginDlg(varargin)
% varargout = ib_omeroLoginDlg(varargin)
% ib_omeroLoginDlg function is responsible for login to OMERO server.
%
% ib_omeroLoginDlg contains MATLAB code for ib_omeroLoginDlg.fig

% Copyright (C) 05.03.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
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
                   'gui_OpeningFcn', @ib_omeroLoginDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_omeroLoginDlg_OutputFcn, ...
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

% --- Executes just before ib_omeroLoginDlg is made visible.
function ib_omeroLoginDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_omeroLoginDlg (see VARARGIN)

% Choose default command line output for ib_omeroLoginDlg
handles.output = struct();
handles.password = '';

Font = varargin{1};
% update font and size
if get(handles.text1, 'fontsize') ~= Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), Font.FontName)
    ib_updateFontSize(handles.ib_omeroLoginDlg, Font);
end
% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.ib_omeroLoginDlg);

if exist('c:\temp\im_browser_omero.mat','file') ~= 0
    load('c:\temp\im_browser_omero.mat');  % load omero structure with .servers, .port .username fields
    handles.servers = omeroSettings.servers;
    handles.serverIdx = omeroSettings.serverIdx;
    handles.username = omeroSettings.username;
    handles.port = omeroSettings.port;
elseif exist(fullfile(tempdir, 'im_browser_omero.mat'), 'file') ~= 0
    load(fullfile(tempdir, 'im_browser_omero.mat'));
    handles.servers = omeroSettings.servers;
    handles.serverIdx = omeroSettings.serverIdx;
    handles.username = omeroSettings.username;
    handles.port = omeroSettings.port;
else
    handles.servers = {'demo.openmicroscopy.org','omerovm-1.it.helsinki.fi'};
    handles.serverIdx = 1;
    handles.username = 'ibelev';
    handles.port = 4064;
end
set(handles.serverPopup,'String',handles.servers);
set(handles.serverPopup,'Value',handles.serverIdx);
set(handles.omeroServerPortEdit,'String',handles.port);
set(handles.usernameEdit,'String',handles.username);



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

% UIWAIT makes ib_omeroLoginDlg wait for user response (see UIRESUME)
uiwait(handles.ib_omeroLoginDlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_omeroLoginDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.ib_omeroLoginDlg);
end

% --- Executes on button press in loginBtn.
function loginBtn_Callback(hObject, eventdata, handles)
serverList = get(handles.serverPopup,'string');
serverIdx = get(handles.serverPopup,'value');

handles.output.server = serverList{serverIdx};
handles.output.port = str2double(get(handles.omeroServerPortEdit,'String'));
handles.output.username = get(handles.usernameEdit,'String');
handles.output.password = handles.password;

omeroSettings.servers = handles.servers;
omeroSettings.serverIdx = handles.serverIdx;
omeroSettings.port = handles.output.port;
omeroSettings.username = handles.output.username; %#ok<STRNU>

try
    save(['c:' filesep 'temp' filesep 'im_browser_omero.mat'],'omeroSettings');
catch err
    try     % try to save it into windows temp folder (C:\Users\User-name\AppData\Local\Temp\)
        fn = fullfile(tempdir, 'im_browser_omero.mat');
        save(fn, 'omeroSettings');
    catch err
        msgbox(sprintf('There is a problem with saving settings\n%s', err.identifier),'Error','error','modal');
    end
end

guidata(hObject, handles);
uiresume(handles.ib_omeroLoginDlg);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
handles.output = struct();
guidata(hObject, handles);
uiresume(handles.ib_omeroLoginDlg);
end


% --- Executes on key press with focus on passwordEdit and none of its controls.
function passwordEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to passwordEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.ib_omeroLoginDlg);
switch eventdata.Key
    case {'backspace', 'delete'}
        if numel(handles.password) == 0; return; end;
        handles.password = handles.password(1:end-1);
    case {'leftarrow','rightarrow','downarrow',  'uparrow', 'shift', 'alt', 'control',...
            'escape', 'insert', 'home', 'pageup', 'pagedown', 'end'}
    case 'return'
        loginBtn_Callback(handles.loginBtn, eventdata, handles);
        return;
    otherwise
        handles.password = [handles.password eventdata.Character];
end
set(handles.passwordEdit,'String', sprintf('%s', repmat('*',[1 numel(handles.password)])));
guidata(hObject, handles);
end


% --- Executes on key press with focus on ib_omeroLoginDlg and none of its controls.
function ib_omeroLoginDlg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ib_omeroLoginDlg (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    cancelBtn_Callback(handles.cancelBtn, eventdata, handles);
    return;
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    loginBtn_Callback(handles.loginBtn, eventdata, handles);
    return;
end    

end


% --- Executes on button press in addServerBtn.
function addServerBtn_Callback(hObject, eventdata, handles)
%answer = inputdlg('Enter server address','Add server',1,{''});
answer = mib_inputdlg(NaN,'Enter server address','Add server','');
if isempty(answer); return; end;
handles.servers = [handles.servers, answer];
set(handles.serverPopup,'string',handles.servers);
handles.serverIdx = numel(handles.servers);
set(handles.serverPopup,'value',handles.serverIdx);
guidata(hObject, handles);
end

% --- Executes on button press in removeServerBtn.
function removeServerBtn_Callback(hObject, eventdata, handles)
serverList = get(handles.serverPopup,'string');
serverValue = get(handles.serverPopup,'value');
button = questdlg(sprintf('You are going to remove:\n%s\nfrom the list!', serverList{serverValue}),'Remove server','Cancel','Remove','Cancel');
if strcmp(button, 'Cancel'); return; end;
i = 1:numel(serverList);
handles.servers = serverList(i~=serverValue)';
set(handles.serverPopup,'string',handles.servers);
handles.serverIdx = 1;
set(handles.serverPopup,'value',handles.serverIdx);
guidata(hObject, handles);
end

% --- Executes on selection change in serverPopup.
function serverPopup_Callback(hObject, eventdata, handles)
handles.serverIdx = get(handles.serverPopup, 'value');
guidata(hObject, handles);
end
