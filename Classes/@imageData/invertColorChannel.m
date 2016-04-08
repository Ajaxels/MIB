function invertColorChannel(obj, channel1)
% function swapColorChannels(obj, channel1)
% Invert color channel of the dataset.
%
% The specified @em channel1 will be inverted
%
% Parameters:
% channel1: [@em optional] index of the color channel to invert
%
% Return values:

%| 
% @b Examples:
% @code handles = imageData.invertColorChannels(1);     // invert color channel 1 @endcode
% @code handles = invertColorChannels(obj, 1); // Call within the class; invert color channel 1 @endcode

% Copyright (C) 05.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, IB, changed .slices to cells
% 04.02.2016, IB, updated for 4D datasets

if nargin < 2
    prompt = {sprintf('Which color channel to invert:')};
    answer = mib_inputdlg(NaN,prompt,'Invert color channel',{num2str(obj.slices{3}(1))});
    if size(answer) == 0; return; end;
    channel1 = str2double(answer{1});
end

wb = waitbar(0,sprintf('Inverting color channel: %d\n\nPlease wait...',channel1),'Name','Invert color channel','WindowStyle','modal');

maxval = intmax(class(obj.img));
waitbar(0.1, wb);
obj.img(:,:,channel1,:,:) = maxval - obj.img(:,:,channel1,:,:);
waitbar(0.95, wb);

% generate the log text
log_text = sprintf('Invert color channel %d', channel1);
updateImgInfo(obj, log_text);

waitbar(1, wb);
delete(wb);
end