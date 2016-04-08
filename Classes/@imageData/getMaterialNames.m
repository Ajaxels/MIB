function modelMaterialNames = getMaterialNames(obj)
% function modelMaterialNames = getMaterialNames(obj)
% Get names of materials of the model
%
% Parameters:
% 
% Return values:
% modelMaterialNames: a cell array with names of materials

%| 
% @b Example:
% @code modelMaterialNames = imageData.getMaterialNames();     // get list of materials  @endcode
% @code modelMaterialNames = getMaterialNames(obj); // Call within the class; get list of materials @endcode

% Copyright (C) 14.11.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

modelMaterialNames = obj.modelMaterialNames;