function menuMaskImport(hObject, eventdata, handles)
% function loadModelBtn(hObject, eventdata, handles)
% a callback to Menu->Mask->Import
% imports the Mask layer from the main Matlab workspace
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 17.02.2016, IB, updated for 4D datasets


% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); 
    warndlg(sprintf('The mask layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The masks are disabled','modal');
    return; 
end;

answer = mib_inputdlg(handles, 'Mask variable (1:h,1:w,1:z,1:t)','Import from Matlab','M');
if size(answer) == 0; return; end;
if (~isempty(answer{1}))
    try
        mask = evalin('base',answer{1});
    catch exception
        errordlg(sprintf('The variable was not found in the Matlab base workspace:\n\n%s', exception.message),'Misssing variable!','modal');
        return;
    end
    if size(mask,1) ~= size(handles.Img{handles.Id}.I.img,1) || size(mask,2) ~= size(handles.Img{handles.Id}.I.img,2) || size(mask,3) ~= handles.Img{handles.Id}.I.no_stacks
        msgbox(sprintf('Mask and image dimensions mismatch!\nImage (HxWxZ) = %d x %d x %d pixels\nMask (HxWxZ) = %d x %d x %d pixels',...
            handles.Img{handles.Id}.I.height, handles.Img{handles.Id}.I.width, handles.Img{handles.Id}.I.no_stacks, size(mask,1), size(mask,2), size(mask,3)),'Error!','error','modal');
        return;
    end
    ib_do_backup(handles, 'mask', 1);
    
    if size(mask,3) == 1
        if ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
            if handles.Img{handles.Id}.I.maskExist == 0
                handles.Img{handles.Id}.I.maskImg = zeros(size(handles.Img{handles.Id}.I.img,1),size(handles.Img{handles.Id}.I.img,2),size(handles.Img{handles.Id}.I.img,4),'uint8');
            end
        end
        handles.Img{handles.Id}.I.setCurrentSlice('mask',mask);
    elseif size(mask,3) == size(handles.Img{handles.Id}.I.img,4) && size(mask,4) == 1
        options.blockModeSwitch = 0;
        handles.Img{handles.Id}.I.setData3D('mask', mask, NaN, 4, NaN, options);
    elseif size(mask,4) == handles.Img{handles.Id}.I.time
        options.blockModeSwitch = 0;
        handles.Img{handles.Id}.I.setData4D('mask', mask, 4, NaN, options);        
    end
    [pathstr, name] = fileparts(handles.Img{handles.Id}.I.img_info('Filename'));
    handles.Img{handles.Id}.I.maskImgFilename = fullfile(pathstr, 'importMask.mask');
end
handles.Img{handles.Id}.I.maskExist = 1;
set(handles.maskShowCheck,'Value',1);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end