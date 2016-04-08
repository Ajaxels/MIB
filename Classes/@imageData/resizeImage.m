function resizeImage(obj, new_width, new_height, method)
% function resizeImage(obj, new_width, new_height, method)
% Resize all layers using specified @em method
%
% Parameters:
% new_width: new width of the dataset
% new_height: new height of the dataset
% method: a method to use during resizing: ''nearest'', ''bilinear'', ''bicubic''
% @note The 'Model', 'Mask', 'Selection' layers will be resized using the ''nearest'' method.
%
% Return values:

%| 
% @b Examples:
% @code imageData.resizeImage(512, 1024);     // resize image to 512 width and 1024 height @endcode
% @code resizeImage(obj, 512, 1024);// Call within the class; resize image to 512 width and 1024 height @endcode

% Copyright (C) 05.03.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}


ratio_w = size(obj.img,2)/new_width;
ratio_h = size(obj.img,1)/new_height;
newI = zeros(new_height,new_width,size(obj.img,3),obj.no_stacks,class(obj.img));
for i=1:obj.no_stacks     % resize image
    newI(:,:,:,i) = imresize(obj.img(:,:,:,i),[new_height new_width], method);
end
obj.img = newI;
clear newI;
if ~isnan(obj.model(1,1,1)) % resize model
    newI = zeros(new_height,new_width,obj.no_stacks,class(obj.model));
    for i=1:obj.no_stacks
        newI(:,:,i) = imresize(obj.model(:,:,i),[new_height new_width],'nearest');
    end
    obj.model = newI;
    clear newI;
end
if ~isnan(obj.maskImg(1))    % resize filterImage
    newI = zeros(new_height,new_width,obj.no_stacks,'uint8');
    for i=1:obj.no_stacks
        newI(:,:,i) = imresize(obj.maskImg(:,:,i),[new_height new_width]);
    end
    obj.maskImg = newI;
    clear newI;
end
% change pixel size
obj.pixSize.x = obj.pixSize.x*ratio_w;
obj.pixSize.y = obj.pixSize.y*ratio_h;
% update info structure
obj.img_info('Height') = new_height;
obj.img_info('Width') = new_width;
obj.clearSelection();
obj.imh = 0;
obj.slices{1} = [1 new_height];
obj.slices{2} = [1 new_width];
obj.height = new_height;
obj.width = new_width;

% remove slice name
if isKey(obj.img_info, 'SliceName')
    remove(obj.img_info, 'SliceName');
end

end