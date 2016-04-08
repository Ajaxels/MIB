function roiRemoveBtn_Callback(hObject, eventdata, handles)
% function roiRemoveBtn_Callback(hObject, eventdata, handles)
% a callback to the handles.roiRemoveBtn, removes selected roi from a list of rois
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
% 07.04.2015, Ilya Belevich, ilya.belevich @ helsinki.fi

% Remove selected ROI
roiString = get(handles.roiList,'String');
roiValue = get(handles.roiList,'Value');
currentVal = roiString{roiValue};

index = handles.Img{handles.Id}.I.hROI.findIndexByLabel(currentVal);
if roiValue == 1 
    button = questdlg(sprintf('!!! Warning !!!\nYou are going to delete all ROIs\nAre you sure?'),'Delete ROIs!','Delete','Cancel','Cancel');
    if strcmp(button, 'Cancel'); return; end;
else
    button = questdlg(sprintf('You are going to delete\nROI region with label "%s"\nAre you sure?', cell2mat(handles.Img{handles.Id}.I.hROI.Data(index).label)),'Delete ROIs!','Delete','Cancel','Cancel');
    if strcmp(button, 'Cancel'); return; end;
end
set(handles.roiList,'Value',1);
handles.Img{handles.Id}.I.hROI.removeROI(index);

% update roiList
[number, indices] = handles.Img{handles.Id}.I.hROI.getNumberOfROI();
str2 = cell([number+1 1]);
str2(1) = cellstr('All');
for i=1:number
    %    str2(i+1) = cellstr(num2str(indices(i)));
    str2(i+1) = handles.Img{handles.Id}.I.hROI.Data(indices(i)).label;
end
set(handles.roiList,'String',str2);

set(handles.roiList,'Value',1);
if handles.Img{handles.Id}.I.hROI.getNumberOfROI(0) == 0; set(handles.roiShowCheck,'Value',0); end;
roiShowCheck_Callback(handles.roiShowCheck, eventdata, handles);
end