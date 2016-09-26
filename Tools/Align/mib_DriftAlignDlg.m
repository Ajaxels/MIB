function varargout = mib_DriftAlignDlg(varargin)
% MIB_DRIFTALIGNDLG M-file for mib_driftaligndlg.fig
%      MIB_DRIFTALIGNDLG by itself, creates a new MIB_DRIFTALIGNDLG or raises the
%      existing singleton*.
%
%      H = MIB_DRIFTALIGNDLG returns the handle to a new MIB_DRIFTALIGNDLG or the handle to
%      the existing singleton*.
%
%      MIB_DRIFTALIGNDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIB_DRIFTALIGNDLG.M with the given input arguments.
%
%      MIB_DRIFTALIGNDLG('Property','Value',...) creates a new MIB_DRIFTALIGNDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mib_DriftAlignDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mib_DriftAlignDlg_OpeningFcn via varargin.
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

% Edit the above text to modify the response to help mib_driftaligndlg

% Last Modified by GUIDE v2.5 15-Sep-2016 18:13:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mib_DriftAlignDlg_OpeningFcn, ...
    'gui_OutputFcn',  @mib_DriftAlignDlg_OutputFcn, ...
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

% --- Executes just before mib_driftaligndlg is made visible.
function mib_DriftAlignDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mib_driftaligndlg (see VARARGIN)

% Choose default command line output for mib_driftaligndlg
handles.output = 'Continue';

% set size of the window, because in Guide it is bigger
winPos = get(handles.mib_DriftAlignDlg, 'position');
set(handles.mib_DriftAlignDlg, 'position', [winPos(1) winPos(2) 358 winPos(4)]);

handles.I = varargin{1};    % get imageData class with the image to align
if nargin < 5
    handles.Font.FontName = get(handles.text1,'FontName');
    handles.Font.FontUnits = 'points';
    handles.Font.FontSize = 8;
else
    handles.Font = varargin{2};  % get main window preferences to resize the fonts
end

% radio button callbacks
set(handles.alignRadio, 'SelectionChangeFcn', @modeRadioButton_Callback);

height = size(handles.I.img,1);
width = size(handles.I.img,2);
handles.varname = 'I';  % variable for import
fn = handles.I.img_info('Filename');
[pathstr, name, ext] = fileparts(fn);
handles.pathstr = pathstr;

% define variables to store the shifts
handles.shiftsX = [];
handles.shiftsY = [];
handles.maskOrSelection = 'mask';   % variable to keep information about type of layer used for alignment

handles.img_info = containers.Map;   % img_info containers.Map from the getImageMetadata
handles.files = struct();      % files structure from the getImageMetadata
handles.pixSize = struct();    % pixSize structure from the getImageMetadata

set(handles.existingFnText1,'String', pathstr);
set(handles.existingFnText1,'Tooltip',handles.I.img_info('Filename'));
set(handles.existingFnText2,'String',[name '.' ext]);
set(handles.existingFnText2,'String',[name '.' ext]);
set(handles.existingFnText2,'Tooltip',handles.I.img_info('Filename'));
str2 = sprintf('%d x %d x %d', width, height, size(handles.I.img,4));
set(handles.existingDimText,'String',str2);
set(handles.existingPixText2,'String',sprintf('Pixel size, %s:', handles.I.pixSize.units));
str2 = sprintf('%f x %f x %f', handles.I.pixSize.x, handles.I.pixSize.y, handles.I.pixSize.z);
set(handles.existingPixText,'String',str2);

set(handles.pathEdit, 'String', pathstr);
set(handles.saveShiftsXYpath, 'String', fullfile(pathstr, [name '_align.coefXY']));
set(handles.loadShiftsXYpath, 'String', fullfile(pathstr, [name '_align.coefXY']));

% fill default entries for subwindow
set(handles.searchXminEdit, 'String', num2str(floor(width/2)-floor(width/4)));
set(handles.searchYminEdit, 'String', num2str(floor(height/2)-floor(height/4)));
set(handles.searchXmaxEdit, 'String', num2str(floor(width/2)+floor(width/4)));
set(handles.searchYmaxEdit, 'String', num2str(floor(height/2)+floor(height/4)));

% updating color channel popup
colors = size(handles.I.img,3);
colorList = cell([colors,1]);
for i=1:colors
    colorList{i} = sprintf('Ch %d', i);
end
set(handles.colChPopup, 'String', colorList);

% setting panels
panelPosition = get(handles.saveShiftsPanel,'Position');
panelParent = get(handles.saveShiftsPanel,'Parent');

panelPosition = get(handles.secondDatasetPanel,'Position');
panelParent = get(handles.secondDatasetPanel,'Parent');
set(handles.currStackOptionsPanel,'Parent',panelParent);
set(handles.currStackOptionsPanel,'position',panelPosition);
set(handles.currStackOptionsPanel,'visible','on');

% update font and size
if get(handles.existingFnText1, 'fontsize') ~= handles.Font.FontSize ...
        || ~strcmp(get(handles.existingFnText1, 'fontname'), handles.Font.FontName)
    ib_updateFontSize(handles.mib_DriftAlignDlg, handles.Font);
end

% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.mib_DriftAlignDlg);

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
set(handles.mib_DriftAlignDlg,'WindowStyle','modal')

% UIWAIT makes mib_driftaligndlg wait for user response (see UIRESUME)
uiwait(handles.mib_DriftAlignDlg);
end

% --- Outputs from this function are returned to the command line.
function varargout = mib_DriftAlignDlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if strcmp(handles.output, 'Continue')
    varargout{1} = handles.I;
else
    varargout{1} = [];
end

% The figure can be deleted now
delete(handles.mib_DriftAlignDlg);
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
tic
parameters.waitbar = waitbar(0,'Please wait...','Name', 'Alignment and drift correction');

handles.output = get(hObject,'String');
pathIn = get(handles.pathEdit,'String');
colorCh = get(handles.colChPopup, 'Value');

% get color to fill background
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

parameters.refFrame = get(handles.correlateWithPopup, 'value')-1;
if parameters.refFrame == 2
    parameters.refFrame = -str2double(get(handles.stepEditbox, 'string'));
end
   
algorithmText = get(handles.methodPopup,'String');
parameters.method = algorithmText{get(handles.methodPopup,'value')};

if get(handles.singleStacksModeRadio,'value')   % align the currently opened dataset
    if strcmp(parameters.method, 'Single landmark point')
        optionsGetData.blockModeSwitch = 0;
        handles.shiftsX = zeros(1, size(handles.I.img, 4));
        handles.shiftsY = zeros(1, size(handles.I.img, 4));
        
        shiftX = 0;     % shift vs 1st slice in X
        shiftY = 0;     % shift vs 1st slice in Y
        STATS1 = struct([]);
        for layer=2:size(handles.I.img, 4)
            if isempty(STATS1)
                prevLayer = handles.I.getData2D('selection', layer-1, NaN, 4, NaN, optionsGetData);
                STATS1 = regionprops(prevLayer, 'Centroid');
            end
            if ~isempty(STATS1)
                currLayer = handles.I.getData2D('selection', layer, NaN, 4, NaN, optionsGetData);
                STATS2 = regionprops(currLayer, 'Centroid');
                if ~isempty(STATS2)  % no second landmark found
                    shiftX = shiftX + round(STATS1.Centroid(1) - STATS2.Centroid(1));
                    shiftY = shiftY + round(STATS1.Centroid(2) - STATS2.Centroid(2));
                    handles.shiftsX(layer:end) = shiftX;
                    handles.shiftsY(layer:end) = shiftY;
                    STATS1 = STATS2;
                else
                    STATS1 = struct([]);
                end
            else
                STATS1 = struct([]);
            end
        end
        
        toc
        
        figure(155);
        plot(1:length(handles.shiftsX),handles.shiftsX,1:length(handles.shiftsY),handles.shiftsY);
        legend('Shift X', 'Shift Y');
        grid;
        xlabel('Frame number');
        ylabel('Displacement');
        title('Detected drifts');
       
        if isdeployed == 0
            assignin('base', 'shiftX', handles.shiftsX);
            assignin('base', 'shiftY', handles.shiftsY);
            fprintf('Shifts between images were exported to the Matlab workspace (shiftX, shiftY)\nThese variables can be modified and saved to a disk using the following command:\nsave ''myfile.mat'' shiftX shiftY;\n');
        end
        
        fixDrifts = questdlg('Align the stack using detected displacements?','Fix drifts','Yes','No','Yes');
        if strcmp(fixDrifts, 'No')
            delete(parameters.waitbar);
            return;
        end
        delete(155);
        
        % do alignment
        handles.I.clearSelection();
        handles.I.img = mib_crossShiftStack(handles.I.img, handles.shiftsX, handles.shiftsY, parameters);
    elseif strcmp(parameters.method, 'Three landmark points')
        optionsGetData.blockModeSwitch = 0;
        selection = handles.I.getData3D('selection', NaN, 4, NaN, optionsGetData);
        %handles.shiftsXY = zeros(2,size(selection, 3));
        %shiftX = 0;     % shift vs 1st slice in X
        %shiftY = 0;     % shift vs 1st slice in Y
        
        handles.shiftsX = zeros(1, size(selection, 3));
        handles.shiftsY = zeros(1, size(selection, 3));
        
        layer = 1;
        while layer <= size(selection, 3)-1
            if sum(sum(selection(:,:,layer))) > 0   % landmark is found
                CC1 = bwconncomp(selection(:,:,layer));
                if CC1.NumObjects < 3; continue; end;  % require 3 points
                CC2 = bwconncomp(selection(:,:,layer+1));
                if CC2.NumObjects < 3; layer = layer + 1; continue; end;  % require 3 points
                
                STATS1 = regionprops(CC1, 'Centroid');
                STATS2 = regionprops(CC2, 'Centroid');
                
                % find distances between centroids of material 1 and material 2
                X1 =  reshape([STATS1.Centroid],[2 numel(STATS1)])';     % centroids matrix, c1([x,y], pointNumber)
                X2 =  reshape([STATS2.Centroid],[2 numel(STATS1)])';
                idx = findMatchingPairs(X2, X1);
                
                output = reshape([STATS1.Centroid],[2 numel(STATS1)])';     % main dataset points, centroids matrix, c1(pointNumber, [x,y])
                for objId = 1:numel(STATS2)
                    input(objId, :) = STATS2(idx(objId)).Centroid; % the second dataset points, centroids matrix, c1(pointNumber, [x,y])
                end
                
                % define background color
                if isnumeric(parameters.backgroundColor)
                    backgroundColor = options.backgroundColor;
                else
                    if strcmp(parameters.backgroundColor,'black')
                        backgroundColor = 0;
                    elseif strcmp(parameters.backgroundColor,'white')
                        backgroundColor = intmax(class(handles.I.img));
                    else
                        backgroundColor = mean(mean(mean(mean( handles.I.img(:,:,colorCh,layer)))));
                    end
                end
                
                tform2 = maketform('affine', input, output);
                [T, xdata, ydata] = imtransform(handles.I.img(:,:,:,layer+1:end), tform2, 'bicubic', 'FillValues', double(backgroundColor));
                if xdata(1) < 1
                    handles.shiftsX = floor(xdata(1));
                else
                    handles.shiftsX = ceil(xdata(1));
                end
                if ydata(1) < 1
                    handles.shiftsY = floor(ydata(1))-1;
                else
                    handles.shiftsY = ceil(ydata(1))-1;
                end
                
                
%                 %tform2 = fitgeotrans(output, input, 'affine');
%                 tform2 = fitgeotrans(output, input, 'NonreflectiveSimilarity');
%                 
%                 [T, RB] = imwarp(handles.I.img(:,:,:,layer+1:end), tform2, 'bicubic', 'FillValues', backgroundColor);
%                 if RB.XWorldLimits(1) <  1
%                     handles.shiftsX = floor(RB.XWorldLimits(1));
%                 else
%                     handles.shiftsX = ceil(RB.XWorldLimits(1));
%                 end
%                 if RB.YWorldLimits(1) < 1
%                     handles.shiftsY = floor(RB.YWorldLimits(1))-1;
%                 else
%                     handles.shiftsY = ceil(RB.YWorldLimits(1))-1;
%                 end
                
                [img, bbShiftXY] = mib_crossShiftStacks(handles.I.img(:,:,:,1:layer), T, handles.shiftsX, handles.shiftsY, parameters);
                if isempty(img);   return; end;
                handles.I.img = img;
                
                layerId = layer;
                layer = size(selection, 3);
            end
            layer = layer + 1;
        end
    else        % standard alignement
        parameters.step = str2double(get(handles.stepEditbox,'string'));
        
        % calculate shifts
        if isempty(handles.shiftsX)
            if get(handles.subWindowCheck,'value') == 1
                x1 = str2double(get(handles.searchXminEdit,'String'));
                y1 = str2double(get(handles.searchYminEdit,'String'));
                x2 = str2double(get(handles.searchXmaxEdit,'String'));
                y2 = str2double(get(handles.searchYmaxEdit,'String'));
                I = squeeze(handles.I.img(y1:y2, x1:x2, colorCh, :, handles.I.slices{5}(1)));
            else
                I = squeeze(handles.I.img(:, :, colorCh, :, handles.I.slices{5}(1)));
            end
            
            if get(handles.maskCheck,'value') == 1
                waitbar(0, parameters.waitbar, sprintf('Extracting masked areas\nPlease wait...'));
                
                getDataOptions.blockModeSwitch = 0;
                %intensityShift =  mean(I(:));   % needed for better correlation of images of different size
                img = zeros(size(I), class(I));% + intensityShift;
                bb = nan([size(I, 3), 4]);
                
                for slice = 1:size(I, 3)
                    mask = handles.I.getData2D(handles.maskOrSelection, slice, NaN, 4, NaN, getDataOptions);
                    stats = regionprops(mask, 'BoundingBox');
                    if numel(stats) == 0; continue; end;
                    
                    currBB = floor(stats.BoundingBox);
                    mask = mask(currBB(2):currBB(2)+currBB(4)-1, currBB(1):currBB(1)+currBB(3)-1);
                    currImg = I(currBB(2):currBB(2)+currBB(4)-1, currBB(1):currBB(1)+currBB(3)-1, slice);
                    intensityShift = mean(mean(currImg));  % needed for better correlation of images of different size
                    currImg(~mask) = intensityShift;
                    img(:, :, slice) = intensityShift;
                    img(1:currBB(4), 1:currBB(3), slice) = currImg;
                    
                    bb(slice, :) = currBB;
                    waitbar(slice/size(I, 3), parameters.waitbar);
                end
                sliceIndices = find(~isnan(bb(:,1)));   % find indices of slices that have mask
                if isempty(sliceIndices)
                    delete(parameters.waitbar);
                    errordlg(sprintf('No %s areas were found!',handles.maskOrSelection),sprintf('Missing %s',handles.maskOrSelection));
                    return;
                end
                I = img(1:max(bb(:, 4)), 1:max(bb(:, 3)), sliceIndices);
                clear img;
            end
            
            if get(handles.gradientCheckBox, 'value')
                waitbar(0, parameters.waitbar, sprintf('Calculating intensity gradient for color channel %d ...', colorCh));
                
                img = zeros(size(I), class(I));
                % generate gradient image
                hy = fspecial('sobel');
                hx = hy';
                for slice = 1:size(I, 3)
                    Im = I(:,:,slice);   % get a slice
                    Iy = imfilter(double(Im), hy, 'replicate');
                    Ix = imfilter(double(Im), hx, 'replicate');
                    img(:,:,slice) = sqrt(Ix.^2 + Iy.^2);
                    waitbar(slice/size(I, 3), parameters.waitbar);
                end
                I = img;
                clear img;
            end
            
            % calculate drifts
            [shiftX, shiftY] = mib_calcShifts(I, parameters);
            if isempty(shiftX); return; end;
            
            if get(handles.maskCheck,'value') == 1
                % check for missing mask slices
                if length(sliceIndices) ~= size(handles.I.img, 4)
                    shX = zeros([size(handles.I.img, 4), 1]);
                    shY = zeros([size(handles.I.img, 4), 1]);
                    
                    index = 1;
                    breakBegin = 0;
                    for i=2:size(handles.I.img, 4)
                        if isnan(bb(i,1))
                            if breakBegin == 0;
                                breakBegin = 1;
                                shX(i) = shX(i-1);
                                shY(i) = shY(i-1);
                            else
                                shX(i) = shX(i-1);
                                shY(i) = shY(i-1);
                            end
                        else
                            if breakBegin == 1
                                shX(i) = shX(i-1);
                                shY(i) = shY(i-1);
                                breakBegin = 0;
                            else
                                shX(i) = shX(i-1) + shiftX(index)-shiftX(index-1)-(bb(i,1)-bb(i-1,1));
                                shY(i) = shY(i-1) + shiftY(index)-shiftY(index-1)-(bb(i,2)-bb(i-1,2));
                            end
                            index = index + 1;
                        end
                    end
                    shiftX = shX;
                    shiftY = shY;
                else
                    difX = [0; diff(bb(:,1))];
                    difX = cumsum(difX);
                    shiftX = shiftX - difX;
                    difY = [0; diff(bb(:,2))];
                    difY = cumsum(difY);
                    shiftY = shiftY - difY;
                end
            end
            
%             % ---- start of drift problems correction
            figure(155);
            %subplot(2,1,1);
            plot(1:length(shiftX),shiftX,1:length(shiftY),shiftY);
            legend('Shift X', 'Shift Y');
            grid;
            xlabel('Frame number');
            ylabel('Displacement');
            title('Before drift correction');
%             
%             fixDrifts = questdlg('Fix the drifts?','Fix drifts','No','Yes','No');
%             if strcmp(fixDrifts, 'Yes')
%                 diffX = abs(diff(shiftX));
%                 diffY = abs(diff(shiftY));
%                 cutX = mean(diffX)*4;
%                 cutY = mean(diffY)*4;
%                 
%                 indX = find(diffX > cutX);
%                 indY = find(diffY > cutY);
%                 
%                 windvValue = 3;
%                 shiftX2 = round(windv(shiftX,windvValue+2));
%                 shiftY2 = round(windv(shiftY,windvValue+2));
%                 
%                 for i=1:length(indX)
%                     shiftX2(indX(i)) = shiftX2(indX(i)-1);
%                 end
%                 for i=1:length(indY)
%                     shiftY2(indY(i)) = shiftY2(indY(i)-1);
%                 end
%                 
%                 shiftX2 = round(windv(shiftX2, windvValue));
%                 shiftY2 = round(windv(shiftY2, windvValue));
%                 
%                 subplot(2,1,2);
%                 plot(1:length(shiftX2),shiftX2,1:length(shiftY2),shiftY2);
%                 legend('Shift X', 'Shift Y');
%                 title('After drift correction');
%                 grid;
%                 xlabel('Frame number');
%                 ylabel('Displacement');
%                 
%                 fixDrifts = questdlg('Would you like to use the fixed drifts?','Use fixed drifts?','Use fixed','Use not fixed','Cancel','Use fixed');
%                 if strcmp(fixDrifts, 'Cancel');
%                     if isdeployed == 0
%                         assignin('base', 'shiftX', shiftX);
%                         assignin('base', 'shiftY', shiftY);
%                         disp('Shifts between images were exported to the Matlab workspace (shiftX, shiftY)');
%                     end
%                     return;
%                 end;
%                 
%                 if strcmp(fixDrifts, 'Use fixed');
%                     shiftX = shiftX2;
%                     shiftY = shiftY2;
%                 end;
%             end
%             delete(155);    % close the figure window
%             
%             % ---- end of drift problems correction
            
            if isdeployed == 0
                assignin('base', 'shiftX', shiftX);
                assignin('base', 'shiftY', shiftY);
                fprintf('Shifts between images were exported to the Matlab workspace (shiftX, shiftY)\nThese variables can be modified and saved to a disk using the following command:\nsave ''myfile.mat'' shiftX shiftY;\n');
            end
            
            fixDrifts = questdlg('Align the stack using detected displacements?','Fix drifts','Yes','No','Yes');
            if strcmp(fixDrifts, 'No')
                delete(parameters.waitbar);
                return;
            end
            delete(155);

            handles.shiftsX = shiftX;
            handles.shiftsY = shiftY;
        end
        
        img = mib_crossShiftStack(handles.I.img, handles.shiftsX, handles.shiftsY, parameters);
        if isempty(img); return; end;
        handles.I.img = img;
    end
    
    handles.I.height = size(handles.I.img, 1);
    handles.I.width = size(handles.I.img, 2);
    handles.I.slices{1} = [1, handles.I.height];
    handles.I.slices{2} = [1, handles.I.width];
    handles.I.slices{3} = 1:size(handles.I.img,3);
    handles.I.slices{4} = [1, 1];
    handles.I.slices{5} = [1, 1];
    
    % calculate shift of the bounding box
    maxXshift =  min(handles.shiftsX);   % maximal X shift in pixels vs the first slice
    maxYshift = min(handles.shiftsY);   % maximal Y shift in pixels vs the first slice
    maxXshift = maxXshift*handles.I.pixSize.x;  % X shift in units vs the first slice
    maxYshift = maxYshift*handles.I.pixSize.y;  % Y shift in units vs the first slice
    handles.I.updateBoundingBox(NaN, [maxXshift, maxYshift, 0]);
    handles.I.updateImgInfo(sprintf('Aligned using %s; relative to %d', algorithmText{get(handles.methodPopup,'value')}, parameters.refFrame));
    
    % aligning the service layers: mask, selection, model
    % force background color to be black for the service layers
    % if the background needs to be selected, the parameters.backgroundColor = 'white'; should be used for selection layer
    parameters.backgroundColor = 0;
    parameters.modelSwitch = 1;
    
    if ~strcmp(handles.I.model_type, 'uint6')
        if handles.I.modelExist
            waitbar(0, parameters.waitbar, sprintf('Aligning model\nPlease wait...'));
            if ~strcmp(parameters.method, 'Three landmark points')
                handles.I.model = mib_crossShiftStack(handles.I.model, handles.shiftsX, handles.shiftsY, parameters);
            else
                T = imtransform(handles.I.model(:,:,layerId+1:end), tform2, 'nearest');
                handles.I.model = mib_crossShiftStacks(handles.I.model(:,:,1:layerId), T, handles.shiftsX, handles.shiftsY, parameters);                
            end
        end
        if handles.I.maskExist
            waitbar(0, parameters.waitbar, sprintf('Aligning mask...\nPlease wait...'));
            if ~strcmp(parameters.method, 'Three landmark points')
                handles.I.maskImg = mib_crossShiftStack(handles.I.maskImg, handles.shiftsX, handles.shiftsY, parameters);
            else
                T = imtransform(handles.I.maskImg(:,:,layerId+1:end), tform2, 'nearest');
                handles.I.maskImg = mib_crossShiftStacks(handles.I.maskImg(:,:,1:layerId), T, handles.shiftsX, handles.shiftsY, parameters);                
            end
        end
        if  ~isnan(handles.I.selection(1))
            waitbar(0, parameters.waitbar, sprintf('Aligning selection...\nPlease wait...'));
            if ~strcmp(parameters.method, 'Three landmark points')
                handles.I.selection = mib_crossShiftStack(handles.I.selection, handles.shiftsX, handles.shiftsY, parameters);
            else
                T = imtransform(handles.I.selection(:,:,layerId+1:end), tform2, 'nearest');
                handles.I.selection = mib_crossShiftStacks(handles.I.selection(:,:,1:layerId), T, handles.shiftsX, handles.shiftsY, parameters);                
            end
        end
    else
        waitbar(0, parameters.waitbar, sprintf('Aligning Selection, Mask, Model...\nPlease wait...'));
        if ~strcmp(parameters.method, 'Three landmark points')
            handles.I.model = mib_crossShiftStack(handles.I.model, handles.shiftsX, handles.shiftsY, parameters);
        else
            %T = imwarp(handles.I.model(:,:,layerId+1:end), tform2, 'nearest', 'FillValues', parameters.backgroundColor);
            %handles.I.model = mib_crossShiftStacks(handles.I.model(:,:,1:layerId), T, handles.shiftsX, handles.shiftsY, parameters);
            T = imtransform(handles.I.model(:,:,layerId+1:end), tform2, 'nearest');
            handles.I.model = mib_crossShiftStacks(handles.I.model(:,:,1:layerId), T, handles.shiftsX, handles.shiftsY, parameters);
        end
    end
    
    if get(handles.saveShiftsCheck,'Value')     % use preexisting parameters
        fn = get(handles.saveShiftsXYpath,'String');
        shiftsX = handles.shiftsX; %#ok<NASGU>
        shiftsY = handles.shiftsY; %#ok<NASGU>
        save(fn, 'shiftsX', 'shiftsY');
    end
else
    if isempty(fields(handles.files)) && get(handles.importRadio,'Value') == 0
        handles = selectButton_Callback(hObject, eventdata, handles);
        %handles = guidata(handles.mib_DriftAlignDlg);
    end
    if get(handles.dirRadio, 'Value')
        % loading the datasets
        [img,  img_info] = ib_getImages(handles.files, handles.img_info);
        waitbar(0, parameters.waitbar, sprintf('Aligning stacks using color channel %d ...', colorCh));
    elseif get(handles.fileRadio, 'Value')
        [img,  img_info] = ib_getImages(handles.files, handles.img_info);
        waitbar(0, parameters.waitbar, sprintf('Aligning stacks using color channel %d ...', colorCh));
    elseif get(handles.importRadio, 'Value')
        waitbar(0, parameters.waitbar, sprintf('Aligning stacks using color channel %d ...', colorCh));
        imgInfoVar = get(handles.imageInfoEdit,'String');
        img = evalin('base', pathIn);
        if numel(size(img)) == 3 && size(img,3) > 3    % reshape original dataset to w:h:color:z
            img = reshape(img, size(img,1),size(img,2),1,size(img,3));
        end;
        if ~isempty(imgInfoVar)
            img_info = evalin('base', imgInfoVar);
        else
            img_info = containers.Map;
        end
    end

    [height2, width2, color2, depth2, time2] = size(img);
    dummySelection = zeros(size(img,1),size(img,2),size(img,4),'uint8');    % dummy variable for resizing mask, model and selection
    
    if get(handles.twoStacksAutoSwitch,'Value')     % automatic mode
        w1 = max([size(handles.I.img,2) size(img,2)]);
        h1 = max([size(handles.I.img,1) size(img,1)]);

        I = zeros([h1, w1, 2], class(handles.I.img))+mean(mean(handles.I.img(:, :, colorCh, end, handles.I.slices{5}(1))));
        I(1:size(handles.I.img,1), 1:size(handles.I.img,2),1) = handles.I.img(:, :, colorCh, end, handles.I.slices{5}(1));
        I(1:size(img,1), 1:size(img,2),2) = img(:, :, colorCh, 1, handles.I.slices{5}(1));
        
        if get(handles.gradientCheckBox, 'value')
            % generate gradient image
            I2 = zeros(size(I), class(I));
            % generate gradient image
            hy = fspecial('sobel');
            hx = hy';
            for slice = 1:size(I, 3)
                Im = I(:,:,slice);   % get a slice
                Iy = imfilter(double(Im), hy, 'replicate');
                Ix = imfilter(double(Im), hx, 'replicate');
                I2(:,:,slice) = sqrt(Ix.^2 + Iy.^2);
            end
            I = I2;
            clear I2;
        end
        % calculate drifts
        [shiftX, shiftY] = mib_calcShifts(I, parameters);
        if isempty(shiftX); return; end;
        
        prompt = {sprintf('Would you like to use detected shifts?\n\nX shift:'),'Y shift:'};
        dlg_title = 'Calculated shifts';
        defaultans = {num2str(shiftX(2)),num2str(shiftY(2))};
        answer = inputdlg(prompt,dlg_title,1,defaultans);
        if isempty(answer); delete(parameters.waitbar); return; end
        handles.shiftsX = str2double(answer{1});
        handles.shiftsY = str2double(answer{2});
    else
        handles.shiftsX = str2double(get(handles.manualShiftX, 'string'));
        handles.shiftsY = str2double(get(handles.manualShiftY, 'string'));
    end
    [img, bbShiftXY] = mib_crossShiftStacks(handles.I.img, img, handles.shiftsX, handles.shiftsY, parameters);
    if isempty(img);        delete(parameters.waitbar);        return; end;
    handles.I.img = img;
    clear img;

    handles.I.no_stacks = size(handles.I.img, 4);
    handles.I.img_info('Stacks') = size(handles.I.img,3);
        
    % calculate shift of the bounding box
    maxXshift = bbShiftXY(1)*handles.I.pixSize.x;  % X shift in units vs the first slice
    maxYshift = bbShiftXY(2)*handles.I.pixSize.y;  % Y shift in units vs the first slice
    bb = handles.I.getBoundingBox;
    bb(1:2) = bb(1:2)-maxXshift;
    bb(3:4) = bb(3:4)-maxYshift;
    bb(6) = bb(6)+depth2*handles.I.pixSize.z;
    handles.I.updateBoundingBox(bb);

    handles.I.updateImgInfo(sprintf('Aligned two stacks using %s', algorithmText{get(handles.methodPopup,'value')}));
    
    % aligning the service layers: mask, selection, model
    % force background color to be black for the service layers
    % if the background needs to be selected, the parameters.backgroundColor = 'white'; should be used for selection layer
    parameters.backgroundColor = 0;
    parameters.modelSwitch = 1;
    
    if ~strcmp(handles.I.model_type, 'uint6')
        if handles.I.modelExist
            waitbar(.5, parameters.waitbar,sprintf('Aligning model\nPlease wait...'));
            handles.I.model = mib_crossShiftStacks(handles.I.model, dummySelection, handles.shiftsX, handles.shiftsY, parameters);
        end
        if handles.I.maskExist
            waitbar(.5, parameters.waitbar,sprintf('Aligning mask\nPlease wait...'));
            handles.I.maskImg = mib_crossShiftStacks(handles.I.maskImg, dummySelection, handles.shiftsX, handles.shiftsY, parameters);
        end
        if  ~isnan(handles.I.selection(1))
            waitbar(.5, parameters.waitbar,sprintf('Aligning selection\nPlease wait...'));
            handles.I.selection = mib_crossShiftStacks(handles.I.selection, dummySelection, handles.shiftsX, handles.shiftsY, parameters);
        end
    else
        waitbar(.5, parameters.waitbar,sprintf('Aligning Selection, Mask, Model\nPlease wait...'));
        handles.I.model = mib_crossShiftStacks(handles.I.model, dummySelection, handles.shiftsX, handles.shiftsY, parameters);
    end
    
    % combine SliceNames
    if isKey(handles.I.img_info, 'SliceName')
        SN = cell([size(handles.I.img,4),1]);
        SN(1:handles.I.img_info('Stacks')) = handles.I.img_info('SliceName');
        
        if isKey(img_info, 'SliceName')
            SN(handles.I.img_info('Stacks')+1:end) = img_info('SliceName');
        else
            if isKey(img_info, 'Filename')
                [~, fn, ext] = fileparts(img_info('Filename'));
                SN(handles.I.img_info('Stacks')+1:end) = [fn ext];
            else
                SN(handles.I.img_info('Stacks')+1:end) = cellstr('noname');
            end
        end
        handles.I.img_info('SliceName') = SN;
    end
end

delete(parameters.waitbar);

handles.I.width = size(handles.I.img, 2);
handles.I.height = size(handles.I.img, 1);
handles.I.colors = size(handles.I.img, 3);
handles.I.img_info('Height') = handles.I.height;
handles.I.img_info('Width') = handles.I.width;

toc;
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.mib_DriftAlignDlg);

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
uiresume(handles.mib_DriftAlignDlg);
end

% --- Executes when user attempts to close mib_DriftAlignDlg.
function mib_DriftAlignDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mib_DriftAlignDlg (see GCBO)
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

% --- Executes on key press over mib_DriftAlignDlg with no controls selected.
function mib_DriftAlignDlg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to mib_DriftAlignDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'Cancel';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.mib_DriftAlignDlg);
end

if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.mib_DriftAlignDlg);
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
guidata(handles.mib_DriftAlignDlg, handles);
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
    [img_info, files, pixSize] = getImageMetadata(cellstr(dirName), parameters);
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
set(handles.searchXminEdit,'String', num2str(round(dimsXYZ(1)/2)-round(dimsXYZ(1)/4)));
set(handles.searchXmaxEdit,'String', num2str(round(dimsXYZ(1)/2)+round(dimsXYZ(1)/4)));
set(handles.searchYminEdit,'String', num2str(round(dimsXYZ(2)/2)-round(dimsXYZ(2)/4)));
set(handles.searchYmaxEdit,'String', num2str(round(dimsXYZ(2)/2)+round(dimsXYZ(2)/4)));

% Update handles structure
guidata(handles.mib_DriftAlignDlg, handles);
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
guidata(hObject, handles);
end

function modeRadioButton_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
hObject = eventdata.NewValue;
tagId = get(hObject, 'tag');
curVal = get(hObject, 'value');
if curVal == 0; set(hObject, 'value', 1); return; end;

if strcmp(tagId, 'twoStacksModeRadio')
    set(handles.secondDatasetPanel,'Visible','on');
    set(handles.saveShiftsPanel,'Visible','off');
    set(handles.currStackOptionsPanel,'Visible','off');
    
    set(handles.correlateWithPopup, 'enable', 'off');
    set(handles.correlateWithText, 'enable', 'off');
    set(handles.maskCheck, 'enable', 'off');
    set(handles.subWindowCheck, 'enable', 'off');
else
    set(handles.secondDatasetPanel,'Visible','off');
    set(handles.saveShiftsPanel,'Visible','on');
    set(handles.currStackOptionsPanel,'Visible','on');
    
    set(handles.correlateWithPopup, 'enable', 'on');
    set(handles.correlateWithText, 'enable', 'on');
    set(handles.maskCheck, 'enable', 'on');
    set(handles.subWindowCheck, 'enable', 'on');
end
end


% --- Executes on button press in getSearchWindow.
function getSearchWindow_Callback(hObject, eventdata, handles)
sel = handles.I.getCurrentSlice('selection');
STATS = regionprops(sel, 'BoundingBox');
if numel(STATS) == 0
    msgbox('No selection layer present in the current slice!','Error','err');
    return;
end
STATS = STATS(1);

set(handles.searchXminEdit, 'String', num2str(ceil(STATS.BoundingBox(1))));
set(handles.searchYminEdit, 'String', num2str(ceil(STATS.BoundingBox(2))));
set(handles.searchXmaxEdit, 'String', num2str(ceil(STATS.BoundingBox(1)) + STATS.BoundingBox(3) - 1));
set(handles.searchYmaxEdit, 'String', num2str(ceil(STATS.BoundingBox(1)) + STATS.BoundingBox(4) - 1));
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
    handles.shiftsX = var.shiftsX;
    handles.shiftsY = var.shiftsY;
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


% --- Executes on selection change in methodPopup.
function methodPopup_Callback(hObject, eventdata, handles)
val = get(handles.methodPopup, 'value');
switch val
    case 1  % drift correction
        textStr = sprintf('Use the Drift correction mode for small shifts or comparably sized images');
    case 2  % Template matching
         textStr = sprintf('Use the Template matching mode for when aligning two stacks with one of the stacks smaller in size');
    case 3
        textStr = sprintf('Use the brush tool to mark two corresponding spots on consecutive slices. The dataset will be translated to align the marked spots');
    case 4
        textStr = sprintf('In this mode use the brush tool to mark corresponding spots on two consecutive slices. The dataset will be transformed to align the marked spots');
end
set(handles.landmarkHelpText, 'String', textStr);
set(handles.landmarkHelpText, 'TooltipString', textStr);
end


% --- Executes on button press in subWindowCheck.
function subWindowCheck_Callback(hObject, eventdata, handles)
if get(handles.subWindowCheck, 'value')
    set(handles.searchWinMinXText, 'enable', 'on');
    set(handles.searchWinMinYText, 'enable', 'on');
    set(handles.searchWinMaxXText, 'enable', 'on');
    set(handles.searchWinMaxYText, 'enable', 'on');
    set(handles.searchXminEdit, 'enable', 'on');
    set(handles.searchYminEdit, 'enable', 'on');
    set(handles.searchXmaxEdit, 'enable', 'on');
    set(handles.searchYmaxEdit, 'enable', 'on');
    set(handles.getSearchWindow, 'enable', 'on');
    
    % disable mask mode
    set(handles.maskCheck, 'value', 0);
else
    set(handles.searchWinMinXText, 'enable', 'off');
    set(handles.searchWinMinYText, 'enable', 'off');
    set(handles.searchWinMaxXText, 'enable', 'off');
    set(handles.searchWinMaxYText, 'enable', 'off');
    set(handles.searchXminEdit, 'enable', 'off');
    set(handles.searchYminEdit, 'enable', 'off');
    set(handles.searchXmaxEdit, 'enable', 'off');
    set(handles.searchYmaxEdit, 'enable', 'off');
    set(handles.getSearchWindow, 'enable', 'off');
end

end



function subwindowEdit_Callback(hObject, eventdata, handles)
x1 = str2double(get(handles.searchXminEdit,'String'));
y1 = str2double(get(handles.searchYminEdit,'String'));
x2 = str2double(get(handles.searchXmaxEdit,'String'));
y2 = str2double(get(handles.searchYmaxEdit,'String'));
if x1 < 1 || x1 > size(handles.I.img, 2)
    errordlg(sprintf('!!! Error !!!\n\nThe minY value should be between 1 and %d!', size(handles.I.img, 1)),'Wrong X min');
    set(handles.searchXminEdit,'String', '1');
    return;
end
if y1 < 1 || y1 > size(handles.I.img, 1)
    errordlg(sprintf('!!! Error !!!\n\nThe minY value should be between 1 and %d!', size(handles.I.img, 1)),'Wrong Y min');
    set(handles.searchYminEdit,'String', '1');
    return;
end
if x2 < 1 || x2 > size(handles.I.img, 2)
    errordlg(sprintf('!!! Error !!!\n\nThe maxX value should be smaller than %d!', size(handles.I.img, 2)),'Wrong X max');
    set(handles.searchXmaxEdit,'String', num2str(size(handles.I.img, 2)));
    return;
end
if y2 < 1 || y2 > size(handles.I.img, 1)
    errordlg(sprintf('!!! Error !!!\n\nThe maxY value should be between 1 and %d!', size(handles.I.img, 1)),'Wrong Y max');
    set(handles.searchYmaxEdit,'String', num2str(size(handles.I.img, 1)));
    return;
end
end


% --- Executes on button press in maskCheck.
function maskCheck_Callback(hObject, eventdata, handles)
val = get(handles.maskCheck, 'value');
if val == 1     % disable subwindow mode
    set(handles.subWindowCheck, 'value', 0);
    subWindowCheck_Callback(hObject, eventdata, handles);
    button = questdlg(sprintf('Would you like to use Mask or Selection layer for alignment?'),'Mask or Selection', 'Mask', 'Selection','Cancel','Mask');
    if strcmp(button, 'Cancel'); set(handles.maskCheck, 'value', 0); end;
    handles.maskOrSelection = lower(button);
    guidata(handles.mib_DriftAlignDlg, handles);
end
end


% --- Executes on selection change in correlateWithPopup.
function correlateWithPopup_Callback(hObject, eventdata, handles)
if get(handles.correlateWithPopup, 'value') == 3    % relative to mode
    set(handles.stepEditbox, 'enable', 'on');
    set(handles.stepText, 'enable', 'on');
else
    set(handles.stepEditbox, 'enable', 'off');
    set(handles.stepText, 'enable', 'off');
end
end


% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
web('http://mib.helsinki.fi/help/main/ug_gui_menu_dataset_alignment.html', '-helpbrowser');
end
