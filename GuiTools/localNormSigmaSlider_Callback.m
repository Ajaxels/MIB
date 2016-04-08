function localNormSigmaSlider_Callback(hObject, eventdata, handles)
% function localNormSigmaSlider_Callback(hObject, eventdata, handles)
% a callback to the handles.localNormSigmaSlider
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% local normalization demo test runs
% local normalization, based code by on Guanglei Xiong (xgl99@mails.tsinghua.edu.cn)
% http://www.mathworks.com/matlabcentral/fileexchange/8303-local-normalization

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if strcmp(get(hObject,'tag'),'localNormSigma1Slider')
    set(handles.localNormSigma1Edit,'String',num2str(get(hObject,'Value')));
elseif strcmp(get(hObject,'tag'),'localNormSigma2Slider')
    set(handles.localNormSigma2Edit,'String',num2str(get(hObject,'Value')));
elseif strcmp(get(hObject,'tag'),'localNormSigma1Edit') || strcmp(get(hObject,'tag'),'localNormSigma2Edit')
    editbox_Callback(hObject, 0, handles, 'pint','4',[1 NaN]);
end

if get(handles.backgroundRemoveTestCheck,'Value')==0; return; end;
color_id = get(handles.ColChannelCombo,'Value') - 1; % index of a color channel for normalization
sigma1 = round(str2double(get(handles.localNormSigma1Edit,'String')));
sigma2 = round(str2double(get(handles.localNormSigma2Edit,'String')));
epsilon=1e-1;
halfsize1=ceil(-norminv(epsilon/2,0,sigma1));
size1=2*halfsize1+1;
halfsize2=ceil(-norminv(epsilon/2,0,sigma2));
size2=2*halfsize2+1;

gaussian1=fspecial('gaussian',size1,sigma1);
gaussian2=fspecial('gaussian',size2,sigma2);
imageIn = handles.Img{handles.Id}.I.getSlice('image');
currentImage = imageIn(:,:,color_id);
maxIntVal = double(intmax(class(currentImage)));
currentImage = double(currentImage);
num = currentImage-imfilter(currentImage,gaussian1);
den=sqrt(imfilter(num.^2,gaussian2));
currentImage=num./den;
minVal = min(min(currentImage));
maxVal = max(max(currentImage));
currentImage = (currentImage - minVal)/(maxVal-minVal)*maxIntVal;
imageIn(:,:,color_id) = currentImage;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0, imageIn);
end