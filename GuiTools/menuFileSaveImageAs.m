function menuFileSaveImageAs(hObject, eventdata, handles)
% function menuFileSaveImageAs(hObject, eventdata, handles)
% a callback to the handles.menuFileSaveImageAs, saves image to a file
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
%


% save image as...
if size(handles.Img{handles.Id}.I.img,1)<1; msgbox('No image detected!','Error!','error','modal'); return; end;

fn_out = handles.Img{handles.Id}.I.img_info('Filename');
if isempty(strfind(fn_out,'/')) && isempty(strfind(fn_out,'\'))
    fn_out = fullfile(handles.mypath, fn_out);
end
if isempty(fn_out)
    fn_out = handles.mypath;
end

Filters = {'*.am;',  'Amira Mesh binary (*.am)';...
    '*.jpg;',  'Joint Photographic Experts Group (*.jpg)'; ...
    '*.h5',   'Hierarchical Data Format (*.h5)'; ...
    '*.mrc;',  'MRC format for IMOD (*.mrc)'; ...
    '*.nrrd',  'NRRD Data Format (*.nrrd)'; ...
    '*.png',   'Portable Network Graphics (*.png)'; ...
    '*.tif;',  'TIF format LZW compression (*.tif)'; ...
    '*.tif;',  'TIF format uncompressed (*.tif)'; ...
    '*.xml',   'Hierarchical Data Format with XML header (*.xml)'; ...
    '*.*',  'All Files (*.*)'};

[pathStr,fnameStr,ext] = fileparts(fn_out);
if strcmp('.am', ext)
    %Filters = Filters([6 1:5 7:end],:);
elseif strcmp('.jpg', ext)
    Filters = Filters([2 1 3:end],:);
    fn_out = fullfile(pathStr, [fnameStr '.jpg']);
elseif strcmp('.h5', ext)
    Filters = Filters([3 1:2 4:end],:);
elseif strcmp('.mrc', ext)     % Volume for IMOD (*.mrc)
    Filters = Filters([4 1:3 5:end],:);
elseif strcmp('.nrrd', ext)
    Filters = Filters([5 1:4 6:end],:);
elseif strcmp('.png', ext)
    Filters = Filters([6 1:5 7:end],:);
elseif strcmp('.tif', ext)
    Filters = Filters([7 1:6 8:end],:);
    fn_out = fullfile(pathStr, [fnameStr '.tif']);
elseif strcmp('.xml', ext)
    Filters = Filters([9 1:7 9:end],:);
else
    Filters = Filters([10 1:9],:);
end

[filename, path, FilterIndex] = uiputfile(Filters, 'Save image...',fn_out); %...
if isequal(filename,0); return; end; % check for cancel

t1 = 1;
t2 = handles.Img{handles.Id}.I.time;
if handles.Img{handles.Id}.I.time > 1 && isempty(strfind(Filters{FilterIndex,2}, 'Hierarchical'))
    button = questdlg(sprintf('!!! Warning !!!\nIt is not possible to save 4D dataset into a single file using "%s"\nHowever,\n - it is possible to save a series of 3D files;\n - save the currently shown Z-stack;\n - or save 4D data using the HDF format (press Cancel and select Hierarchical Data Format during saving)', Filters{FilterIndex,2}),'Save image','Save as series of 3D datasets','Save the currently shown Z-stack','Cancel','Save as series of 3D datasets');
    if strcmp(button, 'Cancel'); return; end;
    if strcmp(button, 'Save as series of 3D datasets');
        t1 = 1;
        t2 = handles.Img{handles.Id}.I.time;
    else
        t1 = handles.Img{handles.Id}.I.slices{5}(1);
        t2 = t1;
    end
end

getDataOptions.blockModeSwitch = 0;     % get the full dataset
[~,filename, ext] = fileparts(filename);
res = handles.Img{handles.Id}.I.updateParameters();
if res == 0; return; end;   % cancel

pause(.1);
showLocalWaitbar = 0;   % switch to show or not wait bar in this function
if t1 ~= t2
    showLocalWaitbar = 1;
    wb = waitbar(0,sprintf('Saving %s\nPlease wait...',Filters{FilterIndex,2}),'Name','Saving images...','WindowStyle','modal');
    dT = t2-t1+1;
end
tic
for t=t1:t2
    if t1~=t2   % generate filename
        fnOut = generateSequentialFilename(filename, t, t2-t1+1, ext);
    else
        fnOut = [filename ext];
    end
    
    img = handles.Img{handles.Id}.I.getData3D('image', t, 4, 0, getDataOptions);
    
    switch Filters{FilterIndex,2}
        case 'Amira Mesh binary (*.am)'    % am format
            if exist('savingOptions', 'var') == 0   % define parameters for the first time use
                savingOptions = struct('overwrite', 1);
                savingOptions.colors = handles.Img{handles.Id}.I.lutColors;   % store colors for color channels 0-1;
                savingOptions.showWaitbar = ~showLocalWaitbar;  % show or not waitbar in bitmap2amiraMesh
            end
            bitmap2amiraMesh(fullfile(path, fnOut), img, ...
                containers.Map(keys(handles.Img{handles.Id}.I.img_info),values(handles.Img{handles.Id}.I.img_info)), savingOptions);
        case {'Hierarchical Data Format (*.h5)', 'Hierarchical Data Format with XML header (*.xml)' }   % hdf5 format
            if t==t1    % getting parameters for saving dataset
                options = mib_saveHDF5Dlg(handles, handles.preferences.Font);
                if isempty(options); 
                    if showLocalWaitbar; delete(wb); end;
                    return; 
                end;
                tic;
                options.filename = fullfile(path, [filename ext]);
                ImageDescription = handles.Img{handles.Id}.I.img_info('ImageDescription');  % initialize ImageDescription
            end
            
            % permute dataset if needed
            if strcmp(options.Format, 'bdv.hdf5')
                % permute image to swap the X and Y dimensions
                img = permute(img, [2 1 3 4 5]);
            end
            
            if t==t1    % updating parameters for saving dataset
                options.height = size(img,1);
                options.width = size(img,2);
                options.colors = size(img,3);
                options.depth = size(img,4);
                options.time = handles.Img{handles.Id}.I.time;
                options.pixSize = handles.Img{handles.Id}.I.pixSize;    % !!! check .units = 'um'
                options.showWaitbar = ~showLocalWaitbar;        % show or not waitbar in data saving function
                options.lutColors = handles.Img{handles.Id}.I.lutColors;    % store LUT colors for channels
                options.ImageDescription = ImageDescription; 
                options.DatasetName = filename; 
                options.overwrite = 1;
                options.DatasetType = 'image';
            
                % saving xml file if needed
                if options.xmlCreate
                    saveXMLheader(options.filename, options);
                end
            end
                        
            options.t = t;
            switch options.Format
                case 'bdv.hdf5'
                    options.pixSize.units = sprintf('\xB5m'); % 'µm';
                    saveBigDataViewerFormat(options.filename, img, options);
                case 'matlab.hdf5'
                    image2hdf5(fullfile(path, [filename '.h5']), img, options);
            end
        case 'Joint Photographic Experts Group (*.jpg)'    % jpg format
            if exist('savingOptions', 'var') == 0   % define parameters for the first time use
                savingOptions = struct('overwrite', 1,'Comment', handles.Img{handles.Id}.I.img_info('ImageDescription'));
                if strcmp(handles.Img{handles.Id}.I.img_info('ColorType'), 'indexed')
                    savingOptions.cmap = handles.Img{handles.Id}.I.img_info('Colormap');
                else
                    savingOptions.cmap = NaN;
                end
                prompt = {'Compression mode (lossy, lossless):','Quality (0-100):'};
                dlg_title = 'JPG Parameters';
                def = {'lossy','90'};
                answer = inputdlg(prompt,dlg_title,1,def);
                if isempty(answer); return; end;
                savingOptions.Compression = answer{1};
                savingOptions.Quality = str2double(answer{2});
                savingOptions.showWaitbar = ~showLocalWaitbar;
                
                % get list of filenames for slices
                if isKey(handles.Img{handles.Id}.I.img_info, 'SliceName') && numel(handles.Img{handles.Id}.I.img_info('SliceName')) == handles.Img{handles.Id}.I.no_stacks
                    choice = questdlg('Would you like to use original or sequential filenaming?','Save as JPEG...','Original','Sequential','Cancel','Sequential');
                    if strcmp(choice, 'Cancel'); return; end;
                    if strcmp(choice, 'Original'); savingOptions.SliceName = handles.Img{handles.Id}.I.img_info('SliceName'); end;
                end
            end
            ib_image2jpg(fullfile(path, fnOut), img, savingOptions);
        case 'MRC format for IMOD (*.mrc)'    % MRC format
            if size(img,3) > 1
                errordlg(sprintf('!!! Error !!!\n\nIt is not possile to save %s images in the MRC format', class(img)),'Wrong image class');
                return;
            end
            savingOptions.volumeFilename = fullfile(path, fnOut);
            savingOptions.pixSize = handles.Img{handles.Id}.I.pixSize;
            savingOptions.showWaitbar = ~showLocalWaitbar;
            ib_image2mrc(img, savingOptions);
        case 'Portable Network Graphics (*.png)'    % PNG format
            if exist('savingOptions', 'var') == 0   % define parameters for the first time use
                savingOptions = struct('overwrite', 1,'Comment', handles.Img{handles.Id}.I.img_info('ImageDescription'),...
                    'XResolution', handles.Img{handles.Id}.I.img_info('XResolution'), 'YResolution', handles.Img{handles.Id}.I.img_info('YResolution'), ...
                    'ResolutionUnit', 'Unknown', 'Reshape', 0);
                if strcmp(handles.Img{handles.Id}.I.img_info('ColorType'), 'indexed')
                    savingOptions.cmap = handles.Img{handles.Id}.I.img_info('Colormap');
                else
                    savingOptions.cmap = NaN;
                end
                % get list of filenames for slices
                if isKey(handles.Img{handles.Id}.I.img_info, 'SliceName') && numel(handles.Img{handles.Id}.I.img_info('SliceName')) == handles.Img{handles.Id}.I.no_stacks
                    savingOptions.SliceName = handles.Img{handles.Id}.I.img_info('SliceName');
                end
                savingOptions.showWaitbar = ~showLocalWaitbar;
            end
            ib_image2png(fullfile(path, fnOut), img, savingOptions);
        case 'NRRD Data Format (*.nrrd)'   % PNG format
            savingOptions = struct('overwrite', 1);
            savingOptions.showWaitbar = ~showLocalWaitbar;
            bb = handles.Img{handles.Id}.I.getBoundingBox();
            bitmap2nrrd(fullfile(path, fnOut), img, bb, savingOptions);
        otherwise    % tif format
            if exist('savingOptions', 'var') == 0   % define parameters for the first time use
                colortype = handles.Img{handles.Id}.I.img_info('ColorType');
                if strcmp('TIF format LZW compression (*.tif)', Filters{FilterIndex,2})
                    compression = 'lzw';
                else
                    compression = 'none';
                end
                if strcmp(colortype,'indexed')
                    cmap = handles.Img{handles.Id}.I.img_info('Colormap');
                else
                    cmap = NaN;
                end
                ImageDescription = {handles.Img{handles.Id}.I.img_info('ImageDescription')};
                savingOptions = struct('Resolution', [handles.Img{handles.Id}.I.img_info('XResolution') handles.Img{handles.Id}.I.img_info('YResolution')],...
                    'overwrite', 1, 'Saving3d', NaN, 'cmap', cmap, 'Compression', compression);
                savingOptions.showWaitbar = ~showLocalWaitbar;
                if handles.Img{handles.Id}.I.no_stacks == 1; savingOptions.Saving3d = 'multi'; end;
                
                % get list of filenames for slices
                if isKey(handles.Img{handles.Id}.I.img_info, 'SliceName') && numel(handles.Img{handles.Id}.I.img_info('SliceName')) == handles.Img{handles.Id}.I.no_stacks && handles.Img{handles.Id}.I.time == 1
                    savingOptions.SliceName = handles.Img{handles.Id}.I.img_info('SliceName');
                end
            end
            [result, savingOptions] = ib_image2tiff(fullfile(path, fnOut), img, savingOptions, ImageDescription);
            if isfield(savingOptions, 'SliceName'); savingOptions = rmfield(savingOptions, 'SliceName'); end; % remove SliceName field when saving series of 2D files
    end
    if showLocalWaitbar;        waitbar(t/dT, wb);    end;
end
update_filelist(handles, [filename ext]);     % update list of files, use filename to highlight the saved file
if showLocalWaitbar; delete(wb); end;
toc;
end

% supporting function to generate sequential filenames
function fn = generateSequentialFilename(name, num, files_no, ext)
% name - a filename template
% num - sequential number to generate
% files_no - total number of files in sequence
% ext - string with extension
if files_no == 1
    fn = [name ext];
elseif files_no < 100
    fn = [name '_' sprintf('%02i',num) ext];
elseif files_no < 1000
    fn = [name '_' sprintf('%03i',num) ext];
elseif files_no < 10000
    fn = [name '_' sprintf('%04i',num) ext];
elseif files_no < 100000
    fn = [name '_' sprintf('%05i',num) ext];
elseif files_no < 1000000
    fn = [name '_' sprintf('%06i',num) ext];
elseif files_no < 10000000
    fn = [name '_' sprintf('%07i',num) ext];
end
end