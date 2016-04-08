function handles = ib_calcCorrelation(handles)
% function handles = ib_calcCorrelation(handles)
% Calculate correlation coefficients between frames in the XY plane
%
% This is the main function called from Correlation Panel of im_browser.m
%
% Parameters:
% handles: structure with handles of im_browser.m
%
% Return values:
% handles: structure with handles of im_browser.m
% @see correlationAnalysis_script, calc_correlation

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

tic
if handles.Img{handles.Id}.I.no_stacks < 2
    msgbox('Correlation analysis requires a set of images','Error!','error','modal'); return;
end;
if size(handles.Img{handles.Id}.I.img,3) > 1
    msgbox('Correlation analysis works only with a single color data','Error!','error','modal'); return;
end
if handles.Img{handles.Id}.I.orientation ~= 4;
    msgbox('Please rotate the dataset to the XY orientation!','Error!','error','modal');
    return;
end

answer = inputdlg({'Input time between the frames','Input number of frames for slope calculation'},'Parameters',1,{num2str(handles.Img{handles.Id}.I.pixSize.t), '3'});
if isempty(answer); return; end;
handles.Img{handles.Id}.I.pixSize.t = str2double(answer{1});
slope_length = str2double(answer{2});

modes_list = get(handles.corrModeCombo,'String');   % mode: Absolute, Relative or Relative cummulative
mode = modes_list(get(handles.corrModeCombo,'Value'));
types_list = get(handles.corrTypeCombo,'String');   % type: Pearson, Manders...
type = types_list(get(handles.corrTypeCombo,'Value'));
if strcmp(mode,'Absolute')
    relative_to_frame = str2double(get(handles.corrAbsvsEdit,'String'));  % get reference frame number
else
    relative_to_frame = 1;
end
if ~strcmp(class(handles.Img{handles.Id}.I.img),'uint8')    % 8bit format is required
    msgbox(sprintf('Please convert to the 8-bit data format first!\nMenu->Image->Mode->8 bit\nRemember to adjust brighness before conversion!'),'Convert to 8bit format!','error','modal');
    return;
end
if get(handles.corrManualRadio,'Value') == 1    % set b/w threshold
    darkthres = str2double(get(handles.corrManualThresEdit,'String'));  % points below threshold will not be counted
else
    darkthres = 0;
end
if get(handles.corrAutoRadio,'Value') == 1    % set b/w threshold
    auto_thres = 1;  % use automatic thresholding mode
else
    auto_thres = 0;
end
if get(handles.corrMaskRadio,'Value') == 0   % if no mask is used, create an empty variable
    handles.Img{handles.Id}.I.maskImg = zeros(size(handles.Img{handles.Id}.I.img,1),size(handles.Img{handles.Id}.I.img,2),handles.Img{handles.Id}.I.no_stacks,'uint8');
end
if get(handles.corrAutoContrastCheck,'Value') == 1
    prompt = {sprintf('Enter low limit of saturation [0-1], %%:'),...
        'Enter high limit of saturation [0-1], %%:'};
    dlg_title = 'Enter limits for contrast stretching';
    num_lines = 1;
    def = {'0.01','0.99'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if isempty(answer); return; end;
    
    a_contrast(1) = str2double(cell2mat(answer(1)));
    a_contrast(2) = str2double(cell2mat(answer(2)));
else
    a_contrast(1) = NaN;
    a_contrast(2) = NaN;
end
grid_run_sw = get(handles.corrGridCheck,'Value');
inv_sw = get(handles.corrInvCheck,'Value');


dt = handles.Img{handles.Id}.I.pixSize.t; % time between frames
wb = waitbar(0,'Calculating difference maps...','Name','Diff-maps','WindowStyle','modal');
handles.Img{handles.Id}.I.clearSelection();
handles.Img{handles.Id}.I.model = zeros(size(handles.Img{handles.Id}.I.img,1),size(handles.Img{handles.Id}.I.img,2),handles.Img{handles.Id}.I.no_stacks,'int16');

selected_roi = get(handles.roiList,'Value') - 1;
roi_list = get(handles.roiList,'String');
if ischar(class(roi_list)); roi_list = cellstr(roi_list); end;   % turn to cell when one element only

if strcmp(type,'Manders')   % define size switch for memory preallocation
    manders_par = 2;
else
    manders_par = 1;
end

if ~grid_run_sw         % do analysis of ROIs or whole image
    if get(handles.roiShowCheck,'Value') == 0    % do the whole image analysis
        granularity = zeros(1,1,size(handles.Img{handles.Id}.I.img,4));     % granularity vector
        roi_size = zeros(1,1);        % roi size
        corr_coef = zeros(1,1,size(handles.Img{handles.Id}.I.img,4),manders_par);
        smooth_corr = zeros(1,1,size(handles.Img{handles.Id}.I.img,4),manders_par);   % smoothed corr coef.
        
        img_mask = zeros(size(handles.Img{handles.Id}.I.img,1), size(handles.Img{handles.Id}.I.img,2),'uint8')+1;  % take whole image
        if get(handles.corrMaskRadio,'Value')    % use predefined mask
            [corr_coef(1,1,:,:), handles.Img{handles.Id}.I.model, ~, smooth_corr(1,1,:,:), granularity(1,1,:), roi_size(1,1)] = ...
                calc_correlation(handles.Img{handles.Id}.I.img, img_mask, mode, type, slope_length, darkthres, dt, auto_thres, inv_sw, a_contrast, relative_to_frame, handles.Img{handles.Id}.I.maskImg);
        else    % generate object mask, or use provided threshold value
            [corr_coef(1,1,:,:), handles.Img{handles.Id}.I.model, handles.Img{handles.Id}.I.maskImg, smooth_corr(1,1,:,:), granularity(1,1,:),roi_size(1,1)] = ...
                calc_correlation(handles.Img{handles.Id}.I.img, img_mask, mode, type, slope_length, darkthres, dt, auto_thres, inv_sw, a_contrast, relative_to_frame);
        end
    else    % check rois
        if selected_roi > 0     % do only selected ROI
            start_no = selected_roi;
            end_no = selected_roi;
        elseif selected_roi == 0 && numel(roi_list) == 2  % only one roi present
            start_no = 1;
            end_no = 1;
        elseif selected_roi == 0 && numel(roi_list) > 2  % several roi found
            button = questdlg(sprintf('There are %d ROIs found\nWould you like to use them one by one or as one combined area?',numel(roi_list)-1),'ROI selection','One by One','Combine','Cancel','One by One');
            if strcmp('Cancel',button); return;
            elseif strcmp('Combine',button) % combine ROI into one
                start_no = 0;
                end_no = 0;
            elseif strcmp('One by One',button) % do ROI one by one
                start_no = 1;
                end_no = numel(roi_list)-1;
            end
        end
        num_of_roi = end_no-start_no+1;
        
        granularity = zeros(num_of_roi,1,size(handles.Img{handles.Id}.I.img,4));
        roi_size = zeros(num_of_roi,1);
        corr_coef = zeros(num_of_roi,1,size(handles.Img{handles.Id}.I.img,4),manders_par);
        smooth_corr = zeros(1,1,size(handles.Img{handles.Id}.I.img,4),manders_par);
        
        for i=start_no:end_no
            waitbar(i/num_of_roi,wb);
            
            mask = handles.Img{handles.Id}.I.hROI.returnMask(i, size(handles.Img{handles.Id}.I.img,1), size(handles.Img{handles.Id}.I.img,2), handles.Img{handles.Id}.I.orientation);
            % crop image only to the region of interest
            STATS = regionprops(mask, 'BoundingBox');
            for stat_element = 1:numel(STATS)
                w1_vec(stat_element) = round(STATS(stat_element).BoundingBox(1));
                w2_vec(stat_element) = round(STATS(stat_element).BoundingBox(1))+STATS(stat_element).BoundingBox(3)-1;
                h1_vec(stat_element) = round(STATS(stat_element).BoundingBox(2));
                h2_vec(stat_element) = round(STATS(stat_element).BoundingBox(2))+STATS(stat_element).BoundingBox(4)-1;
            end
            w1 = min(w1_vec);
            w2 = max(w2_vec);
            h1 = min(h1_vec);
            h2 = max(h2_vec);
            if get(handles.corrMaskRadio,'Value')    % use predefined mask
                [corr_coef(i-start_no+1,1,:,:), handles.Img{handles.Id}.I.model(h1:h2,w1:w2,:), ~, smooth_corr(i-start_no+1,1,:,:), granularity(i-start_no+1,1,:),roi_size(i-start_no+1,1)] = ...
                    calc_correlation(handles.Img{handles.Id}.I.img(h1:h2,w1:w2,:,:), mask(h1:h2,w1:w2), mode, type, slope_length, darkthres, dt, auto_thres, inv_sw, a_contrast, relative_to_frame, handles.Img{handles.Id}.I.maskImg(h1:h2,w1:w2,:));
            else
                [corr_coef(i-start_no+1,1,:,:), handles.Img{handles.Id}.I.model(h1:h2,w1:w2,:), handles.Img{handles.Id}.I.maskImg(h1:h2,w1:w2,:), smooth_corr(i-start_no+1,1,:,:), granularity(i-start_no+1,1,:),roi_size(i-start_no+1,1)] = ...
                    calc_correlation(handles.Img{handles.Id}.I.img(h1:h2,w1:w2,:,:), mask(h1:h2,w1:w2), mode, type, slope_length, darkthres, dt, auto_thres, inv_sw, a_contrast, relative_to_frame);
            end
        end
        
    end
else    % do grid run
    gridsize = handles.corrGridrunSize;
    if get(handles.roiShowCheck,'Value') == 1
        mask = handles.Img{handles.Id}.I.hROI.returnMask(selected_roi, size(handles.Img{handles.Id}.I.img,1), size(handles.Img{handles.Id}.I.img,2), handles.Img{handles.Id}.I.orientation);
        %if max(max(mask)) == 0  % when no ROI present
        %    mask(:,:) = 1;
        %end
    else
        mask = zeros(size(handles.Img{handles.Id}.I.img,1), size(handles.Img{handles.Id}.I.img,2),'uint8')+1;
    end
    % crop image only to the region of interest
    STATS = regionprops(mask, 'BoundingBox');
    for stat_element = 1:numel(STATS)
        w1_vec(stat_element) = round(STATS(stat_element).BoundingBox(1));
        w2_vec(stat_element) = round(STATS(stat_element).BoundingBox(1))+STATS(stat_element).BoundingBox(3)-1;
        h1_vec(stat_element) = round(STATS(stat_element).BoundingBox(2));
        h2_vec(stat_element) = round(STATS(stat_element).BoundingBox(2))+STATS(stat_element).BoundingBox(4)-1;
    end
    w1 = min(w1_vec);
    w2 = max(w2_vec);
    h1 = min(h1_vec);
    h2 = max(h2_vec);
    width = w2-w1+1;
    height = h2-h1+1;
    
    button = questdlg('Would you like to have grid dimensions of the exact size?','Grid size','Floating','Exact','Exact');
    if strcmp(button,'Floating')
        [bl_w, bl_h] = generate_grid_block_size(width, height,gridsize);
    else
        bl_w = gridsize;
        bl_h = gridsize;
    end
    disp(['Area Width=' num2str(width) ' Height=' num2str(height) '; Block size: Width=' num2str(bl_w) ' Height=' num2str(bl_h)]);
    
    
    corr_coef = zeros(ceil(height/bl_h),ceil(width/bl_w),size(handles.Img{handles.Id}.I.img,4),manders_par);
    smooth_corr = zeros(ceil(height/bl_h),ceil(width/bl_w),size(handles.Img{handles.Id}.I.img,4),manders_par);
    granularity = zeros(ceil(height/bl_h),ceil(width/bl_w),size(handles.Img{handles.Id}.I.img,4));
    roi_size = zeros(ceil(height/bl_h),ceil(width/bl_w));
    
    ind_y = 1;
    index = 1;
    max_ind = ceil(height/bl_h)*ceil(width/bl_w);
    for y_pos=h1:bl_h:h2   % cycling
        ind_x = 1;
        y_pos2 = y_pos + bl_h - 1;
        if y_pos2 > h2; y_pos2 = h2; end;
        if y_pos == h2; continue; end;
        for x_pos=w1:bl_w:w2
            waitbar(index/max_ind,wb);
            x_pos2 = x_pos + bl_w - 1;
            if x_pos2 > w2; x_pos2 = w2; end;
            if x_pos == w2; continue; end;
            %thresholds(y_pos:y_pos2,x_pos:x_pos2)=auto_threshold;
            if sum(sum(mask(y_pos:y_pos2,x_pos:x_pos2)))/(bl_w*bl_h) < 0.5  % do not calculate those where the mask is less than 50%
                corr_coef(ind_y,ind_x,:,:) = 0; %$zeros(handles.Img{handles.Id}.I.no_stacks,1)-1;
                smooth_corr(ind_y,ind_x,:,:) = 0; %zeros(handles.Img{handles.Id}.I.no_stacks,2)-1;
                granularity(ind_y,ind_x,:) = 0; %zeros(handles.Img{handles.Id}.I.no_stacks,1)-1;
                ind_x = ind_x + 1;
                continue
            end;
            
            handles.Img{handles.Id}.I.selection(y_pos:y_pos2,x_pos,:) = 1;
            handles.Img{handles.Id}.I.selection(y_pos:y_pos2,x_pos2,:) = 1;
            handles.Img{handles.Id}.I.selection(y_pos,x_pos:x_pos2,:) = 1;
            handles.Img{handles.Id}.I.selection(y_pos2,x_pos:x_pos2,:) = 1;
            
            if get(handles.corrMaskRadio,'Value')    % use predefined mask
                [corr_coef(ind_y,ind_x,:,:), handles.Img{handles.Id}.I.model(y_pos:y_pos2,x_pos:x_pos2,:), ~, smooth_corr(ind_y,ind_x,:,:), granularity(ind_y,ind_x,:),roi_size(ind_y,ind_x)] = ...
                    calc_correlation(handles.Img{handles.Id}.I.img(y_pos:y_pos2,x_pos:x_pos2,:,:), mask(y_pos:y_pos2,x_pos:x_pos2), mode, type, slope_length, darkthres, dt, auto_thres, inv_sw, a_contrast, relative_to_frame, handles.Img{handles.Id}.I.maskImg(y_pos:y_pos2,x_pos:x_pos2,:));
            else
                [corr_coef(ind_y,ind_x,:,:), handles.Img{handles.Id}.I.model(y_pos:y_pos2,x_pos:x_pos2,:), handles.Img{handles.Id}.I.maskImg(y_pos:y_pos2,x_pos:x_pos2,:), smooth_corr(ind_y,ind_x,:,:), granularity(ind_y,ind_x,:),roi_size(ind_y,ind_x)] = ...
                    calc_correlation(handles.Img{handles.Id}.I.img(y_pos:y_pos2,x_pos:x_pos2,:,:), mask(y_pos:y_pos2,x_pos:x_pos2), mode, type, slope_length, darkthres, dt, auto_thres, inv_sw, a_contrast, relative_to_frame);
            end
            ind_x = ind_x + 1;
            index = index + 1;
        end
        ind_y = ind_y + 1;
    end
end
delete(wb);
handles.Img{handles.Id}.I.model_type = 'int8';
handles.Img{handles.Id}.I.model_diff_max = max(max(abs(handles.Img{handles.Id}.I.model)));
toc
set(handles.modelShowCheck,'Value',1);
%resize = 0;
%handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, resize);
%guidata(handles.im_browser, handles);
if inv_sw
    mode = {[cell2mat(mode) ' Inv.']};
end;

strOut.corr_coef = corr_coef;
strOut.smooth_corr = smooth_corr;
strOut.granularity = granularity;
strOut.roi_size = roi_size;
strOut.dt = handles.Img{handles.Id}.I.pixSize.t;
strOut.type = type;
strOut.mode = mode;

choice = questdlg('Would you like to save results, or to see them by running correlationAnalysis_script.m file?', ...
    'What next?','Take a look','Save','Both','Take a look');
if strcmp(choice,'Save') | strcmp(choice,'Both')    %#ok<OR2> % do saving first
    fn_out = handles.Img{handles.Id}.I.img_info('Filename');
    if isempty(fn_out)
        fn_out = handles.mypath;
    else
        dots = strfind(fn_out,'.');
        fn_out = fn_out(1:dots(end)-1);
    end
    [filename, path] = uiputfile(...
        {'*.mat;',  'Matlab format (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Provide a template for saving...',fn_out);
    if ~isequal(filename,0)
        fn = [path filename];
        save(fn, '-struct','strOut','-v7');
        disp(['Status: ' fn ' was created']);
        
        fn = [path filename(1:end-3) 'xls'];
        file_exist = '';
        if exist(fn,'file') == 2; file_exist = 'Note! the existing file will be erased!'; end
        
        if ~grid_run_sw
            choice2 = questdlg(sprintf('Would you like to generate file for Excel?\n\n%s\n%s', fn, file_exist), ...
                'Export to Excel','Yes','No','No');
            if strcmp(choice2,'Yes')    % generating XLS file
                if exist(fn,'file') == 2; delete(fn); end; % delete exising file
                warning off MATLAB:xlswrite:AddSheet
                
                frame_vec = 1:size(corr_coef,3);
                s = {'Correlation coef. calculation'};
                s(2,1) = {['Filename: ' handles.Img{handles.Id}.I.img_info('Filename')]};
                s(3,1) = {['Time between points: ' num2str(strOut.dt)]};
                s(4,1) = {[cell2mat(type) ' correlation coef (' cell2mat(mode) ' mode):']};
                if strcmp(type,'Manders')
                    shift_coef = 2;
                    s(5,1) = {'First Manders coefficient Current vs. Relative; Second: Relative vs Current'};
                else
                    shift_coef = 1;
                end
                s(7,1) = {'Frame no:'};
                s(7,2:size(corr_coef,3)+1) = num2cell(frame_vec);
                for roi=1:size(corr_coef,1)
                    s((roi-1)*shift_coef+8,1) = {['ROI' num2str(roi) ' (' num2str(roi_size(roi,1)) ' pix)']};
                    s((roi-1)*shift_coef+8,2:size(corr_coef,3)+1) = num2cell(corr_coef(roi,1,:,1));
                    if strcmp(type,'Manders')
                        s((roi-1)*shift_coef+9,2:size(corr_coef,3)+1) = num2cell(corr_coef(roi,1,:,2));
                    end
                end
                xlswrite(fn, s, 'Sheet1', 'A1');
                s(4,1) = {['Correlation smoothed, window length: ' num2str(slope_length) ' frames']};
                for roi=1:size(corr_coef,1)
                    s((roi-1)*shift_coef+8,1) = {['ROI' num2str(roi) ' (' num2str(roi_size(roi,1)) ' pix)']};
                    s((roi-1)*shift_coef+8,2:size(corr_coef,3)+1) = num2cell(smooth_corr(roi,1,:,1));
                    if strcmp(type,'Manders')
                        s((roi-1)*shift_coef+9,2:size(corr_coef,3)+1) = num2cell(smooth_corr(roi,1,:,2));
                    end
                end
                xlswrite(fn, s, 'Sheet2', 'A1');
                s(4,1) = {'Correlation granularity:'};
                s(8:end,1:end) = cellstr('');
                for roi=1:size(corr_coef,1)
                    s(roi+7,1) = {['ROI' num2str(roi) ' (' num2str(roi_size(roi,1)) ' pix)']};
                    s(roi+7,2:size(corr_coef,3)+1) = num2cell(granularity(roi,1,:));
                end
                xlswrite(fn, s, 'Sheet3', 'A1');
                disp(['Status: ' fn ' was created']);
            end
        end
    end
end
if strcmp(choice,'Take a look') | strcmp(choice,'Both')    %#ok<OR2> % starting the analysis script
    correlationAnalysis_script(corr_coef, smooth_corr, granularity, roi_size, handles.Img{handles.Id}.I.pixSize.t, type, mode, slope_length);  % script for additional analysis
end
assignin('base','IM_corrcoef',strOut);
disp('''IM_corrcoef'' structure with results has been created in the Matlab workspace');

end