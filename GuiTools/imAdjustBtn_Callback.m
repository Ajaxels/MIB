function imAdjustBtn_Callback(~, ~, handles)
% function imAdjustBtn_Callback(~, ~, handles)
% Open image adjustments dialog
%
% Parameters:
% handles: structure with handles of im_browser.m

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if strcmp(handles.Img{handles.Id}.I.img_info('ColorType'),'indexed')
    msgbox(sprintf('Please convert to grayscale or truecolor data format first!\nMenu->Image->Mode->'),'Change format!','error','modal');
    return;
end
imAdjustments(handles);
guidata(handles.im_browser, handles);
end