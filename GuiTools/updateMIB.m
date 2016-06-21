function varargout = updateMIB(varargin)
% UPDATEMIB MATLAB code for updateMIB.fig
%      UPDATEMIB, by itself, creates a new UPDATEMIB or raises the existing
%      singleton*.
%
%      H = UPDATEMIB returns the handle to a new UPDATEMIB or the handle to
%      the existing singleton*.
%
%      UPDATEMIB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UPDATEMIB.M with the given input arguments.
%
%      UPDATEMIB('Property','Value',...) creates a new UPDATEMIB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before updateMIB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to updateMIB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 30.01.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% Edit the above text to modify the response to help updateMIB

% Last Modified by GUIDE v2.5 30-Jan-2014 09:12:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @updateMIB_OpeningFcn, ...
                   'gui_OutputFcn',  @updateMIB_OutputFcn, ...
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

% --- Executes just before updateMIB is made visible.
function updateMIB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to updateMIB (see VARARGIN)

% Choose default command line output for updateMIB
handles.output = NaN;

% get installation directory
if ~isdeployed;
    % ------ COMMENT THE FOLLOWING CODE WHEN COMPILING UPDATEMIB
    mode = varargin{2};     % get mode of the update: Matlab functions or deployed
    if strcmp(mode,'Matlab functions')
        set(handles.releaseTypePopup, 'value', 1);
    else
        set(handles.releaseTypePopup, 'value', 2);
    end
    
    func_name='im_browser.m';
    destinationDir=which(func_name);
    destinationDir=fileparts(destinationDir);
    % ------ COMMENT TILL HERE, SEE BELOW FOR ONE OTHER PLACE TO COMMENT
else
    set(handles.releaseTypePopup, 'value', 2);
    if ismac()
        %[~, user_name] = system('whoami');
        %destinationDir = fullfile('./Users', user_name(1:end-1), 'Documents/MIB');
        [status, result] = system('path');
        destinationDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    else
        %destinationDir = pwd;
        [status, result] = system('path');
        destinationDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    end
end
set(handles.destinationEdit, 'String', destinationDir);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes updateMIB wait for user response (see UIRESUME)
% uiwait(handles.updateMIB);
end

% --- Outputs from this function are returned to the command line.
function varargout = updateMIB_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.output;
end


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
delete(handles.updateMIB);
end

% --- Executes on button press in updateBtn.
function updateBtn_Callback(hObject, eventdata, handles)
destination = get(handles.destinationEdit, 'string');
wb = waitbar(0,sprintf('Updating Microscopy Image Browser...\nIt may take up to few minutes \ndepending on network connection.\n\nPlease wait...'), 'Name', 'Updating...');

% store java_path.txt
javaPathFile = fullfile(destination, 'mib_java_path.txt');
JavaPathText = NaN;
try
    fileID = fopen(javaPathFile, 'r');
    if fileID ~= -1
        tline = fgetl(fileID);
        JavaPathText = tline;
        while ischar(tline)
            tline = fgetl(fileID);
            JavaPathText = sprintf('%s\n%s', JavaPathText, tline);
        end
        fclose(fileID);
    end
catch err
    err
end
waitbar(0.05, wb);
if get(handles.releaseTypePopup, 'value') == 1  % matlab functions
    unzip('http://mib.helsinki.fi/web-update/im_browser.zip',destination);
else
    %unzip('http://mib.helsinki.fi/web-update/im_browser_distrib.zip',destination);
    web('http://mib.helsinki.fi/web-update/MIB_distrib.exe', '-browser');
end
waitbar(0.95, wb);

% save java_path.txt
if ~isnan(JavaPathText(1))
    fileID = fopen(javaPathFile, 'w');
    fwrite(fileID, JavaPathText);
    fclose(fileID);
end
waitbar(1, wb);
delete(wb);
if ~isdeployed
    % ------ COMMENT THE FOLLOWING CODE WHEN COMPILING UPDATEMIB
    rehash;     % update list of known functions
    im_browser;
    % ------ COMMENT TILL HERE
else
    msgbox(sprintf('Microscopy Image Browser has been updated!\n\nPlease restart the program.'),'Update status','help');
end
delete(handles.updateMIB);
end


% --- Executes on button press in listChangesBtn.
function listChangesBtn_Callback(hObject, eventdata, handles)
    web('http://mib.helsinki.fi/downloads.html', '-browser');
end


% --- Executes on button press in selectFolderBtn.
function selectFolderBtn_Callback(hObject, eventdata, handles)
destination = get(handles.destinationEdit, 'string');
dirname = uigetdir(destination,'Select destination folder');

if ischar(dirname)
    set(handles.destinationEdit, 'string', dirname);    
end

end
