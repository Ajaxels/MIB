function imfiltPar1Edit_Callback(hObject, eventdata, handles)
% function imfiltPar1Edit_Callback(hObject, eventdata, handles)
% a callback to the handles.imfiltPar1Edit, checks parameters for image filters
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


list = get(handles.imageFilterPopup,'String');
val = get(handles.imageFilterPopup,'Value');
switch cell2mat(list(val))
    case {'Gaussian','Average','Log','Gaussian 3D','Wiener 2D','Median 2D'}
        editbox_Callback(handles.imfiltPar1Edit,eventdata,handles,'posintx2','3',[1,NaN]);
    case {'Disk','Motion'}
        editbox_Callback(handles.imfiltPar1Edit,eventdata,handles,'pint','3',[1,NaN]);
    case {'Unsharp'}
        if handles.matlabVersion < 8.1
            editbox_Callback(handles.imfiltPar1Edit,eventdata,handles,'pfloat','.5',[0.0001,1]);
        else
            editbox_Callback(handles.imfiltPar1Edit,eventdata,handles,'pfloat','1',[0.0001,NaN]);
        end
    case {'Frangi 2D','Frangi 3D'}
        editbox_Callback(handles.imfiltPar1Edit,eventdata,handles,'intrange','1-6');
        editbox_Callback(handles.imfiltPar2Edit,eventdata,handles,'pint','2',[1,NaN]);
        editbox_Callback(handles.imfiltPar3Edit,eventdata,handles,'pfloat', '0.9');
        editbox_Callback(handles.imfiltPar4Edit,eventdata,handles,'pfloat','15');
        editbox_Callback(handles.imfiltPar5Edit,eventdata,handles,'pint','500',[1,NaN]);
    case {'Perona Malik anisotropic diffusion','Diplib: Perona Malik anisotropic diffusion','Diplib: Robust Anisotropic Diffusion',...
            'Diplib: Mean Curvature Diffusion','Diplib: Corner Preserving Diffusion','Diplib: Kuwahara filter for edge-preserving smoothing'}
        editbox_Callback(handles.imfiltPar1Edit,eventdata,handles,'pint','10',[1,NaN]);
        editbox_Callback(handles.imfiltPar2Edit,eventdata,handles,'pint','10',[1,NaN]);
        editbox_Callback(handles.imfiltPar3Edit,eventdata,handles,'pfloat','.25',[0,NaN]);
end
end