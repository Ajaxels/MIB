function imgRGB =  getRGBimage(obj, handles, options, sImgIn)
% function imgRGB =  getRGBimage(obj, handles, options, sImgIn)
% Generate RGB image from all layers that have to be shown on the screen.
%
% Parameters:
% handles: handles structure from im_browser
% options: a structure with extra parameters:
% @li .mode -> @b full -> return RGB image of the whole slice; @b shown -> return RGB image of the shown area only
% @li .resize -> @b yes -> resize RGB image to the current magnification value [@b default]; @b no -> return the image in the original resolution
% @li .sliceNo [@em optional] -> index of a slice to show
% @li .markerType [@em optional] -> @em default NaN, type of annotations: when @b both show a label next to the position marker,
%                           when @b marker - show only the marker without the label, when
%                           @b text - show only text without marker
% @li .t -> [@em optional], [tmin, tmax] the time point of the dataset; default is the currently shown time point
% sImgIn: a custom 3D stack to grab a single 2D slice from
%
% Return values:
% imgRGB: - RGB image with combined layers, [1:height, 1:width, 1:3]
%
%| @b Examples:
% @code options.mode = 'shown'; @endcode
% @code imageData.Ishown = imageData.getRGBimage(handles, options);     // to get cropped 2D RGB image of the shown area @endcode
% @code imageData.Ishown = getRGBimage(obj, handles, options);// Call within the class; to get cropped 2D RGB image of the shown area @endcode

% Copyright (C) 30.10.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 24.09.2014 fixed annotations for snapshots, improved rendering of large images in the nearest mode
% 30.11.2015 added image resampling for magnifications < 1 to the end of procedure
% 18.09.2016, changed .slices to cells
% 03.02.2016, added .t field to options
% 26.10.2016, IB, updated for segmentation table

if ~isfield(options, 'resize'); options.resize = 'yes'; end;
if ~isfield(options, 'markerType'); options.markerType = NaN; end;
if ~isfield(options, 't'); options.t = [obj.slices{5}(1) obj.slices{5}(1)]; end;

if strcmp(options.resize, 'no')
    magnificationFactor = 1;
else
    magnificationFactor = obj.magFactor;
end

panModeException = 0; % otherwise in the pan mode the image may be huge
if strcmp(options.mode, 'full') && magnificationFactor < 1 % to use with the pan mode
    panModeException = 1;
end
if isfield(options, 'sliceNo')      % overwrite current slice number with the provided
    sliceToShowIdx = options.sliceNo;
else
    sliceToShowIdx = obj.slices{obj.orientation}(1);
end

% get image
if nargin < 4
    %z_current = obj.current_yxz(3);
    if strcmp(options.mode,'full')
        sImgIn = obj.getFullSlice('image', sliceToShowIdx, NaN, NaN, NaN, options);
    else
        sImgIn = obj.getSliceToShow('image', sliceToShowIdx, NaN, NaN, NaN, options);
    end
    colortype = obj.img_info('ColorType');
    currViewPort = obj.viewPort;    % copy view port information
    showModelSwitch = get(handles.modelShowCheck,'Value');  % whether or not show model above the image
    showMaskSwitch = get(handles.maskShowCheck,'Value');  % whether or not show mask above the image
else
    if size(sImgIn,3) > 1     % define color type for provided image
        colortype = 'truecolor';
    else
        colortype = 'grayscale';
    end
    currViewPort.min =  0;    % generate viewPort information, needed for cases when sImgIn has different class from obj.img
    currViewPort.max =  intmax(class(sImgIn));    % generate viewPort information
    currViewPort.gamma =  1;    % generate viewPort information
    %magnificationFactor = 1;

    showModelSwitch = 0;    % do not show the model
    showMaskSwitch = 0;     % do not show the mask
%     if strcmp(get(handles.toolbarBlockModeSwitch,'State'),'off')
%         sImgIn = obj.getSliceToShow('custom', sliceToShowIdx, obj.orientation,obj.slices{3},sImgIn);
%     end
end

% resize image to show, except the 'full' case with magFactor > 1
if panModeException == 1 % to use with the pan mode
    sImg = sImgIn;
else
    if magnificationFactor > 1  % do not upscale images until the end of procedure
        if strcmp(handles.preferences.resize,'nearest') ||  strcmp(colortype, 'indexed') % tweak to make resizing faster in the nearest mode, may result in different image sizes compared to imresize method
            sImg = sImgIn(round(.51:magnificationFactor:end+.49),round(.51:magnificationFactor:end+.49),:);     % NOTE! the image size may be different from the imresize method
        else
            for colCh = 1:size(sImgIn,3);
                if colCh==1;
%                     if strcmp(colortype, 'indexed')     % only nearest neighborhood for the indexed images
%                         sImg = imresize(sImgIn(:,:,colCh), 1/magnificationFactor, 'nearest');
%                     else
                          sImg = imresize(sImgIn(:,:,colCh), 1/magnificationFactor, handles.preferences.resize); 
%                     end
                else
%                     if strcmp(colortype, 'indexed')     % only nearest neighborhood for the indexed images
%                         sImg(:,:,colCh) = imresize(sImgIn(:,:,colCh), 1/magnificationFactor, 'nearest');
%                     else
                        sImg(:,:,colCh) = imresize(sImgIn(:,:,colCh), 1/magnificationFactor, handles.preferences.resize);
%                     end
                end
            end
        end
    else
        sImg = sImgIn;
    end
end
clear sImgIn;

% hide image
if get(handles.hideImageCheck,'Value') % hide image
    sImg = zeros(size(sImg),class(sImg));
end;

% stretch image for preview
if get(handles.liveStretchCheck, 'value')
    for i=1:size(sImg,3)
        sImg(:,:,i) = imadjust(sImg(:,:,i) ,stretchlim(sImg(:,:,i),[0 1]),[]);
    end
end

% get the segmentation model if neeeded
if showModelSwitch == 1 && obj.modelExist % whether to show model
    if strcmp(options.mode,'full')
        sOver1 = obj.getFullSlice('model', sliceToShowIdx);
    else
        sOver1 = obj.getSliceToShow('model', sliceToShowIdx);
    end
    if panModeException == 0 && magnificationFactor > 1
        if strcmp(handles.preferences.resize,'nearest') ||  strcmp(colortype, 'indexed')    % because no matter of the resampling way, the indexed images are resampled via nearest
            sOver1 = sOver1(round(.51:magnificationFactor:end+.49),round(.51:magnificationFactor:end+.49));     % NOTE! the image size may be different from the imresize method
        else
            sOver1 = imresize(sOver1, 1/magnificationFactor, 'nearest');
        end
    end
else
    sOver1 = NaN;
end

% get the mask model if needed
if showMaskSwitch == 1 && obj.maskExist % whether to show filter model
    if strcmp(options.mode,'full')
        sOver2 = obj.getFullSlice('mask', sliceToShowIdx);
    else
        sOver2 = obj.getSliceToShow('mask', sliceToShowIdx);
    end
    if panModeException == 0 && magnificationFactor > 1
        if strcmp(handles.preferences.resize,'nearest') ||  strcmp(colortype, 'indexed')    % because no matter of the resampling way, the indexed images are resampled via nearest
            sOver2 = sOver2(round(.51:magnificationFactor:end+.49),round(.51:magnificationFactor:end+.49));     % NOTE! the image size may be different from the imresize method
        else
            sOver2 = imresize(sOver2, 1/magnificationFactor, 'nearest');    
        end
    end
else
    sOver2 = NaN;
end

% get the selection model
if strcmp(handles.preferences.disableSelection, 'no')
    if strcmp(options.mode,'full')
        selectionModel = obj.getFullSlice('selection', sliceToShowIdx);
    else
        selectionModel = obj.getSliceToShow('selection', sliceToShowIdx);
    end
    if panModeException == 0 && magnificationFactor > 1
        if strcmp(handles.preferences.resize,'nearest')  ||  strcmp(colortype, 'indexed')   % because no matter of the resampling way, the indexed images are resampled via nearest
            selectionModel = selectionModel(round(.51:magnificationFactor:end+.49),round(.51:magnificationFactor:end+.49));     % NOTE! the image size may be different from the imresize method
        else
            selectionModel = imresize(selectionModel, 1/magnificationFactor, 'nearest');
        end
    end
else
    selectionModel = NaN;
end

max_int = double(intmax(class(sImg)));
colorScale = max_int; % coefficient for scaling the colors

selectedColorsLUT = obj.lutColors(obj.slices{3},:);     % take LUT colors for the selected color channels

switch colortype
    case 'grayscale'
        if currViewPort.min(1) ~= 0 || currViewPort.max(1) ~= max_int || currViewPort.gamma ~= 1
            sImg = imadjust(sImg,[currViewPort.min(1)/max_int currViewPort.max(1)/max_int],[0 1],currViewPort.gamma(1));
        end
        if get(handles.lutCheckbox,'value')     % use LUT for colors
            R = sImg*selectedColorsLUT(1,1);
            G = sImg*selectedColorsLUT(1,2);
            B = sImg*selectedColorsLUT(1,3);
        else
            R = sImg;
            G = sImg;
            B = sImg;
        end
    case 'indexed'
        cmap = obj.img_info('Colormap');
        sImg = uint8(ind2rgb(sImg, cmap)*255);
        R = sImg(:,:,1);
        G = sImg(:,:,2);
        B = sImg(:,:,3);

    otherwise
        if get(handles.lutCheckbox,'value')     % use LUT for colors
            %adjImg = imadjust(sImg(:,:,1),[currViewPort.min(obj.slices{3}(1))*brightness_coef/max_int currViewPort.max(obj.slices{3}(1))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
            adjImg = imadjust(sImg(:,:,1),[currViewPort.min(obj.slices{3}(1))/max_int currViewPort.max(obj.slices{3}(1))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
            R = adjImg*selectedColorsLUT(1,1);
            G = adjImg*selectedColorsLUT(1,2);
            B = adjImg*selectedColorsLUT(1,3);
            
            if numel(obj.slices{3} > 1)
                for i=2:numel(obj.slices{3})
                    adjImg = imadjust(sImg(:,:,i),[currViewPort.min(obj.slices{3}(i))/max_int currViewPort.max(obj.slices{3}(i))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(i)));
                    R = R + adjImg*selectedColorsLUT(i, 1);
                    G = G + adjImg*selectedColorsLUT(i, 2);
                    B = B + adjImg*selectedColorsLUT(i, 3);
                end
            end
        else
            if numel(obj.slices{3}) > 3
                R = imadjust(sImg(:,:,1),[currViewPort.min(1)/max_int currViewPort.max(1)/max_int],[0 1],currViewPort.gamma(1));
                G = imadjust(sImg(:,:,2),[currViewPort.min(2)/max_int currViewPort.max(2)/max_int],[0 1],currViewPort.gamma(2));
                B = imadjust(sImg(:,:,3),[currViewPort.min(3)/max_int currViewPort.max(3)/max_int],[0 1],currViewPort.gamma(3));
            elseif numel(obj.slices{3}) == 3
                R = imadjust(sImg(:,:,1),[currViewPort.min(obj.slices{3}(1))/max_int currViewPort.max(obj.slices{3}(1))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
                G = imadjust(sImg(:,:,2),[currViewPort.min(obj.slices{3}(2))/max_int currViewPort.max(obj.slices{3}(2))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(2)));
                B = imadjust(sImg(:,:,3),[currViewPort.min(obj.slices{3}(3))/max_int currViewPort.max(obj.slices{3}(3))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(3)));
            elseif numel(obj.slices{3}) == 2
                if obj.colors == 3 || obj.slices{3}(end) < 4
                    if obj.slices{3}(1) ~= 1
                        R = zeros(size(sImg,1),size(sImg,2),class(sImg));
                        G = imadjust(sImg(:,:,1),[currViewPort.min(obj.slices{3}(1))/max_int currViewPort.max(obj.slices{3}(1))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
                        B = imadjust(sImg(:,:,2),[currViewPort.min(obj.slices{3}(2))/max_int currViewPort.max(obj.slices{3}(2))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(2)));
                    elseif obj.slices{3}(2) ~= 2
                        R = imadjust(sImg(:,:,1),[currViewPort.min(obj.slices{3}(1))/max_int currViewPort.max(obj.slices{3}(1))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
                        G = zeros(size(sImg,1),size(sImg,2),class(sImg));
                        B = imadjust(sImg(:,:,2),[currViewPort.min(obj.slices{3}(2))/max_int currViewPort.max(obj.slices{3}(2))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(2)));
                    else
                        R = imadjust(sImg(:,:,1),[currViewPort.min(obj.slices{3}(1))/max_int currViewPort.max(obj.slices{3}(1))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
                        G = imadjust(sImg(:,:,2),[currViewPort.min(obj.slices{3}(2))/max_int currViewPort.max(obj.slices{3}(2))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
                        B = zeros(size(sImg,1),size(sImg,2),class(sImg));
                    end
                else
                    R = imadjust(sImg(:,:,1),[currViewPort.min(obj.slices{3}(1))/max_int currViewPort.max(obj.slices{3}(1))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
                    G = imadjust(sImg(:,:,2),[currViewPort.min(obj.slices{3}(2))/max_int currViewPort.max(obj.slices{3}(2))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(2)));
                    B = zeros(size(sImg,1),size(sImg,2),class(sImg));
                end
            elseif numel(obj.slices{3}) == 1  % show in greyscale
                    R = imadjust(sImg(:,:,1),[currViewPort.min(obj.slices{3}(1))/max_int currViewPort.max(obj.slices{3}(1))/max_int],[0 1],currViewPort.gamma(obj.slices{3}(1)));
                    G = R;
                    B = R;
            end
        end
end

if isnan(sOver1(1,1,1)) == 0   % segmentation model
    sList = obj.modelMaterialNames;
    T = get(handles.modelTransSlider,'Value'); % transparency for the segmentation model
    if strcmp(handles.Img{handles.Id}.I.model_type,'uint8') || strcmp(handles.Img{handles.Id}.I.model_type,'uint6')
        over_type = get(handles.segmShowTypePopup,'Value');  % if 1=filled, 2=contour
        M = sOver1;   % Model
        userData = get(handles.segmTable,'UserData');
        selectedObject = userData.prevMaterial-2;  % selected model object
        
        if over_type == 2       % see model as a countour
            if userData.showAll == 1 % show all materials
                M2 = zeros(size(M),'uint8');
                for ind = 1:numel(sList)
                    M3 = zeros(size(M2),'uint8');
                    M3(M==ind) = 1;
                    M3 = bwperim(M3);
                    M2(M3==1) = ind;
                end
                M = M2;
            elseif selectedObject > 0
                ind = selectedObject;    % only selected
                M2 = zeros(size(M),'uint8');
                M2(M==ind) = 1;
                M = bwperim(M2)*ind;
            end
        end
        
        if userData.showAll == 1 % show all materials
             % simple example of the following code
%             A = ones(3);
%             B = randi(3, 3);
%             C = [2 4 6];
%             
%             % fast option
%             D1 = A(:,:) .* C(B(:,:));
%             
%             % slow option
%             for i=1:size(A,1)
%                 for j=1:size(A,2)
%                     D2(i,j) = A(i,j)*C(B(i,j));
%                 end
%             end
            
            modIndeces = find(M~=0);  % generate list of points that have elements of the model
            if numel(modIndeces) > 0
                switch class(R)     % generate list of colors for the materials of the model
                    case 'uint8';   modColors = uint8(obj.modelMaterialColors*colorScale);
                    case 'uint16';  modColors = uint16(obj.modelMaterialColors*colorScale);
                    case 'uint32';  modColors = uint32(obj.modelMaterialColors*colorScale);
                end
                R(modIndeces) = R(modIndeces)*T + modColors(M(modIndeces),1) * (1-T);
                G(modIndeces) = G(modIndeces)*T + modColors(M(modIndeces),2) * (1-T);
                B(modIndeces) = B(modIndeces)*T + modColors(M(modIndeces),3) * (1-T);
            end
        elseif selectedObject > 0
            i = selectedObject;
            pntlist = find(M==i);
            if ~isempty(pntlist)
                R(pntlist) = R(pntlist)*T+obj.modelMaterialColors(i,1)*colorScale*(1-T);
                G(pntlist) = G(pntlist)*T+obj.modelMaterialColors(i,2)*colorScale*(1-T);
                B(pntlist) = B(pntlist)*T+obj.modelMaterialColors(i,3)*colorScale*(1-T);
            end
        end
    elseif strcmp(handles.Img{handles.Id}.I.model_type,'int8')
        %maximum = max(max(abs(sOver1)))-1;
        if obj.orientation == 4
            maximum = obj.model_diff_max(obj.slices{4}(1));
        else
            maximum = max(obj.model_diff_max);
        end
        coef = 1 + 255/maximum*T;
        R = zeros(size(R),'uint8');
        R(sOver1<0) = uint8(abs(sOver1(sOver1<0))*coef); %*T+255*(1-T));
        B = zeros(size(B),'uint8');
        B(sOver1>0) = uint8(sOver1(sOver1>0)*coef); %*T+255*(1-T));
    end
end

T1 = get(handles.selectionTransparencySlider,'Value'); % transparency for selection

% add the mask layer
if isnan(sOver2(1,1,1)) == 0
    T2 = get(handles.maskTransSlider,'Value'); % transparency for mask
    over_type = 2; %get(handles.segmShowTypePopup,'Value');  % if 1=filled, 2=contour
    %T1 = 0.65;    % transparency for mask model
    
    ind = 1;    % index
    if over_type == 2       % see model as a countour
        M = bwperim(sOver2); % mask
    else
        M = sOver2;   % mask
    end
    
    pntlist = find(M==ind);
    if ~isempty(pntlist)
        R(pntlist) = R(pntlist)*T2+handles.preferences.maskcolor(1)*colorScale*(1-T2);
        G(pntlist) = G(pntlist)*T2+handles.preferences.maskcolor(2)*colorScale*(1-T2);
        B(pntlist) = B(pntlist)*T2+handles.preferences.maskcolor(3)*colorScale*(1-T2);
    end
end

% put a selection area on a top
if ~isnan(selectionModel(1))
    pnt_list = find(selectionModel==1);
    R(pnt_list) = R(pnt_list)*T1+handles.preferences.selectioncolor(1)*colorScale*(1-T1);
    G(pnt_list) = G(pnt_list)*T1+handles.preferences.selectioncolor(2)*colorScale*(1-T1);
    B(pnt_list) = B(pnt_list)*T1+handles.preferences.selectioncolor(3)*colorScale*(1-T1);
end
imgRGB = cat(3,R,G,B);

% upscale image now for magnificationFactor < 1
if magnificationFactor < 1 && panModeException == 0
    if strcmp(handles.preferences.resize,'nearest') ||  strcmp(colortype, 'indexed') % tweak to make resizing faster in the nearest mode, may result in different image sizes compared to imresize method
        imgRGB = imgRGB(round(.51:magnificationFactor:end+.49),round(.51:magnificationFactor:end+.49),:);     % NOTE! the image size may be different from the imresize method
    else
        imgRGB = imresize(imgRGB, 1/magnificationFactor, handles.preferences.resize);
    end
end

% show annotations
if get(handles.showAnnotationsCheck,'value') %% && obj.orientation == 4
    if obj.hLabels.getLabelsNumber() >= 1
        % labelPos(index, z x y)
        %[labelsList,labelPos] = obj.hLabels.getLabels(sliceToShowIdx);
        [labelsList, labelPos] = obj.hLabels.getSliceLabels(handles, sliceToShowIdx);
        if isempty(labelsList); return; end;
        if obj.orientation == 4     % get ids of the correct vectors in the matrix, depending on orientation
            xId = 2;
            yId = 3;
        elseif obj.orientation == 1
            xId = 1;
            yId = 2;        
        elseif obj.orientation == 2
            xId = 1;
            yId = 3;
        end
        if strcmp(options.mode, 'full')
            if strcmp(options.resize, 'no') % this needed for snapshots
                pos(:,1) = ceil(labelPos(:,xId));
                pos(:,2) = ceil(labelPos(:,yId));
            else
                pos(:,1) = ceil(labelPos(:,xId)/max([obj.magFactor 1]));
                pos(:,2) = ceil(labelPos(:,yId)/max([obj.magFactor 1]));
            end
            if isnan(options.markerType)
                addTextOptions.markerText = 'marker';
            else
                addTextOptions.markerText = options.markerType;
            end
        else
            if strcmp(options.resize, 'no')     % this needed for snapshots
                pos(:,1) = ceil((labelPos(:,xId) - max([0 floor(obj.axesX(1))])) );     % - .999/obj.magFactor subtract 1 pixel to put a marker to the left-upper corner of the pixel
                pos(:,2) = ceil((labelPos(:,yId) - max([0 floor(obj.axesY(1))])) );
            else
                pos(:,1) = ceil((labelPos(:,xId) - max([0 floor(obj.axesX(1))])) / obj.magFactor);% - .999/obj.magFactor);     % - .999/obj.magFactor subtract 1 pixel to put a marker to the left-upper corner of the pixel
                pos(:,2) = ceil((labelPos(:,yId) - max([0 floor(obj.axesY(1))])) / obj.magFactor);% - .999/obj.magFactor);
            end
            if get(handles.annMarkerCheck, 'value')     % show only a marker
                addTextOptions.markerText = 'marker';
            else
                addTextOptions.markerText = 'both';
            end
        end
        addTextOptions.color = handles.preferences.annotationColor;
        addTextOptions.fontSize = handles.preferences.annotationFontSize;
        imgRGB = ib_addText2Img(imgRGB, labelsList, pos, handles.dejavufont, addTextOptions);
    end
end
end