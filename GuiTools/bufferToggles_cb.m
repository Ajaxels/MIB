function bufferToggles_cb(hObject, eventdata, parameter, buttonID)
% function bufferToggles_cb(hObject, eventdata, parameter, buttonID)
% A callback function for the popup menu of the buffer buttons in the upper
% part of the @em Directory @em contents panel. This callback is triggered
% from all those buttons.
% 
% Parameters:
% hObject: - a handle to one of the buttons
% eventdata: - eventdata structure
% parameter: - a string that defines options:
% - @b duplicate - duplicate the dataset to another buffer
% - @b sync_xy - synchronize datasets with another dataset in XY
% - @b sync_xyz - synchronize datasets with another dataset in XYZ
% - @b sync_xyzt - synchronize datasets with another dataset in XYZT
% - @b clear - delete the dataset
% - @b clearAll - delete all datasets
% buttonID: - a number (from 1 to 8) of the pressed button.

% Copyright (C) 20.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, IB, changed .slices() to .slices{:}; .slicesColor->.slices{3}
% 01.02.2016, IB, added syncronization in the XYZT dimension

handles = guidata(hObject);
switch parameter
    case 'duplicate'    % duplicate dataset to a new position
        destinationButton = 8;
        for i=1:8
            if ismac()
                eval(sprintf('bgColor = get(handles.bufferToggle%d,''ForegroundColor'');', i));     % make green
            else
                eval(sprintf('bgColor = get(handles.bufferToggle%d,''BackgroundColor'');', i));     % make green
            end
            if bgColor(2) ~= 1;
                destinationButton = i;
                break;
            end;
        end
        
        answer = mib_inputdlg(handles, 'Enter destination buffer number (from 1 to 8) to duplicate the dataset:','Duplicate',num2str(destinationButton));
        if isempty(answer); return; end;
        destinationButton = str2double(answer{1});
        if destinationButton > 8 || destinationButton<1; errordlg('The destination should be a number from 1 to 8!','Wrong destination'); return; end;
        if ismac()
            eval(sprintf('bgColor = get(handles.bufferToggle%d,''ForegroundColor'');', destinationButton));     % make green
        else
            eval(sprintf('bgColor = get(handles.bufferToggle%d,''BackgroundColor'');', destinationButton));     % make green
        end
        if bgColor(2) == 1
            button = questdlg(sprintf('You are goind to overwrite dataset in buffer %d\n\nAre you sure?', destinationButton),'!! Warning !!','Overwrite','Cancel','Cancel');
            if strcmp(button, 'Cancel'); return; end;
        end
        
        handles.Img{destinationButton}.I  = copy(handles.Img{buttonID}.I);
        handles.Img{destinationButton}.I.img_info  = containers.Map(keys(handles.Img{buttonID}.I.img_info), values(handles.Img{buttonID}.I.img_info));  % make a copy of img_info containers.Map
        handles.Img{destinationButton}.I.hROI  = copy(handles.Img{destinationButton}.I.hROI);
        handles.Img{destinationButton}.I.hROI.hImg = handles.Img{destinationButton}.I;  % need to copy a handle of imageData class to a copy of the roiRegion class
        handles.Img{destinationButton}.I.hLabels  = copy(handles.Img{destinationButton}.I.hLabels);
        handles.Img{destinationButton}.I.hMeasure  = copy(handles.Img{destinationButton}.I.hMeasure);
        
        if ismac()
            eval(sprintf('set(handles.bufferToggle%d,''ForegroundColor'',[ 0    1    0]);', destinationButton));
        else
            eval(sprintf('set(handles.bufferToggle%d,''BackgroundColor'',[ 0    1    0]);', destinationButton));
        end
        eval(sprintf('set(handles.bufferToggle%d,''TooltipString'', handles.Img{%d}.I.img_info(''Filename''));',destinationButton, destinationButton));     % make a tooltip as filename
        handles = updateGuiWidgets(handles);
        %set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
        %set(handles.im_browser, 'windowbuttonmotionfcn' , {@im_browser_winMouseMotionFcn, handles});
        %set(handles.im_browser, 'windowbuttonupfcn', {@im_browser_WindowButtonUpFcn, handles});
        
        guidata(handles.im_browser, handles);   % store handles
    case {'sync_xy', 'sync_xyz', 'sync_xyzt'}  % synchronize view with another opened dataset
        destinationButton = 8;
        for i=1:8
            if ismac()
                eval(sprintf('bgColor = get(handles.bufferToggle%d,''ForegroundColor'');', i));     % make green
            else
                eval(sprintf('bgColor = get(handles.bufferToggle%d,''BackgroundColor'');', i));     % make green
            end
            if bgColor(2) == 1 && i~=buttonID;
                destinationButton = i;
                break;
            end;
        end
        
        %answer = inputdlg('Enter buffer number (from 1 to 8) to synchronize with:','Synchronize xy',1,{num2str(destinationButton)});
        answer = mib_inputdlg(handles, 'Enter buffer number (from 1 to 8) to synchronize with:','Synchronize xy',num2str(destinationButton));
        if isempty(answer); return; end;
        destinationButton = str2double(answer{1});
        if destinationButton > 8 || destinationButton<1; errordlg('The buffer number should be from 1 to 8!','Wrong buffer'); return; end;
        if handles.Img{buttonID}.I.orientation ~= handles.Img{destinationButton}.I.orientation
            errordlg(sprintf('The datasets should be in the same orientation!\n\nFor example, switch orientation of both datasets to XY (the XY button in the toolbar) and try again'),'Wrong buffer'); return;
        end
        
        if strcmp(get(handles.volrenToolbarSwitch, 'state'), 'off')
            
            handles.Img{buttonID}.I.axesX = handles.Img{destinationButton}.I.axesX;
            handles.Img{buttonID}.I.axesY = handles.Img{destinationButton}.I.axesY;
            handles.Img{buttonID}.I.magFactor = handles.Img{destinationButton}.I.magFactor;
            
            if strcmp(parameter, 'sync_xyz') || strcmp(parameter, 'sync_xyzt')   % sync in z, t as well
                destZ = handles.Img{destinationButton}.I.slices{handles.Img{destinationButton}.I.orientation}(1);
                if destZ > size(handles.Img{buttonID}.I.img, handles.Img{buttonID}.I.orientation)
                    warndlg(sprintf('The second dataset has the Z value higher than the Z-dimension of the first dataset!\n\nThe synchronization was done in the XY mode.'),'Dimensions mismatch!');
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                    return;
                end
                if handles.Img{buttonID}.I.no_stacks > 1
                    set(handles.changelayerEdit, 'String', destZ);
                    changelayerEdit_Callback(0, eventdata, handles);
                end
                if strcmp(parameter, 'sync_xyzt') && handles.Img{buttonID}.I.time > 1
                    destT = handles.Img{destinationButton}.I.slices{5}(1);
                    if destT > handles.Img{buttonID}.I.time
                        warndlg(sprintf('The second dataset has the T value higher than the T-dimension of the first dataset!\n\nThe synchronization was done in the XYZ mode.'),'Dimensions mismatch!');
                        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                        return;
                    end
                    set(handles.changeTimeEdit, 'String', destT);
                    changeTimeEdit_Callback(0, eventdata, handles);
                end
            end
        else
             handles.Img{buttonID}.I.volren.viewer_matrix = handles.Img{destinationButton}.I.volren.viewer_matrix;
        end
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    case 'clear'    % clear dataset
        
        if handles.preferences.uint8
            handles.Img{buttonID}.I = imageData(handles, 'uint8');    % create instanse for keeping images;
        else
            handles.Img{buttonID}.I = imageData(handles, 'uint6');    % create instanse for keeping images;
        end
        handles = handles.Img{buttonID}.I.updateAxesLimits(handles, 'resize');
        
        %handles = guidata(handles.im_browser);
        % guidata(handles.im_browser, handles); 
        if ismac()
            eval(sprintf('set(handles.bufferToggle%d,''ForegroundColor'',[ 0.8314    0.8157    0.7843]);', buttonID));
        else
            eval(sprintf('set(handles.bufferToggle%d,''BackgroundColor'',[ 0.8314    0.8157    0.7843]);', buttonID));
        end
        eval(sprintf('set(handles.bufferToggle%d,''ToolTipString'',''Use the left mouse button to select the dataset and the right mouse button for additional menu'');', buttonID));
        if buttonID == handles.Id   % delete the currently shown dataset
            handles.U.clearContents();  % clear undo history
            updateGuiWidgets(handles);
            %handles = guidata(handles.im_browser);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        else
            guidata(handles.im_browser, handles);   % store handles
        end
    case 'clearAll'     % clear all stored datasets
        button = questdlg(sprintf('Warning!\n\nYou are going to clear all buffered datasets!\nContinue?'),...
            'Clear buffer','Continue','Cancel','Cancel');
        if strcmp(button, 'Cancel'); return; end;
        
        % initializa image buffer with dummy images
        handles.Id = 1;   % number of the selected buffer
        for button=1:8
            if handles.preferences.uint8
                handles.Img{button}.I = imageData(handles, 'uint8');    % create instanse for keeping images;
            else
                handles.Img{button}.I = imageData(handles, 'uint6');    % create instanse for keeping images;
            end
            
            handles = handles.Img{button}.I.updateAxesLimits(handles, 'resize');
            if ismac()
                eval(sprintf('set(handles.bufferToggle%d,''ForegroundColor'',[ 0.8314    0.8157    0.7843]);', button));
            else
                eval(sprintf('set(handles.bufferToggle%d,''BackgroundColor'',[ 0.8314    0.8157    0.7843]);', button));
            end
            eval(sprintf('set(handles.bufferToggle%d,''ToolTipString'',''Use the left mouse button to select the dataset and the right mouse button for additional menu'');', button));
            eval(sprintf('set(handles.bufferToggle%d, ''value'', 0);',button));
        end;
        set(handles.bufferToggle1, 'value', 1);
        handles.U.clearContents();  % clear undo history
        handles = updateGuiWidgets(handles);
        %handles = guidata(handles.im_browser);
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
end
