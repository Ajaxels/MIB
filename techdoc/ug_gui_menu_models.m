%% Model Menu
% Actions that can be applied to the |Model| layers. The |Model layer| is one
% of three main segmentation layers (|Model, Selection, Mask|) which can be
% used in combibation with other layer. See more about segmentation layers
% in <ug_gui_data_layers.html the Data layers of Microscopy Image Browser section>.
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_menu.html *Menu*>
%
%% New model
% Allocates space for a new model. Use this entry when you want to start a new model or to delete the existing one.
% Alternatively it is possible to use the |Create| button in the <ug_panel_segm.html Segmentation Panel>.
%% Load model
% Load model from the disk. By default |im_browser| tries to read the models in the Matlab .mat format, but it is also
% possible to specify other formats as well namely:
%%
% 
% * *.AM, Amira Mesh* - as Amira Mesh label field for models saved in <http://www.vsg3d.com/amira/overview Amira> format
% * *.NRRD, Nearly Raw Raster Data* - a data format compatible with <www.slicer.org 3D slicer>.
% * *.TIF, TIF format*
% 
% Alternatively it is possible to use the |Load| button in the <ug_panel_segm.html Segmentation Panel>.
%% Import model from Matlab
% Imports model from the main Matlab workspace. Please provide a variable name from the main Matlab workspace with the model.
% The variable could be either a matrix with dimensions similar to those of
% the loaded dataset |[1:height, 1:width, 1:no-slices]| of the |uint8|
% class or a structure with the following fields:
% 
% * *.model* - the field |model| is a matrix with dimensions similar to those of the loaded dataset |[1:height,
% 1:width, 1:no-slices]| of the |uint8| class
% * *.materials* - [_optional_] the field |materials| a cell array with names of the materials used in the model.
% * *.colors* - [_optional_] a matrix with colors (0-1) for the materials of the model, [1:materialIndex, Red Green Blue]
% * *.labelText* - [_optional_] a cell array containing labels for the annotations
% * *.labelPosition* - [_optional_] a matrix containing positions for the annotations [1:annotationIndex, x y z]
%
%
%% Export model to...
% Exports model from MIB to other programs:
%%
% 
% * *Matlab*, export to the main Matlab workspace, as a structure (see above). The exported models may be later imported back to |im_browser| using the _Import model
% from Matlab_ menu entry. 
% * *Imaris as volume*, export model to Imaris (if it is available, please
% see <im_browser_system_requirements.html#16 System Requirements
% section> for details.
% 
%% Save model
% Saves model to a file in the Matlab format. The file name is not asked, which means that the |im_browser| will use:
%%
% 
% * Default template such as |Labels_NAME_OF_THE_DATASET.mat|
% * the name that was provided from the _Save model as..._ entry
% * the name that was obtained during the _Load model_ action.
% The models can be saved also using the corresponding _Save model_ button in <ug_gui_toolbar.html Toolbar>.
%% Save model as...
% Saves model in a number of formats:
%%
% 
% * *.AM, Amira Mesh* - as Amira Mesh label field in RAW, RAW-ASCII and RLE
% compressed formats. (*Note!* the RLE compression is very slow).
% * *.MAT, Matlab format* - _[default]_, Matlab native data format
% * *.MOD, IMOD format* - contours for IMOD 
% * *.MRC, IMOD format* - volume for IMOD 
% * *.NRRD, Nearly Raw Raster Data* - a data format compatible with <www.slicer.org 3D slicer>.
% * *.STL, STL format* - triangulated mesh for use with visualization
% programs such as Blender.
% * *.TIF, TIF format*
%
%% Render model...
% The segmented models can be rendered directly from MIB using one of the
% following methods:
%
%%
% 
% * *Matlab isosurfaces*, MIB uses Matlab engine to generate isosurfaces
% from the models and visualize those using a modification of the <http://www.mathworks.com/matlabcentral/fileexchange/334-view3d-m view3d> function 
% written by Torsten Vogel. 
% 
%%
% 
% <html>
% <table style="width: 600px; text-align: left; margin-left: 60pt" cellspacing=2px cellpadding=2px >
% <tr style="font-weight: bold; background: #ff6600;">
%   <td colspan=2><b>The following controls are implemented:</b></td>
% </tr>
% <tr>
%   <td>Double click to restore the original view</td>
%   <td></td>
% </tr>
% <tr>
%   <td>Hit 'z' key over the figure to switch from <em>ROTATION</em> to <em>ZOOM</em></td>
%   <td>
%   <ul>In the <em>ZOOM</em> mode
%       <li>press and hold left mouse button to zoom in and out</li>
%       <li>press and hold middle mouse button to move the plot</li>
%   </ul>
% </td>
% </tr>
% <tr>
%   <td>Hit 'r' key over the figure to switch from <em>ZOOM</em> to <em>ROTATION</em></td>
%   <td>
%   <ul style="margin-left: 50pt">In the <em>ROTATION</em> mode
%       <li>press and hold left mouse button to rotate about screen xy axis</li>
%       <li>press and hold middle mouse button to rotate about screen z axis</li>
%   </ul>
% </td>
% </tr>
% <tr>
% <td colspan=2><img src="images\render_in_matlab.jpg"</img>
% </tr>
% </table>
% </html>
% 
% * *Fiji volume...*, uses Fiji 3D viewer for visualization of the model as
% a volume (<http://mib.helsinki.fi/tutorials/VisualizationOverview.html click here for details>. (requires Fiji to be installed,
% <im_browser_system_requirements.html see here>).
%
%%
% 
% <<images\render_in_fiji.jpg>>
% 
%%
% * *Imaris surface*, render the model in Imaris ( <http://mib.helsinki.fi/tutorials_visualization.html see tutorial>); (requires Imaris and ImarisXT to be installed,
% <im_browser_system_requirements.html see here>)
%
%%
% 
% <<images\render_in_imaris_large.jpg>>
% 
% The rendered material is specified in the Material list of the
% <ug_panel_segm.html Segmentation Panel>. 
%
%% Fill membrane
% Experimental function that should transforms lines into planar
% structures to make sure that the line objects on two consecutive frames
% overlap. This function asks for the overlap value in pixels. The function may
% be useful to complement the traced membranes.
%
%% Annotations...
% Use this menu to modify the |Annotations| layer
%%
% 
% * *List of annotations...* - starts an auxiliary window with a list of
% existing annotations, <ug_panel_segm_tools.html see more here> .
% * *Remove all annotations...* - deletes all annotations stored with the
% model.
%
%% Model Statistics...
% Get statistics for the selected material of the model. Statistical results may be used to filter the model based on properties of its objects. 
% The statistics dialog can also be reached from the <ug_panel_segm.html  Segmentation Panel> ->Materials List->Right mouse click->Get statistics...
% See more <ug_gui_menu_mask_statistics.html here>
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_menu.html *Menu*>