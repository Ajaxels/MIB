function varargout = ib_datasetInfoGui(varargin)
% function varargout = ib_datasetInfoGui(varargin)
% ib_datasetInfoGui is a GUI window that shows parameters of the dataset
%
%
% ib_datasetInfoGui.m contains MATLAB code for ib_datasetInfoGui.fig
%

% Copyright (C) 07.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
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
    'gui_OpeningFcn', @ib_datasetInfoGui_OpeningFcn, ...
    'gui_OutputFcn',  @ib_datasetInfoGui_OutputFcn, ...
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

% --- Executes just before ib_datasetInfoGui is made visible.
function ib_datasetInfoGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_datasetInfoGui (see VARARGIN)

repositionSwitch = 1; % reposition the figure, when creating a new figure

if numel(varargin) > 1  % for the update of the window from updateGuiWidgets function
    handles = guidata(varargin{2});
    
    % Sync tables
    % Note: the following also works with Matlab listboxes and editboxes
    jScrollPane = findjobj(handles.fileinfoTable);
    jViewport = jScrollPane.getViewport;
    originalPos = jViewport.getViewPosition;  % java.awt.Point[x=150,y=54]
    % jViewport.setViewPosition(originalPos);          jScrollPane.repaint
    % jViewport.setViewPosition(java.awt.Point(0,0));  jScrollPane.repaint  % move to top-left position
    
    repositionSwitch = 0; % keep the current coordinates when the figure already exist
    handles = rmfield(handles, 'hMain');
end

% Choose default command line output for ib_datasetInfoGui
handles.output = hObject;
set(hObject,'Name','Dataset parameters');
handles.hMain = varargin{1};
refreshBtn_Callback(handles.refreshBtn, eventdata, handles);    % fill the table

% adding a popup menu to the table
handles.table_cm = uicontextmenu('Parent',handles.ib_datasetInfoGui);
uimenu(handles.table_cm, 'Label', 'Modify', 'Callback', {@popupCallback, 'modify'});
uimenu(handles.table_cm, 'Label', 'Insert a new', 'Callback', {@popupCallback, 'insert'});
uimenu(handles.table_cm, 'Label', 'Delete', 'Separator','on','Callback', {@popupCallback, 'delete'});
set(handles.fileinfoTable,'uicontextmenu',handles.table_cm);

% update font and size
if get(handles.uipanel1, 'fontsize') ~= handles.hMain.preferences.Font.FontSize ...
        || ~strcmp(get(handles.uipanel1, 'fontname'), handles.hMain.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_datasetInfoGui, handles.hMain.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_datasetInfoGui);

% Update handles structure
guidata(hObject, handles);

% Determine the position of the dialog - on a side of the main figure
% if available, else, centered on the screen
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
            FigPos(1:2) = [GCBFPos(1)-FigWidth-16 GCBFPos(2)+GCBFPos(4)-FigHeight+55];
        elseif GCBFPos(1) + GCBFPos(3) + FigWidth < screenSize(3) % put figure on the right side of the main figure
            FigPos(1:2) = [GCBFPos(1)+GCBFPos(3)+16 GCBFPos(2)+GCBFPos(4)-FigHeight+55];
        else
            FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
        end
    end
    FigPos(3:4)=[FigWidth FigHeight];
    set(hObject, 'Position', FigPos);
    set(hObject, 'Units', OldUnits);
else
    % sync tables
    drawnow;
    jViewport.setViewPosition(originalPos);
    jScrollPane.repaint;
end
ib_datasetInfoGui_ResizeFcn(hObject, eventdata, handles);
% UIWAIT makes ib_datasetInfoGui wait for user response (see UIRESUME)
% uiwait(handles.ib_datasetInfoGui);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_datasetInfoGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
% delete(handles.ib_datasetInfoGui);
end

% --- Executes on button press in refreshBtn.
function refreshBtn_Callback(hObject, eventdata, handles)
handles.hMain = guidata(handles.hMain.im_browser);

jScrollPane = findjobj(handles.fileinfoTable);  % sync views
if ~isempty(jScrollPane)
    jViewport = jScrollPane.getViewport;
    originalPos = jViewport.getViewPosition;  % java.awt.Point[x=150,y=54]
end

tableUnits = get(handles.fileinfoTable, 'Units');
set(handles.fileinfoTable, 'Units', 'Pixels');
fields = keys(handles.hMain.Img{handles.hMain.Id}.I.img_info);
dat = cell(numel(fields),2);
for index = 1:numel(fields)
    if strcmp(fields(index),'UnknownTags') % unknown parameters, skip
        continue;
    else
        dat(index,1) = fields(index);
        switch class(handles.hMain.Img{handles.hMain.Id}.I.img_info(fields{index}))
            case 'char'
                dat{index,2} = sprintf('%s',handles.hMain.Img{handles.hMain.Id}.I.img_info(fields{index}));
            case 'double'
                dat(index,2) = {num2str(handles.hMain.Img{handles.hMain.Id}.I.img_info(fields{index}))};
        end
    end
end
set(handles.fileinfoTable, 'Data', dat);
set(handles.fileinfoTable, 'Units',tableUnits);
if ~isempty(jScrollPane)    % sync views
    drawnow;
    jViewport.setViewPosition(originalPos);
    jScrollPane.repaint;
end
guidata(handles.ib_datasetInfoGui, handles)
end

function popupCallback(hObject, ~, parameter)
% popup menu callback
handles = guidata(hObject);
switch parameter
    case 'modify'
        modifyBtn_Callback(hObject, NaN, handles);
    case 'insert'
        insertBtn_Callback(hObject, NaN, handles);
    case 'delete'
        deleteBtn_Callback(hObject, NaN, handles);
end
end


% --- Executes when ib_datasetInfoGui is resized.
function ib_datasetInfoGui_ResizeFcn(hObject, eventdata, handles)
if isstruct(handles) == 0; return; end;
tableUnits = get(handles.fileinfoTable, 'Units');
set(handles.fileinfoTable, 'Units', 'Characters');
size_char = get(handles.fileinfoTable, 'Position');
set(handles.fileinfoTable, 'Units', 'Pixels');
size_pix = get(handles.fileinfoTable, 'Position');
ratio = size_pix(3)/size_char(3);

dat = get(handles.fileinfoTable, 'data');
counts = max(cellfun(@(x) numel(x), dat(:,1)));     % get the longest field
firstColumnWidth = ratio*counts;
firstColumnWidth = min([size_pix(3)/3*2 firstColumnWidth]);     % fix for situation when the parameter value is too long
set(handles.fileinfoTable, 'ColumnWidth', {firstColumnWidth size_pix(3)-firstColumnWidth-19});
set(handles.fileinfoTable, 'Units',tableUnits);
end


% --- Executes when user attempts to close ib_datasetInfoGui.
function ib_datasetInfoGui_CloseRequestFcn(hObject, eventdata, handles)
guidata(handles.hMain.im_browser, handles.hMain);
delete(hObject);
end


% --- Executes on button press in insertBtn.
function insertBtn_Callback(hObject, eventdata, handles)
options.Resize = 'on';
prompt = {'New parameter name:','New parameter value:'};
answer = inputdlg(prompt,'Insert an entry',[1; 5],{'',''},options);
if isempty(answer); return; end;
handles.hMain.Img{handles.hMain.Id}.I.img_info(answer{1}) = answer{2};
set(handles.fileinfoTable,'userdata','');
refreshBtn_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in modifyBtn.
function modifyBtn_Callback(hObject, eventdata, handles)
selection = get(handles.fileinfoTable,'userdata');
if size(selection,1) ~= 1 || isempty(selection)
    errordlg(sprintf('Please select a single cell and try again!'),'Error');
    return;
end
dat = get(handles.fileinfoTable, 'data');

options.Resize = 'on';
answer = inputdlg('Please modify the entry:','Modify the entry',5,dat(selection(1),selection(2)),options);
if isempty(answer); return; end;
if selection(1,2) == 2  % modify the value
    handles.hMain.Img{handles.hMain.Id}.I.img_info(dat{selection(1,1),1}) = answer{1}; 
else                    % modify the parameter name
    handles.hMain.Img{handles.hMain.Id}.I.img_info(answer{1}) = dat{selection(1,1),2};  % add new key
    remove(handles.hMain.Img{handles.hMain.Id}.I.img_info, dat{selection(1,1),1});      % remove the old key
end
set(handles.fileinfoTable,'userdata','');
refreshBtn_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in deleteBtn.
function deleteBtn_Callback(hObject, eventdata, handles)
% hObject    handle to deleteBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = get(handles.fileinfoTable,'userdata');
if isempty(selection)
    errordlg(sprintf('Please select a cells and try again!'),'Error');
    return;
end
selection = unique(selection(:,1));
button = questdlg(sprintf('Warning!!!\n\nYou are going to delete the highlighted parameters!\nAre you sure?'),'Delete entries','Delete','Cancel','Cancel');
if strcmp(button, 'Cancel'); return; end;

dat = get(handles.fileinfoTable, 'data');
keySet = dat(selection,1);
remove(handles.hMain.Img{handles.hMain.Id}.I.img_info, keySet);
set(handles.fileinfoTable,'userdata','');
refreshBtn_Callback(hObject, eventdata, handles);
end


% --- Executes when selected cell(s) is changed in fileinfoTable.
function fileinfoTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to fileinfoTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if isempty(eventdata.Indices); return; end;
set(handles.fileinfoTable,'userdata', eventdata.Indices);   % store selected position
data = get(handles.fileinfoTable, 'data');
set(handles.selectedText, 'String',data{eventdata.Indices(1,1), eventdata.Indices(1,2)});
    
% Update handles structure
guidata(handles.ib_datasetInfoGui, handles);
end
