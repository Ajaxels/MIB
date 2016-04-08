function im_browser_brush_scrollWheelFcn(hObject, eventdata, handles)
% function im_browser_brush_scrollWheelFcn(hObject, eventdata, handles)
% Control callbacks from mouse scroll wheel during the brush tool
%
%
% Parameters:
% hObject: a handle to the object from where the call was implemented
% eventdata: additinal parameters
% handles: structure with handles of im_browser.m

% Copyright (C) 08.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


handles = guidata(handles.im_browser);  % update handles structure

modifier = get(handles.im_browser,'currentmodifier');   % change size of the brush tool, when the Ctrl key is pressed

step = .2;   % step of the brush size change
if strcmp(cell2mat(modifier), 'shift')
    step = 1;
elseif strcmp(cell2mat(modifier), 'shiftcontrol')
    step = 5;
end;

if eventdata.VerticalScrollCount < 0
    handles.Img{handles.Id}.I.brush_selection{3}.factor = handles.Img{handles.Id}.I.brush_selection{3}.factor + step;
else
    handles.Img{handles.Id}.I.brush_selection{3}.factor = handles.Img{handles.Id}.I.brush_selection{3}.factor - step;
    if handles.Img{handles.Id}.I.brush_selection{3}.factor < 0; handles.Img{handles.Id}.I.brush_selection{3}.factor = 0.1; end;
end
set(handles.dilateAdaptCoefEdit, 'string', num2str(handles.Img{handles.Id}.I.brush_selection{3}.factor));

% labelObj = handles.Img{handles.Id}.I.brush_selection{3}.labelObj;
% allShortest = handles.Img{handles.Id}.I.brush_selection{3}.allShortest(:,labelObj);
% [idx1, idx2] = find(allShortest <= handles.Img{handles.Id}.I.brush_selection{3}.std*handles.Img{handles.Id}.I.brush_selection{3}.factor);
% 
% handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic = logical(zeros(size(handles.Img{handles.Id}.I.brush_selection{1})));
% handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic(ismember(handles.Img{handles.Id}.I.brush_selection{2}.slic, idx1)) = 1;
% 
% CData = handles.Img{handles.Id}.I.brush_selection{3}.CData;
% CData(handles.Img{handles.Id}.I.brush_selection{2}.selectedSlic==1) = intmax(class(handles.Img{handles.Id}.I.Ishown))*.4;
% set(handles.Img{handles.Id}.I.imh,'CData',CData);
end