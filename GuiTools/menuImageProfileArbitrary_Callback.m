function menuImageProfileArbitrary_Callback(hObject, eventdata, handles)
% function menuImageProfileArbitrary_Callback(hObject, eventdata, handles)
% a callback to the handles.menuImageProfileLine, generates a profile of image intensities under an arbitrary line
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}


if numel(handles.Img{handles.Id}.I.slices{3}) ~= 1    % get color channel from the selected in the Selection panel
    colorChannel = get(handles.ColChannelCombo,'Value') - 1;
else    % when only one color channel is shown, take it
    colorChannel = handles.Img{handles.Id}.I.slices{3};
end

set(handles.im_browser, 'windowbuttondownfcn', '');
roi = imfreehand(handles.imageAxes,'Closed',0);
pos = round(roi.getPosition());
delete(roi);
pos(:,1) = pos(:,1)*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesX(1))]);
pos(:,2) = pos(:,2)*handles.Img{handles.Id}.I.magFactor + max([0 floor(handles.Img{handles.Id}.I.axesY(1))]);
set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
img = handles.Img{handles.Id}.I.getFullSlice('image', handles.Img{handles.Id}.I.getCurrentSliceNumber, handles.Img{handles.Id}.I.orientation, colorChannel);

for i=1:size(img,3)
    c1(:,i) = improfile(img(:,:,i), pos(:,1),pos(:,2));
    legendStr(i) = cellstr(sprintf('Channel: %d', i));
end
if size(img,3) == 1;     legendStr = sprintf('Channel: %d', colorChannel);  end;

%c1 = improfile(img, pos(:,1), pos(:,2));
figure(15214);
clf
subplot(2,1,1);
%colorList = get(gca,'colororder');
for i=1:size(img,3) 
    improfile(img(:,:,i), pos(:,1), pos(:,2));
    hold on;
end
hold off;
title(sprintf('Image profile for color channel: %d', colorChannel));
set(gca,'DataAspectRatio',[1 1 max(max(c1))/size(img,1)*5]);
set(gca,'xlim',[1 size(img,2)]);
set(gca,'ylim',[1 size(img,1)]);
grid;
subplot(2,1,2);
plot(1:size(c1,1),c1);
legend(legendStr);
xlabel('Point in the drawn profile');
ylabel('Intensity');
grid;
end