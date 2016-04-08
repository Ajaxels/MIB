function createModelBtn_Callback(hObject, eventdata, handles)
% function createModelBtn_Callback(~, ~, handles)
% Create Model
%
% Parameters:
% hObject: a handle to the calling object
% eventdata: eventdata structure of Matlab
% handles: handles structure of im_browser.m

% Copyright (C) 21.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); 
    warndlg(sprintf('The models are switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The models are disabled','modal');
    return; 
end;

if handles.Img{handles.Id}.I.modelExist == 1
    button = questdlg(sprintf('Warning!\nYou are about to start a new model,\n the existing model will be deleted!\n\n'),'Start new model','Continue','Cancel','Cancel');
    if strcmp(button, 'Cancel'); return; end;
end

if handles.preferences.uint8
    handles.Img{handles.Id}.I.createModel('uint8');
else
    handles.Img{handles.Id}.I.createModel('uint6');
end
handles.lastSegmSelection = 1;
updateSegmentationLists(handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
set(handles.modelShowCheck,'Value',1);
set(handles.segmAddList,'Value',2);
end