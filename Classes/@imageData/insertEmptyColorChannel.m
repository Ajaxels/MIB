function insertEmptyColorChannel(obj, channel1)
% function insertEmptyColorChannel(obj, channel1)
% Insert an empty color channel to the specified position.
%
% Parameters:
% channel1: [@em optional] the index of color channel to insert.
%
% Return values:

%| 
% @b Examples:
% @code imageData.insertEmptyColorChannel(1);     // insert empty color channel to position 1 @endcode
% @code insertEmptyColorChannel(obj, 1); // Call within the class; insert empty color channel to position 1 @endcode

% Copyright (C) 04.02.2016, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 
% 

if nargin < 2
    channel1 = obj.colors + 1;
end

prompt = {sprintf('Insert empty color channel\n\nEnter position (1-%d):',obj.colors + 1)};
answer = mib_inputdlg(NaN, prompt,'Insert empty color channel', {num2str(channel1)});
if size(answer) == 0; return; end;
channel1 = str2double(answer{1});
if channel1 < 1 || channel1 > obj.colors+1 
    errordlg(sprintf('!!! Error !!!\n\nWrong channel number!\nThe channel numbers should be between 1 and %d', obj.colors),'Error');
    return;
end

wb = waitbar(0,sprintf('Inserting empty color channel to position %d\n\nPlease wait...',channel1),'Name','Insert empty color channels','WindowStyle','modal');
if channel1 == 1
    obj.img(:,:,2:obj.colors+1,:,:) = obj.img;
    obj.img(:,:,1,:,:) = zeros([size(obj.img,1), size(obj.img,2), 1, size(obj.img,4), size(obj.img,5)], class(obj.img)); %#ok<ZEROLIKE>
elseif channel1 == obj.colors + 1
    obj.img(:,:,obj.colors+1,:,:) = zeros([size(obj.img,1), size(obj.img,2), 1, size(obj.img,4), size(obj.img,5)], class(obj.img)); %#ok<ZEROLIKE>
else
    obj.img(:,:,1:channel1-1,:,:) = obj.img(:,:,1:channel1-1,:,:);
    obj.img(:,:,channel1+1:obj.colors+1,:,:) = obj.img(:,:,channel1:obj.colors,:,:);
    obj.img(:,:,channel1,:,:) = zeros([size(obj.img,1), size(obj.img,2), 1, size(obj.img,4), size(obj.img,5)], class(obj.img)); %#ok<ZEROLIKE>
end
waitbar(0.66, wb);
obj.colors = obj.colors + 1;
obj.viewPort.min(obj.colors) = 0;
obj.viewPort.max(obj.colors) = double(intmax(class(obj.img)));
obj.viewPort.gamma(obj.colors) = 1;
obj.img_info('ColorType') = 'truecolor';

waitbar(.99, wb);

% generate the log text
log_text = sprintf('Insert empty color channel to position %d', channel1);
updateImgInfo(obj, log_text);

waitbar(1, wb);
delete(wb);
end