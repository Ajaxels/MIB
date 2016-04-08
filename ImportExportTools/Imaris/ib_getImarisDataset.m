function [img, img_info, viewPort, handles] = ib_getImarisDataset(handles)
% function [img, img_info, viewPort, handles] = ib_getImarisDataset(handles)
% Get a dataset opened in Imaris and corresponding meta-data
%
% Parameters:
% handles: handles structure from im_browser
%
% Return values:
% img: 4D dataset
% img_info: Containers.Map with meta data
% viewPort: a structure with the viewPort parameters
%   .min - a vector with minimal intensities for contrast adjustment
%   .max - a vector with maximal intensities for contrast adjustment
%   .gamma - a vector with gamma factor for contrast adjustment
% handles:  handles structure from im_browser

% @note 
% uses IceImarisConnector bindings
% @b Requires:
% 1. set system environment variable IMARISPATH to the installation
% directory, for example "c:\tools\science\imaris"
% 2. restart Matlab

%|
% @b Examples:
% @code [img, img_info] = ib_getImarisDataset(handles);     // get dataset from imaris @endcode

% Copyright (C) 04.11.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


img = NaN;
img_info = NaN;
viewPort = struct();
timePoint = 0;

% establish connection to Imaris
wb = waitbar(0, 'Please wait...', 'Name', 'Connecting to Imaris');
if ~isfield(handles, 'connImaris')
    handles.connImaris = IceImarisConnector(0);
    if handles.connImaris.isAlive == 0
        errordlg(sprintf('Imaris was not found;\nPlease start Imaris and try again!'),'Missing Imaris');
        handles = rmfield(handles, 'connImaris');
        delete(wb);
        return;
    end
else
    if handles.connImaris.isAlive == 0
        handles.connImaris.startImaris();
    end    
end
delete(wb);

% Get size of the dataset in pixels
[vSizeX, vSizeY, vSizeZ, vSizeC, vSizeT] = handles.connImaris.getSizes();
if vSizeZ > 1 && vSizeT > 1
    %answer = inputdlg(sprintf('!!! Warning !!!\n\nMIB can''t open 5D datasets!\nPlease enter a time point to open (starting from 0)'), 'Time point', 1, cellstr('0'));
    answer = mib_inputdlg(NaN,sprintf('!!! Warning !!!\nA 5D dataset is opened in Imaris!\nPlease enter a time point to open (starting from 1) or type 0 to obtain the 5D dataset completely'), 'Time point', '1');
    if isempty(answer);         return;    end;
    timePoint = str2double(answer{1});    % frame number to open for 5D datasets
end

% the block size defined in the getByBlocks function below
%blockSizeX = 512;
%blockSizeY = 512;
%blockSizeZ = 512;
useBlockMode = 0;
if vSizeX*vSizeY*vSizeZ > 134217728 % = 512 x 512 x 512
    useBlockMode = 1;
end

wb = waitbar(0,'Please wait...','Name','Importing Image from Imaris');

img_info = containers.Map;
img_info('Width') = vSizeX;
img_info('Height') = vSizeY;
if vSizeZ >= 1 && vSizeT == 1
    img_info('Stacks') = vSizeZ;    % open as Z-stack
    img_info('Time') = 1; 
elseif vSizeZ == 1 && vSizeT >= 1
    img_info('Stacks') = vSizeT;    % open as a movie
    img_info('Time') = 1; 
else
    if timePoint == 0
        img_info('Stacks') = vSizeZ;
        img_info('Time') = vSizeT; 
    else
        img_info('Stacks') = vSizeZ;
        img_info('Time') = 1; 
    end
end

if vSizeC == 1
    img_info('ColorType') = 'grayscale';
else
    img_info('ColorType') = 'truecolor';
end

% Get the extents of the image, Bounding Box in image units
[minX, maxX, minY, maxY, minZ, maxZ] = handles.connImaris.getExtends();

% fix of a problem of different calculations of the bounding box for a
% single slice and Z-stack
if img_info('Stacks') > 1
    maxZ = maxZ - (maxZ-minZ)/img_info('Stacks');
else
    maxZ = maxZ;
end

img_info('ImageDescription') = sprintf('BoundingBox %.5f %.5f %.5f %.5f %.5f %.5f |',...
    minX, maxX, minY, maxY, minZ, maxZ);

% Get details of contrast and gamma
datasetClass = handles.connImaris.getMatlabDatatype();

% update viewPort structure
for colId = 1:vSizeC
    viewPort.min(colId) = handles.connImaris.mImarisApplication.GetDataSet.GetChannelRangeMin(colId-1);
    viewPort.max(colId) = handles.connImaris.mImarisApplication.GetDataSet.GetChannelRangeMax(colId-1);
    viewPort.gamma(colId) = handles.connImaris.mImarisApplication.GetDataSet.GetChannelGamma(colId-1);
end

colorChannels = zeros(vSizeC,3);    % allocate space for colors of the color channels
img = zeros([vSizeY, vSizeX, vSizeC, img_info('Stacks'), img_info('Time')], datasetClass);

if timePoint == 0
    timePointsImaris = 0:img_info('Time')-1;
    timePointsMIB = 1:img_info('Time');
else
    timePointsImaris = timePoint-1;
    timePointsMIB = 1;
end

callsId = 0; % number of calls in the for loop
maxWaitbarIndex = vSizeC*numel(timePointsImaris);

tIndex = 1;
for t=timePointsImaris
    for colId = 1:vSizeC
        if vSizeZ > 1 && vSizeT > 1   % 5D dataset
            if useBlockMode == 0
                img(:,:,colId,:,timePointsMIB(tIndex)) = permute(handles.connImaris.getDataVolumeRM(colId-1, t),[1, 2, 4, 3]);    % getDataVolumeRM(colorChannel, TimePoint)
            else
                img(:,:,colId,:,timePointsMIB(tIndex)) = getByBlocks(handles.connImaris, colId-1, t);
            end
        elseif vSizeZ >= 1 && vSizeT == 1   % open as a Z-stack, 4D dataset
            if useBlockMode == 0
                img(:,:,colId,:) = permute(handles.connImaris.getDataVolumeRM(colId-1, t),[1, 2, 4, 3]);    % getDataVolumeRM(colorChannel, TimePoint)
            else
                img(:,:,colId,:) = getByBlocks(handles.connImaris, colId-1, t);
            end
        else                            % open as a movie
            switch datasetClass
                case 'uint8'
                    for tPoint=1:vSizeT
                        slice = handles.connImaris.mImarisApplication.GetDataSet.GetDataVolumeAs1DArrayBytes(colId-1, tPoint-1);     % Z, color, time
                        slice = typecast(slice, 'uint8');
                        img(:,:,colId,tPoint) = reshape(slice, [vSizeX vSizeY])';
                    end
                case 'uint16'
                    for tPoint=1:vSizeT
                        slice = handles.connImaris.mImarisApplication.GetDataSet.GetDataVolumeAs1DArrayShorts(colId-1, tPoint-1);     % Z, color, time
                        slice = typecast(slice, 'uint16');
                        img(:,:,colId,tPoint) = reshape(slice, [vSizeX vSizeY])';
                    end
                case 'single'
                    for tPoint=1:vSizeT
                        img(:,:,colId,tPoint) = handles.connImaris.mImarisApplication.GetDataSet.GetDataSliceFloats(0, colId-1, tPoint-1)';
                    end
            end
        end
        if t==timePointsImaris(1)
            ColorRGBA = handles.connImaris.mImarisApplication.GetDataSet.GetChannelColorRGBA(colId-1);
            ColorRGBA = handles.connImaris.mapRgbaScalarToVector(ColorRGBA);
            colorChannels(colId,:) = ColorRGBA(1:3);
            handles.Img{handles.Id}.I.lutColors(colId,:) = ColorRGBA(1:3);
        end
        waitbar(colId/maxWaitbarIndex, wb);
        callsId = callsId + 1;
    end
    tIndex = tIndex + 1;
end

% import ImageDescription
logText = char(handles.connImaris.mImarisApplication.GetDataSet.GetParameter('Image','Description'));
if ~isempty(strfind(logText, 'BoundingBox'))
    linefeeds = strfind(logText, sprintf('\n'));    % get linefeeds
    for linefeed = 1:numel(linefeeds)-1
        img_info('ImageDescription') = [img_info('ImageDescription') logText(linefeeds(linefeed)+1:linefeeds(linefeed+1)-1) '|'];
    end
end
set(handles.lutCheckbox, 'value', 1);
delete(wb);
end


function imOut = getByBlocks(connImaris, colId, timePoint)
blockSizeX = 512;
blockSizeY = 512;
blockSizeZ = 512;

[sizeX, sizeY, sizeZ, sizeC, sizeT] = connImaris.getSizes();

imOut = zeros(sizeY, sizeX, 1, sizeZ, connImaris.getMatlabDatatype());

for z=0:ceil(sizeZ/blockSizeZ)-1
    for y=0:ceil(sizeY/blockSizeY)-1
        for x=0:ceil(sizeX/blockSizeX)-1
            imgBlock = connImaris.getDataSubVolumeRM(blockSizeX*x, blockSizeY*y, blockSizeZ*z,...
                colId, timePoint,...
                min(blockSizeX+blockSizeX*x, sizeX)-blockSizeX*x,...
                min(blockSizeY+blockSizeY*y, sizeY)-blockSizeY*y,...
                min(blockSizeZ+blockSizeZ*z, sizeZ)-blockSizeZ*z);
            
            
            imOut(1+blockSizeY*y:min(blockSizeY+blockSizeY*y, sizeY),...
                1+blockSizeX*x:min(blockSizeX+blockSizeX*x, sizeX),...
                1,...
                1+blockSizeZ*z:min(blockSizeZ+blockSizeZ*z, sizeZ)) = permute(imgBlock, [1,2,4,3]);
        end
    end
end

end