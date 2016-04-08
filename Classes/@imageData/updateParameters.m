function result = updateParameters(obj, pixSize)
% function updateParameters(obj, pixSize)
% Update imageData.pixelSize, imageData.img_info(''XResolution'') and imageData.img_info(''XResolution'')
%
% The function starts a dialog to update voxel size and the units of the dataset. As result the voxel dimensions will be updated;
% in addition imageData.img_info(''XResolution'') and imageData.img_info(''YResolution'') keys will be recalculated.
%
% Parameters:
% pixSize: - [@e optional], a structure with new parameters, may have the following fields
% - @b .x - physical voxel size in X, a number
% - @b .y - physical voxel size in Y, a number
% - @b .z - physical voxel size in Z, a number 
% - @b .t - time difference between the frames, a number 
% - @b .units - physical units for voxels, (m, cm, mm, um, nm)
% - @b .tunits - time unit 

% Return values:
% result: @b 1 - success, @b 0 - cancel

%| 
% @b Examples:
% @code
% pixSize.x = 10;
% pixSize.y = 10;
% pixSize.z = 50;
% pixSize.units = 'nm';
% imageData.updateParameters(pixSize);  // update parameters using voxels: 10x10x50nm in size @endcode
% @endcode
% @code imageData.updateParameters();  // update parameters of the dataset @endcode
% @code updateParameters(obj);   // Call within the class; update parameters of the dataset @endcode

% Copyright (C) 05.06.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

result = 0;

if nargin < 2
    prompt = {'Voxel size, X:','Voxel size, Y:','Voxel size, Z:','Time between frames:','Pixel units (m, cm, mm, um, nm):','Time units:'};
    title = 'Dataset parameters';
    lines = [1 30];
    def = {sprintf('%g',obj.pixSize.x),sprintf('%g',obj.pixSize.y),sprintf('%g',obj.pixSize.z),...
        sprintf('%g',obj.pixSize.t),obj.pixSize.units,obj.pixSize.tunits};
    dlgOptions.Resize = 'on';
    dlgOptions.WindowStyle = 'normal';
    answer = inputdlg(prompt,title,lines,def,dlgOptions);
    if size(answer) == 0; return; end;

    obj.pixSize.x = str2double(answer{1});
    obj.pixSize.y = str2double(answer{2});
    obj.pixSize.z = str2double(answer{3});
    obj.pixSize.t = str2double(answer{4});
    obj.pixSize.units = answer{5};
    obj.pixSize.tunits = answer{6};
else
    if isfield(pixSize, 'x'); obj.pixSize.x = pixSize.x; end;
    if isfield(pixSize, 'y'); obj.pixSize.y = pixSize.y; end;
    if isfield(pixSize, 'z'); obj.pixSize.z = pixSize.z; end;
    if isfield(pixSize, 't'); obj.pixSize.t = pixSize.t; end;
    if isfield(pixSize, 'units'); obj.pixSize.units = pixSize.units; end;
    if isfield(pixSize, 'tunits'); obj.pixSize.tunits = pixSize.tunits; end;
end
    

%resolution = obj.calculateResolution();
resolution = ib_calculateResolution(obj.pixSize);
obj.img_info('XResolution') = resolution(1);
obj.img_info('YResolution') = resolution(2);
obj.img_info('ResolutionUnit') = 'Inch';
obj.updateBoundingBox();
result = 1;
end
