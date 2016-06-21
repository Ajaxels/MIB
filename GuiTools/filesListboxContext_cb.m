function filesListboxContext_cb(hObject, eventdata, parameter)
% function filesListboxContext_cb(hObject, eventdata, parameter)
% a context menu to the to the handles.filesListbox, the menu is called
% with the right mouse button
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% parameter: a string with parameters for the function
% @li 'load' - Combine selected datasets
% @li 'loadPart' - Load part of the dataset
% @li 'nth' - Load each N-th dataset
% @li 'insertData' - Insert into the open dataset
% @li 'combinecolors' - Combine files as color channels
% @li 'addchannel' - Add as a new color channel
% @li 'addchannel_nth' - Add each N-th dataset as a new color channel
% @li 'rename' - Rename selected file
% @li 'delete' - Delete selected files
% @li 'file_properties' - File properties

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 



% generate a dataset from the selected files
handles = guidata(hObject);
% generate list of files
val = get(handles.filesListbox, 'Value');
list = get(handles.filesListbox, 'String');
filename = list(val);
options.bioformatsCheck = get(handles.bioformatsCheck,'Value');
options.progressDlg = 1;
index = 1;

if (strcmp(parameter, 'nth') || strcmp(parameter, 'addchannel_nth')) && numel(filename) == 1     % combines all files in the directory starting from the selected
    filename = list(val:end);
else
    filename = list(val);       % take the selected datasets
end

for i=1:numel(filename)
    if ~strcmp(filename{i}, '.') && ~strcmp(filename{i}, '..') && filename{i}(1) ~= '['
        fn(index) = cellstr(fullfile(handles.mypath, filename{i})); %#ok<AGROW>
        index = index + 1;
    end
end
if index<=1; 
    errordlg(sprintf('No files were selected!!!\nPlease select desired files and try again!\nYou can use Ctrl and Shift for the selection.'),'Wrong selection!');
    return; 
end    % no files were selected
if strcmp(parameter, 'nth') || strcmp(parameter, 'addchannel_nth')
    answer = mib_inputdlg(handles, sprintf('Please enter the step:\n\nFor example when step is 2 \nim_browser loads each second dataset'),'Enter the step','2');
    if isempty(answer); return; end;
    step = str2double(cell2mat(answer));
    idx = 1;
    for i=1:step:numel(fn)
        fn2(idx) = fn(i);
        idx = idx + 1;
    end
    fn = fn2;
end

switch parameter
    case {'load' 'nth','loadPart','combinecolors'}
        if val < 3; return; end;
        handles.Img{handles.Id}.I.clearContents();
        if strcmp(parameter, 'loadPart')
            options.customSections = 1;     % to load part of the dataset, for AM only
        end
        [img, img_info, ~] = ib_loadImages(fn, options, handles);
        if isnan(img);
            if handles.preferences.uint8
                handles.Img{handles.Id}.I = imageData(handles, 'uint8');    % create instanse for keeping images
            else
                handles.Img{handles.Id}.I = imageData(handles, 'uint6');    % create instanse for keeping images
            end
            handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
            return;
            
        end;
        if strcmp(parameter, 'combinecolors') 
            %img = squeeze(img);
            img = reshape(img, [size(img,1), size(img,2), size(img,3)*size(img,4)]);
            img_info('ColorType') = 'truecolor';
            if isKey(img_info, 'lutColors')
                currColors = img_info('lutColors');
                lutColors = currColors;
                index1 = size(lutColors,1);
                index2 = 1;
                while size(lutColors,1) < size(img,3)
                    lutColors(index1+1, :) = currColors(index2,:);
                    index1 = index1 + 1;
                    index2 = index2 + 1;
                    if index2 > size(currColors,1); index2 = 1; end;
                end
                img_info('lutColors') = lutColors;
            end
            handles = handles.Img{handles.Id}.I.replaceDataset(img, handles, img_info);
        else
            handles = handles.Img{handles.Id}.I.replaceDataset(img, handles, img_info);
        end
        
        
        
        handles.lastSegmSelection = 1;  % last selected contour for use with the 'e' button
        handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
    case 'insertData'
        prompt = sprintf('Where the new dataset should be inserted?\n\n1 - beginning of the open dataset\n0 - end of the open dataset\n\nor type any number to define position');
        %insertPosition = inputdlg(prompt, 'Insert dataset', 1, {'0'});
        insertPosition = mib_inputdlg(handles, prompt, 'Insert dataset', '0');
        if isempty(insertPosition); return; end;
        insertPosition = str2double(insertPosition{1});
        if insertPosition == 0; insertPosition = NaN; end;
        [img, img_info, ~] = ib_loadImages(fn, options, handles);
        handles = handles.Img{handles.Id}.I.insertSlice(img, handles, insertPosition, img_info);
        handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
        handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
    case 'rename'
        if numel(fn) ~= 1
            msgbox('Please select a single file!', 'Rename file', 'warn');
            return;
        end
        %options.Resize='on';
        %options.WindowStyle='normal';
        %options.Interpreter='none';
        [path, filename, ext] = fileparts(fn{1});
        %answer = inputdlg('Please enter new file name','Rename file',1,cellstr([filename, ext]),options);
        answer = mib_inputdlg(handles, 'Please enter new file name','Rename file',[filename, ext]);
        if isempty(answer); return; end;
        movefile(fn{1}, fullfile(path, answer{1}));
        update_filelist(handles);
    case 'delete'
        if numel(fn) == 1
            msg = sprintf('You are going to delete\n%s', fn{1});
        else
            msg = sprintf('You are going to delete\n%d files', numel(fn));
        end
        button =  questdlg(msg,'Delete file(s)?','Delete','Cancel','Cancel');
        if strcmp(button, 'Cancel') == 1; return; end;
        for i=1:numel(fn)
            delete(fn{i});
        end
        update_filelist(handles);
    case 'file_properties'
        if exist('fn','var') == 0; return; end;
        properties = dir(fn{1});
        msgbox(sprintf('Filename: %s\nDate: %s\nSize: %.3f KB', properties.name, properties.date, properties.bytes/1000),...
            'File info');
    case {'addchannel' 'addchannel_nth'}   % add color channel
        [img, img_info, ~] = ib_loadImages(fn, options, handles);
        if isnan(img); return; end;
        
        if isKey(img_info, 'lutColors')
            lutColors = img_info('lutColors');
            lutColors = lutColors(1:size(img,3),:);
        else
            lutColors = NaN;
        end
        
        result = handles.Img{handles.Id}.I.addColorChannel(img, handles, NaN, lutColors);
        if ~isstruct(result);
            return;
        else
            handles = result;
        end

        handles = updateGuiWidgets(handles);
        
        handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
end
unFocus(handles.filesListbox);   % remove focus from hObject
end