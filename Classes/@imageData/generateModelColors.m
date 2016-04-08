function generateModelColors(obj)
% function generateModelColors(obj)
% Generate list of colors for materials of a model. 
%
% When a new material is added to a model, this function generates a random color for it.
%
% Parameters:
% 

%| 
% @b Examples:
% @code imageData.generateModelColors();  // generate colors @endcode
% @code generateModelColors(obj);   // Call within the class; generate colors @endcode

% Copyright (C) 30.04.2014, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 13.03.2014, moved to the ImageData class

if size(obj.modelMaterialColors,1) < numel(obj.modelMaterialNames)
    for i=size(obj.modelMaterialColors,1)+1:numel(obj.modelMaterialNames)
        obj.modelMaterialColors(i,:) = [rand(1) rand(1) rand(1)];
    end
end
end