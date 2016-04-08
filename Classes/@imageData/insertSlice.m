function handles = insertSlice(obj, img, handles, insertPosition, img_info)
% function handles = insertSlice(obj, img, handles, insertPosition, img_info)
% Insert a slice or a dataset into the existing volume
%
% Parameters:
% img: new 2D-4D image stack to insert
% handles: handles structure from im_browser
% insertPosition: @b [optional] position where to insert the new slice/volume
% starting from @b 1. When omitted or @em NaN add img to the end of the dataset
% img_info: @b [optional] containers Map with parameters of the dataset to insert
%
% Return values:
% handles: handles structure from im_browser

%| 
% @b Examples:
% @code handles = imageData.insertSlice(img, handles, 1);     // insert img to the beginning of the opened dataset @endcode
% @code handles = insertSlice(obj, img); // Call within the class; add img to the end of the opened dataset @endcode

% Copyright (C) 05.03.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

if nargin < 5; img_info = containers.Map; end;
if nargin < 4; insertPosition = NaN; end;

if size(obj.img,1) ~= size(img, 1) || size(obj.img,2) ~= size(img, 2) || size(obj.img,3) ~= size(img, 3)
    button = questdlg(sprintf('Warning!\nSome of the image dimensions mismatch.\nContinue anyway?'),'Dimensions mismatch!','Continue','Cancel','Continue');
    if strcmp(button,'Cancel'); handles = NaN; return; end;
end
if isnan(insertPosition) || insertPosition > size(obj.img,4)    % define start position at the end of the opened dataset
    insertPosition = size(obj.img,4)+1;
end
wb = waitbar(0,sprintf('Insert dataset to position: %d\nPlease wait...', insertPosition),'Name','Insert dataset...','WindowStyle','modal');

% store dimensions of the existing datasets
D1_y = size(obj.img,1);
D1_x = size(obj.img,2);
D1_c = size(obj.img,3);
D1_z = size(obj.img,4);

% store dimensions of the inserted datasets
D2_y = size(img,1);
D2_x = size(img,2);
D2_c = size(img,3);
D2_z = size(img,4);


cMax = max([D1_c D2_c]);
xMax = max([D1_x D2_x]);
yMax = max([D1_y D2_y]);

imgOut = zeros([yMax, xMax, cMax, D1_z+D2_z], class(obj.img));
waitbar(.05, wb);
if insertPosition == 1  % insert dataset in the beginning of the opened dataset
    %Z1_part1 = [size(img,4)+1 size(img,4)+1];
    Z1_part2 = [D2_z+1 D2_z+D1_z];
    Z2_part1 = [1 D2_z];
    %Z2_part2 = [size(img,4) size(img,4)];
    imgOut(1:D1_y, 1:D1_x, 1:D1_c, Z1_part2(1):Z1_part2(2)) = obj.img;
    imgOut(1:D2_y, 1:D2_x, 1:D2_c, Z2_part1(1):Z2_part1(2)) = img;
    obj.img = imgOut;
    waitbar(.4, wb);
    % resize model
    if strcmp(obj.model_type, 'uint6') && ~isnan(obj.model(1))     % resize uint6 type of the model
        imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
        imgOut(1:D1_y, 1:D1_x, Z1_part2(1):Z1_part2(2)) = obj.model;
        obj.model = imgOut;
        waitbar(.9, wb);
    else        % resize other types of models
        if obj.modelExist == 1       % resize model layer
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part2(1):Z1_part2(2)) = obj.model;
            obj.model = imgOut;
        end
        waitbar(.6, wb);
        if obj.maskExist == 1      % resize mask layer
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part2(1):Z1_part2(2)) = obj.maskImg;
            obj.maskImg = imgOut;
        end
        waitbar(.8, wb);
        if ~isnan(obj.selection(1))    % resize selection
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part2(1):Z1_part2(2)) = obj.selection;
            obj.selection = imgOut;
        end
        waitbar(.9, wb);
    end
elseif insertPosition == D1_z+1 % add dataset to the end of the existing dataset
    Z1_part1 = [1 D1_z];
    %Z1_part2 = [size(obj.img,4) size(obj.img,4)];
    %Z2_part1 = [size(obj.img,4)+1 size(obj.img,4)+size(img,4)];
    Z2_part2 = [D1_z+1 D1_z+D2_z];
    imgOut(1:D1_y, 1:D1_x, 1:D1_c, Z1_part1(1):Z1_part1(2)) = obj.img;
    imgOut(1:D2_y, 1:D2_x, 1:D2_c, Z2_part2(1):Z2_part2(2)) = img;
    obj.img = imgOut;
    waitbar(.4, wb);
    % resize model
    if strcmp(obj.model_type, 'uint6') && ~isnan(obj.model(1))     % resize uint6 type of the model
        imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
        imgOut(1:D1_y, 1:D1_x, Z1_part1(1):Z1_part1(2)) = obj.model;
        obj.model = imgOut;
        waitbar(.9, wb);
    else        % resize other types of models
        if obj.modelExist       % resize model layer
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part1(1):Z1_part1(2)) = obj.model;
            obj.model = imgOut;
        end
        waitbar(0.6, wb);
        if obj.maskExist       % resize mask layer
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part1(1):Z1_part1(2)) = obj.maskImg;
            obj.maskImg = imgOut;
        end
        waitbar(.7, wb);
        if ~isnan(obj.selection(1))    % resize selection
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part1(1):Z1_part1(2)) = obj.selection;
            obj.selection = imgOut;
        end
        waitbar(.9, wb);
    end
else        % insert dataset inside the existing dataset
    Z1_part1 = [1 insertPosition-1];
    Z1_part2 = [insertPosition+D2_z D2_z+D1_z];
    Z2_part1 = [insertPosition insertPosition+D2_z-1];
    %Z2_part2 = [insertPosition+size(img,4) insertPosition+size(img,4)];
    imgOut(1:D1_y, 1:D1_x, 1:D1_c, Z1_part1(1):Z1_part1(2)) = obj.img(:,:,:,1:Z1_part1(2));
    imgOut(1:D2_y, 1:D2_x, 1:D2_c, Z2_part1(1):Z2_part1(2)) = img;
    imgOut(1:D1_y, 1:D1_x, 1:D1_c, Z1_part2(1):Z1_part2(2)) = obj.img(:,:,:,Z1_part1(2)+1:end);
    obj.img = imgOut;
    waitbar(.4, wb);
    % resize model
    if strcmp(obj.model_type, 'uint6') && ~isnan(obj.model(1))     % resize uint6 type of the model
        imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
        imgOut(1:D1_y, 1:D1_x, Z1_part1(1):Z1_part1(2)) = obj.model(:,:,1:Z1_part1(2));
        imgOut(1:D1_y, 1:D1_x, Z1_part2(1):Z1_part2(2)) = obj.model(:,:,Z1_part1(2)+1:end);
        obj.model = imgOut;
        waitbar(.9, wb);
    else        % resize other types of models
        if obj.modelExist       % resize model layer
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part1(1):Z1_part1(2)) = obj.model(:,:,1:Z1_part1(2));
            imgOut(1:D1_y, 1:D1_x, Z1_part2(1):Z1_part2(2)) = obj.model(:,:,Z1_part1(2)+1:end);
            obj.model = imgOut;
        end
        waitbar(.6, wb);
        if obj.maskExist       % resize mask layer
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part1(1):Z1_part1(2)) = obj.maskImg(:,:,1:Z1_part1(2));
            imgOut(1:D1_y, 1:D1_x, Z1_part2(1):Z1_part2(2)) = obj.maskImg(:,:,Z1_part1(2)+1:end);
            obj.maskImg = imgOut;
        end
        waitbar(.7, wb);
        if ~isnan(obj.selection(1))    % resize selection
            imgOut = zeros([yMax, xMax, D1_z+D2_z], 'uint8');
            imgOut(1:D1_y, 1:D1_x, Z1_part1(1):Z1_part1(2)) = obj.selection(:,:,1:Z1_part1(2));
            imgOut(1:D1_y, 1:D1_x, Z1_part2(1):Z1_part2(2)) = obj.selection(:,:,Z1_part1(2)+1:end);
            obj.selection = imgOut;
        end
        waitbar(.9, wb);
    end
     
end
clear imgOut;

obj.colors = cMax;
obj.width = xMax;
obj.height = yMax;
obj.no_stacks = size(obj.img,4);

obj.img_info('Height') = yMax;
obj.img_info('Width') = xMax;
obj.img_info('Stacks') = obj.no_stacks;
obj.updateBoundingBox();

if isKey(obj.img_info, 'SliceName')
    sliceNames = obj.img_info('SliceName');
    % generate vector of slice names
    if numel(sliceNames) == 1; sliceNames = repmat(sliceNames,[D1_z 1]);   end;
    
    if isempty(img_info)
        sliceNamesNew = {''};
    else
        sliceNamesNew = img_info('SliceName');
    end
    if numel(sliceNamesNew) == 1; sliceNamesNew = repmat(sliceNamesNew,[D2_z 1]);   end;
    
    if insertPosition == D1_z+1     % end of the dataset
        sliceNames = [sliceNames; sliceNamesNew];
    elseif insertPosition == 1
        sliceNames = [sliceNamesNew; sliceNames];
    else
        sliceNames = [sliceNames(1:insertPosition-1); sliceNamesNew; sliceNames(insertPosition:end)];
        
        %sliceNames(numel(sliceNames)+1:numel(sliceNames)+D2_z) = sliceNamesNew;
    end
    
%     if isempty(img_info)
%         sliceNames(numel(sliceNames)+1:numel(sliceNames)+D2_z) = {''};
%     else
%         sliceNamesNew = img_info('SliceName');
%         sliceNames(numel(sliceNames)+1:numel(sliceNames)+D2_z) = sliceNamesNew;
%     end
    obj.img_info('SliceName') = sliceNames;
end
obj.updateImgInfo(sprintf('Insert dataset [%dx%dx%dx%d] at position %d', D2_y, D2_x, D2_c, D2_z, insertPosition));  % update log
handles = updateGuiWidgets(handles);
waitbar(1, wb);
delete(wb);
end