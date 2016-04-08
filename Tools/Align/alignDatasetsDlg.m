function varargout = alignDatasetsDlg(varargin)
% ALIGNDATASETSDLG M-file for aligndatasetsdlg.fig
%      ALIGNDATASETSDLG by itself, creates a new ALIGNDATASETSDLG or raises the
%      existing singleton*.
%
%      H = ALIGNDATASETSDLG returns the handle to a new ALIGNDATASETSDLG or the handle to
%      the existing singleton*.
%
%      ALIGNDATASETSDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGNDATASETSDLG.M with the given input arguments.
%
%      ALIGNDATASETSDLG('Property','Value',...) creates a new ALIGNDATASETSDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before alignDatasetsDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to alignDatasetsDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 25.02.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% Edit the above text to modify the response to help aligndatasetsdlg

% Last Modified by GUIDE v2.5 02-Sep-2015 11:59:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @alignDatasetsDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @alignDatasetsDlg_OutputFcn, ...
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

% --- Executes just before aligndatasetsdlg is made visible.
function alignDatasetsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aligndatasetsdlg (see VARARGIN)

% Choose default command line output for aligndatasetsdlg
handles.output = 'Continue';

% set size of the window, because in Guide it is bigger
set(handles.alignDatasetsDlg, 'position', [492 65 358 414]);

handles.hMain = varargin{1};
options = varargin{2};
%set(handles.weightCentCheck,'Value',options.weightCent);

height = size(handles.hMain.Img{handles.hMain.Id}.I.img,1);
width = size(handles.hMain.Img{handles.hMain.Id}.I.img,2);
handles.varname = 'I';  % variable for import
fn = handles.hMain.Img{handles.hMain.Id}.I.img_info('Filename');
[pathstr, name, ext] = fileparts(fn);
handles.pathstr = pathstr;

handles.img_info = containers.Map;   % img_info containers.Map from the getImageMetadata
handles.files = struct();      % files structure from the getImageMetadata
handles.pixSize = struct();    % pixSize structure from the getImageMetadata

set(handles.existingFnText1,'String', pathstr);
set(handles.existingFnText1,'Tooltip',handles.hMain.Img{handles.hMain.Id}.I.img_info('Filename'));
set(handles.existingFnText2,'String',[name '.' ext]);
set(handles.existingFnText2,'String',[name '.' ext]);
set(handles.existingFnText2,'Tooltip',handles.hMain.Img{handles.hMain.Id}.I.img_info('Filename'));
str2 = sprintf('%d x %d x %d', width, height, size(handles.hMain.Img{handles.hMain.Id}.I.img,4));
set(handles.existingDimText,'String',str2);
set(handles.existingPixText2,'String',sprintf('Pixel size, %s:', handles.hMain.Img{handles.hMain.Id}.I.pixSize.units));
str2 = sprintf('%f x %f x %f', handles.hMain.Img{handles.hMain.Id}.I.pixSize.x, handles.hMain.Img{handles.hMain.Id}.I.pixSize.y, handles.hMain.Img{handles.hMain.Id}.I.pixSize.z);
set(handles.existingPixText,'String',str2);

set(handles.pathEdit, 'String', pathstr);
set(handles.saveShiftsXYpath, 'String', fullfile(pathstr, [name '_align.coefXY']));
set(handles.loadShiftsXYpath, 'String', fullfile(pathstr, [name '_align.coefXY']));
%handles.pathstr = pwd;

centerX = floor(width/2);
centerY = floor(height/2);
%templateWidth = round(min([height/7 width/7]));
templateWidth = floor(min([height/2 width/2]));
set(handles.searchX, 'String', num2str(centerX));
set(handles.searchY, 'String', num2str(centerY));
set(handles.searchWidth, 'String', num2str(templateWidth));

% setting panels
panelPosition = get(handles.saveShiftsPanel,'Position');
panelParent = get(handles.saveShiftsPanel,'Parent');
set(handles.secondDatasetDetailsPanel,'Parent',panelParent);
set(handles.secondDatasetDetailsPanel,'position',panelPosition);

panelPosition = get(handles.secondDatasetPanel,'Position');
panelParent = get(handles.secondDatasetPanel,'Parent');
set(handles.currStackOptionsPanel,'Parent',panelParent);
set(handles.currStackOptionsPanel,'position',panelPosition);
set(handles.currStackOptionsPanel,'visible','on');

% adding description of the landmark mode
textStr = sprintf('Use the brush tool to mark two corresponding spots on\nconsecutive slices.\nThe dataset will be shifted to align the marked spots.');
set(handles.landmarkHelpText,'string', textStr);

% update font and size
if get(handles.existingFnText1, 'fontsize') ~= handles.hMain.preferences.Font.FontSize ...
        || ~strcmp(get(handles.existingFnText1, 'fontname'), handles.hMain.preferences.Font.FontName)
    ib_updateFontSize(handles.alignDatasetsDlg, handles.hMain.preferences.Font);
end

% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.alignDatasetsDlg);

% Update handles structure
guidata(hObject, handles);

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

% Make the GUI modal
set(handles.alignDatasetsDlg,'WindowStyle','modal')

% UIWAIT makes aligndatasetsdlg wait for user response (see UIRESUME)
uiwait(handles.alignDatasetsDlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = alignDatasetsDlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
options.out = '';

fields = fieldnames(options);
sum1 = 0;
for i=1:numel(fields)
    %sum1 = sum1 + getfield(options,fields{i});
    sum1 = sum1 + options.(fields{i});
end
if sum1 == 0; handles.output = 'Cancel'; end;
if sum1 == 1 & stat.showRes == 1;  handles.output = 'Cancel'; end; %#ok<AND2>


varargout{1} = handles.output;
varargout{2} = options;
% The figure can be deleted now
delete(handles.alignDatasetsDlg);
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
handles.output = get(hObject,'String');
pathIn = get(handles.pathEdit,'String');
colorCh = get(handles.hMain.ColChannelCombo,'Value') - 1;

if get(handles.bgWhiteRadio,'Value')
    parameters.backgroundColor = 'white';
elseif get(handles.bgBlackRadio,'Value')
    parameters.backgroundColor = 'black';
elseif get(handles.bgMeanRadio,'Value')  
    parameters.backgroundColor = 'mean';
else
    parameters.backgroundColor = str2double(get(handles.bgCustomEdit,'String'));
    handles.files(1).backgroundColor = parameters.backgroundColor;
end

if get(handles.methodCC,'Value')
    parameters.method = 'cc';
elseif get(handles.methodSquare,'Value')
    parameters.method = 'sq';
else
    parameters.method = 'xcMatlab';
end

handles.hMain.U.clearContents();  % clear Undo history
 
if get(handles.twoStacksModeRadio,'Value')  % align 2 datasets
    if isempty(fields(handles.files)) && get(handles.importRadio,'Value') == 0
        handles = selectButton_Callback(hObject, eventdata, handles);
        %handles = guidata(handles.alignDatasetsDlg);
    end
    if get(handles.dirRadio, 'Value')
        % loading the datasets
        [img,  handles.img_info] = ib_getImages(handles.files, handles.img_info);
        wb = waitbar(0,sprintf('Aligning stacks using color channel %d ...', colorCh),'Name','Aligning...','WindowStyle','modal');
    elseif get(handles.fileRadio, 'Value')
        [img,  handles.img_info] = ib_getImages(handles.files, handles.img_info);
        wb = waitbar(0,sprintf('Aligning stacks using color channel %d ...', colorCh),'Name','Aligning...','WindowStyle','modal');
    elseif get(handles.importRadio, 'Value')
        wb = waitbar(0,sprintf('Aligning stacks using color channel %d ...', colorCh),'Name','Aligning...','WindowStyle','modal');
        imgInfoVar = get(handles.imageInfoEdit,'String');
        img = evalin('base', pathIn);
        if numel(size(img)) == 3 && size(img,3) > 3    % reshape original dataset to w:h:color:z
            img = reshape(img, size(img,1),size(img,2),1,size(img,3));
        end;
        if ~isempty(imgInfoVar)
            handles.img_info = evalin('base', imgInfoVar);
        else
            handles.img_info = NaN;
        end
    end
    
    parameters.centerX = str2double(get(handles.searchX, 'String'));
    parameters.centerY = str2double(get(handles.searchY, 'String'));
    parameters.templateWidth = str2double(get(handles.searchWidth, 'String'));
    parameters.colorCh = colorCh;
    if parameters.colorCh==0
        parameters.colorCh = 1;
    end
    
    if get(handles.gradientCheckBox, 'value')
        parameters.gradientSw = 1;
    else
        parameters.gradientSw = 0;
    end
    
    firstInfoSize = size(handles.hMain.Img{handles.hMain.Id}.I.img);
    secondInfoSize = size(img);
    
    if size(img,3) == 3
        colorType = 'truecolor';
    else
        colorType = 'grayscale';
    end
    
    dummySelection = zeros(size(img,1),size(img,2),size(img,4),'uint8');    % dummy variable for resizing mask, model and selection
    
    %handles.hMain.Img{handles.hMain.Id}.I.img = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.img, img, parameters);
    if get(handles.twoStacksAutoSwitch,'Value')     % automatic mode
        [img, shiftsXY] = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.img, img, parameters);
    else    % manual mode with provided parameters
        shiftsXY(1) = str2double(get(handles.manualShiftX,'String'));
        shiftsXY(2) = str2double(get(handles.manualShiftY,'String'));
        [img, shiftsXY] = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.img, img, parameters, shiftsXY);
    end
    if img == 0;        delete(wb);        return; end;

    waitbar(0.5, wb);
%     if ~isa(handles.img_info,'containers.Map')
%         fieldNames = keys(handles.hMain.Img{handles.hMain.Id}.I.img_info);
%         for field=1:numel(fieldNames)
%             handles.hMain.Img{handles.hMain.Id}.I.img_info(fieldNames{field}) = NaN;
%         end
%         handles.hMain.Img{handles.hMain.Id}.I.img_info('ColorType') = colorType;
%     else
%         fieldNames = keys(handles.hMain.Img{handles.hMain.Id}.I.img_info);
%         for field=1:numel(fieldNames)
%             if isKey(handles.img_info, fieldNames(field))
%                 handles.hMain.Img{handles.hMain.Id}.I.img_info(fieldNames{field}) = handles.img_info(fieldNames{field});
%             else
%                 handles.hMain.Img{handles.hMain.Id}.I.img_info(fieldNames{field}) = NaN;
%             end
%         end
%     end
    
    waitbar(0.7, wb);
    
    if ~strcmp(handles.hMain.Img{handles.hMain.Id}.I.model_type, 'uint6')
        if handles.hMain.Img{handles.hMain.Id}.I.modelExist
            set(wb,'Name','Aligning model...');
            [handles.hMain.Img{handles.hMain.Id}.I.model, ~] = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.model, dummySelection, parameters, shiftsXY);
        end
        if handles.hMain.Img{handles.hMain.Id}.I.maskExist
            set(wb,'Name','Aligning mask...');
            [handles.hMain.Img{handles.hMain.Id}.I.maskImg, ~] = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.maskImg, dummySelection, parameters, shiftsXY);
        end
        if  ~isnan(handles.hMain.Img{handles.hMain.Id}.I.selection(1))
            set(wb,'Name','Aligning selection...');
            [handles.hMain.Img{handles.hMain.Id}.I.selection, ~] = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.selection, dummySelection, parameters, shiftsXY);
        end
    else
        set(wb,'Name','Aligning Selection, Mask, Model...');
        [handles.hMain.Img{handles.hMain.Id}.I.model, ~] = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.model, dummySelection, parameters, shiftsXY);
    end
    
    imgDims(1) = size(img,1);
    imgDims(2) = size(img,2);
    imgDims(3) = size(img,4);
    
    %firstInfoSize
    %secondInfoSize
    %shiftsXY
    
    xyzShift = [0 0 0];
    if shiftsXY(1) < 0  % shift x coordinate
        xyzShift(1) = shiftsXY(1) * handles.hMain.Img{handles.hMain.Id}.I.pixSize.x;    % convert to image units
    end
    if shiftsXY(2) < 0  % shift y coordinate
        xyzShift(2) = shiftsXY(2) * handles.hMain.Img{handles.hMain.Id}.I.pixSize.y;    % convert to image units
    end
    
    handles.hMain.Img{handles.hMain.Id}.I.updateBoundingBox(NaN, xyzShift, imgDims);    % update bounding box
    %bb = handles.hMain.Img{handles.hMain.Id}.I.getBoundingBox();     % get updated bounding box
    waitbar(0.99, wb);
    
    % combine SliceName
    if isKey(handles.hMain.Img{handles.hMain.Id}.I.img_info, 'SliceName')
        handles.hMain.Img{handles.hMain.Id}.I.img_info('SliceName') = [handles.hMain.Img{handles.hMain.Id}.I.img_info('SliceName'); handles.img_info('SliceName')];
    end
    
    handles.hMain = handles.hMain.Img{handles.hMain.Id}.I.replaceDataset(img, handles.hMain, handles.hMain.Img{handles.hMain.Id}.I.img_info,...
        handles.hMain.Img{handles.hMain.Id}.I.model, handles.hMain.Img{handles.hMain.Id}.I.maskImg, handles.hMain.Img{handles.hMain.Id}.I.selection);
    %handles.hMain.Img{handles.hMain.Id}.I.updateBoundingBox();
    %[handles.hMain.Img{handles.hMain.Id}.I.img_info ~] = ib_updatePixSizeAndResolution(handles.hMain.Img{handles.hMain.Id}.I.img_info, handles.hMain.Img{handles.hMain.Id}.I.pixSize);
    delete(wb);
else    % align the currently opened dataset
    if get(handles.landmarkCheck, 'value')
        optionsGetData.blockModeSwitch = 0;
        selection = handles.hMain.Img{handles.hMain.Id}.I.getData3D('selection', NaN, 4, NaN, optionsGetData);
        handles.shiftsXY = zeros(2,size(selection, 3));
        shiftX = 0;     % shift vs 1st slice in X
        shiftY = 0;     % shift vs 1st slice in Y
        for layer=1:size(selection, 3)-1
            if sum(sum(selection(:,:,layer))) > 0   % landmark is found
                STATS1 = regionprops(selection(:,:,layer), 'Centroid');
                STATS2 = regionprops(selection(:,:,layer+1), 'Centroid');
                if ~isempty(STATS2)  % no second landmark found
                    shiftX = round(shiftX - (STATS2.Centroid(1) - STATS1.Centroid(1)));
                    shiftY = round(shiftY - (STATS2.Centroid(2) - STATS1.Centroid(2)));
                end
            end
            handles.shiftsXY(1,layer+1) = shiftX;
            handles.shiftsXY(2,layer+1) = shiftY;
        end
        % do alignment
        [handles.hMain.Img{handles.hMain.Id}.I.img, handles.shiftsXY] = ib_alignstack(handles.hMain.Img{handles.hMain.Id}.I.img, parameters, handles.shiftsXY);
    elseif get(handles.affineCheck, 'value')
        optionsGetData.blockModeSwitch = 0;
        selection = handles.hMain.Img{handles.hMain.Id}.I.getData3D('selection', NaN, 4, NaN, optionsGetData);
        handles.shiftsXY = zeros(2,size(selection, 3));
        %shiftX = 0;     % shift vs 1st slice in X
        %shiftY = 0;     % shift vs 1st slice in Y
        for layer=1:size(selection, 3)-1
            if sum(sum(selection(:,:,layer))) > 0   % landmark is found
                CC1 = bwconncomp(selection(:,:,layer));
                if CC1.NumObjects ~= 3; continue; end;  % require 3 points
                CC2 = bwconncomp(selection(:,:,layer+1));
                if CC2.NumObjects ~= 3; layer=layer+1; continue; end;  % require 3 points
                
                STATS1 = regionprops(CC1, 'Centroid');
                STATS2 = regionprops(CC2, 'Centroid');
                
                % find distances between centroids of material 1 and material 2
                X1 =  reshape([STATS1.Centroid],[2 3])';     % centroids matrix, c1([x,y], pointNumber)
                X2 =  reshape([STATS2.Centroid],[2 3])';
                idx = findMatchingPairs(X2, X1);
                
                output = reshape([STATS1.Centroid],[2 3])';     % main dataset points, centroids matrix, c1(pointNumber, [x,y]) 
                for objId = 1:3
                    input(objId, :) = STATS2(idx(objId)).Centroid; % the second dataset points, centroids matrix, c1(pointNumber, [x,y]) 
                end
                tform2 = maketform('affine', input, output);
                
                [T, xdata, ydata] = imtransform(handles.hMain.Img{handles.hMain.Id}.I.img(:,:,:,layer+1:end), tform2, 'bicubic');
                options = struct();
                options.backgroundColor = 'black';
                options.modelSwitch = 0;
                if xdata(1) < 1
                    shiftsXY = floor(xdata(1));
                else
                    shiftsXY = ceil(xdata(1));
                end
                
                if ydata(1) < 1
                    shiftsXY(2) = floor(ydata(1))-1;
                else
                    shiftsXY(2) = ceil(ydata(1))-1;
                end
                handles.shiftsXY(:,layer) = shiftsXY;
                [handles.hMain.Img{handles.hMain.Id}.I.img, handles.shiftsXY] = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.img(:,:,:,1:layer), T, options, handles.shiftsXY(:,layer));
                layerId = layer;
                layer = size(selection, 3)-1;
            end
        end
        
    elseif get(handles.loadShiftsCheck,'Value')     % use preexisting parameters
        [handles.hMain.Img{handles.hMain.Id}.I.img, handles.shiftsXY] = ib_alignstack(handles.hMain.Img{handles.hMain.Id}.I.img, parameters, handles.shiftsXY);
    else
        parameters.centerX = str2double(get(handles.searchX,'String'));
        parameters.centerY = str2double(get(handles.searchY,'String'));
        parameters.templateWidth = str2double(get(handles.searchWidth,'String'));
        parameters.colorCh = colorCh;
        if get(handles.gradientCheckBox, 'value')
            parameters.gradientSw = 1;
        else
            parameters.gradientSw = 0;
        end
        parameters.step = str2double(get(handles.stepEditbox,'string'));
        [handles.hMain.Img{handles.hMain.Id}.I.img, handles.shiftsXY] = ib_alignstack(handles.hMain.Img{handles.hMain.Id}.I.img, parameters);
    end
    handles.hMain.Img{handles.hMain.Id}.I.height = size(handles.hMain.Img{handles.hMain.Id}.I.img, 1);
    handles.hMain.Img{handles.hMain.Id}.I.width = size(handles.hMain.Img{handles.hMain.Id}.I.img, 2);
    handles.hMain.Img{handles.hMain.Id}.I.slices{1} = [1, handles.hMain.Img{handles.hMain.Id}.I.height];
    handles.hMain.Img{handles.hMain.Id}.I.slices{2} = [1, handles.hMain.Img{handles.hMain.Id}.I.width];
    handles.hMain.Img{handles.hMain.Id}.I.slices{3} = 1:size(handles.hMain.Img{handles.hMain.Id}.I.img,3);
    handles.hMain.Img{handles.hMain.Id}.I.slices{4} = [1, 1];
    handles.hMain.Img{handles.hMain.Id}.I.slices{5} = [1, 1];
    
    % calculate shift of the bounding box
    maxXshift = min(handles.shiftsXY(1,:)-handles.shiftsXY(1,1));   % X shift in pixels vs the first slice
    maxYshift = min(handles.shiftsXY(2,:)-handles.shiftsXY(2,1));   % Y shift in pixels vs the first slice
    maxXshift = maxXshift*handles.hMain.Img{handles.hMain.Id}.I.pixSize.x;  % X shift in units vs the first slice
    maxYshift = maxYshift*handles.hMain.Img{handles.hMain.Id}.I.pixSize.y;  % Y shift in units vs the first slice
    handles.hMain.Img{handles.hMain.Id}.I.updateBoundingBox(NaN, [maxXshift, maxYshift, 0]);
    handles.hMain.Img{handles.hMain.Id}.I.updateImgInfo('Aligned');
    
    options.modelSwitch = 1;
    
    wb = waitbar(0,'','WindowStyle','modal');
    if ~strcmp(handles.hMain.Img{handles.hMain.Id}.I.model_type, 'uint6')
        if handles.hMain.Img{handles.hMain.Id}.I.modelExist
            set(wb,'Name','Aligning model...');
            if get(handles.affineCheck, 'value') == 0
                [handles.hMain.Img{handles.hMain.Id}.I.model, handles.shiftsXY] = ib_alignstack(handles.hMain.Img{handles.hMain.Id}.I.model, parameters, handles.shiftsXY);
            else
                T = imtransform(handles.hMain.Img{handles.hMain.Id}.I.model(:,:,layerId+1:end), tform2, 'nearest');
                handles.hMain.Img{handles.hMain.Id}.I.model = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.model(:,:,1:layerId), T, options, handles.shiftsXY(:,layerId));
            end
        end
        if handles.hMain.Img{handles.hMain.Id}.I.maskExist
            set(wb,'Name','Aligning mask...');
            if get(handles.affineCheck, 'value') == 0
                [handles.hMain.Img{handles.hMain.Id}.I.maskImg, handles.shiftsXY] = ib_alignstack(handles.hMain.Img{handles.hMain.Id}.I.maskImg, parameters, handles.shiftsXY);
            else
                T = imtransform(handles.hMain.Img{handles.hMain.Id}.I.maskImg(:,:,layerId+1:end), tform2, 'nearest');
                handles.hMain.Img{handles.hMain.Id}.I.maskImg = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.maskImg(:,:,1:layerId), T, options, handles.shiftsXY(:,layerId));
            end
        end
        if  ~isnan(handles.hMain.Img{handles.hMain.Id}.I.selection(1))
            set(wb,'Name','Aligning selection...');
            if get(handles.affineCheck, 'value') == 0
                [handles.hMain.Img{handles.hMain.Id}.I.selection, handles.shiftsXY] = ib_alignstack(handles.hMain.Img{handles.hMain.Id}.I.selection, parameters, handles.shiftsXY);
            else
                T = imtransform(handles.hMain.Img{handles.hMain.Id}.I.selection(:,:,layerId+1:end), tform2, 'nearest');
                handles.hMain.Img{handles.hMain.Id}.I.selection = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.selection(:,:,1:layerId), T, options, handles.shiftsXY(:,layerId));
            end
        end
    else
        set(wb,'Name','Aligning Selection, Mask, Model...');
        if get(handles.affineCheck, 'value') == 0
            [handles.hMain.Img{handles.hMain.Id}.I.model, handles.shiftsXY] = ib_alignstack(handles.hMain.Img{handles.hMain.Id}.I.model, parameters, handles.shiftsXY);
        else
            T = imtransform(handles.hMain.Img{handles.hMain.Id}.I.model(:,:,layerId+1:end), tform2, 'nearest');
            handles.hMain.Img{handles.hMain.Id}.I.model = ib_alignstacks(handles.hMain.Img{handles.hMain.Id}.I.model(:,:,1:layerId), T, options, handles.shiftsXY(:,layerId));
        end
    end
    
    if get(handles.saveShiftsCheck,'Value')     % use preexisting parameters
        fn = get(handles.saveShiftsXYpath,'String');
        output = handles.shiftsXY; %#ok<NASGU>
        save(fn, 'output');
    end
    delete(wb);
end

handles.hMain.Img{handles.hMain.Id}.I.width = size(handles.hMain.Img{handles.hMain.Id}.I.img, 2);
handles.hMain.Img{handles.hMain.Id}.I.height = size(handles.hMain.Img{handles.hMain.Id}.I.img, 1);
handles.hMain.Img{handles.hMain.Id}.I.img_info('Height') = handles.hMain.Img{handles.hMain.Id}.I.height;
handles.hMain.Img{handles.hMain.Id}.I.img_info('Width') = handles.hMain.Img{handles.hMain.Id}.I.width;
handles.hMain.Img{handles.hMain.Id}.I.img_info('Stacks') = size(handles.hMain.Img{handles.hMain.Id}.I.img,3);
% update axes to show the resized image
handles.hMain = handles.hMain.Img{handles.hMain.Id}.I.updateAxesLimits(handles.hMain, 'resize');

% Update handles structure
%guidata(hObject, handles);
guidata(handles.hMain.im_browser, handles.hMain);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.alignDatasetsDlg);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.alignDatasetsDlg);
end

% --- Executes when user attempts to close alignDatasetsDlg.
function alignDatasetsDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to alignDatasetsDlg (see GCBO)
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

% --- Executes on key press over alignDatasetsDlg with no controls selected.
function alignDatasetsDlg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to alignDatasetsDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'Cancel';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.alignDatasetsDlg);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.alignDatasetsDlg);
end    
end



function pathEdit_Callback(hObject, eventdata, handles)
handles = selectButton_Callback(hObject, eventdata, handles);
path = get(handles.pathEdit,'String');
if get(handles.dirRadio,'Value')
    if ~isdir(path)
        msgbox('Wrong directory name!','Error!','err');
    end
elseif get(handles.fileRadio, 'Value')
    if ~exist(path, 'file')
        msgbox('Wrong file name!','Error!','err');
    end
end
% Update handles structure
guidata(handles.alignDatasetsDlg, handles);
end

function [img_info, files, pixSize, dimsXYZ] = getMetaInfo(dirName, handles)
parameters.waitbar = 1;     % show waitbar
if get(handles.dirRadio,'Value')
    files = dir(dirName);
    clear filenames;
    index=1;
    for i=1:numel(files)
        if ~files(i).isdir
            filenames{index} = fullfile(dirName, files(i).name);
            index = index + 1;
        end
    end
    [img_info, files, pixSize] = getImageMetadata(filenames, parameters);
    dimsXYZ(1) = files(1).width;
    dimsXYZ(2) = files(1).height;
    dimsXYZ(3) = 0;
    for i=1:numel(files)
        dimsXYZ(3) = dimsXYZ(3) + files(i).noLayers;
    end
elseif get(handles.fileRadio, 'Value')
    [img_info, files, pixSize] = getImageMetadata(cellstr(dirName));
    dimsXYZ(1) = files(1).width;
    dimsXYZ(2) = files(1).height;
    dimsXYZ(3) = 0;
    for i=1:numel(files)
        dimsXYZ(3) = dimsXYZ(3) + files(i).noLayers;
    end
elseif get(handles.importRadio, 'Value')
    imgInfoVar = get(handles.imageInfoEdit,'String');
    pathIn = get(handles.pathEdit,'String');
    try %#ok<TRYNC>
        img = evalin('base', pathIn);
        if numel(size(img)) == 3 && size(img,3) > 3    % reshape original dataset to w:h:color:z
            dimsXYZ(1) = size(img,2);
            dimsXYZ(2) = size(img,1);
            dimsXYZ(3) = size(img,3);
        else
            dimsXYZ(1) = size(img,2);
            dimsXYZ(2) = size(img,1);
            dimsXYZ(3) = size(img,4);
        end;
        if ~isempty(imgInfoVar)
            img_info = evalin('base', imgInfoVar);
        else
            img_info = containers.Map;
        end
    end
    files = struct();
    pixSize = struct();
    img_info = NaN; 
    dimsXYZ = NaN;
end
end



% --- Executes on button press in selectButton.
function handles = selectButton_Callback(hObject, eventdata, handles)
startingPath = get(handles.pathEdit,'String');
%parameters.waitbar = 1;     % show waitbar
if get(handles.dirRadio,'Value')
    newValue = uigetdir(startingPath,'Select directory...');
    if newValue == 0; return; end;
    [handles.img_info, handles.files, handles.pixSize, dimsXYZ] = getMetaInfo(newValue, handles);
    set(handles.pathEdit,'String', newValue);
    set(handles.pathEdit,'Tooltip', newValue);
elseif get(handles.fileRadio, 'Value')
    [FileName, PathName] = uigetfile({'*.tif; *.am','(*.tif; *.am) TIF/AM Files'; 
                                      '*.am','(*.am) Amira Mesh Files'; 
                                      '*.tif','(*.tif) TIF Files'; 
                                      '*.*','All Files'},'Select file...',startingPath);
    if FileName == 0; return; end;
    newValue = fullfile(PathName, FileName);
    [handles.img_info, handles.files, handles.pixSize, dimsXYZ] = getMetaInfo(newValue, handles);
    set(handles.pathEdit,'String', newValue);
    set(handles.pathEdit,'Tooltip', newValue);
elseif get(handles.importRadio, 'Value')
    [handles.img_info, handles.files, handles.pixSize, dimsXYZ] = getMetaInfo('', handles);
    if isnan(dimsXYZ); return; end;
end
set(handles.secondDimText,'String', sprintf('%d x %d x %d', dimsXYZ(1), dimsXYZ(2), dimsXYZ(3)));
set(handles.searchX,'String', num2str(round(dimsXYZ(1)/2)));
set(handles.searchY,'String', num2str(round(dimsXYZ(2)/2)));

% Update handles structure
guidata(handles.alignDatasetsDlg, handles);

end



function radioButton_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 0; set(hObject,'Value',1); return; end;
if get(handles.dirRadio,'Value')
    set(handles.pathEdit, 'String', handles.pathstr);
    set(handles.imageInfoEdit,'Enable','off');
    set(handles.secondDatasetPath,'String','Path:');
elseif get(handles.fileRadio, 'Value')
    set(handles.pathEdit, 'String', handles.pathstr);
    set(handles.imageInfoEdit,'Enable','off');
    set(handles.secondDatasetPath,'String','Filename:');
elseif get(handles.importRadio, 'Value')
    handles.pathstr = get(handles.pathEdit, 'String');
    set(handles.pathEdit, 'String', handles.varname);
    set(handles.secondDatasetPath,'String','Variable in the main Matlab workspace:');
    set(handles.imageInfoEdit,'Enable','on');
end
handles = selectButton_Callback(hObject, eventdata, handles);
%[handles.img_info handles.files handles.pixSize dimsXYZ] = getMetaInfo('handles.pathstr', handles);
%set(handles.secondDimText,'String', sprintf('%d x %d x %d', dimsXYZ(1), dimsXYZ(2), dimsXYZ(3)));
guidata(hObject, handles);
end

function modeRadioButton_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 0
    set(hObject,'Value',1);
end
if get(handles.twoStacksModeRadio,'Value')
    set(handles.secondDatasetPanel,'Visible','on');
    set(handles.secondDatasetDetailsPanel,'Visible','on');
    set(handles.saveShiftsPanel,'Visible','off');
    set(handles.currStackOptionsPanel,'Visible','off');
else
    set(handles.secondDatasetPanel,'Visible','off');
    set(handles.secondDatasetDetailsPanel,'Visible','off');
    set(handles.saveShiftsPanel,'Visible','on');
    set(handles.currStackOptionsPanel,'Visible','on');
end
end


% --- Executes on button press in getSearchWindow.
function getSearchWindow_Callback(hObject, eventdata, handles)
sel = handles.hMain.Img{handles.hMain.Id}.I.getCurrentSlice('selection');
STATS = regionprops(sel, 'BoundingBox');
if numel(STATS) == 0
    msgbox('No selection layer present in the current slice!','Error','err');
    return;
end
STATS = STATS(1);
centerX = round(STATS.BoundingBox(1)+STATS.BoundingBox(3)/2);
centerY = round(STATS.BoundingBox(2)+STATS.BoundingBox(4)/2);
templateWidth = round(min([STATS.BoundingBox(3)/2 STATS.BoundingBox(4)/2]))-1;
set(handles.searchX, 'String', num2str(centerX));
set(handles.searchY, 'String', num2str(centerY));
set(handles.searchWidth, 'String', num2str(templateWidth));
end


% --- Executes on button press in saveShiftsCheck.
function saveShiftsCheck_Callback(hObject, eventdata, handles)
if get(handles.saveShiftsCheck, 'Value')
    startingPath = get(handles.saveShiftsXYpath,'String');
    [FileName, PathName] = uiputfile({'*.coefXY','*.coefXY (Matlab format)'; '*.*','All Files'},'Select file...',startingPath);
    if FileName == 0; set(handles.saveShiftsCheck, 'Value', 0); return; end;
    set(handles.saveShiftsXYpath,'String', fullfile(PathName, FileName));
    set(handles.saveShiftsXYpath,'Enable','on');
else
    set(handles.saveShiftsXYpath,'Enable','off');
end
end

% --- Executes on button press in loadShiftsCheck.
function loadShiftsCheck_Callback(hObject, eventdata, handles)
if get(handles.loadShiftsCheck, 'Value')
    startingPath = get(handles.loadShiftsXYpath,'String');
    [FileName, PathName] = uigetfile({'*.coefXY','*.coefXY (Matlab format)'; '*.*','All Files'},'Select file...',startingPath);
    if FileName == 0; set(handles.loadShiftsCheck, 'Value', 0); return; end;
    set(handles.loadShiftsXYpath,'String', fullfile(PathName, FileName));
    set(handles.loadShiftsXYpath,'Enable','on');
    var = load(fullfile(PathName, FileName),'-mat');
    fields = fieldnames(var);
    handles.shiftsXY = var.(fields{1});
else
    set(handles.loadShiftsXYpath,'Enable','off');
end
guidata(hObject, handles);
end


% --- Executes on button press in twoStacksAutoSwitch.
function twoStacksAutoSwitch_Callback(hObject, eventdata, handles)
if get(handles.twoStacksAutoSwitch,'Value')
    set(handles.manualShiftX, 'Enable', 'off');
    set(handles.manualShiftY, 'Enable', 'off');
else
    set(handles.manualShiftX, 'Enable', 'on');
    set(handles.manualShiftY, 'Enable', 'on');
end

end



function stepEditbox_Callback(hObject, eventdata, handles)
val = round(str2double(get(handles.stepEditbox,'String')));
if val < 1
    msgbox('Step should be an integer positive number!', 'Error!','error');
    set(handles.stepEditbox,'String', 1);
else
    set(handles.stepEditbox,'String', num2str(val));
end
end


function bgCustomEdit_Callback(hObject, eventdata, handles)
set(handles.bgCustomRadio,'Value',1);
end

% --- Executes on button press in landmarkCheck.
function landmarkCheck_Callback(hObject, eventdata, handles)
val = get(handles.landmarkCheck, 'value');
if val
    textStr = sprintf('Use the brush tool to mark two corresponding spots on\nconsecutive slices.\nThe dataset will be shifted to align the marked spots.');
    set(handles.landmarkHelpText,'string', textStr);
    set(handles.landmarkHelpText, 'enable', 'on');
    set(handles.affineCheck, 'value', 0);
else
    set(handles.landmarkHelpText, 'enable', 'off');
end
end


% --- Executes on button press in affineCheck.
function affineCheck_Callback(hObject, eventdata, handles)
val = get(handles.affineCheck, 'value');
if val
    textStr = sprintf('Use the brush tool to mark three corresponding spots on\ntwo consecutive slices.\nThe dataset will be shifted/rotated/scaled to align the marked spots.');
    set(handles.landmarkHelpText,'string', textStr);
    set(handles.landmarkHelpText, 'enable', 'on');
    set(handles.landmarkCheck, 'value', 0);
else
    set(handles.landmarkHelpText, 'enable', 'off');
end
end

function idx = findMatchingPairs(X1, X2)
% find matching pairs for X1 from X2
% X1[:, (x,y)]
% X2[:, (x,y)]

% % following code is equal to pdist2 function in the statistics toolbox
% % such as: dist = pdist2(X1,X2);
dist = zeros([size(X1,1) size(X2,1)]);
for i=1:size(X1,1)
    for j=1:size(X2,1)
        dist(i,j) = sqrt((X1(i,1)-X2(j,1))^2 + (X1(i,2)-X2(j,2))^2);
    end
end

% alternative fast method
% DD = sqrt( bsxfun(@plus,sum(X1.^2,2),sum(X2.^2,2)') - 2*(X1*X2') );

% following is an adaptation of a code by Gunther Struyf
% http://stackoverflow.com/questions/12083467/find-the-nearest-point-pairs-between-two-sets-of-of-matrix
N = size(X1,1);
matchAtoB=NaN(N,1);
X1b = X1;
X2b = X2;
for ii=1:N
    %dist(:,matchAtoB(1:ii-1))=Inf; % make sure that already picked points of B are not eligible to be new closest point
    %[~, matchAtoB(ii)]=min(dist(ii,:));
    dist(matchAtoB(1:ii-1),:)=Inf; % make sure that already picked points of B are not eligible to be new closest point
    %         for jj=1:N
    %             [~, minVec(jj)] = min(dist(:,jj));
    %         end
    [~, matchAtoB(ii)]=min(dist(:,ii));
    
    %         X2b(matchAtoB(1:ii-1),:)=Inf;
    %         goal = X1b(ii,:);
    %         r = bsxfun(@minus,X2b,goal);
    %         [~, matchAtoB(ii)] = min(hypot(r(:,1),r(:,2)));
end
matchBtoA = NaN(size(X2,1),1);
matchBtoA(matchAtoB)=1:N;
idx =  matchBtoA;   % indeces of the matching objects, i.e. STATS1(objId) =match= STATS2(idx(objId))

end