function handles = ib_renderModelImaris(handles)
% function handles = ib_renderModelImaris(handles)
% Render a model in Imaris. 
%
% Parameters:
% handles: handles structure from im_browser
%
%
% Return values:
% handles:  handles structure from im_browser

% @note 
% uses IceImarisConnector bindings
% @b Requires:
% 1. set system environment variable IMARISPATH to the installation
% directory, for example "c:\tools\science\imaris"
% 2. restart Matlab
% 

%|
% @b Examples:
% @code handles = ib_setImarisDataset(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.img_info, handles);     // get dataset from imaris @endcode

% Copyright (C) 05.11.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Written with a help of an old code SurfacesFromSegmentationImage.m by
% Igor Beati, Bitplane.
%
% Updates
% 26.10.2016, IB, updated for segmentation table

answer = inputdlg(sprintf('!!! ATTENTION !!!\n\nA volume that is currently open in Imaris will be removed!\nYou can preserve it by importing it into MIB and exporting it back to Imaris after the surface is generated.\n\nTo proceed further please define a smoothing factor,\na number, 0 or higher (IN IMAGE UNITS);\ncurrent voxel size: %.4f x %.4f x %.4f:', ...
    handles.Img{handles.Id}.I.pixSize.x, handles.Img{handles.Id}.I.pixSize.y, handles.Img{handles.Id}.I.pixSize.z),'Smoothing factor',1,{'0'});
%answer = mib_inputdlg(handles, sprintf('!!! ATTENTION !!!A volume that is currently open in Imaris will be removed!\nYou can preserve it by importing it into MIB and exporting it back to Imaris after the surface is generated.\n\nTo proceed further please define a smoothing factor,\na number, 0 or higher (IN IMAGE UNITS):'),'Smoothing factor','0');
if isempty(answer); return; end;
vSmoothing = str2double(answer{1});

% establishing connection to Imaris
wb = waitbar(0, 'Please wait...', 'Name', 'Connecting to Imaris');
if ~isfield(handles, 'connImaris')
    try
        handles.connImaris = IceImarisConnector(0);
    catch exception
        errordlg(sprintf('Could not connect to Imaris Server;\nPlease start Imaris and try again!'),'Missing Imaris');
        delete(wb);
        return;
    end
    if handles.connImaris.isAlive == 0
        % start Imaris
        handles.connImaris.startImaris();
    end
else
    if handles.connImaris.isAlive == 0
        % start Imaris
        handles.connImaris.startImaris();
    end
end
delete(wb);

% define index of material to model, NaN - model all
userData = get(handles.segmTable,'UserData');
if userData.showAll == 1    % all materials
    materialStart = 1;  
    materialEnd = numel(handles.Img{handles.Id}.I.modelMaterialNames);  
    vNumberOfObjects = numel(handles.Img{handles.Id}.I.modelMaterialNames);
else
    materialStart = userData.prevMaterial-2;  
    materialEnd = userData.prevMaterial-2;  
    vNumberOfObjects = 1;
end

if handles.Img{handles.Id}.I.time > 1
    mode = questdlg(sprintf('Would you like to export currently shown 3D (W:H:C:Z) stack or complete 4D (W:H:C:Z:T) dataset to Imaris?'),'Export to Imaris','3D','4D','Cancel','3D');
    if strcmp(mode, 'Cancel'); return; end;
else
    mode = '3D';
end
if ~isempty(handles.connImaris.mImarisApplication.GetDataSet) && strcmp(mode, '3D')
    [vSizeX, vSizeY, vSizeZ, vSizeC, vSizeT] = handles.connImaris.getSizes();
    if vSizeZ > 1 && vSizeT > 1 && strcmp(mode, '3D')
        insertInto = mib_inputdlg(handles, sprintf('!!! Warning !!!\n\nA 5D dataset is open in Imaris!\nPlease enter a time point to update (starting from 0)\nor type "-1" to replace dataset completely'), 'Time point', handles.Img{handles.Id}.I.slices{5}(1));
        if isempty(insertInto); return; end;
        imarisOptions.insertInto = insertInto;
    end
end
imarisOptions.type = 'model';
imarisOptions.mode = mode;

wb = waitbar(0, 'Please wait...','Name','Rendering model in Imaris');
tic
for vIndex = materialStart:materialEnd
    imarisOptions.modelIndex = vIndex;
    %-- to export as multiple color channels --% imarisOptions.modelIndex = NaN;
    handles = ib_setImarisDataset(handles, imarisOptions);
    aDataSet = handles.connImaris.mImarisApplication.GetDataSet();
    if isempty(aDataSet)
        errordlg(sprintf('!!! Error !!!\nThe dataset was not transferred...'),'Error');
        delete(wb);
        return;
    end
    
    % generate surface
    vSurfaces = handles.connImaris.mImarisApplication.GetImageProcessing.DetectSurfaces(...
       aDataSet, [], 0, vSmoothing, 0, 0, .5, '');     
    
%-- to export as multiple color channels --%     for vIndex = materialStart:materialEnd
%-- to export as multiple color channels --%         vSurfaces = handles.connImaris.mImarisApplication.GetImageProcessing.DetectSurfaces(...
%-- to export as multiple color channels --%             aDataSet, [], vIndex-1, vSmoothing, 0, 0, .5, '');
%-- to export as multiple color channels --%         vSurfaces.SetName(handles.Img{handles.Id}.I.modelMaterialNames{vIndex});
%-- to export as multiple color channels --%         % set color for the surface
%-- to export as multiple color channels --%         ColorRGBA = [handles.Img{handles.Id}.I.modelMaterialColors(vIndex,:), 0];
%-- to export as multiple color channels --%         ColorRGBA = handles.connImaris.mapRgbaVectorToScalar(ColorRGBA);
%-- to export as multiple color channels --%         vSurfaces.SetColorRGBA(ColorRGBA);
%-- to export as multiple color channels --%         % add surface to scene
%-- to export as multiple color channels --%         handles.connImaris.mImarisApplication.GetSurpassScene.AddChild(vSurfaces, -1);
%-- to export as multiple color channels --%     end
    
    vSurfaces.SetName(handles.Img{handles.Id}.I.modelMaterialNames{vIndex});
    % set color for the surface
    ColorRGBA = [handles.Img{handles.Id}.I.modelMaterialColors(vIndex,:), 0];
    ColorRGBA = handles.connImaris.mapRgbaVectorToScalar(ColorRGBA);
    vSurfaces.SetColorRGBA(ColorRGBA);
    
    % add surface to scene
    handles.connImaris.mImarisApplication.GetSurpassScene.AddChild(vSurfaces, -1);
    waitbar(vIndex / vNumberOfObjects, wb);
end
delete(wb);
toc
end