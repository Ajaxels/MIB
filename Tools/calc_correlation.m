function [corr_coef, model, objMask, smooth_corr, granularity, roi_size] = ...
                calc_correlation(img, img_mask, mode, type, slope_length, darkthres, dt, auto_thres, inv_sw, a_contrast, relative_to_frame, objMask)
% Calculate correlation coefficients for img, script to run from Correlation panel of im_browser 
%
% Parameters:
%  img: - stack of images (h,w,color_channel,frame)
%  img_mask: - take only part of the original image into analysis. Mask(h,w) defines the area for analysis
%  mode: - mode, Absolute, Relative (current-previous), Relative cummulative
%  type: - type of correlation: Pearson, Overlap, Manders, Intersection...
%  slope_length: - number of frames to be used for smoothing calculation
%  darkthres: - object separation threshold, use 0 to analyse the whole image
%  dt: - time between frames
%  auto_thres: - [@em optional] automatic thresholding by Otsu's method switch: @b 0 - off, @b 1 - on
%  inv_sw: - [@em optional] instead of correlation, return displacement, usually 1-minus-correlation
%  a_contrast: - [@em optional] if not @em NaN, is used for adjust contrast individually for each roi box in each frame
%  relative_to_frame: - [@em optional] frame number for absolute mode
%  objMask: - [@em optional] provide object mask for analysis
%
% Return values:
%  corr_coef: - vector with amplitudes of correlation coefficients
%  model: - difference map, current_frame -minus- previous
%  objMask: - object mask, generated with  Otsu's method or with specified threshold value (darkthres)
%  smooth_corr: - smoothed correlation coefficient with the window size=slope_length 
%  granularity: - granularity of the objMask
%  roi_size: - size of the roi object in pixels

%| @b Types of coefficients:
% 1. @b Pearson: Pearson colocalization coefficient, intensity based
%       as 
%   @code
%  figure;
%  ax=gca;
%  set(ax,'Visible','off');
%   text(0.2,0.5,'$r_p = \frac{\sum((R_i-\bar{R})(G_i-\bar{G}))}{\sqrt{\sum{(R_i-\bar{R})^2\sum{(G_i-\bar{G})^2}}}}$','interpreter','latex','fontsize',14);
% @endcode
% 2. @b Overlap, overlap, intensity based coefficient
%       as
%   @code
% figure;ax=gca;
% set(ax,'Visible','off');text(0.2,0.5,'$r_o = \frac{\sum{R_i \times
% G_i}}{\sqrt{\sum{R_i^2}\times\sum{G_i^2}}}$','interpreter','latex','fontsize',14);
% @endcode
% 3. @b Manders, intensity based coefficient: M1 (current vs relative) and M2 (relative vs current)
%       as
%   @code
%   figure;ax=gca;set(ax,'Visible','off');text(0.2,0.5,'$M_1 = \frac{\sum{G_{i,coloc}}}{\sum{G_i}}$','interpreter','latex','fontsize',14)
%   figure;ax=gca;set(ax,'Visible','off');text(0.2,0.5,'$M_2 = \frac{\sum{R_{i,coloc}}}{\sum{R_i}}$','interpreter','latex','fontsize',14)
% @endcode
% 4. @b Intersection @b coefficient, object based
%       as
%   @code figure;ax=gca;set(ax,'Visible','off');
%   text(0.2,0.5,'$Rth_i =\Big\{ \frac{\mbox{0, if} R_i \le R_{bg}}{\mbox{1, if} R_i > R_{bg}} $','interpreter','latex','fontsize',14)
%   text(0.2,0.3,'$I =\frac{\sum{Rth_i \cap Gth_i}}{\sum{Rth_i} + \sum{Gth_i} - \sum{Rth_i \cap Gth_i}} $','interpreter','latex','fontsize',14);
%   @endcode;
% 5. @b Mask @b displacement, object based coefficient.
%    Calculates displacement of the thresholded image as
%   @code
%    figure;ax=gca;set(ax,'Visible','off');
%    text(0.02,0.5,'$Rth_i =\Big\{ \frac{\mbox{0, if} R_i \le R_{bg}}{\mbox{1, if} R_i > R_{bg}} $','interpreter','latex','fontsize',12)
%    text(0.02,0.3,'$D_m =\frac{\sum{Rth_i \ominus Gth_i}}{\mbox{total number of pixels}}, \mbox{where }\ominus \mbox{is symmetric difference} $','interpreter','latex','fontsize',12);
%   @endcode
% 6. @b Image @b displacement, displacements of masks that are generated from the difference of compared images
%       as
%    - take difference between current and relative images
%    - threshold the difference image with the provided parameter to generate two masks of displacement
%    - take a union of both masks
%    - calculate the coefficient as sum of mask's union / by total number of pixels in the area
% @see ib_calcCorrelation, correlationAnalysis_script

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

if strcmp(type,'Manders')
    corr_coef = zeros(size(img,4),2);   % M(:,1) -> current vs reference; M(:,2) -> reference vs current
else
    corr_coef = zeros(size(img,4),1);
end
granularity = zeros(1,size(img,4));
model = zeros(size(img,1),size(img,2),size(img,4),'int16');
if nargin < 12; 
    objMask = zeros(size(img,1),size(img,2),size(img,4),'uint8');
    use_bw_mask = 0;
else
    use_bw_mask = 1;
end;
if nargin < 11; relative_to_frame = 1; end;
if nargin < 10; a_contrast = [NaN NaN]; end;
if nargin < 9; inv_sw = 0; end;

roi_size = sum(sum(img_mask));

for i=1:size(img,4)
    if strcmp(mode,'Relative') || strcmp(mode,'Relative cummulative')
        relative_to_frame = i-1;
    end;
    if relative_to_frame == 0; relative_to_frame = 1; end;
    rel_img = img(:,:,1,relative_to_frame);
    curr_img = img(:,:,1,i);
    %rel_img = double(img(:,:,1,relative_to_frame));
    %curr_img = double(img(:,:,1,i));
    
    % do image masking
    %rel_img(img_mask==0) = -1;  % -1 because of mask2(rel_img>=darkthres) = 1;
    %curr_img(img_mask==0) = -1; 
    
    rel_img(img_mask==0) = 0;
    curr_img(img_mask==0) = 0;
    
    diff_map = double(curr_img) - double(rel_img);
    model(:,:,i) = diff_map;
    
    % Generate Mask based on predefined/generated mask (objMask) and selected ROI (img_mask)
    if use_bw_mask  % use predefined mask
        curr_mask = objMask(:,:,i);
        diff_mask = imabsdiff(img_mask,curr_mask);
        diff_mask(img_mask==0) = 0;
        curr_bg = max(curr_img(diff_mask==1));  % maximal background intensity to be subtracted
        if ~isempty(curr_bg)
            curr_img = curr_img - curr_bg;
        end;
        rel_mask = objMask(:,:,relative_to_frame);
        diff_mask = imabsdiff(img_mask,rel_mask);
        diff_mask(img_mask==0) = 0;
        rel_bg = max(rel_img(diff_mask==1));
        if ~isempty(rel_bg)
            rel_img = rel_img - rel_bg;
        end;
    else % no mask, or generate a new mask
        if auto_thres   % automatically calculate threshold
             thres_rel = graythresh(uint8(rel_img(img_mask==1)));
             thres_curr = graythresh(uint8(curr_img(img_mask==1)));
             rel_mask = im2bw(uint8(rel_img),thres_rel);
             curr_mask = im2bw(uint8(curr_img),thres_curr);
             rel_img = rel_img - thres_rel*255;
             curr_img = curr_img - thres_curr*255;
             darkthres = thres_curr*255;
        else    % no b/w thresholding when darkthreshold == 0
            rel_mask = zeros(size(img_mask),'uint8');
            curr_mask = zeros(size(img_mask),'uint8');
            if ~strcmp(type, 'Image Displacement')  
                if darkthres ~= 0
                    rel_mask(rel_img>darkthres) = 1;
                    curr_mask(curr_img>darkthres) = 1;
                    rel_img = rel_img - darkthres;
                    curr_img = curr_img - darkthres;
                else
                    rel_mask(rel_img>=darkthres) = 1;  
                    curr_mask(curr_img>=darkthres) = 1;  
                end
             else   % calculate mask for image displacement type, this time the mask is the actual displacement
                diff_map = double(curr_img) - double(rel_img);
                curr_mask(diff_map > darkthres) = 1;
                rel_mask(diff_map < -darkthres) = 1;
                curr_mask = curr_mask | rel_mask;
             end
        end  
        dummyMask = objMask(:,:,i);
        dummyMask(img_mask==1) = curr_mask(img_mask==1);
        objMask(:,:,i) = dummyMask;
    end
    
    % calculate granularity
    if use_bw_mask | auto_thres | darkthres > 0 & ~strcmp(type, 'Image Displacement') %#ok<*AND2,OR2>
        remain_img = imerode(curr_mask, strel('rectangle', [3 3]));
        granularity(1,i) = (sum(sum(curr_mask))-sum(sum(remain_img)))/sum(sum(curr_mask)); 
    else
        granularity(1,i) = 0;
    end
%     if darkthres==0 | strcmp(type, 'Image Displacement') | ~use_bw_mask | ~auto_thres
%         granularity(1,i) = 0;
%     else
%         remain_img = imerode(curr_mask, strel('rectangle', [3 3]));
%         granularity(1,i) = (sum(sum(curr_mask))-sum(sum(remain_img)))/sum(sum(curr_mask)); 
%     end
   
    if strcmp(type, 'Pearson')  % normal Pearson's coefficient
        if inv_sw == 1
            corr_coef(i) = 1 - corr2(curr_img(img_mask==1), rel_img(img_mask==1));
        else
            corr_coef(i) = corr2(curr_img(img_mask==1), rel_img(img_mask==1));
        end
    elseif strcmp(type, 'Overlap')
        curr_intensities = double(curr_img(img_mask==1));
        rel_intensities = double(rel_img(img_mask==1));
        numerator = 0;
        denominator1 = 0;
        denominator2 = 0;
        for ind=1:numel(curr_intensities)
            numerator = numerator + curr_intensities(ind)*rel_intensities(ind);
            denominator1 = denominator1 + curr_intensities(ind)^2;
            denominator2 = denominator2 + rel_intensities(ind)^2;
        end
        if inv_sw == 1
            corr_coef(i) = 1 - numerator/sqrt(denominator1*denominator2);
        else
            corr_coef(i) = numerator/sqrt(denominator1*denominator2);
        end
    elseif strcmp(type,'Manders')    % calculate only M2 value
        mask_overlap = curr_mask & rel_mask;
        if inv_sw == 1
            corr_coef(i,1) = 1 - sum(curr_img(mask_overlap==1))/sum(curr_img(curr_mask==1));
            corr_coef(i,2) = 1 - sum(rel_img(mask_overlap==1))/sum(rel_img(rel_mask==1));
        else
            corr_coef(i,1) = sum(curr_img(mask_overlap==1))/sum(curr_img(curr_mask==1));
            corr_coef(i,2) = sum(rel_img(mask_overlap==1))/sum(rel_img(rel_mask==1));
        end
    elseif strcmp(type,'Intersection')    
        mask_overlap = curr_mask & rel_mask;
        if inv_sw == 1
            corr_coef(i) = 1 - sum(sum(mask_overlap))/(sum(sum(curr_mask))+sum(sum(rel_mask))-sum(sum(mask_overlap)));
        else
            corr_coef(i) = sum(sum(mask_overlap))/(sum(sum(curr_mask))+sum(sum(rel_mask))-sum(sum(mask_overlap)));
        end
    elseif strcmp(type,'Mask Displacement')
        mask_disp = imabsdiff(rel_mask,curr_mask);
        if inv_sw == 1
            corr_coef(i) = 1 - sum(sum(mask_disp))/roi_size;
        else
            corr_coef(i) = sum(sum(mask_disp))/roi_size;
        end
    elseif strcmp(type,'Image Displacement')
        %mask_sum = curr_mask | rel_mask;
        mask_sum = curr_mask;   % curr_mask is actually already a sum of two masks
        if inv_sw == 1
            corr_coef(i) = 1 - sum(sum(mask_sum))/roi_size;
        else
            corr_coef(i) = sum(sum(mask_sum))/roi_size;
        end
    end
end

if strcmp(mode,'Relative cummulative')  % calculate cummulative coefficients
    cummulative = zeros(size(corr_coef));
    for i=2:size(corr_coef,1)
        cummulative(i,:) = cummulative(i-1,:) + corr_coef(i,:); 
    end
    corr_coef = cummulative;
end

smooth_corr = zeros(size(corr_coef))*NaN;
win_width = round(slope_length-1)/2;
for id=1:size(corr_coef,2)
    for frameid=1+win_width:size(corr_coef,1)-win_width
        smooth_corr(frameid,id) = mean(corr_coef(frameid-win_width:frameid+win_width, id));
    end
end

% % next is to calculate slopes of the cummulative plot
% slopes = zeros(size(corr_coef,1),size(corr_coef,2),2)*NaN;    % initilize with NaN slopes(frame,M1/M2,k/dx)
% lShift = floor(slope_length/2);     % get window for slope calculations
% rShift = slope_length - lShift-1;
% start_no = 1 + lShift;
% end_no = size(corr_coef,1)-rShift;
% time_vec = 0:dt:size(corr_coef,1)*dt-dt;
% for id=1:size(corr_coef,2)
%     for i=start_no:end_no
%         slopes(i,id,:) = polyfit(time_vec(i-lShift:i+rShift),corr_coef(i-lShift:i+rShift,id)',1);
%     end
% end

% figure(293)
% plot(time_vec(1):time_vec(end),slopes(:,1,1),'o-');
% title('Slopes');
% grid;    
% figure(294)
% ind=5;
% if ind > size(corr_coef,1)-slope_length+1
%     ind = size(corr_coef,1)-slope_length+1;
% end
% hh=plot(time_vec(1):time_vec(end),corr_coef(:,1),'o-',[time_vec(ind) time_vec(ind+slope_length-1)],[time_vec(ind)*slopes(ind,1,1)+slopes(ind,1,2) time_vec(ind+slope_length-1)*slopes(ind,1,1)+slopes(ind,1,2)],'r');
% set(hh(2),'Linewidth',3);
% title('Pearson corr. coef. and sloping function');
% grid;
end