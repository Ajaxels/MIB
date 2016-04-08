function ib_channelMixerTable_Callback(hObject, eventdata, handles, type)
% function ib_channelMixerTable_Callback(hObject, eventdata, handles, type)
% A callback function for the handles.ib_channelMixerTable table.
%
% Duplicates action of the Menu->Image->Color channels entry
%
% Parameters:
% hObject: handle of a calling object
% eventdata: not used
% handles: handle structure of im_browser, not used because it is updated by the @em guidata function
% type: a string that defines required action
% - ''insert'', insert an empty color channel to the specified position
% - ''copy'' - copy color channel to a new channel, same as Menu->Image->Color channels->Copy channel...
% - ''invert'' - invert color channel, same as Menu->Image->Color channels->Invert channel...
% - ''swap'' - swap two color channels, same as Menu->Image->Color channels->Swap channels...
% - ''delete'' - delete color channel, same as Menu->Image->Color channels->Delete channel...
% - ''set color'' - set color to show the channel when the LUT mode (View Settings->Colors->LUT) is enabled.
%
% Return values:

%| @b Examples:
% @code ib_channelMixerTable_Callback(handles.channelMixerTable, NaN, NaN, 'invert');     // invert the selected channel  @endcode
% @code ib_channelMixerTable_Callback(handles.channelMixerTable, NaN, NaN, 'set color');     // set color for the selected channel @endcode

% Copyright (C) 05.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 04.02.2016, IB, added insert empty color channel option


handles = guidata(hObject);
if isempty(get(handles.channelMixerTable, 'userdata'))
    errordlg(sprintf('The color channel was not selected!\n\nPlease select it in the View Settings->Colors table with the left mouse button and try again.'),'Wrong selection');
    return;
end
rawId = get(handles.channelMixerTable, 'userdata');
if size(rawId,1) > 1
    errordlg(sprintf('Multiple color channels are selected!\n\nPlease select only one channel in the View Settings->Colors table with the left mouse button and try again.'),'Wrong selection');
    return;
end

ib_do_backup(handles, 'image', 1);

rawId = rawId(1,1);
switch type
    case 'insert'
        handles.Img{handles.Id}.I.insertEmptyColorChannel(rawId+1);
        handles = updateGuiWidgets(handles);
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
    case 'copy'
        handles.Img{handles.Id}.I.copyColorChannel(rawId);
        handles = updateGuiWidgets(handles);
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
    case 'invert'
        % invert specified color channel
        if handles.Img{handles.Id}.I.time < 2; ib_do_backup(handles, 'image', 1); end;
        handles.Img{handles.Id}.I.invertColorChannel(rawId);
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
    case 'swap'
        if handles.Img{handles.Id}.I.time < 2; ib_do_backup(handles, 'image', 1); end;
        handles.Img{handles.Id}.I.swapColorChannels(rawId);
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
    case 'delete'
        % Delete color channel from the Image layer
        handles.Img{handles.Id}.I.deleteColorChannel(rawId);
        handles = updateGuiWidgets(handles);
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
    case 'set color'
        eventdata.Indices = [rawId, 3];
        channelMixerTable_CellSelectionCallback(handles.channelMixerTable, eventdata, handles);
end

end