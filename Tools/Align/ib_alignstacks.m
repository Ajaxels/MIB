function [img, shiftsXY] = ib_alignstacks(S1, S2, options, shiftsXY)
% align 2 stacks together
%  [img shiftsXY] = ib_alignstacks(S1, S2, options, shiftsXY)
% OUT:
% img -> aligned image stacks
% shiftsXY -> shift coefficients
% IN:
% S1 and S2 -> two stacks, that have (height x width x color x layers) or
%              (height x width x layers) format
% options -> optional
%       options.centerX -> center of the search window
%       options.centerY -> center of the search window
%       options.templateWidth -> half-width of the searching window
%       options.backgroundColor -> background color: 'black', 'white', 'mean', or a value
%       options.colorCh -> color channel
%       options.method -> method: 
%                   'cc' - the normalized cross correlation
%                   'sq' - the normalized sum of squared difference
%                   'xcMatlab' - beta of using matlab normxcorr2
%       options.gradientSw = 1 or 0, use gradient image or the original intensity image
%       options.modelSwitch -> 1-defines that dataset has 3 dimensions
%       [H,W,Z], or when 0 - 4 dimensions [H,W,C,Z]
% shiftsXY -> optional, when provided the function generates aligned stack
%             using this provided coordinates of shifts

% Copyright (C) 12.07.2011 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

% detect type of the inpuit data
if ndims(S1) ~= ndims(S2) && ndims(S1) ~= 2 && ndims(S2) ~= 2
    msgbox('Datasets dimensions mismatch!','Error','err');
    img = 0;
    return;
end

if ~isfield(options, 'colorCh')
    options.colorCh = 1;
end
colCh = options.colorCh;

width1 = size(S1,2);
height1 = size(S1,1);
width2 = size(S2,2);
height2 = size(S2,1);

if isfield(options, 'modelSwitch')
    if options.modelSwitch == 1
        modelSwitch = 1;  % model type height:width:thickness
        color1 = 1;
        color2 = 1;
        thick1 = size(S1,3);
        thick2 = size(S2,3);
    else
        modelSwitch = 0; % image type height:width:color:thickness
        color1 = size(S1,3);
        thick1 = size(S1,4);
        color2 = size(S2,3);
        thick2 = size(S2,4);
    end
else
    if ndims(S1) == 3
        modelSwitch = 1;  % model type height:width:thickness
        color1 = 1;
        color2 = 1;
        thick1 = size(S1,3);
        thick2 = size(S2,3);
    else
        modelSwitch = 0; % image type height:width:color:thickness
        color1 = size(S1,3);
        thick1 = size(S1,4);
        color2 = size(S2,3);
        thick2 = size(S2,4);
    end
end

if nargin < 4
    shiftsXY = NaN;
end

if nargin < 3
    templateWidth = round(min([width1/5 height1/5 width2/5 height2/5]));    
    centerX = floor(width2/2);
    centerY = floor(height2/2);
    backgroundColor = double(intmax(class(S1)));
else
    if isnan(shiftsXY(1))
        templateWidth = options.templateWidth;
        centerX = options.centerX;
        centerY = options.centerY;
    end
    if isfield(options, 'backgroundColor')
        if isnumeric(options.backgroundColor)
            backgroundColor = options.backgroundColor;
        else
            if strcmp(options.backgroundColor,'white')
                backgroundColor = double(intmax(class(S1)));
            elseif strcmp(options.backgroundColor,'black')
                backgroundColor = 0;
            else
                if modelSwitch
                    backgroundColor = round(mean2(S1(:,:,end)));
                else
                    backgroundColor = round(mean2(S1(:,:,colCh,end)));
                end
            end
        end
    else
        backgroundColor = double(intmax(class(S1)));
    end
end

if isnan(shiftsXY)
    if modelSwitch
        I1 = S1(:,:,end); % get the last slice of the stack 1
        I2 = S2(:,:,1); % get the first slice of the stack 2
    else
        I1 = S1(:,:,colCh,end); % get the last slice of the stack 1
        I2 = S2(:,:,colCh,1); % get the first slice of the stack 2
    end
    
    if options.gradientSw
        % generate gradient image
        hy = fspecial('sobel');
        hx = hy';
        Iy = imfilter(double(I1), hy, 'replicate');
        Ix = imfilter(double(I1), hx, 'replicate');
        I1grad = sqrt(Ix.^2 + Iy.^2);
        
        Iy = imfilter(double(I2), hy, 'replicate');
        Ix = imfilter(double(I2), hx, 'replicate');
        I2grad = sqrt(Ix.^2 + Iy.^2);
    else
        I1grad = double(I1);
        I2grad = double(I2);
    end
  
    if modelSwitch
        T = I2grad(max([1 centerY-templateWidth]):min([height2 centerY+templateWidth]),max([1 centerX-templateWidth]):min([width2 centerX+templateWidth]));
    else
        T = I2grad(max([1 centerY-templateWidth]):min([height2 centerY+templateWidth]),max([1 centerX-templateWidth]):min([width2 centerX+templateWidth]),:);
    end
    
    if strcmp(options.method,'cc')
        [~,I_NCC]=template_matching(T,I1grad);
        %I_NCC = normxcorr2(T,I1);
        [y,x]=find(I_NCC==max(I_NCC(:)));
    elseif strcmp(options.method,'sq')
        [I_NCC,~]=template_matching(T,I1grad);
        [y,x]=find(I_NCC==max(I_NCC(:)));
    elseif strcmp(options.method,'xcMatlab')
        c = normxcorr2(T, I1grad);
        [ypeak,xpeak]=find(c==max(c(:)));
        y = (ypeak-floor(size(T,1)/2));
        x = (xpeak-floor(size(T,2)/2));
    end
    
    Xo2 = x - centerX;
    Yo2 = y - centerY;
    shiftsXY(1) = Xo2;
    shiftsXY(2) = Yo2;
else
    Xo2 = shiftsXY(1);
    Yo2 = shiftsXY(2);
end
disp(['im_browser: alignment shifts of the second dataset X=' num2str(Xo2) ', Y=' num2str(Yo2)]);

if modelSwitch        % image format [height:width:thickness]
    if Xo2 <= 0
        if Yo2 >= 0     % the second dataset is shifted to towards the lower left corner
            %img = zeros(max([height1 Yo2+height2]), max([width1 abs(Xo2)+width2]), thick1+thick2, class(S1)) + backgroundColor;
            img = zeros(max([height1 Yo2+height2]), max([width2 abs(Xo2)+width1]), thick1+thick2, class(S1)) + backgroundColor;
            img(1:height1,1+abs(Xo2):1+abs(Xo2)+width1-1,1:thick1) = S1;
            img(1+Yo2:1+Yo2+height2-1,1:width2,thick1+1:thick1+thick2) = S2;
        else            % the second dataset is shifted to towards the upper left corner, !!! not checked
            img = zeros(max([abs(Yo2)+height1 height2]), max([abs(Xo2)+width1 width2]), thick1+thick2,class(S1))+backgroundColor;
            img(1+abs(Yo2):1+abs(Yo2)+height1-1,1+abs(Xo2):1+abs(Xo2)+width1-1,1:thick1) = S1;
            img(1:height2,1:width2,thick1+1:thick1+thick2) = S2;
        end
    else
        if Yo2 >= 0     % the second dataset is shifted to towards the lower right corner, 
            img = zeros(max([height1 Yo2+height2]), max([width1 abs(Xo2)+width2]), thick1+thick2,class(S1))+backgroundColor;
            img(1:height1,1:width1,1:thick1) = S1;
            img(1+Yo2:1+Yo2+height2-1,1+abs(Xo2):1+abs(Xo2)+width2-1,thick1+1:thick1+thick2) = S2;
        else            % the second dataset is shifted to towards the upper right corner
            img = zeros(max([height2 abs(Yo2)+height1]), max([width1 abs(Xo2)+width2]), thick1+thick2,class(S1))+backgroundColor;
            img(1+abs(Yo2):1+abs(Yo2)+height1-1,1:width1,1:thick1) = S1;
            img(1:height2,1+abs(Xo2):1+abs(Xo2)+width2-1,thick1+1:thick1+thick2) = S2;
            %img(1:height1,1:width1,1:thick1) = S1;
            %img(1+abs(Yo2):1+abs(Yo2)+height2-1,1+abs(Xo2):1+abs(Xo2)+width2-1,thick1+1:thick1+thick2) = S2;
        end
    end
else                % image format [height:width:color:thickness]
    if Xo2 <= 0
        if Yo2 >= 0     % the second dataset is shifted to towards the lower left corner
            %img = zeros(max([height1 Yo2+height2]), max([width1 abs(Xo2)+width2]), max([color1 color2]), thick1+thick2,class(S1))+backgroundColor;
            img = zeros(max([height1 Yo2+height2]),max([width2 abs(Xo2)+width1]), max([color1 color2]), thick1+thick2,class(S1))+backgroundColor;
            img(1:height1,1+abs(Xo2):1+abs(Xo2)+width1-1,1:color1,1:thick1) = S1;
            img(1+Yo2:1+Yo2+height2-1,1:width2,1:color2,thick1+1:thick1+thick2) = S2;
        else            % the second dataset is shifted to towards the upper left corner, !!! not checked
            img = zeros(max([abs(Yo2)+height1 height2]), max([abs(Xo2)+width1 width2]), max([color1 color2]), thick1+thick2,class(S1))+backgroundColor;
            img(1+abs(Yo2):1+abs(Yo2)+height1-1,1+abs(Xo2):1+abs(Xo2)+width1-1,1:color1,1:thick1) = S1;
            img(1:height2,1:width2,1:color2,thick1+1:thick1+thick2) = S2;
        end
    else
        if Yo2 >= 0     % the second dataset is shifted to towards the lower right corner
            img = zeros(max([height1 Yo2+height2]), max([width1 abs(Xo2)+width2]), max([color1 color2]), thick1+thick2,class(S1))+backgroundColor;
            img(1:height1,1:width1,1:color1,1:thick1) = S1;
            img(1+Yo2:1+Yo2+height2-1,1+abs(Xo2):1+abs(Xo2)+width2-1,1:color2,thick1+1:thick1+thick2) = S2;
        else            % the second dataset is shifted to towards the upper right corner, !!! not checked
            img = zeros(max([height2 abs(Yo2)+height1]), max([width1 abs(Xo2)+width2]), max([color1 color2]), thick1+thick2,class(S1))+backgroundColor;
            img(1+abs(Yo2):1+abs(Yo2)+height1-1,1:width1,1:color1,1:thick1) = S1;
            img(1:height2,1+abs(Xo2):1+abs(Xo2)+width2-1,1:color2,thick1+1:thick1+thick2) = S2;
            %img(1:height1,1:width1,1:color1,1:thick1) = S1;
            %img(1+abs(Yo2):1+abs(Yo2)+height2-1,1+abs(Xo2):1+abs(Xo2)+width2-1,1:color2,thick1+1:thick1+thick2) = S2;
        end
    end
end

%figure(123)
%clf
%subplot(2,2,1), imshow(I1,[]); hold on; plot(x,y,'r*'); title('Result')
%subplot(2,2,2), imshow(T,[]); title('The eye template');
%subplot(2,2,3), imshow(I2,[]); hold on; plot(centerX,centerY,'r*'); title('second image');
%subplot(2,2,4), imshow(I_NCC,[]); title('Normalized-CC');

end