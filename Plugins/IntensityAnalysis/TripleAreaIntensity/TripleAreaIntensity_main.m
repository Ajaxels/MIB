function TripleAreaIntensity_main(handles)
% main function for triple intensity analysis

% Copyright (C) 19.05.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

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

parameterToCalculateList = get(handles.parameterCombo,'String');    % get type of intensity to calculate (min, max, average...)
parameterToCalculateVal = get(handles.parameterCombo,'Value');
parameterToCalculate = parameterToCalculateList{parameterToCalculateVal};
colCh = get(handles.colorChannelCombo, 'value');    % color channel to analyze
% get materials to be analyzed
material1_Index = get(handles.material1Popup, 'value');
material2_Index = get(handles.material2Popup, 'value');
background_Check = get(handles.backgroundCheck, 'value');   % get background values
background_Index = get(handles.backgroundPopup, 'value');   % index of the background material
subtractBg_Check = get(handles.subtractBackgroundCheck, 'value');   % index of the background material
calculateRatioCheck = get(handles.calculateRatioCheck, 'value');    % calculate ratio of material1/material2
additionalThresholdingCheck = get(handles.additionalThresholdingCheck, 'value');    % whether to do additional thresholding of any material
if additionalThresholdingCheck  % clear the mask layer
    addMaterial_Index = get(handles.thresholdingPopup, 'value');
    addMaterial_Shift = str2double(get(handles.thresholdEdit, 'string'));   % shift of intensities from background value for additional thresholding
    handles.h.Img{handles.h.Id}.I.clearMask();
    handles.h.Img{handles.h.Id}.I.maskExist = 1;
    if addMaterial_Index ~= material1_Index && addMaterial_Index ~= material2_Index 
        errordlg(sprintf('Material for additional thresholding should be Material 1 or Material 2!'), 'Wrong material!')
        return;
    end
end

wb = waitbar(0,'Please wait...','Name','Triple Area Intensity...','WindowStyle','modal');
ib_do_backup(handles.h, 'selection', 1);
handles.h.Img{handles.h.Id}.I.hLabels.clearContents();  % remove annotations from the model

warning off MATLAB:xlswrite:AddSheet
% Sheet 1
s = {'TripleAreaIntensity: triple material intensity analysis and ratio calculation'};
s(2,1) = {'Image directory:'};
s(2,2) = {fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'))};
s(3,1) = {['Calculating: ' parameterToCalculate]};
s(3,4) = {['Color channel: ' num2str(colCh)]};

if background_Check
    s(4,4) = {['Background material: ' handles.h.Img{handles.h.Id}.I.modelMaterialNames{background_Index}]};
end

s(6,1) = {'Filename'};
s(6,2) = {'Slice Number'};
if subtractBg_Check
    s(6,3) = cellstr([handles.h.Img{handles.h.Id}.I.modelMaterialNames{material1_Index} '-minus-Bg']);
    s(6,4) = cellstr([handles.h.Img{handles.h.Id}.I.modelMaterialNames{material2_Index} '-minus-Bg']);
else
    s(6,3) = handles.h.Img{handles.h.Id}.I.modelMaterialNames(material1_Index);
    s(6,4) = handles.h.Img{handles.h.Id}.I.modelMaterialNames(material2_Index);
end
s(6,5) = cellstr('Bg');
s(7,5) = cellstr('(background)');
s(6,6) = {'Ratio'};
s(7,6) = {[handles.h.Img{handles.h.Id}.I.modelMaterialNames{material1_Index} '/' handles.h.Img{handles.h.Id}.I.modelMaterialNames{material2_Index}]};
if additionalThresholdingCheck 
    s(4,8) = {['Intensity shift for thresholding: ' num2str(addMaterial_Shift)]};
    s(6,7) = {'Intensity of thresholded'};
    if subtractBg_Check
        s(7,7) = {[handles.h.Img{handles.h.Id}.I.modelMaterialNames{addMaterial_Index} '-minus-Bg']};
    else
        s(7,7) = handles.h.Img{handles.h.Id}.I.modelMaterialNames(addMaterial_Index);
    end
end

options.blockModeSwitch = 0; 
img = handles.h.Img{handles.h.Id}.I.getData3D('image', NaN, 4, colCh, options);    % get desired color channel from the image
model1 = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, material1_Index, options);    % get model 1
model2 = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, material2_Index, options);    % get model 2
if background_Check     % get background material
    background = handles.h.Img{handles.h.Id}.I.getData3D('model', NaN, 4, background_Index, options);    % get model 2
else
    background = NaN;
end
selection = zeros(size(model1), class(model1));   % create new selection layer 

if isKey(handles.h.Img{handles.h.Id}.I.img_info, 'SliceName')   % when filenames are present use them
    inputFn = handles.h.Img{handles.h.Id}.I.img_info('SliceName');
    if numel(inputFn) < size(img,4)
        inputFn = repmat(inputFn(1),[size(img,4),1]);
    end
else
    [~,inputFn, ext] = fileparts(handles.h.Img{handles.h.Id}.I.img_info('Filename'));
    inputFn = [inputFn ext];
end

rowId = 8;  % a row for the excel file
Ratio = []; % a variable to keep ratios of intensities   
%%
for sliceId = 1:size(model1, 3)
    waitbar(sliceId/size(model1, 3),wb);
    CC1 = bwconncomp(model1(:,:,sliceId),8);
    if CC1.NumObjects == 0; continue; end;  % check whether the materials exist on the current slice
    STATS1 = regionprops(CC1, 'Centroid','PixelIdxList');
    CC2 = bwconncomp(model2(:,:,sliceId),8);
    STATS2 = regionprops(CC2, 'Centroid','PixelIdxList');
    if CC1.NumObjects ~= CC2.NumObjects; continue; end;

    BG_CC.NumObjects = 0;
    BG_STATS = [];
    if background_Check
        BG_CC = bwconncomp(background(:,:,sliceId),8);
        BG_STATS = regionprops(BG_CC, 'Centroid','PixelIdxList');
    end
   
    %% find distances between centroids of material 1 and material 2
    X1 = zeros([numel(STATS1) 2]);
    X2 = zeros([numel(STATS2) 2]);
    for i=1:numel(STATS1)
        X1(i,:) = STATS1(i).Centroid;
        X2(i,:) = STATS2(i).Centroid;
    end
    idx = findMatchingPairs(X1, X2);
    
    %% find distances between centroids of material 1 and background
    if background_Check == 1  % when number of objects for material 1 match number of Bg objects - find matching pairs, otherwise use mean value for the background
        X3 = zeros([numel(BG_STATS) 2]);
        for i=1:numel(BG_STATS)
            X3(i,:) = BG_STATS(i).Centroid;
        end
        if CC1.NumObjects == BG_CC.NumObjects   % find matching to material 1 background
            bg_idx =  findMatchingPairs(X1, X3);   % indeces of the matching objects, i.e. STATS1(objId) =match= BG_STATS(bg_idx(objId))
        elseif BG_CC.NumObjects > 0     % average all background areas
            bg_idx = [];
        end
    else
        bg_idx = [];
    end
    
    %% calculate intensities
    Intensity1 = zeros([numel(STATS1),1]);  % reserve space for intensities of the 1st material
    Intensity2 = zeros([numel(STATS2),1]);  % reserve space for intensities of the 2nd material
    Background = zeros([numel(BG_STATS),1]);  % reserve space for intensities of the background
    BackgroundStd = zeros([numel(BG_STATS),1]);  % reserve space for intensities of the background standard deviation
    if additionalThresholdingCheck
        if addMaterial_Index == material1_Index 
            IntensityA = zeros([numel(STATS1),1]); 
            AD_STATS = STATS1;
        else
            IntensityA = zeros([numel(STATS2),1]); 
            AD_STATS = STATS2;
        end
        mask = zeros(size(model1, 1), size(model1, 2), 'uint8');    % create empty mask layer
    end
    slice = squeeze(img(:,:,:,sliceId));
    
    %% when number of background objects is different from number of material 1 objects -> average Bg
    if background_Check == 1 && CC1.NumObjects ~= BG_CC.NumObjects
        IntVec = [];
        for bgId = 1:numel(BG_STATS)
            IntVec = [IntVec; slice(BG_STATS(bgId).PixelIdxList)];
        end
        
        switch parameterToCalculate
            case 'Mean intensity'
                Background = mean(IntVec);
            case 'Min intensity'
                Background = min(IntVec);
            case 'Max intensity'
                Background = max(IntVec);
            case 'Sum intensity'
                Background = sum(IntVec);
        end
        clear IntVec;
%         for bgId = 1:numel(BG_STATS)
%             switch parameterToCalculate
%                 case 'Mean intensity'
%                     Background(bgId) = mean(slice(BG_STATS(bgId).PixelIdxList));
%                 case 'Min intensity'
%                     Background(bgId) = min(slice(BG_STATS(bgId).PixelIdxList));
%                 case 'Max intensity'
%                     Background(bgId) = max(slice(BG_STATS(bgId).PixelIdxList));
%                 case 'Sum intensity'
%                     Background(bgId) = sum(slice(BG_STATS(bgId).PixelIdxList));
%             end
%             %BackgroundStd(bgId) = std(slice(BG_STATS(bgId).PixelIdxList));
%         end
%         Background = mean(Background);
    end
    
    %% calculate intensities of material 1 and material 2
    for objId = 1:numel(STATS1)
        pnts(1,:) = STATS1(objId).Centroid;
        pnts(2,:) = STATS2(idx(objId)).Centroid;
        selection(:,:,sliceId) = ib_connectPoints(selection(:,:,sliceId), pnts);    % connect centroids between Material 1 and Material 2 for checking
        if numel(bg_idx) > 0    % connect centroids of material 1 and Bg
            pnts2(1,:) = STATS1(objId).Centroid;
            pnts2(2,:) = BG_STATS(bg_idx(objId)).Centroid;
            selection(:,:,sliceId) = ib_connectPoints(selection(:,:,sliceId), pnts2);    % connect centroids for checking
        end
        
        switch parameterToCalculate
            case 'Mean intensity'
                Intensity1(objId) = mean(slice(STATS1(objId).PixelIdxList));
                Intensity2(objId) = mean(slice(STATS2(idx(objId)).PixelIdxList));
                if background_Check == 1 && CC1.NumObjects == BG_CC.NumObjects  
                    Background(objId) = mean(slice(BG_STATS(bg_idx(objId)).PixelIdxList));
                end
                if additionalThresholdingCheck
                    indecesId = find(slice(AD_STATS(objId).PixelIdxList) > (Background(min([numel(Background) objId]))+addMaterial_Shift));    % get indeces with intensities higher than bg+shift
                    PixelIdxList = AD_STATS(objId).PixelIdxList(indecesId);   %#ok<FNDSB> % generate new indeces
                    mask(PixelIdxList) = 1;     % generate mask
                    IntensityA(objId) = mean(slice(PixelIdxList));
                end
            case 'Min intensity'
                Intensity1(objId) = min(slice(STATS1(objId).PixelIdxList));
                Intensity2(objId) = min(slice(STATS2(idx(objId)).PixelIdxList));
                if background_Check == 1 && CC1.NumObjects == BG_CC.NumObjects  
                    Background(objId) = min(slice(BG_STATS(bg_idx(objId)).PixelIdxList));
                end
                if additionalThresholdingCheck
                    indecesId = find(slice(AD_STATS(objId).PixelIdxList) > (Background(min([numel(Background) objId]))+addMaterial_Shift));    % get indeces with intensities higher than bg+shift
                    PixelIdxList = AD_STATS(objId).PixelIdxList(indecesId);   %#ok<FNDSB> % generate new indeces
                    mask(PixelIdxList) = 1;     % generate mask
                    IntensityA(objId) = min(slice(PixelIdxList));
                end
            case 'Max intensity'
                Intensity1(objId) = max(slice(STATS1(objId).PixelIdxList));
                Intensity2(objId) = max(slice(STATS2(idx(objId)).PixelIdxList));
                if background_Check == 1 && CC1.NumObjects == BG_CC.NumObjects  
                    Background(objId) = max(slice(BG_STATS(bg_idx(objId)).PixelIdxList));
                end
                if additionalThresholdingCheck
                    indecesId = find(slice(AD_STATS(objId).PixelIdxList) > (Background(min([numel(Background) objId]))+addMaterial_Shift));    % get indeces with intensities higher than bg+shift
                    PixelIdxList = AD_STATS(objId).PixelIdxList(indecesId);   %#ok<FNDSB> % generate new indeces
                    mask(PixelIdxList) = 1;     % generate mask
                    IntensityA(objId) = max(slice(PixelIdxList));
                end
            case 'Sum intensity'
                Intensity1(objId) = sum(slice(STATS1(objId).PixelIdxList));
                Intensity2(objId) = sum(slice(STATS2(idx(objId)).PixelIdxList));
                if background_Check == 1 && CC1.NumObjects == BG_CC.NumObjects  
                    Background(objId) = sum(slice(BG_STATS(bg_idx(objId)).PixelIdxList));
                end
                if additionalThresholdingCheck
                    indecesId = find(slice(AD_STATS(objId).PixelIdxList) > (Background(min([numel(Background) objId]))+addMaterial_Shift));    % get indeces with intensities higher than bg+shift
                    PixelIdxList = AD_STATS(objId).PixelIdxList(indecesId);   %#ok<FNDSB> % generate new indeces
                    mask(PixelIdxList) = 1;     % generate mask
                    IntensityA(objId) = sum(slice(PixelIdxList));
                end
        end
        
        % subtract background
        if subtractBg_Check == 1 && background_Check == 1
            Intensity1(objId) = Intensity1(objId) - Background(min([numel(Background) objId]));
            Intensity2(objId) = Intensity2(objId) - Background(min([numel(Background) objId]));
            if additionalThresholdingCheck
                IntensityA(objId) = IntensityA(objId) - Background(min([numel(Background) objId]));
            end
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
        if background_Check
            % save background
            if CC1.NumObjects == BG_CC.NumObjects
                s(rowId, 5) = {num2str(Background(objId))};
            elseif objId==1     % save averaged background once
                s(rowId, 5) = {num2str(Background(1))};
            end
        end
        if calculateRatioCheck 
            % generate ratio, intensity2/intensity1
            s(rowId, 6) = {num2str(Intensity1(objId)/Intensity2(objId))};
        end
        
        if additionalThresholdingCheck
            % report intensities of additional thresholding
            s(rowId, 7) = {num2str(IntensityA(objId))};
        end
        
        handles.h.Img{handles.h.Id}.I.hLabels.addLabels(num2str(Intensity1(objId)), [sliceId, round(X1(objId,:))]);
        handles.h.Img{handles.h.Id}.I.hLabels.addLabels(num2str(Intensity2(objId)), [sliceId, round(X2(idx(objId),:))]);
        
        if background_Check == 1 && CC1.NumObjects == BG_CC.NumObjects   
            handles.h.Img{handles.h.Id}.I.hLabels.addLabels(num2str(Background(objId)), [sliceId, round(X3(bg_idx(objId),:))]);
        end
        if additionalThresholdingCheck
            try
                if addMaterial_Index == material1_Index
                    coordinates = round(X1(objId,:));
                else
                    coordinates = round(X2(idx(objId),:));
                end
                coordinates(2) = coordinates(2) + 18;    % shift coordinate for text
                handles.h.Img{handles.h.Id}.I.hLabels.addLabels(num2str(IntensityA(objId)), [sliceId, coordinates]);
            catch err;
            end
        end
        
        rowId = rowId + 1;
    end
    
    if background_Check == 1 && CC1.NumObjects ~= BG_CC.NumObjects  % add text of averaged background
        for bgId = 1:numel(BG_STATS)    
            handles.h.Img{handles.h.Id}.I.hLabels.addLabels(num2str(Background(min([numel(Background) bgId]))), [sliceId, round(X3(bgId,:))]);
        end
    end
    
    if calculateRatioCheck
        Ratio = [Ratio; Intensity1./Intensity2]; %#ok<AGROW>
    end
    
    % do additional thresholding
    if additionalThresholdingCheck  
         handles.h.Img{handles.h.Id}.I.setFullSlice('mask', mask, sliceId);
    end
    
    rowId = rowId + 1;
end
handles.h.Img{handles.h.Id}.I.setData3D('selection', selection, NaN, 4, NaN, options);

if get(handles.savetoExcel, 'value')
    waitbar(1, wb, 'Generating Excel file...');
    xlswrite2(fn, s, 'Sheet1', 'A1');
end
% turn on annotations
set(handles.h.showAnnotationsCheck, 'value', 1);
handles.h.Img{handles.h.Id}.I.plotImage(handles.h.imageAxes, handles.h, 0);

% plot histogram
if calculateRatioCheck
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
guidata(handles.TripleAreaIntensity, handles);
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
