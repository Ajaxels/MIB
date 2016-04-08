function deleteColorChannel(obj, channel1)
% function deleteColorChannel(obj, channel1)
% Delete specified color channel from the dataset.
%
% Parameters:
% channel1: [@em optional] the index of color channel to delete.
%
% Return values:

%| 
% @b Examples:
% @code imageData.deleteColorChannel(3);     // delete color channel 3 from the obj.img @endcode
% @code deleteColorChannel(obj, 1); // Call within the class; delete color channel 1 from the obj.img @endcode

% Copyright (C) 05.11.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 10.11.2015, IB, added shift of LUT information when color channel is deleted
% 18.09.2016, changed .slices to cells

if obj.colors < 2; errordlg(sprintf('Error!\nThere is only one color available!\nCancelling...'),'Not enough colors','modal'); return; end

if nargin < 2
    channel1 = 2;
end

prompt = {sprintf('Delete color channel\n\nEnter number of the color channel to be deleted:')};
%answer = inputdlg(prompt,'Delete color channel',1,{num2str(channel1)});
answer = mib_inputdlg(NaN, prompt,'Delete color channel',{num2str(channel1)});
if size(answer) == 0; return; end;
channel1 = str2double(answer{1});
if channel1 < 1 || channel1 > obj.colors 
    errordlg(sprintf('!!! Error !!!\n\nWrong channel number!\nThe channel numbers should be between 1 and %d', obj.colors),'Error');
    return;
end

wb = waitbar(0,sprintf('Deleting color channel %d from the dataset\n\nPlease wait...',channel1),'Name','Delete color channels','WindowStyle','modal');
colorList = 1:obj.colors;
obj.img = obj.img(:,:,colorList(colorList~=channel1),:,:);
waitbar(0.66, wb);
obj.colors = obj.colors - 1;
obj.viewPort.min = obj.viewPort.min(colorList(colorList~=channel1));
obj.viewPort.max = obj.viewPort.max(colorList(colorList~=channel1));
obj.viewPort.gamma = obj.viewPort.gamma(colorList(colorList~=channel1));
obj.slices{3} = obj.slices{3}(obj.slices{3}~=channel1);
obj.slices{3}(obj.slices{3} > channel1) = obj.slices{3}(obj.slices{3} > channel1) - 1;

% remove information about the lut
obj.lutColors(channel1,:) = [];
if isKey(obj.img_info, 'lutColors')
    lutColorsLocal = obj.img_info('lutColors');
    lutColorsLocal(channel1,:) = [];
    obj.img_info('lutColors') = lutColorsLocal;
end

waitbar(.99, wb);

if obj.colors == 1
    obj.img_info('ColorType') = 'grayscale';
end

% generate the log text
log_text = sprintf('Delete color channel %d', channel1);
updateImgInfo(obj, log_text);

waitbar(1, wb);
delete(wb);
end