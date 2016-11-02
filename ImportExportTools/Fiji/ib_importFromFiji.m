function ib_importFromFiji(handles)
% import dataset from Fiji to im_browser

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 25.09.2015, IB updated to setData3D
% 23.03.2016, IB updated to allow import of subsets that are defined by ROI from Fiji, fixed import of selection and mask

% check for MIJ
if exist('MIJ','class') == 8
    if ~isempty(ij.gui.Toolbar.getInstance)
        ij_instance = char(ij.gui.Toolbar.getInstance.toString);
        % -> ij.gui.Toolbar[canvas1,3,41,548x27,invalid]
        if numel(strfind(ij_instance, 'invalid')) > 0    % instance already exist, but not shown
            Miji_wrapper(true);     % wrapper to Miji.m file
        end
    else
        Miji_wrapper(true);     % wrapper to Miji.m file
    end
else
   Miji_wrapper(true);     % wrapper to Miji.m file
end

datasetName = ib_fijiSelectDataset(handles.preferences.Font);
if isnan(datasetName); return; end;

img = MIJ.getImage(datasetName);
minVal = double(min(min(min(min(img)))));
maxVal = double(max(max(max(max(img)))));
if ndims(img) == 4 
    img = permute(img, [1 2 4 3]);
end
if minVal < 0   % shift the dataset to the positive values
    img = double(img);
    for i=1:size(img,3)
        img(:,:,i,:) = img(:,:,i,:) - minVal;
    end
end
    
if maxVal-minVal < 256  % convert image to uint8
    img = uint8(img);
elseif maxVal-minVal < 65536
    img = uint16(img);
elseif maxVal-minVal < 4294967296    
    img = uint32(img);
else
    msgbox(sprintf('Dataset format problem!'),...
        'Problem!','error');
    return;
end

% define type of the dataset
datasetTypeValue = get(handles.fijiconnectTypePop, 'value');
datasetTypeList = get(handles.fijiconnectTypePop, 'string');
datasetType = datasetTypeList{datasetTypeValue};
options.blockModeSwitch = 0;

if get(handles.roiShowCheck,'value') == 1
    roiNo = get(handles.roiList, 'value');
    totalROINo = numel(get(handles.roiList, 'string'));
    if totalROINo > 2 && roiNo == 1
        msgbox('Please select ROI from the ROI list or unselect the ROI mode!','Select ROI!','warn','modal');
        return;
    end
end

if strcmp(datasetType, 'image')
    if ndims(img) == 3 && size(img, 3) ~= 3
        img = reshape(img, size(img,1),size(img,2),1,size(img,3));
    end
    if get(handles.roiShowCheck,'value') == 1
        ib_setStack('image',{img}, handles, NaN, NaN, NaN);
    else
        handles = handles.Img{handles.Id}.I.replaceDataset(img, handles);    
    end
else
    if get(handles.roiShowCheck,'value') == 0
        if size(img,1) ~= size(handles.Img{handles.Id}.I.img,1) || size(img,2) ~= size(handles.Img{handles.Id}.I.img,2) || size(img,3) ~= size(handles.Img{handles.Id}.I.img,4)
            msgbox(sprintf('Dimensions mismatch!\nImage (HxWxZ) = %d x %d x d pixels\nModel (HxWxZ) = %d x %d x d pixels',...
                size(handles.Img{handles.Id}.I.img,1),size(handles.Img{handles.Id}.I.img,2),size(handles.Img{handles.Id}.I.img,4),...
                size(img,1),size(img,2),size(img,3)),'Error!','error','modal');
            return;
        end
    end
    if strcmp(datasetType, 'model')
        if get(handles.roiShowCheck,'value') == 1
            ib_setStack('model',{img}, handles, NaN, NaN, NaN);
        else
            createModelBtn_Callback(handles.createModelBtn,NaN, handles);
            handles.Img{handles.Id}.I.setData3D('model', img, NaN, 4, NaN, options);
            handles.Img{handles.Id}.I.modelExist = 1;
            % update modelMaterialNames
            for i=1:maxVal-minVal
                handles.Img{handles.Id}.I.modelMaterialNames(i,1) = cellstr(num2str(i));
            end
            updateSegmentationTable(handles);
        end
        modelShowCheck_Callback(handles.modelShowCheck,NaN,handles);
    elseif strcmp(datasetType, 'mask')
        img(img>1) = 1;     % convert to 0-1 range
        if get(handles.roiShowCheck,'value') == 1
            ib_setStack('mask',{img}, handles, NaN, NaN, NaN);
        else
            handles.Img{handles.Id}.I.clearMask();
            handles.Img{handles.Id}.I.setData3D('mask', img, NaN, 4, NaN, options);
        end
        set(handles.maskShowCheck,'Value',1);
    elseif strcmp(datasetType, 'selection')
        img(img>1) = 1;     % convert to 0-1 range
        if get(handles.roiShowCheck,'value') == 1
            ib_setStack('selection',{img}, handles, NaN, NaN, NaN);
        else
            handles.Img{handles.Id}.I.setData3D('selection', img, NaN, 4, NaN, options);
        end
    end
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end