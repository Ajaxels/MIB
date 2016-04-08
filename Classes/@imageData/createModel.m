function createModel(obj, model_type)
% function createModel(obj, model_type)
% Create an empty model: allocate memory for a new model.
%
% Reinitialize imageData.model variable (@em NaN when no model present) with an empty matrix
% [imageData.height, imageData.width, imageData.no_stacks] of the defined type class
%
% Parameters:
% model_type: type of the model,
% - @b 'uint6' - a segmentation model with up to 63 materials; the 'Model', 'Mask' and 'Selection' layers stored in the same matrix, to decrease memory consumption;
% - @b 'uint8' - a segmentation model with up to 255 materials; the 'Model', 'Mask' and 'Selection' layers stored in separate matrices;
% - @b 'int8' - a model layer that has intensities from -128 to 128.%
%
% Return values:

%| 
% @b Examples:
% @code imageData.createModel('uint6');  // allocate space for a new Model layer, type 'uint6' @endcode
% @code createModel(obj,'uint6');   // Call within the class; allocate space for a new Model layer, type 'uint6 @endcode

% Copyright (C) 30.10.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 05.02.2016, IB updated for 4D datasets


if nargin < 2; model_type = obj.model_type; end;
    
if strcmp(model_type, 'uint8')
    obj.model = zeros([obj.height, obj.width, obj.no_stacks,obj.time],'uint8');
elseif strcmp(model_type, 'uint6')
    obj.model = bitand(obj.model, 192);
end
obj.modelExist = 1;
obj.model_var = 'im_browser_model';
[pathstr, name] = fileparts(obj.img_info('Filename'));
obj.model_fn = fullfile(pathstr,['Labels_' name '.mat']);
obj.model_type = model_type;
obj.modelMaterialNames = {};
obj.hLabels.clearContents();    % clear labels
end