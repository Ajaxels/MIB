function mib_calibrateScaleBar(handles)
% function mib_calibrateScaleBar(handles)
% Obtain physical X and Y size of pixels using a scale bar plotted on the
% loaded image
%
% Parameters:
% handles: handles structure from im_browser
% Return values:
% 

%| 
% @b Examples:
% @code mib_calibrateScaleBar(handles);     // calibrate pixel sizes @endcode


% Copyright (C) 05.10.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

choice = questdlg(sprintf('The following procedure allows to define the pixel size for the dataset using a scale bar displayed on the image.\n\nHow to use:\n1. With the left mouse button mark the end points of the scale bar\n2. Double click on the line to confirm the selection\n3. Enter the length of the scale bar'),'Scale bar info','Continue','Cancel','Cancel');
if strcmp(choice, 'Cancel'); return; end;
    
answer = mib_inputdlg(handles, sprintf('Please enter length of the scale bar, keep the space character between the number and the unit;\nyou can use the following units:\n m, cm, mm, um, nm'),'Scale bar lenght', '2 um');
if isempty(answer);  
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    return; 
end;
answer = answer{1};
spaceChar = strfind(answer, ' ');

%disableSelectionSwitch = handles.preferences.disableSelection;    % get current settings for selection
%handles.preferences.disableSelection = 'yes'; % disable selection
%guidata(handles.im_browser, handles);
brushSize = get(handles.segmSpotSizeEdit,'string');
set(handles.segmSpotSizeEdit,'string', '0');

result = handles.Img{handles.Id}.I.hMeasure.DistanceFun(handles); % use Measure class to draw a line above the scale bar
%handles.preferences.disableSelection = disableSelectionSwitch ;    % restore settings for selection
set(handles.segmSpotSizeEdit,'string', brushSize);

if result == 0; 
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
    return; 
end;
xCoord = handles.Img{handles.Id}.I.hMeasure.Data(end).X;    % get the X coordinates in pixels
yCoord = handles.Img{handles.Id}.I.hMeasure.Data(end).Y;    % get the Y coordinates in pixels
distPix = sqrt((xCoord(1)-xCoord(2))^2 + (yCoord(1)-yCoord(2))^2);  % calculate the distance between two selected points
handles.Img{handles.Id}.I.hMeasure.removeMeasurements(handles.Img{handles.Id}.I.hMeasure.getNumberOfMeasurements());    % remove this measurement from the list

scaleLength = str2double(answer(1:spaceChar));
pixSize.units = answer(spaceChar+1:end);
pixSize.x = scaleLength / distPix;
pixSize.y = scaleLength / distPix;
pixSize.z = scaleLength / distPix;

handles.Img{handles.Id}.I.updateParameters(pixSize);
handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);

end