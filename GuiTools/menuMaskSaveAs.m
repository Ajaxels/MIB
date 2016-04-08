function menuMaskSaveAs(hObject, eventdata, handles)
% function menuMaskSaveAs(hObject, eventdata, handles)
% a callback to Menu->Mask->Save As
% saves the Mask layer to a file
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
% 07.09.2015, IB updated to use imageData.getData3D methods
% 17.02.2016, IB updated for 4D datasets

% Save mask layer to a file in Matlab format
if handles.Img{handles.Id}.I.maskExist == 0; disp('Cancelled: No mask information found!'); return; end;
if isnan(handles.Img{handles.Id}.I.maskImgFilename)
    [pathstr, name] = fileparts(handles.Img{handles.Id}.I.img_info('Filename'));
    fn_out = fullfile(pathstr, [name '.mask']);
    if isempty(strfind(fn_out,'/')) && isempty(strfind(fn_out,'\'))
        fn_out = fullfile(handles.mypath, fn_out);
    end
    if isempty(fn_out)
        fn_out = handles.mypath;
    end
else
    fn_out = handles.Img{handles.Id}.I.maskImgFilename;
end;
[filename, path, FilterIndex] = uiputfile(...
    {'*.mask',  'Matlab format (*.mask)'; ...
    '*.am',  'Amira mesh binary RLE compression SLOW (*.am)'; ...
    '*.am',  'Amira mesh binary (*.am)'; ...
    '*.tif',  'TIF format (*.tif)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Save mask data...', fn_out);
if isequal(filename,0); return; end; % check for cancel
%warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');    % switch off warnings for latex
curInt = get(0, 'DefaulttextInterpreter'); 
set(0, 'DefaulttextInterpreter', 'none'); 
wb = waitbar(0,sprintf('%s\nPlease wait...',fullfile(path, filename)),'Name','Saving the mask','WindowStyle','modal');

getDataOptions.blockModeSwitch = 0;
waitbar(0.1, wb);

if FilterIndex == 1     % matlab file
    maskImg = handles.Img{handles.Id}.I.getData4D('mask', 4, NaN, getDataOptions); %#ok<NASGU>
    save([path filename], 'maskImg', '-v7.3');
else
    t1 = handles.Img{handles.Id}.I.slices{5}(1);
    t2 = t1;
    if handles.Img{handles.Id}.I.time > 1
        button = questdlg(sprintf('!!! Warning !!!\nIt is not possible to save 4D dataset into a single file!\n\nHowever it is possible to save the currently shown Z-stack, or to make a series of files'),'Save mask','Save as series of 3D datasets','Save the currently shown Z-stack','Cancel','Save as series of 3D datasets');
        if strcmp(button, 'Cancel'); return; end;
        if strcmp(button, 'Save as series of 3D datasets');
            t1 = 1;
            t2 = handles.Img{handles.Id}.I.time;
        end
    end
    [~,filename, ext] = fileparts(filename);
    
    for t=t1:t2
        if t1~=t2   % generate filename
            fnOut = generateSequentialFilename(filename, t, t2-t1+1, ext);
        else
            fnOut = [filename ext];
        end        
        
        maskImg = handles.Img{handles.Id}.I.getData3D('mask', t, 4, NaN, getDataOptions);
        if FilterIndex == 2 || FilterIndex == 3      % Amira mesh
            if FilterIndex == 2
                amiraType = 'binaryRLE';
            else
                amiraType = 'binary';
            end
            bb = handles.Img{handles.Id}.I.getBoundingBox();
            pixStr = handles.Img{handles.Id}.I.pixSize;
            pixStr.minx = bb(1);
            pixStr.miny = bb(3);
            pixStr.minz = bb(5);
            bitmap2amiraLabels([path fnOut], maskImg, amiraType, pixStr, handles.preferences.maskcolor,cellstr('Mask'), 1);    
        elseif FilterIndex == 4   % as tif
            ImageDescription = {handles.Img{handles.Id}.I.img_info('ImageDescription')};
            resolution(1) = handles.Img{handles.Id}.I.img_info('XResolution');
            resolution(2) = handles.Img{handles.Id}.I.img_info('YResolution');
            if exist('savingOptions', 'var') == 0   % define parameters for the first time use
                savingOptions = struct('Resolution', resolution, 'overwrite', 1, 'Saving3d', NaN, 'cmap', NaN);
            end
            maskImg = reshape(maskImg,[size(maskImg,1) size(maskImg,2) 1 size(maskImg,3)]);
            [result, savingOptions] = ib_image2tiff(fullfile(path, fnOut), maskImg, savingOptions, ImageDescription); 
            if isfield(savingOptions, 'SliceName'); savingOptions = rmfield(savingOptions, 'SliceName'); end; % remove SliceName field when saving series of 2D files
        end
    end
end

waitbar(0.9, wb);
handles.Img{handles.Id}.I.maskImgFilename = fullfile(path, filename);
sprintf('The mask %s was saved!', fullfile(path, filename));
waitbar(1, wb);
set(0, 'DefaulttextInterpreter', curInt); 
delete(wb);
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