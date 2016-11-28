function varargout = ib_labelsGui(varargin)
% function varargout = ib_labelsGui(varargin)
% ib_labelsGui is a GUI tool to show list of labels

% Copyright (C) 16.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 25.01.2016, updated for 4D


% Edit the above text to modify the response to help ib_labelsGui

% Last Modified by GUIDE v2.5 20-May-2014 10:52:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ib_labelsGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_labelsGui_OutputFcn, ...
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

% --- Executes just before ib_labelsGui is made visible.
function ib_labelsGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_labelsGui (see VARARGIN)

repositionSwitch = 1; % reposition the figure, when creating a new figure
if numel(varargin) > 1  % reinitialize the dialog
    handles = guidata(varargin{2});
    repositionSwitch = 0; % keep the current coordinates when the figure already exist
    handles = rmfield(handles, 'h');
else
    % add some default parameters here
end
handles.h = varargin{1};    % handles of im_browser

updateTable(handles);

handles.labelsTable_cm = uicontextmenu('Parent',handles.ib_labelsGui);
uimenu(handles.labelsTable_cm, 'Label', 'Add annotation...', 'Callback', {@tableContextMenu_cb, 'Add'});
uimenu(handles.labelsTable_cm, 'Label', 'Jump to annotation...', 'Callback', {@tableContextMenu_cb, 'Jump'});
uimenu(handles.labelsTable_cm, 'Label', 'Delete annotation...', 'Callback', {@tableContextMenu_cb, 'Delete'});
set(handles.labelsTable,'UIContextMenu',handles.labelsTable_cm);

% indeces of the selected rows
handles.indices = [];

% update font and size
if get(handles.jumpCheck, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.jumpCheck, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_labelsGui, handles.h.preferences.Font);
end


% Choose default command line output for ib_labelsGui
handles.output = hObject;

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_labelsGui);

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
            FigPos(1:2) = [GCBFPos(1)-FigWidth-16 GCBFPos(2)+GCBFPos(4)-FigHeight+54];
        elseif GCBFPos(1) + GCBFPos(3) + FigWidth < screenSize(3) % put figure on the right side of the main figure
            FigPos(1:2) = [GCBFPos(1)+GCBFPos(3)+16 GCBFPos(2)+GCBFPos(4)-FigHeight+54];
        else
            FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
        end
    end
    FigPos(3:4)=[FigWidth FigHeight];
    set(hObject, 'Position', FigPos);
    set(hObject, 'Units', OldUnits);
end

% UIWAIT makes ib_labelsGui wait for user response (see UIRESUME)
% uiwait(handles.ib_labelsGui);
end

function updateTable(handles)
numberOfLabels = handles.h.Img{handles.h.Id}.I.hLabels.getLabelsNumber(); 
if numberOfLabels >= 1
    [labelsText, labelsPos, labelIndices] = handles.h.Img{handles.h.Id}.I.hLabels.getLabels();
    data = cell([numel(labelsText), 5]);
    data(:,1) = labelsText';
    data(:,2) = arrayfun(@(x) sprintf('%.2f',x),labelsPos(:,1),'UniformOutput',0);
    data(:,3) = arrayfun(@(x) sprintf('%.2f',x),labelsPos(:,2),'UniformOutput',0);
    data(:,4) = arrayfun(@(x) sprintf('%.2f',x),labelsPos(:,3),'UniformOutput',0);
    data(:,5) = arrayfun(@(x) sprintf('%d',x),labelsPos(:,4),'UniformOutput',0);
    set(handles.labelsTable,'RowName', labelIndices);
    set(handles.labelsTable, 'data', data);
else
    data = cell([5,1]);
    set(handles.labelsTable, 'data', data);set(handles.labelsTable, 'data', data);
end
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_labelsGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.h;

end

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to closeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = handles.h;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_labelsGui);
delete(handles.ib_labelsGui);

end

function tableContextMenu_cb(hObject, eventdata, parameter)
handles = guidata(hObject);
switch parameter
    case 'Add'  % add annotation
        prompt={'Annotation text',...
                sprintf('Z coordinate (Zmax=%d):', handles.h.Img{handles.h.Id}.I.no_stacks)...
                sprintf('X coordinate (Xmax=%d):', handles.h.Img{handles.h.Id}.I.width)...
                sprintf('Y coordinate (Ymax=%d):', handles.h.Img{handles.h.Id}.I.height)...
                sprintf('T coordinate (Tmax=%d)', handles.h.Img{handles.h.Id}.I.time)};
        name='Add annotation';
        numlines=1;
        zVal = num2str(handles.h.Img{handles.h.Id}.I.slices{handles.h.Img{handles.h.Id}.I.orientation}(1));
        tVal = num2str(handles.h.Img{handles.h.Id}.I.slices{5}(1));
        defaultanswer={'TypeSomething',zVal,'10','10',tVal};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer); return; end;
        ib_do_backup(handles.h, 'labels', 0);
        labelsText = answer(1);
        labelsPosition(1) = str2double(answer{2});
        labelsPosition(2) = str2double(answer{3});
        labelsPosition(3) = str2double(answer{4});
        labelsPosition(4) = str2double(answer{5});
        handles.h.Img{handles.h.Id}.I.hLabels.addLabels(labelsText, labelsPosition);
        updateTable(handles);
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
    case 'Jump'     % jump to the highlighted annotation
        data = get(handles.labelsTable,'Data');
        if isempty(data); return; end;
        if isempty(handles.indices); return; end;

        rowId = handles.indices(1);
        data = get(handles.labelsTable, 'data');    % get table contents
        getDim.blockModeSwitch = 0;
        [imgH, imgW, ~, imgZ] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image',NaN,NaN,getDim);
        if handles.h.Img{handles.h.Id}.I.orientation == 4   % xy
            z = str2double(data{rowId,2});
            x = str2double(data{rowId,3});
            y = str2double(data{rowId,4});
        elseif handles.h.Img{handles.h.Id}.I.orientation == 1   % zx
            z = str2double(data{rowId,4});
            x = str2double(data{rowId,2});
            y = str2double(data{rowId,3});
        elseif handles.h.Img{handles.h.Id}.I.orientation == 2   % zy
            z = str2double(data{rowId,3});
            x = str2double(data{rowId,2});
            y = str2double(data{rowId,4});
        end
        t = str2double(data{rowId,5});
        % do not jump when the label out of image boundaries
        if x>imgW || y>imgH || z>imgZ
            warndlg('The annotation is outside of the image boundaries!','Wrong coordinates');
            return; 
        end;
        
        % move image-view to the object
        handles.h.Img{handles.h.Id}.I.moveView(x, y);
        
        % change t
        if handles.h.Img{handles.h.Id}.I.time > 1
            set(handles.h.changeTimeEdit, 'String', floor(t));
            changeTimeEdit_Callback(0, eventdata, handles.h);
        end
        % change z
        if size(handles.h.Img{handles.h.Id}.I.img, handles.h.Img{handles.h.Id}.I.orientation) > 1
            set(handles.h.changelayerEdit, 'String', floor(z));
            changelayerEdit_Callback(0, eventdata, handles.h);
        else
            handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
        end
                
    case 'Delete'   % delete the highlighted annotation
        data = get(handles.labelsTable,'Data');
        if isempty(data); return; end;
        if isempty(handles.indices); return; end;

        rowId = handles.indices(:, 1);
        if numel(rowId) == 1
            button =  questdlg(sprintf('Delete the following annotation?\n\nLabel: %s\n\nCoordinates (z,x,y,t): %s %s %s %s', data{rowId,1},data{rowId,2},data{rowId,3},data{rowId,4},data{rowId,5}),'Delete annotation','Delete','Cancel','Cancel'); 
        else
            button =  questdlg(sprintf('Delete the multiple annotations?'),'Delete annotation','Delete','Cancel','Cancel');
        end
        if strcmp(button, 'Cancel'); return; end;
        ib_do_backup(handles.h, 'labels', 0);
        labelIndices = get(handles.labelsTable,'RowName');    % get indices of the labels
        handles.h.Img{handles.h.Id}.I.hLabels.removeLabels(str2num(labelIndices(rowId,:))); %#ok<ST2NM>
        updateTable(handles);
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end
end


% --- Executes on button press in exportBtn.
function exportBtn_Callback(hObject, eventdata, handles)
[labelsList, labelPositions] = handles.h.Img{handles.h.Id}.I.hLabels.getLabels();
if numel(labelsList) == 0; return; end;

button =  questdlg(sprintf('Would you like to save annotations to a file or export to the main Matlab workspace?'),'Export/Save annotations','Save to a file','Export to Matlab','Cancel','Save to a file'); 
if strcmp(button, 'Cancel'); return; end;
if strcmp(button, 'Export to Matlab')
    title = 'Input variables to export';
    lines = [1 30];
    def = {'labelsList', 'labelPositions'};
    prompt = {'A variable for the annotation labels:','A variable for the annotation coordinates:'};
    answer = inputdlg(prompt,title,lines,def,'on');
    if size(answer) == 0; return; end;
    assignin('base',answer{1},labelsList);    
    assignin('base',answer{2},labelPositions);    
    sprintf('Export annotations (%s and %s) to Matlab: done!', answer{1}, answer{2})
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

Filters = {'*.ann;',  'Matlab format (*.ann)';...
        '*.xls',   'Excel format (*.xls)'; };

[filename, path, FilterIndex] = uiputfile(Filters, 'Save annotations...',fn_out); %...
if isequal(filename,0); return; end; % check for cancel
fn_out = fullfile(path, filename);
if strcmp('Matlab format (*.ann)', Filters{FilterIndex,2})    % matlab format    
    save(fn_out, 'labelsList', 'labelPositions', '-mat', '-v7.3');
    sprintf('Saving annotations to %s: done!', fn_out)
elseif strcmp('Excel format (*.xls)', Filters{FilterIndex,2})    % excel format    
    wb = waitbar(0,'Please wait...','Name','Generating Excel file...','WindowStyle','modal');
    warning off MATLAB:xlswrite:AddSheet
    % Sheet 1
    s = {sprintf('Annotations for %s', handles.h.Img{handles.h.Id}.I.img_info('Filename'));};
    s(4,1) = {'Annotation text'};
    s(3,3) = {'Coordinates'};
    s(4,2) = {'Z'};
    s(4,3) = {'X'};
    s(4,4) = {'Y'};
    s(4,5) = {'Z'};
    roiId = 4;
    for i=1:numel(labelsList)
        s(roiId+i, 1) = labelsList(i);
        s{roiId+i, 2} = labelPositions(i,1);
        s{roiId+i, 3} = labelPositions(i,2);
        s{roiId+i, 4} = labelPositions(i,3);
        s{roiId+i, 5} = labelPositions(i,4);
    end
    xlswrite2(fn_out, s, 'Sheet1', 'A1');
    waitbar(1, wb);
    delete(wb);
end
end

% --- Executes when entered data in editable cell(s) in labelsTable.
function labelsTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to labelsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.labelsTable, 'data');    % get table contents
indices = get(handles.labelsTable, 'RowName');  % get row names, that are indices for the labels.
rowId = eventdata.Indices(1);
ib_do_backup(handles.h, 'labels', 0);

newLabelText = data(rowId,1);
newLabelPos(1) = str2double(data{rowId,2});
newLabelPos(2) = str2double(data{rowId,3});
newLabelPos(3) = str2double(data{rowId,4});
newLabelPos(4) = str2double(data{rowId,5});
handles.h.Img{handles.h.Id}.I.hLabels.updateLabels(str2double(indices(rowId,:)), newLabelText, newLabelPos);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end


    % --- Executes when selected cell(s) is changed in labelsTable.
function labelsTable_CellSelectionCallback(hObject, eventdata, handles)
if get(handles.jumpCheck, 'value')  % jump to the selected annotation
    if isempty(eventdata.Indices); return; end;
    rowId = eventdata.Indices(1);
    data = get(handles.labelsTable, 'data');    % get table contents
    if size(data,1) < rowId; return; end;
    getDim.blockModeSwitch = 0;
        [imgH, imgW, ~, imgZ] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image',NaN,NaN,getDim);
    if handles.h.Img{handles.h.Id}.I.orientation == 4   % xy
        z = str2double(data{rowId,2});
        x = str2double(data{rowId,3});
        y = str2double(data{rowId,4});
    elseif handles.h.Img{handles.h.Id}.I.orientation == 1   % zx
        z = str2double(data{rowId,4});
        x = str2double(data{rowId,2});
        y = str2double(data{rowId,3});
    elseif handles.h.Img{handles.h.Id}.I.orientation == 2   % zy
        z = str2double(data{rowId,3});
        x = str2double(data{rowId,2});
        y = str2double(data{rowId,4});    
    end
    t = str2double(data{rowId,5});    
    % do not jump when the label out of image boundaries
    if x>imgW || y>imgH || z>imgZ
        warndlg('The annotation is outside of the image boundaries!','Wrong coordinates');
        return;
    end;
    
    % move image-view to the object
    handles.h.Img{handles.h.Id}.I.moveView(x, y);
    
    % change t
    if handles.h.Img{handles.h.Id}.I.time > 1
        set(handles.h.changeTimeEdit, 'String', floor(t));
        changeTimeEdit_Callback(0, eventdata, handles.h);
    end
    % change z
    if size(handles.h.Img{handles.h.Id}.I.img, handles.h.Img{handles.h.Id}.I.orientation) > 1
        set(handles.h.changelayerEdit, 'String', floor(z));
        changelayerEdit_Callback(0, eventdata, handles.h);
    else
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
    end
end
handles.indices = eventdata.Indices;
guidata(handles.ib_labelsGui, handles);
end


% --- Executes on button press in importBtn.
function importBtn_Callback(hObject, eventdata, handles)
button =  questdlg(sprintf('Would you like to import annotations from a file or from the main Matlab workspace?'),'Import/Load annotations','Load from a file','Import from Matlab','Cancel','Load from a file'); 
switch button
    case 'Cancel'   
        return;
    case 'Import from Matlab'
        title = 'Input variables for import';
        lines = [1 30];
        def = {'labelsList', 'labelPositions'};
        prompt = {'A variable for the annotation labels:','A variable for the annotation coordinates:'};
        answer = inputdlg(prompt,title,lines,def,'on');
        if size(answer) == 0; return; end;
        ib_do_backup(handles.h, 'labels', 0);
        labelsList = evalin('base',answer{1});
        labelPositions = evalin('base',answer{2});
        if size(labelPositions,2) == 3  % missing the t
            labelPositions(:, 4) = handles.h.Img{handles.h.Id}.I.slices{5}(1);
        end
        handles.h.Img{handles.h.Id}.I.hLabels.replaceLabels(labelsList, labelPositions);
    case 'Load from a file'
        [filename, path] = uigetfile(...
            {'*.ann;',  'Matlab format (*.ann)'; ...
            '*.*',  'All Files (*.*)'}, ...
            'Load annotations...',handles.h.mypath);
        if isequal(filename, 0); return; end; % check for cancel
        ib_do_backup(handles.h, 'labels', 0);
        res = load(fullfile(path, filename),'-mat');
        if size(res.labelPositions,2) == 3  % missing the t
            res.labelPositions(:, 4) = handles.h.Img{handles.h.Id}.I.slices{5}(1);
        end
        handles.h.Img{handles.h.Id}.I.hLabels.replaceLabels(res.labelsList, res.labelPositions);
end
updateTable(handles);
set(handles.h.showAnnotationsCheck, 'value', 1);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
disp('Import annotations: done!')
end


% --- Executes on button press in refreshBtn.
function refreshBtn_Callback(hObject, eventdata, handles)
handles.h = guidata(handles.h.im_browser);
updateTable(handles);
end

% --- Executes on button press in deleteBtn.
function deleteBtn_Callback(hObject, eventdata, handles)
ib_do_backup(handles.h, 'labels', 0);
handles.h.Img{handles.h.Id}.I.hLabels.removeLabels();
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
updateTable(handles);
end
