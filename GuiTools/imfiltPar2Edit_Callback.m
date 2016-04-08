function imfiltPar2Edit_Callback(hObject, eventdata, handles)
% function imfiltPar2Edit_Callback(hObject, eventdata, handles)
% a callback to the handles.imfiltPar2Edit, checks parameters for image filters
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
    case 'Unsharp'
        if handles.matlabVersion >= 8.1
            editbox_Callback(handles.imfiltPar2Edit,eventdata,handles,'pfloat','1.2',[0.001,10]);
        end
    otherwise
        editbox_Callback(handles.imfiltPar2Edit,eventdata,handles,'pfloat','1',[0.001,NaN]);
end
end