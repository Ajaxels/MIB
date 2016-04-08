% @page docnewbeta What's new in beta
% Microscopy Image Browser Release Notes for the beta development
%
% @section v10000 1.0000 (19.11.2015)
% - Added X/Y calibration of the loaded dataset using an existing scale bar printed on images (Menu->Dataset->Scale bar)
% - Replaced function that calculates adjacency of supervoxels in the graphcut and classifier tools to Region Adjacency Graph (RAG) by David Legland
% - Added Stereology mode to count intersections of materials of the model with a grid lines (Menu->Tools->Stereology)
% - Added watershed superpixels and supervoxels to the graphcut segmentation
% - Added watershed superpixels to the Brush tool
% - Added watershed superpixels/supervoxels to the superpixel classifier
% - Added customization dialog for key shortcuts (File->Preference->Shortcuts)
% - Added detection of LUTs for color channels when using the Bio-Formats reader
% - Fixes 
%
% @section v09990 0.9990 (30.09.2015)
% - Added Maxflow/mincut semi-automatic segmentation (Menu->Tools->Watershed/Graphcut segmentation)
% - Added Supervoxel/superpixel based classifier (Menu->Tools->Classifiers->Supervoxels classification)
% - Added a mode for chopping and combining back large images (Menu->File->Chop images...)
% - Added possibility to calculate multiple properties of objects in the
% Get Statistics... dialog (Menu->Models->Model Statistics...)
% - Added rendering of measurements to snapshots
% - Added modification of the adaptive coefficient for the brush with the
% supervoxels mode: while drawing use the mouse wheel to change the
% coefficient
% - Added Undo for the Brush tool with superpixels, while selecting
% superpixels press the Ctrl+Z shortcut to undo selection of the last
% superpixel
% - Added RegionGrowing mode to the Magic Wand tool
% - Added Affine Transformation mode to the Alignment tool 
% - Added new methods to access the dataset: imageData.getData2D,
% imageData.getData3D, imageData.getData4D, imageData.setData2D, imageData.setData3D, imageData.setData4D that replace old methods
% imageData.getDataset and imageData.setDataset.
% - Added possibility to crop dataset based on detected 2D objects: Menu->Model Statistics...->Run->Select objects and press the right mouse button->Crop to a file/matlab...
% - Modified syntax of the imageData.getDatasetDimensions method call
% - Modified Make video dialog: now it is not modal; added back-and-forth option
% - Preserve the current magnification during the orientation switch using the Alt+1, Alt+2 and Alt+3 shortcuts
%
% @section v09980 0.9980 (28.04.2015)
% - Added stand-alone version for Mac OS (tested with OS X Yosemite, ver. 10.10.3 and Matlab R2014b)
% - Added Measure Tool (Menu->Tools->Measure length->Measure tool)
% - Added possibility to crop dataset based on detected 3D objects: Menu->Model Statistics...->Run->Select objects and press the right mouse button->Crop to a file/matlab...
% - Completely rewritten roiRegion class to perform faster in the R2014b
% and later
% - Added possibility to change font name in the |Menu->File->Preferences|
% dialog
% - Fixed many issues with Linux and MacOS compatibility
%
% @section v09970 0.9970 (24.03.2015)
% - Added highlighting of the current file, when switching the buffers 
% - Added names of series during opening of datasets using Bioformats
% - Added morphological filters to the Mask Generators panel, imextendedmax, imextendedmin, imregionalmax, imregionalmin
% - Added a context menu to the Pixel Information text of the Path panel
% for instant jump to desired position within the dataset
% - Added a new dialog to define coordinates of the bounding box
% - Update: colors of materials are stored with the ImageData class, now
% the colors are also saved together with the model
% - Update: the LUT colors are stored in the imageData class
% - Update: Bio-formats library is now bioformats_package.jar  
% - Update: Connection to Imaris
% - Modified the Mask Generators panel
% - Fixed opening of images with different XY and color channels using Bioformats
% - Fixed generation of JPG snapshots for 16-bit images
% - Fixed triggering of the key press callback during the pan mode
% - Fixed dublicates of the brush cursor in some situations
%
% @section v09960 0.9960 (06.03.2015)
% - Added CZI format to the list of extensions
% - Added a custom input dialog 
% - Annotations and measure tools are available when the model/selection layers are turned off
% - Updated to the new server for updates, at http://mib.helsinki.fi
% - Multiple fixes in the mode when the model/selection layers are turned off
% - Bug fixes
%
% @section v09950 0.9950 (26.01.2015)
% - Adaptation to Matlab R2014b
% - Added Smart Watershed to the segmentation tools (Segmentation
% panel->Selection type->Smart watershed); check also improved watershed tool (Menu->Tools->Watershed)
% - Added number of morphological operations for images:
% Menu->Image->Morphological operations
% - Added increase of the brush size by ~40% when starting the Erase mode (by holding the Control key)
% - Added import/export images from Imaris: Menu->File->Import(Export)->Imaris (requires Imaris and ImarisXT)
% - Added import images from URL link: Menu->File->Import->URL
% - Added Annotations to the statistical filtering window. The right mouse button above
% the Statistics table starts a popup menu with access to annotations.
% - Added Gradient 2D and Gradient 3D filters to the Image Filters panel
% - Added tools for manipulation with the colormaps in the Preferences dialog
% - Added rendering models with Imaris: Menu->Models->Render
% model...->Imaris
% - Many functions moved from im_browser.m to a separate files located in the GuiTools directory
% - Improved rendering of large images using the 'nearest' resampling mode
% - Updated and significantly improved the <ug_gui_menu_tools_watershed.html watershed tool>
% - Renamed the |Mask/Model| segmentation tool to |Object Picker|
% - Fixed import of models with more colors than defined in MIB
% - Fixed rotation of datasets with the Mask or Model layers
% - Moved Top and Bottom hat filters to the morphological operations for images:
% Menu->Image->Morphological operations 
%
% @section v09940 0.9941 (23.09.2014)
% - Added color palettes for materials of models, Menu->File->Preferences->Colors
% - Added conversion to HSV colorspace, test version
% - Added possibility to plot a histogram in the Statistics dialog
% - Added restore default settings button to the Preferences window
% - Added paste from Clipboard: Menu->File->Import image from->Clipboard
% - Rearranged files/directories
% - Updated BioFormats reader
% - Fixed bugs with dynamic sliders in the deployed version
% - Fixed bug in the wrong shifts of datasets during alignmen
% - Fixed bug with ROI during duplication of datasets
%
% @section v09932 0.9932 (23.06.2014)
% - Added the Random forest classifier for tests, original functions from <http://www.kaynig.de/demos.html Verena Kaynig> and <https://code.google.com/p/randomforest-matlab/ randomforest-matlab> by Abhishek Jaiantilal.
% - Added EndPointsLength statistics for 3D lines
% - Updated EndPointsLength statistics is now reported in the image units
% - Updated the Make Snapshot dialog 
% - Updated the Image Adjustment dialog 
% - Updated the Magic Wand tool: it is possible to specify an effective radius of for the tool 
% - Updated the Spot tool: much faster
% - Fixed MembraneClickTracker tool for straight lines in 3D with width = 1 and for the points at the edge of the image
% - Fixed saving of individual materials of the models
%
% @section  v09931 0.9931 (22.05.2014)
% - Added: conversion of multichannel images to greyscale
% - Improved: refreshing of the opened auxiliary windows
% - Updated: the watershed segmentation was updated to seeded watershed.
% - Fixed: image rescaling during resize of the main window
%
% @section v09930 0.9930 (20.05.2014)
% - Added a layer for Annotations, a label that may be placed at desired
% part of the dataset (|Segmentation panel->Selection type->Annotations|).
% - Improved speed of image generation when the Show model switch is On
% - Some sliders were updated to allow real-time feedback
% - Modified the Segmentation panel by introducing the Show all checkbox
% - Added possibility to synchronize the views between opened datasets. Use
% a popup menu for the buffer buttons in the Directory contents panel.
% - Added indication of intensity of the 4th color channel during the mouse move above the image
% - Added Rectangle, Ellipse and Polyline type of selections to the Lasso segmentation tool
% - Added possibility to use original filenames when saving dataset in Jpeg, PNG and TIF formats
% - Added possibility to see a single channel using a Ctrl+left mouse click
% above the checkboxes of the Colors table in the View settings panel.
% - Added sorting by slice number to the Get Statistics dialog (right mouse click above the Sort button)
% - Updated the Adjust Display dialog with colors and right mouse callbacks
% for the sliders to set sliders to 0 and maximal possible values
% - Improved BioFormats reading dialog
% - Fixed saving models (removed the Selection and Mask layers) using the Save Model button in the toolbar
% - Fixed generation of statistics for the currently shown slice
%
% @section v09923 0.9923 (20.03.2014)
% - Changed implementation of the Membrane Click Tracker tool. Now
% Shift+mouse click defines the first point of the membrane domain.
% - Fixed very long parameter names in the Dataset Info window; added display in the upper part of the
% Dataset Info window to show entry in the selected cell.
% - The Image Profile functions were updated for multicolored datasets
%
% @section v09922 0.9922 (06.03.2014)
% - Added the Interpolation type button to the toolbar.
% - Added possibility to insert another dataset to the opened dataset. 
% - Skip dataset selection for BioFormats reader, when only one dataset
% present
% - Extended filename information of the current dataset in the View Image Panel
% - Several bug fixes and improvements
%
% @section v09921 0.9921 (25.02.2014)
% - Added watershed segmentation, Menu->Tools->Watershed
% - Added support for NRRD format, a native format of 3D slicer
% - Added file name to the title of the Image View panel
% - Added landmark alignment mode for the opened datasets, some fixes of 
% the alignment.
% - Renamed Menu->Measure to Menu->Tools
% - Modified formation of Z stacks with datasets of different dimensions,
% now the data is not cropped.
% - The brightness slider in the View settings panel was replaced with the
% live stretch check box. When enabled im_browser automatically adjust
% contrast for each shown image; but only for preview, the actual image
% intensities will not be affected.
% - Fixed auto-updater for Matlab release R2012a and older.
% - Fixed Delete Slice for multiple slices
%
% @section v09919 0.9919 (11.02.2014)
% - Added posibility to define a step for thresholding sliders in the BW
% thresholding selection tool, available via a popup menu (right mouse click on the sliders)
% - Fixed import models bug
% - Set the Column Format in the Value column of the MaskStatsDlg to the 'short
% g' representation.
%
% @section v09917 0.9917 (10.02.2014)
% - Added possibility to change font size
% - Added a context menu to the Adjust channel button of the Display
% adjustment dialog. The menu allows contrast adjustment of the currenly
% shown slice.
% - Updated selection of the fast-access tools for the "D" key shortcut.
% Now the tools can be selected using the *D* checkbox in the <ug_panel_segm.html Segmentation panel>
%
% @section v09916 0.9916 (31.01.2014)
% - Improved brush performance for the brush size
%
% @section v09915 0.9915 (30.01.2014)
% - Added Matlab normalized 2-D cross-correlation to the Alignment options for tests
% - It is possible to open multiple series using BioFormats reader
% - Updated Stop Fiji routine
% - Improved sensitivity of the Membrane ClickTracker tool
% - Fixed network update for the deployed version
% - Fixed background colors in some windows
%
% @section v09914 0.9914 (25.11.2013)
% - Large update of the ROI mode. Now the ROIs are bound to the image dataset, so it is possible to have set of ROI for each
% opened image
% - Added positioning of the logList window to the bottom of the main window
% - Fixed ib_maskGenerator.m for multi-colored datasets
% - Fixed implementation of BioFormats for the deployed version
% 
% @section v09913 0.9913 (19.11.2013)
% - Added store position of the selected mode in the Get Statistics dialog, plus some other modifications in the same dialog
% - Fixed a bug in the imageData.plotImage function, when the brightness slider is used 
% - Added delete the maskStatsDlg and ib_datasetInfoGui dialogs after close of im_browser
%
% @section v09912 0.9912 (15.11.2013)
% - Added Duplicate dataset to the context menu of the buffer buttons: |Directory Contents->Buffer buttons->right mouse
% click->Duplicate dataset|
% - Added 'Enter' and 'Esc' shortcuts to Load Bioformats, make snapshot, make movie, morph ops dialogs
% - Added synchronozation of Image Info tables between different datasets, using |FindJObj.m| function
% - Moved all functions from ImageData class to own files
% - Updated coloring of the brush tool during the brush motion for 16bit images
%
% @section v09911 0.9911 (13.11.2013)
% - Added a new window for showing parameters of the dataset (Path panel->Info button)
% - Added ROI mode to the Make snapshot dialog (Menu->File->Make Snapshot...)
% - Added ROI mode to the Make video dialog (Menu->File->Make Movie...)
% - Added use of system TEMP folder to store |im_browser| parameters as a second choice, when _c:\temp_ is not available for
% writing (settings are stored in _im_browser.mat_)
% - Added PNG format to Save image as dialog
% - the Adjust Display window does not show histogram for modified gamma, but shows histogram for all color channels
% - Combine as color channels - added to the popup menu in the file listing of the Directory contents panel
% - Updated saving of multichannel images in Amira Mesh format
% - Updated the color table in the View settings panel
% - Replaced '\t' character in the ImageDescription field to the '|'
%
% @section v09910 0.9910 (06.11.2013)
% - Added short release notes in the automatic update
% - Added LUT (look-up table) for defining a custom set of colors for color channels
% - Added copy color channel: Menu->Image->Color Channels->Copy channel...
% - Added copy color channel: Menu->Image->Color Channels->Invert channel...
% - Updated Preferences dialog: Menu->File->Preferences
% - Moved some functions from the class to external files
% - Renamed |cropImage| to |cropDataset| function in the |imageData| class
%
% @section v09909 0.9909 (18.10.2013)
% - Added tooltips to some toolbar buttons
% - Added rehash of files after using web-update of |im_browser|
% - Added TIF to bio-formats file filter
% - Added synchronization of the Material list boxes in the segmentation panel (|Materials List->right mouse button->Sync all
% lists|)
% - Updated un-focusing behavior with some edit and combo boxes
% - Updated colors of the Preferences dialog;
% - Fixed import/export |img_info| containers.Map class object with description of the dataset. The |img_info| map is a handle
% so it has to be reinitialized: |img_info_new = containers.Map(keys(img_info), values(img_info));|
%
% @section v09908 0.9908 (17.10.2013)
% - Added preservation of the bounding box during alignment of stacks
% - Fixed bug of the bounding box settings (introduced in 0.9904)
% - Minor improvements
%
% @section v09907 0.9907 (14.10.2013)
% - Fixed resizing of the slider responsible for change of slices
%
% @section v09906 0.9906 (10.10.2013)
% - Added 3D Frangi filter (Mask Generators->Frangi filter)
%
% @section v09905 0.9905 (07.10.2013)
% - Added selection of the first and last points for rendering videos (Menu->File->Save as video...)
%
% @section v09904 0.9904 (03.10.2013)
% - Taken into account stage rotation bias when calculating the bounding box (rotation stage bias field in the |Menu->Dataset->Bounding Box| dialog).
%
% @section v09903 0.9903 (02.10.2013)
% - Fixed the memory clearance after disabling of the Selection mode in the preference dialog for the uint6 models
%
% @section v09902 0.9902 (24.09.2013)
% - Added fast pan mode, for fast navigation when showing large XY images (|Toolbar->Fast pan mode|)
% - Fixed in the |Menu->Selection->Mask| and |Mask->Selection|
%
% @section v09901 0.9901 (18.09.2013)
% - Added ultimate erosion
% - Implementated automatic check for updates
% - Fixed modification of ROI for large images
%
% @section Alpha Alpha
% Alpha version of Microscopy Image Browser was under development between
% 2010-2013.
