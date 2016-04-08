function varargout = TripleAreaIntensity(varargin)
% TRIPLEAREAINTENSITY MATLAB code for TripleAreaIntensity.fig
%      TRIPLEAREAINTENSITY, by itself, creates a new TRIPLEAREAINTENSITY or raises the existing
%      singleton*.
%
%      H = TRIPLEAREAINTENSITY returns the handle to a new TRIPLEAREAINTENSITY or the handle to
%      the existing singleton*.
%
%      TRIPLEAREAINTENSITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRIPLEAREAINTENSITY.M with the given input arguments.
%
%      TRIPLEAREAINTENSITY('Property','Value',...) creates a new TRIPLEAREAINTENSITY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TripleAreaIntensity_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TripleAreaIntensity_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 30.04.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% Edit the above text to modify the response to help TripleAreaIntensity

% Last Modified by GUIDE v2.5 28-Apr-2014 10:14:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TripleAreaIntensity_OpeningFcn, ...
                   'gui_OutputFcn',  @TripleAreaIntensity_OutputFcn, ...
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

% --- Executes just before TripleAreaIntensity is made visible.
function TripleAreaIntensity_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TripleAreaIntensity (see VARARGIN)

% Written by Ilya Belevich, 16.03.2014
% ilya.belevich @ helsinki.fi

%! get the handle of the main program
h_im_browser = varargin{3};
%! get the handles structure of the main program
handles.h = guidata(h_im_browser);

strText = sprintf('Calculate image intensities of two materials of the opened model.\nSee details in the Help section.');
set(handles.helpText, 'String', strText);

% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.TripleAreaIntensity, handles.h.preferences.Font);
end
% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.TripleAreaIntensity);

% populate color channel combo box
set(handles.colorChannelCombo,'Value',1);
col_channels = cell([size(handles.h.Img{handles.h.Id}.I.img,3), 1]);
for col_ch=1:size(handles.h.Img{handles.h.Id}.I.img,3)
    col_channels(col_ch) = cellstr(['Channel ' num2str(col_ch)]);
end
set(handles.colorChannelCombo,'String',col_channels);
colorChannelSelection = max([1 get(handles.h.ColChannelCombo,'Value')-1]);     % get selected color channel
% when only one color channel is shown select it
if numel(handles.h.Img{handles.h.Id}.I.slices{3}) == 1    
    colorChannelSelection = handles.h.Img{handles.h.Id}.I.slices{3};
    set(handles.colorChannelCombo,'Value',colorChannelSelection);
else
    if size(handles.h.Img{handles.h.Id}.I.img,3) >= colorChannelSelection
        set(handles.colorChannelCombo,'Value',colorChannelSelection);
    end
end

set(handles.backgroundPopup, 'value', 1);
set(handles.material1Popup, 'value', 1);
set(handles.material2Popup, 'value', 2);
set(handles.thresholdingPopup, 'value', 1);
materialsList = handles.h.Img{handles.h.Id}.I.modelMaterialNames;
if isempty(materialsList)
    materialsList = {'Insufficient data, please check Help!'};
    set(handles.material2Popup, 'value', 1);
    set(handles.continueBtn, 'enable', 'off');
end
set(handles.backgroundPopup, 'string', materialsList);
set(handles.material1Popup, 'string', materialsList);
set(handles.material2Popup, 'string', materialsList);
set(handles.thresholdingPopup, 'string', materialsList);

[path,fn] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
set(handles.filenameEdit, 'string', fullfile(path, [fn '_analysis.xls']));
set(handles.filenameEdit, 'tooltip', fullfile(path, [fn '_analysis.xls']));
%set(handles.filenameEdit, 'string', fullfile(handles.h.mypath, 'results.xls'));

% Choose default command line output for TripleAreaIntensity
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TripleAreaIntensity wait for user response (see UIRESUME)
% uiwait(handles.TripleAreaIntensity);
end

% --- Outputs from this function are returned to the command line.
function varargout = TripleAreaIntensity_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to closeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.TripleAreaIntensity);
end

function filenameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to filenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenameEdit as text
%        str2double(get(hObject,'String')) returns contents of filenameEdit as a double
end

% --- Executes on button press in selectFilenameBtn.
function selectFilenameBtn_Callback(hObject, eventdata, handles)
formatText = {'*.xls', 'Microscoft Excel (*.xls)'};
fn_out = get(handles.filenameEdit, 'string');
[FileName,PathName,FilterIndex] = ...
    uiputfile(formatText, 'Select filename', fn_out);
if isequal(FileName,0) || isequal(PathName,0); return; end;

fn_out = fullfile(PathName, FileName);
set(handles.filenameEdit,'String', fn_out);
set(handles.filenameEdit,'tooltip', fn_out);
end


% --- Executes on button press in savetoExcel.
function savetoExcel_Callback(hObject, eventdata, handles)
val = get(handles.savetoExcel, 'value');
if val==1
    set(handles.filenameEdit, 'enable', 'on');
    set(handles.selectFilenameBtn, 'enable', 'on');
else
    set(handles.filenameEdit, 'enable', 'off');
    set(handles.selectFilenameBtn, 'enable', 'off');
end
end


% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
if isdeployed
     web(fullfile(fileparts(mfilename('fullpath')), 'html/TripleAreaIntensity_help.html'), '-helpbrowser');
else
    %path = fileparts(which('im_browser'));
    %web(fullfile(path, 'techdoc/html/ug_panel_bg_removal.html'), '-helpbrowser');
    web(fullfile(fileparts(mfilename('fullpath')), 'html/TripleAreaIntensity_help.html'), '-helpbrowser');
end

end

% --- Executes on button press in calculateRatioCheck.
function calculateRatioCheck_Callback(hObject, eventdata, handles)
% hObject    handle to calculateRatioCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of calculateRatioCheck
end

% --- Executes on button press in backgroundCheck.
function backgroundCheck_Callback(hObject, eventdata, handles)
val = get(handles.backgroundCheck, 'value');
if val == 1
    set(handles.backgroundPopup, 'enable','on');
    set(handles.subtractBackgroundCheck, 'enable','on');
    set(handles.additionalThresholdingCheck, 'enable','on');
else
    set(handles.backgroundPopup, 'enable','off');
    set(handles.subtractBackgroundCheck, 'enable','off');
    set(handles.additionalThresholdingCheck, 'enable','off');
    set(handles.additionalThresholdingCheck, 'value', 0);
end
additionalThresholdingCheck_Callback(handles.additionalThresholdingCheck, eventdata, handles);
end


% --- Executes on button press in additionalThresholdingCheck.
function additionalThresholdingCheck_Callback(hObject, eventdata, handles)
val = get(handles.additionalThresholdingCheck, 'value');
if val == 1
    set(handles.thresholdingPopup, 'enable','on');
    set(handles.thresholdEdit, 'enable','on');
else
    set(handles.thresholdingPopup, 'enable','off');
    set(handles.thresholdEdit, 'enable','off');
end
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
TripleAreaIntensity_main(handles);
end
