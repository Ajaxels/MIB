function im_browser_PanelShiftBtnUpFcn(hObject, eventdata, handles)
% function im_browser_PanelShiftBtnUpFcn(hObject, eventdata, handles)
% this is callback for the release of a mouse button over
% handles.separatingPanel to change size of Directory contents and
% Segmentation panels
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles of im_browser.m

% Copyright (C) 23.12.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

position = get(handles.im_browser,'currentpoint');  % get position of the cursor
separatingPanelPos = get(handles.separatingPanel, 'position');
rightPanelShift =  position(1,1)-(separatingPanelPos(3))/2;

im_browser_ResizeFcn(0, 0, handles, rightPanelShift);
set(handles.im_browser, 'WindowButtonUpFcn', []);
set(handles.im_browser, 'WindowButtonMotionFcn',{@im_browser_winMouseMotionFcn, handles});
end