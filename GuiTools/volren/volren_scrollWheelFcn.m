function volren_scrollWheelFcn(hObject, eventdata, handles)
modifier = get(handles.im_browser,'currentmodifier');   % change size of the brush tool, when the Ctrl key is pressed
scaleF = 1;
if strcmp(modifier, 'shift');
    scaleF = 5;
end
z = 1+(0.1*eventdata.VerticalScrollCount*scaleF);

handles.Img{handles.Id}.I.magFactor = handles.Img{handles.Id}.I.magFactor * z;
S = makehgtform('scale', 1/z);
handles.Img{handles.Id}.I.volren.viewer_matrix = S * handles.Img{handles.Id}.I.volren.viewer_matrix;

set(handles.zoomEdit, 'string', sprintf('%d %%',round(1/handles.Img{handles.Id}.I.magFactor*100)));
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

