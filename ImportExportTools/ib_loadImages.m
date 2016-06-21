function [img, img_info, pixSize] = ib_loadImages(filenames, options, handles)
% function [img, img_info, pixSize] = ib_loadImages(filenames, options, handles)
% Load images from the list of files
% 
% Load images contained in the array of cells 'filesnames' and return 'img_info' containers.Map 
%
% Parameters:
% filenames: array of cells with filenames
% options: -> a structure with parameters
%     - .bioformatsCheck -> if @b 0 -> open standard image types, if @b 1 -> open images using BioFormats library
%     - .progressDlg -> @b 1 - show waitbar, @b 0 - do not show waitbar
%     - .customSections -> @b 0 or @b 1, when @b 1 take some custom section(s) from the dataset
% handles: handles structure of im_browser
%
% Return values:
% img: - a dataset, [1:height, 1:width, 1:colors, 1:no_stacks]
% img_info: - a containers.Map with meta-data and image details
% pixSize: - a structure with voxel dimensions,
% @li .x - physical width of a pixel
% @li .y - physical height of a pixel
% @li .z - physical thickness of a pixel
% @li .t - time between the frames for 2D movies
% @li .tunits - time units
% @li .units - physical units for x, y, z. Possible values: [m, cm, mm, um, nm]

% Copyright (C) 25.06.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

tic
if nargin < 2; options = struct(); end;

if ~isfield(options, 'bioformatsCheck');    options.bioformatsCheck = 0; end
if ~isfield(options, 'progressDlg');    options.progressDlg = 0; end
if ~isfield(options, 'customSections');    options.customSections = 0; end

pixSize.x = 0.087;
pixSize.y = 0.087;
pixSize.z = 0.087;
pixSize.units = 'um';
pixSize.t = 1;
pixSize.tunits = 's';

autoCropSw = 0;     % auto crop images that have dimension mismatch

no_files = numel(filenames);

files = struct();   % structure that keeps info about each file in the series
% .object_type -> 'movie', 'hdf5_image', 'image'
% .seriesName -> name of the series for HDF5
% .height
% .width
% .color
% .noLayers -> number of image frames in the file
% .imgClass -> class of the image

for i=1:no_files
    files(i).filename = cell2mat(filenames(i));
end
options.waitbar = 1;
[img_info, files, pixSize] = getImageMetadata(filenames, options, handles);
if isempty(keys(img_info))
    img = NaN;
    return;
end
% fill img_info and preallocate memory for the dataset
% check files for dimensions and class
if strcmp(files(1).imgClass, 'int16') || strcmp(files(1).imgClass, 'uint32')
    choice = questdlg(sprintf('The original image is in the %s format\n\nIt will be converted into uint16 format!', files(1).imgClass), ...
        'Image Format Warning!', ...
        'Sure','Cancel','Sure');
    if strcmp(choice, 'Cancel');
        img = NaN;
        return;
    end
end

% no_files = numel(files);
% for fn_index = 1:no_files
%     if files(fn_index).height ~= files(1).height || files(fn_index).width ~= files(1).width && autoCropSw==0
%         if autoCropSw == 0
%             %answer = inputdlg(sprintf('!!! Warning !!!\nThe XY dimensions of images mismatch!\n\nContinue anyway?\nBackground color intensity:'),'Dimensions mismatch',1,{num2str(intmax(files(1).imgClass))});
%             answer = mib_inputdlg(handles,sprintf('!!! Warning !!!\nThe XY dimensions of images mismatch!\nContinue anyway?\nEnter the background color intensity:'),'Dimensions mismatch',num2str(intmax(files(1).imgClass)));
%             if isempty(answer)
%                 if options.progressDlg; delete(wb); end;
%                 img=NaN;
%                 return;
%             end;
%             files(1).backgroundColor = str2double(answer{1});   % add information about background color
%             autoCropSw = 1;
%         end
%     end
% end

if numel(unique(cell2mat({files.color}))) > 1 || numel(unique(cell2mat({files.height}))) > 1 || numel(unique(cell2mat({files.width}))) > 1 && autoCropSw==0
    answer = mib_inputdlg(handles, sprintf('!!! Warning !!!\nThe XY dimensions or number of color channels mismatch!\nContinue anyway?\n\nEnter the background color intensity (0-%d):', intmax(files(1).imgClass)),'Dimensions mismatch','0');
    if isempty(answer)
        img=NaN;
        return;
    end;
    files(1).backgroundColor = str2double(answer{1});   % add information about background color
    autoCropSw = 1;
end

% loading the datasets
getImagesOpt.waitbar = options.progressDlg;
[img, img_info] = ib_getImages(files, img_info, getImagesOpt);

[img_info, pixSize] = ib_updatePixSizeAndResolution(img_info, pixSize);

% % generate layerNames, which are the file names of the datasets that were
% % used to generate a stack
% if numel(files) > 1
%     SliceName = cell(sum(arrayfun(@(x) x.noLayers, files)), 1);
%     index = 1;
%     for fileId = 1:numel(files)
%         [~, fnShort, ext]  = fileparts(files(fileId).filename);
%         SliceName(index:index+files(fileId).noLayers-1) = repmat(cellstr(strcat(fnShort, ext)), [files(fileId).noLayers 1]);
%         index = index+files(fileId).noLayers;
%     end
%     img_info('SliceName') = SliceName;
% else
%     [~, fnShort, ext]  = fileparts(files.filename);
%     img_info('SliceName') = cellstr(strcat(fnShort, ext));
% end

toc
end




