function varargout = ib_tubesVsSheets(varargin)
% IB_TUBESVSSHEETS MATLAB code for ib_tubesVsSheets.fig
%      IB_TUBESVSSHEETS, by itself, creates a new IB_TUBESVSSHEETS or raises the existing
%      singleton*.
%
%      H = IB_TUBESVSSHEETS returns the handle to a new IB_TUBESVSSHEETS or the handle to
%      the existing singleton*.
%
%      IB_TUBESVSSHEETS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IB_TUBESVSSHEETS.M with the given input arguments.
%
%      IB_TUBESVSSHEETS('Property','Value',...) creates a new IB_TUBESVSSHEETS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ib_tubesVsSheets_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ib_tubesVsSheets_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 01.07.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% Edit the above text to modify the response to help ib_tubesVsSheets

% Last Modified by GUIDE v2.5 01-Jul-2014 13:36:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ib_tubesVsSheets_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_tubesVsSheets_OutputFcn, ...
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

% --- Executes just before ib_tubesVsSheets is made visible.
function ib_tubesVsSheets_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_tubesVsSheets (see VARARGIN)

% Choose default command line output for ib_tubesVsSheets
handles.output = hObject;

%! get the handle of the main program
h_im_browser = varargin{3};
%! get the handles structure of the main program
handles.h = guidata(h_im_browser);

% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_tubesVsSheets, handles.h.preferences.Font);
end
% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.ib_tubesVsSheets);

fn = fullfile(handles.h.mypath, 'tube_vs_sheets.xls');
set(handles.filenameEdit, 'string', fn);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ib_tubesVsSheets wait for user response (see UIRESUME)
% uiwait(handles.ib_tubesVsSheets);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_tubesVsSheets_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isstruct(handles)    % to deal with closing of the figure
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

end

% --- Executes when user attempts to close ib_tubesVsSheets.
function ib_tubesVsSheets_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ib_tubesVsSheets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
end

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
ib_tubesVsSheets_CloseRequestFcn(handles.ib_tubesVsSheets, eventdata, handles);
end

% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
if isdeployed
     web(fullfile(fileparts(mfilename('fullpath')), 'html/ib_TubesVsSheets_help.html'), '-helpbrowser');
else
    %path = fileparts(which('im_browser'));
    %web(fullfile(path, 'techdoc/html/ug_panel_bg_removal.html'), '-helpbrowser');
    web(fullfile(fileparts(mfilename('fullpath')), 'html/ib_TubesVsSheets_help.html'), '-helpbrowser');
end
end

% --- Executes on button press in exportMatlab.
function exportMatlab_Callback(hObject, eventdata, handles)
if get(handles.exportMatlab, 'value')
    set(handles.exportVariableNameEdit, 'enable','on');
else
    set(handles.exportVariableNameEdit, 'enable','off');
end

end


% --- Executes on button press in exportExcelCheck.
function exportExcelCheck_Callback(hObject, eventdata, handles)
if get(handles.exportExcelCheck, 'value')
    set(handles.selectFileBtn, 'enable', 'on');
    set(handles.filenameEdit, 'enable', 'on');
    fn = get(handles.filenameEdit, 'string');
    if exist(fn, 'file');
        warndlg(sprintf('!!! Warning !!!\n\nXLS file:\n%s\nalready exists!\nIt will be overwritten!', fn),'Overwrite','modal');
    end
else
    set(handles.selectFileBtn, 'enable', 'off');
    set(handles.filenameEdit, 'enable', 'off');
end
end

function filenameEdit_Callback(hObject, eventdata, handles)
fn = get(handles.filenameEdit, 'string');
if exist(fn, 'file');
    warndlg(sprintf('!!! Warning !!!\n\nXLS file:\n%s\nalready exists!\nIt will be overwritten!', fn),'Overwrite','modal');
end
end

% --- Executes on button press in selectFileBtn.
function selectFileBtn_Callback(hObject, eventdata, handles)
fn = get(handles.filenameEdit, 'string');
[FileName,PathName,FilterIndex] = ...
    uiputfile(fn, 'Select filename', fn);
if isequal(FileName,0) || isequal(PathName,0); return; end;
set(handles.filenameEdit, 'string', fullfile(PathName, FileName));
end

% --- Executes on button press in calculateBtn.
function calculateBtn_Callback(hObject, eventdata, handles)
if handles.h.Img{handles.h.Id}.I.maskExist == 0
    errordlg(sprintf('!!! Error !!!\n\nA mask that contains segmented structure is required!\n\n\nPlease segment the structure of interest and add it to the Mask layer.\n After that try again!'),'Missing the mask');
    return;
end

ib_do_backup(handles.h, 'model', 1);    % store model layer
se_size = str2double(get(handles.strelSizeEdit, 'string'));     % get strel size
handles.h = guidata(handles.h.im_browser);  % update handles
roiOptions.fillBg = 0;  % set color to fill background of non-rectangle ROIs
img = ib_getDataset('image', handles.h, 0, NaN, roiOptions);
mask = ib_getDataset('mask', handles.h, 0, NaN, roiOptions);
% make structural element to erode/dilate
se = zeros([se_size*2+1 se_size*2+1],'uint8');
se(se_size+1,se_size+1) = 1;
se = bwdist(se); 
se = uint8(se <= se_size);

handles.h.Img{handles.h.Id}.I.createModel();    % create new empty model
handles.h.Img{handles.h.Id}.I.modelMaterialNames(1) = cellstr('Tubules');
handles.h.Img{handles.h.Id}.I.modelMaterialNames(2) = cellstr('Sheeets');
handles.h.Img{handles.h.Id}.I.modelMaterialNames = handles.h.Img{handles.h.Id}.I.modelMaterialNames';

wb = waitbar(0,sprintf('Calculating...\nStrel size: %dx%d px', se_size,se_size),'Name','Tubes vs Sheets ratio','WindowStyle','modal');
max_size = size(img{1}, 4);
model = mask;
results.tubeVsSheetsRatio = zeros(numel(img), max_size);   % allocate space for ratio calculations
results.areaSheets = zeros(numel(img), max_size);   % allocate space areas of sheets
results.areaTubules = zeros(numel(img), max_size);   % allocate space areas of tubules

for roiId=1:numel(img)
    for layer_id=1:max_size
        if mod(layer_id, 10)==0; waitbar(layer_id/max_size, wb); end;
        if max(max(mask{roiId}(:,:,layer_id))) < 1; continue; end;
        erodedImg = imerode(mask{roiId}(:,:,layer_id), se);
        erodedDilatedImg = imdilate(erodedImg, se);
        results.areaSheets(roiId, layer_id) = sum(sum(erodedDilatedImg))*handles.h.Img{handles.h.Id}.I.pixSize.x*handles.h.Img{handles.h.Id}.I.pixSize.y;
        results.areaTubules(roiId, layer_id) = sum(sum(mask{roiId}(:,:,layer_id)-erodedDilatedImg))*handles.h.Img{handles.h.Id}.I.pixSize.x*handles.h.Img{handles.h.Id}.I.pixSize.y;
        results.tubeVsSheetsRatio(roiId, layer_id) = results.areaTubules(roiId, layer_id)/results.areaSheets(roiId, layer_id);
        model{roiId}(:,:,layer_id) = mask{roiId}(:,:,layer_id) + erodedDilatedImg;
    end
    if get(handles.plotResultsCheck, 'value') == 1  % plot results
        figure(roiId)
        clf;
        aa1 = axes('position',[0.1300    0.110    0.7750    0.8150]); %#ok<LAXES>
        hBar = bar([results.areaSheets(roiId,:); results.areaTubules(roiId,:)]');
        set(hBar(1), 'LineStyle','none','FaceColor',[0.3686    0.2353    0.6000],'barwidth',3);
        set(hBar(2), 'LineStyle','none','FaceColor',[0.6980    0.6706    0.8235]);
        set(aa1, 'xlim', [1 max_size]);
        set(aa1, 'fontsize', 12);
        set(aa1, 'YAxisLocation','right');
        lab(1) = ylabel(['Area, sq.' handles.h.Img{handles.h.Id}.I.pixSize.units]);
        set(lab(1), 'color',[0.3686    0.2353    0.6000]);
        set(lab(1), 'fontweight','bold');
        lab(2) = xlabel('Slice number');
        legend('Sheets','Tubes')
        grid;
        t1=title(sprintf('Tubes to sheets ratio for ROI: %d ', roiId));
        aa2 = axes('position',[0.1300    0.110    0.7750    0.8150]); %#ok<LAXES>
        hPlot = plot(aa2, 1:max_size, results.tubeVsSheetsRatio(roiId,:),'ko-');
        set(hPlot, 'markerfacecolor','r');
        set(hPlot, 'markersize',10);
        set(hPlot, 'linewidth',3);
        set(aa2, 'color','none');
        set(aa2, 'XTickLabel',[]);
        set(aa2, 'xlim', [1 max_size]);
        lab(3) = ylabel('Ratio tubes/sheets');
        set(lab(3), 'color', 'r');
        set(lab(3), 'fontweight','bold');
        set(lab, 'fontsize',12);
        set(aa2, 'fontsize', 12);
        set(t1, 'fontsize', 12);
        set(t1, 'fontweight', 'bold');
    end
end
ib_setDataset('model', model, handles.h);
if get(handles.exportMatlab, 'value')   % export results to the main matlab workspace
    varName = get(handles.exportVariableNameEdit, 'string');
    assignin('base',varName,results);
    sprintf('Results were exported to the main matlab workspace as "%s" structure', varName)
end
if get(handles.exportExcelCheck, 'value')   % export results to excel
    waitbar(0, wb, 'Exporting results to Excel...');
    fn_out = get(handles.filenameEdit, 'string');
    
    if exist(fn_out,'file') == 2;
        %choice2 =  questdlg('Overwrite?','File already exist','Yes','Cancel','Yes');
        %if strcmp(choice2,'Cancel');    return;        end;
        delete(fn_out);  % delete exising file
    end
    
    warning off MATLAB:xlswrite:AddSheet;
    % Sheet 1
    s = {'Results of the tubes vs sheets calculations'};
    s(2,1) = {['Image filename: ' handles.h.Img{handles.h.Id}.I.img_info('Filename')]};
    if ~isnan(handles.h.Img{handles.h.Id}.I.maskImgFilename)
        s(3,1) = {['Mask filename: ' handles.h.Img{handles.h.Id}.I.maskImgFilename]};
    end
    fieldNames = fieldnames(handles.h.Img{handles.h.Id}.I.pixSize);
    s(4,1) = {'Pixel size and units:'};
    for field=1:numel(fieldNames)
        s(4+field-1, 2) =  fieldNames(field);
        s(4+field-1, 3) =  {handles.h.Img{handles.h.Id}.I.pixSize.(fieldNames{field})};
        %s(4,field*2-1+1) = fieldNames(field);
        %s(4,field*2+1) = {handles.h.Img{handles.h.Id}.I.pixSize.(fieldNames{field})};
    end
    s(10,1) = {'Results:'};
    
    startIndex = 13;
    endIndex = startIndex+size(results.tubeVsSheetsRatio,2)-1;
    %s(startIndex:endIndex, 1) = {1:size(results.tubeVsSheetsRatio,2)};
    s(startIndex:endIndex, 1) = num2cell(1:size(results.tubeVsSheetsRatio,2));
    for roiId = 1:numel(img)
        s(11,3+(roiId-1)*3) = {['ROI' num2str(roiId)]};
        s(12,2+(roiId-1)*3) = {'Tubes, area'};
        s(12,3+(roiId-1)*3) = {'Sheets, area'};
        s(12,4+(roiId-1)*3) = {'Ratio, tubes/sheets'};
        s(startIndex:endIndex, 2+(roiId-1)*3) = num2cell(results.areaTubules(roiId, :));
        s(startIndex:endIndex, 3+(roiId-1)*3) = num2cell(results.areaSheets(roiId, :));
        s(startIndex:endIndex, 4+(roiId-1)*3) = num2cell(results.tubeVsSheetsRatio(roiId, :));
    end
    waitbar(0.4, wb, 'Exporting results to Excel...');
    xlswrite2(fn_out, s, 'Results', 'A1');
    waitbar(1, wb, 'Exporting results to Excel...');
end
delete(wb);
set(handles.h.modelShowCheck, 'value', 1);  % turn on show model check box
handles.h = updateGuiWidgets(handles.h);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);
end
