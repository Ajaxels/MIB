function varargout = ib_fijiSelectDataset(varargin)
% function varargout = ib_fijiSelectDataset(varargin)
% ib_fijiSelectDataset function is a dialog for selection of datasets from Fiji
%
% ib_fijiSelectDataset contains MATLAB code for ib_fijiSelectDataset

% Last Modified by GUIDE v2.5 17-May-2013 16:18:19

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
                   'gui_OpeningFcn', @ib_fijiSelectDataset_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_fijiSelectDataset_OutputFcn, ...
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

% --- Executes just before ib_fijiSelectDataset is made visible.
function ib_fijiSelectDataset_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_fijiSelectDataset (see VARARGIN)

% get font settings for MIB
Font = varargin{1};

% Choose default command line output for ib_cropGui
handles.output = NaN;

% check for MIJ
if exist('MIJ','class') ~= 8
    msgbox(sprintf('Miji was not started!\n\nPress the Start Fiji button in the Fiji connect panel'),...
        'Missing Miji!','error');
    return;
end

% get list of available datasets:
try
    list = MIJ.getListImages;
catch err
    errordlg(sprintf('Error!!!\n\nNothing is available for the import\nPlease open a dataset in Fiji and try again!'));
    cancelBtn_Callback(hObject, eventdata, handles);
    return;
end
  
for i=1:numel(list)
    list2(i) = cellstr(char(list(i)));
end

% update font and size
if get(handles.text1, 'fontsize') ~= Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), Font.FontName)
    ib_updateFontSize(handles.ib_fijiSelectDataset, Font);
end

% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.ib_fijiSelectDataset);

set(handles.fijidatasetsPopup, 'string', list2);

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

% Make the GUI modal
set(handles.ib_fijiSelectDataset,'WindowStyle','modal');

% UIWAIT makes ib_cropGui wait for user response (see UIRESUME)
uiwait(handles.ib_fijiSelectDataset);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_fijiSelectDataset_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.ib_fijiSelectDataset);
else
    varargout{1} = NaN;
end
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
val = get(handles.fijidatasetsPopup, 'value');
lst = get(handles.fijidatasetsPopup, 'string');

handles.output = lst{val};

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_fijiSelectDataset);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)

handles.output = NaN;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_fijiSelectDataset);
end
