function updateSegmentationTable(handles)
% function updateSegmentationTable(handles)
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
% 25.10.2016, IB, updated for segmentation table, renamed from updateSegmentationLists

% check Fix selection to material checkbox
userData = get(handles.segmTable,'UserData');
if get(handles.segmSelectedOnlyCheck, 'value') == 1     % selected only
    fontColor = [200, 200, 200];
else
    fontColor = [0, 0, 0];
end

if handles.Img{handles.Id}.I.modelExist == 0; handles.Img{handles.Id}.I.modelMaterialNames = {}; end;
max_color = numel(handles.Img{handles.Id}.I.modelMaterialNames);

tableData = cell([max_color+2, 3]);
colergen = @(color,text) ['<html><table border=0 width=25 bgcolor=',color,'><TR><TD>',text,'</TD></TR></table></html>'];
colergen2 = @(color,text) ['<html><table border=0 width=300 bgcolor=',color,'><TR><TD>',text,'</TD></TR></table></html>'];
colergen2 = @(color,text) ['<html><table border=0 width=300 color=',color,'><TR><TD>',text,'</TD></TR></table></html>'];
for i=1:max_color+2
    if i==1         % Mask
        tableData{i, 1} = colergen(sprintf('''rgb(%d, %d, %d)''', round(handles.preferences.maskcolor(1)*255), round(handles.preferences.maskcolor(2)*255), round(handles.preferences.maskcolor(3)*255)),'&nbsp;');  % rgb(0,255,0)
        tableData{i, 2} = colergen2(sprintf('''rgb(%d, %d, %d)''', fontColor(1), fontColor(2), fontColor(3)), 'Mask');  
        tableData{i, 3} = false;
    elseif i == 2   % Ext
        tableData{i, 1} = colergen(sprintf('''rgb(%d, %d, %d)''', 255, 255, 255),'&nbsp;');  % rgb(0,255,0)
        tableData{i, 2} = colergen2(sprintf('''rgb(%d, %d, %d)''', fontColor(1), fontColor(2), fontColor(3)), 'Exterior');  
        tableData{i, 3} = false;
    else
        if userData.showAll || i == userData.prevMaterial
            tableData{i, 1} = colergen(sprintf('''rgb(%d, %d, %d)''', round(handles.Img{handles.Id}.I.modelMaterialColors(i-2, 1)*255), round(handles.Img{handles.Id}.I.modelMaterialColors(i-2, 2)*255), round(handles.Img{handles.Id}.I.modelMaterialColors(i-2, 3)*255)),'&nbsp;');  % rgb(0,255,0)
        else
            tableData{i, 1} = colergen(sprintf('''rgb(%d, %d, %d)''', 255, 255, 255),'&nbsp;');  % rgb(0,255,0)
        end
        tableData{i, 2} = colergen2(sprintf('''rgb(%d, %d, %d)''', fontColor(1), fontColor(2), fontColor(3)), handles.Img{handles.Id}.I.modelMaterialNames{i-2});  
        tableData{i, 3} = false;        
    end
end

if ~isfield(userData, 'jTable')  % stop here during starting up of MIB
     return;                                     
end;  

%%
jScrollPosition = userData.jScroll.getViewport.getViewPosition(); % store the view position of the table
set(handles.segmTable,'Data', tableData);
    
if userData.prevMaterial > max_color+2;     userData.prevMaterial = 1;   end;
if userData.prevAddTo > max_color+2;     userData.prevAddTo = 1;   end;
set(handles.segmTable,'UserData', userData);
drawnow;
eventdata.Indices = [userData.prevMaterial, 2];
segmTable_CellSelectionCallback(handles.segmTable, eventdata, handles);     % update Materials column
eventdata.Indices = [userData.prevAddTo, 3];
segmTable_CellSelectionCallback(handles.segmTable, eventdata, handles);     % update Add to column

% restore the view position of the table
drawnow;
userData.jScroll.getViewport.setViewPosition(jScrollPosition);
userData.jScroll.repaint;

%% update list of materials in the Smart Watershed module
bgVal = get(handles.segmWatershedBgPopup, 'value');
if bgVal > numel(handles.Img{handles.Id}.I.modelMaterialNames); set(handles.segmWatershedBgPopup, 'value', 1); end;
bgVal = get(handles.segmWatershedSignalPopup, 'value');
if bgVal > numel(handles.Img{handles.Id}.I.modelMaterialNames); set(handles.segmWatershedSignalPopup, 'value', max([numel(handles.Img{handles.Id}.I.modelMaterialNames), 1])); end;
if isempty(handles.Img{handles.Id}.I.modelMaterialNames)
    set(handles.segmWatershedBgPopup, 'string', 'missing model');  % smart watershed background
    set(handles.segmWatershedSignalPopup, 'string', 'missing model');  % smart watershed signal
else
    set(handles.segmWatershedBgPopup, 'string', handles.Img{handles.Id}.I.modelMaterialNames);  % smart watershed background
    set(handles.segmWatershedSignalPopup, 'string', handles.Img{handles.Id}.I.modelMaterialNames);  % smart watershed signal
end

end