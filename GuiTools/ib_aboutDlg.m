function varargout = ib_aboutDlg(varargin)
% IB_ABOUTDLG MATLAB code for ib_aboutDlg.fig
%      IB_ABOUTDLG, by itself, creates a new IB_ABOUTDLG or raises the existing
%      singleton*.
%
%      H = IB_ABOUTDLG returns the handle to a new IB_ABOUTDLG or the handle to
%      the existing singleton*.
%
%      IB_ABOUTDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IB_ABOUTDLG.M with the given input arguments.
%
%      IB_ABOUTDLG('Property','Value',...) creates a new IB_ABOUTDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ib_aboutDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ib_aboutDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% Edit the above text to modify the response to help ib_aboutDlg

% Last Modified by GUIDE v2.5 06-Mar-2015 14:09:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ib_aboutDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_aboutDlg_OutputFcn, ...
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

% --- Executes just before ib_aboutDlg is made visible.
function ib_aboutDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_aboutDlg (see VARARGIN)

% Choose default command line output for ib_aboutDlg
handles.output = hObject;
handles.h = varargin{1};

if isdeployed
    img = imread(fullfile(handles.h.pathMIB, 'Resources', 'mib_about.jpg'));  % load splash screen
else
    img = imread(fullfile(handles.h.pathMIB, 'Resources', 'mib_about.jpg'));  % load splash screen
end

addTextOptions.color = [1 1 0];
addTextOptions.fontSize = 2;
addTextOptions.markerText = 'text';
dateTag = get(handles.h.im_browser,'Name');
dateTag = dateTag(26:end);  % trim to remove 'Microscopy Image Browser ' text
img = ib_addText2Img(img, dateTag, [1,402], handles.h.dejavufont, addTextOptions);

imh = image(img, 'parent', handles.axes1);
set(handles.axes1, ...
    'xtick', [], ...
    'ytick', [], ...
    'box', 'off', ...
    'visible','off');

greet_txt1 = [
    {get(handles.h.im_browser,'Name');}
    ];

greet_txt2 = [
    {'a handy tool for image management!'}
    {'Matlab for dummies series'}
    {'http://mib.helsinki.fi'}
    {''}
    {'Core developer:'}
    {'     Ilya Belevich'}
    {'     ilya.belevich@helsinki.fi'}
    {''}
    {'Developers:'}
    {'     Merja Joensuu'}
    {'     Darshan Kumar'}
    {'     Helena Vihinen'}
    {'     Eija Jokitalo'}
    {''}
    {'Electron Microscopy Unit'}
    {'Institute of Biotechnology'}
    {'University of Helsinki'}
    {'Finland'}
    ];
set(handles.titleText, 'String', greet_txt1);
set(handles.descriptionText, 'String', greet_txt2);

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_aboutDlg);


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

% UIWAIT makes ib_aboutDlg wait for user response (see UIRESUME)
% uiwait(handles.ib_aboutDlg);

end

% --- Outputs from this function are returned to the command line.
function varargout = ib_aboutDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
delete(handles.ib_aboutDlg);
end


% --- Executes on button press in homepageBtn.
function homepageBtn_Callback(hObject, eventdata, handles)
web('http://mib.helsinki.fi', '-browser');
end
