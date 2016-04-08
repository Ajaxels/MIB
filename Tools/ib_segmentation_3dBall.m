function handles = ib_segmentation_3dBall(y, x, z, modifier, handles)
% function handles = ib_segmentation_3dBall(y, x, z, modifier, handles)
% Do segmentation using the 3D ball tool
%
% Parameters:
% y: y-coordinate of the 3D ball center
% x: x-coordinate of the 3D ball center
% z: z-coordinate of the 3D ball center
% modifier: a string, to specify what to do with the generated selection
% - @em empty - makes new selection
% - @em ''control'' - removes selection from the existing one
% handles: a handles structure of im_browser
%
% Return values:
% handles: a handles structure of im_browser

%| @b Examples:
% @code handles = ib_segmentation_3dBall(50, 75, 10, '', handles);  // add a ball to position [y,x,z]=50,75,10 @endcode

% Copyright (C) 14.05.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.09.2015, IB, updated to use imageData.getData3D methods
% 29.03.2016, IB, optimized backup

radius = str2double(get(handles.segmSpotSizeEdit ,'String'))-1;
minVox = min([handles.Img{handles.Id}.I.pixSize.x handles.Img{handles.Id}.I.pixSize.y handles.Img{handles.Id}.I.pixSize.z]);
ratioX = handles.Img{handles.Id}.I.pixSize.x/minVox;
ratioY = handles.Img{handles.Id}.I.pixSize.y/minVox;
ratioZ = handles.Img{handles.Id}.I.pixSize.z/minVox;
radius = [radius/ratioX radius/ratioX;radius/ratioY radius/ratioY;radius/ratioZ radius/ratioZ];
radius = round(radius);
rad_vec = radius; % vector of radii [-dy +dy;-dx +dx; -dz +dz] for detection out of image border cases
y_max = handles.Img{handles.Id}.I.height; %size(handles.Img{handles.Id}.I.Ishown,1);
x_max = handles.Img{handles.Id}.I.width; %size(handles.Img{handles.Id}.I.Ishown,2);
z_max = handles.Img{handles.Id}.I.no_stacks; %size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation);     % max value for the Z
if y-radius(1,1)<=0; rad_vec(1,1) = y-1; end;
if y+radius(1,2)>y_max; rad_vec(1,2) = y_max-y; end;
if x-radius(2,1)<=0; rad_vec(2,1) = x-1; end;
if x+radius(2,2)>x_max; rad_vec(2,2) = x_max-x; end;
if z-radius(3,1)<=0; rad_vec(3,1) = z-1; end;
if z+radius(3,2)>z_max; rad_vec(3,2) = z_max-z; end;
max_rad = max(max(radius));
selarea = zeros(max_rad*2+1,max_rad*2+1,max_rad*2+1);    % do strel ball type in volume
[x1,y1,z1] = meshgrid(-max_rad:max_rad,-max_rad:max_rad,-max_rad:max_rad);
ball = sqrt((x1/radius(1,1)).^2+(y1/radius(2,1)).^2+(z1/radius(3,1)).^2);
selarea(ball<=1) = 1;
selarea = selarea(max_rad-rad_vec(1,1)+1:max_rad+rad_vec(1,2)+1,max_rad-rad_vec(2,1)+1:max_rad+rad_vec(2,2)+1,max_rad-rad_vec(3,1)+1:max_rad+rad_vec(3,2)+1);
options.y = [y-rad_vec(1,1) y+rad_vec(1,2)];
options.x = [x-rad_vec(2,1) x+rad_vec(2,2)];
options.z = [z-rad_vec(3,1) z+rad_vec(3,2)];

% do backup
ib_do_backup(handles, 'selection', 1, options);

% limit selection to material of the model
if get(handles.segmSelectedOnlyCheck,'Value')
    selcontour = get(handles.segmSelList,'Value') - 2;  % get selected contour
    model = handles.Img{handles.Id}.I.getData3D('model', NaN, 4, selcontour, options);
    selarea = selarea & model;
end

% limit selection to the masked area
if get(handles.maskedAreaCheck, 'value') && handles.Img{handles.Id}.I.maskExist   % do selection only in the masked areas
    model = handles.Img{handles.Id}.I.getData3D('mask', NaN, 4, NaN, options);
    selarea = selarea & model;
end

if isempty(modifier) || strcmp(modifier, 'shift')  % combines selections
    selarea = handles.Img{handles.Id}.I.getData3D('selection', NaN, 4, NaN, options) | selarea;
    handles.Img{handles.Id}.I.setData3D('selection', selarea, NaN, 4, NaN, options);
elseif strcmp(modifier, 'control')  % subtracts selections
    sel = handles.Img{handles.Id}.I.getData3D('selection', NaN, 4, NaN, options);
    sel(selarea==1) = 0;
    handles.Img{handles.Id}.I.setData3D('selection', sel, NaN, 4, NaN, options);
end
