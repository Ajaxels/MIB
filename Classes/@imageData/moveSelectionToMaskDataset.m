function moveSelectionToMaskDataset(obj, action_type, options)
% function moveSelectionToMaskDataset(obj, action_type, options)
% Move the Selection layer to the Mask layer.
%
% This is one of the specific function to move datasets between the layers.
% Allows faster move of complete datasets between the layers than using of
% ib_getDataset.m / ib_setDataset.m functions.
%
% Parameters:
% action_type: a type of the desired action
% - ''add'' - add selection to mask
% - ''remove'' - remove selection from mask
% - ''replace'' - replace mask with selection
% options: a structure with additional paramters
% - @b .contSelIndex    - index of the @em Select @em from material
% - @b .contAddIndex    - index of the @em Add @em to material
% - @b .selected_sw     - [0 / 1] switch to limit actions to the selected @em Select @em from material only
% - @b .maskedAreaSw    - [0 / 1] switch to limit actions to the masked areas
%
% Return values:

%| 
% @b Examples:
% @code 
% options.contSelIndex = get(handles.segmSelList,'Value')-2; // index of the selected material
% options.contAddIndex = get(handles.segmAddList,'Value')-2; // index of the target material
% options.selected_sw = get(handles.segmSelectedOnlyCheck,'value');   // when 1- limit selection to the selected material
% options.maskedAreaSw = get(handles.maskedAreaCheck,'Value');
% @endcode
% @code imageData.moveSelectionToMaskDataset('add', options);     // add selection to mask  @endcode
% @code moveSelectionToMaskDataset(obj, 'add', options);     // call from the imageData class, add selection to mask  @endcode
% @attention @b NOT @b sensitive to the imageData.blockModeSwitch
% @attention @b NOT @b sensitive to the shown ROI
% @see imageData.moveMaskToSelectionDataset imageData.moveModelToMaskDataset imageData.moveModelToSelectionDataset imageData.moveSelectionToMaskDataset imageData.moveSelectionToModelDataset

% Copyright (C) 06.09.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 20.01.2016, IB, adapted to use imageData.getData4D method

% % filter the obj_type_from depending on elected_sw and/or maskedAreaSw states
imgTemp = NaN; % a temporal variable to keep modified version of dataset when selected_sw and/or maskedAreaSw are on
if strcmp(obj.model_type, 'uint6')      % uint6 type of the model
    if options.selected_sw && obj.modelExist && options.maskedAreaSw==0
        imgTemp = bitand(uint8(bitand(obj.model, 63)==options.contSelIndex), bitand(obj.model, 128)/128);   % intersection of material and selection
    elseif options.maskedAreaSw && options.selected_sw == 0  % when only masked area selected
        if strcmp(action_type, 'add'); return; end;
        if strcmp(action_type, 'replace');
            imgTemp = bitand(bitand(obj.model, 64)/64, bitand(obj.model, 128)/128);     % intersection of mask and selection
        end
    elseif options.selected_sw && obj.modelExist && options.maskedAreaSw==1
        if strcmp(action_type, 'add'); return; end;
        imgTemp = bitand(uint8(bitand(obj.model, 63)==options.contSelIndex), bitand(obj.model, 128)/128); % intersection of material and selection
        imgTemp = bitand(imgTemp, bitand(obj.model, 64)/64);    % additional intersection with mask
    end
else            % uint8 type of the model
    if options.selected_sw && obj.modelExist && options.maskedAreaSw==0
        imgTemp = obj.getData4D('model', 4, options.contSelIndex);  % get selected material
        imgTemp = bitand(obj.selection, imgTemp);   % generate intersection between the material and selection
    end
    if options.maskedAreaSw && options.selected_sw == 0     % when only masked area selected
        if strcmp(action_type, 'add'); return; end;
        if strcmp(action_type, 'replace');
            imgTemp = bitand(obj.selection, obj.maskImg);
        end
    end
    if options.selected_sw && obj.modelExist && options.maskedAreaSw==1
        if strcmp(action_type, 'add'); return; end;
        imgTemp = obj.getData4D('model', 4, options.contSelIndex);     % get selected material
        imgTemp = bitand(bitand(imgTemp, obj.maskImg), obj.selection); % generate intersection between the material, selection and mask
    end
end

switch action_type
    case 'add'  % add selection to mask
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                obj.model = bitor(obj.model, bitand(obj.model, 128)/2);     % copy selection to mask
                obj.model = bitand(obj.model, 127); % clear selection
            else     % add layers for the selected or masked areas only
                obj.model = bitor(obj.model, imgTemp*64);
                obj.model = bitand(obj.model, 127); % clear selection
            end
        else    % uint8 type of the model
            if obj.maskExist == 0   % if mask is not present allocate space for it
                obj.maskImg = zeros(size(obj.selection),'uint8');
            end
            if isnan(imgTemp(1))    % add layers for the whole dataset
                obj.maskImg = bitor(obj.selection, obj.maskImg);    % copy selection to mask
                obj.selection = zeros(size(obj.selection), class(obj.selection));     % clear selection
            else     % add layers for the selected or masked areas only
                obj.maskImg = bitor(obj.maskImg, imgTemp);  % copy selection to mask
                obj.selection = zeros(size(obj.selection), class(obj.selection));     % clear selection
            end
        end
    case 'remove'   % subtract selection from mask
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                %obj.model(bitand(obj.model, 128)==128) = bitand(obj.model(bitand(obj.model, 128)==128), 63);
                %obj.model(obj.model>127) = bitand(obj.model(obj.model>127), 63); %this code is x2 slower, than the code below (1.8 vs 0.8 sec)
                imgTemp = bitget(obj.model, 7);
                imgTemp = imgTemp - bitget(obj.model, 8); % mask - selection
                obj.model = bitand(obj.model, 63); % clear selection and mask
                obj.model = bitor(obj.model, imgTemp*64); % set mask
            else     % add layers for the selected or masked areas only
                imgTemp = bitand(obj.model, 64)/64 - imgTemp;
                obj.model = bitand(obj.model, 63); % clear selection and mask
                obj.model = bitor(obj.model, imgTemp*64);  % set mask
            end
        else
            if isnan(imgTemp(1))    % add layers for the whole dataset
                obj.maskImg = obj.maskImg - obj.selection;
            else     % add layers for the selected or masked areas only
                obj.maskImg  = obj.maskImg - imgTemp;
            end
            obj.selection = zeros(size(obj.selection), class(obj.selection));     % clear selection
        end
    case 'replace'  % replace selection with mask
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                imgTemp = bitget(obj.model, 8);
                obj.model = bitand(obj.model, 63); % clear selection and mask
                obj.model = bitor(obj.model, imgTemp*64);  % set mask
            else     % add layers for the selected or masked areas only
                obj.model = bitand(obj.model, 63); % clear selection and mask
                obj.model = bitor(obj.model, imgTemp*64);  % set mask
            end
        else
            if isnan(imgTemp(1))    % add layers for the whole dataset
                obj.maskImg = obj.selection;
            else     % add layers for the selected or masked areas only
                obj.maskImg = imgTemp;
            end
            obj.selection = zeros(size(obj.selection), class(obj.selection));     % clear selection
        end
end
obj.maskExist = 1;
end