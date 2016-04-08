function channelMixerTable_CellSelectionCallback(hObject, eventdata, handles)
% function channelMixerTable_CellSelectionCallback(hObject, eventdata, handles)
% A cell selection callback function function for the handles.ib_channelMixerTable table.
%
% hObject    handle to channelMixerTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Copyright (C) 22.04.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if isempty(eventdata.Indices); return; end;
set(handles.channelMixerTable,'userdata', eventdata.Indices);   % store selected position

if eventdata.Indices(1,2) == 3 % start color selection dialog
    if get(handles.lutCheckbox,'value')==0
        warndlg(sprintf('The colors for the color channels may be selected only in the LUT mode!\n\nTo enable the LUT mode please select the LUT checkbox\n(View Settings Panel->LUT checkbox)'),'Warning!');
        return;
    end
    figTitle = ['Set color for channel ' num2str(eventdata.Indices(1))];
    c = uisetcolor(handles.Img{handles.Id}.I.lutColors(eventdata.Indices(1),:), figTitle);
    if length(c) == 1; return; end;
    handles.Img{handles.Id}.I.lutColors(eventdata.Indices(1),:) = c;
    handles = updateGuiWidgets(handles);
    % redraw image in the im_browser axes
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
% elseif eventdata.Indices(1,2) == 2 % toggle between two color channels using the Ctrl modifier
%     if strcmp(get(handles.im_browser,'currentModifier'), 'control') 
%         data = get(handles.channelMixerTable,'data');
%         for i=1:size(data,1);        data{i,2} = 0;    end;    % clear selected channels
%         data{eventdata.Indices(1,1),2} = true;
%         set(handles.channelMixerTable,'data', data);
%         % redraw image in the im_browser axes
%         handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
%     else
%         % Update handles structure
%         guidata(handles.im_browser, handles);
%     end
else
    % Update handles structure
    guidata(handles.im_browser, handles);
end
end