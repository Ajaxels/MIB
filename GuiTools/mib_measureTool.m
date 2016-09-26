function varargout = mib_measureTool(varargin)
% MIB_MEASURETOOL MATLAB code for mib_measureTool.fig
%      MIB_MEASURETOOL, by itself, creates a new MIB_MEASURETOOL or raises the existing
%      singleton*.
%
%      H = MIB_MEASURETOOL returns the handle to a new MIB_MEASURETOOL or the handle to
%      the existing singleton*.
%
%      MIB_MEASURETOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIB_MEASURETOOL.M with the given input arguments.
%
%      MIB_MEASURETOOL('Property','Value',...) creates a new MIB_MEASURETOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mib_measureTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mib_measureTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mib_measureTool

% Copyright (C) 28.08.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 27.02.2016, IB, updated for 4D datasets


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mib_measureTool_OpeningFcn, ...
                   'gui_OutputFcn',  @mib_measureTool_OutputFcn, ...
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


% --- Executes just before mib_measureTool is made visible.
function mib_measureTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_measureTool (see VARARGIN)

repositionSwitch = 1; % reposition the figure, when creating a new figure
if numel(varargin) > 1  % reinitialize the dialog
    handles = guidata(varargin{2});
    repositionSwitch = 0; % keep the current coordinates when the figure already exist
    handles = rmfield(handles, 'h');
else
    % add some default parameters here
end
handles.h = varargin{1};    % handles of im_browser

% turn off the fine tune check
set(handles.finetuneCheck, 'value', 0);

updateWidgets(handles);     % update widgets of the mib_measureTool window

handles.measureTable_cm = uicontextmenu('Parent',handles.mib_measureTool);
uimenu(handles.measureTable_cm, 'Label', 'Jump to measurement...', 'Callback', {@measureTable_cm, 'Jump'});
uimenu(handles.measureTable_cm, 'Label', 'Edit measurement...', 'Callback', {@measureTable_cm, 'Edit'});
uimenu(handles.measureTable_cm, 'Label', 'Duplicate measurement...', 'Callback', {@measureTable_cm, 'Duplicate'});
uimenu(handles.measureTable_cm, 'Label', 'Plot intensity profile...', 'Callback', {@measureTable_cm, 'Plot'});
uimenu(handles.measureTable_cm, 'Label', 'Delete measurement...', 'Callback', {@measureTable_cm, 'Delete'},'Separator','on');
set(handles.measureTable,'UIContextMenu',handles.measureTable_cm);

% indeces of the selected rows
handles.indices = [];

% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.mib_measureTool, handles.h.preferences.Font);
end

% Choose default command line output for mib_measureTool
handles.output = hObject;

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_measureTool);

% Update handles structure
guidata(hObject, handles);

% Determine the position of the dialog - centered on the callback figure
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
end

% UIWAIT makes mib_measureTool wait for user response (see UIRESUME)
% uiwait(handles.mib_measureTool);
end


% --- Outputs from this function are returned to the command line.
function varargout = mib_measureTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.h;

end

% --- Executes when mib_measureTool is resized.
function mib_measureTool_ResizeFcn(hObject, eventdata, handles)
winPos = get(handles.mib_measureTool, 'position');

measurePanelPos = get(handles.measurePanel, 'position');
measurePanelPos(2) = winPos(4)-measurePanelPos(4);
measurePanelPos(3) = winPos(3)-6;
set(handles.measurePanel, 'position', measurePanelPos);

plotPanelPos = get(handles.plotPanel, 'position');
plotPanelPos(2) = winPos(4)-measurePanelPos(4)-plotPanelPos(4)-1;
plotPanelPos(3) = winPos(3)/2-6;
set(handles.plotPanel, 'position',plotPanelPos);

voxelPanelPos = get(handles.voxelPanel, 'position');
voxelPanelPos(2) = plotPanelPos(2);
voxelPanelPos(3) = plotPanelPos(3);
voxelPanelPos(1) = plotPanelPos(3)+9;
set(handles.voxelPanel, 'position',voxelPanelPos);

buttonsPanelPos = get(handles.buttonsPanel, 'position');
buttonsPanelPos(3) = winPos(3) - 7;
set(handles.buttonsPanel, 'position', buttonsPanelPos);

resultsPanelPos = get(handles.resultsPanel, 'position');
resultsPanelPos(3) = measurePanelPos(3);
resultsPanelPos(2) = buttonsPanelPos(2)+buttonsPanelPos(4);
resultsPanelPos(4) = winPos(4)-measurePanelPos(4)-plotPanelPos(4)-buttonsPanelPos(4)-5;
set(handles.resultsPanel, 'position', resultsPanelPos);
end

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
handles.output = handles.h;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_measureTool);
delete(handles.mib_measureTool);
end

function updateWidgets(handles)
handles.h = guidata(handles.h.im_browser);  % update handles

% updating color channels
colList = get(handles.h.ColChannelCombo, 'string');
%set(handles.imageColChPopup, 'string', colList(2:end));
%set(handles.imageColChPopup, 'value', max([get(handles.h.ColChannelCombo,'value')-1, 1]));
set(handles.imageColChPopup, 'string', colList);
set(handles.imageColChPopup, 'value', 1);
if strcmp(handles.h.Img{handles.h.Id}.I.hMeasure.Options.splinemethod, 'spline')
    set(handles.modePopup, 'value', 1);
else
    set(handles.modePopup, 'value', 2);
end

pixSize = handles.h.Img{handles.h.Id}.I.pixSize;
pixString = sprintf('%f / %f / %f', pixSize.x, pixSize.y, pixSize.z);
set(handles.voxelSizeTxt, 'string', pixString);

guidata(handles.mib_measureTool, handles);  % update local handles

updateTable(handles);
end


% --- Executes on button press in addBtn.
function addBtn_Callback(hObject, eventdata, handles)
% update handles
handles.h = guidata(handles.h.im_browser);
ib_do_backup(handles.h, 'measurements', 0);

colCh = get(handles.imageColChPopup, 'value')-1;
typeString = get(handles.measureTypePopup, 'string');
finetuneCheck = get(handles.finetuneCheck, 'value');
set(handles.addBtn, 'backgroundcolor','r');
switch typeString{get(handles.measureTypePopup, 'value')}
    case 'Angle'
        handles.h.Img{handles.h.Id}.I.hMeasure.AngleFun(handles.h, [], colCh, finetuneCheck);
    case 'Caliper'
        handles.h.Img{handles.h.Id}.I.hMeasure.CaliperFun(handles.h, [], colCh, finetuneCheck);
    case 'Circle (R)'
        handles.h.Img{handles.h.Id}.I.hMeasure.CircleFun(handles.h, [], colCh, finetuneCheck);
    case 'Distance (freehand)'
        handles.h.Img{handles.h.Id}.I.hMeasure.DistanceFreeFun(handles.h, colCh, finetuneCheck);
    case 'Distance (linear)'
        handles.h.Img{handles.h.Id}.I.hMeasure.DistanceFun(handles.h, [], colCh, finetuneCheck);
    case 'Distance (polyline)'
        noPoints = str2double(get(handles.noPointsEdit, 'string'));
        handles.h.Img{handles.h.Id}.I.hMeasure.DistancePolyFun(handles.h, [], colCh, noPoints, finetuneCheck);
    case 'Point'
        handles.h.Img{handles.h.Id}.I.hMeasure.PointFun(handles.h, [], colCh, finetuneCheck);
end
handles.h = guidata(handles.h.im_browser);

set(handles.addBtn, 'backgroundcolor','g');
set(handles.h.showAnnotationsCheck,'value',1);
updateTable(handles);
handles.h = guidata(handles.h.im_browser);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end

function updateTable(handles)
handles.h = guidata(handles.h.im_browser);  % update handles

numberOfLabels = handles.h.Img{handles.h.Id}.I.hMeasure.getNumberOfMeasurements();
filterString = get(handles.filterPopup, 'string');
filterText = filterString{get(handles.filterPopup, 'value')};
handles.h.Img{handles.h.Id}.I.hMeasure.typeToShow = filterText;     % update which measurements to show in the imageAxes
if  ~strcmp(filterText, 'All')  % do filtering
    indeces=find(ismember([handles.h.Img{handles.h.Id}.I.hMeasure.Data.type],filterText));
else
    indeces = 1:numberOfLabels;
end

if numel(indeces) >= 1
    data = cell([numel(indeces), 5]);
    data(:,1) = {handles.h.Img{handles.h.Id}.I.hMeasure.Data(indeces).n}';
    data(:,2) = [handles.h.Img{handles.h.Id}.I.hMeasure.Data(indeces).type]';
    data(:,3) = {handles.h.Img{handles.h.Id}.I.hMeasure.Data(indeces).value}';
    data(:,4) = {handles.h.Img{handles.h.Id}.I.hMeasure.Data(indeces).Z}';
    data(:,5) = {handles.h.Img{handles.h.Id}.I.hMeasure.Data(indeces).T}';
    set(handles.measureTable, 'data', data);
else
    data = cell([3,1]);
    set(handles.measureTable, 'data', data);
end

%handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
%guidata(handles.mib_measureTool, handles);  % store handles, otherswise problems when switching dataset-buffers
end

function measureTable_cm(hObject, eventdata, parameter)
handles = guidata(hObject);
handles.h = guidata(handles.h.im_browser);

data = get(handles.measureTable,'Data');
if isempty(data{1,1}); return; end;
if isempty(handles.indices); return; end;

rowId = handles.indices(1,1);
n = data{rowId,1};

switch parameter
    case 'Jump'
        if size(handles.indices,1) > 1
            errordlg('Please select a single cell and try again!','Wrong selection','modal');
            return;
        end
        
        t = handles.h.Img{handles.h.Id}.I.hMeasure.Data(n).T;
        z = handles.h.Img{handles.h.Id}.I.hMeasure.Data(n).Z;
        x = handles.h.Img{handles.h.Id}.I.hMeasure.Data(n).X;
        y = handles.h.Img{handles.h.Id}.I.hMeasure.Data(n).Y;
        % move image-view to the object
        handles.h.Img{handles.h.Id}.I.moveView(x(end), y(end));
        
        % change z
        if size(handles.h.Img{handles.h.Id}.I.img, handles.h.Img{handles.h.Id}.I.orientation) > 1
            set(handles.h.changelayerEdit, 'String', floor(z));
            changelayerEdit_Callback(0, eventdata, handles.h);
        else
            handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
        end
        
        % change t
        if handles.h.Img{handles.h.Id}.I.time > 1
            set(handles.h.changeTimeEdit, 'String', floor(t));
            changeTimeEdit_Callback(0, eventdata, handles.h);
        end
        
    case 'Edit'
        if size(handles.indices,1) > 1
            errordlg('Please select a single cell and try again!','Wrong selection','modal');
            return;
        end
        ib_do_backup(handles.h, 'measurements', 0);
        
        % first jump to the measurement
        z = handles.h.Img{handles.h.Id}.I.hMeasure.Data(n).Z;
        t = handles.h.Img{handles.h.Id}.I.hMeasure.Data(n).T;
        
        % change z
        if size(handles.h.Img{handles.h.Id}.I.img, handles.h.Img{handles.h.Id}.I.orientation) > 1
            set(handles.h.changelayerEdit, 'String', floor(z));
            changelayerEdit_Callback(0, eventdata, handles.h);
        else
            handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
        end
        
        % change t
        if handles.h.Img{handles.h.Id}.I.time > 1
            set(handles.h.changeTimeEdit, 'String', floor(t));
            changeTimeEdit_Callback(0, eventdata, handles.h);
        end
        
        % update measurement
        colCh = get(handles.imageColChPopup, 'value')-1;
        handles.h.Img{handles.h.Id}.I.hMeasure.editMeasurements(handles.h, n, colCh);
        handles.h = guidata(handles.h.im_browser);
        updateTable(handles);
    case 'Duplicate'
        ib_do_backup(handles.h, 'measurements', 0);
        newData = handles.h.Img{handles.h.Id}.I.hMeasure.Data(n);
        handles.h.Img{handles.h.Id}.I.hMeasure.addMeasurements(newData, n);
        updateTable(handles);
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
    case 'Plot'
        figure(1951);
        clf;
        ax = axes();
        rowId = handles.indices(:,1);
        n = [data{rowId,1}];
        set(ax,'NextPlot','add');
        colorOrder = get(ax, 'colororder');
        for i=n
            h{i} = plot(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).profile(1,:), handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).profile(2:end,:));
            set(h{i}, 'color', colorOrder(mod(i, size(colorOrder,1))+1,:));
        end
        legend(num2str(n'));
        grid;
        set(ax,'NextPlot','replace');
        title('Intensity profiles');
        xlabel('Point number');
        ylabel('Intensity');
    case 'Delete'
        ib_do_backup(handles.h, 'measurements', 0);
        rowId = handles.indices(:,1);
        n = [data{rowId,1}];
        
        handles.h.Img{handles.h.Id}.I.hMeasure.removeMeasurements(n);
        updateTable(handles);
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end

end

% --- Executes on button press in deleteAllBtn.
function deleteAllBtn_Callback(hObject, eventdata, handles)
handles.h.Img{handles.h.Id}.I.hMeasure.removeMeasurements();
updateTable(handles);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end


% --- Executes when selected cell(s) is changed in measureTable.
function measureTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to measureTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.indices = eventdata.Indices;

ids = handles.indices(:,1);
data = get(handles.measureTable,'Data');
ids = [data{ids,1}];
cla(handles.profileAxes);
set(handles.profileAxes,'NextPlot','add');
colorOrder = get(handles.profileAxes, 'colororder');

lutColors = handles.h.Img{handles.h.Id}.I.lutColors;
colCh = get(handles.imageColChPopup,'value')-1;

for i=1:numel(ids)
    if colCh==0
        noColorChannels = size(handles.h.Img{handles.h.Id}.I.hMeasure.Data(ids(i)).profile,1)-1;
        h{i} = plot(handles.profileAxes, handles.h.Img{handles.h.Id}.I.hMeasure.Data(ids(i)).profile(1,:), handles.h.Img{handles.h.Id}.I.hMeasure.Data(ids(i)).profile(2:end,:));
        %set(h{i}, 'color', colorOrder(mod(i, size(colorOrder,1))+1,:));
        for colId=1:noColorChannels
            set(h{i}(colId), 'color', lutColors(colId,:));
        end
    else
        colId = min([colCh+1, size(handles.h.Img{handles.h.Id}.I.hMeasure.Data(ids(i)).profile,1)]);
        h{i} = plot(handles.profileAxes, handles.h.Img{handles.h.Id}.I.hMeasure.Data(ids(i)).profile(1,:), handles.h.Img{handles.h.Id}.I.hMeasure.Data(ids(i)).profile(colId,:));
        %set(h{i}, 'color', colorOrder(mod(i, size(colorOrder,1))+1,:));
        set(h{i}, 'color', lutColors(colCh,:));
    end
end
grid on;
set(handles.profileAxes,'NextPlot','replace');
guidata(handles.mib_measureTool, handles);

% jump to the selected measurement
if get(handles.autoJumpCheck,'value')
    measureTable_cm(handles.measureTable, eventdata, 'Jump');
end
figure(handles.mib_measureTool);
end

function updatePlotSettings(hObject, eventdata, handles)
handles.h.Img{handles.h.Id}.I.hMeasure.Options.showMarkers = get(handles.markersCheck, 'value');
handles.h.Img{handles.h.Id}.I.hMeasure.Options.showLines = get(handles.linesCheck, 'value');
handles.h.Img{handles.h.Id}.I.hMeasure.Options.showText = get(handles.textCheck, 'value');
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);

end


% --- Executes on button press in optionsBtn.
function optionsBtn_Callback(hObject, eventdata, handles)
handles.h.Img{handles.h.Id}.I.hMeasure.setOptions();
handles.h = guidata(handles.h.im_browser);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end


% --- Executes on selection change in modePopup.
function modePopup_Callback(hObject, eventdata, handles)
% hObject    handle to modePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns modePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from modePopup
methodString = get(handles.modePopup, 'string');
methodString = methodString{get(handles.modePopup, 'value')};
handles.h.Img{handles.h.Id}.I.hMeasure.Options.splinemethod = methodString;
guidata(handles.h.im_browser, handles.h);   % store handles
end


% --- Executes on selection change in measureTypePopup.
function measureTypePopup_Callback(hObject, eventdata, handles)
typeString = get(handles.measureTypePopup, 'string');
set(handles.noPointsEdit, 'enable', 'off');
set(handles.modePopup, 'enable', 'off');
switch typeString{get(handles.measureTypePopup, 'value')}
    case 'Distance (polyline)'
        set(handles.noPointsEdit, 'enable', 'on');
        set(handles.modePopup, 'enable', 'on');
    case 'Distance (freehand)'        
        set(handles.modePopup, 'enable', 'on');
end
end


% --- Executes on selection change in filterPopup.
function filterPopup_Callback(hObject, eventdata, handles)
updateTable(handles);
end


% --- Executes on button press in loadBtn.
function loadBtn_Callback(hObject, eventdata, handles)
button =  questdlg(sprintf('Would you like to load measurements from a file or from the main Matlab workspace?'),'Import/Load measurements','Load from a file','Import from Matlab','Cancel','Load from a file'); 
switch button
    case 'Cancel'   
        return;
    case 'Import from Matlab'
        title = 'Input variables for import';
        prompt = 'A variable that contains compatible structure:';
        def = 'MIB_measurements';
        answer = mib_inputdlg(handles.h, prompt,title,def); 
        if size(answer) == 0; return; end;
        ib_do_backup(handles.h, 'measurements', 0);
        handles.h.Img{handles.h.Id}.I.hMeasure.Data = evalin('base',answer{1});
    case 'Load from a file'
        [filename, path] = uigetfile(...
            {'*.measure;',  'Matlab format (*.measure)'; ...
            '*.*',  'All Files (*.*)'}, ...
            'Load annotations...',handles.h.mypath);
        if isequal(filename, 0); return; end; % check for cancel
        ib_do_backup(handles.h, 'measurements', 0);
        res = load(fullfile(path, filename),'-mat');
        if ~isfield(res.Data, 'T')  % loading old measurements before 4D datasets
            [res.Data.T] = deal(1);     
        end
            
        handles.h.Img{handles.h.Id}.I.hMeasure.Data = res.Data;
end

updateTable(handles);
set(handles.h.showAnnotationsCheck, 'value', 1);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
fprintf('MIB: import measurements  -> done!\n')
end

% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
if numel(handles.h.Img{handles.h.Id}.I.hMeasure.Data) < 1; return; end;

button =  questdlg(sprintf('Would you like to save measurements to a file or export to the main Matlab workspace?'),'Export/Save measurements','Save to a file','Export to Matlab','Cancel','Save to a file'); 
if strcmp(button, 'Cancel'); return; end;
if strcmp(button, 'Export to Matlab')
    title = 'Input variable to export';
    def = 'MIB_measurements';
    prompt = {'A variable for the measurements structure:'};
    answer = mib_inputdlg(handles.h, prompt,title,def); 
    if size(answer) == 0; return; end;
    assignin('base', answer{1}, handles.h.Img{handles.h.Id}.I.hMeasure.Data);    
    fprintf('MIB: export measurements ("%s") to Matlab -> done!\n', answer{1});
    return;
end

fn_out = handles.h.Img{handles.h.Id}.I.img_info('Filename');
dotIndex = strfind(fn_out,'.');
if ~isempty(dotIndex)
    fn_out = fn_out(1:dotIndex-1);
end
if isempty(strfind(fn_out,'/')) && isempty(strfind(fn_out,'\'))
    fn_out = fullfile(handles.h.mypath, fn_out);
end
if isempty(fn_out)
    fn_out = handles.h.mypath;
end

Filters = {'*.measure;',  'Matlab format (*.measure)';...
           '*.xls',   'Excel format (*.xls)'; };

[filename, path, FilterIndex] = uiputfile(Filters, 'Save measurements...',fn_out); %...
if isequal(filename,0); return; end; % check for cancel
fn_out = fullfile(path, filename);

Data = handles.h.Img{handles.h.Id}.I.hMeasure.Data;
if strcmp('Matlab format (*.measure)', Filters{FilterIndex,2})    % matlab format    
    save(fn_out, 'Data', '-mat', '-v7.3');
    fprintf('MIB: saving measurements to %s -> done!\n', fn_out);
elseif strcmp('Excel format (*.xls)', Filters{FilterIndex,2})    % excel format    
    wb = waitbar(0,'Please wait...','Name','Generating Excel file...','WindowStyle','modal');
    warning off MATLAB:xlswrite:AddSheet
    % Sheet 1
    s = {sprintf('Measurements for %s', handles.h.Img{handles.h.Id}.I.img_info('Filename'));};
    
    s(3,1:8) = {'n','type','value','intensity','[tcoords]','[zcoords]','[xcoords]','[ycoords]'};
    roiId = 4;
    
    shift = 1;
    for i=1:numel(handles.h.Img{handles.h.Id}.I.hMeasure.Data)
        % get the coordinates
        if strcmp(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).type,'Circle (R)')
            X = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).circ.xc ;
            Y = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).circ.yc ;
        elseif strcmp(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).type,'Distance (polyline)')
            X = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).spline.x ;
            Y = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).spline.y ;
        else
            X = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).X;
            Y = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).Y;
        end
        % format to a string
        xstr = '[';
        ystr = '[';
        for kk = 1:length(X);
            if kk == 1
                xstr = [ xstr sprintf('%.2f',X(kk)) ] ;
                ystr = [ ystr sprintf('%.2f',Y(kk)) ] ;
            else
                xstr = [ xstr ' ; ' sprintf('%.2f',X(kk)) ] ;
                ystr = [ ystr ' ; ' sprintf('%.2f',Y(kk)) ] ;
            end
        end
        xstr = [ xstr ']' ];
        ystr = [ ystr ']' ];
        
        s{roiId+shift, 1} = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).n;
        s{roiId+shift, 2} = cell2mat(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).type);
        s{roiId+shift, 3} = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).value;
        for j=1:numel(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).intensity)
            s{roiId+shift+j-1, 4} = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).intensity(j);
        end
        s{roiId+shift, 5} = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).T;
        s{roiId+shift, 6} = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).Z;
        s{roiId+shift, 7} = xstr;
        s{roiId+shift, 8} = ystr;
        
        shift = shift + numel(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).intensity);
    end
    xlswrite2(fn_out, s, 'Sheet1', 'A1');
    
    waitbar(.5, wb);
    
    % Sheet 2
    s = {sprintf('Measurements for %s', handles.h.Img{handles.h.Id}.I.img_info('Filename'));};
    s{2,1} = 'Intensity profiles';
    
    rowId = 5;
    shift = 1;
    for i=1:numel(handles.h.Img{handles.h.Id}.I.hMeasure.Data)
        s{4,shift+1} = handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).n;
        noColChannels = size(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).profile, 1)-1;
        noElements = size(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).profile, 2);
        
        s(rowId:rowId+noElements-1, shift+1:shift+noColChannels) = num2cell(handles.h.Img{handles.h.Id}.I.hMeasure.Data(i).profile(2:end,:)');
        
        shift = shift + noColChannels;
    end
    xlswrite2(fn_out, s, 'Sheet2', 'A1');
    
    waitbar(1, wb);
    delete(wb);
end
end


% --- Executes on button press in refreshTableBtn.
function refreshTableBtn_Callback(hObject, eventdata, handles)
updateWidgets(handles);
end


% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_gui_menu_tools_measure.html'), '-helpbrowser');
end


% --- Executes on button press in updateVoxelsButton.
function updateVoxelsButton_Callback(hObject, eventdata, handles)
handles.h.Img{handles.h.Id}.I.updateParameters();
handles.h = handles.h.Img{handles.h.Id}.I.updateAxesLimits(handles.h, 'resize');
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 1);
updateWidgets(handles);
end
