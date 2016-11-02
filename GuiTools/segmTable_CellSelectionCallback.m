function segmTable_CellSelectionCallback(hObject, eventdata, handles)
% --- Executes when selected cell(s) is changed in segmTable.
% hObject    handle to segmTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Copyright (C) 28.10.2016, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

if isempty(eventdata.Indices); return; end;
if size(eventdata.Indices,1) > 1 && eventdata.Indices(1,1) == 1 % check for Ctrl+A press
    updateSegmentationTable(handles);
    return; 
end;   

Indices = eventdata.Indices(1,:);

userData = get(handles.segmTable,'UserData');
prevMaterial = userData.prevMaterial;   % index of the previously selected material
prevAddTo = userData.prevAddTo;         % index of the previously selected add to material
jTable = userData.jTable;   % jTable is initializaed in the beginning of im_browser.m
unlink = userData.unlink;   % unlink selection of material from Add to (does not apply for the Fix selection to material mode)
if get(handles.segmSelectedOnlyCheck, 'value') == 1
    unlink = 1;
end

% fix selection to material checkbox
val = get(handles.segmSelectedOnlyCheck, 'value');
if val == 1
    fontColor = [200, 200, 200];
else
    fontColor = [0, 0, 0]; 
end


if Indices(2) == 2        % selection of Material
    selectedMaterial = Indices(1);
    userData.prevMaterial = selectedMaterial;
    if selectedMaterial > 2
        handles.lastSegmSelection = selectedMaterial;
        guidata(handles.im_browser, handles);
    end
    if unlink == 0
        userData.prevAddTo = selectedMaterial;
        jTable.setValueAt(java.lang.Boolean(0),prevMaterial-1, 2);
        drawnow;
        jTable.setValueAt(java.lang.Boolean(1),selectedMaterial-1, 2);
    end
    set(handles.segmTable, 'UserData', userData);
elseif Indices(2) == 3    % click on the Add to checkbox
    if isempty(prevMaterial)
        selectedMaterial = Indices(1);
        userData.prevMaterial = selectedMaterial;
    else
        if unlink == 1
            selectedMaterial = prevMaterial;
            prevMaterial = [];
        else
            selectedMaterial = Indices(1);
        end
    end
    
    if isempty(prevAddTo)
        userData.prevAddTo = Indices(1);
        jTable.setValueAt(java.lang.Boolean(1),Indices(1)-1, 2);
    elseif prevAddTo ~= Indices(1)
        jTable.setValueAt(java.lang.Boolean(0),prevAddTo-1, 2);
        userData.prevAddTo = Indices(1);
        jTable.setValueAt(java.lang.Boolean(1),Indices(1)-1, 2);
    elseif prevAddTo == Indices(1)
        jTable.setValueAt(java.lang.Boolean(1),prevAddTo-1, 2);
    end
    
    if unlink == 0
        userData.prevMaterial = selectedMaterial;
        if selectedMaterial > 2
            handles.lastSegmSelection = selectedMaterial;
            guidata(handles.im_browser, handles);
        end
    end
    set(handles.segmTable, 'UserData', userData);    
else                        % define color
    if Indices(1) == 1    % mask
        c = uisetcolor(handles.preferences.maskcolor, 'Set color for Mask');
        if length(c) == 1; return; end;
        handles.preferences.maskcolor = c;
    elseif Indices(1) > 2
        figTitle = ['Set color for ' handles.Img{handles.Id}.I.modelMaterialNames{Indices(1)-2}];
        c = uisetcolor(handles.Img{handles.Id}.I.modelMaterialColors(Indices(1)-2,:), figTitle);
        if length(c) == 1; return; end;
        handles.Img{handles.Id}.I.modelMaterialColors(Indices(1)-2,:) = c;
    else
        return;
    end
    guidata(handles.im_browser, handles);
    updateSegmentationTable(handles);
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    return;
end

colergen = @(color,text) ['<html><table border=0 width=300 color=',color,'><TR><TD>',text,'</TD></TR></table></html>'];
% remove background for the previously selected item
if ~isempty(prevMaterial)
    if prevMaterial ~= selectedMaterial
        if prevMaterial == 1
            jTable.setValueAt(java.lang.String(colergen(sprintf('''rgb(%d, %d, %d)''', fontColor(1), fontColor(2), fontColor(3)), 'Mask')),prevMaterial-1,1);
        elseif prevMaterial == 2
            jTable.setValueAt(java.lang.String(colergen(sprintf('''rgb(%d, %d, %d)''', fontColor(1), fontColor(2), fontColor(3)), 'Exterior')),prevMaterial-1,1);
        else
            jTable.setValueAt(java.lang.String(colergen(sprintf('''rgb(%d,%d,%d)''', fontColor(1), fontColor(2), fontColor(3)), handles.Img{handles.Id}.I.modelMaterialNames{prevMaterial-2})),prevMaterial-1,1); % clear background
            if userData.showAll == 0
                jTable.setValueAt(java.lang.String(colergen(sprintf('''rgb(%d, %d, %d)''', 255, 255, 255),'&nbsp;')),prevMaterial-1,0); % clear color field
            end
        end
    end
end

colergen = @(color,text) ['<html><table border=0 width=300 color=0 bgcolor=',color,'><TR><TD>',text,'</TD></TR></table></html>'];
if selectedMaterial == 1
    jTable.setValueAt(java.lang.String(colergen(sprintf('''rgb(%d, %d, %d)''', 51, 153, 255), 'Mask')),selectedMaterial-1,1);
elseif selectedMaterial == 2
    jTable.setValueAt(java.lang.String(colergen(sprintf('''rgb(%d, %d, %d)''', 51, 153, 255), 'Exterior')),selectedMaterial-1,1);
else
    jTable.setValueAt(java.lang.String(colergen(sprintf('''rgb(%d, %d, %d)''', 51, 153, 255), handles.Img{handles.Id}.I.modelMaterialNames{selectedMaterial-2})),selectedMaterial-1,1);
    if userData.showAll == 0
        jTable.setValueAt(java.lang.String(colergen(sprintf('''rgb(%d, %d, %d)''', round(handles.Img{handles.Id}.I.modelMaterialColors(selectedMaterial-2, 1)*255), round(handles.Img{handles.Id}.I.modelMaterialColors(selectedMaterial-2, 2)*255), round(handles.Img{handles.Id}.I.modelMaterialColors(selectedMaterial-2, 3)*255)),'&nbsp;')),selectedMaterial-1,0); % update color for the field
    end
end
%unFocus(hObject); % remove focus from hObject

if userData.showAll == 0 && selectedMaterial > 2
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

end