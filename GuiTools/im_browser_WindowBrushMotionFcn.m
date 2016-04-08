function im_browser_WindowBrushMotionFcn(hObject, eventdata, handles, selection_layer, structElement, currMask)
% function im_browser_WindowBrushMotionFcn(hObject, eventdata, handles, brush_switch, selection_layer, structElement,currMask)
% This function draws the brush trace during use of the brush tool
%
% Parameters:
% hObject: a handle to the object from where the call was implemented
% eventdata: additinal parameters
% handles: handles structure of im_browser.m
% selection_layer: when ''mask'' limit selection to the masked area, could be ''''
% structElement: a structural element to be used with the brush, similar to the one generated with Matlab @em strel function
% currMask: is a bitmap with the Mask image, needed for selection_layer == ''mask''

% Copyright (C) 15.09.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 04.05.2015 ib, added superpixels mode

if nargin < 6; currMask = NaN; end;
pos = get(handles.imageAxes, 'currentpoint');
XLim = size(handles.Img{handles.Id}.I.Ishown,2);
YLim = size(handles.Img{handles.Id}.I.Ishown,1);
pos = round(pos);

if pos(1,1)<=0; pos(1,1)=1; end
if pos(1,1)>XLim; pos(1,1)=XLim; end
if pos(1,2)<=0; pos(1,2)=1; end;
if pos(1,2)>YLim; pos(1,2)=YLim; end;

if isnan(handles.Img{handles.Id}.I.brush_prev_xy(1,1))
    handles.Img{handles.Id}.I.brush_prev_xy = [pos(1,1) pos(1,2)];
    return;
end;

% recalculate brush cursor positions
diffX = pos(1,1)-handles.Img{handles.Id}.I.brush_prev_xy(1);
diffY = pos(1,2)-handles.Img{handles.Id}.I.brush_prev_xy(2);
xv = get(handles.cursor, 'XData')+diffX;
yv = get(handles.cursor, 'YData')+diffY;
set(handles.cursor, 'XData', xv);
set(handles.cursor, 'YData', yv);


selarea = logical(zeros([size(handles.Img{handles.Id}.I.Ishown,1), size(handles.Img{handles.Id}.I.Ishown, 2)], 'uint8'));      %#ok<LOGL> % needs logicals for performance

if abs(pos(1,1)-handles.Img{handles.Id}.I.brush_prev_xy(1)) > abs(pos(1,2)-handles.Img{handles.Id}.I.brush_prev_xy(2))     % horizontal movement
    if pos(1,1) <= handles.Img{handles.Id}.I.brush_prev_xy(1)
        X = [pos(1,1) handles.Img{handles.Id}.I.brush_prev_xy(1)];
        Y = [pos(1,2) handles.Img{handles.Id}.I.brush_prev_xy(2)];
    else
        X = [handles.Img{handles.Id}.I.brush_prev_xy(1) pos(1,1)];
        Y = [handles.Img{handles.Id}.I.brush_prev_xy(2) pos(1,2)];
    end
    dY = (Y(2)-Y(1))/(X(2)-X(1)+1);
    for x=X(1):X(2)
        y = round(Y(1) + (x-X(1))*dY);
        selarea(y,x) = 1;
        
        %strelH2 = floor(size(structElement,1)/2);
        %strelW2 = floor(size(structElement,2)/2);
        %selarea(y-strelH2:y+strelH2, x-strelW2:x+strelW2) = uint8(selarea(y-strelH2:y+strelH2, x-strelW2:x+strelW2)) | uint8(structElement);
    end
else    % vertical movement
    if pos(1,2) < handles.Img{handles.Id}.I.brush_prev_xy(2)
        X = [pos(1,1) handles.Img{handles.Id}.I.brush_prev_xy(1)];
        Y = [pos(1,2) handles.Img{handles.Id}.I.brush_prev_xy(2)];
    else
        X = [handles.Img{handles.Id}.I.brush_prev_xy(1) pos(1,1)];
        Y = [handles.Img{handles.Id}.I.brush_prev_xy(2) pos(1,2)];
    end
    dX = (X(2)-X(1))/(Y(2)-Y(1)+1);
    for y=Y(1):Y(2)
        x = round(X(1) + (y-Y(1))*dX);
        selarea(y,x) = 1;
        %strelH2 = floor(size(structElement,1)/2);
        %strelW2 = floor(size(structElement,2)/2);
        %selarea(y-strelH2:y+strelH2, x-strelW2:x+strelW2) = uint8(selarea(y-strelH2:y+strelH2, x-strelW2:x+strelW2)) | uint8(structElement);
    end
end

% when the brush is large use bwdist function instead of imdilate
if size(structElement,2) < 170
    selarea1 = imdilate(selarea, structElement);
else
    selarea1 = bwdist(selarea)<=size(structElement,1)/2; 
end

%selarea1 = RGBCircle(selarea, x, y, [size(structElement,1)/2 size(structElement,2)/2], 1);
%selarea1 = imfill(uint8(selarea1));
% tic
% X0=10;
% Y0=20;
% a=20;
% b=9;
% %[x, y] = meshgrid(-50:50,-50:50);
% [x, y] = meshgrid(1:100,1:100);
% el=((x-X0)/a).^2+((y-Y0)/b).^2<=1;
% toc
% figure(1)
% imagesc(el); colormap(bone) 

CData = get(handles.Img{handles.Id}.I.imh,'CData');

if numel(handles.Img{handles.Id}.I.brush_selection) > 1
    if get(handles.AdaptiveDilateCheck, 'value') == 1
        diffSelarea = uint8(selarea1 - handles.Img{handles.Id}.I.brush_selection{1});
        newIndices = unique(handles.Img{handles.Id}.I.brush_selection{2}.slic(diffSelarea==1));
        
        outIndices = zeros([numel(newIndices),1]);
        
        factor = handles.Img{handles.Id}.I.brush_selection{3}.factor;
        
        for indx = 1:numel(newIndices)
            if handles.Img{handles.Id}.I.brush_selection{3}.meanVals(newIndices(indx)) >= handles.Img{handles.Id}.I.brush_selection{3}.mean-handles.Img{handles.Id}.I.brush_selection{3}.std*factor && ...
                    handles.Img{handles.Id}.I.brush_selection{3}.meanVals(newIndices(indx)) <= handles.Img{handles.Id}.I.brush_selection{3}.mean+handles.Img{handles.Id}.I.brush_selection{3}.std*factor
                outIndices(indx) = 1;
            end
        end
        outIndices = newIndices(outIndices==1);
        
        if ~isempty(outIndices)
            selarea2 = ismember(handles.Img{handles.Id}.I.brush_selection{2}.slic, outIndices);
        else
            selarea2 = zeros(size(handles.Img{handles.Id}.I.brush_selection{1}),'uint8');
        end
    else
        slicIndices = unique(handles.Img{handles.Id}.I.brush_selection{2}.slic(selarea1));  % get indices of new superpixels where the brush is currently in
        if min(ismember(slicIndices, handles.Img{handles.Id}.I.brush_selection{2}.selectedSlicIndices)) == 0;   % new superpixel detected -> store history
            slicIndices(ismember(slicIndices, handles.Img{handles.Id}.I.brush_selection{2}.selectedSlicIndices)) = [];  % remove indices that already selected
            selectedSlicIndices = [handles.Img{handles.Id}.I.brush_selection{2}.selectedSlicIndices; slicIndices];      % generate new list of the selected indices
            handles.Img{handles.Id}.I.brush_selection{2}.selectedSlicIndices = selectedSlicIndices;     % store the list of superpixels
        end
        selarea2 = ismember(handles.Img{handles.Id}.I.brush_selection{2}.slic, slicIndices);
    end
    if strcmp(selection_layer,'mask')
        selarea2 = selarea2 & currMask;
        selarea1 = selarea1 & currMask;
    end
    handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic(selarea2==1)=1;
    CData(handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic==1) = intmax(class(handles.Img{handles.Id}.I.Ishown))*.4;
    handles.Img{handles.Id}.I.brush_selection{1}(selarea1==1)=1;
else        % normal brush
    if strcmp(selection_layer,'mask')
        selarea1 = selarea1 & currMask;
    end
    %handles.Img{handles.Id}.I.brush_selection{1}(selarea1==1)=1;
    handles.Img{handles.Id}.I.brush_selection{1} = handles.Img{handles.Id}.I.brush_selection{1} | selarea1;
    CData(handles.Img{handles.Id}.I.brush_selection{1}==1) = intmax(class(handles.Img{handles.Id}.I.Ishown))*.4;
end

set(handles.Img{handles.Id}.I.imh,'CData',CData);
handles.Img{handles.Id}.I.brush_prev_xy = [pos(1,1) pos(1,2)];
end