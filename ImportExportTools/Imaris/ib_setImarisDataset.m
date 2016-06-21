function handles = ib_setImarisDataset(handles, options)
% function handles = ib_setImarisDataset(handles, options)
% Send a dataset from MIB to Imaris
%
% Parameters:
% handles: handles structure from im_browser
% options: an optional structure with additional settings (for example, when is called
% from ib_renderModelImaris.m)
% @li .type -> [@em optional] type of dataset to send ('image', 'model', 'mask', 'selection')
% @li .modelIndex [@em optional] index of a model material to send, could be @em NaN
% @li .mode -> [@em optional] type of mode for sending ('3D', '4D')
% @li .insertInto -> [@em optional] a cell with index where to insert the Z-stack, when -1 replaces the whole dataset;
%
% Return values:
% handles:  handles structure from im_browser

% @note
% uses IceImarisConnector bindings
% @b Requires:
% 1. set system environment variable IMARISPATH to the installation
% directory, for example "c:\tools\science\imaris"
% 2. restart Matlab

%|
% @b Examples:
% @code handles = ib_setImarisDataset(handles);     // send dataset from matlab to imaris @endcode

% Copyright (C) 05.11.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 02.02.2016, updated for 4D

if nargin < 2;     options = struct(); end;

if ~isfield(options, 'type'); options.type = 'image'; end;
if ~isfield(options, 'modelIndex'); options.modelIndex = NaN; end;

% establish connection to Imaris
wb = waitbar(0, 'Please wait...', 'Name', 'Connecting to Imaris');
if ~isfield(handles, 'connImaris')
    try
        handles.connImaris = IceImarisConnector(0);
        waitbar(0.3, wb);
    catch exception
        %if strcmp(exception.message, 'Could not connect to Imaris Server.')
        errordlg(sprintf('Could not connect to Imaris Server;\nPlease start Imaris and try again!'),'Missing Imaris');
        delete(wb);
        return;
    end
    waitbar(0.7, wb);
    if handles.connImaris.isAlive == 0
        % start Imaris
        handles.connImaris.startImaris()
        waitbar(0.95, wb);
    end
else
    if handles.connImaris.isAlive == 0
        handles.connImaris.startImaris();
    end
end
delete(wb);

if isfield(options, 'mode')     % mode already provided
    mode = options.mode;
else
    if handles.Img{handles.Id}.I.time > 1
        mode = questdlg(sprintf('Would you like to export currently shown 3D (W:H:C:Z) stack or complete 4D (W:H:C:Z:T) dataset to Imaris?'),'Export to Imaris','3D','4D','Cancel','3D');
        if strcmp(mode, 'Cancel'); return; end;
    else
        mode = '3D';
    end
end

options.blockModeSwitch = 0;
[sizeY, sizeX, maxColors, sizeZ, maxTime] = handles.Img{handles.Id}.I.getDatasetDimensions('image', 4, NaN, options); % get dataset dimensions

blockSizeX = 512;
blockSizeY = 512;
blockSizeZ = 512;

useBlockMode = 0;
if sizeX*sizeY*sizeZ > 134217728 % = 512 x 512 x 512
    useBlockMode = 1;
end
if strcmp(options.type, 'image')
    noColors = numel(handles.Img{handles.Id}.I.slices{3});  % number of shown colors
    dataClass = class(handles.Img{handles.Id}.I.img);
else
    if isnan(options.modelIndex)
        noColors = numel(handles.Img{handles.Id}.I.modelMaterialNames);  % number of shown colors
        options.modelIndex = 1:numel(handles.Img{handles.Id}.I.modelMaterialNames);
    else
        noColors = 1;
    end
    dataClass = class(handles.Img{handles.Id}.I.model);
end

updateBoundingBox = 1;  % switch to update bouning box
% check whether replace the dataset or update a time point
if strcmp(mode, '4D')
    % create an empty dataset
    handles.connImaris.createDataset(dataClass, sizeX, sizeY, sizeZ, noColors, maxTime);
    timePointsIn = 1:maxTime;   % list of time points in the MIB dataset
    timePointsOut = 1:maxTime;  % list of time points in the Imaris dataset
elseif isempty(handles.connImaris.mImarisApplication.GetDataSet) && strcmp(mode, '3D')
    % create an empty dataset
    handles.connImaris.createDataset(dataClass, sizeX, sizeY, sizeZ, noColors, 1);
    timePointsIn = handles.Img{handles.Id}.I.slices{5}(1);  % list of time points in the MIB dataset
    timePointsOut = 1;  % list of time points in the Imaris dataset
else
    [vSizeX, vSizeY, vSizeZ, vSizeC, vSizeT] = handles.connImaris.getSizes();
    if vSizeZ > 1 && vSizeT > 1 && strcmp(mode, '3D')
        if ~isfield(options, 'insertInto')
            insertInto = mib_inputdlg(handles, sprintf('!!! Warning !!!\n\nA 5D dataset is open in Imaris!\nPlease enter a time point to update (starting from 0)\nor type "-1" to replace dataset completely'), 'Time point', handles.Img{handles.Id}.I.slices{5}(1));
            if isempty(insertInto);            return;        end;
        else
            insertInto = options.insertInto;
        end
        if str2double(insertInto{1}) == -1
            % create an empty dataset
            handles.connImaris.createDataset(dataClass, sizeX, sizeY, sizeZ, noColors, 1);
            timePointsIn = handles.Img{handles.Id}.I.slices{5}(1);
            timePointsOut = 1;
        else
            timePointsIn = str2double(insertInto{1});
            timePointsOut = str2double(insertInto{1});
            updateBoundingBox = 0;
        end
    else
        % create an empty dataset
        handles.connImaris.createDataset(dataClass, sizeX, sizeY, sizeZ, noColors, 1);
        timePointsIn = handles.Img{handles.Id}.I.slices{5}(1);  % list of time points in the MIB dataset
        timePointsOut = 1;  % list of time points in the Imaris dataset
    end
end
wb = waitbar(0, 'Please wait...','Name','Export image to Imaris');
callsId = 0;

if useBlockMode == 0
    maxWaitbarIndex = numel(timePointsIn)*noColors;
else
    maxWaitbarIndex = noColors*ceil(sizeZ/blockSizeZ)*ceil(sizeY/blockSizeY)*ceil(sizeX/blockSizeX)*numel(timePointsIn);
end

tIndex = 1;
for t=timePointsIn
    for colId = 1:noColors
        % get color channel
        if strcmp(options.type, 'image')
            colorIndex = handles.Img{handles.Id}.I.slices{3}(colId);    % index of the selected colors
        else
            colorIndex = options.modelIndex(colId);
        end
        
        img = squeeze(handles.Img{handles.Id}.I.getData3D(options.type, t, 4, colorIndex, options));
        % set dataset as a new
        if useBlockMode == 0
            handles.connImaris.setDataVolumeRM(img(:,:,:), colId-1, timePointsOut(tIndex)-1);
            callsId = callsId + 1;
        else
            for z=0:ceil(sizeZ/blockSizeZ)-1
                for y=0:ceil(sizeY/blockSizeY)-1
                    for x=0:ceil(sizeX/blockSizeX)-1
                        imgBlock = img(...
                            1+blockSizeY*y:min(blockSizeY+blockSizeY*y, sizeY) ,...
                            1+blockSizeX*x:min(blockSizeX+blockSizeX*x, sizeX) ,...
                            1+blockSizeZ*z:min(blockSizeZ+blockSizeZ*z, sizeZ));
                        
                        handles.connImaris.mib_setDataSubVolumeRM(imgBlock,...
                            blockSizeX*x, blockSizeY*y, blockSizeZ*z,...
                            colId-1, timePointsOut(tIndex)-1,...
                            size(imgBlock,2), size(imgBlock,1), size(imgBlock,3));
                        callsId = callsId + 1;
                        waitbar(callsId/maxWaitbarIndex, wb);
                    end
                end
            end
        end
        
        % update contrast for color channels
        if t == timePointsIn(1)
            if strcmp(options.type, 'image')
                % get color channel
                colorData = get(handles.channelMixerTable,'data');   % get data in the channelMixerTable
                colorIndex = handles.Img{handles.Id}.I.slices{3}(colId);    % index of the selected colors
                handles.connImaris.mImarisApplication.GetDataSet.SetChannelRange(colId-1, ...
                    handles.Img{handles.Id}.I.viewPort.min(colorIndex), handles.Img{handles.Id}.I.viewPort.max(colorIndex));
                handles.connImaris.mImarisApplication.GetDataSet.SetChannelGamma(colId-1, handles.Img{handles.Id}.I.viewPort.gamma(colorIndex));
            
                ColorRGBA = colorData{colorIndex,3};
                index1 = strfind(ColorRGBA, 'rgb(');    % example: '<html><table border=0 width=40 bgcolor='rgb(0, 0, 0)'><TR><TD>&nbsp;</TD></TR> </table></html>'
                index2 = strfind(ColorRGBA, '><TR>');
                ColorRGBA = ColorRGBA(index1+4:index2-3);
                %ColorRGBA = str2num(ColorRGBA)/double(intmax(class(img))); %#ok<ST2NM>
                ColorRGBA = str2num(ColorRGBA)/255; %#ok<ST2NM>
            
                % replace black with white
                for i=1:size(ColorRGBA,1)
                    if sum(ColorRGBA(i,:)) == 0
                        ColorRGBA(i,:) = [1 1 1];
                    end
                end
                ColorRGBA(4) = 0;   % add Alpha value
                ColorRGBA = handles.connImaris.mapRgbaVectorToScalar(ColorRGBA);
            else
                % set color for the surface
                ColorRGBA = [handles.Img{handles.Id}.I.modelMaterialColors(colorIndex,:) 0];
                ColorRGBA = handles.connImaris.mapRgbaVectorToScalar(ColorRGBA);   
                handles.connImaris.mImarisApplication.GetDataSet.SetChannelRange(colId-1, ...
                    0, max(max(max(max(img)))));
            end
            handles.connImaris.mImarisApplication.GetDataSet.SetChannelColorRGBA(colId-1, ColorRGBA);     % update color channel
        end
        waitbar(callsId/maxWaitbarIndex, wb);
    end
    tIndex = tIndex + 1;
end

% update BoundingBox and Image Description
if updateBoundingBox == 1
    bb = handles.Img{handles.Id}.I.getBoundingBox();    % bb[xMin, xMax, yMin, yMax, zMin, zMax]
    handles.connImaris.mImarisApplication.GetDataSet.SetExtendMinX(bb(1));
    handles.connImaris.mImarisApplication.GetDataSet.SetExtendMaxX(bb(2));
    handles.connImaris.mImarisApplication.GetDataSet.SetExtendMinY(bb(3));
    handles.connImaris.mImarisApplication.GetDataSet.SetExtendMaxY(bb(4));
    handles.connImaris.mImarisApplication.GetDataSet.SetExtendMinZ(bb(5));
    % fix of a problem of different calculations of the bounding box for a
    % single slice and Z-stack
    if size(img,4) > 1
        handles.connImaris.mImarisApplication.GetDataSet.SetExtendMaxZ(bb(6)+handles.Img{handles.Id}.I.pixSize.z);
    else
        handles.connImaris.mImarisApplication.GetDataSet.SetExtendMaxZ(bb(6));
    end
    
    logText = handles.Img{handles.Id}.I.img_info('ImageDescription');
    linefeeds = strfind(logText,sprintf('|'));
    
    if ~isempty(linefeeds)
        for linefeed = 1:numel(linefeeds)
            if linefeed == 1
                logTextForm(linefeed) = cellstr(logText(1:linefeeds(1)-1)); %#ok<AGROW>
            else
                logTextForm(linefeed) = cellstr(logText(linefeeds(linefeed-1)+1:linefeeds(linefeed)-1)); %#ok<AGROW>
            end
        end
        if numel(logText(linefeeds(end)+1:end)) > 1
            logTextForm(linefeed+1) = cellstr(logText(linefeeds(end)+1:end));
        end
    else
        logTextForm = [];
    end
    logOut = [];
    for i=1:numel(logTextForm)
        logOut = [logOut sprintf('%s\n',logTextForm{i})];
    end
    handles.connImaris.mImarisApplication.GetDataSet.SetParameter('Image','Description',logOut);
end

% set the time point for the dataset to sync it later with models
if numel(timePointsIn) == 1 && timePointsOut(1) == 1     % single 3D dataset
    handles.connImaris.mImarisApplication.GetDataSet.SetTimePoint(0, '0000-01-00 00:00:00.000');
% elseif numel(timePointsIn) == 1 && timePointsOut(1) ~= 1  % single 3D dataset into the opened dataset
%     stringTime = datestr(datenum('0000-01-00 00:00:00.000', 'yyyy-mm-dd HH:MM:SS.FFF') + ...
%         datenum(sprintf('0000-01-00 00:00:%.3f', (timePointsIn(1)-1)*handles.Img{handles.Id}.I.pixSize.t), 'yyyy-mm-dd HH:MM:SS.FFF'),...
%         'yyyy-mm-dd HH:MM:SS.FFF');
%     handles.connImaris.mImarisApplication.GetDataSet.SetTimePoint(timePointsOut(1), stringTime);
else
    stringTime = datestr(datenum('0000-01-00 00:00:00.000', 'yyyy-mm-dd HH:MM:SS.FFF') + ...
        datenum(sprintf('0000-01-00 00:00:%3f', (timePointsIn(1)-1)*handles.Img{handles.Id}.I.pixSize.t), 'yyyy-mm-dd HH:MM:SS.FFF'),...
        'yyyy-mm-dd HH:MM:SS.FFF');
    handles.connImaris.mImarisApplication.GetDataSet.SetTimePoint(timePointsOut(1)-1, stringTime);
    handles.connImaris.mImarisApplication.GetDataSet.SetTimePointsDelta(handles.Img{handles.Id}.I.pixSize.t);
end
delete(wb);
end
