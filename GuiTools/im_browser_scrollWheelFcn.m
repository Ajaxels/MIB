function im_browser_scrollWheelFcn(hObject, eventdata, handles) 
% function im_browser_scrollWheelFcn(hObject, eventdata, handles) 
% Control callbacks from mouse scroll wheel 
%
% This function takes care of the mouse wheel. Depending on a key modifier and
% @em handles.mouseWheelToolbarSw it can:
% @li Ctrl+mouse wheel, change size of the brush and some other tools. The
% value of the new size value is displayed next to the cursor during the mouse
% wheel rotation.
% @li when @em handles.mouseWheelToolbarSw is not pressed, the mouse wheel
% is used for zoom in/zoom out actions.
% @li when @em handles.mouseWheelToolbarSw is pressed, the mouse wheel is
% used to change slices of the shown 3D dataset.
%
% Parameters:
% hObject: a handle to the object from where the call was implemented
% eventdata: additinal parameters
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices to cells


handles = guidata(handles.im_browser);  % update handles structure

modifier = get(handles.im_browser,'currentmodifier');   % change size of the brush tool, when the Ctrl key is pressed
if strcmp(modifier, 'control') | strcmp(cell2mat(modifier), 'shiftcontrol') | strcmp(cell2mat(modifier), 'controlalt') | strcmp(cell2mat(modifier), 'shiftcontrolalt') %#ok<OR2>
    step = 1;   % step of the brush size change
    if strcmp(cell2mat(modifier), 'shiftcontrol') || strcmp(cell2mat(modifier), 'shiftcontrolalt')
        step = 5;
    end;
    toolList = get(handles.seltypePopup,'string');
    toolName = strtrim(toolList{get(handles.seltypePopup,'value')});
    switch toolName
        case '3D ball'
            h1 = handles.segmSpotSizeEdit;
        case {'Brush', 'Smart Watershed'}
            if strcmp(cell2mat(modifier), 'controlalt') || strcmp(cell2mat(modifier), 'shiftcontrolalt')
                h1 = handles.superpixelsNumberEdit;
            else
                h1 = handles.segmSpotSizeEdit;
            end
        case 'Object Picker'
            h1 = handles.maskBrushSizeEdit;
        case 'Membrane ClickTracker'
            h1 = handles.segmTrackWidthEdit;
        case 'Spot'
            h1 = handles.segmSpotSizeEdit;
        case 'MagicWand-RegionGrowing'
            h1 = handles.selectiontoolEdit;
        otherwise
            return;
    end
    text = get(handles.pixelinfoTxt2,'String');
    colon = strfind(text,':');
    text = str2double(text(strfind(text,'(')+1:colon(2)-1));
    colorText = 1;
    if text < double(intmax(class(handles.Img{handles.Id}.I.img))/2)
        colorText = 2;
    end
    
    val = str2double(get(h1,'String'));
    
    % modification to release increase of the brush radius for the eraser
    if handles.ctrlPressed > 0 && h1 == handles.segmSpotSizeEdit
        val = val - handles.ctrlPressed;
        handles.ctrlPressed = -1;
        set(h1,'String', num2str(val));
        handles = ib_updateCursor(handles);
    end
    
    if eventdata.VerticalScrollCount < 0
        val = val + step;
    else
        val = val - step;
        if val < 1; val = 1; end;
    end
    
    % add cursor text
    %base = 1-imread('numbers.png');   % height=16, pixel size = 7, +1 pixel border
    table='1234567890';
    if val < 100
        text_str = num2str(val);
    else
        text_str = '99';
    end
    
    try
        for i=1:numel(text_str)
            coord(i) = (find(table == text_str(i))-1)*8 + 1; %#ok<AGROW>
        end
    catch err
        0
    end
    valuePointer = zeros([16 16]);
    for index = 1:numel(text_str)
        valuePointer(1:16, index*8-7:index*8) = handles.brushSizeNumbers(1:16,coord(index):coord(index)+7)*colorText;
    end
    valuePointer(valuePointer==0) = NaN;
    valuePointer(1:5,3) = colorText;
    valuePointer(3,1:5) = colorText;
    set(handles.im_browser, 'pointer', 'custom', 'pointershapecdata', valuePointer);
    set(h1,'String',num2str(val));
    ib_updateCursor(handles);
    %guidata(handles.im_browser, handles);
    return;
end

% check whether the mouse cursor within the axes.
position=get(handles.imageAxes,'currentpoint');
axXLim=get(handles.imageAxes,'xlim');
axYLim=get(handles.imageAxes,'ylim');
x = round(position(1,1));
y = round(position(1,2));
if x<axXLim(1) || x>axXLim(2) || y<axYLim(1) || y>axYLim(2)
    return;
end

if strcmp(get(handles.mouseWheelToolbarSw,'state'),'on') & (strcmp(modifier, 'alt') | strcmp(cell2mat(modifier), 'shiftalt'))               %#ok<OR2,AND2> % change time point with Alt
    if strcmp(cell2mat(modifier), 'shiftalt')
        shift = handles.sliderShiftStep;
    else
        shift = 1;
    end

    new_index = handles.Img{handles.Id}.I.slices{5}(1) + eventdata.VerticalScrollCount*shift;
    if new_index < 1;  new_index = 1; end;
    if new_index > handles.Img{handles.Id}.I.time; new_index = handles.Img{handles.Id}.I.time; end;
    set(handles.changeTimeSlider, 'value', new_index);     % update slider value
    changeTimeSlider_Callback(handles.changeTimeSlider, eventdata, handles);
elseif strcmp(get(handles.mouseWheelToolbarSw,'state'),'off')                % zoom in/zoom out with the mouse wheel
    % Power law allows for the inverse to work:
    %      C^(x) * C^(-x) = 1
    % Choose C to get "appropriate" zoom factor
    C = 1.10;
    %             ch = get(handles.im_browser, 'CurrentCharacter');
    %             if ch == '`'    % change size of the brush
    %                 brush = str2double(get(handles.segmSpotSizeEdit,'String'));
    %                 brush = max([1 brush+eventdata.VerticalScrollCount]);
    %                 set(handles.segmSpotSizeEdit,'String',num2str(brush));
    %                 set(handles.im_browser, 'CurrentCharacter', '1');
    %                 return;
    %             end
    
    curPt  = mean(get(handles.imageAxes, 'currentpoint'));
    curPt = curPt(1:2);  % mouse coordinates
    
    % modify curPt with shifts that come from handles.Img{handles.Id}.I.axesX/handles.Img{handles.Id}.I.axesY and magnification factor
    curPt(1) = curPt(1)*handles.Img{handles.Id}.I.magFactor + max([0 handles.Img{handles.Id}.I.axesX(1)]);
    curPt(2) = curPt(2)*handles.Img{handles.Id}.I.magFactor + max([0 handles.Img{handles.Id}.I.axesY(1)]);
    xl = handles.Img{handles.Id}.I.axesX;
    yl = handles.Img{handles.Id}.I.axesY;
    % zoom will work only when the mouse is above the image
    if curPt(1)<xl(1) || curPt(1)>xl(2); return; end;
    if curPt(2)<yl(1) || curPt(2)>yl(2); return; end;
    
    midX = mean(xl);
    rngXhalf = diff(xl) / 2; % half-width of the shown image
    midY = mean(yl);
    rngYhalf = diff(yl) / 2; % half-height of the shown image
    
    curPt2 = (curPt-[midX, midY]) ./ [rngXhalf, rngYhalf];  % image shift in %%
    curPt  = [curPt; curPt];
    curPt2 = [-(1+curPt2).*[rngXhalf, rngYhalf];...
        (1-curPt2).*[rngXhalf, rngYhalf]];           % new image half-sizes without zooming
    
    r = C^(eventdata.VerticalScrollCount*eventdata.VerticalScrollAmount);
    newLimSpan = r * curPt2;
    
    % Determine new limits based on r
    lims = curPt + newLimSpan;
    
    % check out of image bounds conditions
    if lims(1,1) < 0 && lims(2,1) < 0; return; end;
    if lims(1,2) < 0 && lims(2,2) < 0; return; end;
    if lims(1,1) > handles.Img{handles.Id}.I.width && lims(2,1) > handles.Img{handles.Id}.I.width; return; end;
    if lims(1,2) > handles.Img{handles.Id}.I.height && lims(2,2) > handles.Img{handles.Id}.I.height; return; end;
    
    handles.Img{handles.Id}.I.magFactor = handles.Img{handles.Id}.I.magFactor*r;
    handles.Img{handles.Id}.I.axesX = lims(:,1)';
    handles.Img{handles.Id}.I.axesY = lims(:,2)';
    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
else    % slice change with the mouse wheel
    %selType = get(handles.im_browser,'SelectionType');
    %get(handles.im_browser,'currentmodifier')
    modifier = get(handles.im_browser,'currentmodifier');
    if strcmp(modifier,'shift')
        shift = handles.sliderShiftStep;
    else
        shift = 1;
    end
    new_index = handles.Img{handles.Id}.I.slices{handles.Img{handles.Id}.I.orientation}(1) - eventdata.VerticalScrollCount*shift;
    if new_index < 1;  new_index = 1; end;
    if new_index > size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation); new_index = size(handles.Img{handles.Id}.I.img, handles.Img{handles.Id}.I.orientation); end;
    set(handles.changelayerSlider, 'value', new_index);     % update slider value
    changelayerSlider_Callback(handles.changelayerSlider, eventdata, handles);
end
end