function menuMaskInvert(hObject, eventdata, handles)
% function menuMaskInvert(hObject, eventdata, handles)
% a callback to Menu->Mask->Invert
% inverts the Mask layer
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% 14.05.2014, Ilya Belevich, ilya.belevich @ helsinki.fi% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

ib_do_backup(handles, 'mask', 1);
if ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
    mask = ib_getDataset('mask', handles);
    for roi=1:numel(mask)
        mask{roi} = 1 - mask{roi};
    end
    ib_setDataset('mask', mask, handles);
else
    mask = ib_getDataset('everything', handles);
    for roi=1:numel(mask)
        mask{roi} = bitxor(mask{roi},64);
    end
    ib_setDataset('everything', mask, handles);
end
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end