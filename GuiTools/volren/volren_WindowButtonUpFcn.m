function volren_WindowButtonUpFcn(hObject, eventdata, handles)
set(hObject, 'pointer', 'crosshair');
set(hObject, 'WindowButtonUpFcn', '');

if handles.Img{handles.Id}.I.volren.showFullRes == 0;
    S = makehgtform('scale', handles.Img{handles.Id}.I.volren.previewScale) ;
    handles.Img{handles.Id}.I.volren.viewer_matrix = handles.Img{handles.Id}.I.volren.viewer_matrix * S;
end

handles.Img{handles.Id}.I.volren.showFullRes = 1;
set(handles.im_browser, 'WindowButtonDownFcn', {@volren_WindowButtonDownFcn, handles});
set(handles.im_browser, 'WindowButtonMotionFcn' , {@volren_winMouseMotionFcn, handles});
handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end
