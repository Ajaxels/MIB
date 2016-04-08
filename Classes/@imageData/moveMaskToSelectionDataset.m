function moveMaskToSelectionDataset(obj, action_type, options)
% function moveMaskToSelectionDataset(obj, action_type, options)
% Move the Mask layer to the Selection layer.
%
% This is one of the specific functions to move datasets between the layers.
% Allows faster move of complete datasets between the layers than using of
% ib_getDataset.m / ib_setDataset.m functions.
%
% Parameters:
% action_type: a type of the desired action
% - ''add'' - add mask to selection
% - ''remove'' - remove mask from selection
% - ''replace'' - replace selection with mask
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
% @code imageData.moveMaskToSelectionDataset('add', options);     // add mask to selection  @endcode
% @code moveMaskToSelectionDataset(obj, 'add', options);     // call from the imageData class, add mask to selection  @endcode
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
% 20.01.2016, IB, updated to use getData4D

% % filter the obj_type_from depending on elected_sw and/or maskedAreaSw states
imgTemp = NaN; % a temporal variable to keep modified version of dataset when selected_sw and/or maskedAreaSw are on
if strcmp(obj.model_type, 'uint6')      % uint6 type of the model
    if options.selected_sw && obj.modelExist 
        id = bitset(options.contSelIndex, 7, 1);    % generate id with the 7bit = 1 (mask)
        imgTemp = bitset(obj.model, 8, 0);  % generate temp variable as model, but without the selection; faster than: imgTemp = bitand(obj.model, 127);
        imgTemp(imgTemp == id) = 128;   % set selection to the intersection of material and mask
    end
else            % uint8 type of the model
    if options.selected_sw && obj.modelExist 
        imgTemp = obj.getData4D('model', 4, options.contSelIndex);  % get selected material
        imgTemp = bitand(obj.maskImg, imgTemp);   % generate intersection between the material and mask
    end
end

switch action_type
    case 'add'  % add mask to selection
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                obj.model = bitor(obj.model, bitand(obj.model, 64)*2);     % copy selection to mask
            else     % add layers for the selected or masked areas only
                %obj.model = bitor(obj.model, imgTemp*128);
                obj.model = bitor(obj.model, imgTemp);
            end
        else    % uint8 type of the model
            if isnan(imgTemp(1))    % add layers for the whole dataset
                obj.selection = bitor(obj.selection, obj.maskImg);    % copy selection to mask
            else     % add layers for the selected or masked areas only
                obj.selection = bitor(obj.selection, imgTemp);  % copy selection to mask
            end
        end
    case 'remove'   % subtract selection from mask
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                imgTemp = bitget(obj.model, 8);     % get selection
                imgTemp = imgTemp - bitget(obj.model, 7); % selection - mask
                obj.model = bitand(obj.model, 127); % clear selection 
                obj.model = bitor(obj.model, imgTemp*128); % set selection
            else     % add layers for the selected or masked areas only
                imgTemp = bitand(obj.model, 128) - imgTemp;
                obj.model = bitand(obj.model, 127); % clear selection 
                obj.model = bitor(obj.model, imgTemp*128);  % set selection
            end
        else
            if isnan(imgTemp(1))    % add layers for the whole dataset
                obj.selection = obj.selection - obj.maskImg;
            else     % add layers for the selected or masked areas only
                obj.selection  = obj.selection - imgTemp;
            end
        end
    case 'replace'  % replace selection with mask
        if strcmp(obj.model_type, 'uint6')
            if isnan(imgTemp(1))    % add layers for the whole dataset
                imgTemp = bitget(obj.model, 7);     % get mask
                obj.model = bitand(obj.model, 127); % clear selection 
                obj.model = bitor(obj.model, imgTemp*128);  % set selection
            else     % add layers for the selected or masked areas only
                obj.model = bitand(obj.model, 127); % clear selection 
                obj.model = bitor(obj.model, imgTemp);  % set selection
            end
        else
            if isnan(imgTemp(1))    % add layers for the whole dataset
                obj.selection = obj.maskImg;
            else     % add layers for the selected or masked areas only
                obj.selection = imgTemp;
            end
        end
end
end