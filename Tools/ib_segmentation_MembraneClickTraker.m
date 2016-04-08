function [output, handles] = ib_segmentation_MembraneClickTraker(yxzCoordinate, yx, modifier, handles)
% [output, handles] = ib_segmentation_MembraneClickTraker(yxzCoordinate, yx, modifier, handles)
% Trace membranes and draw a straight lines in 2d and 3d
%
% Parameters:
% yxzCoordinate: a vector with [y,x,z] coodrinates of the starting point (match voxel coordinates of the dataset)
% yx: a vector [y,x] with coordinates of the clicked point
% modifier: a string, to specify what to do with the generated selection
% - @em empty - trace membrane from the starting to the selected point
% - @em ''shift'' - defines the starting point of a membrane
% handles: a handles structure of im_browser
%
% Return values:
% output:  a string that defines what next to do in the im_browser_WindowButtonDown function
% - @em ''continue'' - continue with the script
% - @em ''return'' - stop execution and return
% handles: a handles structure of im_browser

% Copyright (C) 2012 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 14.05.2014, taken to a separate function
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 29.03.2016, IB, optimized backup

switch3d = get(handles.actions3dCheck,'Value');     % use tool in 3d
output = 'continue';
if handles.Img{handles.Id}.I.blockModeSwitch
    msgbox('Please switch off the BlockMode using the button in the toolbar','Not compatible with the BlockMode','error'); return;
end
if switch3d && get(handles.segmTrackStraightChk, 'value') ==0
    msgbox('Please switch off the 3D mode in the Selection panel','Error','error');
    return;
end

line_width = str2double(get(handles.segmTrackWidthEdit,'String'));
orient = 4;

if switch3d
    h = yxzCoordinate(1);
    w = yxzCoordinate(2);
    z = yxzCoordinate(3);
    if strcmp(modifier, 'shift')    % defines first point for the tracer, with the Shift button
        ib_do_backup(handles, 'selection', 0);
        %handles.Img{handles.Id}.I.trackerYXZ = [y; x; z];
        handles.Img{handles.Id}.I.trackerYXZ = [h; w; z];
        currentSelection = handles.Img{handles.Id}.I.getSliceToShow('selection');
        selarea = zeros(size(currentSelection), 'uint8');
        selarea(ceil(yx(1)*handles.Img{handles.Id}.I.magFactor),ceil(yx(2)*handles.Img{handles.Id}.I.magFactor)) = 1;
        %selarea = imdilate(selarea, strel('disk', line_width));
        handles.Img{handles.Id}.I.setSliceToShow('selection', bitor(selarea, currentSelection));
    else
        if isnan(handles.Img{handles.Id}.I.trackerYXZ(1));
            msgbox('Please use Shift+Mouse click to define the starting point!','Missing the starting point');
            return;
        end;
        handles.Img{handles.Id}.I.trackerYXZ = handles.Img{handles.Id}.I.trackerYXZ(:,end);
        [height, width, ~, thick] = handles.Img{handles.Id}.I.getDatasetDimensions('image', 4);
        p1 = handles.Img{handles.Id}.I.trackerYXZ;
        %p2 = [y; x; z];
        p2 = [h; w; z];
        dv = p2 - p1;
        
        % generate structural element for dilation
        if handles.Img{handles.Id}.I.orientation == 1
            se_size(1) = line_width; % x
            se_size(2) = round(se_size(1)*handles.Img{handles.Id}.I.pixSize.x/handles.Img{handles.Id}.I.pixSize.z); % y
            se_size(3) = line_width; % for z
        elseif handles.Img{handles.Id}.I.orientation == 2
            se_size(2) = line_width; % y
            se_size(3) = line_width; % for z
            se_size(1) = round(line_width*handles.Img{handles.Id}.I.pixSize.x/handles.Img{handles.Id}.I.pixSize.z); % x
        elseif handles.Img{handles.Id}.I.orientation == 4
            se_size(1) = line_width; % for x
            se_size(2) = line_width; % for y
            se_size(3) = round(se_size(1)*handles.Img{handles.Id}.I.pixSize.x/handles.Img{handles.Id}.I.pixSize.z); % for z
        end
        se = zeros(se_size(1)*2+1,se_size(2)*2+1,se_size(3)*2+1);    % do strel ball type in volume
        [xMesh,yMesh,zMesh] = meshgrid(-se_size(1):se_size(1),-se_size(2):se_size(2),-se_size(3):se_size(3));
        ball = sqrt((xMesh/se_size(1)).^2+(yMesh/se_size(2)).^2+(zMesh/se_size(3)).^2);
        se(ball<=1) = 1;
        
        minY = min([p1(1) p2(1)]);
        maxY = max([p1(1) p2(1)]);
        minX = min([p1(2) p2(2)]);
        maxX = max([p1(2) p2(2)]);
        minZ = min([p1(3) p2(3)]);
        maxZ = max([p1(3) p2(3)]);
        
        shiftY1 = se_size(2);
        shiftY2 = se_size(2);
        shiftX1 = se_size(1);
        shiftX2 = se_size(1);
        shiftZ1 = se_size(3);
        shiftZ2 = se_size(3);
        
        if minY-se_size(2) <=0; shiftY1 = minY-1; end
        if minX-se_size(1) <=0; shiftX1 = minX-1; end
        if minZ-se_size(3) <=0; shiftZ1 = minZ-1; end
        if maxY+se_size(2) > height; shiftY2 = height-maxY; end
        if maxX+se_size(1) > width; shiftX2 = width-maxX; end
        if maxZ+se_size(2) > thick; shiftZ2 = thick-maxZ; end
        
        p1shift = p1 - [minY-shiftY1-1; minX-shiftX1-1; minZ-shiftZ1-1];
        
        options.x = [minX-shiftX1 maxX+shiftX2];
        options.y = [minY-shiftY1 maxY+shiftY2];
        options.z = [minZ-shiftZ1 maxZ+shiftZ2];
        
        % do backup
        ib_do_backup(handles, 'selection', switch3d, options);
        
        currSelection = handles.Img{handles.Id}.I.getData3D('selection', NaN, orient, 0, options);
        selareaCrop = zeros(size(currSelection),'uint8');
        
        nPnts = max(abs(dv))+1;
        linSpacing = linspace(0, 1, nPnts);
        for i=1:nPnts
            selareaCrop(round(p1shift(1)+linSpacing(i)*dv(1)), round(p1shift(2)+linSpacing(i)*dv(2)),round(p1shift(3)+linSpacing(i)*dv(3))) = 1;
        end
        if isempty(find(se_size==0, 1))    % dilate to make line thicker, do not dilate when line is 1 pix wide
            selareaCrop = imdilate(selareaCrop, se);
        end
        handles.Img{handles.Id}.I.trackerYXZ(:,2) = [h; w; z];
        % combines selections
        handles.Img{handles.Id}.I.setData3D('selection', bitor(currSelection, selareaCrop), NaN, orient, 0, options); % combines selections
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        output = 'return';
        return;
    end
else
    ib_do_backup(handles, 'selection', 0);
    yCrop = yxzCoordinate(1);
    xCrop = yxzCoordinate(2);
    z = yxzCoordinate(3); 
    if strcmp(modifier, 'shift')    % defines first point for the tracer
        handles.Img{handles.Id}.I.trackerYXZ = [yCrop; xCrop; z];
        currentSelection = handles.Img{handles.Id}.I.getSliceToShow('selection');
        selarea = zeros(size(currentSelection), 'uint8');
        selarea(ceil(yx(1)*handles.Img{handles.Id}.I.magFactor),ceil(yx(2)*handles.Img{handles.Id}.I.magFactor)) = 1;
    else    % start tracing
        if isnan(handles.Img{handles.Id}.I.trackerYXZ(1));
            msgbox('Please use Shift+Mouse click to define the starting point!','Missing the starting point');
            return;
        end;
        handles.Img{handles.Id}.I.trackerYXZ = handles.Img{handles.Id}.I.trackerYXZ(:,end);
        pointY = handles.Img{handles.Id}.I.trackerYXZ(1)-max([0 floor(handles.Img{handles.Id}.I.axesY(1))]);
        pointX = handles.Img{handles.Id}.I.trackerYXZ(2)-max([0 floor(handles.Img{handles.Id}.I.axesX(1))]);
        if pointY < 1 || pointX < 1 || pointX > handles.Img{handles.Id}.I.axesX(2) || pointY > handles.Img{handles.Id}.I.axesY(2);
            msgbox('Please shift the window to see both the starting and the ending points!','Wrong view!','error');
            return;
        end
        currentSelection = handles.Img{handles.Id}.I.getSliceToShow('selection');
        if get(handles.segmTrackStraightChk, 'value')   % connect points using a straight line
            pnts(1,:) = [pointX, pointY];
            pnts(2,:) = [ceil(yx(2)*handles.Img{handles.Id}.I.magFactor); ceil(yx(1)*handles.Img{handles.Id}.I.magFactor)];
            selarea = zeros(size(currentSelection), 'uint8');
            selarea = ib_connectPoints(selarea, pnts);
            handles.Img{handles.Id}.I.trackerYXZ(:,2) = [yCrop; xCrop;z];
        else            % connect points using accurate fast marching function
            colorId = get(handles.ColChannelCombo,'Value')-1;
            if colorId == 0;
                msgbox('Please select the color channel in the Selection panel!','Wrong color channel!','error');
                return;
            end;
            options.p1 = [pointY; pointX];
            options.p2 = [min([ceil(yx(1)*handles.Img{handles.Id}.I.magFactor), size(currentSelection,1)]); min([ceil(yx(2)*handles.Img{handles.Id}.I.magFactor) size(currentSelection,2)])];
            options.scaleFactor = str2double(get(handles.segmTracScaleEdit,'String'));
            options.segmTrackBlackChk = get(handles.segmTrackBlackChk,'Value');
            options.colorId = colorId;
            currImage = handles.Img{handles.Id}.I.getSliceToShow('image');
            
            [selarea, status] = ib_connect_points(currImage, options);
            if status == 1; handles.Img{handles.Id}.I.trackerYXZ(:,2) = [yCrop; xCrop; z]; end;
        end
    end
    if line_width > 0
        selarea = imdilate(selarea, strel('disk', line_width-1, 0));
    end
    handles.Img{handles.Id}.I.setSliceToShow('selection', bitor(currentSelection, selarea));
end