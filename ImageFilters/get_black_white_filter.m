function [bwimage, image_grid] = get_black_white_filter(img,darkthres,automatic,mask,grid_size,grid_coef, orientation, layer_id, thrMatrix)
% function [bwimage, image_grid] = get_black_white_filter(img,darkthres,automatic,mask,grid_size,grid_coef, orientation, layer_id, thrMatrix)
% Calculate black and white bitmap out of the image.
%
% Parameters:
% img: - input image, img - [1:height,1:width,1:colors,1:stacks]
% darkthres: - a vector with minimal and maximal levels b/w threshold [minValue, maxValue]
% automatic: - automatically define b/w thereshold, when @b 1
% mask: - mask for the image, when only part of the image is needed
% grid_size: - detection of b/w threshold based on a grid when grid_size > 0
% grid_coef: - the coefficient for defining the minimal bw convertion value, if empty will be defined automatically
% orientation: - indicates dimension for 2D iterations, @b 1 - XZ, @b 2 - YZ, @b 4 - XY
% layer_id: - define a single slice from the dataset
% - when layer_id > 0 - threshold the slice with this number
% - when layer_id == 0 - threshold the whole dataset
% - when layer_id omitted - threshold the whole dataset
% thrMatrix: [@em optional] matrix with thresholding coefficients, @b
% default = NaN
%
% Return values:
% bwimage: - thresholded b/w image
% image_grid - image with the applied grid

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


bwimage = 0;
image_grid = 0;
if nargin < 9   % threshold matrix for manual grid thresholding
    thrMatrix = NaN;
end
if nargin < 8;
    start_id = 1;
    end_id = size(img, orientation);
else
    if layer_id == 0
        start_id = 1;
        end_id = size(img, orientation);
    else
        start_id = layer_id;
        end_id = layer_id;
    end
end
if nargin < 7; orientation = 4; end;
if nargin < 6; grid_coef = 0; end;
if nargin < 5; grid_size = 0; end;
if nargin < 4; mask = zeros(size(img,1),size(img,2),'uint8')+1; end; 
if nargin < 3; automatic=1; end;
if nargin < 2; darkthres = [0 0]; end;
if nargin < 1; msgbox('At least image is required!','Error!','error');return; end;

if orientation == 4
    dim1 = 1;
    dim2 = 2;
elseif orientation == 1
    dim1 = 2;
    dim2 = 4;
elseif orientation == 2
    dim1 = 1;
    dim2 = 4;
end
maxY = size(img,1);
maxX = size(img,2);
maxZ = size(img,4);

STATS = regionprops(mask, 'BoundingBox');

if numel(STATS) == 0
    w1 = 1;
    w2 = size(img,dim2);
    h1 = 1;
    h2 = size(img,dim1);
else
    w1 = round(STATS(1).BoundingBox(1));
    w2 = round(STATS(1).BoundingBox(1))+STATS(1).BoundingBox(3)-1;
    h1 = round(STATS(1).BoundingBox(2));
    h2 = round(STATS(1).BoundingBox(2))+STATS(1).BoundingBox(4)-1;
end

if grid_size > 0
    width = w2-w1+1;
    height = h2-h1+1;
    [bl_w, bl_h] = generate_grid_block_size(width, height, grid_size);
    grid_switch = 1;
    disp(['Grid block size (width:height)= ' num2str(bl_w) ':' num2str(bl_h) ' pixels']);
else
    block_size = [size(img,dim1), size(img,dim2)];
    bl_w = block_size(2);
    bl_h = block_size(1);
    grid_switch = 0;
end
bwimage = zeros(maxY,maxX,maxZ,'uint8');  
image_grid = zeros(maxY,maxX,maxZ,'uint8');
th_min = zeros(size(img,orientation),1);

Options.h1 = h1;
Options.bl_h = bl_h;
Options.h2 = h2;
Options.w1 = w1;
Options.bl_w = bl_w;
Options.w2 = w2;
Options.grid_coef = grid_coef;
Options.darkthres = darkthres;
Options.grid_switch = grid_switch;
Options.automatic =  automatic;
Options.thrMatrix = thrMatrix;

if orientation == 4     % xy plane
    layer = start_id;
    I = img(:,:,:,layer);
    exportThrMatrixSw = 1;
    
    if numel(thrMatrix) > 1
        h = size(bwimage,1);
        w = size(bwimage,2);
        stepX = w/size(thrMatrix,2);
        stepY = h/size(thrMatrix,1);
        
        [X,Y] = meshgrid(stepX/2:stepX:w,stepY/2:stepY:h);
        [Xi,Yi] = meshgrid(1:w,1:h);
        Zi = interp2(X,Y,thrMatrix,Xi,Yi,'*cubic',0);
        centX = round(w/2);
        centY = round(h/2);
        y1 = max(find(Zi(1:centX,centY)==0)); %#ok<MXFND>
        y2 = min(find(Zi(centX:end,centY)==0))+centX-1; %#ok<MXFND>
        x1 = max(find(Zi(centX,1:centY)==0)); %#ok<MXFND>
        x2 = min(find(Zi(centX,centY:end)==0))+centY-1; %#ok<MXFND>
        
        Zi(1:y1,:) = repmat(Zi(y1+1,:),[y1 1]);
        Zi(y2:h,:) = repmat(Zi(y2-1,:),[h-y2+1 1]);
        Zi(:,1:x1) = repmat(Zi(:,x1+1),[1 x1]);
        Zi(:,x2:w) = repmat(Zi(:,x2-1),[1 w-x2+1]);
        %figure(1);
        %mesh(X,Y,thrMatrix); hold; mesh(Xi,Yi,Zi+15);
    else
        Zi = NaN;
    end
    
    if start_id == end_id
        [bwimage(:,:,layer), image_grid(:,:,layer), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw, Zi);
        bwimage = uint8(bwimage(:,:,start_id));
        image_grid = uint8(image_grid(:,:,start_id));
        th_min = th_min(start_id);
    else
        [bwimage(:,:,layer), image_grid(:,:,layer), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw, Zi);
        exportThrMatrixSw = 0;
        parfor layer = start_id+1:end_id   % change to parfor
            I = img(:,:,:,layer);
            [bwimage(:,:,layer), image_grid(:,:,layer), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw, Zi);
        end
    end
elseif orientation == 1     % xz plane
    layer = start_id;
    I = squeeze(img(layer,:,:,:));
    exportThrMatrixSw = 1;
    if start_id == end_id
        [bwimage(layer,:,:), image_grid(layer,:,:), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw);
        bwimage = squeeze(uint8(bwimage(start_id,:,:)));
        image_grid = squeeze(uint8(image_grid(start_id,:,:)));
        th_min = th_min(start_id);
    else
        [bwimage(layer,:,:), image_grid(layer,:,:), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw);
        exportThrMatrixSw = 0;
        parfor layer = start_id+1:end_id   % change to parfor
            I = squeeze(img(layer,:,:,:));
            [bwimage(layer,:,:), image_grid(layer,:,:), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw);
        end
    end
    
elseif orientation == 2     % yz plane
    layer = start_id;
    I = squeeze(img(:,layer,:,:));
    exportThrMatrixSw = 1;
    if start_id == end_id
        [bwimage(:,layer,:), image_grid(:,layer,:), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw);
        bwimage = squeeze(uint8(bwimage(:,start_id,:)));
        image_grid = squeeze(uint8(image_grid(:,start_id,:)));
        th_min = th_min(start_id);
    else
        [bwimage(:,layer,:), image_grid(:,layer,:), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw);
        exportThrMatrixSw = 0;
        parfor layer = start_id:end_id   % change to parfor
            I = squeeze(img(:,layer,:,:));
            [bwimage(:,layer,:), image_grid(:,layer,:), th_min(layer)] = do_filter(I, mask, Options, exportThrMatrixSw);
        end
    end
    
else
    error('[Error] Strel Mask Filter: unsupported dimention/orientation!');
end
th_min = min(th_min);
disp(['Black and White filter: threshold=' num2str(th_min)]);
end


function [bwimage, image_grid, th_min] = do_filter(I, mask, Options, exportThrMatrixSw, thresholdImage)
h1 = Options.h1;
bl_h = Options.bl_h;
h2 = Options.h2;
w1 = Options.w1;
bl_w = Options.bl_w;
w2 = Options.w2;
grid_coef = Options.grid_coef;
darkthres = Options.darkthres;
grid_switch = Options.grid_switch;
automatic =  Options.automatic;
thrMatrix = Options.thrMatrix;

image_grid_dummy = zeros(size(I),'uint8');
image_grid = image_grid_dummy;
max_int = double(intmax(class(I)));

if grid_switch && isnan(thrMatrix(1,1)) % when using grid in auto mode
    mask2 = zeros(size(mask),'uint8'); % second mask bigger than the 'mask' by size of the grid's rectangle
    thresholds = zeros(size(I))+1;
    %I_masked = I;
    %I_masked(mask==0) = -1;
    indX = 0;   % column index for thrMatrix or thrMatrixOut
    indY = 0;   % row index for thrMatrix or thrMatrixOut
    thrMatrixOut = zeros(ceil((h2-h1-1)/bl_h), ceil((w2-w1-1)/bl_w))+255; % memory preallocation for a matrix of threshold values
    for y_pos=h1:bl_h:h2   % cycling
        indY = indY + 1;
        y_pos2 = y_pos + bl_h - 1;
        if y_pos2 > h2; y_pos2 = h2; end;
        if y_pos == h2; continue; end;
        for x_pos=w1:bl_w:w2
            indX = indX + 1;
            if indX > size(thrMatrixOut,2); indX = 1; end;
            x_pos2 = x_pos + bl_w - 1;
            if x_pos2 > w2; x_pos2 = w2; end;
            if x_pos == w2; indX = 0; continue; end;
            dummy = zeros(size(I),'uint8');
            dummy(y_pos:y_pos2,x_pos:x_pos2) = 1;
            
            if sum(sum(dummy & mask))/(bl_w*bl_h) < 0.5  % do not calculate those where the mask is less than 50%
                continue;
            end
            
            if max(max(dummy & mask))
                mask2(y_pos:y_pos2,x_pos:x_pos2) = 1;
                %if layer==1
                image_grid_dummy(y_pos:y_pos2,x_pos) = 1;
                image_grid_dummy(y_pos:y_pos2,x_pos2) = 1;
                image_grid_dummy(y_pos,x_pos:x_pos2) = 1;
                image_grid_dummy(y_pos2,x_pos:x_pos2) = 1;
                %end
            end;
            %if automatic == 1
            auto_threshold = graythresh(I(y_pos:y_pos2,x_pos:x_pos2));
            thrMatrixOut(indY, indX) = round(auto_threshold*max_int);
            if auto_threshold*max_int > darkthres(2) && darkthres(2) ~= 0
                auto_threshold = darkthres(2)/max_int;
            end
            if auto_threshold*max_int < darkthres(1) && darkthres(1) ~= 0
                auto_threshold = darkthres(1)/max_int;
            end
            thresholds(y_pos:y_pos2,x_pos:x_pos2)=auto_threshold;
        end
        indX = 0;
    end
    thresholds(mask2==0) = 0;
    if grid_coef == 0
        th_min = min(min(thresholds(thresholds>0)));
    else
        th_min = grid_coef;
    end;
    thresholds(mask==0) = 0;
    thresholds_coef = 1-(thresholds-th_min);
    I(mask2~=1) = 0;
    correctedImg = uint8(double(I).*thresholds_coef);
    bwimage = im2bw(correctedImg,th_min);
    image_grid = image_grid_dummy;
    if exportThrMatrixSw
        assignin('base','thrMatrix', thrMatrixOut);
        disp('im_browser: variable "thrMatrix" with grid thresholds is created in the Matlab workspace');
    end
elseif grid_switch && ~isnan(thrMatrix(1,1)) && numel(thrMatrix) > 1 % when using grid in manual mode after press of the Start button
    mask2 = zeros(size(mask),'uint8'); % second mask bigger than the 'mask' by size of the grid's rectangle
    bwimage = zeros([size(I,1) size(I,2)],'uint8');
    %indX = 0;   % column index for thrMatrix
    %indY = 0;   % row index for thrMatrix
    
%     stepX = size(bwimage,2)/size(thrMatrix,2);
%     stepY = size(bwimage,1)/size(thrMatrix,1);
%     
%     h = size(bwimage,1);
%     w = size(bwimage,2);
%     [X,Y] = meshgrid(stepX/2:stepX:w,stepY/2:stepY:h);
%     [Xi,Yi] = meshgrid(1:w,1:h);
%     Zi = interp2(X,Y,thrMatrix,Xi,Yi,'*cubic',0);
%     centX = round(w/2);
%     centY = round(h/2);
%     y1 = max(find(Zi(1:centX,centY)==0)); %#ok<MXFND>
%     y2 = min(find(Zi(centX:end,centY)==0))+centX-1; %#ok<MXFND>
%     x1 = max(find(Zi(centX,1:centY)==0)); %#ok<MXFND> 
%     x2 = min(find(Zi(centX,centY:end)==0))+centY-1; %#ok<MXFND>
%     
%     Zi(1:y1,:) = repmat(Zi(y1+1,:),[y1 1]);
%     Zi(y2:h,:) = repmat(Zi(y2-1,:),[h-y2+1 1]);
%     Zi(:,1:x1) = repmat(Zi(:,x1+1),[1 x1]);
%     Zi(:,x2:w) = repmat(Zi(:,x2-1),[1 w-x2+1]);
%     
%     %figure(1);
%     %mesh(X,Y,thrMatrix); hold; mesh(Xi,Yi,Zi+15);
    bwimage(I>thresholdImage) = 1;
    
    for y_pos=h1:bl_h:h2   % cycling
        y_pos2 = y_pos + bl_h - 1;
        if y_pos2 > h2; y_pos2 = h2; end;
        if y_pos == h2; continue; end;
        for x_pos=w1:bl_w:w2
            x_pos2 = x_pos + bl_w - 1;
            if x_pos2 > w2; x_pos2 = w2; end;
            if x_pos == w2; continue; end;
            dummy = zeros(size(I),'uint8');
            dummy(y_pos:y_pos2,x_pos:x_pos2) = 1;
            
            if max(max(dummy & mask))
                mask2(y_pos:y_pos2,x_pos:x_pos2) = 1;
                image_grid_dummy(y_pos:y_pos2,x_pos) = 1;
                image_grid_dummy(y_pos:y_pos2,x_pos2) = 1;
                image_grid_dummy(y_pos,x_pos:x_pos2) = 1;
                image_grid_dummy(y_pos2,x_pos:x_pos2) = 1;
            end;
        end
    end
    th_min = 0;
    bwimage(mask==0) = 0;
    image_grid = image_grid_dummy;
elseif grid_switch && ~isnan(thrMatrix(1,1)) && numel(thrMatrix) == 1 % fast light option
    mask2 = zeros(size(mask),'uint8'); % second mask bigger than the 'mask' by size of the grid's rectangle
    bwimage = zeros([size(I,1) size(I,2)],'uint8');
    indX = 0;   % column index for thrMatrix
    indY = 0;   % row index for thrMatrix
    
    for y_pos=h1:bl_h:h2   % cycling
        indY = indY + 1;
        y_pos2 = y_pos + bl_h - 1;
        if y_pos2 > h2; y_pos2 = h2; end;
        if y_pos == h2; continue; end;
        for x_pos=w1:bl_w:w2
            indX = indX + 1;
            if indX > size(thrMatrix,2); indX = 1;  continue; end;
            x_pos2 = x_pos + bl_w - 1;
            if x_pos2 > w2; x_pos2 = w2; end;
            if x_pos == w2; continue; end;
            dummy = zeros(size(I),'uint8');
            dummy(y_pos:y_pos2,x_pos:x_pos2) = 1;
            
            if max(max(dummy & mask))
                mask2(y_pos:y_pos2,x_pos:x_pos2) = 1;
                image_grid_dummy(y_pos:y_pos2,x_pos) = 1;
                image_grid_dummy(y_pos:y_pos2,x_pos2) = 1;
                image_grid_dummy(y_pos,x_pos:x_pos2) = 1;
                image_grid_dummy(y_pos2,x_pos:x_pos2) = 1;
            end;
            if indY <= size(thrMatrix,1) && indX <= size(thrMatrix,2)   % if thrMatrix smaller than the number of grids
                auto_threshold = thrMatrix(indY, indX)/max_int;
            else
                auto_threshold = 1;
            end
            bwimage(y_pos:y_pos2,x_pos:x_pos2)=im2bw(I(y_pos:y_pos2,x_pos:x_pos2), auto_threshold);
        end
        indX = 0;
    end
    th_min = 0;
    bwimage(mask==0) = 0;
    image_grid = image_grid_dummy;
else    % without grid, i.e. for all image one parameter
    I(mask==0) = -1;
    if automatic    % automatic determination of the thrashold value
        auto_threshold = graythresh(I(mask==1));
        if auto_threshold*max_int > darkthres(2) && darkthres(2) ~= 0
            auto_threshold = darkthres(2)/max_int;
        end
        if auto_threshold*max_int < darkthres(1) && darkthres(1) ~= 0
            auto_threshold = darkthres(1)/max_int;
        end
        bwimg = im2bw(I,auto_threshold);
    else  % using provided value
        auto_threshold = 0;
        if darkthres(1) == 0
            bwimg = 1-im2bw(I,darkthres(2)/max_int);
        elseif darkthres(2) == 0
            bwimg = im2bw(I,darkthres(1)/max_int);
        else
            bwimg = im2bw(I,darkthres(1)/max_int)-im2bw(I,darkthres(2)/max_int);
        end
        
    end
    bwimg(mask==0) = 0;
    bwimage = bwimg;
    th_min = auto_threshold;
end
end
