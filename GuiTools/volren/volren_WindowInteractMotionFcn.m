function volren_WindowInteractMotionFcn(hObject, ~, handles, seltype)
xy = get(handles.imageAxes, 'currentpoint');
if (~isempty(xy))
    axes_size(1) = handles.Img{handles.Id}.I.axesX(2)-handles.Img{handles.Id}.I.axesX(1);
    axes_size(2) = handles.Img{handles.Id}.I.axesY(2)-handles.Img{handles.Id}.I.axesY(1);
    brush_curr_xy = [xy(1, 1) xy(1, 2)]./axes_size(1:2);  % as fraction of the viewing axes
end

if strcmp(seltype, 'normal')    % rotation
    dx = handles.Img{handles.Id}.I.brush_prev_xy(1) - brush_curr_xy(1);
    dy = handles.Img{handles.Id}.I.brush_prev_xy(2) - brush_curr_xy(2);
    r1 = -360*dx;   % r1 = radtodeg(atan2(R(3,2), R(3,3)));
    r2 = 360*dy;    % r2 = radtodeg(atan2(-R(3,1), sqrt( R(3,2)^2+R(3,3)^2 )));
    R = RotationMatrix([r1, r2, 0]);

    %r3 = radtodeg(atan2(R(2,1), R(1,1)));
    
    %handles.Img{handles.Id}.I.volren.Rx = mod(handles.Img{handles.Id}.I.volren.Rx + r1, 360);
    %handles.Img{handles.Id}.I.volren.Ry = mod(handles.Img{handles.Id}.I.volren.Ry + r2, 360);
    %handles.Img{handles.Id}.I.volren.Rz = mod(handles.Img{handles.Id}.I.volren.Rz + r3, 360);
    %sprintf('Rx=%f, Ry=%f, Rz=%f\n', handles.Img{handles.Id}.I.volren.Rx, handles.Img{handles.Id}.I.volren.Ry, handles.Img{handles.Id}.I.volren.Rz)
    
    handles.Img{handles.Id}.I.volren.viewer_matrix = R*handles.Img{handles.Id}.I.volren.viewer_matrix;
elseif strcmp(seltype, 'alt')   % pan
    t2=550*(handles.Img{handles.Id}.I.brush_prev_xy(1) - brush_curr_xy(1));
    t1=550*(handles.Img{handles.Id}.I.brush_prev_xy(2) - brush_curr_xy(2));
    
    handles.Img{handles.Id}.I.volren.T = TranslateMatrix([t1 t2 0]);
    T = TranslateMatrix([t1 t2 0]);
    handles.Img{handles.Id}.I.volren.viewer_matrix = T*handles.Img{handles.Id}.I.volren.viewer_matrix;
end
handles.Img{handles.Id}.I.brush_prev_xy = brush_curr_xy;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end

function R = RotationMatrix(r)
% Determine the rotation matrix (View matrix) for rotation angles xyz ...
Rx=[1 0 0 0;                     0 cosd(r(1)) -sind(r(1)) 0;     0 sind(r(1)) cosd(r(1)) 0;    0 0 0 1];
Ry=[cosd(r(2)) 0 sind(r(2)) 0;   0 1 0 0;                        -sind(r(2)) 0 cosd(r(2)) 0;   0 0 0 1];
Rz=[cosd(r(3)) -sind(r(3)) 0 0;  sind(r(3)) cosd(r(3)) 0 0;      0 0 1 0;                      0 0 0 1];
R=Rx*Ry*Rz;
end

function M = TranslateMatrix(t)
M=[1 0 0 -t(1);
    0 1 0 -t(2);
    0 0 1 -t(3);
    0 0 0 1];
%M = makehgtform('translate',-t(1),-t(2),-t(3)) ;
end

