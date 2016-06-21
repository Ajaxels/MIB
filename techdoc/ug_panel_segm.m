%% Segmentation Panel
% The segmentation panel is the main panel used for segmentation. It allows creating models, modifying materials and selecting different segmentation tools. 
%
% <<images\07_panel_segm.jpg>>
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>
%% What are the Models
% |Model| is a matrix with dimensions equal to those of the opened |Image| dataset: _i.e._  [ |1:imageHeight,
% 1:imageWidth, 1:imageThickness| ]. The |Model| consists of Materials, each element of the |Model| matrix can belong only to
% a single material or to an exterior. So it is not possible to have several materials above the same pixel of the |Image| overlapping each other.
% Each material in the |Model| matrix is encrypted with own index:
Model = [1 1 0 0; 1 1 0 0; 0 0 2 2; 0 0 2 2];
Model
%%
% In this example, the shown matrix represents a Model with 2 materials
% encrypted with *1* (the upper left corner) and *2* (the lower right corner) for the |Image| of 4x4 pixels.
%% 1. The Materials list box
% The Materials list box shows the names of all materials of the model.
% When the |Show all| checkbox is selected all existing materials would be 
% displayed in <ug_panel_im_view.html the Image View panel> simultaneously. However, when this
% checkbox is unchecked the only highlighted material would be shown.
% Additional context menu is available after selection of material and 
% pressing the right mouse button:
% 
% <<images\07_panel_segm_materials.jpg>>
% 
%
% * *Rename...*, renames the highlighted material
% * *Set color...*, allows setting of a color for the highlighted material. *_Note!_* it is also possible to change the colors
% using the <ug_gui_menu_file_preferences.html Menu->File->Preferences dialig>
% * *Smooth...*, smoothes the selected material of the model with the Gaussian 2D or 3D
% filter
% * *Get statistics...*, - starts the Statistics dialog to calculate quantification of objects in the selected
% material of the model
% Please refer to the <ug_gui_menu_mask_statistics.html Menu->Models->Model statistics...> section for details 
% * *Show isosurface (Matlab)...*, visualize the highlighted material, as an isosurface. This functionality is powered by 
% Matlab and <http://www.mathworks.com/matlabcentral/fileexchange/334-view3d-m view3d> function written by  Torsten Vogel. Use the '*r*' shortcut to rotate and '*z*'
% to zoom. See more in the _Render model..._ section <ug_gui_menu_models.html here>.
% * *Show as volume (Fiji)...*, visualization using volume rendering of the selected material of the model with Fiji 3D viewer,
% please refer to the <im_browser_system_requirements.html Microscopy Image Browser System Requirements Fiji> for details
% * *Sync all lists* - sets selection in the |Material|, |Select from| and |Add to| lists to the same value
%% 2. The Select from list box
% Specifies material for selection. In general use it does not matter which material is selected in this list. However when 
% the |Fix selection to material| (*7.*) is checked all selection actions are limited to selected material. It is possible to
% switch between Exterior (|Ext|) and any other material with the *E* shortcut <ug_gui_shortcuts.html shortcut>.
%
% Selection of material in the |Select from| list and pressing the right mouse button calls a context menu with additional
% possibilities:
%
% 
% <<images\07_panel_segm_selectfrom.jpg>>
% 
% 
% * *Set this material as Mask*, generates a |Mask| layer from the selected material. *_Note!_* The existing |Mask| will be
% erased without confirmation (Press Ctrl+Z for Undo)
% * *NEW Selection (CURRENT)*, generates a new |Selection| layer from the selected material for the *currently* shown slice
% * *ADD to Selection (CURRENT)*, adds the selected material to the |Selection| layer for the *currently* shown slice
% * *Remove Material from Selection (CURRENT)*, removes the selected material from the |Selection| layer for the *currently* shown slice
% * *NEW Selection (ALL)*, generates a new |Selection| layer from the selected material for the *whole* dataset
% * *ADD to Selection (ALL)*, adds the selected material to the |Selection| layer for the *whole* dataset
% * *Remove Material from Selection (ALL)*, removes the selected material from the |Selection| layer for the *whole* dataset
% * *Sync all lists* - sets selection in the |Material|, |Select from| and |Add to| lists to the same value
% 
%
% There are |Ctrl+A| and |Alt+A| <ug_gui_shortcuts.html shortcuts> that can be used. Here is a table with possible results (the |Show Model| and |Show Mask|
% checkboxes are located in <ug_panel_view_settings.html the |View Settings| panel>):
%%
%
% <html>
% <table style="width: 550px; text-align: left;" cellspacing=2px cellpadding=2px >
% <tr style="font-weight: bold;">
% <td>Select from</td><td>Show Model checkbox</td><td>Show Mask checkbox</td><td>Result of selection</td>
% </tr>
% <tr style="background: #F0F8FF;"><td>All</td><td>OFF or ON</td><td>OFF</td><td>Nothing</td></tr>
% <tr style="background: #F0F8FF;"><td>Ext or any material</td><td>OFF or ON</td><td>OFF</td><td>Background or selected material</td></tr>
% <tr style="background: #F0F8FF;"><td>Any entry</td><td>OFF</td><td>ON</td><td>Mask</td></tr>
% <tr style="background: #FFEBCD"><td>Any entry</td><td>ON</td><td>ON</td><td>Mask</td></tr>
% </table>
% </html>
%
% The *Ctrl+A* shortcut will select objects only on the shown slice, while *Alt+A* will do that for
% the whole dataset. The selection is sensitive to the |Fix selection to material| (*7.*) 
% and the |Masked area| (*11.*) switches.
%% 3. The Add to list box
% Specifies to which material the selection should be assigned.
%
% For example, material *1* can be selected on all slices (|Segmentation Panel->Select from->1, press the Alt+A shortcut|) and then
% copied to the second material *2* (|Segmentation Panel->Add to->2,
% Shift+A|). The Shift+A shortcut moves selected areas from the |Selection|
% layer to the |Model| layer, Material 2 for all slices of the dataset. Please refer to the <ug_panel_selection.html |Selection|> panel reference for more information.
%
% Selection of matirial in the |Add to| list and pressing the right mouse button calls a context menu with additional
% possibilities:
%
% 
% <<images\07_panel_segm_addto.jpg>>
%
%
% * *Mask statistics* - starts the Statistics dialog to calculate quantification of objects in the Mask layer
% * *Sync all lists* - sets selection in the |Material|, |Select from| and
% |Add to| lists to the same entry
%
%% 4. The + button
% Press to add a new material to the model.
%
%% 5. The - button
% Press to delete selected in the |Select from| list box (*2.*) material from the model.
%
%% 6. The "D" checkbox, to select fast access tools 
% Allows to defining of the favorite selection tools that are called using the
% 'D' key shortcut. The chosen fast access tools are highlighted
% with orange background in the |Selection type| popup menu.
%% 7. The Fix selection to material check box
% This check box ensures that all segmentation tools (*8.*) will be performed only
% for material selected in the |Select from| list (*2.*).
%% 8. Segmentation tools panel
% This panel hosts different tools for the segmentation.
% <ug_panel_segm_tools.html See more here>.
%
%% 9. The Create button
% Starts a new model. The existing |Model| layer will be removed.
%
%% 10. The Load button
% Loads model from the disk. The following formats are accepted:
%%
% 
% * Matlab (*.MAT), _default recommended format_
% * Amira Mesh binary (*.AM); for models saved in <http://www.vsg3d.com/amira/overview Amira> format
% * NRRD format (*.NRRD); for models saved in <http://www.slicer.org/ 3D slicer> format
% * TIF format (*.TIF); 
% 
% Alternatively it is possible to use the <ug_gui_menu_models.html |Menu->Models->Load model|> .
%% 11. The Masked area checkbox
% This check box ensures that all segmentation tools (*8.*) will be limited only
% within the masked areas of the image.
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>