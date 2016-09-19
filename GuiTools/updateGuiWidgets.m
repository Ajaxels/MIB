function handles = updateGuiWidgets(handles)
% function updateGuiWidgets(handles)
% Update user interface widgets based on the properties of the opened dataset
%
% Parameters:
% handles: structure with handles of im_browser.m

% Copyright (C) 03.09.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices to cells


% % set focus to the main window - freezes the program
% warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
% javaFrame = get(handles.im_browser,'JavaFrame');
% javaFrame.getAxisComponent.requestFocus;
% drawnow;

% % delete all old cursors - this implementation is not compatible with
% % ROIs because ROIs belong to the line type.
% cursors = findall(handles.im_browser,'Type','line');
% for i=1:numel(cursors)
%     delete(cursors(i));
% end

% if isfield(handles, 'cursor'); 
%     %delete(handles.cursor); 
%     handles.cursor = [];
%     set(handles.cursor, 'XData', [],'YData', []);
% end;

% try
%     delete(handles.cursor); 
% catch err
%     
% end
handles = ib_updateCursor(handles);

% update checkboxes in the menu
switch class(handles.Img{handles.Id}.I.img)
    case 'uint8'
        set(handles.menuImage8bit,'Checked','on');
        set(handles.menuImage16bit,'Checked','off');
        set(handles.menuImage32bit,'Checked','off');
    case 'uint16'
        set(handles.menuImage8bit,'Checked','off');
        set(handles.menuImage16bit,'Checked','on');
        set(handles.menuImage32bit,'Checked','off');
    case 'uint32'
        set(handles.menuImage8bit,'Checked','off');
        set(handles.menuImage16bit,'Checked','off');
        set(handles.menuImage32bit,'Checked','on');
end

set(handles.menuImageGrayscale,'Enable','on');
set(handles.menuImageIndexed,'Enable','on');
set(handles.menuImageHSVColor,'Enable','on');
switch handles.Img{handles.Id}.I.img_info('ColorType')
    case 'grayscale'
        set(handles.menuImageGrayscale,'Checked','on');
        set(handles.menuImageRGBColor,'Checked','off');
        set(handles.menuImageHSVColor,'Checked','off');
        set(handles.menuImageIndexed,'Checked','off');
        
        set(handles.menuImageHSVColor,'Enable','off');
    case 'truecolor'
        set(handles.menuImageGrayscale,'Checked','off');
        set(handles.menuImageRGBColor,'Checked','on');
        set(handles.menuImageHSVColor,'Checked','off');
        set(handles.menuImageIndexed,'Checked','off');
    case 'hsvcolor'
        set(handles.menuImageGrayscale,'Checked','off');
        set(handles.menuImageRGBColor,'Checked','off');
        set(handles.menuImageHSVColor,'Checked','on');
        set(handles.menuImageIndexed,'Checked','off');        
        
        set(handles.menuImageGrayscale,'Enable','off');
        set(handles.menuImageIndexed,'Enable','off');
    case 'indexed'
        set(handles.menuImageGrayscale,'Checked','off');
        set(handles.menuImageRGBColor,'Checked','off');
        set(handles.menuImageHSVColor,'Checked','off');
        set(handles.menuImageIndexed,'Checked','on');
        
        set(handles.menuImageHSVColor,'Enable','off');
end

max_val = double(intmax(class(handles.Img{handles.Id}.I.img)));
if get(handles.segmLowSlider, 'value') > max_val; set(handles.segmLowSlider, 'value', max_val); end;
if get(handles.segmHighSlider, 'value') > max_val; set(handles.segmHighSlider, 'value', max_val); end;
set(handles.segmLowSlider,'Max',max_val);
set(handles.segmHighSlider,'Max',max_val);
if handles.Img{handles.Id}.I.time > 1
    set(handles.segmBWthres4D, 'enable', 'on');
else
    set(handles.segmBWthres4D, 'enable', 'off');
    set(handles.segmBWthres4D, 'value', 0);
end

% set properties for the slice slider, turn on/off the slider
% and set XY, YZ, XZ toggles
set(handles.xyPlaneToggle,'State','off');    % set back to default XY-viewing plane
set(handles.zxPlaneToggle,'State','off');
set(handles.zyPlaneToggle,'State','off');
if handles.Img{handles.Id}.I.orientation == 1 % 'xz'
    current = handles.Img{handles.Id}.I.slices{1}(1);
    max_slice = handles.Img{handles.Id}.I.height;
    set(handles.zxPlaneToggle,'State','on');
elseif handles.Img{handles.Id}.I.orientation == 2 % 'yz'
    current = handles.Img{handles.Id}.I.slices{2}(1);
    max_slice = handles.Img{handles.Id}.I.width;
    set(handles.zyPlaneToggle,'State','on');
elseif handles.Img{handles.Id}.I.orientation == 4 %'yx'
    current = handles.Img{handles.Id}.I.slices{4}(1);
    max_slice = handles.Img{handles.Id}.I.no_stacks;
    set(handles.xyPlaneToggle,'State','on');
end

% update the change of layers slider
if max_slice > 1
    set(handles.slider3Dpanel,'Visible','on');
    set(handles.changelayerSlider,'Max',max_slice);
    set(handles.changelayerSlider,'Min',1);
    set(handles.changelayerSlider,'SliderStep',[1.0/(max_slice-1) 1.0/(max_slice-1)]);
    set(handles.slider3Dpanel,'Visible','on');
    if handles.matlabVersion >= 8.4     % R2014b at least
        handles.changelayerSliderListener.Enabled = 1;   % turn on changelayerSlider listener for real-time update of the slider
    else
        handles.changelayerSliderListener.Enabled = 'on';   % turn on changelayerSlider listener for real-time update of the slider
    end
else
    if handles.matlabVersion >= 8.4     % R2014b at least
        handles.changelayerSliderListener.Enabled = 0;  % turn off changelayerSlider listener for Z=1
    else
        handles.changelayerSliderListener.Enabled = 'off';  % turn off changelayerSlider listener for Z=1
    end
    set(handles.slider3Dpanel,'Visible','off');
end
set(handles.changelayerEdit,'String',num2str(current));
set(handles.changelayerSlider,'Value',current);

% update the change of time points slider
if handles.Img{handles.Id}.I.time > 1
    set(handles.changeTimeSlider, 'Max', handles.Img{handles.Id}.I.time);
    set(handles.changeTimeSlider, 'Min', 1);
    set(handles.changeTimeSlider,'SliderStep',[1.0/max([1 (handles.Img{handles.Id}.I.time-1)]) 1.0/max([1 (handles.Img{handles.Id}.I.time-1)])]);
    if handles.matlabVersion >= 8.4     % R2014b at least
        handles.changeTimeSliderListener.Enabled = 1;   % turn on changelayerSlider listener for real-time update of the slider
    else
        handles.changeTimeSliderListener.Enabled = 'on';   % turn on changelayerSlider listener for real-time update of the slider
    end
    set(handles.changeTimeEdit, 'visible','on');
    set(handles.changeTimeSlider, 'visible','on');
    set(handles.firstTimeBtn, 'visible','on');
    set(handles.lastTimeBtn, 'visible','on');
else
    if handles.matlabVersion >= 8.4     % R2014b at least
        handles.changeTimeSliderListener.Enabled = 0;  % turn off changelayerSlider listener for Z=1
    else
        handles.changeTimeSliderListener.Enabled = 'off';  % turn off changelayerSlider listener for Z=1
    end
    set(handles.changeTimeEdit, 'visible','off');
    set(handles.changeTimeSlider, 'visible','off');
    set(handles.firstTimeBtn, 'visible','off');
    set(handles.lastTimeBtn, 'visible','off');
end
set(handles.changeTimeEdit,'String',num2str(handles.Img{handles.Id}.I.slices{5}(1)));
set(handles.changeTimeSlider,'Value',handles.Img{handles.Id}.I.slices{5}(1));

% update toolbar buttons
if strcmp(handles.preferences.mouseWheel, 'zoom')
    set(handles.mouseWheelToolbarSw,'State','off');
else
    set(handles.mouseWheelToolbarSw,'State','on');
end

if strcmp(handles.preferences.mouseButton, 'pan')
    set(handles.toolbarSwapMouse,'State','off');
else
    set(handles.toolbarSwapMouse,'State','on');
end
set(handles.toolbarShowROISwitch,'State','off');

% generate lut colors
if handles.Img{handles.Id}.I.colors > size(handles.Img{handles.Id}.I.lutColors,1)
    for i=size(handles.Img{handles.Id}.I.lutColors,1)+1:handles.Img{handles.Id}.I.colors
        handles.Img{handles.Id}.I.lutColors(i,:) = [rand(1) rand(1) rand(1)];
    end
end

% update handles.channelMixerTable
redrawChannelMixerTable(handles);

if size(handles.Img{handles.Id}.I.img,3) == 1; set(handles.ColChannelCombo,'Value',2); end;

% 
updateSegmentationLists(handles);

% update show mask checkbox
if handles.Img{handles.Id}.I.maskExist == 0
    set(handles.maskShowCheck,'value',0);
    set(handles.maskedAreaCheck, 'value', 0);
    set(handles.maskedAreaCheck, 'backgroundcolor', [0.8310    0.8160    0.7840]);
end

% update show model checkbox
if get(handles.modelShowCheck,'value') && handles.Img{handles.Id}.I.modelExist == 0
    set(handles.modelShowCheck,'value',0);
end

% update roi list box
% get number of ROIs
[number, indices] = handles.Img{handles.Id}.I.hROI.getNumberOfROI();
str2 = cell([number+1 1]);
str2(1) = cellstr('All');
if number > 0
    currVal = get(handles.roiList,'Value');
    for i=1:number
        str2(i+1) = handles.Img{handles.Id}.I.hROI.Data(indices(i)).label;
    end
    if currVal > number+1; 
        set(handles.roiList,'Value',1);
    end
else
    set(handles.roiList,'Value',1);
end
set(handles.roiList,'String',str2);

roiShowCheck_Callback(handles.roiShowCheck, NaN, handles, 'noplot');    % noplot means do not redraw image inside this function

% add a label to the image view panel
strVal1 = 'Image View    >>>>>    ';
[~, fn, ext] = fileparts(handles.Img{handles.Id}.I.img_info('Filename'));
strVal1 = sprintf('%s%s%s', strVal1, fn, ext);
if isKey(handles.Img{handles.Id}.I.img_info, 'SliceName') && handles.Img{handles.Id}.I.no_stacks > 1 && handles.Img{handles.Id}.I.orientation == 4   %'yx'
    % use getfield to get exact value as suggested by Ian M. Garcia in
    % http://stackoverflow.com/questions/3627107/how-can-i-index-a-matlab-array-returned-by-a-function-without-first-assigning-it
    layerName = getfield(handles.Img{handles.Id}.I.img_info('SliceName'), {min([current numel(handles.Img{handles.Id}.I.img_info('SliceName'))])}); 
    set(handles.imagePanel, 'Title', sprintf('%s    >>>>>    %s', strVal1, layerName{1}));
else
    set(handles.imagePanel, 'Title', strVal1);    
end

% update additional windows
windowList = findall(0,'Type','figure');
for i=1:numel(windowList)
    if strcmp(get(windowList(i),'tag'),'imAdjustments') % update imAdjustment window
        %imAdjustments(handles, windowList(i));
        hGui = guidata(windowList(i));
        cb = get(hGui.updateBtn, 'callback');
        feval(cb, hGui.updateBtn, []);
    end
    if strcmp(get(windowList(i),'tag'),'logWindow') % update the Log List window
        %logList(handles, windowList(i));   % an old call slower than the updated version below
        hGui = guidata(windowList(i));
        cb = get(hGui.updateBtn,'callback');
        feval(cb, hGui.updateBtn, []);
    end
    if strcmp(get(windowList(i),'tag'),'ib_datasetInfoGui') % update the Dataset Info window
        %ib_datasetInfoGui(handles, windowList(i));     % an old call slower than the updated version below
        hGui = guidata(windowList(i));
        cb = get(hGui.refreshBtn,'callback');
        feval(cb, hGui.refreshBtn, []);
    end
    if strcmp(get(windowList(i),'tag'),'ib_labelsGui') % update the Annotation window
        %ib_labelsGui(handles, windowList(i));  % an old call slower than the updated version below
        hGui = guidata(windowList(i));
        cb = get(hGui.refreshBtn,'callback');
        feval(cb, hGui.refreshBtn, []);
    end
    if strcmp(get(windowList(i),'tag'),'mib_measureTool') % update the Annotation window
        %ib_labelsGui(handles, windowList(i));  % an old call slower than the updated version below
        hGui = guidata(windowList(i));
        cb = get(hGui.refreshTableBtn,'callback');
        feval(cb, hGui.refreshTableBtn, []);
        %handles = guidata(hGui.h.im_browser);   % needed to update handles, otherwise brush cursor is still visible
    end
end

% update the blockmode switch
if strcmp(get(handles.toolbarBlockModeSwitch, 'state'), 'on')
    handles.Img{handles.Id}.I.blockModeSwitch = 1;
else
    handles.Img{handles.Id}.I.blockModeSwitch = 0;
end

%% update handles of GUI callbacks
%set(handles.im_browser, 'WindowKeyPressFcn', {@im_browser_WindowKeyPressFcn, handles}); 
%set(handles.im_browser, 'WindowButtonDownFcn', {@im_browser_WindowButtonDownFcn, handles});

%guidata(handles.im_browser, handles);
handles.Img{handles.Id}.I.volren.previewImg = [];
volrenToolbarSwitch_ClickedCallback(handles.volrenToolbarSwitch, struct(), handles);
%handles = guidata(handles.im_browser);
%guidata(handles.im_browser, handles);
%handles = ib_updateCursor(handles);

% import java.awt.Robot;
% import java.awt.event.*;
% mouse = Robot;
% %mouse.mousePress(InputEvent.BUTTON1_MASK);
% mouse.mousePress(InputEvent.BUTTON1_MASK);
% mouse.mouseRelease(InputEvent.BUTTON1_MASK);

% % move focus to the main window - freezes the program
% javaFrame.getAxisComponent.requestFocus;
% drawnow;
% guidata(handles.im_browser, handles);
end
