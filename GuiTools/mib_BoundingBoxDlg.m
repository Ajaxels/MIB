function varargout = mib_BoundingBoxDlg(varargin)
% function output = mib_BoundingBoxDlg(NaN, dlgText, dlgTitle, defAnswer)
% custom input dialog
%
%
% Parameters:
% NaN:  just use NaN here
% dlgText:  dialog test, a string
% dlgTitle: dialog title, a string
% defAnswer:    default answer, a string
%
% Return values:
% output: a cell with the entered value, or an empty cell, when cancelled

%| 
% @b Examples:
% @code answer = mib_BoundingBoxDlg(NaN,'Please enter a number in the edit box below','Test title','123');
%       if size(answer) == 0; return; end; @endcode

% Copyright (C) 04.03.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
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
                   'gui_OpeningFcn', @mib_BoundingBoxDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @mib_BoundingBoxDlg_OutputFcn, ...
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

% --- Executes just before mib_BoundingBoxDlg is made visible.
function mib_BoundingBoxDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_BoundingBoxDlg (see VARARGIN)

handles.h = varargin{2};
handles.bb = handles.h.Img{handles.h.Id}.I.getBoundingBox();

handles.pixSize.x = handles.h.Img{handles.h.Id}.I.pixSize.x;
handles.pixSize.y = handles.h.Img{handles.h.Id}.I.pixSize.y;
handles.pixSize.z = handles.h.Img{handles.h.Id}.I.pixSize.z;
handles.oldBB = handles.h.Img{handles.h.Id}.I.getBoundingBox();

set(handles.textString, 'string', sprintf('xmin-xmax: %g - %g\nymin-ymax: %g - %g\nzmin-zmax: %g - %g\n',...
    handles.bb(1),handles.bb(2),handles.bb(3),handles.bb(4),handles.bb(5),handles.bb(6)));
set(handles.pixSizeText, 'string', sprintf('X: %g\nY: %g\nZ: %g\n',...
    handles.pixSize.x, handles.pixSize.y,handles.pixSize.z));

set(handles.textInfo,'String', sprintf('To shift the bounding box it is enough to provide one set of numbers: minimal or central.\nUpdate of both minimal and maximal values results in change of pixel size!'));

set(handles.xMinEdit, 'string', num2str(handles.bb(1)));
set(handles.yMinEdit, 'string', num2str(handles.bb(3)));
set(handles.zMinEdit, 'string', num2str(handles.bb(5)));

% update font and size
if get(handles.textInfo, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.textInfo, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.mib_BoundingBoxDlg, handles.h.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_BoundingBoxDlg);

% Choose default command line output for mib_BoundingBoxDlg
handles.output = {};

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

pos = get(handles.mib_BoundingBoxDlg, 'position');
handles.dialogHeight = pos(4);

% add icon
[IconData, IconCMap] = imread(fullfile(handles.h.pathMIB, 'Resources','mib_quest.gif'));
Img=image(IconData, 'Parent', handles.axes1);
IconCMap(IconData(1,1)+1,:) = get(handles.mib_BoundingBoxDlg, 'Color');   % replace background color
set(handles.mib_BoundingBoxDlg, 'Colormap', IconCMap);

set(handles.axes1, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );

% update WindowKeyPressFcn
set(handles.mib_BoundingBoxDlg, 'WindowKeyPressFcn', {@mib_BoundingBoxDlg_KeyPressFcn, handles});

% Make the GUI modal
% set(handles.mib_BoundingBoxDlg,'WindowStyle','modal')

% Update handles structure
guidata(hObject, handles);

set(handles.mib_BoundingBoxDlg,'Visible','on');
drawnow;

% UIWAIT makes mib_BoundingBoxDlg wait for user response (see UIRESUME)
uiwait(handles.mib_BoundingBoxDlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = mib_BoundingBoxDlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = guidata(handles.mib_BoundingBoxDlg);

% Get default command line output from handles structure
if isempty(handles.output)
    varargout{1} = {};
else
    varargout{1} = handles.output;
end
%varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.mib_BoundingBoxDlg);

end

% --- Executes when user attempts to close mib_BoundingBoxDlg.
function mib_BoundingBoxDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_BoundingBoxDlg (see GCBO)
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
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = {};

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_BoundingBoxDlg);
end

% --- Executes on key press over mib_BoundingBoxDlg with no controls selected.
function mib_BoundingBoxDlg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to mib_BoundingBoxDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%if nargin < 3;    handles = guidata(hObject); end;
handles = guidata(hObject);

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    cancelBtn_Callback(hObject, eventdata, handles);
end    
if isequal(get(hObject,'CurrentKey'),'return')
    okBtn_Callback(hObject, eventdata, handles);
end    
end

% --- Executes on button press in importBtn.
function importBtn_Callback(hObject, eventdata, handles)
str = clipboard('paste');
lineFeeds = strfind(str, sprintf('\n'));
equalSigns = strfind(str, sprintf('='));

switch handles.h.Img{handles.h.Id}.I.pixSize.units
    case 'm'
        coef = 1e6;
    case 'cm'
        coef = 1e4;
    case 'mm'
        coef = 1e3;
    case 'um'
        coef = 1;
    case 'nm'
        coef = 1e-3;
end

% read pixel size X
pos = strfind(str, sprintf('ScaleX'));
if ~isempty(pos); 
    ScaleX = str2double(str(equalSigns(find(equalSigns>pos, 1))+1:lineFeeds(find(lineFeeds>pos, 1))));
    if isnumeric(ScaleX)
        handles.pixSize.x = ScaleX;
        dx = (max([handles.h.Img{handles.h.Id}.I.width 2])-1)*handles.pixSize.x*coef;     % tweek (using the max function) for Amira single layer images max([w 2])
        handles.bb(2) = handles.bb(1) + dx;
    end
end
% read pixel size Y
pos = strfind(str, sprintf('ScaleY'));
if ~isempty(pos); 
    ScaleY = str2double(str(equalSigns(find(equalSigns>pos, 1))+1:lineFeeds(find(lineFeeds>pos, 1))));
    if isnumeric(ScaleY)
        handles.pixSize.y = ScaleY;
        dy = (max([handles.h.Img{handles.h.Id}.I.height 2])-1)*handles.pixSize.y*coef;     % tweek for Amira single layer images max([w 2])
        handles.bb(4) = handles.bb(3) + dy;
    end
end
% read pixel size Z
pos = strfind(str, sprintf('ScaleZ'));
if ~isempty(pos); 
    ScaleZ = str2double(str(equalSigns(find(equalSigns>pos, 1))+1:lineFeeds(find(lineFeeds>pos, 1))));
    if isnumeric(ScaleZ)
        if ScaleZ == 0
            handles.pixSize.z = handles.pixSize.x;
        else
            handles.pixSize.z = ScaleZ;
        end
        dz = (max([handles.h.Img{handles.h.Id}.I.no_stacks 2])-1)*handles.pixSize.z*coef;     % tweek for Amira single layer images max([w 2])
        handles.bb(6) = handles.bb(5) + dz;
    end
end

% read center X
pos = strfind(str, sprintf('xPos'));
if ~isempty(pos); 
    centerX = str2double(str(equalSigns(find(equalSigns>pos, 1))+1:lineFeeds(find(lineFeeds>pos, 1))));
    if isnumeric(centerX)
        set(handles.xCenterEdit, 'string', num2str(centerX));
    end
end

% read center Y
pos = strfind(str, sprintf('yPos'));
if ~isempty(pos); 
    centerY = str2double(str(equalSigns(find(equalSigns>pos, 1))+1:lineFeeds(find(lineFeeds>pos, 1))));
    if isnumeric(centerY)
        set(handles.yCenterEdit, 'string', num2str(centerY));
    end
end

% read Z
pos = strfind(str, sprintf('Z Position'));
if ~isempty(pos); 
    posZ = str2double(str(equalSigns(find(equalSigns>pos, 1))+1:lineFeeds(find(lineFeeds>pos, 1))));
    if isnumeric(posZ)
        set(handles.zMinEdit, 'string', num2str(posZ));
    end
end

% read Rotation
pos = strfind(str, sprintf('Rotation'));
if ~isempty(pos); 
    rotationVal = str2double(str(equalSigns(find(equalSigns>pos, 1))+1:lineFeeds(find(lineFeeds>pos, 1))));
    if isnumeric(rotationVal)
        set(handles.rotationEdit, 'string', num2str(45-rotationVal));
    end
end

set(handles.textString, 'string', sprintf('xmin-xmax: %g - %g\nymin-ymax: %g - %g\nzmin-zmax: %g - %g\n',...
    handles.bb(1),handles.bb(2),handles.bb(3),handles.bb(4),handles.bb(5),handles.bb(6)));

set(handles.pixSizeText, 'string', sprintf('X: %g\nY: %g\nZ: %g\n',...
    handles.pixSize.x, handles.pixSize.y,handles.pixSize.z));

guidata(handles.mib_BoundingBoxDlg, handles);
end


% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

drawnow;     % needed to fix callback after the key press

%handles = guidata(handles.mib_BoundingBoxDlg);

minX = str2double(get(handles.xMinEdit,'string'));
minY = str2double(get(handles.yMinEdit,'string'));
minZ = str2double(get(handles.zMinEdit,'string'));
meanX = str2double(get(handles.xCenterEdit,'string'));
meanY = str2double(get(handles.yCenterEdit,'string'));
maxX = str2double(get(handles.xMaxEdit,'string'));
maxY = str2double(get(handles.yMaxEdit,'string'));
maxZ = str2double(get(handles.zMaxEdit,'string'));
rotXY = str2double(get(handles.rotationEdit,'string'));

if isempty(rotXY) || isnan(rotXY); rotXY = 0; end;

if isnan(meanX)     % use the min point
    %minX = max([abs(minX) 0]);
    xyzShift(1) = minX-handles.bb(1);
else                % use the center point
    halfWidth = abs((handles.bb(2)-handles.bb(1))/2);
    %halfHeight = abs((handles.bb(4)-handles.bb(3))/2);
    if rotXY ~= 0
        tempX = sqrt(meanX^2+meanY^2)*cosd(atan2d(meanY, meanX)-rotXY);
        xyzShift(1) = tempX-halfWidth-handles.bb(1);
    else
        xyzShift(1) = meanX-halfWidth-handles.bb(1);
    end
end

if isnan(meanY)     % use the min point
    %minY = max([abs(minY) 0]);
    xyzShift(2) = minY-handles.bb(3);
else                % use the center point
    halfHeight = abs((handles.bb(4)-handles.bb(3))/2);
    %halfWidth = abs((handles.bb(2)-handles.bb(1))/2);
    if rotXY ~= 0
        tempY = sqrt(meanX^2+meanY^2)*sind(atan2d(meanY, meanX)-rotXY);
        xyzShift(2) = tempY-halfHeight-handles.bb(3);
    else
        xyzShift(2) = meanY-halfHeight-handles.bb(3);
    end
end

%minZ = max([abs(minZ) 0]);
xyzShift(3) = minZ-handles.bb(5);

handles.h.Img{handles.h.Id}.I.pixSize.x = handles.pixSize.x;
handles.h.Img{handles.h.Id}.I.pixSize.y = handles.pixSize.y;
handles.h.Img{handles.h.Id}.I.pixSize.z = handles.pixSize.z;

recalcuteCheck = 0;
if ~isnan(maxX)  % recalculate pixSize.x
    handles.h.Img{handles.h.Id}.I.pixSize.x = (maxX-minX)/(max([handles.h.Img{handles.h.Id}.I.width 2])-1);
    recalcuteCheck = 1;
end
if ~isnan(maxY)  % recalculate pixSize.y
    handles.h.Img{handles.h.Id}.I.pixSize.y = (maxY-minY)/(max([handles.h.Img{handles.h.Id}.I.height 2])-1);
    recalcuteCheck = 1;
end
if ~isnan(maxZ)  % recalculate pixSize.z
    handles.h.Img{handles.h.Id}.I.pixSize.z = (maxZ-minZ)/(max([handles.h.Img{handles.h.Id}.I.no_stacks 2])-1);
    recalcuteCheck = 1;
end
%if recalcuteCheck == 1
    handles.h.Img{handles.h.Id}.I.pixSize.units = 'um';
    resolution = ib_calculateResolution(handles.h.Img{handles.h.Id}.I.pixSize);
    handles.h.Img{handles.h.Id}.I.img_info('XResolution') = resolution(1);
    handles.h.Img{handles.h.Id}.I.img_info('YResolution') = resolution(2);
    handles.h.Img{handles.h.Id}.I.img_info('ResolutionUnit') = 'Inch';
    handles.h.Img{handles.h.Id}.I.updateBoundingBox();
%end
handles.h.Img{handles.h.Id}.I.updateBoundingBox(NaN, xyzShift);

handles.output = handles.h;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_BoundingBoxDlg);
end
