function varargout = preferencesDlg(varargin)
% varargout = preferencesDlg(varargin)
% preferencesDlg a dialog responsible for setting preferences for
% im_browser.m
%
% preferencesDlg contains MATLAB code for preferencesDlg.fig

% Copyright (C) 02.09.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 26.10.2016, IB, updated for segmentation table

 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @preferencesDlg_OpeningFcn, ...
    'gui_OutputFcn',  @preferencesDlg_OutputFcn, ...
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

% --- Executes just before preferencesdlg is made visible.
function preferencesDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to preferencesdlg (see VARARGIN)

% Choose default command line output for preferencesdlg

handles.preferences = varargin{1};
handles.im_browser = varargin{2};

% set background color to panels and texts
set(handles.preferencesDlg,'Color',[.831 .816 .784]);
tempList = findall(handles.preferencesDlg,'Style','text');   % set color to text
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.preferencesDlg,'Type','uipanel');    % set color to panels
set(tempList,'BackgroundColor',[.831 .816 .784]);
tempList = findall(handles.preferencesDlg,'Style','checkbox');    % set color to checkboxes
set(tempList,'BackgroundColor',[.831 .816 .784]);

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.preferencesDlg);

% update widgets
if strcmp(handles.preferences.mouseWheel, 'zoom')
    set(handles.mouseWheelPopup, 'Value', 1);
else
    set(handles.mouseWheelPopup, 'Value', 2);
end
if strcmp(handles.preferences.mouseButton, 'pan')
    set(handles.mouseButtonPopup, 'Value', 1);
else
    set(handles.mouseButtonPopup, 'Value', 2);
end
if strcmp(handles.preferences.undo, 'yes')
    set(handles.undoPopup, 'Value', 1);
    set(handles.maxUndoHistory, 'Enable','on');
    set(handles.max3dUndoHistory, 'Enable','on');
else
    set(handles.undoPopup, 'Value', 2);
    set(handles.maxUndoHistory, 'Enable','off');
    set(handles.max3dUndoHistory, 'Enable','off');
end
if strcmp(handles.preferences.resize, 'nearest')
    set(handles.imresizePopup, 'Value', 1);
else
    set(handles.imresizePopup, 'Value', 2);
end
if strcmp(handles.preferences.disableSelection, 'no')
    set(handles.disableSelectionPopup, 'Value', 1);
else
    set(handles.disableSelectionPopup, 'Value', 2);
end
if strcmp(handles.preferences.interpolationType, 'line')
    set(handles.interpolationTypePopup,'Value', 2);
    set(handles.interpolationLineWidth,'Enable', 'on');
end
if handles.preferences.uint8 == 1
    set(handles.maxModelPopup, 'Value', 2);
end

set(handles.annotationFontSizeCombo, 'value', handles.preferences.annotationFontSize);

set(handles.fontSizeDirEdit, 'string', num2str(handles.preferences.fontSizeDir));
set(handles.fontSizeEdit, 'string', num2str(handles.preferences.Font.FontSize));

% update font and size
if get(handles.text2, 'fontsize') ~= handles.preferences.Font.FontSize ...
        || strcmp(get(handles.text2, 'fontname'), handles.preferences.Font.FontName)
    ib_updateFontSize(handles.preferencesDlg, handles.preferences.Font);
end

set(handles.maxUndoHistory,'String', num2str(handles.preferences.maxUndoHistory));
set(handles.max3dUndoHistory,'String', num2str( handles.preferences.max3dUndoHistory));
set(handles.interpolationNoPoints, 'String', num2str(handles.preferences.interpolationNoPoints));
set(handles.interpolationLineWidth, 'String', num2str(handles.preferences.interpolationLineWidth));

set(handles.annotationColorBtn, 'BackgroundColor', handles.preferences.annotationColor);
set(handles.colorMaskBtn, 'BackgroundColor', handles.preferences.maskcolor);
set(handles.colorSelectionBtn, 'BackgroundColor', handles.preferences.selectioncolor);

% updating options for color palettes
mainWindowHandles = guidata(handles.im_browser);
materialsNumber = numel(mainWindowHandles.Img{mainWindowHandles.Id}.I.modelMaterialNames);

if materialsNumber > 12
    paletteList = {'Matlab Jet','Matlab Gray','Matlab Bone','Matlab HSV', 'Matlab Cool', 'Matlab Hot','Random Colors'};
    set(handles.paletteTypePopup, 'string', paletteList);
    paletteTypePopup_Callback(hObject, eventdata, handles);
elseif materialsNumber > 11
    paletteList = {'Qualitative (Monte Carlo->Half Baked), 3-12 colors','Matlab Jet','Matlab Gray','Matlab Bone','Matlab HSV', 'Matlab Cool', 'Matlab Hot','Random Colors'};
    set(handles.paletteTypePopup, 'string', paletteList);
    paletteTypePopup_Callback(hObject, eventdata, handles);
elseif materialsNumber > 9
    paletteList = {'Qualitative (Monte Carlo->Half Baked), 3-12 colors','Diverging (Deep Bronze->Deep Teal), 3-11 colors','Diverging (Ripe Plum->Kaitoke Green), 3-11 colors',...
                   'Diverging (Bordeaux->Green Vogue), 3-11 colors, 3-11 colors', 'Diverging (Carmine->Bay of Many), 3-11 colors',...
                   'Matlab Jet','Matlab Gray','Matlab Bone','Matlab HSV', 'Matlab Cool', 'Matlab Hot','Random Colors'};
    set(handles.paletteTypePopup, 'string', paletteList);
    paletteTypePopup_Callback(hObject, eventdata, handles);
elseif materialsNumber > 6
    paletteList = {'Qualitative (Monte Carlo->Half Baked), 3-12 colors','Diverging (Deep Bronze->Deep Teal), 3-11 colors','Diverging (Ripe Plum->Kaitoke Green), 3-11 colors',...
                   'Diverging (Bordeaux->Green Vogue), 3-11 colors, 3-11 colors', 'Diverging (Carmine->Bay of Many), 3-11 colors','Sequential (Kaitoke Green), 3-9 colors',...
                   'Sequential (Catalina Blue), 3-9 colors', 'Sequential (Maroon), 3-9 colors', 'Sequential (Astronaut Blue), 3-9 colors', 'Sequential (Downriver), 3-9 colors',...
                   'Matlab Jet','Matlab Gray','Matlab Bone','Matlab HSV', 'Matlab Cool', 'Matlab Hot','Random Colors'};
    set(handles.paletteTypePopup, 'string', paletteList);
    paletteTypePopup_Callback(hObject, eventdata, handles);
else
    paletteList = {'Default, 6 colors', 'Qualitative (Monte Carlo->Half Baked), 3-12 colors','Diverging (Deep Bronze->Deep Teal), 3-11 colors','Diverging (Ripe Plum->Kaitoke Green), 3-11 colors',...
                   'Diverging (Bordeaux->Green Vogue), 3-11 colors', 'Diverging (Carmine->Bay of Many), 3-11 colors','Sequential (Kaitoke Green), 3-9 colors',...
                   'Sequential (Catalina Blue), 3-9 colors', 'Sequential (Maroon), 3-9 colors', 'Sequential (Astronaut Blue), 3-9 colors', 'Sequential (Downriver), 3-9 colors',...
                   'Matlab Jet','Matlab Gray','Matlab Bone','Matlab HSV', 'Matlab Cool', 'Matlab Hot', 'Random Colors'};
    set(handles.paletteTypePopup, 'string', paletteList);
    paletteTypePopup_Callback(hObject, eventdata, handles);
end
% adding colors to the materials color table
updateModelColorTable(handles);

% adding colors to the LUT color table for color channels
updateLUTColorTable(handles);

% add context menu to the colormap table
handles.modelsColorsTable_cm = uicontextmenu('Parent',handles.preferencesDlg);
uimenu(handles.modelsColorsTable_cm, 'Label', 'Reverse colormap', 'Callback', {@modelsColorsTable_cb, 'reverse'});
uimenu(handles.modelsColorsTable_cm, 'Label', 'Insert color', 'Separator', 'on', 'Callback', {@modelsColorsTable_cb, 'insert'});
uimenu(handles.modelsColorsTable_cm, 'Label', 'Replace with random color', 'Callback', {@modelsColorsTable_cb, 'random'});
uimenu(handles.modelsColorsTable_cm, 'Label', 'Swap two colors', 'Callback', {@modelsColorsTable_cb, 'swap'});
uimenu(handles.modelsColorsTable_cm, 'Label', 'Delete color(s)', 'Callback', {@modelsColorsTable_cb, 'delete'});
uimenu(handles.modelsColorsTable_cm, 'Label', 'Import from Matlab', 'Separator', 'on', 'Callback', {@modelsColorsTable_cb, 'import'});
uimenu(handles.modelsColorsTable_cm, 'Label', 'Export to Matlab', 'Callback', {@modelsColorsTable_cb, 'export'});
uimenu(handles.modelsColorsTable_cm, 'Label', 'Load from a file', 'Callback', {@modelsColorsTable_cb, 'load'});
uimenu(handles.modelsColorsTable_cm, 'Label', 'Save to a file', 'Callback', {@modelsColorsTable_cb, 'save'});
set(handles.modelsColorsTable,'uicontextmenu',handles.modelsColorsTable_cm);

handles.output = handles.preferences;

% Update handles structure
guidata(hObject, handles);

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

% Make the GUI modal
set(handles.preferencesDlg,'WindowStyle','modal');

% UIWAIT makes preferencesdlg wait for user response (see UIRESUME)
uiwait(handles.preferencesDlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = preferencesDlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.preferencesDlg);
end

% --- Executes on button press in OKBtn.
function OKBtn_Callback(hObject, eventdata, handles)
% hObject    handle to OKBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles.output = get(hObject,'String');

applyBtn_Callback(hObject, eventdata, handles);

handles.output = handles.preferences;
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.preferencesDlg);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainWindowHandles = guidata(handles.im_browser);
if mainWindowHandles.preferences.Font.FontSize ~= handles.preferences.Font.FontSize ||...
        ~strcmp(mainWindowHandles.preferences.Font.FontName, handles.preferences.Font.FontName)
    ib_updateFontSize(0, mainWindowHandles.preferences.Font);
end

handles.output = NaN;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.preferencesDlg);
end


% --- Executes when user attempts to close preferencesDlg.
function preferencesDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to preferencesDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
end

% --- Executes on key press over preferencesDlg with no controls selected.
function preferencesDlg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to preferencesDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = NaN;
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.preferencesDlg);
end

if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.preferencesDlg);
end
end

% --- Executes on selection change in mouseWheelPopup.
function mouseWheelPopup_Callback(hObject, eventdata, handles)
list = get(hObject, 'String');
handles.preferences.mouseWheel = list{get(hObject,'Value')};
% Update handles structure
guidata(hObject, handles);
end


% --- Executes on selection change in mouseButtonPopup.
function mouseButtonPopup_Callback(hObject, eventdata, handles)
list = get(hObject, 'String');
handles.preferences.mouseButton = list{get(hObject,'Value')};
% Update handles structure
guidata(hObject, handles);
end


% --- Executes on selection change in undoPopup.
function undoPopup_Callback(hObject, eventdata, handles)
list = get(hObject, 'String');
handles.preferences.undo = list{get(hObject,'Value')};
if strcmp(handles.preferences.undo, 'no')
    set(handles.maxUndoHistory, 'Enable','off');
    set(handles.max3dUndoHistory, 'Enable','off');
else
    set(handles.maxUndoHistory, 'Enable','on');
    set(handles.max3dUndoHistory, 'Enable','on');
end
% Update handles structure
guidata(hObject, handles);
end


% --- Executes on selection change in imresizePopup.
function imresizePopup_Callback(hObject, eventdata, handles)
list = get(hObject, 'String');
handles.preferences.resize = list{get(hObject,'Value')};
guidata(hObject, handles); % Update handles structure
end


% --- Executes on button press in colorSelectionBtn.
function colorSelectionBtn_Callback(hObject, eventdata, handles)
% set color for the selection layer
sel_color = handles.preferences.selectioncolor;
c = uisetcolor(sel_color, 'Select Selection color');
if length(c) == 1; return; end;
handles.preferences.selectioncolor = c;
set(handles.colorSelectionBtn, 'BackgroundColor', handles.preferences.selectioncolor);
guidata(hObject, handles); % Update handles structure
end

% --- Executes on button press in colorMaskBtn.
function colorMaskBtn_Callback(hObject, eventdata, handles)
% set color for the mask layer
sel_color = handles.preferences.maskcolor;
c = uisetcolor(sel_color, 'Select Selection color');
if length(c) == 1; return; end;
handles.preferences.maskcolor = c;
set(handles.colorMaskBtn, 'BackgroundColor', handles.preferences.maskcolor);
guidata(hObject, handles); % Update handles structure
end

% --- Executes on press of the color selector for materials
function colorModelSelection_Callback(hObject, eventdata, handles)
position = get(handles.modelsColorsTable,'userdata');
if isempty(position)
    msgbox(sprintf('Error!\nPlease select a row in the table first'),'Error!','error','modal');
    return;
end
figTitle = ['Set color for countour ' num2str(position(1))];
c = uisetcolor(handles.preferences.modelMaterialColors(position(1),:), figTitle);
if length(c) == 1; return; end;
handles.preferences.modelMaterialColors(position(1),:) = c;
guidata(hObject, handles); % Update handles structure
updateModelColorTable(handles);
end

function updateModelColorTable(handles)
% adding colors to the color table for materials
% position: define the row to be selected

colergen = @(color,text) ['<html><table border=0 width=40 bgcolor=',color,'><TR><TD>',text,'</TD></TR> </table></html>'];
data = cell([size(handles.preferences.modelMaterialColors, 1), 4]);
for colorId = 1:size(handles.preferences.modelMaterialColors, 1)
    data{colorId, 1} = round(handles.preferences.modelMaterialColors(colorId, 1)*255);
    data{colorId, 2} = round(handles.preferences.modelMaterialColors(colorId, 2)*255);
    data{colorId, 3} = round(handles.preferences.modelMaterialColors(colorId, 3)*255);
    data{colorId, 4} = colergen(sprintf('''rgb(%d, %d, %d)''', round(handles.preferences.modelMaterialColors(colorId, 1)*255), round(handles.preferences.modelMaterialColors(colorId, 2)*255), round(handles.preferences.modelMaterialColors(colorId, 3)*255)),'&nbsp;');  % rgb(0,255,0)
end
set(handles.modelsColorsTable, 'Data', data);
set(handles.modelsColorsTable, 'ColumnWidth', {39 40 39 32});
end

function modelsColorsTable_cb(hObject, eventdata, parameter)
% callback to the popup menu of handles.modelsColorsTable
handles = guidata(hObject);

position = get(handles.modelsColorsTable,'userdata');   % position = [rowIndex, columnIndex]
if isempty(position) && (~strcmp(parameter, 'reverse') && ~strcmp(parameter, 'import') && ~strcmp(parameter, 'export') ...
        && ~strcmp(parameter, 'load') && ~strcmp(parameter, 'save'))
    msgbox(sprintf('Error!\nPlease select a row in the table first'),'Error!','error','modal');
    return;
end

mainWindowHandles = guidata(handles.im_browser);
materialsNumber = numel(mainWindowHandles.Img{mainWindowHandles.Id}.I.modelMaterialNames);

rng('shuffle');     % randomize generator

switch parameter
    case 'reverse'  % reverse the colormap
        handles.preferences.modelMaterialColors = handles.preferences.modelMaterialColors(end:-1:1,:);  
    case 'insert'
        noColors = size(handles.preferences.modelMaterialColors,1);
        if position(1) == noColors
            handles.preferences.modelMaterialColors = [handles.preferences.modelMaterialColors; rand([1,3])];
        else
            handles.preferences.modelMaterialColors = [handles.preferences.modelMaterialColors(1:position(1),:); rand([1,3]); handles.preferences.modelMaterialColors(position(1)+1:noColors,:)];
        end
    case 'random'   % generate a random color
        handles.preferences.modelMaterialColors(position(1),:) = rand([1,3]);
    case 'swap'     % swap two colors
        answer = mib_inputdlg(mainWindowHandles, sprintf('Enter a color number to swap with the selected\nSelected: %d', position(1)),'Swap with','1');
        if size(answer) == 0; return; end;
        tableContents = get(handles.modelsColorsTable, 'Data');
        newIndex = str2double(answer{1});
        if newIndex > size(tableContents,1) || newIndex < 1
            errordlg(sprintf('The entered number is too big or too small\nIt should be between 0-%d', size(tableContents,1)), 'Wrong value');
            return;
        end
        selectedColor = handles.preferences.modelMaterialColors(position(1),:);
        handles.preferences.modelMaterialColors(position(1),:) = handles.preferences.modelMaterialColors(newIndex,:);
        handles.preferences.modelMaterialColors(str2double(answer{1}),:) = selectedColor;
    case 'delete'   % delete selected color
        handles.preferences.modelMaterialColors(position(:,1),:) = [];
    case 'import'   % import color from matlab workspace
        title = 'Import colormap';
        prompt = sprintf('Input a variable that contains colormap\n\nIt should be a matrix [colorNumber, [R,G,B]]');
        %answer = inputdlg(prompt,title,[1 30],{'colormap'},'on');
        answer = mib_inputdlg(mainWindowHandles, prompt, title, 'colormap');
        if size(answer) == 0; return; end;
        
        try
            colormap = evalin('base',answer{1});
        catch exception
            errordlg(sprintf('The variable was not found in the Matlab base workspace:\n\n%s', exception.message),'Misssing variable!','modal');
            return;
        end
        
        errorSwitch = 0;
        if ndims(colormap) ~= 2; errorSwitch = 1;  end; %#ok<ISMAT>
        if size(colormap,2) ~= 3; errorSwitch = 1;  end;
        if max(max(colormap)) > 255 || min(min(colormap)) < 0; errorSwitch = 1;  end;
        
        if errorSwitch == 1
            errordlg(sprintf('Wrong format of the colormap!\n\nThe colormap should be a matrix [colorIndex, [R,G,B]],\nwith R,G,B between 0-1 or 0-255'),'Wrong colormap')
            return;
        end
        if max(max(colormap)) > 1   % convert from 0-255 to 0-1
            colormap = colormap/255;
        end
        handles.preferences.modelMaterialColors = colormap;
    case 'export'       % export color to Matlab workspace
        title = 'Export colormap';
        prompt = sprintf('Input a destination variable for export\n\nA matrix containing the current colormap [colorNumber, [R,G,B]] will be assigned to this variable');
        %answer = inputdlg(prompt,title,[1 30],{'colormap'},'on');
        answer = mib_inputdlg(mainWindowHandles, prompt, title, 'colormap');
        if size(answer) == 0; return; end;
        assignin('base',answer{1}, handles.preferences.modelMaterialColors);
        disp(['Colormap export: created variable ' answer{1} ' in the Matlab workspace']); 
    case 'load'
        [FileName,PathName] = uigetfile({'*.cmap';'*.mat';'*.*'},'Load colormap',fileparts(mainWindowHandles.Img{mainWindowHandles.Id}.I.img_info('Filename')));
        load(fullfile(PathName, FileName),'-mat');
        handles.preferences.modelMaterialColors = cmap; %#ok<NODEF>
    case 'save'
        [PathName, FileName] = fileparts(mainWindowHandles.Img{mainWindowHandles.Id}.I.img_info('Filename'));
        [FileName,PathName] = uiputfile('*.cmap','Save colormap',fullfile(PathName, [FileName '.cmap']));
        cmap = handles.preferences.modelMaterialColors; %#ok<NASGU>
        save(fullfile(PathName, FileName),'cmap');
        disp(['im_browser: the colormap was saved to ' fullfile(PathName, FileName)]);
end
 
% generate random colors when number of colors less than number of
% materials
if size(handles.preferences.modelMaterialColors, 1) < materialsNumber
    missingColors = materialsNumber-size(handles.preferences.modelMaterialColors, 1);
    handles.preferences.modelMaterialColors = [handles.preferences.modelMaterialColors; rand([missingColors,3])];
end


guidata(hObject, handles); % Update handles structure
updateModelColorTable(handles);
end



function updateLUTColorTable(handles)
% adding colors to the color table for the color channels LUT
colergen = @(color,text) ['<html><table border=0 width=40 bgcolor=',color,'><TR><TD>',text,'</TD></TR> </table></html>'];
data = cell([size(handles.preferences.lutColors, 1), 4]);
for colorId = 1:size(handles.preferences.lutColors, 1)
    data{colorId, 1} = round(handles.preferences.lutColors(colorId, 1)*255);
    data{colorId, 2} = round(handles.preferences.lutColors(colorId, 2)*255);
    data{colorId, 3} = round(handles.preferences.lutColors(colorId, 3)*255);
    data{colorId, 4} = colergen(sprintf('''rgb(%d, %d, %d)''', round(handles.preferences.lutColors(colorId, 1)*255), round(handles.preferences.lutColors(colorId, 2)*255), round(handles.preferences.lutColors(colorId, 3)*255)),'&nbsp;');  % rgb(0,255,0)
end
set(handles.lutColorsTable, 'Data', data);
set(handles.lutColorsTable, 'ColumnWidth', {39 40 39 32});
end

% --- Executes when selected cell(s) is changed in modelsColorsTable.
function modelsColorsTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to modelsColorsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if isempty(eventdata.Indices); return; end; % for return after modelColorsTable_CellEditCallback error
set(handles.modelsColorsTable,'userdata', eventdata.Indices);   % store selected position
guidata(hObject, handles); % Update handles structure
if eventdata.Indices(2) == 4    % start color selection dialog
    colorModelSelection_Callback(handles.modelsColorsTable, eventdata, handles) 
end
end


% --- Executes when entered data in editable cell(s) in modelsColorsTable.
function modelsColorsTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to modelsColorsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
if eventdata.NewData < 0 || eventdata.NewData > 255
    msgbox(sprintf('Error!\nThe colors should be in range 0-255'),'Error!','error','modal');
    updateModelColorTable(handles);
    return;
end

handles.preferences.modelMaterialColors(eventdata.Indices(1),eventdata.Indices(2)) = eventdata.NewData/255;
guidata(hObject, handles); % Update handles structure
updateModelColorTable(handles);
end

% --- Executes when entered data in editable cell(s) in modelsColorsTable.
function lutColorsTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to modelsColorsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
if eventdata.NewData < 0 || eventdata.NewData > 255
    msgbox(sprintf('Error!\nThe colors should be in range 0-255'),'Error!','error','modal');
    updateLUTColorTable(handles);
    return;
end

handles.preferences.lutColors(eventdata.Indices(1),eventdata.Indices(2)) = (eventdata.NewData)/255;
guidata(hObject, handles); % Update handles structure
updateLUTColorTable(handles);
end

% --- Executes on button press in applyBtn.
function applyBtn_Callback(hObject, eventdata, handles)
mainWindowHandles = guidata(handles.im_browser);
if strcmp(handles.preferences.disableSelection, 'no')   % turn ON the Selection
    if strcmp(mainWindowHandles.Img{mainWindowHandles.Id}.I.model_type, 'uint8') && isnan(mainWindowHandles.Img{mainWindowHandles.Id}.I.selection(1))
        mainWindowHandles.Img{mainWindowHandles.Id}.I.clearSelection();
    elseif strcmp(mainWindowHandles.Img{mainWindowHandles.Id}.I.model_type, 'uint6') && isnan(mainWindowHandles.Img{mainWindowHandles.Id}.I.model(1))
        mainWindowHandles.Img{mainWindowHandles.Id}.I.model = zeros(...
            [mainWindowHandles.Img{mainWindowHandles.Id}.I.height, mainWindowHandles.Img{mainWindowHandles.Id}.I.width, mainWindowHandles.Img{mainWindowHandles.Id}.I.no_stacks, mainWindowHandles.Img{mainWindowHandles.Id}.I.time],'uint8');
    end
else         % turn OFF the Selection, Mask, Model
    if strcmp(mainWindowHandles.Img{mainWindowHandles.Id}.I.model_type, 'uint8')
        mainWindowHandles.Img{mainWindowHandles.Id}.I.model = NaN;
    else
        mainWindowHandles.Img{mainWindowHandles.Id}.I.selection = NaN;    
    end
    mainWindowHandles.Img{mainWindowHandles.Id}.I.modelExist = 0;
    mainWindowHandles.Img{mainWindowHandles.Id}.I.maskExist = 0;
    mainWindowHandles.U.clearContents();  % delete backup history
end

% update font size
handles.preferences.fontSizeDir = str2double(get(handles.fontSizeDirEdit, 'string'));
set(mainWindowHandles.filesListbox, 'fontsize', handles.preferences.fontSizeDir);
if get(mainWindowHandles.zoomText, 'fontsize') ~= handles.preferences.Font.FontSize || ...
    ~strcmp(get(mainWindowHandles.zoomText, 'fontname'), handles.preferences.Font.FontName)
    ib_updateFontSize(mainWindowHandles.im_browser, handles.preferences.Font);
    ib_updateFontSize(handles.preferencesDlg, handles.preferences.Font);
end
mainWindowHandles.preferences = handles.preferences;
mainWindowHandles.Img{mainWindowHandles.Id}.I.modelMaterialColors = handles.preferences.modelMaterialColors;
mainWindowHandles.Img{mainWindowHandles.Id}.I.lutColors = handles.preferences.lutColors;
toolbarInterpolation(mainWindowHandles.toolbarInterpolation, '', mainWindowHandles, 'keepcurrent');     % update the interpolation button icon
toolbarResizingMethod(mainWindowHandles.toolbarInterpolation, '', mainWindowHandles, 'keepcurrent');     % update the image interpolation button icon
mainWindowHandles.Img{mainWindowHandles.Id}.I.plotImage(mainWindowHandles.imageAxes, mainWindowHandles, 0);
guidata(hObject, handles); % Update handles structure
end

function undoHistory_Callback(hObject, eventdata, handles)
val = str2double(get(handles.maxUndoHistory, 'String'));
val2 = str2double(get(handles.max3dUndoHistory, 'String'));
if val < 1
    msgbox(sprintf('Error!\nThe minimal total number of history steps is 1'),'Error!','error','modal');
    set(handles.maxUndoHistory, 'String', num2str(handles.preferences.maxUndoHistory));
    return;
end
if val2 < 0
    msgbox(sprintf('Error!\nThe minimal total number of 3D history steps is 0'),'Error!','error','modal');
    set(handles.maxUndoHistory, 'String', num2str(handles.preferences.max2dUndoHistory));
    return;
end

if val2 > val
    msgbox(sprintf('Error!\nThe number of 3D history steps should be lower or equal than total number of steps'),'Error!','error','modal');
    set(handles.maxUndoHistory, 'String', num2str(handles.preferences.maxUndoHistory));
    set(handles.max3dUndoHistory, 'String', num2str(handles.preferences.max3dUndoHistory));
    return;
end
handles.preferences.maxUndoHistory = val;
handles.preferences.max3dUndoHistory = val2;
guidata(hObject, handles); % Update handles structure
end


% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
mainWindowHandles = guidata(handles.im_browser);
web(fullfile(mainWindowHandles.pathMIB, 'techdoc/html/ug_gui_menu_file_preferences.html'), '-helpbrowser');
end


% --- Executes on selection change in disableSelectionPopup.
function disableSelectionPopup_Callback(hObject, eventdata, handles)
list = get(hObject, 'String');
value = list{get(hObject,'Value')};
if strcmp(value, 'yes')
    button = questdlg(sprintf('!!! Warning !!!\nDisabling of the Selection layer delete the Model and Mask layers!!!\n\nAre you sure?'),'Model will be removed!','Continue','Cancel','Cancel');
    if strcmp(button, 'Cancel');
        set(hObject, 'value', 1);
        return;
    end
end

handles.preferences.disableSelection = value;
guidata(hObject, handles); % Update handles structure
end

% --- Executes on selection change in interpolationTypePopup.
function interpolationTypePopup_Callback(hObject, eventdata, handles)
value = get(handles.interpolationTypePopup,'Value');
if value == 1   % shape interpolation
    handles.preferences.interpolationType = 'shape';
    set(handles.interpolationLineWidth,'Enable','off');
else            % line interpolation
    handles.preferences.interpolationType = 'line';
    set(handles.interpolationLineWidth,'Enable','on');
end

guidata(hObject, handles); % Update handles structure
end

function interpolationNoPoints_Callback(hObject, eventdata, handles)
val = str2double(get(handles.interpolationNoPoints, 'String'));
if val < 1
    msgbox(sprintf('Error!\nThe minimal number of interpolation points is 1'),'Error!','error','modal');
    set(handles.interpolationNoPoints, 'String', num2str(handles.preferences.interpolationNoPoints));
    return;
end
handles.preferences.interpolationNoPoints = val;
guidata(hObject, handles); % Update handles structure
end

function interpolationLineWidth_Callback(hObject, eventdata, handles)
val = str2double(get(handles.interpolationLineWidth, 'String'));
if val < 1
    msgbox(sprintf('Error!\nThe minimal number of the line width is 1'),'Error!','error','modal');
    set(handles.interpolationLineWidth, 'String', num2str(handles.preferences.interpolationLineWidth));
    return;
end
handles.preferences.interpolationLineWidth = val;
guidata(hObject, handles); % Update handles structure
end


% --- Executes on selection change in maxModelPopup.
function maxModelPopup_Callback(hObject, eventdata, handles)
val = get(handles.maxModelPopup, 'Value');
if val == 1
    handles.preferences.uint8 = 0;  % store all Model, Selection and Mask in one matrix of the uint8 type
else
    handles.preferences.uint8 = 1;  % store Model, Selection and Mask in three different matrices of the uint8 type
end
guidata(hObject, handles); % Update handles structure
end

% --- Executes when selected cell(s) is changed in modelsColorsTable.
function lutColorsTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to modelsColorsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if isempty(eventdata.Indices); return; end; % for return after lutColorsTable_CellSelectionCallback error
set(handles.lutColorsTable,'userdata', eventdata.Indices);   % store selected position
guidata(hObject, handles); % Update handles structure
if eventdata.Indices(2) == 4    % start color selection dialog
    colorChannelSelection_Callback(handles.lutColorsTable, eventdata, handles) 
end
end

% --- Executes on button of color stripe in the Color channels table
function colorChannelSelection_Callback(hObject, eventdata, handles)
position = get(handles.lutColorsTable,'userdata');
if isempty(position)
    msgbox(sprintf('Error!\nPlease select a row in the table first'),'Error!','error','modal');
    return;
end
figTitle = ['Set color for channel ' num2str(position(1))];
c = uisetcolor(handles.preferences.lutColors(position(1),:), figTitle);
if length(c) == 1; return; end;
handles.preferences.lutColors(position(1),:) = c;
guidata(hObject, handles); % Update handles structure
updateLUTColorTable(handles);
end


function fontSizeDirEdit_Callback(hObject, eventdata, handles)
mainWindowHandles = guidata(handles.im_browser);
guidata(hObject, handles); % Update handles structure
end

function fontSizeEdit_Callback(hObject, eventdata, handles)
% update font size for preferencesDlg
handles.preferences.Font.FontSize = str2double(get(handles.fontSizeEdit, 'string'));
guidata(hObject, handles); % Update handles structure
end


% --- Executes on button press in annotationColorBtn.
function annotationColorBtn_Callback(hObject, eventdata, handles)
sel_color = handles.preferences.annotationColor;
c = uisetcolor(sel_color, 'Select color for annotations');
if length(c) == 1; return; end;
handles.preferences.annotationColor = c;
set(handles.annotationColorBtn, 'BackgroundColor', handles.preferences.annotationColor);
guidata(hObject, handles); % Update handles structure
end


% --- Executes on selection change in annotationFontSizeCombo.
function annotationFontSizeCombo_Callback(hObject, eventdata, handles)
handles.preferences.annotationFontSize = get(handles.annotationFontSizeCombo, 'value');
guidata(hObject, handles); % Update handles structure
end


% --- Executes on button press in defaultBtn.
function defaultBtn_Callback(hObject, eventdata, handles)
button = questdlg(sprintf('You are going to restore default settings\n(except the key shortcuts)\nAre you sure?'),'Restore default settings','Restore','Cancel','Cancel');
if strcmp(button, 'Cancel'); return; end;

    handles.preferences.mouseWheel = 'scroll';  % type of the mouse wheel action, 'scroll': change slices; 'zoom': zoom in/out
    handles.preferences.mouseButton = 'select'; % swap the left and right mouse wheel actions, 'select': pick or draw with the left mouse button; 'pan': to move the image with the left mouse button
    handles.preferences.undo = 'yes';   % enable undo
    handles.preferences.resize = 'bicubic'; % image resizing method for zooming
    handles.preferences.disableSelection = 'no';    % disable selection with the mouse
    handles.preferences.maskcolor = [255 0 255]/255;    % color for the mask layer
    handles.preferences.selectioncolor = [0 255 0]/255; % color for the selection layer
    handles.preferences.modelMaterialColors = [166 67 33;       % default colors for the materials of models
                                       71 178 126; 
                                       79 107 171;
                                       150 169 213;
                                       26 51 111;
                                       255 204 102 ]/255;
    handles.preferences.alphaSelection = .75;       % transparency of the selection layer
    handles.preferences.alphaMask = .75;            % transparency of the mask layer
    handles.preferences.alphaModel = .75;           % transparency of the model layer
    handles.preferences.maxUndoHistory = 8;         % number of steps for the Undo history
    handles.preferences.max3dUndoHistory = 3;       % number of steps for the Undo history for whole dataset
    handles.preferences.uint8 = 0;                  % type of the model: uint6 with 63 maximal number of materials
    handles.preferences.fontSizeDir = 10;        % font size for files and directories
    handles.preferences.fontSize = 8;      % font size for labels
    handles.preferences.lastSegmTool = [3, 4];  % fast access to the selection type tools with the 'd' shortcut
    handles.preferences.annotationColor = [1 1 0];  % color for annotations
    handles.preferences.annotationFontSize = 2;     % font size for annotations
    handles.preferences.interpolationType = 'shape';    % type of the interpolator to use
    handles.preferences.interpolationNoPoints = 200;     % number of points to use for the interpolation
    handles.preferences.interpolationLineWidth = 4;      % line width for the 'line' interpotator
    handles.preferences.lutColors = [       % add colors for color channels
        1 0 0     % red
        0 1 0     % green
        0 0 1     % blue
        1 0 1     % purple
        1 1 0     % yellow
        1 .65 0]; % orange
    
    preferencesDlg_OpeningFcn(hObject, eventdata, handles, handles.preferences, handles.im_browser);
end


% --- Executes on selection change in paletteTypePopup.
function paletteTypePopup_Callback(hObject, eventdata, handles)
selectedVal = get(handles.paletteTypePopup, 'value');
paletteList = get(handles.paletteTypePopup, 'string');
if ischar(paletteList); paletteList = cellstr(paletteList); end;
set(handles.paletteColorNumberPopup, 'value',1);
mainWindowHandles = guidata(handles.im_browser);
materialsNumber = numel(mainWindowHandles.Img{mainWindowHandles.Id}.I.modelMaterialNames);

switch paletteList{selectedVal}
    case 'Default, 6 colors'
        set(handles.paletteColorNumberPopup, 'string','6');
    case 'Qualitative (Monte Carlo->Half Baked), 3-12 colors'
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):12));
    case 'Diverging (Deep Bronze->Deep Teal), 3-11 colors'
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):11));
    case 'Diverging (Ripe Plum->Kaitoke Green), 3-11 colors'        
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):11));
    case 'Diverging (Bordeaux->Green Vogue), 3-11 colors'        
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):11));    
    case 'Diverging (Carmine->Bay of Many), 3-11 colors'        
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):11));
    case 'Sequential (Kaitoke Green), 3-9 colors'        
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):9));
    case 'Sequential (Catalina Blue), 3-9 colors'        
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):9));  
    case 'Sequential (Maroon), 3-9 colors'        
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):9));  
    case 'Sequential (Astronaut Blue), 3-9 colors'        
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):9)); 
    case 'Sequential (Downriver), 3-9 colors'        
        set(handles.paletteColorNumberPopup, 'string', num2cell(max([3, materialsNumber]):9)); 
    case {'Matlab Jet','Matlab Gray','Matlab Bone','Matlab HSV', 'Matlab Cool', 'Matlab Hot', 'Random Colors'}
        %answer = inputdlg('Enter number of colors','Define number of colors',1, cellstr(num2str(max(materialsNumber, 6))));
        answer = mib_inputdlg(mainWindowHandles, 'Enter number of colors', 'Define number of colors', num2str(max(materialsNumber, 6)));
        if isempty(answer); return; end;
        noColors = str2double(answer{1});
        set(handles.paletteColorNumberPopup, 'string', num2cell(noColors)); 
end
updateColorPalette(hObject, eventdata, handles);
end

function updateColorPalette(hObject, eventdata, handles)
% update color palette based on selected parameters in the paletteTypePopup and paletteColorNumberPopup popups
selectedVal = get(handles.paletteTypePopup, 'value');
paletteList = get(handles.paletteTypePopup, 'string');
if ischar(paletteList); paletteList = cellstr(paletteList); end;
colorList = get(handles.paletteColorNumberPopup, 'string');
colorVal = get(handles.paletteColorNumberPopup, 'value');
if iscell(colorList)
    colorsNo = str2double(colorList{colorVal});
else
    colorsNo = str2double(colorList);
end
switch paletteList{selectedVal}
    case 'Default, 6 colors'
        handles.preferences.modelMaterialColors = [166 67 33; 71 178 126; 79 107 171; 150 169 213; 26 51 111; 255 204 102 ]/255;
    case 'Qualitative (Monte Carlo->Half Baked), 3-12 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218]/255;
            case 4; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114]/255;
            case 5; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114; 128,177,211]/255;
            case 6; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114; 128,177,211; 253,180,98]/255;                
            case 7; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114; 128,177,211; 253,180,98; 179,222,105]/255;
            case 8; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114; 128,177,211; 253,180,98; 179,222,105; 252,205,229]/255;
            case 9; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114; 128,177,211; 253,180,98; 179,222,105; 252,205,229; 217,217,217]/255;
            case 10; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114; 128,177,211; 253,180,98; 179,222,105; 252,205,229; 217,217,217; 188,128,189]/255;
            case 11; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114; 128,177,211; 253,180,98; 179,222,105; 252,205,229; 217,217,217; 188,128,189; 204,235,197]/255;
            case 12; handles.preferences.modelMaterialColors = [141,211,199; 255,255,179; 190,186,218; 251,128,114; 128,177,211; 253,180,98; 179,222,105; 252,205,229; 217,217,217; 188,128,189; 204,235,197; 255,237,111]/255;
        end
    case 'Diverging (Deep Bronze->Deep Teal), 3-11 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [216,179,101; 245,245,245; 90,180,172]/255;
            case 4; handles.preferences.modelMaterialColors = [166,97,26; 223,194,125; 128,205,193; 1,133,113]/255;
            case 5; handles.preferences.modelMaterialColors = [166,97,26; 223,194,125; 245,245,245; 128,205,193; 1,133,113]/255;
            case 6; handles.preferences.modelMaterialColors = [140,81,10; 216,179,101; 246,232,195; 199,234,229; 90,180,172; 1,102,94]/255;                
            case 7; handles.preferences.modelMaterialColors = [140,81,10; 216,179,101; 246,232,195; 245,245,245; 199,234,229; 90,180,172; 1,102,94]/255;
            case 8; handles.preferences.modelMaterialColors = [140,81,10; 191,129,45; 223,194,125; 246,232,195; 199,234,229; 128,205,193; 53,151,143; 1,102,94]/255;
            case 9; handles.preferences.modelMaterialColors = [140,81,10; 191,129,45; 223,194,125; 246,232,195; 245,245,245; 199,234,229; 128,205,193; 53,151,143; 1,102,94]/255;
            case 10; handles.preferences.modelMaterialColors = [84,48,5; 140,81,10; 191,129,45; 223,194,125; 246,232,195; 199,234,229; 128,205,193; 53,151,143; 1,102,94; 0,60,48]/255;
            case 11; handles.preferences.modelMaterialColors = [84,48,5; 140,81,10; 191,129,45; 223,194,125; 246,232,195; 245,245,245; 199,234,229; 128,205,193; 53,151,143; 1,102,94; 0,60,48]/255;
        end
    case 'Diverging (Ripe Plum->Kaitoke Green), 3-11 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [175,141,195; 247,247,247; 127,191,123]/255;
            case 4; handles.preferences.modelMaterialColors = [123,50,148; 194,165,207; 166,219,160; 0,136,55]/255;
            case 5; handles.preferences.modelMaterialColors = [123,50,148; 194,165,207; 247,247,247; 166,219,160; 0,136,55]/255;
            case 6; handles.preferences.modelMaterialColors = [118,42,131; 175,141,195; 231,212,232; 217,240,211; 127,191,123; 27,120,55]/255;                
            case 7; handles.preferences.modelMaterialColors = [118,42,131; 175,141,195; 231,212,232; 247,247,247; 217,240,211; 127,191,123; 27,120,55]/255;
            case 8; handles.preferences.modelMaterialColors = [118,42,131; 153,112,171; 194,165,207; 231,212,232; 217,240,211; 166,219,160; 90,174,97; 27,120,55]/255;
            case 9; handles.preferences.modelMaterialColors = [118,42,131; 153,112,171; 194,165,207; 231,212,232; 247,247,247; 217,240,211; 166,219,160; 90,174,97; 27,120,55]/255;
            case 10; handles.preferences.modelMaterialColors = [64,0,75; 118,42,131; 153,112,171; 194,165,207; 231,212,232; 217,240,211; 166,219,160; 90,174,97; 27,120,55; 0,68,27]/255;
            case 11; handles.preferences.modelMaterialColors = [64,0,75; 118,42,131; 153,112,171; 194,165,207; 231,212,232; 247,247,247; 217,240,211; 166,219,160; 90,174,97; 27,120,55; 0,68,27]/255;
        end
    case 'Diverging (Bordeaux->Green Vogue), 3-11 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [239,138,98; 247,247,247; 103,169,207]/255;
            case 4; handles.preferences.modelMaterialColors = [202,0,32; 244,165,130; 146,197,222; 5,113,176]/255;
            case 5; handles.preferences.modelMaterialColors = [202,0,32; 244,165,130; 247,247,247; 146,197,222; 5,113,176]/255;
            case 6; handles.preferences.modelMaterialColors = [178,24,43; 239,138,98; 253,219,199; 209,229,240; 103,169,207; 33,102,172]/255;                
            case 7; handles.preferences.modelMaterialColors = [178,24,43; 239,138,98; 253,219,199; 247,247,247; 209,229,240; 103,169,207; 33,102,172]/255;
            case 8; handles.preferences.modelMaterialColors = [178,24,43; 214,96,77; 244,165,130; 253,219,199; 209,229,240; 146,197,222; 67,147,195; 33,102,172]/255;
            case 9; handles.preferences.modelMaterialColors = [178,24,43; 214,96,77; 244,165,130; 253,219,199; 247,247,247; 209,229,240; 146,197,222; 67,147,195; 33,102,172]/255;
            case 10; handles.preferences.modelMaterialColors = [103,0,31; 178,24,43; 214,96,77; 244,165,130; 253,219,199; 209,229,240; 146,197,222; 67,147,195; 33,102,172; 5,48,97]/255;
            case 11; handles.preferences.modelMaterialColors = [103,0,31; 178,24,43; 214,96,77; 244,165,130; 253,219,199; 247,247,247; 209,229,240; 146,197,222; 67,147,195; 33,102,172; 5,48,97]/255;
        end 
    case 'Diverging (Carmine->Bay of Many), 3-11 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [252,141,89; 255,255,191; 145,191,219]/255;
            case 4; handles.preferences.modelMaterialColors = [215,25,28; 253,174,97; 171,217,233; 44,123,182]/255;
            case 5; handles.preferences.modelMaterialColors = [215,25,28; 253,174,97; 255,255,191; 171,217,233; 44,123,182]/255;
            case 6; handles.preferences.modelMaterialColors = [215,48,39; 252,141,89; 254,224,144; 224,243,248; 145,191,219; 69,117,180]/255;                
            case 7; handles.preferences.modelMaterialColors = [215,48,39; 252,141,89; 254,224,144; 255,255,191; 224,243,248; 145,191,219; 69,117,180]/255;
            case 8; handles.preferences.modelMaterialColors = [215,48,39; 244,109,67; 253,174,97; 254,224,144; 224,243,248; 171,217,233; 116,173,209; 69,117,180]/255;
            case 9; handles.preferences.modelMaterialColors = [215,48,39; 244,109,67; 253,174,97; 254,224,144; 255,255,191; 224,243,248; 171,217,233; 116,173,209; 69,117,180]/255;
            case 10; handles.preferences.modelMaterialColors = [165,0,38; 215,48,39; 244,109,67; 253,174,97; 254,224,144; 224,243,248; 171,217,233; 116,173,209; 69,117,180; 49,54,149]/255;
            case 11; handles.preferences.modelMaterialColors = [165,0,38; 215,48,39; 244,109,67; 253,174,97; 254,224,144; 255,255,191; 224,243,248; 171,217,233; 116,173,209; 69,117,180; 49,54,149]/255;
        end  
    case 'Sequential (Kaitoke Green), 3-9 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [229,245,249; 153,216,201; 44,162,95]/255;
            case 4; handles.preferences.modelMaterialColors = [237,248,251; 178,226,226; 102,194,164; 35,139,69]/255;
            case 5; handles.preferences.modelMaterialColors = [237,248,251; 178,226,226; 102,194,164; 44,162,95; 0,109,44]/255;
            case 6; handles.preferences.modelMaterialColors = [237,248,251; 204,236,230; 153,216,201; 102,194,164; 44,162,95; 0,109,44]/255;                
            case 7; handles.preferences.modelMaterialColors = [237,248,251; 204,236,230; 153,216,201; 102,194,164; 65,174,118; 35,139,69; 0,88,36]/255;
            case 8; handles.preferences.modelMaterialColors = [247,252,253; 229,245,249; 204,236,230; 153,216,201; 102,194,164; 65,174,118; 35,139,69; 0,88,36]/255;
            case 9; handles.preferences.modelMaterialColors = [247,252,253; 229,245,249; 204,236,230; 153,216,201; 102,194,164; 65,174,118; 35,139,69; 0,109,44; 0,68,27]/255;
        end
    case 'Sequential (Catalina Blue), 3-9 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [224,243,219; 168,221,181; 67,162,202]/255;
            case 4; handles.preferences.modelMaterialColors = [240,249,232; 186,228,188; 123,204,196; 43,140,190]/255;
            case 5; handles.preferences.modelMaterialColors = [240,249,232; 186,228,188; 123,204,196; 67,162,202; 8,104,172]/255;
            case 6; handles.preferences.modelMaterialColors = [240,249,232; 204,235,197; 168,221,181; 123,204,196; 67,162,202; 8,104,172]/255;                
            case 7; handles.preferences.modelMaterialColors = [240,249,232; 204,235,197; 168,221,181; 123,204,196; 78,179,211; 43,140,190; 8,88,158]/255;
            case 8; handles.preferences.modelMaterialColors = [247,252,240; 224,243,219; 204,235,197; 168,221,181; 123,204,196; 78,179,211; 43,140,190; 8,88,158]/255;
            case 9; handles.preferences.modelMaterialColors = [247,252,240; 224,243,219; 204,235,197; 168,221,181; 123,204,196; 78,179,211; 43,140,190; 8,104,172; 8,64,129]/255;
        end   
        case 'Sequential (Maroon), 3-9 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [254,232,200; 253,187,132; 227,74,51]/255;
            case 4; handles.preferences.modelMaterialColors = [254,240,217; 253,204,138; 252,141,89; 215,48,31]/255;
            case 5; handles.preferences.modelMaterialColors = [254,240,217; 253,204,138; 252,141,89; 227,74,51; 179,0,0]/255;
            case 6; handles.preferences.modelMaterialColors = [254,240,217; 253,212,158; 253,187,132; 252,141,89; 227,74,51; 179,0,0]/255;                
            case 7; handles.preferences.modelMaterialColors = [254,240,217; 253,212,158; 253,187,132; 252,141,89; 239,101,72; 215,48,31; 153,0,0]/255;
            case 8; handles.preferences.modelMaterialColors = [255,247,236; 254,232,200; 253,212,158; 253,187,132; 252,141,89; 239,101,72; 215,48,31; 153,0,0]/255;
            case 9; handles.preferences.modelMaterialColors = [255,247,236; 254,232,200; 253,212,158; 253,187,132; 252,141,89; 239,101,72; 215,48,31; 179,0,0; 127,0,0]/255;
        end      
        case 'Sequential (Astronaut Blue), 3-9 colors'
        switch colorsNo
            case 3; handles.preferences.modelMaterialColors = [236,231,242; 166,189,219; 43,140,190]/255;
            case 4; handles.preferences.modelMaterialColors = [241,238,246; 189,201,225; 116,169,207; 5,112,176]/255;
            case 5; handles.preferences.modelMaterialColors = [241,238,246; 189,201,225; 116,169,207; 43,140,190; 4,90,141]/255;
            case 6; handles.preferences.modelMaterialColors = [241,238,246; 208,209,230; 166,189,219; 116,169,207; 43,140,190; 4,90,141]/255;                
            case 7; handles.preferences.modelMaterialColors = [241,238,246; 208,209,230; 166,189,219; 116,169,207; 54,144,192; 5,112,176; 3,78,123]/255;
            case 8; handles.preferences.modelMaterialColors = [255,247,251; 236,231,242; 208,209,230; 166,189,219; 116,169,207; 54,144,192; 5,112,176; 3,78,123]/255;
            case 9; handles.preferences.modelMaterialColors = [255,247,251; 236,231,242; 208,209,230; 166,189,219; 116,169,207; 54,144,192; 5,112,176; 4,90,141; 2,56,88]/255;
        end  
        case 'Sequential (Downriver), 3-9 colors'
            switch colorsNo
                case 3; handles.preferences.modelMaterialColors = [237,248,177; 127,205,187; 44,127,184]/255;
                case 4; handles.preferences.modelMaterialColors = [255,255,204; 161,218,180; 65,182,196; 34,94,168]/255;
                case 5; handles.preferences.modelMaterialColors = [255,255,204; 161,218,180; 65,182,196; 44,127,184; 37,52,148]/255;
                case 6; handles.preferences.modelMaterialColors = [255,255,204; 199,233,180; 127,205,187; 65,182,196; 44,127,184; 37,52,148]/255;
                case 7; handles.preferences.modelMaterialColors = [255,255,204; 199,233,180; 127,205,187; 65,182,196; 29,145,192; 34,94,168; 12,44,132]/255;
                case 8; handles.preferences.modelMaterialColors = [255,255,217; 237,248,177; 199,233,180; 127,205,187; 65,182,196; 29,145,192; 34,94,168; 12,44,132]/255;
                case 9; handles.preferences.modelMaterialColors = [255,255,217; 237,248,177; 199,233,180; 127,205,187; 65,182,196; 29,145,192; 34,94,168; 37,52,148; 8,29,88]/255;
            end
    case 'Matlab Jet'
        handles.preferences.modelMaterialColors =  colormap(jet(colorsNo));
    case 'Matlab Gray'
        handles.preferences.modelMaterialColors =  colormap(gray(colorsNo));
    case 'Matlab Bone'
        handles.preferences.modelMaterialColors =  colormap(bone(colorsNo));
    case 'Matlab HSV'
        handles.preferences.modelMaterialColors =  colormap(hsv(colorsNo));
    case 'Matlab Cool'
        handles.preferences.modelMaterialColors =  colormap(cool(colorsNo));
    case 'Matlab Hot'
        handles.preferences.modelMaterialColors =  colormap(hot(colorsNo));
    case 'Random Colors'
        rng('shuffle');     % randomize generator
        handles.preferences.modelMaterialColors =  colormap(rand([colorsNo,3]));
end
updateModelColorTable(handles);
guidata(hObject, handles); % Update handles structure
end


% --- Executes on button press in fontBtn.
function fontBtn_Callback(hObject, eventdata, handles)
currFont = get(handles.text2);
selectedFont = uisetfont(currFont);
selectedFont = rmfield(selectedFont, 'FontWeight');
selectedFont = rmfield(selectedFont, 'FontAngle');

handles.preferences.Font = selectedFont;
ib_updateFontSize(handles.preferencesDlg, handles.preferences.Font);
set(handles.fontSizeEdit, 'string', num2str(handles.preferences.Font.FontSize));
guidata(hObject, handles); % Update handles structure
end


% --- Executes on button press in keyShortcutsBtn.
function keyShortcutsBtn_Callback(hObject, eventdata, handles)
KeyShortcuts = mib_keyShortcutsDlg(handles.preferences.KeyShortcuts);
if isempty(KeyShortcuts); return; end;
handles.preferences.KeyShortcuts = KeyShortcuts;
guidata(hObject, handles); % Update handles structure
end
