function roiList_cm_Callback(hObject, eventdata, parameter)
% function roiList_cm_Callback(hObject, eventdata, parameter)
% a context menu to the to the handles.roiList, the menu is called
% with the right mouse button
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% parameter: - a string that defines options:
% - @li ''rename'' - rename ROI
% - @li ''edit'' - modify ROI
% - @li ''remove'' - remove ROI

% Copyright (C) 07.04.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% generate a dataset from the selected files
handles = guidata(hObject);

roiString = get(handles.roiList,'String');
roiValue = get(handles.roiList,'Value');
currentVal = roiString{roiValue};

if roiValue == 1; return; end;

index = handles.Img{handles.Id}.I.hROI.findIndexByLabel(currentVal);

switch parameter
    case 'rename'  % set brightness on the screen to be the same as in the image
        answer = mib_inputdlg(handles, sprintf('Please add a new name for selected ROI:'), 'Rename ROI', currentVal);
        if isempty(answer); return; end;
        handles.Img{handles.Id}.I.hROI.Data(index).label = answer;
        
        % update roiList
        [number, indices] = handles.Img{handles.Id}.I.hROI.getNumberOfROI();
        str2 = cell([number+1 1]);
        str2(1) = cellstr('All');
        for i=1:number
            %    str2(i+1) = cellstr(num2str(indices(i)));
            str2(i+1) = handles.Img{handles.Id}.I.hROI.Data(indices(i)).label;
        end
        set(handles.roiList,'String',str2);
    case 'edit'
        %axes(handles.imageAxes);
        %drawnow;
        
        %disableSelectionSwitch = handles.preferences.disableSelection;    % get current settings
        %handles.preferences.disableSelection = 'yes'; % disable selection
        %guidata(handles.im_browser, handles);   % store handles
        brushSize = get(handles.segmSpotSizeEdit,'string');
        set(handles.segmSpotSizeEdit,'string', '0');
        set(handles.im_browser, 'WindowKeyPressFcn', []); 
        unFocus(hObject);
        handles.Img{handles.Id}.I.hROI.addROI(handles, [], index);
        %handles.preferences.disableSelection = disableSelectionSwitch;
        set(handles.segmSpotSizeEdit,'string', brushSize);
        set(handles.im_browser, 'WindowKeyPressFcn', {@im_browser_WindowKeyPressFcn, handles}); 
    case 'remove'
        roiRemoveBtn_Callback(handles.roiRemoveBtn, eventdata, handles);
end

handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end