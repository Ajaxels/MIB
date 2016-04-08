function varargout = mib_keyShortcutsDlg(varargin)
% MIB_KEYSHORTCUTSDLG MATLAB code for mib_keyShortcutsDlg.fig
%      MIB_KEYSHORTCUTSDLG, by itself, creates a new MIB_KEYSHORTCUTSDLG or raises the existing
%      singleton*.
%
%      H = MIB_KEYSHORTCUTSDLG returns the handle to a new MIB_KEYSHORTCUTSDLG or the handle to
%      the existing singleton*.
%
%      MIB_KEYSHORTCUTSDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIB_KEYSHORTCUTSDLG.M with the given input arguments.
%
%      MIB_KEYSHORTCUTSDLG('Property','Value',...) creates a new MIB_KEYSHORTCUTSDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mib_keyShortcutsDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mib_keyShortcutsDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mib_keyShortcutsDlg

% Last Modified by GUIDE v2.5 03-Nov-2015 17:29:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mib_keyShortcutsDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @mib_keyShortcutsDlg_OutputFcn, ...
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

% --- Executes just before mib_keyShortcutsDlg is made visible.
function mib_keyShortcutsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_keyShortcutsDlg (see VARARGIN)

% Choose default command line output for mib_keyShortcutsDlg
handles.output = '';

handles.KeyShortcuts = varargin{1};
handles.duplicateEntries = [];  % array with duplicate entries

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_keyShortcutsDlg);
updateTable(handles);
fitTextBtn_Callback(handles.fitTextBtn, eventdata, handles);    % adjust columns

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mib_keyShortcutsDlg wait for user response (see UIRESUME)
uiwait(handles.mib_keyShortcutsDlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = mib_keyShortcutsDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles.output)
    varargout{1} = {};
else
    varargout{1} = handles.KeyShortcuts;
end

% The figure can be deleted now
delete(handles.mib_keyShortcutsDlg);
end

% --- Executes when user attempts to close mib_keyShortcutsDlg.
function mib_keyShortcutsDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_keyShortcutsDlg (see GCBO)
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

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
handles.output = {};
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_keyShortcutsDlg);
end

% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
if numel(handles.duplicateEntries) > 1
    warndlg('Please check for duplicates!');
    return;
end
    
data = get(handles.shortcutsTable, 'data');
handles.KeyShortcuts.Action = data(:, 2)';
handles.KeyShortcuts.Key = data(:, 3)';
handles.KeyShortcuts.shift = cell2mat(data(:, 4))';
handles.KeyShortcuts.control = cell2mat(data(:, 5))';
handles.KeyShortcuts.alt = cell2mat(data(:, 6))';

handles.output = handles.KeyShortcuts;
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_keyShortcutsDlg);
end

function updateTable(handles)
% update table with contents of handles.KeyShortcuts
% Column names and column format
ColumnName =    {'',    'Action name',  'Key',      'Shift',    'Control',  'Alt'};
ColumnFormat =  {'char','char',         'char',     'logical',  'logical',  'logical'};
set(handles.shortcutsTable, 'ColumnName', ColumnName);
set(handles.shortcutsTable, 'ColumnFormat', ColumnFormat);

data(:,2) = handles.KeyShortcuts.Action;
data(:,3) = handles.KeyShortcuts.Key;
data(:,4) = num2cell(logical(handles.KeyShortcuts.shift));
data(:,5) = num2cell(logical(handles.KeyShortcuts.control));
data(:,6) = num2cell(logical(handles.KeyShortcuts.alt));

colergen = @(color,text) ['<html><table border=0 width=20 bgcolor=''',color,'''><TR><TD>',text,'</TD></TR> </table></html>'];
data(1:numel(handles.KeyShortcuts.Action), 1) = cellstr(repmat(colergen('rgb(0, 255, 0)', '&nbsp;'), numel(handles.KeyShortcuts.Action)));  
data(handles.duplicateEntries, 1) = cellstr(repmat(colergen('rgb(255, 0, 0)', '&nbsp;'), numel(handles.duplicateEntries)));  

ColumnEditable = [false false true true true true];
set(handles.shortcutsTable, 'ColumnEditable',ColumnEditable);
set(handles.shortcutsTable, 'Data', data);
end


% --- Executes on button press in fitTextBtn.
function fitTextBtn_Callback(hObject, eventdata, handles)
units = get(handles.shortcutsTable, 'units');
set(handles.shortcutsTable, 'units','pixels');
length1 = max(cellfun(@numel, handles.KeyShortcuts.Action));
length2 = max(cellfun(@numel, handles.KeyShortcuts.Key));
length = {10, length1*5, length2*7, 'auto', 'auto', 'auto'};
set(handles.shortcutsTable, 'ColumnWidth', 'auto');     % for some resons have to make it auto first, otherwise the table is not rescaled
set(handles.shortcutsTable, 'ColumnWidth', length);
set(handles.shortcutsTable, 'units', units);
end


% --- Executes when entered data in editable cell(s) in shortcutsTable.
function shortcutsTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to shortcutsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

index = eventdata.Indices(1);
data = get(handles.shortcutsTable, 'data');

% make it impossible to change Shift action for some actions
if ismember(data(index, 2), handles.KeyShortcuts.Action(6:16))
    data(index, 4) = num2cell(false);
    set(handles.shortcutsTable, 'data', data);
end

colergen = @(color,text) ['<html><table border=0 width=10 bgcolor=''',color,'''><TR><TD>',text,'</TD></TR> </table></html>'];
if ~isempty(data{index, 3})
    % check for duplicates
    KeyShortcutsLocal.Key = data(:, 3)';
    KeyShortcutsLocal.shift = cell2mat(data(:, 4))';
    KeyShortcutsLocal.control = cell2mat(data(:, 5))';
    KeyShortcutsLocal.alt = cell2mat(data(:, 6))';
    
    shiftSw = data{index, 4};
    controlSw = data{index, 5};
    altSw = data{index, 6};
    
    ActionId = ismember(KeyShortcutsLocal.Key, data(index, 3)) & ismember(KeyShortcutsLocal.control, controlSw) & ...
        ismember(KeyShortcutsLocal.shift, shiftSw) & ismember(KeyShortcutsLocal.alt, altSw);
    ActionId = find(ActionId>0);    % action id is the index of the action, handles.preferences.KeyShortcuts.Action(ActionId)
    if numel(ActionId) > 1
        actionId = ActionId(ActionId~=index);
        button = questdlg(sprintf('!!! Warning !!!\n\nA duplicate entry was found in the list of shortcuts!\nThe keystroke "%s" is already assigned to action number "%d"\n"%s"\n\nContinue anyway?', data{index, 3}, actionId, data{actionId, 2}),'Duplicate found!','Continue','Cancel','Cancel');
        if strcmp(button, 'Cancel');
            data(index, eventdata.Indices(2)) = {eventdata.PreviousData};
        else
            handles.duplicateEntries = [handles.duplicateEntries ActionId];     % add index of a duplicate entry
            handles.duplicateEntries = unique(handles.duplicateEntries);     % add index of a duplicate entry
            
            data(ActionId, 1) = cellstr(repmat(colergen('rgb(255, 0, 0)','&nbsp;'), numel(ActionId)));  
        end;
    else
        handles.duplicateEntries(handles.duplicateEntries==ActionId) = [];  % remove possible diplicate
        if numel(handles.duplicateEntries) < 2; 
            handles.duplicateEntries =[]; 
            data(1:size(data,1), 1) = cellstr(repmat(colergen('rgb(0, 255, 0)', '&nbsp;'), size(data,1)));
        else
            data(index, 1) = cellstr(colergen('rgb(0, 255, 0)', '&nbsp;'));
        end
    end
else
    handles.duplicateEntries(handles.duplicateEntries==index) = [];  % remove possible diplicate
    if numel(handles.duplicateEntries) < 2; 
        handles.duplicateEntries =[]; 
        data(1:size(data,1), 1) = cellstr(repmat(colergen('rgb(0, 255, 0)', '&nbsp;'), size(data,1)));
    else
        data(index, 1) = cellstr(colergen('rgb(0, 255, 0)', '&nbsp;'));
    end
end
set(handles.shortcutsTable, 'data', data);

% Update handles structure
guidata(hObject, handles);
end


% --- Executes on key press with focus on mib_keyShortcutsDlg and none of its controls.
function mib_keyShortcutsDlg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to mib_keyShortcutsDlg (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

set(handles.pressedKeyText, 'string', eventdata.Key);
end

% --- Executes on key press with focus on shortcutsTable and none of its controls.
function shortcutsTable_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to shortcutsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

set(handles.pressedKeyText, 'string', eventdata.Key);

end


% --- Executes on button press in defaultBtn.
function defaultBtn_Callback(hObject, eventdata, handles)
button = questdlg(sprintf('You are going to restore default key shortcuts\nAre you sure?'),'Restore default shortcuts','Restore','Cancel','Cancel');
if strcmp(button, 'Cancel'); return; end;

maxShortCutIndex = 27;  % total number of shortcuts
handles.KeyShortcuts.shift(1:maxShortCutIndex) = 0;
handles.KeyShortcuts.control(1:maxShortCutIndex) = 0;
handles.KeyShortcuts.alt(1:maxShortCutIndex) = 0;

handles.KeyShortcuts.Key{1} = '1';
handles.KeyShortcuts.Action{1} = 'Switch dataset to XY orientation';
handles.KeyShortcuts.alt(1) = 1;

handles.KeyShortcuts.Key{2} = '2';
handles.KeyShortcuts.Action{2} = 'Switch dataset to ZX orientation';
handles.KeyShortcuts.alt(2) = 1;

handles.KeyShortcuts.Key{3} = '3';
handles.KeyShortcuts.Action{3} = 'Switch dataset to ZY orientation';
handles.KeyShortcuts.alt(3) = 1;

handles.KeyShortcuts.Key{4} = 'i';
handles.KeyShortcuts.Action{4} = 'Interpolate selection';

handles.KeyShortcuts.Key{5} = 'i';
handles.KeyShortcuts.Action{5} = 'Invert image';
handles.KeyShortcuts.control(5) = 1;

handles.KeyShortcuts.Key{6} = 'a';
handles.KeyShortcuts.Action{6} = 'Add to selection to material';

handles.KeyShortcuts.Key{7} = 's';
handles.KeyShortcuts.Action{7} = 'Subtract from material';

handles.KeyShortcuts.Key{8} = 'r';
handles.KeyShortcuts.Action{8} = 'Replace material with current selection';

handles.KeyShortcuts.Key{9} = 'c';
handles.KeyShortcuts.Action{9} = 'Clear selection';

handles.KeyShortcuts.Key{10} = 'f';
handles.KeyShortcuts.Action{10} = 'Fill the holes in the Selection layer';

handles.KeyShortcuts.Key{11} = 'z';
handles.KeyShortcuts.Action{11} = 'Erode the Selection layer';

handles.KeyShortcuts.Key{12} = 'x';
handles.KeyShortcuts.Action{12} = 'Dilate the Selection layer';

handles.KeyShortcuts.Key{13} = 'q';
handles.KeyShortcuts.Action{13} = 'Zoom out/Previous slice';

handles.KeyShortcuts.Key{14} = 'w';
handles.KeyShortcuts.Action{14} = 'Zoom in/Next slice';

handles.KeyShortcuts.Key{15} = 'downarrow';
handles.KeyShortcuts.Action{15} = 'Previous slice';

handles.KeyShortcuts.Key{16} = 'uparrow';
handles.KeyShortcuts.Action{16} = 'Next slice';

handles.KeyShortcuts.Key{17} = 'space';
handles.KeyShortcuts.Action{17} = 'Show/hide the Model layer';

handles.KeyShortcuts.Key{18} = 'space';
handles.KeyShortcuts.Action{18} = 'Show/hide the Mask layer';
handles.KeyShortcuts.control(18) = 1;

handles.KeyShortcuts.Key{19} = 'space';
handles.KeyShortcuts.Action{19} = 'Fix selection to material';
handles.KeyShortcuts.shift(19) = 1;

handles.KeyShortcuts.Key{20} = 's';
handles.KeyShortcuts.Action{20} = 'Save image as...';
handles.KeyShortcuts.control(20) = 1;

handles.KeyShortcuts.Key{21} = 'c';
handles.KeyShortcuts.Action{21} = 'Copy to buffer selection from the current slice';
handles.KeyShortcuts.control(21) = 1;

handles.KeyShortcuts.Key{22} = 'v';
handles.KeyShortcuts.Action{22} = 'Paste buffered selection to the current slice';
handles.KeyShortcuts.control(22) = 1;

handles.KeyShortcuts.Key{23} = 'e';
handles.KeyShortcuts.Action{23} = 'Toggle between the selected material and exterior';

handles.KeyShortcuts.Key{24} = 'd';
handles.KeyShortcuts.Action{24} = 'Loop through the list of favourite segmentation tools';

handles.KeyShortcuts.Key{25} = 'leftarrow';
handles.KeyShortcuts.Action{25} = 'Previous time point';

handles.KeyShortcuts.Key{26} = 'rightarrow';
handles.KeyShortcuts.Action{26} = 'Next time point';

handles.KeyShortcuts.Key{maxShortCutIndex} = 'z';
handles.KeyShortcuts.Action{maxShortCutIndex} = 'Undo/Redo last action';
handles.KeyShortcuts.control(maxShortCutIndex) = 1;

handles.duplicateEntries = [];  % array with duplicate entries

updateTable(handles);
fitTextBtn_Callback(handles.fitTextBtn, eventdata, handles);    % adjust columns

% Update handles structure
guidata(hObject, handles);
end