function varargout = mib_stereologyGui(varargin)
% MIB_STEREOLOGYGUI MATLAB code for mib_stereologygui.fig
%      MIB_STEREOLOGYGUI, by itself, creates a new MIB_STEREOLOGYGUI or raises the existing
%      singleton*.
%
%      H = MIB_STEREOLOGYGUI returns the handle to a new MIB_STEREOLOGYGUI or the handle to
%      the existing singleton*.
%
%      MIB_STEREOLOGYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIB_STEREOLOGYGUI.M with the given input arguments.
%
%      MIB_STEREOLOGYGUI('Property','Value',...) creates a new MIB_STEREOLOGYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mib_stereologyGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mib_stereologyGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 12.11.2015 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 27.02.2016, IB, updated for 4D

% Last Modified by GUIDE v2.5 12-Nov-2015 17:55:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mib_stereologyGui_OpeningFcn, ...
                   'gui_OutputFcn',  @mib_stereologyGui_OutputFcn, ...
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

% --- Executes just before mib_stereologygui is made visible.
function mib_stereologyGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_stereologygui (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser

% update font and size
if get(handles.infoText, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.infoText, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.mib_stereologyGui, handles.h.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.mib_stereologyGui);

updateWidgets(handles);     % update widgets of mib_stereologyGui

% Choose default command line output for ib_MorphOpsGui
handles.output = NaN;

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

% UIWAIT makes mib_stereologygui wait for user response (see UIRESUME)
% uiwait(handles.mib_stereologyGui);
end

% --- Outputs from this function are returned to the command line.
function varargout = mib_stereologyGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = NaN;
end

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
handles.output = NaN;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_stereologyGui);
delete(handles.mib_stereologyGui);
end

% --- Executes when user attempts to close mib_stereologyGui.
function mib_stereologyGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_stereologyGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.mib_stereologyGui);
delete(handles.mib_stereologyGui);
end

function updateWidgets(handles)
handles.h = guidata(handles.h.im_browser);  % update handles

% update pixel sizes
pixSize = handles.h.Img{handles.h.Id}.I.pixSize;
pixString = sprintf('%.3f x %.3f x %.3f\nUnits: %s', pixSize.x, pixSize.y, pixSize.z, pixSize.units);
set(handles.pixelSizeText, 'string', pixString);
end

% --- Executes on button press in generateGrid.
function generateGrid_Callback(hObject, eventdata, handles)
handles.h = guidata(handles.h.im_browser);  % update handles
if strcmp(handles.h.preferences.disableSelection, 'yes');
    errordlg(sprintf('!!! Error !!!\n\nSelection is disabled\nEnable it in the\nMenu->File->Preferences->Disable selection: no'),'Error');
    return;
end
options.blockModeSwitch = 0;    % turn off the blockmode switch to get dimensions of the whole dataset
[height, width, color, depth, time] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, 0, options);

if handles.h.Img{handles.h.Id}.I.maskExist == 1
    button = questdlg(sprintf('!!! Warning !!!\n\nThe existing mask layer will be replaced with the grid!\n\nIt can be undone using the Ctrl+Z shortcut'),'Generate grid','Continue','Cancel','Cancel');
    if strcmp(button, 'Cancel'); return; end;
end
if handles.h.Img{handles.h.Id}.I.time == 1
    ib_do_backup(handles.h, 'mask', 1);
end

dX = str2double(get(handles.stepXedit, 'string'));   % step for the grid in X
dY = str2double(get(handles.stepYedit, 'string'));   % step for the grid in Y
oX = str2double(get(handles.offsetXedit, 'string')); % offset for the grid in X
oY = str2double(get(handles.offsetYedit, 'string')); % offset for the grid in Y
pixSize = handles.h.Img{handles.h.Id}.I.pixSize;

if get(handles.imageunitsRadio, 'value')    % recalculate step and offset to the image units
    dX = round(dX/pixSize.x);
    dY = round(dY/pixSize.y);
    oX = round(oX/pixSize.x);
    oY = round(oY/pixSize.y);
end

wb = waitbar(0,sprintf('Generating the grid\nPlease wait...'), 'Name', 'Stereology grid');
for t=1:handles.h.Img{handles.h.Id}.I.time
    % allocate space for the mask
    mask = zeros([height, width, depth],'uint8');
    waitbar(0.1, wb);

    oX2 = ceil(dX/2);
    oY2 = ceil(dY/2);

    mask(:,1+oX+oX2:dX:end,:) = 1;
    waitbar(0.4, wb);
    mask(1+oY+oY2:dY:end,:,:) = 1;
    waitbar(0.8, wb);

    gridThickness = str2double(get(handles.gridThickness, 'string'));
    if gridThickness > 0
        se = zeros(gridThickness*2+1);
        se(:,round(gridThickness/2)) = 1;
        se(round(gridThickness/2),:) = 1;
    
        for slice=1:size(mask,3)
            mask(:,:,slice) = imdilate(mask(:,:,slice), se);
        end
    end

    % keep mask for the ROI area only
    if get(handles.h.roiShowCheck, 'value')
        roiMask = handles.h.Img{handles.h.Id}.I.hROI.returnMask(0);
        for slice=1:size(mask,3)
            mask(:,:,slice) = mask(:,:,slice) & roiMask;
        end
    end

    handles.h.Img{handles.h.Id}.I.setData3D('mask', mask, t, NaN, 0, options);
    waitbar(0.95, wb);
end
set(handles.h.maskShowCheck, 'value', 1);
waitbar(1, wb);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
delete(wb);
end

% --- Executes on button press in doStereologyBtn.
function doStereologyBtn_Callback(hObject, eventdata, handles)
handles.h = guidata(handles.h.im_browser);  % update handles
options.blockModeSwitch = 0;    % turn off the blockmode switch to get dimensions of the whole dataset
[height, width, color, depth, time] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, 0, options);

if handles.h.Img{handles.h.Id}.I.maskExist == 0
    errordlg(sprintf('!!! Error !!!\n\nThe mask layer with a grid is required to proceed further!\n\nUse the Generate grid button to make a new grid!'),'Missing the mask!');
    return;
end

if handles.h.Img{handles.h.Id}.I.modelExist == 1
    button = questdlg(sprintf('!!! Warning !!!\n\nThe existing model layer will be replaced with the results!\n\nIt can be undone using the Ctrl+Z shortcut'),'Do analysis','Continue','Cancel','Cancel');
    if strcmp(button, 'Cancel'); return; end;
else
    errordlg(sprintf('!!! Error !!!\n\nA model with labeled objects of interest has to be present to proceed further!\n\nMake a new model and segment structures of interest'),'Missing the model!');
    return;
end

if get(handles.matlabExportRadio, 'value') == 1     % export to Matlab
    title = 'Input variable to export';
    [~,def] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
    prompt = {'A variable for the measurements structure:'};
    answer = mib_inputdlg(NaN, prompt,title,[def '_stgy']); 
    if size(answer) == 0; return; end;
    fn_out = answer{1};
else        % export to Excel
    fn_out = handles.h.Img{handles.h.Id}.I.img_info('Filename');
    dotIndex = strfind(fn_out,'.');
    if ~isempty(dotIndex)
        fn_out = fn_out(1:dotIndex-1);
    end
    if isempty(strfind(fn_out,'/')) && isempty(strfind(fn_out,'\'))
        fn_out = fullfile(handles.mypath, fn_out);
    end
    if isempty(fn_out)
        fn_out = handles.mypath;
    end
    
    Filters = {'*.xls',   'Excel format (*.xls)'; };

    [filename, path, FilterIndex] = uiputfile(Filters, 'Save stereology...',fn_out); %...
    if isequal(filename,0); return; end; % check for cancel
    fn_out = fullfile(path, filename);
end

wb = waitbar(0,sprintf('Doing stereology\nPlease wait...'), 'Name', 'Stereology analysis');
if handles.h.Img{handles.h.Id}.I.time == 1
    ib_do_backup(handles.h, 'model', 1);
end

pointSize = str2double(get(handles.pointSizeEdit, 'string'));
matNames = handles.h.Img{handles.h.Id}.I.modelMaterialNames;    % get material names
nMat = numel(matNames); % number of materials in the model

if strcmp(matNames{end}, 'Unassigned')  % define material for unassigned points
    unassId = nMat;
    Occurrence = zeros([time, depth, nMat]);  % allocate space for results
else
    unassId = nMat + 1;
    matNames{unassId} = 'Unassigned';
    Occurrence = zeros([time, depth, nMat+1]);    % allocate space for results
end

for t=1:handles.h.Img{handles.h.Id}.I.time
    options.t = [t t];
    modelOut = zeros([height, width, depth], 'uint8');

    se = strel('disk', pointSize);
    for slice=1:depth
        currMask = handles.h.Img{handles.h.Id}.I.getData2D('mask', slice, NaN, NaN, NaN, options);
        currMask = bwmorph(currMask, 'thin', 'Inf');     % thin lines to make them 1px wide
        currMask = bwmorph(currMask, 'branchpoints', 1);        % find branch points, i.e. intersections

        currModel = handles.h.Img{handles.h.Id}.I.getData2D('model', slice, NaN, NaN, NaN, options);
    
        currModelOut = zeros(size(currModel), 'uint8');
        for mat = 1:nMat
            BW = zeros(size(currModel), 'uint8');
            BW(currModel==mat & currMask==1) = 1;
        
            STATS = regionprops(bwconncomp(BW, 8), 'Area', 'PixelIdxList');
            Occurrence(t, slice, mat) = Occurrence(t, slice, mat)+numel(STATS);
                
            currModelOut(BW==1) = mat;
        end
        % add unassigned material
        BW = zeros(size(currModel), 'uint8');
        BW(currModel==0 & currMask==1) = 1;
        STATS = regionprops(bwconncomp(BW, 8), 'Area', 'PixelIdxList');
        Occurrence(t, slice, unassId) = Occurrence(t, slice, unassId) + numel(STATS);
        currModelOut(BW==1) = unassId;
    
        if pointSize > 1
            currModelOut = imdilate(currModelOut, se);
        end
        modelOut(:,:,slice) = currModelOut;
        waitbar(slice/depth, wb);
    end

    % % find grid step
    STATS = regionprops(bwconncomp(currMask, 8), 'Area', 'Centroid');
    xy = cat(1, STATS.Centroid);

    dXp = diff(xy(:,1));     % get step in X
    dXp(dXp==0) = [];         % remove 0
    dXp = mode(dXp);          % find the most frequent step, when used with ROI the centers of the wide grids may be shifted
    dX = dXp*handles.h.Img{handles.h.Id}.I.pixSize.x;   % dX in units

    dYp = diff(xy(:,1));     % get step in Y
    dYp(dYp==0) = [];         % remove 0
    dYp = mode(dYp);          % find the most frequent step, when used with ROI the centers of the wide grids may be shifted
    dY = dYp*handles.h.Img{handles.h.Id}.I.pixSize.y;   % dY in units

    waitbar(0.95, wb);
    handles.h.Img{handles.h.Id}.I.setData3D('model', modelOut, t, NaN, NaN, options);
end
handles.h.Img{handles.h.Id}.I.modelMaterialNames = matNames;    % update material names

res.Occurrence = Occurrence;    % number of Occurrence for each material at each grid point
res.Materials = matNames;       % names for Materials

SurfaceFraction = zeros(size(Occurrence));
Surface_in_units = zeros(size(Occurrence));

for t=1:time
    for i=1:depth
        SurfaceFraction(t,i,:) = Occurrence(t,i,:)./sum(Occurrence(t,i,:));   % surface fraction for each material
        Surface_in_units(t,i,:) = Occurrence(t,i,:)*dX*dY;                  % surface estimation in units
    end
end
res.SurfaceFraction = SurfaceFraction;
res.Surface_in_units = Surface_in_units;
res.GridSize.pixelsX = dXp;
res.GridSize.pixelsY = dYp;
res.GridSize.unitsX = dX;
res.GridSize.unitsY = dY;
res.GridSize.unitsType = handles.h.Img{handles.h.Id}.I.pixSize.units;
res.Filename = handles.h.Img{handles.h.Id}.I.img_info('Filename');
res.ModelName = handles.h.Img{handles.h.Id}.I.model_fn;

% exporting
if get(handles.matlabExportRadio, 'value') == 1     % export to Matlab
    waitbar(0.98, wb, sprintf('Exporting to Matlab\nPlease wait...'));
    assignin('base', fn_out, res);    
    fprintf('MIB: export measurements ("%s") to Matlab -> done!\n', fn_out);
else    % export to Excel
    waitbar(0.98, wb, sprintf('Exporting to Excel\nPlease wait...'));
    
    warning off MATLAB:xlswrite:AddSheet;
    
    for t=1:time
        % Sheet 1
        clear s;
        s = {sprintf('Stereology analysis with Microscopy Image Browser')};
        s(2,1:2) = {'Filename:' sprintf('%s', res.Filename)};
        s(3,1:2) = {'Model:' sprintf('%s', res.ModelName)};
        s(1,13:15) = {'Grid size','dX', 'dY'};
        s(2,13:15) = {'in Pixels:' sprintf('%d', res.GridSize.pixelsX) sprintf('%d', res.GridSize.pixelsY)};
        s(4,1:2) = {'Time point:' sprintf('%d', t)};
        
        nMat = numel(res.Materials);
        s(6,1) = {'SliceId'}; s(6,2) = {'Occurrence'}; s(6,2+nMat+2) = {'SurfaceFraction'};  s(6,2+nMat*2+2*2) = {sprintf('Surface in %s^2', res.GridSize.unitsType)};
        s(7,2:nMat+1) = res.Materials(:);
        s(7,2+nMat+2:2+nMat*2+2-1) = res.Materials(:);
        s(7,2+nMat*2+2*2:2+nMat*3+2*2-1) = res.Materials(:);
        
        % add slice IDs
        if numel(handles.h.Img{handles.h.Id}.I.img_info('SliceName')) ~= depth
            list = 1:depth;
            s(8:8+depth-1,1) = cellstr(num2str(list'));
        else
            s(8:8+depth-1,1) = handles.h.Img{handles.h.Id}.I.img_info('SliceName');
        end
        % saving results
        s(8:8+depth-1,2:nMat+1) = num2cell(res.Occurrence(t,:,:));
        s(8:8+depth-1,2+nMat+2:2+nMat*2+2-1) = num2cell(res.SurfaceFraction(t,:,:));
        s(8:8+depth-1,2+nMat*2+2*2:2+nMat*3+2*2-1) = num2cell(res.Surface_in_units(t,:,:));
        
        s(depth+10, nMat*5) = {''};
        sheetId = sprintf('Sheet_%d',t);
        xlswrite2(fn_out, s, sheetId, 'A1');
        waitbar(t/time, wb);
    end
end

waitbar(1, wb);
handles.h = updateGuiWidgets(handles.h);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);

delete(wb);
end
