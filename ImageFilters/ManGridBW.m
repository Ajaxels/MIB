function varargout = ManGridBW(varargin)
% function varargout = ManGridBW(varargin)
% ManGridBW function allows to perform black and white thresholding of the image using the small blocks. In each of these blocks the image
% is thresholded with own coefficient.
%
% ManGridBW contains MATLAB code for ManGridBW.fig

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
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
                   'gui_OpeningFcn', @ManGridBW_OpeningFcn, ...
                   'gui_OutputFcn',  @ManGridBW_OutputFcn, ...
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

% --- Executes just before ManGridBW is made visible.
function ManGridBW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ManGridBW (see VARARGIN)

% Choose default command line output for ManGridBW
handles.h = varargin{1}; % handles of im_browser
handles.roi_mask = varargin{2};     % roi mask
handles.type = varargin{3};     % type: new, add, newSingle

img = ib_getSlice('image', handles.h);
img = img{1};
[bl_w, bl_h] = generate_grid_block_size(size(img,2), size(img,1), handles.h.corrGridrunSize);
rowsNo = ceil(size(img,2)/bl_w);
colsNo = ceil(size(img,1)/bl_h);
handles.thrMatrix = zeros([colsNo rowsNo])+255;
updateTable(handles);

set(handles.allCheck,'Value',get(handles.h.maskGenPanel2DAllRadio,'Value'));   % update local the all switch

% Update handles structure
guidata(hObject, handles);

% rescale widgets for Mac and Linux
%mib_rescaleWidgets(handles.ManGridBW);


% Determine the position of the dialog FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
% GCBFOldUnits = get(gcbf,'Units');
% set(gcbf,'Units','pixels');
% GCBFPos = get(gcbf,'Position');
% set(gcbf,'Units',GCBFOldUnits);
screenSize = get(0,'ScreenSize');
% if GCBFPos(1)-FigWidth > 0 % put figure on the left side of the main figure
%     FigPos(1:2) = [GCBFPos(1)-FigWidth GCBFPos(2)+GCBFPos(4)-FigHeight];
% elseif GCBFPos(1) + GCBFPos(3) + FigWidth < screenSize(3) % put figure on the right side of the main figure
%     FigPos(1:2) = [GCBFPos(1)+GCBFPos(3) GCBFPos(2)+GCBFPos(4)-FigHeight];
% else
%     FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
%         (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
% end
FigPos = [1 screenSize(4)-FigHeight-20 FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% UIWAIT makes ManGridBW wait for user response (see UIRESUME)
% uiwait(handles.manGridBW);
end

% --- Outputs from this function are returned to the command line.
function varargout = ManGridBW_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.h;

% The figure can be deleted now
% delete(handles.manGridBW);
end


% --- Executes on button press in startBtn.
function startBtn_Callback(hObject, eventdata, handles)
wb = waitbar(0,'Thresholding the image...','Name','Manual grid');
gridSize = handles.h.corrGridrunSize;
allSw = get(handles.allCheck,'Value');
if allSw == 1 
    handles.type = 'new'; 
else
    handles.type = 'newSingle';
end;
handles.thrMatrix = get(handles.thresholdsTable,'Data');

if allSw == 1
    img = ib_getDataset('image', handles.h);
    img = img{1};
    layer_id = 0;
else
    img = ib_getSlice('image', handles.h);
    img = img{1};
    layer_id = 1;
end
waitbar(.05,wb);
[filter_out, selection] = get_black_white_filter(img,[0 0],0,handles.roi_mask,...
    gridSize, 0, handles.h.Img{handles.h.Id}.I.orientation, layer_id, handles.thrMatrix);
if size(filter_out,1) <= 1; return; end;
waitbar(.9,wb);
if strcmp(handles.type,'new')   % make completely new mask
    ib_setDataset('mask', filter_out, handles.h);
    ib_setDataset('selection', selection, handles.h);
elseif strcmp(handles.type,'add')   % add generated mask to the preexisting one
    mask = ib_getDataset('mask', handles.h);
    filter_out(mask==1) = 1;
    ib_setDataset('mask', filter_out, handles.h);
    ib_setDataset('selection', selection, handles.h);
elseif strcmp(handles.type,'newSingle')     % make a new single slice
    ib_setSlice('mask', filter_out, handles.h);
    ib_setSlice('selection', selection, handles.h);
end
waitbar(1,wb);
set(handles.h.maskShowCheck,'value',1);
guidata(hObject, handles);
delete(wb);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end


% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to closeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = handles.h;

% Update handles structure
guidata(hObject, handles);

if ~isnan(handles.thrMatrix(1))
    assignin('base','thrMatrix',handles.thrMatrix);
end;

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.manGridBW);
delete(handles.manGridBW);
end


% --- Executes when user attempts to close manGridBW.
function manGridBW_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to manGridBW (see GCBO)
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

% --- Executes on button press in importGridBtn.
function importGridBtn_Callback(hObject, eventdata, handles)
%answer = inputdlg({'Threshold matrix variable:'},'Import from Matlab',1,{'thrMatrix'},'on');
answer = mib_inputdlg(NaN,'Threshold matrix variable:','Import from Matlab','thrMatrix');
if size(answer) == 0; return; end;
try
    handles.thrMatrix = evalin('base',answer{1});
catch exception
    errordlg(sprintf('The variable was not found in the Matlab base workspace:\n\n%s', exception.message),'Misssing variable!','modal');
    return;
end

updateTable(handles);
end

% --- Executes on button press in exportGrid.
function exportGrid_Callback(hObject, eventdata, handles)
%answer = inputdlg({'Variable for the threshold matrix:'},'Input variables for export', 1, {'thrMatrix'},'on');    
answer = mib_inputdlg(NaN,'Variable for the threshold matrix:','Input variables for export', 'thrMatrix');    
if size(answer) == 0; return; end; 
handles.thrMatrix = get(handles.thresholdsTable,'Data');
assignin('base',answer{1},handles.thrMatrix);
end

function updateTable(handles)
% update table with new coefficients
data = handles.thrMatrix;
set(handles.rowsNoEdit,'String',num2str(size(data,1)));
set(handles.columnsNoEdit,'String',num2str(size(data,2)));
set(handles.thresholdsTable,'Data',data);
set(handles.thresholdsTable,'ColumnEditable',logical(zeros(size(data,2),1)'+1));
set(handles.thresholdsTable,'ColumnWidth',{32});
guidata(handles.manGridBW, handles);
end


% --- Executes when entered data in editable cell(s) in thresholdsTable.
function thresholdsTable_CellEditCallback(hObject, eventdata, handles)
if isnan(eventdata.NewData(1))
    data = get(handles.thresholdsTable,'Data'); %#ok<NASGU>
    data(eventdata.Indices(1),eventdata.Indices(2)) = eventdata.PreviousData;
    set(handles.thresholdsTable,'Data',data);
    return;
end
gridSize = handles.h.corrGridrunSize;
img = ib_getSlice('image', handles.h);
img = img{1};
mask = ib_getSlice('mask', handles.h);
mask = mask{1};
width = size(img,2);
height = size(img,1);
[bl_w, bl_h] = generate_grid_block_size(width, height, gridSize);
y1 = (eventdata.Indices(1)-1)*bl_h+1;
y2 = min([eventdata.Indices(1)*bl_h size(img,1)]);
x1 = (eventdata.Indices(2)-1)*bl_w+1;
x2 = min([eventdata.Indices(2)*bl_w size(img,2)]);
img_block = img(y1:y2,x1:x2);
roi_mask_block = handles.roi_mask(y1:y2,x1:x2);
orient = 4;
[filter_out, ~] = get_black_white_filter(img_block,[0 0],0,roi_mask_block,...
        gridSize, 0, orient, 1, eventdata.NewData);    
mask(y1:y2,x1:x2) = filter_out;
ib_setSlice('mask', {mask}, handles.h);
guidata(hObject, handles);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end


% --- Executes on button press in loadBtn.
function loadBtn_Callback(hObject, eventdata, handles)
handles.mypath = get(handles.h.pathEdit,'String');
[filename, path] = uigetfile(...
    {'*.thrMatrix;',  'Matlab format (*.thrMatrix)'; ...
     '*.*',  'All Files (*.*)'}, ...
     'Open thrMatrix data...',handles.mypath);
if isequal(filename,0); return; end; % check for cancel
res = load([path filename],'-mat');
handles.thrMatrix = res.data;
updateTable(handles);
end

% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
[pathstr, name] = fileparts(handles.h.Img{handles.h.Id}.I.filename(1).name);
fn_out = fullfile(pathstr, [name '.thrMatrix']);
if isempty(strfind(fn_out,'/')) && isempty(strfind(fn_out,'\'))  
    fn_out = fullfile(handles.mypath, fn_out);
end
if isempty(fn_out)
    fn_out = handles.mypath;
end
[filename, path] = uiputfile(...
    {'*.thrMatrix;',  'Matlab format (*.thrMatrix)'; ...
     '*.*',  'All Files (*.*)'}, ...
     'Save thrMatrix data...', fn_out);
if isequal(filename,0); return; end; % check for cancel
data = get(handles.thresholdsTable,'Data'); %#ok<NASGU>
save([path filename], 'data');
disp('Saving thrMatrix: done!');
end


function rowsNoEdit_Callback(hObject, eventdata, handles)
rows = str2double(get(hObject, 'String'));
data = get(handles.thresholdsTable,'Data');
if rows <= size(handles.thrMatrix, 1)
    handles.thrMatrix = data(1:rows, :);
else
    handles.thrMatrix = zeros(rows, size(data,2))+255;
    handles.thrMatrix(1:size(data,1), 1:size(data,2)) = data;
end
updateTable(handles);
end


function columnsNoEdit_Callback(hObject, eventdata, handles)
columns = str2double(get(hObject, 'String'));
data = get(handles.thresholdsTable,'Data');
if columns <= size(handles.thrMatrix, 2)
    handles.thrMatrix = data(:,1:columns);
else
    handles.thrMatrix = zeros(size(data,1),columns)+255;
    handles.thrMatrix(1:size(data,1), 1:size(data,2)) = data;
end
updateTable(handles);
end
