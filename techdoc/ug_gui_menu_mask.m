%% Mask Menu
% Actions that can be applied to the |Mask| layer. The |Mask layer| is one
% of three main segmentation layers (|Model, Selection, Mask|) which can be
% used in combibation with other layer. See more about segmentation layers
% in <ug_gui_data_layers.html the Data layers of Microscopy Image Browser section>.
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_menu.html *Menu*>
%
%% ..->Selection
% Allows modification of the |Selection| layer by the |Mask| layer. It
% is possible to replace the selection with the mask, add mask to the
% selection, or remove mask from the selection. These actions can be applied
% for the currently shown slice or for the whole volume.
%% Clear mask
% Clears the mask, i.e. deletes the |Mask| layer from the memory.
%% Load mask
% Load mask from disk. The mask is saved in the Matlab format with the |*.mask|
% extension.
%% Import Mask from Matlab
% Imports mask from the main Matlab workspace. The mask should be a matrix with dimensions similar to those of the loaded dataset |[1:height, 1:width, 1:no-slices]| of the |uint8| class.
%% Export Mask to Matlab
% Exports mask to the main Matlab workspace, the exported mask may be imported back to |im_browser| using _Import Mask from
% Matlab_ command.
%% Save mask as...
% Saves mask to disk. The mask is saved in the Matlab format with |*.mask|
% extension.
%% Invert mask
% Inverts mask so that the masked areas become background and the background
% becomes a mask.
%% Size exclusion filter
% Filters the mask based on size of the objects within this mask. It is
% possible to filter 2D or 3D objects. The minimal and the maximal sizes of
% the objects are asked in the first two edit boxes of the corresponding
% dialog. *Note!* It might be handier to use the
% <ug_gui_menu_mask_statistics.html Mask Statistics...> option. 
%%
% 
% <<images/menuMaskSizeFilter.jpg>>
% 
%% Replace masked area in the image.
% Replaces image intensity in the masked areas with new values. A new dialog
% would ask to provide new intensities, slices, and the color channels.
%
% <html>
% A brief demonstration is available in the following video:<br>
% <a href="https://youtu.be/fNz1vGq7Hb0"><img style="vertical-align:middle;" src="images\youtube2.png">  https://youtu.be/fNz1vGq7Hb0</a>
% </html>
%%
% 
% <<images/menuMaskReplaceColor.jpg>>
% 
%% Smooth mask
% Smoothes the |Mask| layer in 2D or 3D space.
%% Mask Statistics
% Get statistics for the mask layer. See more <ug_gui_menu_mask_statistics.html here>
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_menu.html *Menu*>