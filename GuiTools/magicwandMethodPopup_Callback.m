% --- Executes on selection change in magicwandMethodPopup.
function magicwandMethodPopup_Callback(hObject, eventdata, handles)
% function magicwandMethodPopup_Callback(hObject, eventdata, handles)
% a callback to the handles.magicwandMethodPopup, allowing selection of method for the MagicWand-RegionGrowing tool
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 20.08.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


method = get(handles.magicwandMethodPopup, 'value');
if method ==1   % magic wand
    set(handles.magicupthresEdit, 'visible', 'on');
    set(handles.magicdashTxt, 'visible', 'on');
    set(handles.magicupthresEdit, 'visible', 'on');
    %set(handles.magicwandRadiusText, 'visible', 'on');
    %set(handles.magicWandRadius, 'visible', 'on');
    set(handles.magicwandConnectCheck, 'visible', 'on');
    set(handles.magicwandConnectCheck4, 'visible', 'on');
    set(handles.magicwandConnectText, 'visible', 'on');
else            % region growing
    set(handles.magicupthresEdit, 'visible', 'off');
    set(handles.magicdashTxt, 'visible', 'off');
    set(handles.magicupthresEdit, 'visible', 'off');
    %set(handles.magicwandRadiusText, 'visible', 'off');
    %set(handles.magicWandRadius, 'visible', 'off');
    set(handles.magicwandConnectCheck, 'visible', 'off');
    set(handles.magicwandConnectCheck4, 'visible', 'off');
    set(handles.magicwandConnectText, 'visible', 'off');
end

end