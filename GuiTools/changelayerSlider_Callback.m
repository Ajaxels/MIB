function changelayerSlider_Callback(hObject, eventdata, handles)
% function changelayerSlider_Callback(~, eventdata, handles)
% A callback function for handles.changelayerSlider. Responsible for showing next or previous slice of the dataset
%
% Parameters:
% hObject: a handle to the calling object
% eventdata: eventdata structure of Matlab
% handles: handles structure of im_browser.m

% Copyright (C) 21.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices to cells


% update handles, needed for slider listener, initialized in im_browser_getDefaultParameters() 
handles = guidata(hObject);

value = get(handles.changelayerSlider,'Value');
value_str = sprintf('%.0f',value);
set(handles.changelayerEdit,'String',value_str);
value = str2double(value_str);
if handles.Img{handles.Id}.I.orientation == 1 %'xz'
    handles.Img{handles.Id}.I.slices{1} = [value, value];
elseif handles.Img{handles.Id}.I.orientation == 2 %'yz'
    handles.Img{handles.Id}.I.slices{2} = [value, value];
elseif handles.Img{handles.Id}.I.orientation == 4 %'yx'
    % update label text for the image view panel
    if isKey(handles.Img{handles.Id}.I.img_info, 'SliceName')
        % use getfield to get exact value as suggested by Ian M. Garcia in
        % http://stackoverflow.com/questions/3627107/how-can-i-index-a-matlab-array-returned-by-a-function-without-first-assigning-it
        layerNamePrevious = getfield(handles.Img{handles.Id}.I.img_info('SliceName'), {min([handles.Img{handles.Id}.I.slices{4}(1) numel(handles.Img{handles.Id}.I.img_info('SliceName'))])}); %#ok<GFLD>
        layerNameNext = getfield(handles.Img{handles.Id}.I.img_info('SliceName'), {min([value numel(handles.Img{handles.Id}.I.img_info('SliceName'))])}); %#ok<GFLD>
        if strcmp(layerNamePrevious{1}, layerNameNext{1}) == 0  % update label
            strVal1 = 'Image View    >>>>>    ';
            %strVal = sprintf('Image View    >>>>>    %s    >>>>>    %s', handles.Img{handles.Id}.I.img_info('Filename'), layerNameNext{1});
            [~, fn, ext] = fileparts(handles.Img{handles.Id}.I.img_info('Filename'));
            strVal2 = sprintf('%s%s    >>>>>    %s', fn, ext, layerNameNext{1});
            set(handles.imagePanel, 'Title', [strVal1 strVal2]);    
        end
    end
    handles.Img{handles.Id}.I.slices{4} = [value, value];
end

% % add a label to the image view panel
% if isKey(handles.Img{handles.Id}.I.img_info, 'SliceName') && handles.Img{handles.Id}.I.orientation == 4   %'yx'
%     % from http://stackoverflow.com/questions/3627107/how-can-i-index-a-matlab-array-returned-by-a-function-without-first-assigning-it
%     layerName = builtin('_paren', handles.Img{handles.Id}.I.img_info('SliceName'), current); 
%     set(handles.imagePanel, 'Title', sprintf('Image View   %s    >>>>>    %s', handles.Img{handles.Id}.I.img_info('Filename'), layerName{1}));
% else
%     set(handles.imagePanel, 'Title', sprintf('Image View   %s', handles.Img{handles.Id}.I.img_info('Filename')));    
% end

im_browser_winMouseMotionFcn(handles.im_browser, NaN, handles);
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
%unFocus(hObject);   % remove focus from hObject
end
