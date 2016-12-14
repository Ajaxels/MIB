%% Microscopy Image Browser Release Notes
% 
%
% <im_browser_product_page.html Back to Index>
%
%
%%
%% 1.304 09.12.2016
% * Improved and simplified the Segmentation panel
% * Added list of recent directories
% * Added "Mask_" prefix to filename when saving masks
% * Added "FirstAxisLength" and "SecondAxisLength" properties to the Get
% Statistics dialog for calculation of exact lengths of the objects (ver 1.302)
% * Added default state of the link channels checkbox to selected in the
% Display adjustment dialog (ver 1.302)
% * The contrast normalization over selected areas in Z does not require selection of all slices
% * Fix of substructures in Dataset Info dialog
% * Fix of fine-tune checkbox for the freehand mode of the measure tool
% * Improved performance of black-and-white thresholding
% * Fix of add matarial bug (ver 1.303)
% * Fix of export annotations to a file for MacOS (ver 1.303)
% * Fix startup crashes for compiled MIB on some windows configurations (ver 1.304)
%
%% 1.233 07.10.2016 
% * Completely rewritten alignment tool, now it is much faster and more reliable
% * Added loading and combining MRC models from IMOD
% * Added convertion from uint16 to uint8 using the currently selected display adjustments settings (ver. 1.232)
% * Added automatic scaling of scale bars for large snapshots
% * Added adjustment of the image contrast during supervoxel calculation in the graphcut tool
% * Added links to many short demo clips to the Help (ver. 1.233)
% * Improved performance of the shape interpolation tool (ver. 1.232)
% * Update movie rendering, now it will also render movies from 16-bit images
% * Update of the alignment tool for the YZ and XZ dimensions (ver. 1.233)
% * Fix of uncleared memory after closing of datesets, introduced in MIB 1.20
% * Few small fixes in the mib_measureTool and in the alignment tool (ver. 1.231)
% * The 'handles' handle has been removed from getImageMetadata(filenames,
% options); the required fields handles.matlabVersion and
% handles.preferences.Font were included into the options structure
%
%% 1.22 22.08.2016 
% * Added extra options for exporting models and masks from the Statistics
% window
% * Mostly bug fixes
%
%% 1.21 29.06.2016 
% * Fixed horizontal/vertical flipping for 2D datasets
% * Fix of several small bugs
%
%% 1.20 20.06.2016 
% * Added Volume Rendering for small datasets (Toolbar->Volume rendering button)
% * Added the Crop To mode to the Crop tool (Menu->Dataset->Crop dataset...)
% * Added split color channels mode for the snapshots
% * Added possibility to copy ROI areas to the Selection layer (ROI
% Panel->the ROI to Selection button) 
% * Added rotation of a single color channel for square-shaped images
% (Menu->Image->Color channels->Rotate channel...) 
% * Updated Image Description dialog: Path Panel->Info
% * Updated the Chop/Rechop modes
% * Updated Bio-Formats library to 5.1.10
% * Fixed version check for MacOS Matlab R2012a
% * Fixed a bug during object unselection in the Object picker tool
% * Bug fixes
% * |java_path.txt| was renamed to |mib_java_path.txt| and placed to the first folder on the search path (usually |[username]\Documents\MATLAB|; path to this file will be displayed in the command prompt during start of MIB)
%
%% 1.10 07.04.2016 (update for 4D datasets)
%
% * Modification of MIB to work with 4D data (H,W,C,Z,T)
% * Replaced imageData.slices(1:4,:) matrix variable with a cell imageData.slices{1:5}(:)
% * Replaced imageData.slicesColor variable with imageData.slices{3}(:)
% * Renamed functions: getData3D->getData2D; getData4D->getData3D; getData5D->getData4D; setData3D->setData2D; setData4D->setData3D; setData5D->setData4D;
% * Added ib_getStack, ib_setStack methods for working with individual stacks of 4D datasets 
% * Added flip time points of the dataset (Menu->Dataset->Transform->Flip T)
% * Added transpose of Z to T dimension (Menu->Dataset->Transform->Transpose Z<->T)
% * Added insert of an empty color channel to the dataset (Menu->Image->Color channels->Insert empty channel)
% * Added possibility to delete a time frames (Menu->Dataset->Delete slice->Delete frame(s)...)
% * Added additional modes for CLAHE contrast (Menu->Image->Contrast->CLAHE)
% * Added Bin2, Bin4, Bin8 buttons to the Snapshot dialog
% * Added the link checkbox to the Display adjustment dialog to link modification of settings for all shown color channels
% * Added Frangi 2D/3D filters to the Image Filters panel, the panel was also redesigned
% * Added t-parameter to imageData.clearSelection
% * Added reading/writing of BigDataViewer HDF5 format for Fiji
% * Improved data exchange with Imaris, added export of models as volumes to Imaris (Menu->Models->Export model to...->Imaris as volume)
% * Improved loading and saving of HDF5 datasets
% * Improved performance of many manual segmentation tools
% * Modified call of ib_moveLayers
% * Updated TIF reader to accept pyramidal TIFs from Zeiss microscopes
% * Updated Menu->Image->Invert image with various options
% * Updated programming tutorials
% * Optimized Undo functionality to make it faster and use less memory
% * Bug fixes
%
%% 1.02 20.01.2016
% * Added resizing of panels
% * Added undo for the brush in the superpixel mode (press Ctrl+Z while drawing to unselect superpixels)
% * Added save models using the STL format (Menu->Models->Save model as...)
% * Added a button to change image interpolation type to the toolbar
% (nearest/bicubic) and removed bilinear interpolation from the visualization
% options
% * Updated the drawing of scalebars, now they are displayed as round numbers
% * Updated the Watershed/Graphcut segmentation tool
% * Fixed the length of a scale bar in snapshots after resizing
% * Fixed elements of GUI that were not properly resized
% * Fixed use of the memory function for non-windows operating systems
%
%% 1.00 19.11.2015 Official Release
% * Added X/Y calibration of the loaded dataset using an existing scale bar printed on
% images (Menu->Dataset->Scale bar)
% * Replaced function that calculates adjacency of supervoxels in the graphcut and classifier tools to <http://www.mathworks.com/matlabcentral/fileexchange/16938-region-adjacency-graph--rag- Region Adjacency Graph (RAG)> by David Legland
% * Added Stereology mode to count intersections of materials of the model with a grid lines (Menu->Tools->Stereology)
% * Added watershed superpixels and supervoxels to the graphcut segmentation
% * Added watershed superpixels to the Brush tool
% * Added watershed superpixels/supervoxels to the superpixel classifier
% * Added customization dialog for key shortcuts (File->Preference->Shortcuts)
% * Added detection of LUTs for color channels when using the Bio-Formats reader
% * Fixes 
%
%% 0.999 30.09.2015
% * Added Maxflow/mincut semi-automatic segmentation (Menu->Tools->Watershed/Graphcut segmentation)
% * Added Supervoxel/superpixel based classifier (Menu->Tools->Classifiers->Supervoxels classification)
% * Added a mode for chopping and combining back large images (Menu->File->Chop images...)
% * Added possibility to calculate multiple properties of objects in the
% Get Statistics... dialog (Menu->Models->Model Statistics...)
% * Added rendering of measurements to snapshots
% * Added modification of the adaptive coefficient for the brush with the
% supervoxels mode: while drawing use the mouse wheel to change the
% coefficient
% * Added Undo for the Brush tool with superpixels, while selecting
% superpixels press the Ctrl+Z shortcut to undo selection of the last
% superpixel
% * Added RegionGrowing mode to the Magic Wand tool
% * Added Affine Transformation mode to the Alignment tool 
% * Added new methods to access the dataset: _imageData.getData2D_,
% _imageData.getData3D_, _imageData.getData4D_, _imageData.setData2D_,
% _imageData.setData3D_, _imageData.setData4D_ that replace old methods
% _imageData.getDataset_ and _imageData.setDataset_
% * Added possibility to crop dataset based on detected 2D objects:
% Menu->Model Statistics...->Run->Select objects and press the right mouse
% button->Crop to a file/matlab...
% * Modified syntax of the imageData.getDatasetDimensions method call
% * Modified Make video dialog: now it is not modal; added back-and-forth
% option
% * Preserve the current magnification during the orientation switch using the Alt+1, Alt+2 and Alt+3 shortcuts
%
%% 0.998 05.05.2015
% * Added stand-alone version for Mac OS (tested with OS X Yosemite, ver. 10.10.3 and Matlab R2014b)
% * Added Measure Tool (Menu->Tools->Measure length->Measure tool)
% * Added superpixels mode for the brush tool
% * Added possibility to crop dataset based on detected 3D objects:
% Menu->Model Statistics...->Run->Select objects and press the right mouse
% button->Crop to a file/matlab...
% * Completely rewritten roiRegion class to perform faster in the R2014b
% and later
% * Added possibility to change font name in the |Menu->File->Preferences|
% dialog
% * Fixed many issues with Linux and MacOS compatibility
%
%% 0.997 24.03.2015
% * Added highlighting of the current file, when switching the buffers 
% * Added names of series during opening of datasets using Bioformats
% * Added morphological filters to the Mask Generators panel:
% imextendedmax, imextendedmin, imregionalmax, imregionalmin
% * Added a context menu to the Pixel Information text of the Path panel
% for instant jump to desired position within the dataset
% * Added a new dialog to define coordinates of the bounding box
% * Update: colors of materials are stored with the ImageData class, now
% the colors are also saved together with the model
% * Update: the LUT colors are stored in the imageData class
% * Update: Bio-formats library is now bioformats_package.jar  
% * Update: Connection to Imaris
% * Modified the Mask Generators panel
% * Fixed opening of images with different XY and color channels using Bioformats
% * Fixed generation of JPG snapshots for 16-bit images
% * Fixed triggering of the key press callback during the pan mode
% * Fixed dublicates of the brush cursor in some situations
%
%% 0.996 06.03.2015
% * Added CZI format to the list of extensions
% * Added a custom input dialog 
% * Annotations and measure tools are available when the model/selection layers are turned off
% * Updated to the new server for updates, at http://mib.helsinki.fi
% * Multiple fixes in the mode when the model/selection layers are turned off
% * Bug fixes
%
%% 0.995 26.01.2015
% * Adaptation to Matlab R2014b
% * Added Smart Watershed to the segmentation tools (Segmentation
% panel->Selection type->Smart watershed); see also <ug_gui_menu_tools_watershed.html improved watershed tool>
% * Added number of morphological operations for images:
% Menu->Image->Morphological operations
% * Added increase of the brush size by ~40% when starting the Erase mode (by holding the Control key)
% * Added import/export images from <http://www.bitplane.com Imaris> : Menu->File->Import(Export)->Imaris (requires Imaris and ImarisXT)
% * Added import images from URL link: Menu->File->Import->URL
% * Added Annotations to the statistical filtering window. The right mouse button above
% <ug_gui_menu_mask_statistics.html the Statistics table> starts a popup menu with access to annotations.
% * Added Gradient 2D and Gradient 3D filters to the Image Filters panel
% * Added tools for manipulation with the colormaps in <ug_gui_menu_file_preferences.html#6 the Preferences dialog>
% * Added rendering models with Imaris: Menu->Models->Render model...->Imaris
% * Added calculation of the following properties for 3D objects:
% _MajorAxisLength, SecondMajorAxisLength, MinorAxisLength,
% MeriodionalEccentricity, EquatorialEccentricity_
% * Added Zoom in/out using the _Alt+Mouse wheel_ combination
% * Many functions moved from im_browser.m to a separate files located in the GuiTools directory
% * Improved rendering of large images using the 'nearest' resampling mode
% * Updated and significantly improved the <ug_gui_menu_tools_watershed.html watershed tool>
% * Renamed the |Mask/Model| segmentation tool to |Object Picker|
% * Fixed import of models with more colors than defined in MIB
% * Fixed rotation of datasets with the Mask or Model layers
% * Moved Top and Bottom hat filters to the morphological operations for images:
% Menu->Image->Morphological operations 
%% 0.9941 23.09.2014
% * Added color palettes for materials of models, Menu->File->Preferences->Colors
% * Added conversion to HSV colorspace, test version
% * Added possibility to plot a histogram in the Statistics dialog
% * Added restore default settings button to the Preferences window
% * Added paste from Clipboard: Menu->File->Import image from->Clipboard
% * Rearranged files/directories
% * Updated BioFormats reader
% * Fixed bugs with dynamic sliders in the deployed version
% * Fixed bug in the wrong shifts of datasets during alignmen
% * Fixed bug with ROI during duplication of datasets
%% 0.9932 23.06.2014
% * Added the Random forest classifier for tests, original functions from <http://www.kaynig.de/demos.html Verena Kaynig> and <https://code.google.com/p/randomforest-matlab/ randomforest-matlab> by Abhishek Jaiantilal.
% * Added EndPointsLength statistics for 3D lines
% * Updated EndPointsLength statistics is now reported in the image units
% * Updated the Make Snapshot dialog 
% * Updated the Image Adjustment dialog 
% * Updated the Magic Wand tool: it is possible to specify an effective radius of for the tool 
% * Updated the Spot tool: much faster
% * Fixed MembraneClickTracker tool for straight lines in 3D with width = 1 and for the points at the edge of the image
% * Fixed saving of individual materials of the models
%% 0.9931 22.05.2014
% * Added: conversion of multichannel images to greyscale
% * Improved: refreshing of the opened auxiliary windows
% * Updated: the watershed segmentation was updated to seeded watershed.
% * Fixed: image rescaling during resize of the main window
%% 0.9930 20.05.2014
% * Added a layer for Annotations, a label that may be placed at desired
% part of the dataset (|Segmentation panel->Selection type->Annotations|).
% * Improved speed of image generation when the Show model switch is On
% * Some sliders were updated to allow real-time feedback
% * Modified the Segmentation panel by introducing the Show all checkbox
% * Added possibility to synchronize the views between opened datasets. Use
% a popup menu for the buffer buttons in the Directory contents panel.
% * Added indication of intensity of the 4th color channel during the mouse move above the image
% * Added Rectangle, Ellipse and Polyline type of selections to the Lasso segmentation tool
% * Added possibility to use original filenames when saving dataset in Jpeg, PNG and TIF formats
% * Added possibility to see a single channel using a Ctrl+left mouse click
% above the checkboxes of the Colors table in the View settings panel.
% * Added sorting by slice number to the Get Statistics dialog (right mouse click above the Sort button)
% * Updated the Adjust Display dialog with colors and right mouse callbacks
% for the sliders to set sliders to 0 and maximal possible values
% * Improved BioFormats reading dialog
% * Fixed saving models (removed the Selection and Mask layers) using the Save Model button in the toolbar
% * Fixed generation of statistics for the currently shown slice
%% 0.9923 20.03.2014
% * Changed implementation of the Membrane Click Tracker tool. Now
% Shift+mouse click defines the first point of the membrane domain.
% * Fixed very long parameter names in the Dataset Info window; added display in the upper part of the
% Dataset Info window to show entry in the selected cell.
% * The Image Profile functions were updated for multicolored datasets
%% 0.9922 06.03.2014
% * Added the Interpolation type button to the toolbar.
% * Added possibility to insert another dataset to the opened dataset. 
% * Skip dataset selection for BioFormats reader, when only one dataset
% present
% * Extended filename information of the current dataset in the View Image Panel
% * Several bug fixes and improvements
%% 0.9921 25.02.2014
% * Added watershed segmentation, Menu->Tools->Watershed
% * Added support for NRRD format, a native format of 3D slicer
% * Added file name to the title of the Image View panel
% * Added landmark alignment mode for the opened datasets, some fixes of 
% the alignment.
% * Renamed Menu->Measure to Menu->Tools
% * Modified formation of Z stacks with datasets of different dimensions,
% now the data is not cropped.
% * The brightness slider in the View settings panel was replaced with the
% live stretch check box. When enabled im_browser automatically adjust
% contrast for each shown image; but only for preview, the actual image
% intensities will not be affected.
% * Fixed auto-updater for Matlab release R2012a and older.
% * Fixed Delete Slice for multiple slices
%% 0.9919 11.02.2014
% * Added posibility to define a step for thresholding sliders in the BW
% thresholding selection tool, available via a popup menu (right mouse click on the sliders)
% * Fixed import models bug
% * Set the Column Format in the Value column of the MaskStatsDlg to the 'short
% g' representation.
%% 0.9917 10.02.2014
% * Added possibility to change font size
% * Added a context menu to the Adjust channel button of the Display
% adjustment dialog. The menu allows contrast adjustment of the currenly
% shown slice.
% * Updated selection of the fast-access tools for the "D" key shortcut.
% Now the tools can be selected using the *D* checkbox in the <ug_panel_segm.html Segmentation panel>
%% 0.9916 31.01.2014
% * Improved brush performance for the brush size
%% 0.9915 30.01.2014
% * Added Matlab normalized 2-D cross-correlation to the Alignment options for tests
% * It is possible to open multiple series using BioFormats reader
% * Updated Stop Fiji routine
% * Improved sensitivity of the Membrane ClickTracker tool
% * Fixed network update for the deployed version
% * Fixed background colors in some windows
%% 0.9914 25.11.2013
% * Large update of the ROI mode. Now the ROIs are bound to the image dataset, so it is possible to have set of ROI for each
% opened image
% * Added positioning of the logList window to the bottom of the main window
% * Fixed ib_maskGenerator.m for multi-colored datasets
% * Fixed implementation of BioFormats for the deployed version
%% 0.9913 19.11.2013
% * Added store position of the selected mode in the Get Statistics dialog, plus some other modifications in the same dialog
% * Fixed a bug in the imageData.plotImage function, when the brightness slider is used 
% * Added delete the maskStatsDlg and ib_datasetInfoGui dialogs after close of im_browser
%% 0.9912 15.11.2013
% * Added Duplicate dataset to the context menu of the buffer buttons: |Directory Contents->Buffer buttons->right mouse
% click->Duplicate dataset|
% * Added 'Enter' and 'Esc' shortcuts to Load Bioformats, make snapshot, make movie, morph ops dialogs
% * Added synchronozation of Image Info tables between different datasets, using |FindJObj.m| function
% * Moved all functions from ImageData class to own files
% * Updated coloring of the brush tool during the brush motion for 16bit images
%% 0.9911 13.11.2013
% * Added a new window for showing parameters of the dataset (Path panel->Info button)
% * Added ROI mode to the Make snapshot dialog (Menu->File->Make Snapshot...)
% * Added ROI mode to the Make video dialog (Menu->File->Make Movie...)
% * Added use of system TEMP folder to store |im_browser| parameters as a second choice, when _c:\temp_ is not available for
% writing (settings are stored in _im_browser.mat_)
% * Added PNG format to Save image as dialog
% * the Adjust Display window does not show histogram for modified gamma, but shows histogram for all color channels
% * Combine as color channels - added to the popup menu in the file listing of the Directory contents panel
% * Updated saving of multichannel images in Amira Mesh format
% * Updated the color table in the View settings panel
% * Replaced '\t' character in the ImageDescription field to the '|'
%% 0.9910 06.11.2013
% * Added short release notes in the automatic update
% * Added LUT (look-up table) for defining a custom set of colors for color channels
% * Added copy color channel: Menu->Image->Color Channels->Copy channel...
% * Added copy color channel: Menu->Image->Color Channels->Invert channel...
% * Updated Preferences dialog: Menu->File->Preferences
% * Moved some functions from the class to external files
% * Renamed |cropImage| to |cropDataset| function in the |imageData| class
%% 0.9909 18.10.2013
% * Added tooltips to some toolbar buttons
% * Added rehash of files after using web-update of |im_browser|
% * Added TIF to bio-formats file filter
% * Added synchronization of the Material list boxes in the segmentation panel (|Materials List->right mouse button->Sync all
% lists|)
% * Updated un-focusing behavior with some edit and combo boxes
% * Updated colors of the Preferences dialog;
% * Fixed import/export |img_info| containers.Map class object with description of the dataset. The |img_info| map is a handle
% so it has to be reinitialized: |img_info_new = containers.Map(keys(img_info), values(img_info));|
%% 0.9908 17.10.2013
% * Added preservation of the bounding box during alignment of stacks
% * Fixed bug of the bounding box settings (introduced in 0.9904)
% * Minor improvements
%% 0.9907 14.10.2013
% * Fixed resizing of the slider responsible for change of slices
%% 0.9906 10.10.2013
% * Added 3D Frangi filter (Mask Generators->Frangi filter)
%% 0.9905 07.10.2013
% * Added selection of the first and last points for rendering videos (Menu->File->Save as video...)
%% 0.9904 03.10.2013
% * Taken into account stage rotation bias when calculating the bounding box (rotation stage bias field in the |Menu->Dataset->Bounding Box| dialog).
%% 0.9903 02.10.2013
% * Fixed the memory clearance after disabling of the Selection mode in the preference dialog for the uint6 models
%% 0.9902 24.09.2013
% * Added fast pan mode, for fast navigation when showing large XY images (|Toolbar->Fast pan mode|)
% * Fixed in the |Menu->Selection->Mask| and |Mask->Selection|
%% 0.9901 18.09.2013
% * Added ultimate erosion
% * Implementated automatic check for updates
% * Fixed modification of ROI for large images
%
%
% *Back to* <im_browser_product_page.html *Index*>
