function volren_WindowButtonDownFcn(hObject, eventdata, handles)
xy = get(handles.imageAxes, 'currentpoint');

axXLim=get(handles.imageAxes,'xlim');
axYLim=get(handles.imageAxes,'ylim');
if xy(1, 1)<axXLim(1) || xy(1, 1)>axXLim(2) || ...
        xy(1, 2)<axYLim(1) || xy(1, 2)>axYLim(2) % mouse pointer within the current axes
    return;
end

if (~isempty(xy))
    axes_size(1) = handles.Img{handles.Id}.I.axesX(2)-handles.Img{handles.Id}.I.axesX(1);
    axes_size(2) = handles.Img{handles.Id}.I.axesY(2)-handles.Img{handles.Id}.I.axesY(1);
    handles.Img{handles.Id}.I.brush_prev_xy = [xy(1, 1) xy(1, 2)]./axes_size(1:2);  % as fraction of the viewing axes
end
seltype = get(handles.im_browser, 'selectiontype');
handles.Img{handles.Id}.I.volren.showFullRes = 0;
if handles.Img{handles.Id}.I.volren.showFullRes == 0;
    S = makehgtform('scale',1/handles.Img{handles.Id}.I.volren.previewScale);
    handles.Img{handles.Id}.I.volren.viewer_matrix = handles.Img{handles.Id}.I.volren.viewer_matrix*S;
end

if strcmp(seltype, 'normal')
    cursorIcon=[NaN NaN NaN NaN NaN NaN NaN NaN NaN 1 1 NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN NaN NaN NaN 1 1 1 NaN NaN NaN NaN NaN;
        NaN NaN NaN NaN NaN NaN NaN 1 1 1 1 NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN NaN NaN 1 1 NaN NaN NaN NaN NaN NaN NaN;
        NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN;
        NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN; NaN NaN 1 NaN NaN NaN 1 1 1 1 NaN NaN NaN NaN NaN NaN;
        NaN 1 1 1 1 1 NaN 1 NaN NaN 1 1 1 1 1 1; 1 1 1 1 NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN 1 1;
        1 1 1 1 NaN NaN NaN 1 NaN NaN NaN NaN NaN 1 1 1; 1 NaN NaN NaN NaN NaN NaN NaN 1 NaN 1 NaN NaN NaN 1 1;
        NaN NaN NaN NaN NaN NaN NaN NaN 1 1 1 NaN NaN NaN NaN 1; NaN NaN NaN NaN NaN NaN NaN 1 1 1 1 NaN NaN NaN NaN NaN;
        NaN NaN NaN NaN NaN NaN NaN NaN 1 1 1 NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN];
else
    cursorIcon=[NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN NaN 1 NaN 1 NaN NaN NaN NaN NaN NaN NaN;
        NaN NaN NaN NaN NaN 1 1 NaN 1 1 NaN NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN 1 NaN 1 NaN 1 NaN NaN NaN NaN NaN NaN;
        NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN; NaN NaN 1 1 NaN NaN NaN 1 NaN NaN NaN 1 1 NaN NaN NaN;
        NaN 1 1 NaN NaN NaN NaN 1 NaN NaN NaN NaN 1 1 NaN NaN; 1 NaN NaN 1 1 1 1 1 1 1 1 1 NaN NaN 1 NaN;
        NaN 1 1 NaN NaN NaN NaN 1 NaN NaN NaN NaN 1 1 NaN NaN; NaN NaN 1 1 NaN NaN NaN 1 NaN NaN NaN 1 1 NaN NaN NaN;
        NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN 1 NaN 1 NaN 1 NaN NaN NaN NaN NaN NaN;
        NaN NaN NaN NaN NaN 1 1 NaN 1 1 NaN NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN NaN 1 NaN 1 NaN NaN NaN NaN NaN NaN NaN;
        NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
end
set(handles.im_browser,'Pointer','custom');
set(handles.im_browser, 'PointerShapeCData', cursorIcon, 'PointerShapeHotSpot', round(size(cursorIcon)/2))

set(handles.im_browser, 'WindowButtonMotionFcn' , {@volren_WindowInteractMotionFcn, handles, seltype});
set(handles.im_browser, 'WindowButtonUpFcn', {@volren_WindowButtonUpFcn, handles});
end
