function handles = replaceDataset(obj, img, handles, img_info, modelImg, maskImg, selectionImg)
% function handles = replaceDataset(obj, img, handles, img_info, modelImg, maskImg, selectionImg)
% Replace existing dataset with a new one.
%
% Parameters:
% img: a new 2D/3D image stack
% handles: handles structure from im_browser
% img_info: [@em optional] a 'containers'.'Map' class with parameters of the dataset, can be @e NaN
% modelImg: [@em optional] the 'Model' layer, can be @e NaN
% maskImg: [@em optional] the 'Mask' layer, can be @e NaN
% selectionImg: [@em optional] the 'Selection' layer
%
% Return values:
% handles: handles structure from im_browser

%| 
% @b Examples:
% @code handles = imageData.replaceDataset(img, handles, img_info);     // replace the imageData.img with new stack from img  @endcode
% @code handles = replaceDataset(obj, img, handles, img_info); // Call within the class; replace the imageData.img with new stack from img  @endcode

% Copyright (C) 03.03.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices to cells


obj.width = size(img,2);
obj.height = size(img,1);
obj.colors = size(img,3);
obj.no_stacks = size(img,4);
obj.time = size(img,5);

handles.U.clearContents();  % clear Undo class
obj.hROI.clearData();   % remove all ROIs

% clear some class parameters
%obj.imh = image(handles.imageAxes, 'CData',[], 'UserData', 'new');  % handle for image object
obj.imh = matlab.graphics.primitive.Image('CData',[],'UserData', 'new');

obj.orientation = 4;
obj.current_yxz = [1 1 1];
obj.brush_prev_xy = NaN;    % coordinates of the previous pixel for brush
obj.brush_selection = NaN;  % selection during brush movement

obj.model_diff_max = 255;
obj.trackerYXZ = [NaN;NaN;NaN];   % starting point for membrane tracer
obj.slices{1} = [1,obj.height];  % height [min, max]
obj.slices{2} = [1,obj.width];   % width [min, max]
obj.slices{3} = 1:obj.colors;    % list of shown color channels [1, 2, 3, 4...]
obj.slices{4} = [1, 1];          % z-values, [min, max]
obj.slices{5} = [1, 1];          % time points, [min, max]    
    
    
if handles.preferences.uint8
    % no selection layer
    if strcmp(handles.preferences.disableSelection, 'yes')
        obj.selection = NaN;
    else
        if nargin < 7
            obj.selection = zeros([obj.height, obj.width, obj.no_stacks, obj.time], 'uint8');
        else
            obj.selection = selectionImg;
        end
    end;
    
    if nargin < 6
        obj.maskImg = NaN;
        obj.maskImgFilename = NaN;
        obj.maskExist = 0;
    else
        handles.maskImg = maskImg;
        if ~isnan(maskImg(1)) || isempty(maskImg)
            obj.maskExist = 1;
        end
    end
    
    if nargin < 5
        obj.model = NaN;
        obj.modelExist = 0;
    else
        obj.model = modelImg;
        obj.model_type = 'uint8';  % a model type 'uint6', or 'uint8'
        if ~isnan(modelImg(1)) || isempty(modelImg)
            obj.modelExist = 1;
        end
    end
else        % ************ uint6 model type
    if nargin < 7; selectionImg = NaN; end;
    if nargin < 6; maskImg = NaN; end;
    if nargin < 5; modelImg = NaN; end;
    if ~isnan(modelImg(1))
        obj.model = modelImg;
        obj.modelExist = 1;
    else
        obj.modelExist = 0;
        if strcmp(handles.preferences.disableSelection, 'no')   % selection is enabled
            obj.model = zeros([obj.height, obj.width, obj.no_stacks, obj.time], 'uint8');
            if ~isnan(selectionImg(1))
                obj.model(selectionImg==1) = bitset(obj.model(selectionImg==1), 8, 1);
            end
            if ~isnan(maskImg(1))
                obj.model(maskImg==1) = bitset(obj.model(maskImg==1), 7, 1);
                obj.maskExist = 1;
            else
                obj.maskExist = 0;
            end
        else        % selection is disabled
            obj.model = NaN;
        end
    end
    obj.model_type = 'uint6';
end

if nargin < 4
    img_info = NaN;
end

obj.img = img;
if obj.modelExist; set(handles.modelShowCheck,'Value',0); end;
if obj.maskExist; set(handles.maskShowCheck,'Value',0); end;

if isa(img_info,'containers.Map')
    obj.img_info = img_info;
    if ~isKey(img_info,'ColorType')
        if size(img,3) == 1
            obj.img_info('ColorType') = 'grayscale';
        else
            obj.img_info('ColorType') = 'truecolor';
        end
    end
    if ~isKey(img_info,'ImageDescription') || isempty(img_info('ImageDescription'))
        obj.img_info('ImageDescription') = sprintf('|');
    else
        img_info('ImageDescription') = strrep(img_info('ImageDescription'), sprintf('\t'), '|');   % replace \t with || because of the older versions of im_browser
        if isempty(strfind(obj.img_info('ImageDescription'), sprintf('|'))) && isempty(strfind(obj.img_info('ImageDescription'), 'BoundingBox'))   % add a tab sign in the beginning of the ImageDescription string
            obj.img_info('ImageDescription') = [sprintf('|') obj.img_info('ImageDescription')];
        end
    end
    if ~isKey(img_info,'Filename')
        obj.img_info('Filename') = fullfile(handles.mypath, 'dataset.tif');
    end
else
    %keySet = {'ColorType', 'ImageDescription','Height','Width','Stacks','XResolution','YResolution','ResolutionUnit','Filename'};
    %valueSet = {'grayscale', sprintf('|'),1,1,1,1,1,'Inch','none.tif'};
    keySet = {'ColorType', 'ImageDescription','Height','Width','Stacks','ResolutionUnit','Filename'};
    valueSet = {'grayscale', sprintf('|'),1,1,1,'Inch','none.tif'};
    obj.img_info = containers.Map(keySet,valueSet);
    if size(img,3) > 1
        obj.img_info('ColorType') = 'truecolor';
    else
        obj.img_info('ColorType') = 'grayscale';
    end
end

obj.img_info('Height') = obj.height;
obj.img_info('Width') = obj.width;
obj.img_info('Stacks') = obj.no_stacks;
obj.img_info('Time') = obj.time;

obj.slices{1} = [1, obj.height];
obj.slices{2} = [1, obj.width];
obj.slices{4} = [1, 1];
obj.slices{5} = [1, 1];
if get(handles.lutCheckbox, 'value') == 1
    obj.slices{3} = 1:size(obj.img,3);
else
    obj.slices{3} = 1:min([size(obj.img,3) 3]);
end

% modify filename for the mask
if isnan(obj.maskImgFilename)
    pathStr = fileparts(obj.img_info('Filename'));
    if ~isempty(pathStr)
        [pathStr, filenameStr] = fileparts(obj.img_info('Filename'));
        obj.maskImgFilename = fullfile(pathStr, [filenameStr '.mask']);
    end
end

if isa(img_info,'containers.Map')
    if isKey(img_info, 'lutColors')
        if ischar(img_info('lutColors')); img_info('lutColors') = str2num(img_info('lutColors')); end;
        obj.lutColors(1:size(img_info('lutColors'),1), :) = img_info('lutColors');
    end
end

[obj.img_info, obj.pixSize] = ib_updatePixSizeAndResolution(obj.img_info, obj.pixSize);
handles = updateAxesLimits(obj, handles, 'resize');
handles.Img{handles.Id}.I.updateDisplayParameters();

R = [0 0 0];
S = [1*obj.magFactor,...
     1*obj.magFactor,...
     1*obj.pixSize.x/obj.pixSize.z*obj.magFactor];  
T = [0 0 0];
obj.volren.viewer_matrix = makeViewMatrix(R, S, T);

handles = updateGuiWidgets(handles);
handles = guidata(handles.im_browser);

% update bufferToggles
if ismac()
    eval(sprintf('set(handles.bufferToggle%d,''ForegroundColor'',[0 1 0]);', handles.Id));     % make green
else
    eval(sprintf('set(handles.bufferToggle%d,''BackgroundColor'',[0 1 0]);', handles.Id));     % make green
end
eval(sprintf('set(handles.bufferToggle%d,''TooltipString'', obj.img_info(''Filename''));',handles.Id));     % make a tooltip as filename

% move focus to the main window
%set(handles.updatefilelistBtn, 'Enable', 'off');
%drawnow;
%set(handles.updatefilelistBtn, 'Enable', 'on');
%             warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
%             javaFrame = get(handles.im_browser,'JavaFrame');
%             javaFrame.getAxisComponent.requestFocus;
%             drawnow;
end