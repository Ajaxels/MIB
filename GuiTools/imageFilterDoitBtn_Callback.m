function imageFilterDoitBtn_Callback(hObject, eventdata, handles)
% function imageFilterDoitBtn_Callback(hObject, eventdata, handles)
% a callback to the handles.imageFilterDoitBtn, filters image with the selected filter
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 03.09.2015, Ilya Belevich, updated to use imageData.getData3D methods in ib_getDataset
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

filter_val = get(handles.imageFilterPopup,'Value');
filter_list = get(handles.imageFilterPopup,'String');

switch filter_list{filter_val}
    case 'Edge Enhancing Coherence Filter'
        handles = ib_anisotropicDiffusion(handles, 'coherence_filter');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        return;
    case 'Perona Malik anisotropic diffusion'
        handles = ib_anisotropicDiffusion(handles, 'anisodiff');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        return;
    case {'Diplib: Perona Malik anisotropic diffusion','Diplib: Robust Anisotropic Diffusion','Diplib: Mean Curvature Diffusion',...
            'Diplib: Corner Preserving Diffusion','Diplib: Kuwahara filter for edge-preserving smoothing'}
        handles = ib_anisotropicDiffusion(handles, 'diplib');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        return;
end

% define strel size
hsize_txt = get(handles.imfiltPar1Edit,'String');
semicolon = strfind(hsize_txt,';');
if ~isempty(semicolon)
    hsize(1) = str2double(hsize_txt(1:semicolon(1)-1));
    hsize(2) = str2double(hsize_txt(semicolon(1)+1:end));
else
    dashsign = strfind(hsize_txt,'-');
    if ~isempty(dashsign)
        hsize(1) = str2double(hsize_txt(1:dashsign(1)-1));
        hsize(2) = str2double(hsize_txt(dashsign(1)+1:end));
    else
        hsize(1) = str2double(hsize_txt);
        hsize(2) = hsize(1);    
    end
end

% define mode to apply a filter:
% 2D, shown slice
% 3D, current stack
% 4D, complete volume
mode = get(handles.imageFiltersMode, 'string');
mode = mode{get(handles.imageFiltersMode, 'value')};
if handles.Img{handles.Id}.I.time == 1 && strcmp(mode, '4D, complete volume')
    mode = '3D, current stack';
end

% define what to do with the filtered image:
% Apply filter
% Apply and add to the image
% Apply and subtract from the image
doAfter = get(handles.imageFiltersOptions, 'string');
doAfter = doAfter{get(handles.imageFiltersOptions, 'value')};

options.dataType = '4D';    % 4D means that there are 4 dimensions in the dataset (h,w,c,z) to separate with selection, where it is only 3 (h,w,z)
options.fitType = cell2mat(filter_list(filter_val));

%options.colorChannel = get(handles.ColChannelCombo,'Value')-1;
if numel(handles.Img{handles.Id}.I.slices{3}) ~= 1    % get color channel from the selected in the Selection panel
    options.colorChannel = get(handles.ColChannelCombo,'Value') - 1;
else    % when only one color channel is shown, take it
    options.colorChannel = handles.Img{handles.Id}.I.slices{3};
end

if strcmp(get(handles.imfiltPar1Edit,'enable'), 'on')
    options.hSize = hsize;
end
if strcmp(get(handles.imfiltPar2Edit,'Enable'), 'on'); options.sigma = str2double(get(handles.imfiltPar2Edit,'String'));  end;
if strcmp(get(handles.imfiltPar3Edit,'Enable'), 'on'); options.lambda = str2double(get(handles.imfiltPar3Edit,'String')); end;
if strcmp(get(handles.imfiltPar4Edit,'Enable'), 'on'); options.beta2 = str2double(get(handles.imfiltPar4Edit,'String')); end;
if strcmp(get(handles.imfiltPar5Edit,'Enable'), 'on'); options.beta3 = str2double(get(handles.imfiltPar5Edit,'String')); end;
if strcmp(get(handles.andiffPopupFavours,'Enable'), 'on');
    if get(handles.andiffPopupFavours,'value') == 1
        options.BlackWhite = 1; 
    else
        options.BlackWhite = 0; 
    end;
end

options.pixSize = handles.Img{handles.Id}.I.pixSize;    % for 3D gaussian filter
if get(handles.roiShowCheck, 'value')   % when ROI mode is on, the returned dataset is transposed
    options.orientation = 4;
else
    options.orientation = handles.Img{handles.Id}.I.orientation;
end

showWaitbarLocal = 0;
if strcmp(mode, '4D, complete volume')
    timeVector = [1, handles.Img{handles.Id}.I.time];
    options.showWaitbar = 0;    % do not show waitbar in the filtering function
    showWaitbarLocal = 1;
    wb = waitbar(0,['Applying ' options.fitType ' filter...'],'Name','Filtering','WindowStyle','modal');
elseif strcmp(mode, '3D, current stack')
    ib_do_backup(handles, 'image', 1);
    timeVector = [handles.Img{handles.Id}.I.getCurrentTimePoint(), handles.Img{handles.Id}.I.getCurrentTimePoint()];
else
    ib_do_backup(handles, 'image', 0);
    timeVector = [handles.Img{handles.Id}.I.getCurrentTimePoint(), handles.Img{handles.Id}.I.getCurrentTimePoint()];
end

for t=timeVector(1):timeVector(2)
    if ~strcmp(mode, '2D, shown slice')
        img = ib_getStack('image', handles, t, 0, options.colorChannel);
    else
        getDataOptions.t = [t t];
        img = ib_getSlice('image', handles, handles.Img{handles.Id}.I.getCurrentSliceNumber(), NaN, options.colorChannel, getDataOptions);        
    end
    
    for roi = 1:numel(img)
        switch doAfter
            case 'Apply filter'
                [img{roi}, log_text] = ib_doImageFiltering(img{roi}, options);
            case 'Apply and add to the image'
                [imgOut, log_text] = ib_doImageFiltering(img{roi}, options);
                img{roi} = img{roi}+imgOut;
            case 'Apply and subtract from the image'
                [imgOut, log_text] = ib_doImageFiltering(img{roi}, options);
                img{roi} = img{roi}-imgOut;
        end
    end
    
    if ~strcmp(mode, '2D, shown slice')
        ib_setStack('image', img, handles, t, 0, options.colorChannel);
    else
        ib_setSlice('image', img, handles, handles.Img{handles.Id}.I.getCurrentSliceNumber(), NaN, options.colorChannel, getDataOptions);
    end
    if showWaitbarLocal == 1
        waitbar(t/(timeVector(2)-timeVector(1)),wb);
    end
end

log_text = sprintf('%s, Mode:%s, Options:%s', log_text, mode, doAfter);
if strcmp(mode, '2D, shown slice')
    log_text = [log_text ',slice=' num2str(handles.Img{handles.Id}.I.getCurrentSliceNumber())];
end
if showWaitbarLocal == 1
    delete(wb);
end
if isnan(log_text); return; end;
handles.Img{handles.Id}.I.updateImgInfo(log_text);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);

end