function moveSelectionToModelDataset(obj, action_type, options)
% function moveSelectionToModelDataset(obj, action_type, options)
% Move selection layer to the model layer.
%
% This is one of the specific functions to move datasets between the layers.
% Allows faster move of complete datasets between the layers than using of
% ib_getDataset.m / ib_setDataset.m functions.
%
% Parameters:
% action_type: a type of the desired action
% - ''add'' - add selection to the selected material (@em Add @em to)
% - ''remove'' - remove selection from the model
% - ''replace'' - replace the selected (@em Add @em to) material with selection
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
% @code imageData.moveSelectionToModelDataset('add', options);     // add selection to model  @endcode
% @code moveSelectionToModelDataset(obj, 'add', options);     // call from the imageData class, add selection to model  @endcode
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
% 



% % filter the obj_type_from depending on elected_sw and/or maskedAreaSw states
imgTemp = NaN; % a temporal variable to keep modified version of dataset when selected_sw and/or maskedAreaSw are on
if strcmp(obj.model_type, 'uint6')      % uint6 type of the model
    if options.selected_sw && obj.modelExist && options.maskedAreaSw==0
        imgTemp = bitand(uint8(bitand(obj.model, 63)==options.contSelIndex), bitand(obj.model, 128)/128);   % intersection of material and selection
    elseif options.maskedAreaSw && options.selected_sw == 0  % when only masked area selected
        imgTemp = bitand(bitand(obj.model, 128)/128, bitand(obj.model, 64)/64);     % intersection of selection and mask
    elseif options.selected_sw && obj.modelExist && options.maskedAreaSw==1
        imgTemp = bitand(uint8(bitand(obj.model, 63)==options.contSelIndex), bitand(obj.model, 128)/128);  % intersection of material and selection
        imgTemp = bitand(imgTemp, bitand(obj.model, 64)/64);    % additional intersection with mask
    end
else            % uint8 type of the model
    if options.selected_sw && obj.modelExist && options.maskedAreaSw==0
        obj.selection(obj.model ~= options.contSelIndex) = 0;   % decrease selection
    elseif options.maskedAreaSw && options.selected_sw == 0  % when only masked area selected
        obj.selection = bitand(obj.selection, obj.maskImg);   % decrease selection
    elseif options.selected_sw && obj.modelExist && options.maskedAreaSw==1
        obj.selection = bitand(obj.selection, obj.maskImg);   % decrease selection
        obj.selection(obj.model ~= options.contSelIndex) = 0;   % decrease selection
    end
end

switch action_type
    case 'add'  % add selection to mask
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                M = bitand(obj.model, 64);  % store existing mask
                obj.model(bitand(obj.model, 128) > 0) = options.contAddIndex;   % populating material
                obj.model = bitor(obj.model, M);    % populating the mask
                obj.model = bitset(obj.model, 8, 0); % clear selection
            else     % add layers for the selected or masked areas only
                M = bitand(obj.model, 64);  % store existing mask
                obj.model = bitset(obj.model, 8, 0); % clear selection
                obj.model(imgTemp==1) = options.contAddIndex;   % populating material
                obj.model = bitor(obj.model, M);    % populating the mask
            end
        else    % uint8 type of the model
            obj.model(obj.selection==1) = options.contAddIndex;
            obj.selection = zeros(size(obj.selection), class(obj.selection));     % clear selection
        end
    case 'remove'   % subtract selection from mask
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                M = bitand(obj.model, 64);  % store existing mask
                obj.model(bitand(obj.model, 128) > 0) = 0;   % removing material
                obj.model = bitor(obj.model, M);    % populating the mask
                obj.model = bitset(obj.model, 8, 0); % clear selection
            else     % add layers for the selected or masked areas only
                M = bitand(obj.model, 64);  % store existing mask
                obj.model = bitset(obj.model, 8, 0); % clear selection
                obj.model(imgTemp==1) = 0;   % populating material
                obj.model = bitor(obj.model, M);    % populating the mask
            end
        else    % uint8 type of the model
            obj.model(obj.selection==1) = 0;
            obj.selection = zeros(size(obj.selection), class(obj.selection));     % clear selection
        end
    case 'replace'  % replace selection with mask
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                M = bitand(obj.model, 64);  % store existing mask
                imgTemp = bitset(obj.model, 7, 0);  % clear mask
                imgTemp = bitset(imgTemp, 8, 0);    % clear selection
                imgTemp(imgTemp==options.contAddIndex) = 0;     % clear destination material
                imgTemp(bitand(obj.model, 128) == 128) = options.contAddIndex;  % populate destination material
                obj.model = bitor(imgTemp, M);  % populate mask
            else     % add layers for the selected or masked areas only
                M = bitand(obj.model, 64);  % store existing mask
                obj.model = bitand(obj.model, 63); % clear selection and mask
                obj.model(obj.model==options.contAddIndex) = 0;     % clear destination material
                obj.model(imgTemp==1) = options.contAddIndex;  % populate destination material
                obj.model = bitor(obj.model, M);    % populating the mask
            end
        else
            obj.model(obj.model==options.contAddIndex) = 0;     % clear destination material
            obj.model(obj.selection==1) = options.contAddIndex;     % populate destination material
            obj.selection = zeros(size(obj.selection), class(obj.selection));     % clear selection
        end
end
end