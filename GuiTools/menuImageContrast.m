function menuImageContrast(hObject, eventdata, handles, parameter)
% function menuImageContrast(hObject, eventdata, handles, parameter)
% a callback to Menu->Image->Contrast
% do contrast enhancement
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% parameter: a string that defines image source:
% - ''linear'', linear contrast adjustments
% - ''CLAHE_2D'', contrast adjustment with CLAHE method for the current slice
% - ''CLAHE_3D'', contrast adjustment with CLAHE method for the shown stack
% - ''CLAHE_4D'', contrast adjustment with CLAHE method for the whole dataset
% - ''NormalizeZ'', normalize layers in the Z-dimension using intensity analysis of complete slices
% - ''NormalizeT'', normalize layers in the Time-dimensionusing intensity analysis of complete slices
% - ''NormalizeMask'', normalize layers using intensity analysis of complete slices
% - ''NormalizeBg'', normalize layers using intensity analysis of complete slices

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 06.04.2016, IB added NormalizeZ and NormalizeT modes


switch parameter
    case 'linear'
        % Contrast button callback
        handles = ib_linearContrast(handles);
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    case {'CLAHE_2D', 'CLAHE_3D', 'CLAHE_4D'}
        mib_contrastContext_cb(handles.contrastBtn,eventdata, parameter);
    case 'NormalizeZ'
        handles = ib_contrastNormalizationMemoryOptimized(handles, 'normalZ');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    case 'NormalizeT'
        if handles.Img{handles.Id}.I.time == 1
            errordlg(sprintf('!!! Error !!!\n\nThe time series normalization requires more than one time point!\nTry Z-stack normalization instead'))
            return;
        end
        handles = ib_contrastNormalizationMemoryOptimized(handles, 'normalT');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);        
    case 'NormalizeMask'
        handles = ib_contrastNormalizationMemoryOptimized(handles, 'mask');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    case 'NormalizeBg'
        handles = ib_contrastNormalizationMemoryOptimized(handles, 'bgMean');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
end