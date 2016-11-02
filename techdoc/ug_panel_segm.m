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
%% 1. The Segmentation table
% The Segmentation table displays the list of materials of the model. 
%
% 
% <html>
% A brief demonstration is available in the following video:<br>
% <a href="https://youtu.be/_iwQI2DIDjk"><img style="vertical-align:middle;" src="images\youtube2.png"> https://youtu.be/_iwQI2DIDjk</a>
% <br><br>
% The segmentation table has 3 columns:
% <ul>
% <li>Column <b>"C"</b> shows the colors for each material. The mouse click on the first column starts a dialog for color selection</li>
% <li>Colimn <b>"Material"</b> has a list of all materials. The right mouse click starts a popup menu with additional options for the selected material: </li>
% <ul>
% <li><b>Show selected material only</b> a toggle that switches visualization of materials in the Image View panel, when checked only the selected material is shown</li>
% <li><b>Rename</b> rename the selected material</li>
% <li><b>Set color</b> change color for the selected material</li>
% <li><b>Get statistics</b> calculate properties for objects that belong to the selected material. Please refer to the <a href="ug_gui_menu_mask_statistics.html">Menu->Models->Model statistics...</a> section for details</li>
% <li><b>Material to Selection</b> a copies objects of the selected material to the Selection layer with the following options:</li>
% <img src="images\07_panel_segm_materials.jpg">
% <ul>
% <li><em>NEW (CURRENT)</em> generates a new Selection layer from the selected material for the currently shown slice</li>
% <li><em>NEW (CURRENT)</em> adds the selected material to the Selection layer for the currently shown slice</li>
% <li><em>NEW (CURRENT)</em> removes the selected material from the Selection layer for the currently shown slice</li>
% <li><em>NEW (ALL SLICES)</em> generates a new Selection layer from the selected material for the whole dataset</li>
% <li><em>NEW (ALL SLICES)</em> adds the selected material to the Selection layer for the whole dataset</li>
% <li><em>NEW (ALL SLICES)</em> removes the selected material from the Selection layer for the whole dataset</li>
% </ul>
% <li><b>Material to Mask</b> a copies objects of the selected material to the Mask layer with the options similar to the previous entry</li>
% <li><b>Show isosurface (Matlab)...</b> visualize the model or only the selected material (when <em>Show selected material only</em> is selected), as an isosurface. This functionality is powered by 
% Matlab and <a href="http://www.mathworks.com/matlabcentral/fileexchange/334-view3d-m">view3d</a> function written by  Torsten Vogel. Use the <b>"r"</b> shortcut to rotate and <b>"z"</b> to zoom. 
% See more in the <a hewd="ug_gui_menu_models.html">Render model...</a>section</li>
% <li><b>Show as volume (Fiji)...</b> visualization of the model or selected material (when <em>Show selected material only</em> is selected) using volume rendering with Fiji 3D viewer,
% please refer to the <a href="im_browser_system_requirements.html">Microscopy Image Browser System Requirements Fiji</a> for details</li>
% <li><b>Unlink material from Add to</b> when unlinked, the Add to column is not changing its status during selection of Materials</li>
% </ul>
% <li>Column <b>"Add to"</b> defines destination material for the Selection layer during the <em>Add</em> and <em>Replace</em> actions. By default, this field is linked to the selected material, but it is unlinked when the 
% <em>Fix selection to material</em> checkbox is selected or the <em>Unlink material from Add to</em> option is enabled</li>
% </ul>
% </html>
%
% There |Ctrl+A| and |Alt+A| <ug_gui_shortcuts.html shortcuts> can be used. Here is a table with possible results (the |Show Model| and |Show Mask|
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
% <tr style="background: #F0F8FF"><td>Any entry</td><td>ON</td><td>ON</td><td>Mask</td></tr>
% </table>
% </html>
%
% The *Ctrl+A* shortcut selects objects only on the shown slice, while *Alt+A* does that for
% the whole dataset. The selection is sensitive to the |Fix selection to material| (*4.*) 
% and the |Masked area| (*8.*) switches.
%
% <html>
% <div style="background-color: #FFE0B2;">
% <b>Programming tips:</b><br>
% Information about selected materials is stored in the UserData field of
% the segmentation table. It can be obtained using the command:<br>
% <div style="font-family: monospace;">userData = get(handles.segmTable, 'UserData');</div><br>
% The returned userData structure has fields:
% <ul>
% <li><em>prevMaterial</em> - index of selected entry in the Materials column</li>
% <li><em>prevAddTo</em> - index of selected entry in the Add to column</li>
% <li><em>showAll</em> - a toggle (0 or 1) to show all or only selected material</li>
% <li><em>unlink</em> - a toggle (0 or 1) to unlink simultaneous selection of Material and Add to columns</li>
% <li><em>jScroll</em> - a handle to Java UIScrollPane object</li>
% <li><em>jTable</em> - a handle to Java UITablePeer object</li>
% </ul>
% If any of these parameters changed the UserData field of the table should
% be updated:<br>
% <div style="font-family: monospace;">set(handles.segmTable, 'UserData', userData);</div><br>
% </div>
% </html>
%
%% 2. The + and - buttons
%
% 
% * the "*+*" button, press to add a new material to the model
% * the "*-*" button, press to delete the selected material from the model
%
%
%% 3. The "D" checkbox, to select fast access tools 
% This checkbox marks the favorite selection tools that are selected using the 'D' key shortcut. The chosen fast access tools are highlighted
% with orange background in the |Selection type| popup menu. Any tool can
% be selected as a favorite one.
%
%
%% 4. The Fix selection to material check box
% This check box ensures that all segmentation tools (*5.*) will be performed only
% for material selected in the table.
%
%% 5. Segmentation tools panel
% This panel hosts different tools for the segmentation.
% <ug_panel_segm_tools.html See more here>.
%
%% 6. The Create button
% Starts a new model. The existing |Model| layer will be removed.
%
%% 7. The Load button
% Loads model from the disk. The following formats are accepted:
%%
% 
% * Matlab (*.MAT), _default recommended format_
% * Amira Mesh binary (*.AM); for models saved in <http://www.vsg3d.com/amira/overview Amira> format
% * Hierarchial Data Format (*.H5); for data exchange with <http://ilastik.org/ Ilastik>
% * Medical Research Concil format (*.MRC);  for data exchange with <http://bio3d.colorado.edu/imod/ IMOD>
% * NRRD format (*.NRRD); for models saved in <http://www.slicer.org/ 3D slicer> format
% * TIF format (*.TIF); 
% * Hierarchial Data Format with XML header (*.XML); 
% * all standard file formats can be opened when selecting "All files(*.*)"
% 
% Alternatively it is possible to use the <ug_gui_menu_models.html |Menu->Models->Load model|> .
%
%% 8. The Masked area checkbox
% This check box ensures that all segmentation tools (*5.*) will be limited only
% within the masked areas of the image.
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>