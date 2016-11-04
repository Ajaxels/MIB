function model_cm_Callback(hObject, eventdata, type)
% function model_cm_Callback(hObject, eventdata, type)
% a context menu to the to the handles.segmList (Materials list of the Segmentation panel), the menu is called
% with the right mouse button
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% type: a string with parameters for the function
% @li ''showselected'' - toggle display of selected/all materials
% @li ''rename'' - Rename material
% @li ''set color'' - Set color of the selected material
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
% 25.10.2016, IB, updated for segmentation table

if isstruct(type)   % call from the Models menu entry
    type = 'statistics';
end
handles = guidata(hObject);
%if isempty(handles.Img{handles.Id}.I.modelMaterialNames); return; end;

userData = get(handles.segmTable,'UserData');
contIndex = userData.prevMaterial-2;

% if contIndex==0 && ~strcmp(type, 'isosurface') && ~strcmp(type, 'volumeFiji') && ~strcmp(type, 'smooth')
%     msgbox('Please select object in the Materials list');
%     return;
% end
switch type
    case 'showselected'
        userData.showAll = 1 - userData.showAll;    % invert the showAll toggle status
        set(handles.segmTable,'UserData', userData);
        updateSegmentationTable(handles);
        if userData.showAll == 0
            set(hObject, 'Checked', 'on');
        else
            set(hObject, 'Checked', 'off');
        end
    case 'rename'
        if contIndex < 1; return; end;  % do not rename Mask/Exterior
        segmList = handles.Img{handles.Id}.I.modelMaterialNames;
        answer = mib_inputdlg(handles, sprintf('Please add a new name for this material:'), 'Rename material', segmList{contIndex});
        if ~isempty(answer)
            segmList(contIndex) = answer(1);
            handles.Img{handles.Id}.I.modelMaterialNames = segmList;
            updateSegmentationTable(handles);
        end
    case 'set color'
        if contIndex == 1   % set color for the mask layer
            c =  uisetcolor(handles.preferences.maskcolor,'Set color for Mask');
            if length(c) ~= 1
                handles.preferences.maskcolor = c;
            end;
        elseif contIndex > 2    % set color for the selected material
            figTitle = ['Set color for ' handles.Img{handles.Id}.I.modelMaterialNames{contIndex-2}];
            c =  uisetcolor(handles.Img{handles.Id}.I.modelMaterialColors(contIndex-2,:),figTitle);
            if length(c) ~= 1
                handles.Img{handles.Id}.I.modelMaterialColors(contIndex-2,:) = c;
            end;
        end
        updateSegmentationTable(handles);
    case 'statistics'
        windowList = findall(0,'Type','figure');
        winStarted = 0;
        % define type of the input: model or mask
        if contIndex == -1   
            statType = 'Mask';
        else
            statType = 'Model';
        end
        
        for i=1:numel(windowList) % re-initialize the window with keeping existing settings
            if strcmp(get(windowList(i),'tag'),'maskStatsDlg') % update imAdjustment window
                handles = MaskStatsDlg(handles, statType, windowList(i));
                winStarted = 1;
            end
        end
        if winStarted == 0  % re-initialize the window completely
            handles = MaskStatsDlg(handles, statType);    
        end
        guidata(handles.im_browser, handles);
    case 'isosurface'
        options.fillBg = 0;
        if contIndex == -1
            model = ib_getDataset('mask', handles, NaN, NaN, options);
            contIndex = 1;
            modelMaterialColors = handles.preferences.maskcolor;
        else
            model = ib_getDataset('model', handles, NaN, NaN, options);
            if userData.showAll == 1; contIndex = 0; end;      % show all materials
            modelMaterialColors = handles.Img{handles.Id}.I.modelMaterialColors;
        end
        if numel(model) > 1;
            msgbox(sprintf('!!! Error !!!\nPlease select which of ROIs you would like to render!'),'Error!','error');
            return;
        end
                
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
        
        getRGBOptions.sliceNo = Options.slice; 
        if ~isnan(Options.slice)
            if Options.slice > handles.Img{handles.Id}.I.no_stacks
                getRGBOptions.sliceNo = handles.Img{handles.Id}.I.no_stacks;
                Options.slice = handles.Img{handles.Id}.I.no_stacks;
            else
                getRGBOptions.sliceNo = max([1 Options.slice]);   
                Options.slice = max([1 Options.slice]);
            end
            image = handles.Img{handles.Id}.I.getRGBimage(handles, getRGBOptions);
        else
            image = NaN;
        end
        
        bb = handles.Img{handles.Id}.I.getBoundingBox();  % get bounding box
        ib_renderModel(model{1}, contIndex, handles.Img{handles.Id}.I.pixSize, bb, modelMaterialColors, image, Options);
    case 'volumeFiji'
        options.fillBg = 0;
        
        if contIndex == -1
            model = ib_getDataset('mask', handles, NaN, NaN, options);
            contIndex = 1;
            modelMaterialColors = handles.preferences.maskcolor;
        else
            model = ib_getDataset('model', handles, NaN, NaN, options);
            if userData.showAll == 1; contIndex = 0; end;      % show all materials
            modelMaterialColors = handles.Img{handles.Id}.I.modelMaterialColors;
        end
        
        if numel(model) > 1
            msgbox(sprintf('Error!\nPlease select a ROI to render!'),'Error!','error');
            return;
        end
        ib_renderModelFiji(model{1}, contIndex, handles.Img{handles.Id}.I.pixSize, modelMaterialColors);
    case 'unlinkaddto'
        userData.unlink = 1 - userData.unlink;    % invert the unlink toggle status
        userData.prevAddTo = userData.prevMaterial;
        set(handles.segmTable,'UserData', userData);
        if userData.unlink == 1
            set(hObject, 'Checked', 'on');
        else
            set(hObject, 'Checked', 'off');
        end
        updateSegmentationTable(handles);
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end