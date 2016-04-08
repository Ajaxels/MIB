function model_cm_Callback(hObject, eventdata, type)
% function model_cm_Callback(hObject, eventdata, type)
% a context menu to the to the handles.segmList (Materials list of the Segmentation panel), the menu is called
% with the right mouse button
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% type: a string with parameters for the function
% @li ''rename'' - Rename material
% @li ''set color'' - Set color of the selected material
% @li ''smooth'' - Smooth material
% @li ''statistics'' - Get statistics for material
% @li ''isosurface'' - Show isosurface (Matlab)
% @li ''volumeFiji'' - Show as volume (Fiji)

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 02.02.2016, updated for 4D datasets

if isstruct(type)   % call from the Models menu entry
    type = 'statistics';
end
handles = guidata(hObject);
if isempty(handles.Img{handles.Id}.I.modelMaterialNames); return; end;
contIndex = get(handles.segmList,'Value');
% if contIndex==0 && ~strcmp(type, 'isosurface') && ~strcmp(type, 'volumeFiji') && ~strcmp(type, 'smooth')
%     msgbox('Please select object in the Materials list');
%     return;
% end
switch type
    case 'rename'
        segmList = handles.Img{handles.Id}.I.modelMaterialNames;
        segmListValue = get(handles.segmList,'Value');
        %answer = inputdlg(sprintf('Please add a new name for this material:'),'Rename material',1,segmList(segmListValue));
        answer = mib_inputdlg(NaN, sprintf('Please add a new name for this material:'),'Rename material',segmList{segmListValue});
        if ~isempty(answer)
            segmList(segmListValue) = answer(1);
            %set(handles.segmList,'String', segmList);
            handles.Img{handles.Id}.I.modelMaterialNames = segmList;
            updateSegmentationLists(handles);
        end
    case 'set color'
        figTitle = ['Set color for ' handles.Img{handles.Id}.I.modelMaterialNames{contIndex}];
        c =  uisetcolor(handles.Img{handles.Id}.I.modelMaterialColors(contIndex,:),figTitle);
        if length(c) ~= 1
            handles.Img{handles.Id}.I.modelMaterialColors(contIndex,:) = c;
        end;
    case 'smooth'
        smoothImage_Callback(NaN, NaN, handles, 'Model');
    case 'statistics'
        windowList = findall(0,'Type','figure');
        winStarted = 0;
        for i=1:numel(windowList) % re-initialize the window with keeping existing settings
            if strcmp(get(windowList(i),'tag'),'maskStatsDlg') % update imAdjustment window
                handles = MaskStatsDlg(handles, 'Model', windowList(i));
                winStarted = 1;
            end
        end
        if winStarted == 0  % re-initialize the window completely
            handles = MaskStatsDlg(handles,'Model');    
        end
        guidata(handles.im_browser, handles);
    case 'isosurface'
        options.fillBg = 0;
        model = ib_getDataset('model', handles, NaN, NaN, options);
        if numel(model) > 1;
            msgbox(sprintf('!!! Error !!!\nPlease select which of ROIs you would like to render!'),'Error!','error');
            return;
        end
        if get(handles.seeAllMaterialsCheck,'value') == 1; contIndex = 0; end;      % show all materials
        
        % define parameters for rendering
        prompt = {'Reduce the volume down to, width pixels [no volume reduction when 0]?',...
            'Smoothing 3d kernel, width (no smoothing when 0):',...
            'Maximal number of faces (no limit when 0):',...
            'Show orthoslice (enter a number slice number, or NaN):'};
        dlg_title = 'Isosurface parameters';
        if size(model{1},2) > 500
            def = {'500','5','300000','1'};
        else
            def = {'0','5','300000','1'};
        end
        answer = inputdlg(prompt,dlg_title,1,def);
        
        if isempty(answer); return;  end;
        Options.reduce = str2double(answer{1});
        Options.smooth = str2double(answer{2});
        Options.maxFaces = str2double(answer{3});
        Options.slice = str2double(answer{4});
        
        getRGBOptions.mode = 'full';
        getRGBOptions.resize = 'no';
        getRGBOptions.sliceNo = max([Options.slice handles.Img{handles.Id}.I.no_stacks]);
        image = handles.Img{handles.Id}.I.getRGBimage(handles, getRGBOptions);
        bb = handles.Img{handles.Id}.I.getBoundingBox();  % get bounding box
        ib_renderModel(model{1}, contIndex, handles.Img{handles.Id}.I.pixSize, bb, handles.Img{handles.Id}.I.modelMaterialColors, image, Options);
    case 'volumeFiji'
        options.fillBg = 0;
        model = ib_getDataset('model', handles, NaN, NaN, options);
        if numel(model) > 1;
            msgbox(sprintf('Error!\nPlease select a ROI to render!'),'Error!','error');
            return;
        end
        if get(handles.seeAllMaterialsCheck,'value') == 1; contIndex = 0; end;      % show all materials
        ib_renderModelFiji(model{1}, contIndex, handles.Img{handles.Id}.I.pixSize, handles.Img{handles.Id}.I.modelMaterialColors);
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end