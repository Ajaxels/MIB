function im_browser_filesListbox_Callback(hObject, eventdata, handles)
% im_browser_filesListbox_Callback(hObject, eventdata, handles)
% navigation in the file list, i.e. open file or change directory
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.10.2016, added list of recent directories


% Open the image after the double click
val = get(handles.filesListbox, 'Value');
list = get(handles.filesListbox, 'String');
filename = list(val);

switch get(handles.im_browser, 'selectiontype')
    case 'normal'   % single click, do nothing
    case 'open'     % double click, open the image
        if strcmp(filename{1},'[..]')     % go up in the directory tree
            [dirname, oldDir] = fileparts(handles.mypath);
            if ~isequal(dirname, handles.mypath)
                handles.mypath = dirname;
                update_filelist(handles, ['[', oldDir, ']']);  % the squares are required because the directory is reported as [dirname] in the update_filelist function
            end
        elseif strcmp(filename{1},'[.]')   % go up to the root directory listing
            if ispc()
                dirname = fileparts(handles.mypath);
                handles.mypath = dirname(1:3);
            else
                handles.mypath = '/';
            end
            update_filelist(handles);
        elseif filename{1}(1) == '[' && filename{1}(end) == ']'   % go into the selected directory
            dirname = fullfile(handles.mypath, filename{1}(2:end-1));
            handles.mypath = dirname;
            update_filelist(handles);
        else        % open the selected file
            options.bioformatsCheck = get(handles.bioformatsCheck,'Value');
            options.progressDlg = 1;
            handles.Img{handles.Id}.I.clearContents();  % remove the current dataset
            handles.U.clearContents();  % clear Undo history
            if get(handles.sequenceCheck,'Value') == 1  % load all files in the folder as a sequence
                index = 1;
                for i=1:numel(list)
                    if ~strcmp(list{i}, '.') && ~strcmp(list{i}, '..') && list{i}(1) ~= '['
                        fn(index) = cellstr(fullfile(handles.mypath, list{i})); %#ok<AGROW>
                        index = index + 1;
                    end
                end
                [img, img_info, ~] = ib_loadImages(fn, options, handles);
            else    % load a single image, not a stack of images
                fn = fullfile(handles.mypath, filename{1});
                [img, img_info, ~] = ib_loadImages(cellstr(fn), options, handles);
            end
            if ~isnan(img(1));
                handles = handles.Img{handles.Id}.I.replaceDataset(img, handles, img_info);
                handles.lastSegmSelection = 1;  % last selected contour for use with the 'e' button
            else
                handles = handles.Img{handles.Id}.I.updateAxesLimits(handles, 'resize');
                handles.Img{handles.Id}.I.updateDisplayParameters();
                handles = updateGuiWidgets(handles);
            end;
            handles = handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 1);
            unFocus(hObject);   % remove focus from hObject
            
            % update list of recent directories
            dirPos = ismember(handles.preferences.recentDirs, fileparts(fn));
            if sum(dirPos) == 0
                handles.preferences.recentDirs = [fileparts(fn) handles.preferences.recentDirs];    % add the new folder to the list of folders
                if numel(handles.preferences.recentDirs) > 10    % trim the list
                    handles.preferences.recentDirs = handles.preferences.recentDirs(1:10);
                end
            else
                % resort the list and put the opened folder to the top of
                % the list
                handles.preferences.recentDirs = [handles.preferences.recentDirs(dirPos==1) handles.preferences.recentDirs(dirPos==0)];
            end
            set(handles.recentDirsPopup, 'String', handles.preferences.recentDirs);
        end
end
guidata(handles.im_browser, handles);
end