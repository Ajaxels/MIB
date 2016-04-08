function update_filelist(handles, filename)
% Update List of files in the current directory
%
% Parameters:
% handles: handles structure of im_browser
% filename: [optional], when specified highlight @b filename in the list of files

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


if nargin < 2;     filename = NaN;   end;

extentions = get(handles.im_filterPopup, 'String');
extention = extentions(get(handles.im_filterPopup, 'Value'));

if handles.mypath(end) == ':'   % change from c: to c:\, because somehow dir('c:') gives wrong result
    handles.mypath = [handles.mypath '\'];
end

fileList = dir(handles.mypath);
fnames = {fileList.name};
dirs = fnames([fileList.isdir]);  % generate list of directories
fileList = fnames(~[fileList.isdir]);     % generate structure with files
[~,~,fileList_ext] = cellfun(@fileparts,fileList,'UniformOutput', false);   % get extensions

if strcmp(extention,'all known')
    if handles.matlabVersion < 8.1    % strjoin appeared only in R2013a (8.1)
        extentions(2:end-1) = cellfun(@(x) sprintf('%s|',x),extentions(2:end-1),'UniformOutput', false);
        extensions = cell2mat(extentions(2:end)');
    else
        extensions = strjoin(extentions(2:end)','|');
    end
    files = fileList(~cellfun(@isempty, regexpi(fileList_ext, extensions)))';
else
    files = fileList(~cellfun(@isempty, regexpi(fileList_ext, extention)))';
end
fnames = sort(files);

if ~isempty(dirs)
    dirs = strcat(repmat({'['}, 1, length(dirs)), dirs, repmat({']'}, 1, length(dirs)));
    fnames = {dirs{:}, fnames{:}}; %#ok<CCAT>
end
if isnan(filename(1))
    set(handles.filesListbox, 'string', fnames, 'value', 1);
else
    for i=1:numel(fnames)
        if strcmp(fnames{i}, filename)
            highlightValue = i;
            continue;
        end
    end
    if exist('highlightValue', 'var')
        set(handles.filesListbox, 'string', fnames, 'value', highlightValue);
    else
        set(handles.filesListbox, 'string', fnames, 'value', 1);
    end
end
set(handles.pathEdit,'String',handles.mypath);
guidata(handles.im_browser, handles);
end