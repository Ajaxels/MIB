classdef imageData < matlab.mixin.Copyable
    % @type imageData class is resposnible to keep and visualize datasets

	% Copyright (C) 30.10.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
	% 
	% This program is free software; you can redistribute it and/or
	% modify it under the terms of the GNU General Public License
	% as published by the Free Software Foundation; either version 2
	% of the License, or (at your option) any later version.

    properties (SetAccess = public, GetAccess = public)
        axesX
        % a vector [min, max] with minimal and maximal coordinates of the axes X of the 'imageAxes' axes
        axesY
        % a vector [min max] with minimal and maximal coordinates of the axes Y of the 'imageAxes' axes
        blockModeSwitch
        % defines whether to get the whole dataset or only the shown part of it, either @b 0 or @b 1
        brush_prev_xy
        % coordinates of the previous pixel for the @em Brush tool,
        % @note dimensions: [x, y] or NaN
        brush_selection
        % selection layer during the brush tool movement, @code {1:2}[1:height,1:width] or NaN @endcode
        % brush_selection{1} - contains brush selection during drawing
        % brush_selection{2} - contains labels of the supervoxels and some additional information
        %   .slic - a label image with superpixels
        %   .selectedSlic - a bitmap image of the selected with the Brush tool superpixels 
        %   .selectedSlicIndices - indices of the selected Slic superpixels
        %   .selectedSlicIndicesNew - a list of freshly selected Slic indices when moving the brush, used for the undo with Ctrl+Z
        %   .CData - a copy of the shown in the imageAxes image, to be used for the undo
        % brush_selection{3} - a structure that contains information for
        % the adaptive mode:
        %   .meanVals - array of mean intensity values for each superpixels
        %   .mean - mean intensity value for the initial selection
        %   .std - standard deviation of intensities for the initial selection
        %   .factor - factor that defines variation of STD variation
        % @note the 'brush_selection' is modified with respect to @code magFactor @endcode and crop of the image within the viewing window
        colors
        % number of color channels
        current_yxz
        % a vector to remember last selected slice number of each 'yx', 'zx', 'zy' planes,
        % @note dimensions: @code [1 1 1] @endcode
        height
        % image height, px
        hLabels
        % a handle to class to keep labels
        hMeasure
        % a handle to class to keep measurements
        hROI
        % handle to ROI class, @b roiImage
        img
        % a property to keep the 'Image' layer.
        % @note The 'Image' layer dimensions: @code [1:height, 1:width, 1:colors 1:no_stacks] @endcode.
        img_info
        % information about the dataset, an instance of the 'containers'.'Map' class
        % Default keys:
        % @li @b ColorType - ''grayscale''
        % @li @b ImageDescription - ''''
        % @li @b Height - 1
        % @li @b Width - 1
        % @li @b Stacks - 1
        % @li @b XResolution - 1
        % @li @b YResolution - 1
        % @li @b ResolutionUnit - ''Inch''
        % @li @b Filename - ''none.tif''
        % @li @b SliceName - @em [optional] a cell array with names of the slices; for combined Z-stack, it is a name of the file that corresponds to the slice. Dimensions of the array should be equal to the  obj.no_stacks
        imh
        % handle for the currently shown image
        Ishown
        % a property to keep the currently displayed image in RGB format
        % @note 'Ishown' dimensions: @code [1:height, 1:width, 1:colors] % @endcode
        lutColors
        % a matrix with LUT colors [1:colorChannel, R G B], (0-1)
        magFactor
        % magnification factor for the currently shown image, 1=100%, 1.5 = 150%
        maskExist
        % a switch to indicate presense of the 'Mask' layer. Can be 0 (no
        % model) or 1 (model exist)
        maskImg
        % a property to keep the 'Mask' layer
        % @note The 'Mask' dimensions are: @code [1:height, 1:width, 1:no_stacks] @endcode
        % @note When the imageData.model_type == ''uint6'', imageData.maskImg = NaN
        maskImgFilename
        % file name of the 'Mask' layer image
        maskStat
        % Statistics for the 'Mask' layer with the 'PixelList' info returned by 'regionprops' Matlab function
        model
        % @em model is a property to keep the 'Model' layer
        % @note The model dimensions are @code [1:height, 1:width, 1:no_stacks] @endcode
        model_fn
        % @em model_fn is a property to keep filename of the 'Model' layer
        model_type
        % The type of a model
        % - @b 'uint6' - a segmentation model with upto 63 materials; the 'Model', 'Mask' and 'Selection' layers stored in the same matrix, to decrease memory consumption;
        % @note
        %   - 10000000 - bit responsible for the 'Selection' layer
        %   - 01000000 - bit responsible for the 'Mask' layer
        %   - 00111111 - bits responsible for the 'Model' layer, the maximal number of Materials in this type of model is 63.
        % - @b uint8 - a segmentation model with upto 255 materials; the 'Model', 'Mask' and 'Selection' layers stored in separate matrices;
        % - @b int8 - a model layer that has intensities from -128 to 128.
        % - @b segm - segmentation, 'uint8' class
        % - @b diffmap - difference maps, 'int8' class
        model_var
        % @em model_var is a variable name in the mat-file to keep the 'Model' layer
        model_diff_max
        % maximal absolute value in the image model of the 'diff_map' type
        modelMaterialColors
        % a matrix of colors [0-1] for materials of the 'Model', [materialIndex, R G B]
        modelMaterialNames
        % an array of strings to define names of materials of the 'Model'
        modelExist
        % a switch to indicate presense of the 'Model' layer. Can be 0 (no
        % model) or 1 (model exist)
        no_stacks
        % number of stacks in the dataset
        orientation
        % Orientation of the currently shown dataset,
        % @li @b 4 = the 'yz' plane, @b default
        % @li @b 1 = the 'zx' plane
        % @li @b 2 = the 'zy' plane
        pixSize
        % a structure with diminsions of voxels, @code .x .y .z .t .tunits .units @endcode
        % the fields are
        % @li .x - physical width of a pixel
        % @li .y - physical height of a pixel
        % @li .z - physical thickness of a pixel
        % @li .t - time between the frames for 2D movies
        % @li .tunits - time units
        % @li .units - physical units for x, y, z. Possible values: [m, cm, mm, um, nm]
        selection
        % a property to keep the Selection layer
        % @note The selection dimensions: @code [1:height, 1:width, 1:no_stacks] @endcode
        % @note When the imageData.model_type == ''uint6'', imageData.selection = NaN
        slices
        % coordinates of the shown slice borders
        % @note dimensions are @code ([height, width, color, z],[min max]) @endcode
        % @li (1,[min max]) - height
        % @li (2,[min max]) - width
        % @li (3,[min max]) - colors , array of color channels to show, for example [1, 3, 4]
        % @li (4,[min max]) - z - value
        % @li (5,[min max]) - t - time point
        storedSelection
        % a buffer to store selection with press of Ctrl+C button, and restore with Ctrl+V
        % @note dimensions are @code [1:height, 1:width] or NaN @endcode
        time
        % number of time points in the dataset
        trackerYXZ
        % starting point for the Membrane Click-tracer tool
        viewPort
        % a structure @code .min .max .gamma @endcode for image adjustment
        % the fields are
        % @li .min - a vector with minimal intensities for contrast adjustment
        % @li .max - a vector with maximal intensities for contrast adjustment
        % @li .gamma - a vector with gamma factor for contrast adjustment
        % @note Dimensions of each field is @code [1:colors] @endcode
		volren
        % a structure with parameters for the volume rendering the fields are
        % @li .viewer_matrix - a viewer matrix generated from the Rotation, Translation and Scaling vectors using makeViewMatrix function
        % @li .previewScale - scaledown factor for dataset preview during volren
        % @li .previewIng - scaled down image
        % @li .showFullRes - switch whether or not render image in full resolution or just preview
        width
        % image width, px
    end
    
    events
        %> Description of events
        none   % when selected two or more curves
    end
    
    methods
        % declaration of functions in the external files, keep empty line in between for the doc generator
        handles = addColorChannel(obj, img, handles, channelId, lutColors);    

        clearContents(obj, handles);   

        clearMask(obj, height, width, z, t);           %  clear the Mask layer

        [handles, status] = convertImage(obj,format,handles);  % Convert image to specified format: 'grayscale', 'truecolor', 'indexed' and 'uint8', 'uint16', 'uint32' class

        [x,y,z,t] = convertMouseToDataCoordinates(obj, x, y, mode, permuteSw);   %  Convert coordinates of the mouse click to the pixel x,y of the dataset
        
        [x,y] = convertDataToMouseCoordinates(obj, x, y, mode, magFactor);   %  Convert data point to the coordinates within the image view panel
        
        convertModel(obj, type);   %  Convert model from uint6 to uint8 and other way around.

        copyColorChannel(obj, channel1, channel2);   % copy intensities from one color channel to another
        
        createModel(obj, model_type);   % Create an empty model: allocate memory for a new model.
        
        cropDataset(obj, cropF);  % Crop dataset 
        
        deleteColorChannel(obj, channel1);       % delete color channel from the Image
        
        result = deleteSlice(obj, sliceNumber, orient);  % delete specified slice from the dataset.
        
        bb = getBoundingBox(obj); % Get Bounding box info as a vector [xmin, width, ymin, height, zmin, depth]
        
        slice = getCurrentSlice(obj, type, countour_id); % get currently shown slice.
        
        slice_no = getCurrentSliceNumber(obj); % Get slice number of the currently shown image
        
        timePnt = getCurrentTimePoint(obj); % Get time point of the currently shown image
        
        slice = getData2D(obj, type, slice_no, orient, col_channel, custom_img, options);   % get 3D slice, [height, width, color]
        
        dataset = getData3D(obj, type, time, orient, col_channel, options, custom_img);     % get 4D dataset, [height, width, color, depth]
        
        dataset = getData4D(obj, type, orient, col_channel, options, custom_img); % get complete 5D dataset
        
        dataset = getDataset(obj, type, permuteSw, col_channel, options); % get complete 4D dataset
        
        imgRGB =  getRGBimage(obj, handles, options, sImgIn);   % generate RGB image from all layers
        
        invertColorChannel(obj, channel1);                     % invert color channel
        
        generateModelColors(obj);   % generate colors for materials of the model
        
        [height, width, color, thick, time] = getDatasetDimensions(obj, type, orient, color, options); % get dataset dimensions
        
        slice = getFullSlice(obj, type, slice_no, orient, col_channel, custom_img, options);     % get full slice
        
        [totalSize, imSize] = getDatasetSizeInBytes(obj);   % get size of the dataset in bytes
        
        modelMaterialNames = getMaterialNames(obj);     % get names of materials of the model  
        
        imgOut = getRoiCrop(obj, type, handles, roiNo, options, col_channel);   % Get a 3D dataset from the defined ROI regions.
            
        imgOut = getRoiCropSlice(obj, type, handles, roiNo, sliceNo, orient, options, col_channel);            % Get a 2D slice of the ROI regions only.
        
        [yMin, yMax, xMin, xMax] = getCoordinatesOfShownImage(obj);            % Get coordinates of the shown area
        
        slice = getSlice(obj, type, slice_no, orient, col_channel, custom_img, options);            % Get the 2D slice
        
        slice = getSliceToShow(obj, type, slice_no, orient, col_channel, custom_img, options);             % Get a part of the 2D slice that fits into the viewing window of the handles.imageAxes
        
        insertEmptyColorChannel(obj, channel1);     % insert an empty color channel to the dataset
        
        handles = insertSlice(obj, img, handles, insertPosition, img_info);     % insert slice(s) into dataset
        
        mark2selection(obj, layer_id, type, str_type, xy_vec); % Add a marker/pointer to the selection layer
        
        moveMaskToSelectionDataset(obj, action_type, options);  % move the Mask layer to the Selection layer
        
        moveModelToMaskDataset(obj, action_type, options);      % move the Model layer to the Mask layer
        
        moveModelToSelectionDataset(obj, action_type, options); % move the Model layer to the Selection layer
        
        moveSelectionToMaskDataset(obj, action_type, options);  % move the Selection layer to the Mask layer     
        
        moveSelectionToModelDataset(obj, action_type, options); % move the Selection layer to the Model layer
        
        moveView(obj, x, y, orient);             % Center the image view at the provided coordinates: x, y
        
        handles = plotImage(obj, axes, handles, resize, sImgIn);             % Plot image to the axes. The main drawing function
        
        handles = replaceDataset(obj, img, handles, img_info, modelImg, maskImg, selectionImg);             % Replace existing dataset with a new one.
        
        handles = replaceImageColor(obj, handles, type);             % Replace image intensities in the @em Masked or @em Selected areas with new intensity value
        
        resizeImage(obj, new_width, new_height, method);             % Resize all layers using specified @em method
        
        rotateColorChannel(obj, channel1);          % Rotate color channel of the dataset
        
        clearSelection(obj, height, width, z, t); % Clear the 'Selection' layer. 
        
        setCurrentSlice(obj, type, slice, color_id);  % Update the currently shown slice of the dataset.
        
        result = setData2D(obj, type, slice, slice_no, orient, col_channel, custom_img, options);   % Update a slice in dataset
        
        result = setData3D(obj, type, dataset, time, orient, col_channel, options, custom_img);     % Update complete 3D/4D stack in 5D dataset
        
        result = setData4D(obj, type, dataset, orient, col_channel, options);                % Update complete 5D dataset
        
        result = setDataset(obj, type, dataset, permuteSw, col_channel, options);             % Update complete 4D dataset, legacy
        
        custom_img = setFullSlice(obj, type, slice, slice_no, orient, col_channel, custom_img, options);             % Update the full 2D slice of the dataset
        
        handles = setMaterialNames(obj, modelMaterialNames, handles);   % update list of names of materials of the model
        
        setRoiCrop(obj, type, imgIn, handles, roiNo, options, col_channel); % Update a full 3D dataset from the defined ROI regions.
        
        setRoiCropSlice(obj, type, imgIn, handles, roiNo, sliceNo, orient, options, col_channel); % Update a 2D slice of the ROI regions of the dataset.
        
        custom_img = setSlice(obj, type, slice, slice_no, orient, col_channel, custom_img, options); % Update the 2D slice of the dataset
        
        custom_img = setSliceToShow(obj, type, slice, slice_no, orient, col_channel, custom_img, options); % Update the croped to the viewing window 2D slice of the dataset
        
        swapColorChannels(obj, channel1, channel2)  % swap two color channels
        
        transpose(obj, new_orient); % Change orientation of the image to the XY, XZ, or YZ plane.
        
        handles = updateAxesLimits(obj, handles, mode, newMagFactor); % Updates the imageData.axesX and imageData.axesY during fit screen, resize, or new dataset drawing
        
        updateBoundingBox(obj, newBB, xyzShift, imgDims); % Update the bounding box info of the dataset
        
        updateDisplayParameters(obj); % Update display parameters for visualization.
        
        updateImgInfo(obj, addText, action, entryIndex); % Update action log
        
        result = updateParameters(obj, pixSize); % Update imageData.pixelSize, imageData.img_info(''XResolution'') and imageData.img_info(''XResolution'')
        
        function obj = imageData(handles, model_type, img)
            % function obj = imageData(handles, model_type)
            % Constructor for the imageData class.
            %
            % Create a new instance of the class with default parameters.
            %
            % Parameters:
            % handles - @b [optional] handles structure of im_browser
            % model_type - @b [optional], parameter to setup the model type
            % img - @b [optional], image to use to initialize imageData
            % class
            %
            % Return values:
            % obj - instance of the imageData class.
            
            if exist('handles','var')
                obj.modelMaterialColors = handles.preferences.modelMaterialColors;
                obj.lutColors = handles.preferences.lutColors;
                if handles.preferences.uint8 == 1
                    obj.model_type = 'uint8';
                else
                    obj.model_type = 'uint6';
                end
            else
                obj.modelMaterialColors = [166 67 33;       % default colors for the materials of models
                                             71 178 126;
                                             79 107 171;
                                             150 169 213;
                                             26 51 111;
                                             255 204 102 ]/255;
                obj.lutColors = [       % add colors for color channels
                    1 0 0     % red
                    0 1 0     % green
                    0 0 1     % blue
                    1 0 1     % purple
                    1 1 0     % yellow
                    1 .65 0]; % orange
                obj.model_type = 'uint6';
            end
            if exist('model_type','var')
                obj.model_type = model_type;
            end
            
            if nargin == 3
                obj.clearContents(img);
            else
                obj.clearContents();
            end
        end
    end
end