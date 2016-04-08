function menuDatasetSlice(hObject, eventdata, handles, parameter)
% function menuDatasetSlice(hObject, eventdata, handles, parameter)
% a callback to Menu->Dataset->Slice
% do actions with individual slices
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m
% parameter: a string that defines image source:
% - 'deleteSlice', delete slice (a section from a Z-stack) from the dataset
% - 'deleteFrame', delete frame (a section from a time series) from the dataset

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


switch parameter
    case 'deleteSlice'
        currentSlice = handles.Img{handles.Id}.I.getCurrentSliceNumber();
        maxSlice = size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation);

        answer=mib_inputdlg(NaN,sprintf('Please enter slice number(s) to delete (1:%d):',maxSlice),'Enter slice number',num2str(currentSlice));
        if isempty(answer); return; end;
        orient = handles.Img{handles.Id}.I.orientation;
        result = handles.Img{handles.Id}.I.deleteSlice(str2num(answer{1}), orient); %#ok<ST2NM>
        if result == 0; return; end;
        % generate the log text
        log_text = sprintf('Delete slice: %s, Orient: %d', answer{1}, orient);
    case 'deleteFrame'
        currentSlice = handles.Img{handles.Id}.I.slices{5}(1);
        maxSlice = handles.Img{handles.Id}.I.time;
        if maxSlice == 1; return; end;
        
        answer=mib_inputdlg(NaN,sprintf('Please enter frame number(s) to delete (1:%d):',maxSlice),'Enter slice number',num2str(currentSlice));
        if isempty(answer); return; end;

        orient = 5;
        result = handles.Img{handles.Id}.I.deleteSlice(str2num(answer{1}), orient); %#ok<ST2NM>
        if result == 0; return; end;
        % generate the log text
        log_text = sprintf('Delete frame: %s, Orient: %d', answer{1}, orient);
end

handles.Img{handles.Id}.I.updateImgInfo(log_text);
% update widgets in the im_browser GUI
handles = updateGuiWidgets(handles);
% redraw image in the im_browser axes
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end