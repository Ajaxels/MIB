function varargout = MaskStatsDlg(varargin)
% function varargout = MaskStatsDlg(varargin)
% MaskStatsDlg is a GUI tool to generate statistics of 2D or 3D objects in the Model or Mask layers
%
% MaskStatsDlg contains MATLAB code for MaskStatsDlg.fig

% Copyright (C) 09.07.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, IB, changed .slices to cells
% 25.02.2016, IB, updated for 4D datasets
% 25.10.2016, IB, updated for segmentation table

% Last Modified by GUIDE v2.5 01-Jun-2015 15:23:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MaskStatsDlg_OpeningFcn, ...
    'gui_OutputFcn',  @MaskStatsDlg_OutputFcn, ...
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

% --- Executes just before MaskStatsDlg is made visible.
function MaskStatsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MaskStatsDlg (see VARARGIN)

% Choose default command line output for MaskStatsDlg
repositionSwitch = 1; % reposition the figure, when creating a new figure

if numel(varargin) > 2
    handles = guidata(varargin{3});
    %colorChannelSelection = get(handles.colorChannelCombo,'Value');     % store selected color channel
    repositionSwitch = 0; % keep the current coordinates when the figure already exist
    handles = rmfield(handles, 'h');
else
    handles.obj2DType = 1;    % index of the selected mode for the object mode
    handles.obj3DType = 1;    % index of the selected mode for the object mode
    handles.intType = 1;    % index of the selected mode for the intensity mode
    handles.properties = {'Area'};
end
handles.h = varargin{1};    % handles of im_browser
handles.type = varargin{2};     % type of the statistics: for Mask or Model

userData = get(handles.h.segmTable, 'UserData');

if strcmp(handles.type,'Model')
    if handles.h.Img{handles.h.Id}.I.modelExist == 0
        errordlg(sprintf('The model is not detected!\n\nPlease create a new model using:\nMenu->Models->New model'),'Missing model');
        return;
    end
    handles.sel_model = userData.prevMaterial-2;    % selected material
    if handles.sel_model == 0
        errordlg(sprintf('Please select material of the model and try again!\n\nSegmentation panel->Materials'),'Select material');
        return;
    end
    list = handles.h.Img{handles.h.Id}.I.modelMaterialNames;
    set(handles.maskStatsDlg,'Name',sprintf('Material "%s" statistics...', list{handles.sel_model}));
else
    set(handles.maskStatsDlg,'Name','Mask statistics...');
end

handles.sorting = 1;    % var to keep sorting status for columns
handles.histLimits = [0 1]; % limits for the histogram
handles.indices = [];   % indices for selected objects

handles.sorting_cm = uicontextmenu('Parent',handles.maskStatsDlg);
uimenu(handles.sorting_cm, 'Label', 'Sort by Objects Id', 'Callback', {@sortButtonContext_cb, 'object'});
uimenu(handles.sorting_cm, 'Label', 'Sort by Value', 'Callback', {@sortButtonContext_cb, 'value'});
uimenu(handles.sorting_cm, 'Label', 'Sort by Slice number', 'Callback', {@sortButtonContext_cb, 'slice'});
uimenu(handles.sorting_cm, 'Label', 'Sort by Time number', 'Callback', {@sortButtonContext_cb, 'time'});
set(handles.sortBtn,'uicontextmenu',handles.sorting_cm);

handles.statTable_cm = uicontextmenu('Parent',handles.maskStatsDlg);
uimenu(handles.statTable_cm, 'Label', 'New selection', 'Callback', {@tableContextMenu_cb, 'Replace'});
uimenu(handles.statTable_cm, 'Label', 'Add to selection', 'Callback', {@tableContextMenu_cb, 'Add'});
uimenu(handles.statTable_cm, 'Label', 'Remove from selection', 'Callback', {@tableContextMenu_cb, 'Remove'});
uimenu(handles.statTable_cm, 'Label', 'New annotations', 'Callback', {@tableContextMenu_cb, 'newLabel'}, 'Separator','on');
uimenu(handles.statTable_cm, 'Label', 'Add to annotations', 'Callback', {@tableContextMenu_cb, 'addLabel'});
uimenu(handles.statTable_cm, 'Label', 'Remove from annotations', 'Callback', {@tableContextMenu_cb, 'removeLabel'});
uimenu(handles.statTable_cm, 'Label', 'Calculate Mean value', 'Callback', {@tableContextMenu_cb, 'mean'}, 'Separator','on');
uimenu(handles.statTable_cm, 'Label', 'Calculate Sum value', 'Callback', {@tableContextMenu_cb, 'sum'});
uimenu(handles.statTable_cm, 'Label', 'Calculate Min value', 'Callback', {@tableContextMenu_cb, 'min'});
uimenu(handles.statTable_cm, 'Label', 'Calculate Max value', 'Callback', {@tableContextMenu_cb, 'max'});
uimenu(handles.statTable_cm, 'Label', 'Crop to a file/matlab...', 'Callback', {@tableContextMenu_cb, 'crop'}, 'Separator','on');
uimenu(handles.statTable_cm, 'Label', 'Plot histogram', 'Callback', {@tableContextMenu_cb, 'hist'}, 'Separator','on');
set(handles.statTable,'UIContextMenu',handles.statTable_cm);

% setting the second color combobox
colorChannelsList = get(handles.h.ColChannelCombo,'String');
set(handles.firstChannelCombo, 'String', colorChannelsList(2:end));
set(handles.secondChannelCombo, 'String', colorChannelsList(2:end));
if numel(colorChannelsList) > 2
    set(handles.secondChannelCombo, 'Value', 2);
else
    set(handles.secondChannelCombo, 'Value', 1);
end
% when only one color channel is shown select it
if numel(handles.h.Img{handles.h.Id}.I.slices{3}) == 1
    colorChannelSelection = handles.h.Img{handles.h.Id}.I.slices{3};
    set(handles.firstChannelCombo,'Value',colorChannelSelection);
else
    set(handles.firstChannelCombo,'Value',handles.h.Img{handles.h.Id}.I.slices{3}(1));
end

% update font and size
if get(handles.text6, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text6, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.maskStatsDlg, handles.h.preferences.Font);
end

% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.maskStatsDlg);

% Update handles structure
guidata(hObject, handles);

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
if repositionSwitch
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
        screenSize = get(0,'ScreenSize');
        if GCBFPos(1)-FigWidth > 0 % put figure on the left side of the main figure
            FigPos(1:2) = [GCBFPos(1)-FigWidth GCBFPos(2)+GCBFPos(4)-FigHeight];
        elseif GCBFPos(1) + GCBFPos(3) + FigWidth < screenSize(3) % put figure on the right side of the main figure
            FigPos(1:2) = [GCBFPos(1)+GCBFPos(3) GCBFPos(2)+GCBFPos(4)-FigHeight];
        else
            FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
        end
    end
    FigPos(3:4)=[FigWidth FigHeight];
    set(hObject, 'Position', FigPos);
    set(hObject, 'Units', OldUnits);
end

% UIWAIT makes MaskStatsDlg wait for user response (see UIRESUME)
% uiwait(handles.maskStatsDlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = MaskStatsDlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.h;

% The figure can be deleted now
% delete(handles.maskStatsDlg);
end

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to closeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = handles.h;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.maskStatsDlg);
delete(handles.maskStatsDlg);
end

% --- Executes when user attempts to close maskStatsDlg.
function maskStatsDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to maskStatsDlg (see GCBO)
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

% --- Executes on button press in runStatAnalysis.
function runStatAnalysis_Callback(hObject, eventdata, handles)
contents = get(handles.propertyCombo,'String');
selectedProperty = contents{get(handles.propertyCombo,'Value')};
selectedProperty = strtrim(selectedProperty);

if get(handles.multipleCheck, 'value') == 1
    property = handles.properties;
else
    property = cellstr(selectedProperty);
end
datasetTypeList = get(handles.datasetPopup,'string');
frame = datasetTypeList{get(handles.datasetPopup,'value')};

mode = get(get(handles.modePanel,'selectedobject'),'String');   % 2d/3d objects
mode2 = get(get(handles.intensityPanel,'selectedobject'),'String');     % object/intensity stats
connectivity = get(handles.connectivityCombo,'Value');   % if 1: connectivity=4(2d) and 6(3d), if 2: 8(2d)/26(3d)
colorChannel = get(handles.firstChannelCombo,'Value');
colorChannel2 = get(handles.secondChannelCombo,'Value');    % for correlation

handles.h = guidata(handles.h.im_browser);  % update handles

userData = get(handles.h.segmTable, 'UserData');
if userData.prevMaterial == 1
    handles.type = 'Mask';
else
    handles.type = 'Model';
end

if strcmp(handles.type,'Model')
    if handles.h.Img{handles.h.Id}.I.modelExist == 0
        errordlg(sprintf('The model is not detected!\n\nPlease create a new model using:\nMenu->Models->New model'),'Missing model');
        return;
    end
    handles.sel_model = userData.prevMaterial-2;    % selected material
    if handles.sel_model < 1
        errordlg(sprintf('Please select material of the model and try again!\n\nSegmentation panel->Materials'),'Select material');
        return;
    end
    list = handles.h.Img{handles.h.Id}.I.modelMaterialNames;
    set(handles.maskStatsDlg, 'Name', sprintf('Material "%s" statistics...', list{handles.sel_model}));
    if numel(property) == 1
        wb = waitbar(0,sprintf('Calculating "%s" of %s for %s\nMaterial: "%s"\nPlease wait...',property{1}, mode, frame, list{handles.sel_model}),'Name','Shape statistics...','WindowStyle','modal');
    else
        wb = waitbar(0,sprintf('Calculating multiple parameters of %s for %s\nMaterial: "%s"\nPlease wait...', mode, frame, list{handles.sel_model}),'Name','Shape statistics...','WindowStyle','modal');
    end
else
    if handles.h.Img{handles.h.Id}.I.maskExist == 0
        errordlg(sprintf('The Mask is not detected!\n\nPlease create a new Mask using:\n1.Draw the mask with Brush\n2. Select Segmentation panel->Add to->Mask\n3. Press the "A" shortcut to add the drawn area to the Mask layer'),'Missing model');
        return;
    end
    set(handles.maskStatsDlg,'Name','Mask statistics...');
    if numel(property) == 1
        wb = waitbar(0,sprintf('Calculating "%s" of %s for %s\n Material: Mask\nPlease wait...',property{1}, mode, frame),'Name','Shape statistics...','WindowStyle','modal');
    else
        wb = waitbar(0,sprintf('Calculating multiple parameters of %s for %s\n Material: Mask\nPlease wait...',mode, frame),'Name','Shape statistics...','WindowStyle','modal');
    end
end

getDataOptions.blockModeSwitch = 0;
[img_height, img_width, ~, img_depth, img_time] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, getDataOptions);

t1 = handles.h.Img{handles.h.Id}.I.slices{5}(1);
t2 = handles.h.Img{handles.h.Id}.I.slices{5}(1);
if strcmp(frame, '4D, Dataset')
    t1 = 1;
    t2 = img_time;
end

property{end+1} = 'PixelIdxList';
property{end+1} = 'Centroid';
property{end+1} = 'TimePnt';
        
handles.STATS = cell2struct(cell(size(property)), property, 2);
handles.STATS = orderfields(handles.STATS);
handles.STATS(1) = [];

for t=t1:t2
    if strcmp(mode, '3D objects')
        if strcmp(frame, '2D, Slice')    % take only objects that are shown in the current slice
            delete(wb);
            msgbox(sprintf('CANCELED!\nThe Shown slice with 3D Mode is not implemented!'),'Error!','error','modal');
            return;
            %         selection2 = zeros(size(img),'uint8');
            %         objCounter = 1;
            %         lay_id = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
            %
            %         CC2.Connectivity = CC.Connectivity;
            %         CC2.ImageSize = CC.ImageSize;
            %         index1 = img_height*img_width*(lay_id-1);
            %         index2 = img_height*img_width*(lay_id);
            %         for obj=1:CC.NumObjects
            %             if CC.PixelIdxList{1,obj}(1) < index1; continue; end;
            %             if CC.PixelIdxList{1,obj}(end) > index2; continue; end;
            %             selection2(CC.PixelIdxList{1,obj}) = 1;
            %             CC2.PixelIdxList(1,objCounter) = CC.PixelIdxList(1,obj);
            %             objCounter = objCounter + 1;
            %         end
            %         CC2.NumObjects = objCounter - 1;
            %         CC = CC2;
        end
        
        if connectivity == 1
            conn = 6;
        else
            conn = 26;
        end;
        
        getDataOptions.blockModeSwitch = 0;
        if strcmp(handles.type, 'Mask')
            img = handles.h.Img{handles.h.Id}.I.getData3D('mask', t, 4, 0, getDataOptions);
        elseif strcmp(handles.type, 'Model')
            img = handles.h.Img{handles.h.Id}.I.getData3D('model', t, 4, handles.sel_model, getDataOptions);
        end
        
        intProps = {'SumIntensity','StdIntensity','MeanIntensity','MaxIntensity','MinIntensity'};
        
        if sum(ismember(property, 'HolesArea')) > 0
            img = imfill(img, conn, 'holes') - img;
        end
        CC = bwconncomp(img,conn);
        if CC.NumObjects == 0
            continue;
        end
        waitbar(0.05,wb);
        
        % calculate common properties
        STATS = regionprops(CC, {'PixelIdxList', 'Centroid'});
        
        % calculate matlab standard shape properties
        prop1 = property(ismember(property,{'FilledArea', 'Area'}));
        if ~isempty(prop1)
            STATS2 = regionprops(CC, prop1);
            fieldNames = fieldnames(STATS2);
            for i=1:numel(fieldNames)
                [STATS.(fieldNames{i})] = STATS2.(fieldNames{i});
            end
        end
        waitbar(0.1,wb);
        % calculate matlab standard shape properties
        prop1 = property(ismember(property, 'HolesArea'));
        if ~isempty(prop1)
            STATS2 = regionprops(CC, 'Area');
            [STATS.HolesArea] = STATS2.Area;
        end
        waitbar(0.2,wb);
        % calculate Eccentricity for 3D objects
        prop1 = property(ismember(property,{'MeridionalEccentricity','EquatorialEccentricity'}));
        if ~isempty(prop1)
            STATS2 = regionprops3(CC, 'Eccentricity');
            if sum(ismember(property,'MeridionalEccentricity')) > 0
                [STATS.MeridionalEccentricity] = deal(STATS2.MeridionalEccentricity);
            end
            if sum(ismember(property,'EquatorialEccentricity')) > 0
                [STATS.EquatorialEccentricity] = deal(STATS2.EquatorialEccentricity);
            end
        end
        waitbar(0.3,wb);
        % calculate MajorAxisLength
        prop1 = property(ismember(property,'MajorAxisLength'));
        if ~isempty(prop1)
            STATS2 = regionprops3(CC, 'MajorAxisLength');
            [STATS.MajorAxisLength] = deal(STATS2.MajorAxisLength);
        end
        waitbar(0.4,wb);
        % calculate 'SecondAxisLength', 'ThirdAxisLength'
        prop1 = property(ismember(property,{'SecondAxisLength', 'ThirdAxisLength'}));
        if ~isempty(prop1)
            STATS2 = regionprops3(CC, 'AllAxes');
            if sum(ismember(property,'SecondAxisLength')) > 0
                [STATS.SecondAxisLength] = deal(STATS2.SecondAxisLength);
            end
            if sum(ismember(property,'ThirdAxisLength')) > 0
                [STATS.ThirdAxisLength] = deal(STATS2.ThirdAxisLength);
            end
        end
        waitbar(0.5,wb);
        % calculate EndpointsLength for lines
        prop1 = property(ismember(property,'EndpointsLength'));
        if ~isempty(prop1)
            STATS3 = regionprops(CC, 'PixelList');
            for obj=1:numel(STATS3)
                minZ = STATS3(obj).PixelList(1,3);
                maxZ = STATS3(obj).PixelList(end,3);
                minPoints = STATS3(obj).PixelList(STATS3(obj).PixelList(:,3)==minZ,:);   % find points on the starting slice
                minPoints = [minPoints(1,1:2); minPoints(end,1:2)];  % take 1st and last point
                maxPoints = STATS3(obj).PixelList(STATS3(obj).PixelList(:,3)==maxZ,:);   % find points on the ending slice
                maxPoints = [maxPoints(1,1:2); maxPoints(end,1:2)];  % take 1st and last point
                
                DD = sqrt( bsxfun(@plus,sum(minPoints.^2,2),sum(maxPoints.^2,2)') - 2*(minPoints*maxPoints') );
                maxVal = max(DD(:));
                [row, col] = find(DD == maxVal,1);
                STATS3(obj).EndpointsLength = sqrt(...
                    ((minPoints(row,1) - maxPoints(col,1))*handles.h.Img{handles.h.Id}.I.pixSize.x)^2 + ...
                    ((minPoints(row,2) - maxPoints(col,2))*handles.h.Img{handles.h.Id}.I.pixSize.y)^2 + ...
                    ((minZ - maxZ)*handles.h.Img{handles.h.Id}.I.pixSize.z)^2 );
            end
            [STATS.EndpointsLength] = deal(STATS3.EndpointsLength);
        end
        waitbar(0.6,wb);
        % calculate Intensities
        prop1 = property(ismember(property,intProps));
        if ~isempty(prop1)
            img = squeeze(handles.h.Img{handles.h.Id}.I.getData3D('image', t, 4, colorChannel, getDataOptions));
            STATS2 = regionprops(CC, img, 'PixelValues');
            if sum(ismember(property, 'MinIntensity')) > 0
                calcVal = cellfun(@min, struct2cell(STATS2),'UniformOutput', false);
                [STATS.MinIntensity] = calcVal{:};
            end
            if sum(ismember(property, 'MaxIntensity')) > 0
                calcVal = cellfun(@max, struct2cell(STATS2),'UniformOutput', false);
                [STATS.MaxIntensity] = calcVal{:};
            end
            if sum(ismember(property, 'MeanIntensity')) > 0
                calcVal = cellfun(@mean, struct2cell(STATS2),'UniformOutput', false);
                [STATS.MeanIntensity] = calcVal{:};
            end
            if sum(ismember(property, 'SumIntensity')) > 0
                calcVal = cellfun(@sum, struct2cell(STATS2),'UniformOutput', false);
                [STATS.SumIntensity] = calcVal{:};
            end
            if sum(ismember(property, 'StdIntensity')) > 0
                calcVal = cellfun(@std2, struct2cell(STATS2),'UniformOutput', false);
                [STATS.StdIntensity] = calcVal{:};
            end
        end
        waitbar(0.8,wb);
        % calculate correlation between channels
        prop1 = property(ismember(property, 'Correlation'));
        if ~isempty(prop1)
            img = handles.h.Img{handles.h.Id}.I.getData3D('image', t, 4);
            img1 = squeeze(img(:,:,colorChannel,:));
            img2 = squeeze(img(:,:,colorChannel2,:));
            clear img;
            for object=1:numel(STATS)
                STATS(object).Correlation = corr2(img1(STATS(object).PixelIdxList),img2(STATS(object).PixelIdxList));
            end
        end
        [STATS.TimePnt] = deal(t);  % add time points
        handles.STATS = [handles.STATS orderfields(STATS')];
        waitbar(0.95,wb);
    else    % 2D objects
        if connectivity == 1
            conn = 4;
        else
            conn = 8;
        end;
        
        % calculate statistics in XY plane
        %orientation = 4;
        orientation = handles.h.Img{handles.h.Id}.I.orientation;
        
        if strcmp(frame, '2D, Slice')
            start_id = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
            end_id = start_id;
        else
            start_id = 1;
            end_id = size(handles.h.Img{handles.h.Id}.I.img, orientation);
        end
        
%         property{end+1} = 'PixelIdxList';
%         property{end+1} = 'Centroid';
%         
%         STATS = cell2struct(cell(size(property)), property, 2);
%         STATS = orderfields(handles.STATS);
%         STATS(1) = [];
        
        getDataOptions.t = [t t];
        for lay_id=start_id:end_id
            waitbar((lay_id-start_id)/(end_id-start_id),wb);
            if strcmp(handles.type,'Mask')
                slice = handles.h.Img{handles.h.Id}.I.getFullSlice('mask', lay_id, orientation, NaN, NaN, getDataOptions);
            elseif strcmp(handles.type,'Model')
                slice = handles.h.Img{handles.h.Id}.I.getFullSlice('model', lay_id, orientation, handles.sel_model, NaN, getDataOptions);
            end
            
            customProps = {'EndpointsLength','CurveLengthInUnits','CurveLengthInPixels','HolesArea'};
            shapeProps = {'Solidity', 'Perimeter', 'Orientation', 'MinorAxisLength', 'MajorAxisLength', 'FilledArea', 'Extent', 'EulerNumber',...
                'EquivDiameter', 'Eccentricity', 'ConvexArea', 'Area'};
            intProps = {'SumIntensity','StdIntensity','MeanIntensity','MaxIntensity','MinIntensity'};
            intCustomProps = 'Correlation';
            commonProps = {'PixelIdxList', 'Centroid'};
            
            % get objects
            if ~isempty(property(ismember(property,'HolesArea')));     % calculate curve length in units
                slice = imfill(slice, conn, 'holes') - slice;
            end
            CC = bwconncomp(slice,conn);
            
            if CC.NumObjects == 0
                continue;
            end
            % calculate common properties
            STATS = regionprops(CC, commonProps);
            
            % calculate matlab standard shape properties
            prop1 = property(ismember(property,shapeProps));
            if ~isempty(prop1)
                STATS2 = regionprops(CC, prop1);
                fieldNames = fieldnames(STATS2);
                for i=1:numel(fieldNames)
                    [STATS.(fieldNames{i})] = STATS2.(fieldNames{i});
                end
            end
            
            % detects length between the end points of each object, applicable only to lines
            prop1 = property(ismember(property,'EndpointsLength'));
            if ~isempty(prop1)
                STATS2 = regionprops(CC, 'PixelList');
                for obj=1:numel(STATS2)
                    STATS(obj).EndpointsLength = sqrt(((STATS2(obj).PixelList(1,1) - STATS2(obj).PixelList(end,1))*handles.h.Img{handles.h.Id}.I.pixSize.x)^2 + ...
                        ((STATS2(obj).PixelList(1,2) - STATS2(obj).PixelList(end,2))*handles.h.Img{handles.h.Id}.I.pixSize.y)^2);
                end
                clear STAT2;
            end
            % calculate curve length in pixels
            prop1 = property(ismember(property,'CurveLengthInPixels'));
            if ~isempty(prop1)
                STATS2 = ib_calcCurveLength(slice, [], CC);
                if isstruct(STATS2)
                    [STATS.CurveLengthInPixels] = deal(STATS2.CurveLengthInPixels);
                end
            end
            % calculate curve length in units
            prop1 = property(ismember(property,'CurveLengthInUnits'));     % calculate curve length in units
            if ~isempty(prop1)
                STATS2 = ib_calcCurveLength(slice, handles.h.Img{handles.h.Id}.I.pixSize, CC);
                if isstruct(STATS2)
                    [STATS.CurveLengthInUnits] = deal(STATS2.CurveLengthInUnits);
                end
            end
            
            % calculate Holes Area
            prop1 = property(ismember(property,'HolesArea'));     % calculate curve length in units
            if ~isempty(prop1)
                STATS2 = regionprops(CC, 'Area');
                [STATS.HolesArea] = deal(STATS2.Area);
            end
            
            % calculate intensity properties
            prop1 = property(ismember(property, intProps));
            if ~isempty(prop1)
                STATS2 = regionprops(CC, handles.h.Img{handles.h.Id}.I.getFullSlice('image', lay_id, orientation, colorChannel, NaN, getDataOptions), 'PixelValues');
                if sum(ismember(property, 'MinIntensity')) > 0
                    calcVal = cellfun(@min, struct2cell(STATS2),'UniformOutput', false);
                    [STATS.MinIntensity] = calcVal{:};
                end
                if sum(ismember(property, 'MaxIntensity')) > 0
                    calcVal = cellfun(@max, struct2cell(STATS2),'UniformOutput', false);
                    [STATS.MaxIntensity] = calcVal{:};
                end
                if sum(ismember(property, 'MeanIntensity')) > 0
                    calcVal = cellfun(@mean, struct2cell(STATS2),'UniformOutput', false);
                    [STATS.MeanIntensity] = calcVal{:};
                end
                if sum(ismember(property, 'SumIntensity')) > 0
                    calcVal = cellfun(@sum, struct2cell(STATS2),'UniformOutput', false);
                    [STATS.SumIntensity] = calcVal{:};
                end
                if sum(ismember(property, 'StdIntensity')) > 0
                    calcVal = cellfun(@std2, struct2cell(STATS2),'UniformOutput', false);
                    [STATS.StdIntensity] = calcVal{:};
                end
            end
            % calculate correlation between channels
            prop1 = property(ismember(property, 'Correlation'));
            if ~isempty(prop1)
                img = handles.h.Img{handles.h.Id}.I.getFullSlice('image', lay_id, orientation, 0, NaN, getDataOptions);
                img1 = img(:,:,colorChannel);
                img2 = img(:,:,colorChannel2);
                for object=1:numel(STATS)
                    STATS(object).Correlation = corr2(img1(STATS(object).PixelIdxList),img2(STATS(object).PixelIdxList));
                end
            end
            
            if numel(STATS)>0
                % recalculate pixels' indeces into 3D space
                STATS = arrayfun(@(s) setfield(s, 'PixelIdxList', s.PixelIdxList+img_height*img_width*(lay_id-1)),STATS);
                %for obj_id=1:numel(STATS)
                %    STATS(obj_id).PixelIdxList = STATS(obj_id).PixelIdxList + img_height*img_width*(lay_id-1);
                %end
                
                % add Z-value to the centroid
                %             Centroids = reshape([STATS.Centroid],[2, numel(STATS)])';
                %             Centroids(:,3) = lay_id;
                STATS = arrayfun(@(s) setfield(s,'Centroid',[s.Centroid lay_id]), STATS);
            end
            [STATS.TimePnt] = deal(t);  % add time points
            handles.STATS = [handles.STATS orderfields(STATS')];
        end
    end
end

data = zeros(numel(handles.STATS),4);
if numel(data) ~= 0
    if isfield(handles.STATS, selectedProperty)
        [data(:,2), data(:,1)] = sort(cat(1,handles.STATS.(selectedProperty)),'descend');
    else
        [data(:,2), data(:,1)] = sort(cat(1,handles.STATS.(property{1})),'descend');
    end
    for row = 1:size(data,1)
        pixelId = max([1 floor(numel(handles.STATS(data(row,1)).PixelIdxList)/2)]);  % id of the voxel to get a slice number
        [~, ~, data(row,3)] = ind2sub([handles.h.Img{handles.h.Id}.I.width handles.h.Img{handles.h.Id}.I.height handles.h.Img{handles.h.Id}.I.no_stacks],handles.STATS(data(row,1)).PixelIdxList(pixelId));
    end
    data(:,4) = [handles.STATS(data(:,1)).TimePnt]';
end


waitbar(1,wb);
set(handles.statTable,'Data',data);
data = data(:,2);
%hist(handles.histogram, data, 256);
[a,b] = hist(data, 256);
bar(handles.histogram, b, a);
handles.histLimits = [min(b) max(b)];
histScale_Callback(handles.histScale, eventdata, handles);
grid(handles.histogram);
delete(wb);
guidata(handles.maskStatsDlg, handles);
end

function sortButtonContext_cb(hObject, eventdata, parameter)
handles = guidata(hObject);
if strcmp(parameter, 'object')
    colIndex = 1;
elseif strcmp(parameter, 'value')
    colIndex = 2;
elseif strcmp(parameter, 'slice')
    colIndex = 3;
elseif strcmp(parameter, 'time')
    colIndex = 4;
end
sortBtn_Callback(hObject, eventdata, handles, colIndex);
end

% --- Executes on button press in sortBtn.
function sortBtn_Callback(hObject, eventdata, handles, colIndex)
data = get(handles.statTable,'Data');
if handles.sorting == 1     % ascend sorting
    [data(:,colIndex), index] = sort(data(:,colIndex),'ascend');
    handles.sorting = 0;
else
    [data(:,colIndex), index] = sort(data(:,colIndex),'descend');
    handles.sorting = 1;
end

if colIndex == 2
    data(:,1) = data(index,1);
    data(:,3) = data(index,3);
    data(:,4) = data(index,4);
elseif colIndex == 1
    data(:,2) = data(index,2);
    data(:,3) = data(index,3);
    data(:,4) = data(index,4);
elseif colIndex == 3
    data(:,1) = data(index,1);
    data(:,2) = data(index,2);
    data(:,4) = data(index,4);
elseif colIndex == 4
    data(:,1) = data(index,1);
    data(:,2) = data(index,2);
    data(:,3) = data(index,3);
end
set(handles.statTable,'Data',data);
guidata(handles.maskStatsDlg, handles);
end

function tableContextMenu_cb(hObject, eventdata, parameter)
handles = guidata(hObject);
data = get(handles.statTable,'Data');
if isempty(data); return; end;
if iscell(data(1)); return; end;
if isempty(handles.indices); return; end;

switch parameter
    case 'mean'
        val = mean(data(handles.indices(:,1),2));
        clipboard('copy', val);
        msgbox(sprintf('Mean value for the selected (N=%d) objects: %f\n\nThis value was copied to the clipboard.', numel(handles.indices(:,1)), val),'Mean value','help');
    case 'sum'
        val = sum(data(handles.indices(:,1),2));
        clipboard('copy', val);
        msgbox(sprintf('Sum value for the selected (N=%d) objects: %f\n\nThis value was copied to the clipboard.', numel(handles.indices(:,1)), val),'Mean value','help');
    case 'min'
        val = min(data(handles.indices(:,1),2));
        clipboard('copy', val);
        msgbox(sprintf('Minimal value for the selected (N=%d) objects: %f\n\nThis value was copied to the clipboard.', numel(handles.indices(:,1)), val),'Min value','help');
    case 'max'
        val = max(data(handles.indices(:,1),2));
        clipboard('copy', val);
        msgbox(sprintf('Maximal value for the selected (N=%d) objects: %f\n\nThis value was copied to the clipboard.', numel(handles.indices(:,1)), val),'Max value','help');
    case 'crop'     % crop reagions to files
        val = data(handles.indices(:,1),2);
        result = cropObjectsDlg(handles, handles.h, val);
    case 'hist'
        val = data(handles.indices(:,1),2);
        %nbins = inputdlg(sprintf('Enter number of bins for sorting\n(there are %d entries selected):', numel(val)),'Historgam',1,cellstr('10'));
        nbins = mib_inputdlg(handles.h, sprintf('Enter number of bins for sorting\n(there are %d entries selected):', numel(val)),'Historgam','10');
        if isempty(nbins); return; end;
        nbins = str2double(nbins{1});
        if isnan(nbins); errordlg(sprintf('Please enter a number to define number of bins to sort the data!'), 'Error', 'modal'); return; end;
        parList = get(handles.propertyCombo, 'string');
        parList = parList{get(handles.propertyCombo, 'value')};
        hf = figure(randi(1000));
        hist(val,nbins);
        hHist = findobj(gca,'Type','patch');
        set(hHist,'FaceColor',[0 1 0],'EdgeColor','k');
        lab(1) = xlabel(parList);
        lab(2) = ylabel('Frequency');
        set(lab, 'fontsize', 12);
        set(lab, 'fontweight', 'bold');
        [~, figName] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
        set(hf, 'Name', figName);
        grid;
    case {'newLabel', 'addLabel', 'removeLabel'}
        if strcmp(parameter, 'newLabel')    % clear existing annotations
            handles.h.Img{handles.h.Id}.I.hLabels.clearContents();
        end
        for rowId = 1:numel(handles.indices(:,1))
            val = data(handles.indices(rowId,1),2);
            objId = data(handles.indices(rowId,1), 1);
            labelList(rowId) = {sprintf('%s',  num2str(val))};
            positionList(rowId,:) = [data(handles.indices(rowId,1), 3),  handles.STATS(objId).Centroid(1),  handles.STATS(objId).Centroid(2)];
        end
        if strcmp(parameter, 'removeLabel')
            handles.h.Img{handles.h.Id}.I.hLabels.removeLabels(positionList);   % remove labels by position
        else
            handles.h.Img{handles.h.Id}.I.hLabels.addLabels(labelList, positionList);
        end
        set(handles.h.showAnnotationsCheck, 'value', 1);
        handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
        % update the annotation window
        windowId = findall(0,'tag','ib_labelsGui');
        if ~isempty(windowId)
            hlabelsGui = guidata(windowId);
            cb = get(hlabelsGui.refreshBtn,'callback');
            feval(cb, hlabelsGui.refreshBtn, []);
        end
    otherwise
        statTable_CellSelectionCallback(hObject, eventdata, handles, parameter);
end
end

function highlightBtn_Callback(hObject, eventdata, handles)
value(1) = str2double(get(handles.highlight1,'String'));
value(2) = str2double(get(handles.highlight2,'String'));
value = sort(value);
data = get(handles.statTable,'Data');
indeces = find(data(:,2) >= value(1) & data(:,2) <= value(2));
object_list = data(indeces, 1);
highlightSelection(handles, object_list);
end

function highlightSelection(handles, object_list, mode)
% function copies information about selected objects into Selection layer
if nargin < 3
    mode = get(get(handles.detailsPanel,'selectedobject'),'String');    % what to do with selected objects: Add, Remove, Replace
end

datasetTypeList = get(handles.datasetPopup,'string');
frame = datasetTypeList{get(handles.datasetPopup,'value')};
mode2 = get(get(handles.modePanel,'selectedobject'),'String');      % 2D/3D objects

getDataOptions.blockModeSwitch = 0;
if strcmp(frame,'2D, Slice') && strcmp(mode2,'2D objects') || (strcmp(mode2,'2D objects') && numel(object_list)==1)
    [img_height, img_width] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, getDataOptions);
    %[~,~,currentSlice] = ind2sub([img_height, img_width, img_depth], handles.STATS(object_list(1)).PixelIdxList(1));
    currentSlice = handles.STATS(object_list(1)).Centroid(3);
    currentTime = handles.STATS(object_list(1)).TimePnt;
    getDataOptions.t = [currentTime, currentTime];
    
    selection_mask = zeros(img_height, img_width, 'uint8');
    coef = img_height*img_width*(currentSlice-1); % shift pixel indeces back into 2D space
    for i=1:numel(object_list)
        selection_mask(handles.STATS(object_list(i)).PixelIdxList-coef) = 1;
    end
    if strcmp(mode,'Add')
        selection = handles.h.Img{handles.h.Id}.I.getFullSlice('selection', currentSlice, NaN, NaN, NaN, getDataOptions);
        selection = bitor(selection_mask, selection);   % selection_mask | selection;
        handles.h.Img{handles.h.Id}.I.setFullSlice('selection', selection, currentSlice, NaN, NaN, NaN, getDataOptions);
    elseif strcmp(mode,'Remove')
        curr_selection = handles.h.Img{handles.h.Id}.I.getFullSlice('selection', currentSlice, NaN, NaN, NaN, getDataOptions);
        curr_selection(selection_mask==1) = 0;
        handles.h.Img{handles.h.Id}.I.setFullSlice('selection', curr_selection, currentSlice, NaN, NaN, NaN, getDataOptions);
    elseif strcmp(mode,'Replace')
        if (strcmp(mode2,'2D objects') && numel(object_list)==1)
            handles.h.Img{handles.h.Id}.I.clearSelection();    
        end
        handles.h.Img{handles.h.Id}.I.setFullSlice('selection', selection_mask, currentSlice, NaN, NaN, NaN, getDataOptions);
    end
else
    wb = waitbar(0,'Highlighting selected objects...','Name','Highlighting');
    [img_height, img_width, ~, img_depth] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', NaN, NaN, getDataOptions);
    timePoints = [handles.STATS(object_list).TimePnt];
    [timePointsUnuque, ~, ic] = unique(timePoints);
    index = 1;
    if strcmp(mode,'Replace'); handles.h.Img{handles.h.Id}.I.clearSelection(); end;
    for t=timePointsUnuque
        selection_mask = zeros([img_height, img_width, img_depth],'uint8');
        objects = object_list(ic==index);
        for i=1:numel(objects)
            selection_mask(handles.STATS(objects(i)).PixelIdxList) = 1;
        end
        
        if strcmp(mode,'Add')
            selection = handles.h.Img{handles.h.Id}.I.getData3D('selection', t, NaN, 0, getDataOptions);
            handles.h.Img{handles.h.Id}.I.setData3D('selection', bitor(selection, selection_mask), t, NaN, 0, getDataOptions);    % selection | selection_mask
        elseif strcmp(mode,'Remove')
            selection = handles.h.Img{handles.h.Id}.I.getData3D('selection', t, NaN, 0, getDataOptions);
            selection(selection_mask==1) = 0;
            handles.h.Img{handles.h.Id}.I.setData3D('selection', selection, t, NaN, 0, getDataOptions);
        elseif strcmp(mode,'Replace')
            handles.h.Img{handles.h.Id}.I.setData3D('selection', selection_mask, t, NaN, 0, getDataOptions);
        end
        index = index + 1;
        waitbar(index/numel(timePointsUnuque),wb);
    end
    delete(wb);
end
disp(['MaskStatistics: selected ' num2str(numel(object_list)) ' objects']);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
guidata(handles.maskStatsDlg, handles);
end

% --- Executes on button press in histScale.
function histScale_Callback(hObject, eventdata, handles)
if get(handles.histScale,'Value')
    set(handles.histogram,'YScale','log');
else
    set(handles.histogram,'YScale','linear');
end
end


% --- Executes when selected cell(s) is changed in statTable.
function statTable_CellSelectionCallback(hObject, eventdata, handles, parameter)
% hObject    handle to statTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.statTable,'Data');
if isempty(data);return; end;
if iscell(data(1)); return; end;
if strcmp(parameter, 'skip')    % turn off real time update upon selection of cells
    if isempty(eventdata.Indices); return; end;
    
    % index of the selected object
    newIndex = NaN;
    if ~isempty(handles.indices)
        newIndex = find(ismember(eventdata.Indices(:,1), handles.indices(:,1))==0);
        if size(eventdata.Indices,1) == 1
            newIndex = eventdata.Indices(1,:);
        elseif size(eventdata.Indices,1) > 1
            newIndex = eventdata.Indices(newIndex,:);
        end
    else
        newIndex = eventdata.Indices(1,:);
    end
    
    handles.indices = eventdata.Indices;
    
    %if size(handles.indices,1) == 1
    if size(newIndex,1) == 1 & ~isnan(newIndex)
        % move image-view to the object
        %objId = data(handles.indices(1,1), 1);
        objId = data(newIndex(1,1), 1);
        pixelId = max([1 floor(numel(handles.STATS(objId).PixelIdxList)/2)]);
        handles.h.Img{handles.h.Id}.I.moveView(handles.STATS(objId).PixelIdxList(pixelId));
        
        %set(handles.h.changelayerEdit, 'String', data(handles.indices(1, 1), 3));
        set(handles.h.changelayerEdit, 'String', data(newIndex(1,1), 3));
        changelayerEdit_Callback(0, eventdata, handles.h);
        if handles.h.Img{handles.h.Id}.I.time > 1
            set(handles.h.changeTimeEdit, 'String', data(newIndex(1,1), 4));
            changeTimeEdit_Callback(0, eventdata, handles.h);
        end
    end
    if get(handles.autoHighlightCheck,'value') == 0     % stop here and do not highlight the objects
        guidata(handles.maskStatsDlg, handles);
        return;
    end
    parameter = get(get(handles.detailsPanel,'selectedobject'),'String');
end
%indices = eventdata.Indices;
indices = handles.indices;
indices = unique(indices(:,1));
object_list = data(indices,1);
highlightSelection(handles, object_list, parameter);
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function maskStatsDlg_WindowButtonDownFcn(hObject, eventdata, handles)

xy = get(handles.histogram, 'currentpoint');
seltype = get(handles.maskStatsDlg, 'selectiontype');
ylim = get(handles.histogram,'YLim');
if xy(1,2) > ylim(2); return; end;   % mouse click was too far from the plot
if xy(1,2) < ylim(1); return; end;   % mouse click was too far from the plot
switch seltype
    case 'normal'       % set the min limit
        handles.histLimits(1) = xy(1,1);
    case 'alt'          % set the max limit
        handles.histLimits(2) = xy(1,1);
end
handles.histLimits = sort(handles.histLimits);
set(handles.highlight1,'string',num2str(handles.histLimits(1)));
set(handles.highlight2,'string',num2str(handles.histLimits(2)));
data = get(handles.statTable,'Data');
indeces = find(data(:,2) >= handles.histLimits(1) & data(:,2) <= handles.histLimits(2));
object_list = data(indeces,1);
highlightSelection(handles, object_list);
guidata(handles.maskStatsDlg, handles);

end

% --------------------------------------------------------------------
function statTable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to statTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%statTable_CellSelectionCallback(hObject, eventdata, handles, 'proceed')
end

% --- Executes on button press in objectBasedRadio.
function radioButton_Callback(hObject, eventdata, handles)
intensityBasedStats_Sw = get(handles.intensityBasedRadio,'Value');
object2d_Sw = get(handles.object2dRadio,'Value');
if intensityBasedStats_Sw == 1  % intensity based statistics
    list ={'MinIntensity','MaxIntensity','MeanIntensity','StdIntensity','SumIntensity','Correlation'};
    set(handles.firstChannelCombo, 'Enable', 'on');
    set(handles.propertyCombo, 'value',  handles.intType);
else                            % object based statistics
    set(handles.firstChannelCombo, 'Enable', 'off');
    set(handles.secondChannelCombo, 'Enable', 'off');
    if object2d_Sw == 1
        list ={'Area','ConvexArea','CurveLengthInPixels','CurveLengthInUnits','Eccentricity','EndpointsLength','EquivDiameter','EulerNumber',...
            'Extent','FilledArea','HolesArea','MajorAxisLength','MinorAxisLength','Orientation',...
            'Perimeter','Solidity'};
        set(handles.propertyCombo, 'value',  handles.obj2DType);
    else
        list ={'Area','EndpointsLength','EquatorialEccentricity','FilledArea','HolesArea','MajorAxisLength','MeridionalEccentricity','SecondAxisLength','ThirdAxisLength'};
        set(handles.propertyCombo, 'value',  handles.obj3DType);
    end
end
%set(handles.propertyCombo,'Value',1);
set(handles.propertyCombo,'String',list);
set(hObject, 'Value', 1);

if strcmp(get(hObject, 'tag'), 'object2dRadio') || strcmp(get(hObject, 'tag'), 'object3dRadio')
    handles.properties = {'Area'};  % update handles.properties
    if object2d_Sw  % update handles.obj3d
        handles.obj3d = 0;
    else
        handles.obj3d = 1;
    end
    set(handles.multipleCheck, 'value', 0);
    set(handles.multipleBtn, 'enable', 'off');
end

if get(handles.multipleCheck, 'value')
    propertyCombo_Callback(handles.objectBasedRadio, eventdata, handles);
end

guidata(handles.maskStatsDlg, handles);
end


% --- Executes on button press in exportButton.
function exportButton_Callback(hObject, eventdata, handles)
% export Statistics to Matlab or Excel
if ~isdeployed
    choice =  questdlg('Would you like to save results?','Export','Save as...','Export to Matlab','Cancel','Save as...');
    if strcmp(choice,'Cancel')    % cancel
        return;
    end
else
    choice = 'Save as...';
end

datasetTypeList = get(handles.datasetPopup,'string');
OPTIONS.frame = datasetTypeList{get(handles.datasetPopup,'value')};
OPTIONS.mode = get(get(handles.modePanel,'selectedobject'),'String');   % 2d/3d objects
connectivityValue = get(handles.connectivityCombo,'Value');   % if 1: connectivity=4(2d) and 6(3d), if 2: 8(2d)/26(3d)
connectivityList = get(handles.connectivityCombo,'String');   % if 1: connectivity=4(2d) and 6(3d), if 2: 8(2d)/26(3d)
OPTIONS.connectivity = connectivityList{connectivityValue};   % if 1: connectivity=4(2d) and 6(3d), if 2: 8(2d)/26(3d)
OPTIONS.colorChannel = get(handles.firstChannelCombo,'Value');
OPTIONS.type = handles.type;
OPTIONS.filename = handles.h.Img{handles.h.Id}.I.img_info('Filename');
if strcmp(handles.type,'Model')
    OPTIONS.model_fn = handles.h.Img{handles.h.Id}.I.model_fn;
    OPTIONS.material_id = sprintf('%d (%s)', handles.sel_model, handles.h.Img{handles.h.Id}.I.modelMaterialNames{handles.sel_model});
else
    OPTIONS.mask_fn = handles.h.Img{handles.h.Id}.I.maskImgFilename;
end

if strcmp(OPTIONS.frame, '2D, Slice')
    OPTIONS.slicenumber = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
else
    OPTIONS.slicenumber = 0;
end

%warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');    % switch off warnings for latex
curInt = get(0, 'DefaulttextInterpreter');
set(0, 'DefaulttextInterpreter', 'none');

if strcmp(choice,'Export to Matlab')
    disp('''IM_stats'' and ''IM_options'' structures with results have been created in the Matlab workspace');
    assignin('base','IM_options',OPTIONS);
    assignin('base','IM_stats',handles.STATS);
elseif strcmp(choice,'Save as...')
    fn_out = handles.h.Img{handles.h.Id}.I.img_info('Filename');
    if isempty(fn_out)
        fn_out = handles.h.mypath;
    else
        [fn_out, name, ~] = fileparts(fn_out);
        fn_out = fullfile(fn_out, [name '_analysis']);
    end
    [filename, path, filterIndex] = uiputfile(...
        {'*.xls;',  'Excel format (*.xls)'; ...
        '*.mat;',  'Matlab format (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Save as...',fn_out);
    if isequal(filename,0); return; end;
    fn = [path filename];
    wb = waitbar(0,sprintf('%s\nPlease wait...',fn),'Name','Saving the results','WindowStyle','modal');
    if exist(fn,'file') == 2;
        %choice2 =  questdlg('Overwrite?','File already exist','Yes','Cancel','Yes');
        %if strcmp(choice2,'Cancel');    return;        end;
        delete(fn);  % delete exising file
    end
    waitbar(0.2,wb);
    if filterIndex == 2     % save as mat file
        STATS = handles.STATS; %#ok<NASGU>
        save(fn, 'OPTIONS','STATS');
    elseif filterIndex == 1     % save as Excel file
        STATS = handles.STATS;
        warning off MATLAB:xlswrite:AddSheet
        % Sheet 1
        s = {'Quantification Results'};
        s(2,1) = {['Image filename: ' handles.h.Img{handles.h.Id}.I.img_info('Filename')]};
        if strcmp(handles.type,'Model')
            s(3,1) = {['Model filename: ' OPTIONS.model_fn]};
            s(3,9) = {sprintf('Material ID: %d (%s)', handles.sel_model, handles.h.Img{handles.h.Id}.I.modelMaterialNames{handles.sel_model})};
        else
            if ~isnan(handles.h.Img{handles.h.Id}.I.maskImgFilename)
                s(3,1) = {['Mask filename: ' handles.h.Img{handles.h.Id}.I.maskImgFilename]};
            end
        end
        fieldNames = fieldnames(handles.h.Img{handles.h.Id}.I.pixSize);
        s(4,1) = {'Pixel size and units:'};
        for field=1:numel(fieldNames)
            s(4,field*2-1+1) = fieldNames(field);
            s(4,field*2+1) = {handles.h.Img{handles.h.Id}.I.pixSize.(fieldNames{field})};
        end
        start=8;
        s(6,1) = {'Results:'};
        s(7,1) = {'ObjID'};
        s(7,3) = {'Centroid'};
        s(8,2) = {'X'};
        s(8,3) = {'Y'};
        s(8,4) = {'Z'};
        s(7,5) = {'TimePnt'};
        noObj = numel(STATS);
        s(start+1:start+noObj,1) = num2cell(1:noObj);
        s(start+1:start+noObj,2:4) = num2cell(cat(1,STATS.Centroid));
        s(start+1:start+noObj,5) = num2cell(cat(1,STATS.TimePnt));
        
        STATS = rmfield(STATS, 'Centroid');
        STATS = rmfield(STATS, 'PixelIdxList');
        STATS = rmfield(STATS, 'TimePnt');
        
        fieldNames = fieldnames(STATS);
        s(7,6:5+numel(fieldNames)) = fieldNames;
        for id=1:numel(fieldNames)
            s(start+1:start+noObj,5+id) = num2cell(cat(1,STATS.(fieldNames{id})));
        end
        
        %         for field=1:numel(fieldNames)
        %             if strcmp(fieldNames(field),'data'); continue; end;
        %             s(6+field-1,3) = fieldNames(field);
        %             s(6+field-1,4) = {STATS.(fieldNames{field})};
        %         end
        %
        %         s(6+field, 1) = {'Object id'};
        %         s(6+field, 2) = {[STATS.property ', px']};
        %         s(6+field+1:6+field+1+size(STATS.data,1), 1:2) = {STATS.data'};
        %
        %         for ind = 1:size(STATS.data,1)
        %             s(6+field+ind, 1) = {STATS.data(ind,1)};
        %             s(6+field+ind, 2) = {STATS.data(ind,2)};
        %         end
        waitbar(0.7,wb);
        xlswrite2(fn, s, 'Results', 'A1');
    end
    waitbar(1,wb);
    delete(wb);
    disp(['im_browser: statistics saved to ' fn]);
end
set(0, 'DefaulttextInterpreter', curInt);
end


% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_gui_menu_mask_statistics.html'), '-helpbrowser');
end


% --- Executes on selection change in propertyCombo.
function propertyCombo_Callback(hObject, eventdata, handles)
list = get(handles.propertyCombo,'String');
value = get(handles.propertyCombo,'Value');
if strcmp(list{value},'Correlation')
    set(handles.secondChannelCombo, 'Enable', 'on');
else
    set(handles.secondChannelCombo, 'Enable', 'off');
    if strcmp(list{value},'EndpointsLength') || strcmp(list{value},'CurveLengthInUnits') || strcmp(list{value},'CurveLengthInPixels')
        if get(handles.connectivityCombo, 'value') == 1
            msgbox('The connectivity parameter was changed from 4 to 8!','Connectivity changed','warn','modal')
            set(handles.connectivityCombo, 'value', 2);
        end
    end
    
    if get(handles.objectBasedRadio, 'value')
        if get(handles.object2dRadio, 'value')
            handles.obj2DType = get(handles.propertyCombo, 'value');
        else
            handles.obj3DType = get(handles.propertyCombo, 'value');
        end
    else
        handles.intType = get(handles.propertyCombo, 'value');
    end
end
selectedProperty = list{value};
if get(handles.multipleCheck, 'value') && isfield(handles, 'STATS')
    % update table if possible
    if isfield(handles.STATS, selectedProperty)
        data = zeros(numel(handles.STATS),4);
        if numel(data) ~= 0
            [data(:,2) data(:,1)] = sort(cat(1,handles.STATS.(selectedProperty)),'descend');
            for row = 1:size(data,1)
                pixelId = max([1 floor(numel(handles.STATS(data(row,1)).PixelIdxList)/2)]);  % id of the voxel to get a slice number
                [~, ~, data(row,3)] = ind2sub([handles.h.Img{handles.h.Id}.I.width handles.h.Img{handles.h.Id}.I.height handles.h.Img{handles.h.Id}.I.no_stacks ],handles.STATS(data(row,1)).PixelIdxList(pixelId));
            end
            data(:, 4) = [handles.STATS(data(:,1)).TimePnt];
        end
        set(handles.statTable,'Data',data);
        data = data(:,2);
        %hist(handles.histogram, data, 256);
        [a,b] = hist(data, 256);
        bar(handles.histogram, b, a);
        handles.histLimits = [min(b) max(b)];
        histScale_Callback(handles.histScale, eventdata, handles);
        grid(handles.histogram);
    else
        data = [];
        set(handles.statTable,'Data',data);
    end
end

if get(handles.multipleCheck, 'value') == 0
    handles.properties = cellstr(selectedProperty);
end

% Update handles structure
guidata(hObject, handles);
end

function multipleCheck_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.multipleBtn, 'enable','on');
else
    set(handles.multipleBtn, 'enable','off');
    contents = get(handles.propertyCombo,'String');
    property = contents{get(handles.propertyCombo,'Value')};
    handles.properties = cellstr(strtrim(property));
    guidata(hObject, handles);
end
end

% --- Executes on button press in multipleBtn.
function multipleBtn_Callback(hObject, eventdata, handles)
obj3d = 1;
if get(handles.object2dRadio, 'value') == 1
    obj3d = 0;
end
res = mib_MaskStatsProps(handles.properties, obj3d);
if ~isempty(res)
    handles.properties = sort(res);
    customProps = {'CurveLengthInUnits','CurveLengthInPixels','EndpointsLength'};
    if sum(ismember(handles.properties, customProps)) > 1
        if get(handles.connectivityCombo, 'value') == 1
            msgbox('The connectivity parameter was changed from 4 to 8!','Connectivity changed','warn','modal')
            set(handles.connectivityCombo, 'value', 2);
        end
    end
    
    list = get(handles.propertyCombo,'string');
    index = find(ismember(list, handles.properties(1))==1);
    if isempty(index)
        if get(handles.objectBasedRadio,'value')    % switch from the object to intensity mode
            set(handles.intensityBasedRadio, 'value', 1);
        else                                        % switch from the intensity to the object mode
            set(handles.objectBasedRadio, 'value', 1);
        end
        radioButton_Callback(handles.objectBasedRadio, eventdata, handles);
        list = get(handles.propertyCombo,'string');
        index = find(ismember(list, handles.properties(1))==1);
    else
        set(handles.propertyCombo,'value', index);
    end
end
guidata(handles.maskStatsDlg, handles);
end
