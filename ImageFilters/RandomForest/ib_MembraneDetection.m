function varargout = ib_MembraneDetection(varargin)
% function varargout = ib_MembraneDetection(varargin)
% ib_MembraneDetection function uses random forest classifier for segmentation.
% The function utilize Random Forest for Membrane Detection functions by Verena Kaynig
% see more http://www.kaynig.de/demos.html
%
% ib_MembraneDetection contains MATLAB code for ib_MembraneDetection.fig

% Copyright (C) 21.08.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
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
                   'gui_OpeningFcn', @ib_MembraneDetection_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_MembraneDetection_OutputFcn, ...
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

% --- Executes just before ib_MembraneDetection is made visible.
function ib_MembraneDetection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_MembraneDetection (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser
% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_MembraneDetection, handles.h.preferences.Font);
end

% % switch off the block mode
% if strcmp(get(handles.h.toolbarBlockModeSwitch,'state'),'on')
%     warndlg(sprintf('!!! Warning !!!\n\nThe block mode will be disabled!'),'Switch off the block mode');
%     set(handles.h.toolbarBlockModeSwitch,'state','off');
% end


% Choose default command line output for ib_MembraneDetection
handles.output = NaN;

% set some default parameters
handles.maxNumberOfSamplesPerClass = 500; 

list = get(handles.h.segmList, 'string');   % list of materials
if handles.h.Img{handles.h.Id}.I.modelExist == 0 || numel(list) < 2
    errordlg(sprintf('!!! Error !!!\n\nA model with at least two materials is needed to proceed further!\n\nPlease create a new model with two materials - one for the objects and another one for the background. After that try again!\n\nPlease also refer to the Help section for details'),'Missing the model','modal');
    set(handles.trainClassifierBtn, 'enable', 'off');
    set(handles.predictSlice, 'enable', 'off');
    list = {'Add 2 Materials to the model!'};
    %ib_MembraneDetection_CloseRequestFcn(hObject, eventdata, handles);
    %return;
end

% populating directories
dirOut = fullfile(handles.h.mypath,'RF_Temp');
set(handles.tempDirEdit, 'string', dirOut);
[~,fn] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
classFilename = fullfile(handles.h.mypath,'RF_Temp',[fn '.forest']);
set(handles.classifierFilenameEdit, 'string', classFilename);

% populating material lists
val = get(handles.h.segmSelList, 'value')-2;
set(handles.objectPopup, 'string', list);
set(handles.objectPopup, 'value', max([val 1]));
val = get(handles.h.segmAddList, 'value')-2;
set(handles.backgroundPopup, 'string', list);
set(handles.backgroundPopup, 'value', max([val 1]));

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_MembraneDetection);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ib_MembraneDetection wait for user response (see UIRESUME)
% uiwait(handles.ib_MembraneDetection);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_MembraneDetection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isstruct(handles)    % to deal with closing of the figure
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end
end

% --- Executes when user attempts to close ib_MembraneDetection.
function ib_MembraneDetection_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ib_MembraneDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
end

function tempDirEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tempDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tempDirEdit as text
%        str2double(get(hObject,'String')) returns contents of tempDirEdit as a double
end

% --- Executes on button press in tempDirSelectBtn.
function tempDirSelectBtn_Callback(hObject, eventdata, handles)
currTempPath = get(handles.tempDirEdit, 'string');
if exist(currTempPath,'dir') == 0     % make directory
    mkdir(currTempPath);
end 
currTempPath = uigetdir(currTempPath, 'Select temp directory');
if currTempPath == 0; return; end;   % cancel
set(handles.tempDirEdit, 'string', currTempPath);
end

% --- Executes on button press in classifierFilenameBtn.
function classifierFilenameBtn_Callback(hObject, eventdata, handles)
% hObject    handle to classifierFilenameBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

function updateLoglist(addText, handles)
status = get(handles.logList, 'string');
c = clock;
if isempty(status);
    status = {sprintf('%d:%02i:%02i  %s', c(4),c(5),round(c(6)),addText)};
else
    status(end+1) = {sprintf('%d:%02i:%02i  %s', c(4),c(5),round(c(6)),addText)};
end
set(handles.logList, 'string', status);
set(handles.logList, 'value', numel(status));
drawnow;
end


% --- Executes on button press in wipeTempDirBtn.
function wipeTempDirBtn_Callback(hObject, eventdata, handles)
tempDir = get(handles.tempDirEdit,'string');
if exist(tempDir,'dir') ~= 0     % remove directory
    
    button =  questdlg(sprintf('!!! Warning !!!\n\nThe whole directory:\n\n%s\n\nwill be deleted!!!\n\nAre you sure?', tempDir),....
        'Delete directory?','Delete','Cancel','Cancel');
    if strcmp(button, 'Cancel')
        updateLoglist('Canceled!', handles);
        return;
    end
    
    rmdir(tempDir, 's');
    updateLoglist('Temp directory was deleted', handles);
end
end

% --- Executes on button press in trainClassifierBtn.
function trainClassifierBtn_Callback(hObject, eventdata, handles)
set(handles.trainClassifierBtn, 'backgroundColor', [1 0 0]);
if get(handles.trainClassifierToggle, 'value')
    trainClassifier(handles);
elseif get(handles.predictDatasetToggle, 'value')
    predictDataset(handles);
end
set(handles.trainClassifierBtn, 'backgroundColor', [0 1 0]);
end

% --- Executes on button press in predictSlice.
function predictSlice_Callback(hObject, eventdata, handles)
set(handles.predictSlice, 'backgroundColor', [1 0 0]);
sliceNo = handles.h.Img{handles.h.Id}.I.getCurrentSliceNumber();
predictDataset(handles, sliceNo);
set(handles.predictSlice, 'backgroundColor', [0 1 0]);
end

% --- Executes on button press in saveClassifierBtn.
function saveClassifierBtn_Callback(hObject, eventdata, handles)
set(handles.logList, 'string','');
updateLoglist('======= Saving classifier... =======', handles);
outFile = get(handles.classifierFilenameEdit,'string');
if exist(outFile,'file')== 2     % make directory
    updateLoglist('The classifier already exist!', handles);
    button =  questdlg(sprintf('!!! Warning !!!\n\nThe file already exist!\n\nOverwrite?'),....
        'Overwrite existing forest?','Overwrite','Cancel','Cancel');
    if strcmp(button, 'Cancel')
        updateLoglist('Canceled!', handles);
        return;
    end
    updateLoglist('Overwriting...', handles);
end
if isfield(handles, 'forest') == 0
    errordlg(sprintf('!!! Error !!!\n\nThe classifier is not created yet!\nTry to train the classifer first!'),'Missing the classifier');
    updateLoglist('The classifier is not created yet!', handles);
    return;
end
forest = handles.forest; %#ok<NASGU>
save(outFile, 'forest', '-mat','-v7.3');
updateLoglist('The classifier was saved!', handles);
updateLoglist(outFile, handles);
end

% --- Executes on button press in trainClassifierToggle.
function trainClassifierToggle_Callback(hObject, eventdata, handles)
% hObject    handle to trainClassifierToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trainClassifierToggle
btnTag = get(hObject, 'tag');
switch btnTag
    case 'trainClassifierToggle'
        set(handles.objectText, 'enable', 'on');
        set(handles.backgroundText, 'enable', 'on');
        set(handles.objectPopup, 'enable', 'on');
        set(handles.backgroundPopup, 'enable', 'on');
        set(handles.membrThickText, 'enable', 'on');
        set(handles.membraneThicknessEdit, 'enable', 'on');
        set(handles.contextSizeEdit, 'enable', 'on');
        set(handles.contextSizeText, 'enable', 'on');   
        set(handles.trainClassifierBtn, 'string', 'Train classifier');
        set(handles.predictSlice, 'visible', 'off');   
    case 'predictDatasetToggle'
        set(handles.objectText, 'enable', 'off');
        set(handles.backgroundText, 'enable', 'off');
        set(handles.objectPopup, 'enable', 'off');
        set(handles.backgroundPopup, 'enable', 'off');
        set(handles.membrThickText, 'enable', 'off');
        set(handles.membraneThicknessEdit, 'enable', 'off');
        set(handles.contextSizeEdit, 'enable', 'off');
        set(handles.contextSizeText, 'enable', 'off');
        set(handles.trainClassifierBtn, 'string', 'Predict dataset');
        set(handles.predictSlice, 'visible', 'on');           
end
end

% train classifier function
function trainClassifier(handles)
% train random forest
% based on skript_trainClassifier_for_membraneDetection.m by Verena Kaynig

set(handles.logList, 'string','');
updateLoglist('======= Starting training... =======', handles);

ib_do_backup(handles.h, 'selection', 1);    % store selection layer

cs = str2double(get(handles.contextSizeEdit,'string'));     % context size 
ms = str2double(get(handles.membraneThicknessEdit,'string'));     % membrane thickness
csHist = cs;  % context Size Histogram 
posModel = get(handles.objectPopup, 'value');
negModel = get(handles.backgroundPopup, 'value');

handles.h = guidata(handles.h.im_browser);  % update handles

% check whether the blockmode is enabled
blockModeSwitch = 0;
if strcmp(get(handles.h.toolbarBlockModeSwitch,'state'),'on');
    blockModeSwitch = 1;
    [yMinShown, yMaxShown, xMinShown, xMaxShown] = handles.h.Img{handles.h.Id}.I.getCoordinatesOfShownImage();
end
votesThreshold = str2double(get(handles.votesThresholdEdit, 'string'));
tempDir = get(handles.tempDirEdit,'string');
if exist(tempDir,'dir') == 0     % make directory
    mkdir(tempDir);
end

t1 = tic;
extraOptions.blockModeSwitch = 0;
model = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, NaN, extraOptions);  
fmPos = [];
fmNeg = [];
slicesForTraining = zeros([size(model,3),1]);   % vector to keep slices for the training.
for sliceNo=1:size(model,3)
    % find slices with model
    if isempty(find(model(:,:,sliceNo) == posModel,1)) && isempty(find(model(:,:,sliceNo) == negModel,1))
        continue;
    end
    slicesForTraining(sliceNo) = 1;     % indicate that this slice was used for the training
    % check whether the membrane feature file exist
    featuresFilename = fullfile(tempDir, sprintf('slice_%06i.fm', sliceNo));     % filename for features
    if ~exist(featuresFilename, 'file');
        updateLoglist(sprintf('Extracting membrane features for slice: %d...', sliceNo), handles);
        
        im = handles.h.Img{handles.h.Id}.I.getFullSlice('image',sliceNo); % get image
        
        % generate membrane features:
        % fm(:,:,1) -> orig image
        % fm(:,:,2:5) -> 1-90 degrees
        % fm(:,:,6) -> minimal values of all degrees
        % fm(:,:,7) -> maximal values of all degrees
        % fm(:,:,8) -> mean values of all degrees
        % fm(:,:,9) -> variance values of all degrees
        % fm(:,:,10) -> median values of all degrees
        % fm(:,:,11:14) -> 90-180 degrees
        % fm(:,:,17:26) -> 10-bin histogram of a context area at each point of the image
        % fm(:,:,27) -> mean value of a context area at each point of the image
        % fm(:,:,28) -> variance (?) value of a context area at each point of the image
        % fm(:,:,29) -> maximal - minimal values for all degrees
        % the following are repeats of
        % fm(:,:,30) -> smoothed original image, sigma = 1
        % fm(:,:,31) -> smoothed eig1/eig2, sigma = 1
        % fm(:,:,32) -> smoothed magnitude, sigma = 1
        % fm(:,:,33) -> magnitude, sigma = 1
        % fm(:,:,34-37) -> repeat 30-33, with sigma=2
        % fm(:,:,38-41) -> repeat 30-33, with sigma=3
        % fm(:,:,42) -> 38 -minus- smoothed original image with sigma=1
        % fm(:,:,43-46) -> repeat 30-33, with sigma=4
        % fm(:,:,47) -> 43 -minus- smoothed original image with sigma=1
        % ...
        % fm(:,:,89) -> end of that cycle
        % fm(:,:,90) -> variance of last 10 entries in the fm
        % fm(:,:,91) -> normalized smoothed orig.image sigma=2 - smoothed orig.image sigma=50
        % fm(:,:,92) -> original image
        
        fm  = membraneFeatures(im, cs, ms, csHist);
        
%         % test fm
%         fm  = membraneFeatures(im, 15, 2, 15);
%         fmout = zeros(size(fm),'uint8');
%         for i=1:size(fm,3)
%             fmout(:,:,i) = uint8(fm(:,:,i)/max(max(fm(:,:,i)))*255);
%         end
        
        
        
        fm(isnan(fm)) = 0;
        save(featuresFilename,'fm', '-mat','-v7.3');
    else
        load(featuresFilename,'fm', '-mat');    % load membrane features
    end
    
    updateLoglist(sprintf('Adding features from slice: %d...', sliceNo), handles);
    posPos = find(model(:,:,sliceNo) == posModel);
    posNeg = find(model(:,:,sliceNo) == negModel);
    
    fm = reshape(fm,size(fm,1)*size(fm,2),size(fm,3));  % convert x,y -> to vector
    fmPos = [fmPos; fm(posPos,:)];  % get features for positive points, combine with another training slice
    fmNeg = [fmNeg; fm(posNeg,:)];  % get features for negative points
end
clear fm;
clear posPos;
clear posNeg;

updateLoglist('======= Training the classifier... =======', handles);
y = [zeros(size(fmNeg,1),1);ones(size(fmPos,1),1)];     % generate a vector that defines positive and negative values
x = double([fmNeg;fmPos]);  % generate a matrix with combined membrane features

extra_options.sampsize = [handles.maxNumberOfSamplesPerClass, handles.maxNumberOfSamplesPerClass];
handles.forest = classRF_train(x, y, 300, 5, extra_options);    % train classifier

for sliceNo=find(slicesForTraining==1)'; 
    featuresFilename = fullfile(tempDir, sprintf('slice_%06i.fm', sliceNo));     % filename for features
    updateLoglist(sprintf('Predicting slice: %d...', sliceNo), handles);
    load(featuresFilename,'fm', '-mat');    % load membrane features
    
    if blockModeSwitch  % crop fm if the block mode is enabled
        fm = fm(yMinShown:yMaxShown, xMinShown:xMaxShown, :);
    end
    imsize = [size(fm,1), size(fm,2)];
    fm = reshape(fm,size(fm,1)*size(fm,2),size(fm,3));
    
    %im = handles.h.Img{handles.h.Id}.I.getSlice('image',sliceNo); % get image
    %im = uint8Img(im); % convert to uint8 and scale from 0 to 255
    % imsize = size(im);
    % clear im
    
    clear y;
    
    
    votes = zeros(imsize(1)*imsize(2),1);
    [y_h,v] = classRF_predict(double(fm), handles.forest);
    votes = v(:,2);
    votes = reshape(votes,imsize);
    votes = double(votes)/max(votes(:));
    
    % store votes for the export
    if get(handles.exportVotesCheck, 'value')  
        if exist('votesOut','var') == 0
            votesOut = zeros([imsize(1), imsize(2), 1, numel(find(slicesForTraining==1))]);
            voteIndex = 1;
        end
        votesOut(:,:,1, voteIndex) = votes;
        voteIndex = voteIndex + 1;
    end
    
    
    if get(handles.skelClosedCheck, 'value')
        skelImg = uint8(bwmorph(skeletonize(votes>=votesThreshold),'dilate',1));
    else
        skelImg = uint8(votes>votesThreshold);
    end
    handles.h.Img{handles.h.Id}.I.setSlice('selection', skelImg, sliceNo);
end;

if get(handles.exportVotesCheck, 'value')  
    updateLoglist('======= Exporting votes to matlab =======', handles);
    assignin('base', 'ib_votes', votesOut);
    updateLoglist('Done! variable -> ib_votes(1:height, 1:width, 1, 1:slices)', handles);
end
updateLoglist('======= Training finished! =======', handles);
resultTOC = toc(t1);
updateLoglist(sprintf('Elapsed time is %f seconds.',resultTOC), handles);

handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);

guidata(handles.ib_MembraneDetection, handles);
end


function predictDataset(handles, sliceNumber)
% predict dataset using the random forest classifier
handles.h = guidata(handles.h.im_browser);  % update handles
if nargin < 2
    [height, width, color, thick] = handles.h.Img{handles.h.Id}.I.getDatasetDimensions('image', 4);
    startSlice = 1;
    finishSlice = thick;
else
    startSlice = sliceNumber;
    finishSlice = sliceNumber;
    thick = 1;
end

set(handles.logList, 'string','');
updateLoglist('======= Starting prediction... =======', handles);

ib_do_backup(handles.h, 'selection', 1);    % store selection layer

cs = str2double(get(handles.contextSizeEdit,'string'));     % context size 
ms = str2double(get(handles.membraneThicknessEdit,'string'));     % membrane thickness
csHist = cs;  % context Size Histogram 

% check whether the blockmode is enabled
blockModeSwitch = 0;
if strcmp(get(handles.h.toolbarBlockModeSwitch,'state'),'on');
    blockModeSwitch = 1;
    [yMinShown, yMaxShown, xMinShown, xMaxShown] = handles.h.Img{handles.h.Id}.I.getCoordinatesOfShownImage();
end
votesThreshold = str2double(get(handles.votesThresholdEdit, 'string'));
tempDir = get(handles.tempDirEdit,'string');
if exist(tempDir,'dir') == 0     % make directory
    mkdir(tempDir);
end

t1 = tic;
extra_options.sampsize = [handles.maxNumberOfSamplesPerClass, handles.maxNumberOfSamplesPerClass];

inFile = get(handles.classifierFilenameEdit,'string');
updateLoglist('Loading classifier...', handles);
updateLoglist(inFile, handles);
if exist(inFile,'file') == 0
    errordlg(sprintf('!!! Error !!!\n\nThe classifier file was not found!\nTry to train the classifer and save it to a file'),'Missing the classifier');
    updateLoglist('The classifier was not found!', handles);
    return;
end
load(inFile, '-mat');
handles.forest = forest;
clear forest;
updateLoglist('Classifier loaded!', handles);

for sliceNo = startSlice:finishSlice
    featuresFilename = fullfile(tempDir, sprintf('slice_%06i.fm', sliceNo));     % filename for features
    
    % check whether the feature file already exist
    if ~exist(featuresFilename, 'file');    
        updateLoglist(sprintf('Extracting membrane features for slice: %d...', sliceNo), handles);
        im = handles.h.Img{handles.h.Id}.I.getFullSlice('image',sliceNo); % get image
        % generate membrane features:
        % fm(:,:,1) -> orig image
        % fm(:,:,2:5) -> 1-90 degrees
        % fm(:,:,6) -> minimal values of all degrees
        % fm(:,:,7) -> maximal values of all degrees
        % fm(:,:,8) -> mean values of all degrees
        % fm(:,:,9) -> variance values of all degrees
        % fm(:,:,10) -> median values of all degrees
        % fm(:,:,11:14) -> 90-180 degrees
        % fm(:,:,17:26) -> 10-bin histogram of a context area at each point of the image
        % fm(:,:,27) -> mean value of a context area at each point of the image
        % fm(:,:,28) -> variance (?) value of a context area at each point of the image
        % fm(:,:,29) -> maximal - minimal values for all degrees
        % the following are repeats of
        % fm(:,:,30) -> smoothed original image, sigma = 1
        % fm(:,:,31) -> smoothed eig1/eig2, sigma = 1
        % fm(:,:,32) -> smoothed magnitude, sigma = 1
        % fm(:,:,33) -> magnitude, sigma = 1
        % fm(:,:,34-37) -> repeat 30-33, with sigma=2
        % fm(:,:,38-41) -> repeat 30-33, with sigma=3
        % fm(:,:,42) -> 38 -minus- smoothed original image with sigma=1
        % fm(:,:,43-46) -> repeat 30-33, with sigma=4
        % fm(:,:,47) -> 43 -minus- smoothed original image with sigma=1
        % ...
        % fm(:,:,89) -> end of that cycle
        % fm(:,:,90) -> variance of last 10 entries in the fm
        % fm(:,:,91) -> normalized smoothed orig.image sigma=2 - smoothed orig.image sigma=50
        % fm(:,:,92) -> original image
        
        fm  = membraneFeatures(im, cs, ms, csHist);
        fm(isnan(fm)) = 0;
        save(featuresFilename,'fm', '-mat','-v7.3');
    else
        load(featuresFilename,'fm', '-mat');    % load membrane features
    end

    updateLoglist(sprintf('Predicting slice: %d...', sliceNo), handles);
    if blockModeSwitch  % crop fm if the block mode is enabled
        fm = fm(yMinShown:yMaxShown, xMinShown:xMaxShown, :);
    end
    imsize = [size(fm,1), size(fm,2)];
    fm = reshape(fm,size(fm,1)*size(fm,2),size(fm,3));

    votes = zeros(imsize(1)*imsize(2),1);
    [y_h, v] = classRF_predict(double(fm), handles.forest);
    votes = v(:,2);
    votes = reshape(votes,imsize);
    votes = double(votes)/max(votes(:));
    
    % store votes for the export
    if get(handles.exportVotesCheck, 'value')  
        if exist('votesOut','var') == 0
            votesOut = zeros([imsize(1), imsize(2), 1, thick]);
            voteIndex = 1;
        end
        votesOut(:,:,1, voteIndex) = votes;
        voteIndex = voteIndex + 1;
    end
    
    if get(handles.skelClosedCheck, 'value')
        skelImg = uint8(bwmorph(skeletonize(votes>=votesThreshold),'dilate',1));
    else
        skelImg = uint8(votes>votesThreshold);
    end
    handles.h.Img{handles.h.Id}.I.setSlice('selection', skelImg, sliceNo);
end

if get(handles.exportVotesCheck, 'value')  
    updateLoglist('======= Exporting votes to matlab =======', handles);
    assignin('base', 'ib_votes', votesOut);
    updateLoglist('Done! variable -> ib_votes(1:height, 1:width, 1, 1:slices)', handles);
end
updateLoglist('======= Prediction finished! =======', handles);
resultTOC = toc(t1);
updateLoglist(sprintf('Elapsed time is %f seconds.',resultTOC), handles);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);

guidata(handles.ib_MembraneDetection, handles);

end

% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
web(fullfile(handles.h.pathMIB, 'techdoc/html/ug_gui_menu_tools_random_forest.html'), '-helpbrowser');
end


function classifierFilenameEdit_Callback(hObject, eventdata, handles)

end
