%% Dataset Menu
% Modify parameters such as voxel sizes and the bounding box for the
% dataset, start the Alignment tool, or do some other dataset related actions.
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_menu.html *Menu*>
%
%% Alignment tool...
% Can be used to align the slices of the opened dataset or to align two
% separate datasets. *Note the limitation!* -  area selected for the alignment should be present on
% both images completely. See more in the Alignment of datasets tutorial pages
% (<http://www.biocenter.helsinki.fi/~ibelev/projects/im_browser/tutorials/AlignmentTool.html
% html>, <http://www.biocenter.helsinki.fi/~ibelev/projects/im_browser/tutorials/pdf/AlignmentTool.pdf pdf>).
%
% 
% <<images/menuDatasetAlignTool.jpg>>
% 
%
% *Description of the panels:*
% 
% * *Current dataset* - shows details of the opened dataset.
% * *Mode* - allows to select alignment mode to align either slices within
% the opened dataset or two separate datasets.
% * *Method* - selection of method to be used for the alignment: either normalized cross-correlation or normalized sum of squared differences.
% * *Second stack* - available only in the |Align two stacks| mode allows
% to select the second dataset as a stack of images in a single file, in a
% series of files in one directory, or import a variable with the dataset
% from the main Matlab workspace. When the |automatic| mode is selected the
% script will calculate the shifts. The shifts however can be provided
% manually, when the |automatic| check box is unchecked. In this case it is required to find the reference point on two
% images, take its X and Y coordinates and calculate the shifts as: |shiftX = X1 - X2| and |shiftY = Y1 - Y2|.
% * *Parameters* - mainly parameters of the search window that will be used
% for alignment. This window can be defined manually or uploaded from the
% |Selection| layer with the |Get from Selection| button. The shifts of
% images results in empty areas that can be filled with black, white or
% mean color of the image. In addition, if the |Align the current dataset|
% mode is used, it is possible to import and export the list of shifts 
% between the images. 
%
%% Crop dataset...
% Crop the image and corresponding Selection, Mask, and Model layers.
% Cropping can be done in the Interactive, Manual or using ROI mode. 
% 
% <<images/menuImageCropDlg2.jpg>>
% 
% When the interactive mode is selected it is possible to draw (by pressing and holding left mouse button) a rectangle
% area a top of the image. This area can then be used for cropping. 
%
% The values for cropping may also be provided directly by enabling the
% |Manual| mode. It is also possible to do cropping based on the selected
% ROI. Use the <ug_panel_roi.html ROI panel> to make them.
%
% The cropped datasets can be placed back to the original dataset using the
% _Fuse into existing_ mode of the _Chop image tool_ available at
% |Menu->File->Chop images...->Import...|. <ug_gui_menu_file_chop.html See more here.>
% 
% 
%% Resample...
% Resample image in any possible direction. 
%%
% 
% <<images/menuImageResampleDlg.jpg>>
% 
%
%% Transform
% Transformation of dataset: image and all other layers. The following modes are possible
%
% 
% * *Flip horizontally* - flips dataset left to right, returns the dataset with columns flipped in the left-right direction, that is, about a vertical axis
% * *Flip vertically* - flips dataset up to down, returns the dataset with rows flipped in the up-down direction, that is, about a horizontal axis
% * *Flip Z* - flips dataset in the Z dimension, returns the dataset with slices flipped in the first-last direction, that is, about a middle slice of the dataset
% * *Flip Y* - flips dataset in the T dimension, returns the dataset with time frames flipped in the first-last direction, that is, about a middle frame of the dataset
% * *Rotate 90 degrees* - rotates dataset 90 degrees clockwise diirection
% * *Rotate -90 degrees* - rotates dataset 90 degrees anti-clockwise diirection
% * *Transpose XY -> ZX* - physically transposes the dataset, so that the XY orienation, becomes ZX
% * *Transpose XY -> ZY* - physically transposes the dataset, so that the XY orienation, becomes ZY
% * *Transpose ZX -> ZY* - physically transposes the dataset, so that the ZX orienation, becomes ZY
% * *Transpose Z <-> T* - physically transposes the dataset, so that the Z orienation, becomes T
% 
%% Slice
% Manipulations with individual slices of the dataset. The following actions are possible
%
% 
% * *Delete slice(s)...* - removes desired slice(s) from a Z-stack of the
% dataset. _For example, type " |5:10| " to delete all slices from slice 5 to
% slice 10._
% * *Delete frame(s)...* - removes desired frame(s) from a time series of the
% dataset.
%
%% Scale bar
% Scale bar is a tool that allows to use a scale bar printed on the 
% image to calibrate physical size (X and Y) for pixels in MIB.
% 
% How to use:
%
% 
% <<images/menuDatasetScalebar.jpg>>
% 
%% Bounding Box...
% Bounding Box defines position of the dataset in the 3D space; the
% bounding box information is important for positioning
% of datasets in the visualization software, such as Amira.
% The bounding box can be shifted based
% on its minimal or centeral coordinates. The current coordinates of the bounding box 
% are shown under the _Current Bounding Box_ text.
% 
% *Attention!* For 3D images the bounding box is calculated as the smallest
% box containing all voxel centers, but not all voxels as is! _I.e._ it's defined by the voxel centers, which means 
% that a 1/2 voxel on both sides of the bounding box are subtracted, resulting in a bounding box that is 1 voxel smaller in all three directions.
% 
%
% <<images/menuDatasetBoundingBox.jpg>>
% 
% 
% * *X, Y, Z, min* - defines minimal coordinates of the bounding box
% * *X, Y, center* - defines central coordinates of the dataset. When the
% central coordinates are used the |X, min| and |Y, min| coordinates are
% going to be recalculated.
% * **X, Y, Z max* - maximal values of the bounding box. When entered
% together with the *X, Y, Z min* coordinates - MIB recalculates the voxel sizes.
% * *Stage rotation bias, degrees* - implemented only when entering X, Y center coordinates. Allows recalculation of the
% coordinates for the cases when the stage has some rotation bias, for example, Gatan 3View has 45 degrees stage bias.
% * *Import from Clipboard*, parses text in the system clipboard and
% automatically extracts the following parameters (syntax: _[ParameterName] = [ParameterValue]_): 
%
%
% <html>
% <table style="width: 550px; text-align: center;" cellspacing=2px cellpadding=2px >
% <tr>
%   <td style="width=150px;"><b>Parameter Name</b></td><td><b>Description</b></td>
% </tr>
% <tr>
%   <td style="width=150px;">ScaleX</td><td>The physical size of pixels in X</td>
% </tr>
% <tr>
%   <td style="width=150px;">ScaleY</td><td>The physical size of pixels in Y</td>
% </tr>
% <tr>
%   <td style="width=150px;">ScaleZ</td><td>The physical size of pixels in Z</td>
% </tr>
% <tr>
%   <td style="width=150px;">xPos</td><td>Central position of the dataset in the X plane</td>
% </tr>
% <tr>
%   <td style="width=150px;">yPos</td><td>Central position of the dataset in the Y plane</td>
% </tr>
% <tr>
%   <td style="width=150px;">Z Position</td><td>Minimal Z coordinate</td>
% </tr>
% <tr>
%   <td style="width=150px;">Rotation</td><td>Rotation BIAS<br><b>Note!</b><br><em>Since it is designed for Gatan 3View system MIB adds 45 degrees to the detected rotation value</em></td>
% </tr>
% </table>
% </html>
%
% Example of text that can be copied to the system clipboard for automatic
% detection of paramters:
% 
% <<images/menuDatasetBoundingBox2.jpg>>
% 
% 
% 
%% Parameters
% Modifies parameters of the dataset: voxels sizes, frame rate for movies and
% units. Enter of new voxels results in recalculation of the bounding box.
%%
% 
% <<images/menuDatasetParameters.jpg>>
% 
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_menu.html *Menu*>
