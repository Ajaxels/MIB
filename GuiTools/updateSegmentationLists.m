function updateSegmentationLists(handles)
% function updateSegmentationLists(handles)
% Update Segmetation Lists in the main window of im_browser.m
%
% Parameters:
% handles: structure with handles of im_browser.m

% Copyright (C) 30.04.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if handles.Img{handles.Id}.I.modelExist == 0; handles.Img{handles.Id}.I.modelMaterialNames = {}; end;

max_color = numel(handles.Img{handles.Id}.I.modelMaterialNames);
showVal = get(handles.segmList, 'Value');
addToVal = get(handles.segmAddList, 'Value');
selFromVal = get(handles.segmSelList,'Value');
if max_color > 0
    str1 = handles.Img{handles.Id}.I.modelMaterialNames;
    str2 = [cellstr('All'); cellstr('Ext'); handles.Img{handles.Id}.I.modelMaterialNames];
    str3 = [cellstr('Mask'); cellstr('Ext'); handles.Img{handles.Id}.I.modelMaterialNames];
    for i=1:max_color
        str2(i+2,1) = cellstr(num2str(i));
        str3(i+2,1) = cellstr(num2str(i));
    end
else
    str1 = [];
    str2 = [cellstr('All'); cellstr('Ext')];
    str3 = [cellstr('Mask'); cellstr('Ext')];
end

set(handles.segmList,'String',str1);    % show     
set(handles.segmSelList,'String',str2);    % select from   
set(handles.segmAddList,'String',str3);    % add to    

% update list of materials in the Smart Watershed module
bgVal = get(handles.segmWatershedBgPopup, 'value');
if bgVal > numel(str1); set(handles.segmWatershedBgPopup, 'value', 1); end;
bgVal = get(handles.segmWatershedSignalPopup, 'value');
if bgVal > numel(str1); set(handles.segmWatershedSignalPopup, 'value', max([numel(str1), 1])); end;
if isempty(str1)
    set(handles.segmWatershedBgPopup, 'string', 'missing model');  % smart watershed background
    set(handles.segmWatershedSignalPopup, 'string', 'missing model');  % smart watershed signal
else
    set(handles.segmWatershedBgPopup, 'string', str1);  % smart watershed background
    set(handles.segmWatershedSignalPopup, 'string', str1);  % smart watershed signal
end


if numel(str1) >= showVal;     
    set(handles.segmList, 'Value', showVal); 
else
    set(handles.segmList,'Value',1);    % show list
end;

if numel(str2) >= selFromVal;     
    set(handles.segmSelList, 'Value', selFromVal); 
else
    set(handles.segmSelList,'Value',1);    % select from list
end;

if numel(str3) >= addToVal;     
    set(handles.segmAddList, 'Value', addToVal); 
else
    set(handles.segmAddList,'Value',1);    % add to list
end;



end