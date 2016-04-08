function handles = ib_removeBackground(handles)
% function handles = ib_removeBackground(handles)
% Remove background of the image
%
% Parameters:
% handles: structure with handles of im_browser.m
%
% Return values:
% handles: structure with handles of im_browser.m

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if get(handles.roiShowCheck,'value') == 1 && get(handles.roiList,'value') == 1
    msgbox('Please select a roi in the roi list!','Error!','error', 'modal');
    return;
end

start_no = 1;
end_no = handles.Img{handles.Id}.I.no_stacks;
strelsize = str2double(get(handles.backgroundStrelSizeEdit,'String'));  % strel size
maximal_min = str2double(get(handles.bgMaxMinimaEdit,'String'));  % maximal minima
gSize = str2double(get(handles.backgroundGaussSize,'String'));
gSigma = str2double(get(handles.backgroundGaussSigmaEdit,'String'));
improf = get(handles.backgroundProfileChk,'Value');
improf_line = str2double(get(handles.backgroundProfileLineEdit,'String'));

test_sw = get(handles.backgroundRemoveTestCheck,'Value');
morph_sw = get(handles.backgroundMorphOpenSw,'Value');
minima_sw = get(handles.backgroundMinimaSw,'Value');
smooth_sw = get(handles.backgroundStrelSmoothingChk,'Value');
localNorm_sw = get(handles.backgroundLocNormSw,'Value');
str_el = strel('disk',strelsize);

gaussian1=0;
gaussian2=0;

% define background subtraction mode: 'gauss', 'morph', 'minima'
bgmode = 'gauss';   % background removal mode
if morph_sw == 1;
    bgmode='morph';
    log_text = ['Background removal based on morph-opening; StrelType: Disk; Size:' num2str(strelsize)];
    if smooth_sw
        log_text = [log_text '; Gaussian Smoothing: Size:' num2str(gSize) ', Sigma:' num2str(gSigma)];
    end
end;
[X,Y] = meshgrid(1:size(handles.Img{handles.Id}.I.img,2),1:size(handles.Img{handles.Id}.I.img,1));
if minima_sw == 1;
    bgmode='minima';
    bg_img = zeros(size(handles.Img{handles.Id}.I.img),class(handles.Img{handles.Id}.I.img));
    log_text = ['Background removal based on local minima; Max. minima:' num2str(maximal_min)];
    if smooth_sw
        log_text = [log_text '; Gaussian Smoothing: Size:' num2str(gSize) ', Sigma:' num2str(gSigma)];
    end
end;
if localNorm_sw == 1
    bgmode='localNorm';
    sigma1 = str2double(get(handles.localNormSigma1Edit,'String'));
    sigma2 = str2double(get(handles.localNormSigma2Edit,'String'));
    log_text = ['Background local normalization; Sigma1:' num2str(sigma1) ',Sigma2:' num2str(sigma2)];
    epsilon=1e-1;
    halfsize1=ceil(-norminv(epsilon/2,0,sigma1));
    size1=2*halfsize1+1;
    halfsize2=ceil(-norminv(epsilon/2,0,sigma2));
    size2=2*halfsize2+1;
    gaussian1=fspecial('gaussian',size1,sigma1);
    gaussian2=fspecial('gaussian',size2,sigma2);
end
if minima_sw == 0 && morph_sw == 0 && localNorm_sw == 0
    log_text = ['Background removal based on gaussian smoothing; Size:' num2str(gSize) ', Sigma:' num2str(gSigma)];
end

switch3d = 1;
if get(handles.backgroundAllCheck,'Value') == 0 || test_sw
    start_no = handles.Img{handles.Id}.I.getCurrentSliceNumber();
    end_no = start_no;
    switch3d = 0;
end

filt = fspecial('gaussian',gSize,gSigma);   % gaussian filter initialization
filt2 = fspecial('disk', strelsize);   % disk smoothing filter for the local minima mode
wb = waitbar(0,'Removing background...','Name','Background','WindowStyle','modal');

% do backup
ib_do_backup(handles, 'image', switch3d);

tic

handles.Img{handles.Id}.I.clearSelection(NaN, NaN, start_no:end_no);
class_str = class(handles.Img{handles.Id}.I.img);   % for conversion to proper image class
maxIntVal = double(intmax(class_str));  % maximal value of the image class
% test and profile comparison run
% calculate backgrounds
if test_sw | improf %#ok<OR2>  % improf-> intensity profile
    %origImg = handles.Img{handles.Id}.I.getCurrentSlice('image');
    origImg = ib_getSlice('image', handles);
    origImg = origImg{1};
    if strcmp(bgmode,'morph')
        bgImgTest = imopen(origImg, str_el);
        if smooth_sw   % gaussian smoothing of the filter
            bgImgTest_f = imfilter(bgImgTest,filt,'replicate');
        else
            bgImgTest_f = bgImgTest;
        end
    elseif strcmp(bgmode,'minima')
        currentImage = imfilter(origImg,filt2,'replicate'); % do 1st filtering to reduce number of local minima
        currentImage = double(currentImage);
        selection = ib_getSlice('selection', handles);
        selection = selection{1};
        [~,~,zmin,imin] = extrema2(currentImage);   % get local minima
        imin = imin(zmin<=maximal_min);     % remove local minima above specified threshold
        zmin = zmin(zmin<=maximal_min);
        if isempty(imin) || isempty(zmin)
            warndlg('The detected minima are higher than the Max minima value!','Cancelling...','modal');
            delete(wb);
            return;
        end
        xy_vec = [X(imin(:)) Y(imin(:))];
        selection(:,:,start_no) = mark2selection(selection,'cross','', xy_vec);
        %F = TriScatteredInterp(Y(imin(:)),X(imin(:)),zmin(:),'nearest');    % reconstruct the background
        F = TriScatteredInterp(Y(imin(:)),X(imin(:)),zmin(:),'natural');    %
        bgImgTest = F(Y,X);
        
        % fill NaN areas with amplitudes of the closest local minima
        bgMask = zeros(size(bgImgTest));
        bgMask(isnan(bgImgTest)) = 1;
        CC = bwconncomp(bgMask);
        STATS = regionprops(CC, 'Centroid','PixelIdxList');
        for centroid = 1:numel(STATS)
            [min_val min_id] = min(sqrt((xy_vec(:,1)-STATS(centroid).Centroid(1)).^2+(xy_vec(:,2)-STATS(centroid).Centroid(2)).^2));    % find the closest minimum
            bgImgTest(STATS(centroid).PixelIdxList) = zmin(min_id);
        end
        
        str2 = ['bgImgTest = ' class_str '(bgImgTest);'];
        eval(str2);
        if smooth_sw    % do gaussian smoothing
            bgImgTest_f = imfilter(bgImgTest, fspecial('gaussian', gSize, gSigma),'replicate');
        else
            bgImgTest_f = bgImgTest;
        end
    elseif strcmp(bgmode,'localNorm')
        % local normalization, based code by on Guanglei Xiong (xgl99@mails.tsinghua.edu.cn)
        % http://www.mathworks.com/matlabcentral/fileexchange/8303-local-normalization
        origImg = double(origImg);
        num = origImg-imfilter(origImg,gaussian1);
        den=sqrt(imfilter(num.^2,gaussian2));
        bgImgTest_f=(num./den);
        minVal = min(min(bgImgTest_f));
        bgImgTest_f = origImg - (bgImgTest_f - minVal);
        bgImgTest = bgImgTest_f;
    else
        bgImgTest = imfilter(origImg,filt,'replicate');     % background
        bgImgTest_f = bgImgTest;
    end
    
end

if test_sw == 0
    
    img = ib_getDataset('image', handles);
    img = img{1};
    selection = ib_getDataset('selection', handles);
    selection = selection{1};
    parfor index=start_no:end_no
        currentImage = img(:,:,:,index);
        if strcmp(bgmode,'morph')   % background removal based on morphological opening
            bgImg = imopen(currentImage, str_el);
            if smooth_sw   % gaussian smoothing of the filter
                img(:,:,:,index) = currentImage - imfilter(bgImg,filt,'replicate');
            else
                img(:,:,:,index) = currentImage - bgImg;
            end
        elseif strcmp(bgmode,'minima') % background removal based on local minima
            currentImage = imfilter(currentImage,filt2,'replicate');    % do 1st filtering to reduce number of local minima
            currentImage = double(currentImage);
            
            [~,~,zmin_out,imin_out] = extrema2(currentImage);   % get local minima
            imin = imin_out(zmin_out<=maximal_min);     % remove local minima above specified threshold
            zmin = zmin_out(zmin_out<=maximal_min);
            xy_vec = [X(imin(:)) Y(imin(:))];   %#ok<PFBNS>
            selection(:,:,index) = mark2selection(selection(:,:,index),'cross','', xy_vec);
            F = TriScatteredInterp(Y(imin(:)),X(imin(:)),zmin(:),'nearest');    % reconstruct the background
            bgImg = F(Y,X);
            if isempty(bgImg);
                bgImg = zeros(size(currentImage), class(currentImage));
            end
            
            % fill NaN areas with amplitudes of the closest local minima
            bgMask = zeros(size(bgImg));
            bgMask(isnan(bgImg)) = 1;
            CC = bwconncomp(bgMask);
            STATS = regionprops(CC, 'Centroid','PixelIdxList');
            for centroid = 1:numel(STATS)
                [min_val min_id] = min(sqrt((xy_vec(:,1)-STATS(centroid).Centroid(1)).^2+(xy_vec(:,2)-STATS(centroid).Centroid(2)).^2));    % find the closest minimum
                bgImg(STATS(centroid).PixelIdxList) = zmin(min_id);
            end
            if smooth_sw    % do gaussian smoothing
                bg_img(:,:,:,index) = imfilter(bgImg, fspecial('gaussian', gSize, gSigma),'replicate');
            else
                bg_img(:,:,:,index) = bgImg;
            end
            % another possibility for bg reconstruction
            %bg_img(:,:,:,index) = uint8(griddata(Y(imin(:)),X(imin(:)),zmin(:),Y,X, 'V4'));
        elseif strcmp(bgmode,'localNorm')
            % local normalization, based code by on Guanglei Xiong (xgl99@mails.tsinghua.edu.cn)
            % http://www.mathworks.com/matlabcentral/fileexchange/8303-local-normalization
            currentImage = double(currentImage);
            num = currentImage-imfilter(currentImage,gaussian1);
            den=sqrt(imfilter(num.^2,gaussian2));
            currentImage=num./den;
            minVal = min(min(currentImage));
            maxVal = max(max(currentImage));
            currentImage = (currentImage - minVal)/(maxVal-minVal)*maxIntVal;
            img(:,:,:,index) = currentImage;
        else        % background removal based on gauss smoothing
            img(:,:,:,index) = currentImage - imfilter(currentImage,filt,'replicate');     % background
        end
        %waitbar((index-start_no)/(end_no-start_no),wb);
    end
    
    % average background for local minima case and substract it from the image
    if strcmp(bgmode,'minima')
        bgImgTest = mean(bg_img(:,:,:,start_no:end_no),4);
        class_str = class(handles.Img{handles.Id}.I.img);   % convert to the proper image class
        str2 = ['bgImgTest = ' class_str '(bgImgTest);'];
        eval(str2);
        bgImgTest_f = bgImgTest;
        for i=start_no:end_no
            img(:,:,:,i) = img(:,:,:,i) - bgImgTest;
            %handles.Img{handles.Id}.I.img(:,:,:,i) = handles.Img{handles.Id}.I.img(:,:,:,i) - bg_img(:,:,:,i);
        end
    end
    ib_setDataset('image', img, handles);
    ib_setDataset('selection', selection, handles);
end

% plot profiles
if improf
    width = size(origImg,2);
    c1 = improfile(origImg,[1 width],[improf_line improf_line]);
    c2 = improfile(bgImgTest,[1 width],[improf_line improf_line]);
    c3 = improfile(bgImgTest_f,[1 width],[improf_line improf_line]);
    c4 = improfile(origImg-bgImgTest_f,[1 width],[improf_line improf_line]);
    if size(c1,3) == 3
        c1 = c1(:,1,1)*0.3+c1(:,1,2)*0.59+c1(:,1,3)*0.11;
        c2 = c2(:,1,1)*0.3+c2(:,1,2)*0.59+c2(:,1,3)*0.11;
        c3 = c3(:,1,1)*0.3+c3(:,1,2)*0.59+c3(:,1,3)*0.11;
        c4 = c4(:,1,1)*0.3+c4(:,1,2)*0.59+c4(:,1,3)*0.11;
    end
    
    figure(15321)
    imshow(bgImgTest_f,[]);
    title('Subtracted background');
    figure(15322)
    plot(1:width,c1,1:width,c2,1:width,c3(:,1),1:width,c4);
    set(gca,'xlim',[1 width]);
    legend('Original image','Background','Smoothed background','Final image');
    title(['Intensity profile for Y=' num2str(improf_line)]);
    grid;
end

% plot test image
if test_sw
    figure(52312)
    diff_img = double(origImg)-double(bgImgTest_f);
    diff_img(diff_img<0) = 0;
    imshow(diff_img,[]);
    title('Result');
    delete(wb);
    return;
end


toc
handles.Img{handles.Id}.I.updateImgInfo(log_text);
delete(wb);
end