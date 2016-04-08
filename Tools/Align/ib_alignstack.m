function [img, shiftsXY] = ib_alignstack(S1, options, shiftsXY)
% alignment of images within the stack
% [img shiftsXY] = ib_alignstack(S1, options, shiftsXY)
% OUT:
% img -> aligned dataset
% shiftsXY -> vector with absolute shifts, shiftsXY(1,:) - for x and
% shiftsXY(2,:) - for y. The shifts are calculated vs the slice with the
% minimum shift, _i.e._ the shiftsXY are always positive
% IN:
% S1 -> stack in (format, height:width:color:thickness)
% options -> optional, defines a center and halfwidth of the searching
%            window
%        options.centerX -> center of the search window
%        options.centerY -> center of the search window
%        options.templateWidth -> half-width of the searching window
%        options.colorCh -> color channel to use in multicolor images
%        options.backgroundColor -> background color: 'black', 'white', 'mean', or a number
%        options.method -> method: 
%                   'cc' - the normalized cross correlation
%                   'sq' - the normalized sum of squared difference
%                   'xcMatlab' - beta of using matlab normxcorr2
%        options.gradientSw = 1 or 0, use gradient image or the original intensity image
%        options.step, step for comparison of images, default=1
% shiftsXY -> optional, a matrix of [2, size(S1,3)]. When provided the function generates aligned stack
%             using this provided coordinates of shifts

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% ver 1.1 04.07.2012, the template is now taken from the previous slice

if nargin < 3
    shiftsXY = NaN;
end
if nargin < 2
    options = struct();
end

if ~isfield(options, 'colorCh'); options.colorCh = 1; end
if ~isfield(options, 'backgroundColor'); options.backgroundColor = 'white'; end

colorCh = options.colorCh;

width1 = size(S1,2);
height1 = size(S1,1);
% detect type of the inpuit data
if ndims(S1) < 4       
    modelSwitch = 1;  % model type height:width:thickness
    color1 = 1;
    thick1 = size(S1,3);
else
    modelSwitch = 0; % image type height:width:color:thickness
    color1 = size(S1,3);
    thick1 = size(S1,4);
end

wb = waitbar(0,sprintf('Aligning images using color channel %d ...', colorCh),'Name','Aligning','WindowStyle','modal');

if isnan(shiftsXY)
    if isstruct(options)
        templateWidth = options.templateWidth;
        centerX = options.centerX;
        centerY = options.centerY;
    else
        templateWidth = round(min([width1/4 height1/4]))-1;
        centerX = floor(width1/2);
        centerY = floor(height1/2);
    end
    
    if options.gradientSw
        img = zeros(size(S1),class(S1));
        % generate gradient image
        hy = fspecial('sobel');
        hx = hy';
        for slice = 1:thick1
            if modelSwitch
                I = S1(:,:,slice);   % get a slice
                Iy = imfilter(double(I), hy, 'replicate');
                Ix = imfilter(double(I), hx, 'replicate');
                img(:,:,slice) = sqrt(Ix.^2 + Iy.^2);
            else
                I = S1(:,:,colorCh,slice);   % get a slice
                Iy = imfilter(double(I), hy, 'replicate');
                Ix = imfilter(double(I), hx, 'replicate');
                img(:,:,colorCh,slice) = sqrt(Ix.^2 + Iy.^2);
            end
            waitbar(slice/(thick1*3),wb);
        end
    else
        img = S1;
    end
    
    Xshifts = zeros(thick1,1);
    Yshifts = zeros(thick1,1);
    shiftsXY = zeros(2, thick1);
    
    %hy = fspecial('sobel');
    %hx = hy';
    
    for slice = options.step+1:thick1
        if modelSwitch
            I2 = img(:,:,slice);   % get a slice
            I1 = img(:,:,slice-options.step); % get the previous slice
            %T = I1(centerY-templateWidth:centerY+templateWidth,centerX-templateWidth:centerX+templateWidth);
            T = I1(max([1 centerY-templateWidth+Yshifts(slice-options.step)]):min([height1 centerY+templateWidth+Yshifts(slice-options.step)]),max([1 centerX-templateWidth+Xshifts(slice-options.step)]):min([width1 centerX+templateWidth+Xshifts(slice-options.step)]));
        else
            I2 = double(img(:,:,colorCh,slice));   % get a slice
            I1 = double(img(:,:,colorCh,slice-options.step)); % get the previous slice
            %Iy = imfilter(double(I1), hy, 'replicate');
            %Ix = imfilter(double(I1), hx, 'replicate');
            %I1grad = sqrt(Ix.^2 + Iy.^2);
           
            T = I1(max([1 centerY-templateWidth+Yshifts(slice-options.step)]):min([height1 centerY+templateWidth+Yshifts(slice-options.step)]),max([1 centerX-templateWidth+Xshifts(slice-options.step)]):min([width1 centerX+templateWidth+Xshifts(slice-options.step)]),:);
            %Iy = imfilter(double(T), hy, 'replicate');
            %Ix = imfilter(double(T), hx, 'replicate');
            %T = sqrt(Ix.^2 + Iy.^2);
        end
        if strcmp(options.method,'cc')
            [~,I_NCC]=template_matching(T, I2);
            %I_NCC = normxcorr2(T,I1); 
            [y,x]=find(I_NCC==max(I_NCC(:)));
        elseif strcmp(options.method,'sq')
            [I_NCC,~]=template_matching(T, I2);
            [y,x]=find(I_NCC==max(I_NCC(:)));
        elseif strcmp(options.method,'xcMatlab')
            c = normxcorr2(T, I2);
            [ypeak,xpeak]=find(c==max(c(:)));
            y = (ypeak-floor(size(T,1)/2));
            x = (xpeak-floor(size(T,2)/2));
        end
        
        if isempty(x);   x = centerX; end;
        if isempty(y);   y = centerY; end;
        Xshifts(slice) = x - centerX;
        Yshifts(slice) = y - centerY;
        waitbar((slice+thick1)/(thick1*3),wb);
    end
    
    % calculate absolute shifts vs 1st slice
%     XshiftsAbs0 = zeros(thick1,1);
%     YshiftsAbs0 = zeros(thick1,1);
%     for slice=2:thick1
%         XshiftsAbs0(slice) = XshiftsAbs0(slice-1)+Xshifts(slice);
%         YshiftsAbs0(slice) = YshiftsAbs0(slice-1)+Yshifts(slice);
%     end
    
    XshiftsAbs0 = -Xshifts;
    YshiftsAbs0 = -Yshifts;
    
    % calculate absolute shifts vs minX and minY values
    XshiftsAbs = zeros(thick1,1);
    YshiftsAbs = zeros(thick1,1);
    minX = min(XshiftsAbs0);
    minY = min(YshiftsAbs0);
    for slice=1:thick1
        XshiftsAbs(slice) = XshiftsAbs0(slice)-minX;
        YshiftsAbs(slice) = YshiftsAbs0(slice)-minY;
    end
else
    Xshifts = shiftsXY(1,:);
    Yshifts = shiftsXY(2,:);
    
    [relXPosVal,relXPosId] = min(Xshifts);
    [relYPosVal,relYPosId] = min(Yshifts);
    
    % calculate absolute shifts vs the relative slice
    XshiftsAbs0 = zeros(thick1,1);
    YshiftsAbs0 = zeros(thick1,1);
    for slice=1:thick1
        XshiftsAbs0(slice) = relXPosVal+Xshifts(slice);
        YshiftsAbs0(slice) = relYPosVal+Yshifts(slice);
    end
    
    % calculate absolute shifts vs minX and minY values
    XshiftsAbs = zeros(thick1,1);
    YshiftsAbs = zeros(thick1,1);
    minX = min(XshiftsAbs0);
    minY = min(YshiftsAbs0);
    for slice=1:thick1
        XshiftsAbs(slice) = XshiftsAbs0(slice)-minX;
        YshiftsAbs(slice) = YshiftsAbs0(slice)-minY;
    end
end

maxX = max(XshiftsAbs);
minX = min(XshiftsAbs);
deltaX = abs(maxX - minX);
maxY = max(YshiftsAbs);
minY = min(YshiftsAbs);
deltaY = abs(maxY - minY);

if modelSwitch
    img = zeros(height1+deltaY, width1+deltaX, thick1, class(S1));
    for slice=1:thick1
        Xo2 = XshiftsAbs(slice)+1;
        Yo2 = YshiftsAbs(slice)+1;
        img(Yo2:Yo2+height1-1,Xo2:Xo2+width1-1,slice) = S1(:,:,slice); 
        waitbar((slice+thick1*2)/(thick1*3),wb);
    end
else
    if isnumeric(options.backgroundColor)
        img = zeros(height1+deltaY, width1+deltaX, color1, thick1, class(S1))+options.backgroundColor;
    else
        if strcmp(options.backgroundColor,'black')
            img = zeros(height1+deltaY, width1+deltaX, color1, thick1, class(S1));
        elseif strcmp(options.backgroundColor,'white')
            img = zeros(height1+deltaY, width1+deltaX, color1, thick1, class(S1))+intmax(class(S1));
        else
            bgIntensity = mean(mean(mean(mean(S1))));
            img = zeros(height1+deltaY, width1+deltaX, color1, thick1, class(S1))+bgIntensity;
        end
    end
    for slice=1:thick1
        Xo2 = XshiftsAbs(slice)+1;
        Yo2 = YshiftsAbs(slice)+1;
        img(Yo2:Yo2+height1-1,Xo2:Xo2+width1-1,:,slice) = S1(:,:,:,slice); 
        waitbar((slice+thick1*2)/(thick1*3),wb);
    end
end

shiftsXY(1,:) = XshiftsAbs;
shiftsXY(2,:) = YshiftsAbs;

%figure(123)
%clf
%subplot(2,2,1), imshow(I1,[]); hold on; plot(x,y,'r*'); title('Result')
%subplot(2,2,2), imshow(T,[]); title('The eye template');
%subplot(2,2,3), imshow(I2,[]); hold on; plot(centerX,centerY,'r*'); title('second image');
%subplot(2,2,4), imshow(I_NCC,[]); title('Normalized-CC');
delete(wb);
end