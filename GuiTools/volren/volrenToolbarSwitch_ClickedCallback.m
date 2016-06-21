function volrenToolbarSwitch_ClickedCallback(hObject, eventdata, handles, parameter)
if nargin < 4; parameter = ''; end;

if strcmp(parameter, 'toolbar') && strcmp(get(handles.volrenToolbarSwitch, 'state'), 'on')
    getDataOptions.blockModeSwitch = 0;
    [h,w,c,z] = handles.Img{handles.Id}.I.getDatasetDimensions('image', 4, 0, getDataOptions);
    if h*w*c*z > 250000000
        button = questdlg(sprintf('!!! Warning !!!\n\nThe volume rendering large datasets is very slow\nAre you sure that you want to proceed further?'),'Volume Rendering','I am sure, please render','Cancel','Cancel');     
        if strcmp(button, 'Cancel')
            set(handles.volrenToolbarSwitch, 'state', 'off');
            return;
        end
    end
end

if strcmp(get(handles.volrenToolbarSwitch, 'state'), 'on')
    set(handles.im_browser, 'WindowButtonDownFcn', {@volren_WindowButtonDownFcn, handles});
    set(handles.im_browser, 'WindowKeyPressFcn', ''); 
    set(handles.im_browser, 'WindowButtonMotionFcn' , {@volren_winMouseMotionFcn, handles});
    set(handles.im_browser, 'WindowScrollWheelFcn', {@volren_scrollWheelFcn, handles});
    
    %if isempty(handles.Img{handles.Id}.I.volren.previewImg)
%         R = [0 0 0];
%         S = [1*handles.Img{handles.Id}.I.magFactor,...
%              1*handles.Img{handles.Id}.I.magFactor,...
%              1*handles.Img{handles.Id}.I.pixSize.x/handles.Img{handles.Id}.I.pixSize.z*handles.Img{handles.Id}.I.magFactor];  
%         T = [5 5 5];
%         handles.Img{handles.Id}.I.volren.viewer_matrix = makeViewMatrix(R, S, T);
    %end
    
    if isempty(handles.Img{handles.Id}.I.volren.previewImg)
        handles.Img{handles.Id}.I.volren.previewScale = 256/size(handles.Img{handles.Id}.I.img, 1);
        getDataOptions.blockModeSwitch = 0;
        resizeOpt.imgType = '4D';
        resizeOpt.method = 'nearest';
        handles.Img{handles.Id}.I.volren.previewImg = mib_resize3d(handles.Img{handles.Id}.I.getData3D('image', NaN, 4, 0, getDataOptions), handles.Img{handles.Id}.I.volren.previewScale, resizeOpt);
        handles.Img{handles.Id}.I.volren.Rx = 0;
        handles.Img{handles.Id}.I.volren.Ry = 0;
        handles.Img{handles.Id}.I.volren.Rz = 0;
    end
    handles.Img{handles.Id}.I.volren.showFullRes = 1;
else
    set(handles.im_browser, 'windowbuttondownfcn', {@im_browser_WindowButtonDownFcn, handles});
    set(handles.im_browser, 'WindowKeyPressFcn', {@im_browser_WindowKeyPressFcn, handles}); % turn ON callback for the keys
    set(handles.im_browser, 'WindowScrollWheelFcn', {@im_browser_scrollWheelFcn, handles});
    set(handles.im_browser, 'WindowButtonMotionFcn' , {@im_browser_winMouseMotionFcn, handles});
end

% plot image when the function is triggered from the toolbar
if strcmp(parameter, 'toolbar')
    set(handles.Img{handles.Id}.I.imh, 'CData', [], 'UserData', 'new');
    handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
else
    guidata(handles.im_browser, handles);
end
end
