function im_browser_ResizeFcn(~, ~, handles, rightPanelShift)
% function im_browser_ResizeFcn(~, ~, handles, rightPanelShift)
% resizing for panels of MIB
%
% Parameters:
% handles: structure with handles of im_browser.m
% rightPanelShift: shift of the panels on the right-hand side of GUI

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

if nargin < 4
    separatingPanelPos = get(handles.separatingPanel, 'position');
    rightPanelShift =  separatingPanelPos(1);%-(separatingPanelPos(3))/2;
end

sF = 1;     % scale factor
if ismac()
    sF = 1.5;
elseif isunix()
    sF = 1.2;
end

separatingPanelPos = get(handles.separatingPanel, 'position');
separatingPanelPos(1) = rightPanelShift;
set(handles.separatingPanel, 'position',separatingPanelPos);

set(handles.im_browser, 'units', 'points');
set(handles.imageAxes,'units','normalized');
figPos = get(handles.im_browser, 'position');
parPanPos = get(handles.segmentationPanel,'Position');
toolsPanPos = get(handles.toolsPanel,'Position');

toolsPanPos(1) = rightPanelShift;%+2*sF;
toolsPanPos(3) = figPos(3)-rightPanelShift;%-4.5*sF;
set(handles.toolsPanel,'Position',toolsPanPos);

% % figure can't be too small or off the screen
% if figPos(3) < 950 || figPos(4) < 700
%     figPos(3) = max([750 figPos(3)]);
%     figPos(4) = max([500 figPos(4)]);
%     screenSize = get(0, 'ScreenSize');
%     if figPos(1)+figPos(3) > screenSize(3)
%         figPos(1) = screenSize(3) - figPos(3) - 50;
%     end
%     if figPos(2)+figPos(4) > screenSize(4)
%         figPos(2) = screenSize(4) - figPos(4) - 50;
%     end
%     set(handles.im_browser, 'position', figPos);
% end

pathPanelPos = [2*sF, figPos(4)-39*sF, figPos(3)-6*sF, 35*sF];
set(handles.pathPanel,'position', pathPanelPos);

%directoryPanelPos = [2*sF, parPanPos(4)+9*sF, parPanPos(3), figPos(4)-parPanPos(4)-48*sF];
directoryPanelPos = [2*sF, parPanPos(4)+7*sF, rightPanelShift-2*sF, figPos(4)-parPanPos(4)-48*sF];
set(handles.directoryPanel,'position',directoryPanelPos);

dir_subpanel = get(handles.dir_subpanel,'position');
bufferButtonsPanel = get(handles.dirBufferBtnPanel,'position');
set(handles.dirBufferBtnPanel,'position', [dir_subpanel(1)-1*sF, directoryPanelPos(4)-31*sF, bufferButtonsPanel(3), bufferButtonsPanel(4)]);

filesListbox = get(handles.filesListbox,'position');
%filesListbox = [filesListbox(1), dir_subpanel(4)+4*sF, filesListbox(3), directoryPanelPos(4)-dir_subpanel(4)-bufferButtonsPanel(4)-18*sF];
filesListbox = [filesListbox(1), dir_subpanel(4)+4*sF, rightPanelShift-16*sF, directoryPanelPos(4)-dir_subpanel(4)-bufferButtonsPanel(4)-18*sF];
set(handles.filesListbox,'position',filesListbox);

%set(handles.segmentationPanel,'position',[2, parPanPos(2),parPanPos(3), parPanPos(4)]);
set(handles.segmentationPanel,'position',[2, parPanPos(2), rightPanelShift-2, parPanPos(4)]);
%set(handles.roiPanel,'position',[2 parPanPos(2), parPanPos(3), parPanPos(4)]);
set(handles.roiPanel,'position',[2 parPanPos(2), rightPanelShift-2, parPanPos(4)]);

%set(handles.imagePanel,'position',[toolsPanPos(1)+4*sF, toolsPanPos(2)+102*sF, figPos(3)-parPanPos(3)-8*sF,  figPos(4)-toolsPanPos(4)-46*sF]);
set(handles.imagePanel,'position',[toolsPanPos(1)+4*sF, toolsPanPos(2)+102*sF, figPos(3)-rightPanelShift-10*sF,  figPos(4)-toolsPanPos(4)-46*sF]);

set(handles.imageAxes,'units','points');
axPos = ceil(get(handles.imageAxes,'Position'));
sliceSliderPos = get(handles.slider3Dpanel, 'position');
set(handles.slider3Dpanel, 'position',[sliceSliderPos(1) sliceSliderPos(2), sliceSliderPos(3),axPos(4)] );

timeSliderPos = get(handles.sliderTimePanel, 'position');
set(handles.sliderTimePanel, 'position',[axPos(1) timeSliderPos(2), axPos(3), timeSliderPos(4)]);

if isfield(handles, 'Id')   % otherwise it gives error during im_browser startup
    handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

im_browser_winMouseMotionFcn(handles.im_browser, NaN, handles);
guidata(handles.im_browser, handles);
end