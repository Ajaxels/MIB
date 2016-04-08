function varargout = ib_checkUpdate(varargin)
% IB_CHECKUPDATE MATLAB code for ib_checkUpdate.fig
%      IB_CHECKUPDATE, by itself, creates a new IB_CHECKUPDATE or raises the existing
%      singleton*.
%
%      H = IB_CHECKUPDATE returns the handle to a new IB_CHECKUPDATE or the handle to
%      the existing singleton*.
%
%      IB_CHECKUPDATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IB_CHECKUPDATE.M with the given input arguments.
%
%      IB_CHECKUPDATE('Property','Value',...) creates a new IB_CHECKUPDATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ib_checkUpdate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ib_checkUpdate_OpeningFcn via varargin.
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
% 29.04.2015 - changed to a new update server


% Edit the above text to modify the response to help ib_checkUpdate

% Last Modified by GUIDE v2.5 29-Apr-2015 11:32:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ib_checkUpdate_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_checkUpdate_OutputFcn, ...
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

% --- Executes just before ib_checkUpdate is made visible.
function ib_checkUpdate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_checkUpdate (see VARARGIN)

% Choose default command line output for ib_checkUpdate
handles.output = 0;
handles.h = varargin{1}; 

% add icon
if isdeployed
    [IconData, IconCMap] = imread(fullfile(pwd, 'Resources','mib_update_wide.gif'));
else
    [IconData, IconCMap] = imread(fullfile(fileparts(which('im_browser')), 'Resources', 'mib_update_wide.gif'));
end
Img=image(IconData, 'Parent', handles.axes1);
IconCMap(IconData(1,1)+1,:) = get(handles.ib_checkUpdate, 'Color');   % replace background color
set(handles.ib_checkUpdate, 'Colormap', IconCMap);

set(handles.axes1, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );

% update font and size
if get(handles.informationText, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.informationText, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_checkUpdate, handles.h.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_checkUpdate);

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

if isdeployed
    if ismac()
        link = 'http://mib.helsinki.fi/web-update/im_browser_current_version_deployed_mac.txt';
        set(handles.updaterBtn, 'enable','off');
        set(handles.updaterBtn, 'tooltipstring', 'The automatic update is not yet available for Mac OS');
    else
        link = 'http://mib.helsinki.fi/web-update/im_browser_current_version_deployed.txt';
    end
    if handles.h.matlabVersion <= 7.14 % get version of matlab, because in R2012b the syntax of urlread has been changed
        urlText = urlread(link);
    else
        urlText = urlread(link,'Timeout',4);
    end
    handles.updateMode = 'Deployed version';
else
    if handles.h.matlabVersion <= 7.14 % get version of matlab, because in R2012b the syntax of urlread has been changed
        urlText = urlread('http://mib.helsinki.fi/web-update/im_browser_current_version.txt');
    else
        urlText = urlread('http://mib.helsinki.fi/web-update/im_browser_current_version.txt','Timeout',4);
    end
    handles.updateMode = 'Matlab functions';
end

spacesPos = strfind(urlText, '<html>');
if ~isempty(strfind(urlText, ' '))
    availableVersion = str2double(urlText(1:spacesPos(1)-1));
    releaseComments = urlText(spacesPos(1):end);
else
    availableVersion = str2double(urlText);
    releaseComments = '';
end

currentVersion = get(handles.h.im_browser,'Name');
index1 = strfind(currentVersion, 'ver.');
index2 = strfind(currentVersion, '/');
currentVersion = str2double(currentVersion(index1+4:index2-1));

% Make the GUI modal
set(handles.ib_checkUpdate,'WindowStyle','modal')
set(handles.ib_checkUpdate, 'visible', 'on');
drawnow;

jScrollPane = findjobj(handles.informationEdit);
jViewPort = jScrollPane.getViewport;
handles.jEditbox = jViewPort.getComponent(0);
handles.jEditbox.setContentType('text/html');
handles.jEditbox.setEditable(false);
%handles.jEditbox.setText('<html><div style="font-family: arial;"><b>My text</b></html>');

if availableVersion - currentVersion > 0
    set(handles.informationText, 'String', sprintf('New version (%f) of Microscopy Image Browser is available!',availableVersion));
    handles.jEditbox.setText(releaseComments);
else
    set(handles.informationText, 'String', 'You are running the latest version of Microscopy Image Browser!');
    handles.jEditbox.setText('<html><div style="font-family: arial;">Nothing to update...</div></html>');
    set(handles.updaterBtn, 'enable', 'off');
    set(handles.listofchangesBtn, 'enable', 'off');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ib_checkUpdate wait for user response (see UIRESUME)
uiwait(handles.ib_checkUpdate);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_checkUpdate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles.output)
    varargout{1} = 0;
else
    varargout{1} = handles.output;
end

% The figure can be deleted now
delete(handles.ib_checkUpdate);
end

% --- Executes when user attempts to close ib_checkUpdate.
function ib_checkUpdate_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    cancelBtn_Callback(hObject, eventdata, handles);
    % The GUI is still in UIWAIT, us UIRESUME
    %uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
end

% --- Executes on button press in listofchangesBtn.
function listofchangesBtn_Callback(hObject, eventdata, handles)
web('http://mib.helsinki.fi/downloads.html', '-browser');
end

% --- Executes on button press in updaterBtn.
function updaterBtn_Callback(hObject, eventdata, handles)
if ~isdeployed
    updateMIB(0, handles.updateMode);     % start update gui
    handles.output = 1;
else
    % updating the updater
    destinationDir = pwd;
    wb = waitbar(0,sprintf('Updating the updater!\nDestination: %s\n\nPlease wait...', destinationDir), 'Name', 'Updating updateMIB.exe');
    try
        unzip('http://mib.helsinki.fi/web-update/updateMIB_distrib.zip',destinationDir);
    catch
        err
    end
    waitbar(1, wb);
    delete(wb);
    msgbox(sprintf('To finish the update please close the Microscopy Image Browser and start updateMIB.exe!'),'Update status','help');
end
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_checkUpdate);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_checkUpdate);
end



function informationEdit_Callback(hObject, eventdata, handles)

end


% --- Executes on button press in mibWebsiteBtn.
function mibWebsiteBtn_Callback(hObject, eventdata, handles)
web('http://mib.helsinki.fi', '-browser');
end
