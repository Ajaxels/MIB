function varargout = logList(varargin)
% function varargout = logList(varargin)
% logList function calls a window with Log list of actions that were performed with the dataset.
%
% The log is stored in imageData.img_info(''ImageDescription'') key.
%
% logList contains MATLAB code for logList.fig

% Copyright (C) 22.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
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
    'gui_OpeningFcn', @logList_OpeningFcn, ...
    'gui_OutputFcn',  @logList_OutputFcn, ...
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

% --- Executes just before logList is made visible.
function logList_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to logList (see VARARGIN)

repositionSwitch = 1; % reposition the figure, when creating a new figure
if numel(varargin) > 1  % for the update of the window from updateGuiWidgets function
    handles = guidata(varargin{2});
    set(handles.logList,'value', 1);
    repositionSwitch = 0; % keep the current coordinates when the figure already exist
end

% Choose default command line output for logList
handles.output = hObject;
set(hObject,'Name','Actions log');
handles.hMain = varargin{1};
updateLog(handles);

% update font and size
if get(handles.logPrint, 'fontsize') ~= handles.hMain.preferences.Font.FontSize ...
        || ~strcmp(get(handles.logPrint, 'fontname'), handles.hMain.preferences.Font.FontName)
    ib_updateFontSize(handles.logWindow, handles.hMain.preferences.Font);
end

% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.logWindow);

% Update handles structure
guidata(hObject, handles);

%% set background color to panels and texts
set(handles.logWindow,'Color',[.831 .816 .784]);
tempList = findall(handles.logWindow,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.logWindow,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.logWindow,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.logWindow,'Style','radiobutton');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);

% Determine the position of the dialog - outside of the main figure, at the
% bottom if available, else, centered on the main figure
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
            FigPos(1:2) = [GCBFPos(1)-FigWidth-16 GCBFPos(2)];
        elseif GCBFPos(1) + GCBFPos(3) + FigWidth < screenSize(3) % put figure on the right side of the main figure
            FigPos(1:2) = [GCBFPos(1)+GCBFPos(3)+16 GCBFPos(2)];
        else
            FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
        end
    end
    FigPos(3:4)=[FigWidth FigHeight];
    set(hObject, 'Position', FigPos);
    set(hObject, 'Units', OldUnits);
end
% UIWAIT makes logList wait for user response (see UIRESUME)
%uiwait(handles.logWindow);
end

function updateLog(handles)
handles.hMain = guidata(handles.hMain.im_browser);
logText = handles.hMain.Img{handles.hMain.Id}.I.img_info('ImageDescription');
linefeeds = strfind(logText,sprintf('|'));
if isempty(linefeeds)
    set(handles.logList,'String',logText);
    return;
end;
for linefeed = 1:numel(linefeeds)
    if linefeed == 1
        logTextForm(linefeed) = cellstr(logText(1:linefeeds(1)-1)); %#ok<AGROW>
    else
        logTextForm(linefeed) = cellstr(logText(linefeeds(linefeed-1)+1:linefeeds(linefeed)-1)); %#ok<AGROW>
    end
end
if numel(logText(linefeeds(end)+1:end)) > 1
    logTextForm(linefeed+1) = cellstr(logText(linefeeds(end)+1:end));
end
currPos = get(handles.logList,'value');
if currPos > numel(logTextForm)
    set(handles.logList,'value', 1);
end
set(handles.logList,'String',logTextForm);
guidata(handles.logList, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = logList_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
% delete(handles.logWindow);
end

% --- Executes on button press in update.
function updateBtn_Callback(hObject, eventdata, handles)
updateLog(handles);
end

% --- Executes when user attempts to close logWindow.
function logWindow_CloseRequestFcn(hObject, eventdata, handles)
guidata(handles.hMain.im_browser, handles.hMain);
delete(hObject);
end

% --- Executes on selection change in logList.
function logList_Callback(hObject, eventdata, handles)
% hObject    handle to logList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns logList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from logList
end


% --- Executes on button press in logPrint.
function logPrint_Callback(hObject, eventdata, handles)
% display the log contents in the matlab command window
logText = get(handles.logList,'String');
if strcmp(class(logText), 'char')
    disp(logText);
else
    for line=1:numel(logText)
        disp(logText{line});
    end
end
end


% --- Executes on button press in clipboardBtn.
function clipboardBtn_Callback(hObject, eventdata, handles)
logText = get(handles.logList,'String');
str1 = '';
for line_idx = 1:numel(logText)
    str1 = sprintf('%s%s\n', str1, logText{line_idx});
end
clipboard('copy', str1);
end


% --- Executes on button press in deleteBtn.
function deleteBtn_Callback(hObject, eventdata, handles)
pos = get(handles.logList,'value');
if pos(1)==1;
    msgbox('The BoundingBox information can not be deleted!','Error','error','modal') ;
    return;
end
button = questdlg(sprintf('You are goint to delete highlighted entry!\n\nAre you sure?'),'Delete entry','Delete','Cancel','Cancel');
if strcmp(button,'Cancel'); return; end;
set(handles.logList,'value',1);
for i=numel(pos):-1:1
    handles.hMain.Img{handles.hMain.Id}.I.updateImgInfo('','delete',pos(i));
end
updateLog(handles);
end

% --- Executes on button press in insertBtn.
function insertBtn_Callback(hObject, eventdata, handles)
pos = get(handles.logList,'value')+1;
pos = pos(end);
%answer = inputdlg('Please type here new entry text','Insert new entry',1);
answer = mib_inputdlg(handles.hMain, 'Please type here new entry text','Insert new entry','type here');
if isempty(answer)
    return;
elseif numel(answer{1}) == 0
    return;
end
handles.hMain.Img{handles.hMain.Id}.I.updateImgInfo(answer{1},'insert',pos);
updateLog(handles);
set(handles.logList, 'value', pos);
end

% --- Executes on button press in modifyBtn.
function modifyBtn_Callback(hObject, eventdata, handles)
pos = get(handles.logList,'value');
currentList = get(handles.logList,'string');
if pos==1;
    warndlg(sprintf('!!! Warning !!!\n\nThe BoundingBox information should be modified from the menu!\n\nPlease use: \nMenu->Dataset->Bounding Box...\nMenu->Dataset->Parameters... '),'Warning','modal');
    return;
end
currEntry = currentList{pos};
colon = strfind(currEntry,':');
currEntry = currEntry(colon(1)+2:end);
%answer = inputdlg('Modify the text:','Modify the entry',1,cellstr(currEntry));
answer = mib_inputdlg(handles.hMain, 'Modify the text:','Modify the entry',currEntry);
if isempty(answer); return;  end;
handles.hMain.Img{handles.hMain.Id}.I.updateImgInfo(answer{1},'modify',pos);
updateLog(handles);
end
