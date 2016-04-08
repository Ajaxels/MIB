function mib_contrastContext_cb(hObject, ~, parameter)
% adjust contrast context menu callback
%
% Parameters:
% hObject: a handle to the calling object
% eventdata: eventdata structure of Matlab
% parameter: - a string that defines options:
% @li showhist - Show histogram
% @li CLAHE_2D - Contrast-limited adaptive histogram equalization for current stack'
% @li CLAHE_3D - Contrast-limited adaptive histogram equalization for current stack
% @li CLAHE_3D - Contrast-limited adaptive histogram equalization for complete volume


% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}

 
 handles = guidata(hObject);
 % adjust contrast
 if numel(handles.Img{handles.Id}.I.slices{3}) ~= 1    % get color channel from the selected in the Selection panel
     colCh = get(handles.ColChannelCombo,'Value') - 1;
     if colCh == 0
         msgbox('Please select the color channel!','Error!','error','modal');
         return;
     end
 else    % when only one color channel is shown, take it
     colCh = handles.Img{handles.Id}.I.slices{3};
 end

 switch parameter
     case 'showhist'  % set brightness on the screen to be the same as in the image
         figure(5137);
         h = imshow(handles.Img{handles.Id}.I.getCurrentSlice('image', colCh));
         imcontrast(h);
         warndlg(sprintf('Attention!\nThis will open the selected image only for estimation of contrast values.\nPlease note desired Minimum and Maximum values and use them when clicking the Contrast button\n'),'Warning!','modal');
     case {'CLAHE_2D','CLAHE_3D','CLAHE_4D'}
         handles = ib_contrastCLAHE(handles, parameter);
 end
 handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
 end