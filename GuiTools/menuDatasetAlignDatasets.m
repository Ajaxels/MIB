function menuDatasetAlignDatasets(hObject, eventdata, handles)
% function menuDatasetAlignDatasets(hObject, eventdata, handles)
% a callback to Menu->Dataset->Alignment tool
% align the dataset or stitch several datasets
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 15.09.2016 updated for the new alignment tool

if handles.Img{handles.Id}.I.time > 1
    msgbox(sprintf('Unfortunately the alignment tool is not compatible with 5D datasets!\nLet us know if you need it!\nhttp:\\mib.helsinki.fi'),'Error!','error','modal');
    return;
end

imgOut = mib_DriftAlignDlg(handles.Img{handles.Id}.I, handles.preferences.Font);
if isempty(imgOut); return; end;

handles.U.clearContents();  % clear Undo history

% handles.Img{handles.Id}.I  = copy(imgOut);
% handles.Img{handles.Id}.I.img_info  = containers.Map(keys(imgOut.img_info), values(imgOut.img_info));  % make a copy of img_info containers.Map
% handles.Img{handles.Id}.I.hROI  = copy(imgOut.I.hROI);
% handles.Img{handles.Id}.I.hROI.hImg = imgOut;  % need to copy a handle of imageData class to a copy of the roiRegion class
% handles.Img{handles.Id}.I.hLabels  = copy(imgOut.hLabels);
% handles.Img{handles.Id}.I.hMeasure  = copy(imgOut.hMeasure);

% update axes to show the resized image
handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
handles = updateGuiWidgets(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end