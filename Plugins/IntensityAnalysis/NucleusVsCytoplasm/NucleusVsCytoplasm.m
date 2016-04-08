function varargout = NucleusVsCytoplasm(varargin)
% NUCLEUSVSCYTOPLASM MATLAB code for NucleusVsCytoplasm.fig
%      NUCLEUSVSCYTOPLASM, by itself, creates a new NUCLEUSVSCYTOPLASM or raises the existing
%      singleton*.
%
%      H = NUCLEUSVSCYTOPLASM returns the handle to a new NUCLEUSVSCYTOPLASM or the handle to
%      the existing singleton*.
%
%      NUCLEUSVSCYTOPLASM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUCLEUSVSCYTOPLASM.M with the given input arguments.
%
%      NUCLEUSVSCYTOPLASM('Property','Value',...) creates a new NUCLEUSVSCYTOPLASM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NucleusVsCytoplasm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NucleusVsCytoplasm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 14.05.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% Edit the above text to modify the response to help NucleusVsCytoplasm

% Last Modified by GUIDE v2.5 16-Mar-2014 10:55:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NucleusVsCytoplasm_OpeningFcn, ...
                   'gui_OutputFcn',  @NucleusVsCytoplasm_OutputFcn, ...
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

% --- Executes just before NucleusVsCytoplasm is made visible.
function NucleusVsCytoplasm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NucleusVsCytoplasm (see VARARGIN)

% Written by Ilya Belevich, 16.03.2014
% ilya.belevich@helsinki.fi

%! get the handle of the main program
h_im_browser = varargin{3};
%! get the handles structure of the main program
handles.h = guidata(h_im_browser);

strText = sprintf('Calculate image intensities of two materials of the opened model.\nSee details in the Help section.');
set(handles.helpText, 'String', strText);

% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.NucleusVsCytoplasm, handles.h.preferences.Font);
end
% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.NucleusVsCytoplasm);

% populate color channel combo box
set(handles.colorChannelCombo,'Value',1);
col_channels = cell([size(handles.h.Img{handles.h.Id}.I.img,3), 1]);
for col_ch=1:size(handles.h.Img{handles.h.Id}.I.img,3)
    col_channels(col_ch) = cellstr(['Ch ' num2str(col_ch)]);
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

% populate materials popups
set(handles.material1Popup, 'value', 1);
set(handles.material2Popup, 'value', 2);
set(handles.material1Popup, 'string', handles.h.Img{handles.h.Id}.I.modelMaterialNames);
set(handles.material2Popup, 'string', handles.h.Img{handles.h.Id}.I.modelMaterialNames);

[path,fn] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
set(handles.filenameEdit, 'string', fullfile(path, [fn '_analysis.xls']));
%set(handles.filenameEdit, 'string', fullfile(handles.h.mypath, 'results.xls'));

% Choose default command line output for NucleusVsCytoplasm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NucleusVsCytoplasm wait for user response (see UIRESUME)
% uiwait(handles.NucleusVsCytoplasm);
end

% --- Outputs from this function are returned to the command line.
function varargout = NucleusVsCytoplasm_OutputFcn(hObject, eventdata, handles) 
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
delete(handles.NucleusVsCytoplasm);
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
     web(fullfile(fileparts(mfilename('fullpath')), 'html/NucleusVsCytoplasm_help.html'), '-helpbrowser');
else
    %path = fileparts(which('im_browser'));
    %web(fullfile(path, 'techdoc/html/ug_panel_bg_removal.html'), '-helpbrowser');
    web(fullfile(fileparts(mfilename('fullpath')), 'html/NucleusVsCytoplasm_help.html'), '-helpbrowser');
end

end

% --- Executes on button press in showHistCheck.
function showHistCheck_Callback(hObject, eventdata, handles)
% hObject    handle to showHistCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showHistCheck
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
handles.h = guidata(handles.h.im_browser);
fn = get(handles.filenameEdit, 'string');
if handles.h.Img{handles.h.Id}.I.modelExist == 0
    errordlg('This plugin requires a model to be present!','Model was not detected');
    return;
end
if get(handles.savetoExcel, 'value')
    % check filename
    if exist(fn, 'file') == 2
        strText = sprintf('!!! Warning !!!\n\nThe file:\n%s \nis already exist!\n\nOverwrite?', fn);
        button = questdlg(strText, 'File exist!','Overwrite', 'Cancel','Cancel');
        if strcmp(button, 'Cancel'); return; end;
        delete(fn);     % delete existing file
    end
end
wb = waitbar(0,'Please wait...','Name','Intensity Ratio...','WindowStyle','modal');
ib_do_backup(handles.h, 'selection', 1);

parameterToCalculateList = get(handles.parameterCombo,'String');
parameterToCalculateVal = get(handles.parameterCombo,'Value');
parameterToCalculate = parameterToCalculateList{parameterToCalculateVal};
colCh = get(handles.colorChannelCombo, 'value');
% get materials to be analyzed
material1_Index = get(handles.material1Popup, 'value');
material2_Index = get(handles.material2Popup, 'value');

warning off MATLAB:xlswrite:AddSheet
% Sheet 1
s = {'Two materials intensity analysis and ratio calculation'};
s(2,1) = {'Image directory:'};
s(2,2) = {fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'))};
s(3,1) = {'Calculating:'};
s(3,2) = {parameterToCalculate};
s(3,6) = {'Color channel:'};
s(3,7) = {num2str(colCh)};
s(5,1) = {'Filename'};
s(5,2) = {'Slice Number'};
s(5,3) = handles.h.Img{handles.h.Id}.I.modelMaterialNames(material1_Index);
s(5,4) = handles.h.Img{handles.h.Id}.I.modelMaterialNames(material2_Index);
s(5,5) = {['Ratio ' handles.h.Img{handles.h.Id}.I.modelMaterialNames{material1_Index} '/' handles.h.Img{handles.h.Id}.I.modelMaterialNames{material2_Index}]};

options.blockModeSwitch = 0; 
img = handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, 4, colCh, options);    % get desired color channel from the image
model1 = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, material1_Index, options);    % get model 1
model2 = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, material2_Index, options);    % get model 2
selection = zeros(size(model1), class(model1));   % create new selection layer 

if isKey(handles.h.Img{handles.h.Id}.I.img_info, 'SliceName')   % when filenames are present use them
    inputFn = handles.h.Img{handles.h.Id}.I.img_info('SliceName');
else
    [~,inputFn, ext] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
    inputFn = [inputFn ext];
end

rowId = 6;  % a row for the excel file
Ratio = []; % a variable to keep ratios of intensities   
for sliceId = 1:size(model1, 3)
    waitbar(sliceId/size(model1, 3),wb);
    CC1 = bwconncomp(model1(:,:,sliceId),8);
    if CC1.NumObjects == 0; continue; end;  % check whether the materials exist on the current slice
    STATS1 = regionprops(CC1, 'Centroid','PixelIdxList');
    CC2 = bwconncomp(model2(:,:,sliceId),8);
    STATS2 = regionprops(CC2, 'Centroid','PixelIdxList');
    
    if CC1.NumObjects ~= CC2.NumObjects; continue; end;
    
    % find distances between centroids
    X1 = zeros([numel(STATS1) 2]);
    X2 = zeros([numel(STATS2) 2]);
    for i=1:numel(STATS1)
        X1(i,:) = STATS1(i).Centroid;
        X2(i,:) = STATS2(i).Centroid;
    end
    % % following code is equal to pdist2 function in the statistics toolbox
    % % such as: dist = pdist2(X1,X2);
    dist = zeros([numel(STATS1) numel(STATS2)]);
    for i=1:numel(STATS1)  
        for j=1:numel(STATS2)
            dist(i,j) = sqrt((X1(i,1)-X2(j,1))^2 + (X1(i,2)-X2(j,2))^2);
        end
    end
       
    % following is an adaptation of a code by Gunther Struyf
    % http://stackoverflow.com/questions/12083467/find-the-nearest-point-pairs-between-two-sets-of-of-matrix
    N = size(X1,1);
    matchAtoB=NaN(N,1);
    for ii=1:N
        %dist(:,matchAtoB(1:ii-1))=Inf; % make sure that already picked points of B are not eligible to be new closest point
        %[~, matchAtoB(ii)]=min(dist(ii,:));
        dist(matchAtoB(1:ii-1),:)=Inf; % make sure that already picked points of B are not eligible to be new closest point
        [~, matchAtoB(ii)]=min(dist(:,ii));
    end
    matchBtoA = NaN(size(X2,1),1);
    matchBtoA(matchAtoB)=1:N;
        
    idx =  matchBtoA;   % indeces of the matching objects, i.e. STATS1(objId) =match= STATS2(idx(objId))
    
    Intensity1 = zeros([numel(STATS1),1]);  % reserve space for intensities of the 1st material
    Intensity2 = zeros([numel(STATS2),1]);  % reserve space for intensities of the 2nd material
    for objId = 1:numel(STATS1)
        pnts(1,:) = STATS1(objId).Centroid;
        pnts(2,:) = STATS2(idx(objId)).Centroid;
        selection(:,:,sliceId) = ib_connectPoints(selection(:,:,sliceId), pnts);    % connect centroids for checking
        
        slice = squeeze(img(:,:,:,sliceId));
        
        switch parameterToCalculate
            case 'Mean intensity'
                Intensity1(objId) = mean(slice(STATS1(objId).PixelIdxList));
                Intensity2(objId) = mean(slice(STATS2(idx(objId)).PixelIdxList));
            case 'Min intensity'
                Intensity1(objId) = min(slice(STATS1(objId).PixelIdxList));
                Intensity2(objId) = min(slice(STATS2(idx(objId)).PixelIdxList));
            case 'Max intensity'
                Intensity1(objId) = max(slice(STATS1(objId).PixelIdxList));
                Intensity2(objId) = max(slice(STATS2(idx(objId)).PixelIdxList));
            case 'Sum intensity'
                Intensity1(objId) = sum(slice(STATS1(objId).PixelIdxList));
                Intensity2(objId) = sum(slice(STATS2(idx(objId)).PixelIdxList));
        end
        
        % generate filename/slice name for excel
        if iscell(inputFn)
            s(rowId, 1) = inputFn(sliceId);
        else
            s(rowId, 1) = {inputFn};
        end
        
        % generate slice number for excel
        s(rowId, 2) = {num2str(sliceId)};

        % generate intensity 1 for excel
        s(rowId, 3) = {num2str(Intensity1(objId))};
        % generate intensity 2 for excel
        s(rowId, 4) = {num2str(Intensity2(objId))};
        % generate ratio, intensity2/intensity1
        s(rowId, 5) = {num2str(Intensity1(objId)/Intensity2(objId))};
        
        handles.h.Img{handles.h.Id}.I.hLabels.addLabels(num2str(Intensity1(objId)), [sliceId, round(X1(objId,:))]);
        handles.h.Img{handles.h.Id}.I.hLabels.addLabels(num2str(Intensity2(objId)), [sliceId, round(X2(idx(objId),:))]);
        
        rowId = rowId + 1;
    end
    Ratio = [Ratio; Intensity1./Intensity2]; %#ok<AGROW>
    
    rowId = rowId + 1;
    handles.h.Img{handles.h.Id}.I.setData3D('selection', selection, NaN, 4, NaN, options);
end
if get(handles.savetoExcel, 'value')
    waitbar(1, wb, 'Generating Excel file...');
    xlswrite2(fn, s, 'Sheet1', 'A1');
end
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);

% plot histogram
if get(handles.showHistCheck, 'value')
    figure(321);
    hist(Ratio, ceil(numel(Ratio)/2));
    t1 = title(sprintf('Ratio (%s/%s) calculated from %s, N=%d', handles.h.Img{handles.h.Id}.I.modelMaterialNames{material1_Index}, handles.h.Img{handles.h.Id}.I.modelMaterialNames{material2_Index}, parameterToCalculate, numel(Ratio)));
    xl = xlabel(sprintf('Ratio (%s/%s)',handles.h.Img{handles.h.Id}.I.modelMaterialNames{material1_Index}, handles.h.Img{handles.h.Id}.I.modelMaterialNames{material2_Index}));
    yl = ylabel('Number of cells');
    grid;
    set(xl, 'Fontsize', 12);
    set(yl, 'Fontsize', 12);
    set(t1, 'Fontsize', 14);
end
delete(wb);
guidata(handles.NucleusVsCytoplasm, handles);
end
