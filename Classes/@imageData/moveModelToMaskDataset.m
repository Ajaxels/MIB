function moveModelToMaskDataset(obj, action_type, options)
% function moveModelToMaskDataset(obj, action_type, options)
% Move the selected Material to the Mask layer
%
% This is one of the specific functions to move datasets between the layers.
% Allows faster move of complete datasets between the layers than using of
% ib_getDataset.m / ib_setDataset.m functions.
%
% Parameters:
% action_type: a type of the desired action
% - ''add'' - add the selected material (@em Select @em from) to mask
% - ''remove'' - remove the selected material (@em Select @em from) from mask
% - ''replace'' - replace mask with the selected (@em Select @em from) material
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
% userData = get(handles.segmTable,'userdata');     // get user data structure
% options.contSelIndex = userData.prevMaterial-2; // index of the selected material
% options.contAddIndex = userData.prevAddTo-2; // index of the target material
% options.selected_sw = get(handles.segmSelectedOnlyCheck,'value');   // when 1- limit selection to the selected material
% options.maskedAreaSw = get(handles.maskedAreaCheck,'Value');
% @endcode
% @code imageData.moveModelToMaskDataset('add', options);     // add material to mask @endcode
% @code moveModelToMaskDataset(obj, 'add', options);     // call from the imageData class, add material to mask @endcode
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

switch action_type
    case 'add'  % add material to selection
        if strcmp(obj.model_type, 'uint6')
            imgTemp = uint8(bitand(obj.model, 63)==options.contSelIndex)*64;   % get material and set it as mask
            obj.model = bitor(obj.model, imgTemp);
        else    % uint8 type of the model
            obj.maskImg(obj.model == options.contSelIndex) = 1;
        end
    case 'remove'   % subtract material from selection
        if strcmp(obj.model_type, 'uint6')
            imgTemp = uint8(bitand(obj.model, 63)==options.contSelIndex)*64;   % get material and set it as selection
            obj.model = obj.model - bitand(obj.model, imgTemp);
        else    % uint8 type of the model
            obj.maskImg = obj.maskImg - uint8(obj.model==options.contSelIndex);
        end
    case 'replace'  % replace selection with material
        if strcmp(obj.model_type, 'uint6')
            obj.model = bitset(obj.model, 7, 0);    % clear mask
            imgTemp = uint8(bitand(obj.model, 63)==options.contSelIndex)*64;   % get material and set it as selection
            obj.model = bitor(obj.model, imgTemp);
        else
            obj.maskImg = zeros(size(obj.selection), class(obj.selection));     % clear selection
            obj.maskImg = uint8(obj.model==options.contSelIndex);
        end
end
end