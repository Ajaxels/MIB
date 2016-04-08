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
% 


options.par1 = '';
if get(handles.ColChannelCombo,'Value') - 1 == 0
    msgbox('Please select a color channel!','Error!','error','modal');
    return;
end
if handles.Img{handles.Id}.I.time > 1
    msgbox(sprintf('Unfortunately the alignment tool is not compatible with 5D datasets!\nLet us know if you need it!\nhttp:\\mib.helsinki.fi'),'Error!','error','modal');
    return;
end
[res, res2] = alignDatasetsDlg(handles, options);
%toolbar_zoomBtn(handles.fitPush, eventdata, handles);
handles = guidata(hObject);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
end