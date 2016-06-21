function ib_segmentation_Brush(y, x, modifier, handles)
% function ib_segmentation_Brush(y, x, modifier, handles)
% Do segmentation using the brush tool
%
% Parameters:
% y: y-coordinate of the mouse cursor at the starting point
% x: x-coordinate of the mouse cursor at the starting point
% modifier: a string, to specify what to do with the generated selection
% - @em empty - makes new selection
% - @em ''control'' - removes selection from the existing one
% handles: a handles structure of im_browser
%
% Return values:
% 

%| @b Examples:
% @code ib_segmentation_Brush(50, 75, '', handles);  // start the brush tool from position [y,x]=50,75,10 @endcode

% Copyright (C) 14.05.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 04.05.2015 IB, added superpixels mode
% 04.11.2015 IB, added Watershed superpixels mode
% 18.09.2016, changed .slices to cells
% 29.03.2016, IB, optimized backup

% do backup
getDatasetDimensionsOpt.blockModeSwitch = 0;
[blockHeight, blockWidth] = handles.Img{handles.Id}.I.getDatasetDimensions('image', handles.Img{handles.Id}.I.orientation, 0, getDatasetDimensionsOpt);
backupOptions.x(1) = max([1 ceil(handles.Img{handles.Id}.I.axesX(1))]);
backupOptions.x(2) = min([ceil(handles.Img{handles.Id}.I.axesX(2)), blockWidth]);
backupOptions.y(1) = max([1 ceil(handles.Img{handles.Id}.I.axesY(1))]);
backupOptions.y(2) = min([ceil(handles.Img{handles.Id}.I.axesY(2)), blockHeight]);
ib_do_backup(handles, 'selection', 0,backupOptions);  % do backup

radius = str2double(get(handles.segmSpotSizeEdit,'String'));
if radius == 0; return; end;

handles.Img{handles.Id}.I.brush_prev_xy = [x, y];

if strcmp(modifier, 'control')    % subtracts selections
    brush_switch = 'subtract';
else
    brush_switch = 'add';  % combines selections
end

selection_layer = 'image';
handles.Img{handles.Id}.I.brush_selection = {};
handles.Img{handles.Id}.I.brush_selection{1} = logical(zeros([size(handles.Img{handles.Id}.I.Ishown,1) size(handles.Img{handles.Id}.I.Ishown,2)], 'uint8')); %#ok<LOGL>

% generate the structural element for the brush
radius = radius - 1;
if radius < 1; radius = 0.5; end;
se_size = round(radius/handles.Img{handles.Id}.I.magFactor);
structElement = zeros(se_size*2+1,se_size*2+1);
[xx,yy] = meshgrid(-se_size:se_size,-se_size:se_size);
ball = sqrt((xx/se_size).^2+(yy/se_size).^2);
structElement(ball<=1) = 1;
handles.Img{handles.Id}.I.brush_selection{1}(y,x) = 1;
handles.Img{handles.Id}.I.brush_selection{1} = imdilate(handles.Img{handles.Id}.I.brush_selection{1}, structElement);

% enable superpixels mode, not for eraser
if (get(handles.brushSuperpixelsCheck, 'value') || get(handles.brushSuperpixelsWatershedCheck, 'value')) && isempty(modifier)
    col_channel = get(handles.ColChannelCombo,'Value')-1;   %
    if col_channel == 0; col_channel = NaN; end;
    if isnan(col_channel) && (handles.Img{handles.Id}.I.colors ~= 3 && handles.Img{handles.Id}.I.colors ~= 1)
        msgbox(sprintf('Please select the color channel!\n\nSelection panel->Color channel'),'Error!','error','modal');
        
        set(handles.im_browser, 'pointer', 'crosshair');
        set(handles.im_browser, 'windowbuttonupfcn', '');
        set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
        set(handles.im_browser, 'WindowKeyPressFcn', {@im_browser_WindowKeyPressFcn, handles}); % turn ON callback for the keys
        handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        im_browser_winMouseMotionFcn(handles.im_browser, [], handles);
        return;
    end
    sImage = handles.Img{handles.Id}.I.getSliceToShow('image', NaN, NaN, col_channel);
    sImage = imresize(sImage, size(handles.Img{handles.Id}.I.brush_selection{1}));
    noLables = str2double(get(handles.superpixelsNumberEdit, 'string'));
    compactFactor = str2double(get(handles.superpixelsCompactEdit, 'string'));
    
    % stretch image for preview
    if get(handles.liveStretchCheck, 'value')
        for i=1:size(sImage,3)
            sImage(:,:,i) = imadjust(sImage(:,:,i) ,stretchlim(sImage(:,:,i),[0 1]),[]);
        end
    end
    
    currViewPort = handles.Img{handles.Id}.I.viewPort;
    if isnan(col_channel)
        selectedColChannels = handles.Img{handles.Id}.I.slices{3};
    else
        selectedColChannels = col_channel;
    end
    max_int = double(intmax(class(sImage)));
    if isa(sImage, 'uint16') % convert to 8bit
        for colCh=1:numel(selectedColChannels)
            sImage(:,:,colCh) = imadjust(sImage(:,:,colCh),[currViewPort.min(selectedColChannels(colCh))/max_int currViewPort.max(selectedColChannels(colCh))/max_int],[0 1],currViewPort.gamma(selectedColChannels(colCh)));
        end
        sImage = uint8(sImage/255);
    elseif isa(sImage, 'uint8')     % stretch contrast if needed
        for colCh=1:numel(selectedColChannels)
            if currViewPort.min(colCh) ~= 0 || ...
                currViewPort.max(colCh) ~= max_int || ...
                currViewPort.gamma(colCh) ~= 1
                        sImage(:,:,colCh) = imadjust(sImage(:,:,colCh),[currViewPort.min(selectedColChannels(colCh))/max_int currViewPort.max(selectedColChannels(colCh))/max_int],[0 1],currViewPort.gamma(selectedColChannels(colCh)));
            end
        end
    end
    
    if get(handles.brushSuperpixelsCheck, 'value')  % calculate SLIC superpixels
        [slicImage, noLabels] = slicmex(sImage, noLables, compactFactor);
        slicImage = slicImage+1;    % remove superpixel with 0 - value
    else                                            % calculate Watershed superpixels
        blackOnWhite = str2double(get(handles.superpixelsCompactEdit,'string'));
        if blackOnWhite > 0     % invert image
            slicImage = imcomplement(sImage);    % convert image that the ridges are white
        else
            slicImage = sImage;    
        end
        mask = imextendedmin(slicImage, str2double(get(handles.superpixelsNumberEdit,'string')));
        mask = imimposemin(slicImage, mask);
        slicImageB = watershed(mask);       % generate superpixels
        slicImage = imdilate(slicImageB, ones(3));
        noLabels = max(max(slicImage));
    end
    
    if noLabels < 255
        handles.Img{handles.Id}.I.brush_selection{2}.slic = uint8(slicImage);
    else
        handles.Img{handles.Id}.I.brush_selection{2}.slic = uint16(slicImage);
    end
    
    % indeces of boundaries for preview
    if get(handles.brushSuperpixelsCheck, 'value')  % calculate SLIC superpixels
        %boundaries = imdilate(handles.Img{handles.Id}.I.brush_selection{2}.slic,ones(3)) > imerode(handles.Img{handles.Id}.I.brush_selection{2}.slic,ones(3));
        boundaries = drawregionboundaries(handles.Img{handles.Id}.I.brush_selection{2}.slic);
        %boundaries = find(boundaries==1);
    else
        boundaries = slicImageB==0;   % for watershed
    end
    
    CData = get(handles.Img{handles.Id}.I.imh,'CData');
    T2 = get(handles.maskTransSlider,'Value'); % transparency for mask
    for ch=1:3
        img = CData(:,:,ch);
        img(boundaries) =  img(boundaries)*T2+handles.preferences.maskcolor(ch)*intmax(class(img))*(1-T2);
        CData(:,:,ch) = img;
    end
    set(handles.Img{handles.Id}.I.imh,'CData',CData);
    
    if get(handles.AdaptiveDilateCheck, 'value') == 1
        if isnan(col_channel) && handles.Img{handles.Id}.I.colors == 3
            msgbox(sprintf('The adaptive mode is not implemented for RGB images!\n\nPlease select a single channel in the Selection panel:\nSelection panel->Color channel'),'Error!','error','modal');
            
            set(handles.im_browser, 'pointer', 'crosshair');
            set(handles.im_browser, 'windowbuttonupfcn', '');
            set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
            set(handles.im_browser, 'WindowKeyPressFcn', {@im_browser_WindowKeyPressFcn, handles}); % turn ON callback for the keys
            handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            im_browser_winMouseMotionFcn(handles.im_browser, [], handles);
            return;
        end
        
        STATS = regionprops(handles.Img{handles.Id}.I.brush_selection{2}.slic, sImage, 'MeanIntensity');
        handles.Img{handles.Id}.I.brush_selection{3}.meanVals = [STATS.MeanIntensity];
        handles.Img{handles.Id}.I.brush_selection{3}.mean = mean(sImage(handles.Img{handles.Id}.I.brush_selection{1}==1));
        handles.Img{handles.Id}.I.brush_selection{3}.std = std(double(sImage(handles.Img{handles.Id}.I.brush_selection{1}==1)));
        handles.Img{handles.Id}.I.brush_selection{3}.factor = str2double(get(handles.dilateAdaptCoefEdit, 'string'));
        
%         labelObj = unique(handles.Img{handles.Id}.I.brush_selection{2}.slic(handles.Img{handles.Id}.I.brush_selection{1}));
%         handles.Img{handles.Id}.I.brush_selection{3}.labelObj = labelObj;
        
%         % this code was for automatic expansion, should be redone
%         % calculate adjacent matrix for labels
%         [Am, Al] = regionadjacency(double(handles.Img{handles.Id}.I.brush_selection{2}.slic), 8);
%         
%         [row, col, nodesVal] = find(Am>0);
%         nodesVal = zeros([numel(row),1]);
%         for i=1:numel(nodesVal)
%             nodesVal(i) = abs(handles.Img{handles.Id}.I.brush_selection{3}.meanVals(row(i))-handles.Img{handles.Id}.I.brush_selection{3}.meanVals(col(i)));
%         end
%         Am = sparse(row,col,nodesVal);
%         
%         Am = tril(Am);
%         handles.Img{handles.Id}.I.brush_selection{3}.allShortest = graphallshortestpaths(Am,'directed',false);
%         allShortest = handles.Img{handles.Id}.I.brush_selection{3}.allShortest(:,labelObj);
%         [idx1, idx2] = find(allShortest <= handles.Img{handles.Id}.I.brush_selection{3}.std*handles.Img{handles.Id}.I.brush_selection{3}.factor);

%        handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic(ismember(handles.Img{handles.Id}.I.brush_selection{2}.slic, idx1)) = 1;
        handles.Img{handles.Id}.I.brush_selection{3}.CData = get(handles.Img{handles.Id}.I.imh,'CData');
        set(handles.im_browser, 'WindowScrollWheelFcn', {@im_browser_brush_scrollWheelFcn, handles});

    end
    
    set(handles.im_browser, 'WindowKeyPressFcn', {@im_browser_WindowKeyPressFcn_BrushSuperpixel, handles}); % turn ON callback for the keys for the Superpixel brush
    
    selectedSlicIndices = unique(handles.Img{handles.Id}.I.brush_selection{2}.slic(handles.Img{handles.Id}.I.brush_selection{1}));
    handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic = ismember(handles.Img{handles.Id}.I.brush_selection{2}.slic, selectedSlicIndices);   % SLIC based image
    handles.Img{handles.Id}.I.brush_selection{2}.selectedSlicIndices = selectedSlicIndices;     % list of indices of the currently selected superpixels
    handles.Img{handles.Id}.I.brush_selection{2}.CData = CData;     % store original CData with Boundaries of the superpixels
end

handles = ib_updateCursor(handles, 'solid');   % set the brush cursor in the drawing mode
set(handles.im_browser, 'windowbuttondownfcn', []);

set(handles.im_browser, 'pointer', 'custom', 'PointerShapeCData',nan(16),......
    'windowbuttonmotionfcn' , {@im_browser_WindowBrushMotionFcn, handles, selection_layer, structElement});
set(handles.im_browser, 'windowbuttonupfcn', {@im_browser_WindowButtonUpFcn, handles, brush_switch});
