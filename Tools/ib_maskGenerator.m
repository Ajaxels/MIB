function handles = ib_maskGenerator(handles, type)
% function handles = ib_maskGenerator(handles, type)
% generate the 'Mask' later
%
% Parameters:
% handles: structure with handles of im_browser.m
% type: a type of the mask generator:
% - ''new'' - generate a new mask
% - ''add'' - generate mask and add it to the existing mask
%
% Return values:
% handles: structure with handles of im_browser.m

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 06.04.2016, IB, brief update for 4D datasets

tic

pos = get(handles.maskGenTypePopup,'Value');
fulllist = get(handles.maskGenTypePopup,'String');
text_str = fulllist{pos};
all_sw = get(handles.maskGenPanel2DAllRadio,'Value');   % do for all slices
threeD = get(handles.maskGenPanel3DAllRadio,'Value');   % do in 3D
selected_color = get(handles.ColChannelCombo,'Value')-1;
if selected_color == 0
    msgbox('Please select the color channel!','Error!','error','modal');
    return;
else
    selected_color = get(handles.ColChannelCombo, 'value')-1;
end

outputType = 'mask';
if str2double(get(handles.frangiBWThreshold,'String')) == 0 && strcmp(text_str, 'Frangi filter')
    button = questdlg(sprintf('!!! Warning !!!\nThe result of the Frangi filter with the B/W Thresholding value == 0 is non-thresholded filtered image.\nThe current image will be removed!\n\nAre you sure?'),'Update existing image!','Continue','Cancel','Cancel');
    if strcmp(button, 'Cancel')
        return;
    end;
    outputType = 'image';
end

% set 2D mode when dataset has onle a single section
if handles.Img{handles.Id}.I.no_stacks == 1
    all_sw = 0;
    threeD = 0;
end
if threeD == 1; all_sw = 1; end;     % use set the all_sw when using the 3D mode

if strcmp(outputType, 'image')
    ib_do_backup(handles, 'image', all_sw);
else
    if ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
        if strcmp(handles.Img{handles.Id}.I.maskImg,'') | isempty(handles.Img{handles.Id}.I.maskImg) | isnan(handles.Img{handles.Id}.I.maskImg) %#ok<OR2> % preallocate memory for the mask
            handles.Img{handles.Id}.I.maskImg = zeros(size(handles.Img{handles.Id}.I.img,1),size(handles.Img{handles.Id}.I.img,2),handles.Img{handles.Id}.I.no_stacks,'uint8');
        else
            ib_do_backup(handles, 'mask', all_sw);
        end
    else
        ib_do_backup(handles, 'everything', all_sw);
    end
end

if all_sw
    imgIn = ib_getStack('image', handles, NaN, NaN, selected_color);
    orientation = handles.Img{handles.Id}.I.orientation;
else
    imgIn = ib_getSlice('image', handles, NaN, NaN, selected_color);
    orientation = 4;
end
if numel(imgIn) > 1
    indeces = handles.Img{handles.Id}.I.hROI.getShownIndeces();
else
    indeces = get(handles.roiList, 'value')-1;
end

for indexId = 1:numel(imgIn)
    img = imgIn{indexId};
    datasetOptions.roiId = indeces(indexId);
    permuteSw = 0;
    %mask = zeros(size(img,1), size(img,2), size(img,4), 'uint8');
    switch text_str
        case 'Frangi filter'
            text = get(handles.frangiRange,'String');
            dash = strfind(text, '-');
            Options.FrangiScaleRange = [str2double(text(1:dash-1)) str2double(text(dash+1:end))];
            Options.FrangiScaleRatio = str2double(get(handles.frangiRatio,'String'));
            Options.FrangiBetaOne = str2double(get(handles.frangiBeta1,'String'));
            Options.FrangiBetaTwo = str2double(get(handles.frangiBeta2,'String'));
            Options.FrangiBetaThree = str2double(get(handles.frangiBeta3,'String'));
            Options.BlackWhite = get(handles.frangiBlackonwhite,'Value');
            Options.verbose = 0;
            Options2.bwthreshold = str2double(get(handles.frangiBWThreshold,'String'));
            Options2.sizefilter = str2double(get(handles.frangiBWSize,'String'));
            
            if threeD == 1   % do Frangi filter in 3d
                mask = getFrangiMask(img, Options, Options2, '3d', orientation); %#ok<*AGROW>
                type='new';
            else                % do Frangi filter in 2d
                if all_sw
                    mask = getFrangiMask(img, Options, Options2, '2d', orientation);
                else
                    mask = getFrangiMask(img, Options, Options2, '2d', orientation, 1);
                end
            end
        case 'Strel filter'
            Options.bwthreshold = str2double(get(handles.strelThresholdEdit,'String'));
            Options.sizefilter = str2double(get(handles.strelSizeLimitEdit,'String'));
            Options.strelfill = get(handles.strelfillCheck,'Value');
            Options.blackwhite = get(handles.strelBWCheck,'Value');
            Options.threeD = threeD;
            Options.all_sw = all_sw;
            Options.orientation = orientation;
            Options.currentIndex = 1;
            se_size_txt = get(handles.strelSizeMaskEdit,'String');
            semicolon = strfind(se_size_txt,';');
            if ~isempty(semicolon)  % when 2 values are provided take them
                Options.se_size(1) = str2double(se_size_txt(1:semicolon(1)-1));     % for x and y
                Options.se_size(2) = str2double(se_size_txt(semicolon(1)+1:end));   % for z
            else                    % when only 1 value - calculate the second from the pixSize
                Options.se_size(1) = str2double(se_size_txt);
                Options.se_size(2) = round(Options.se_size(1)*handles.Img{handles.Id}.I.pixSize.x/handles.Img{handles.Id}.I.pixSize.z);
            end
            mask = getStrelMask(img, Options);
        case 'BW thresholding'
            roi_mask = zeros(size(img,1), size(img,2),'uint8')+1;  % everything
            if get(handles.bwFilterManGridCheck, 'value') == 0 % do automatic grid run
                automatic = get(handles.bwFilterAutoCheck,'Value');
                %all_images = get(handles.bwFilterAllCheck,'Value');
                darkthres(1) = str2double(get(handles.bwFilterThrasMinEdit,'String'));  % get min bw threshold
                darkthres(2) = str2double(get(handles.bwFilterThrasMaxEdit,'String'));  % get max bw threshold
                if get(handles.bwFilterGridCheck,'Value')   % grid mode
                    grid_size = handles.corrGridrunSize;
                else
                    grid_size = 0;
                end
                grid_coef = str2double(get(handles.bwConversionCoefEdit,'String'));
                wb = waitbar(0,'Calculating black/white mask...','Name','Mask generator','WindowStyle','modal');
                [filter_out, selection] = get_black_white_filter(...
                    img, darkthres, automatic, roi_mask, grid_size, grid_coef, orientation);
                if size(filter_out,1) > 1
                    mask = filter_out;
                end
                if all_sw
                    ib_setStack('selection', {selection}, handles, NaN, permuteSw, NaN, datasetOptions);
                else
                    ib_setSlice('selection', {selection}, handles, NaN, NaN, NaN, datasetOptions);
                end
                delete(wb);
            else    % do manual grid run
                handles = ManGridBW(handles, roi_mask, type);
                guidata(handles.im_browser, handles);
                return;
            end
        case 'Morphological filters'
            extraList = get(handles.morphPanelTypeSelectPopup, 'string');
            Options.type = extraList{get(handles.morphPanelTypeSelectPopup, 'value')};
            Options.h = str2double(get(handles.morphPanelThresholdEdit,'String'));
            Options.conn = str2double(get(handles.morphPanelConnectivityEdit,'String'));
            Options.threeD = threeD;
            Options.all_sw = all_sw;
            Options.orientation = orientation;
            Options.currentIndex = 1;
            mask = getMorphMask(img, Options);
    end
    
    % permute if the output type is image
    if strcmp(outputType, 'image')
        mask = permute(mask,[1 2 4 3]);
    end
    
    if all_sw
        if strcmp(type,'new')   % make completely new mask
            ib_setStack(outputType, {mask}, handles, NaN, permuteSw, NaN, datasetOptions);
        elseif strcmp(type,'add')   % add generated mask to the preexisting one
            currMask = ib_getStack(outputType, handles, NaN, permuteSw, NaN, datasetOptions);
            currMask{1}(mask==1) = 1;
            ib_setStack(outputType, currMask, handles, NaN, permuteSw, NaN, datasetOptions);
        end
    else
        if strcmp(type,'new')   % make completely new mask
            ib_setSlice(outputType, {mask}, handles, NaN, NaN, NaN, datasetOptions);
        elseif strcmp(type,'add')   % add generated mask to the preexisting one
            currMask = ib_getSlice(outputType, handles, NaN, NaN, NaN, datasetOptions);
            currMask{1}(mask==1) = 1;
            ib_setSlice(outputType, currMask, handles, NaN, NaN, NaN, datasetOptions);
        end
    end
end
if strcmp(outputType, 'mask')
    set(handles.maskShowCheck,'Value',1);
end
end
