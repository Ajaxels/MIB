%% Selection Menu
% Actions that can be applied to the |Selection| layer. The |Selection| is one
% of three main segmentation layers (|Model, Selection, Mask|) which can be
% used in combibation with other layer. See more about segmentation layers
% in <ug_gui_data_layers.html the Data layers of Microscopy Image Browser section>.
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_menu.html *Menu*>
%
%% Selection to Buffer
% Allows to Copy (|Ctrl+C| shortcut) the |Selection| of the currently shown slice to a buffer, which later can be pasted to any other slice with the |Ctrl+V| shortcut.
% In addition there is an option to clear the buffer
% (|Menu->Selection->Selection to Buffer->Clear|); this action clears only
% the buffer and does not affect any of the other layers (|Selection, Mask,
% Model|).
%% ..->Mask
% Allows the modification of the |Mask| layer by the contents of the |Selection| layer. It
% is possible to replace the mask with the selection, add selection to the
% mask, or remove selection from the mask. This action can be applied
% for the currently shown slice or for the whole volume.
%% Morphological 2D/3D operations
%
% <<images/ultimate_erosion.jpg>>
%
% Performs 2D morphological operations on the |Selection| layer. See more in the description of Matlab |bwmorph| function. The following operations are available:
% 
% * *Branch points* - find branch points of skeleton;
% * *Diagonal fill* - (Diag) uses diagonal fill to eliminate 8-connectivity of thebackground;
% * *Endpoints* - finds end points of skeleton;
% * *Skeleton* - (Skel) with n = Inf, removes pixels on the boundaries of objects but does not allow objects to break apart. The 
% remaining pixels make up the image skeleton. This option preserves the Euler number;
% * *Spur* - removes spur pixels, _i.e._ the pixels that have exactly one 8-connected neighbor. For example, spur essentially removes the endpoints of lines.
% * *Thin* - with n = Inf, thins objects to lines. It removes pixels so that an object without holes shrinks to a
% minimally connected stroke, and an object with holes shrinks to a connected ring halfway between each hole and the outer boundary. This option preserves the Euler number;
% * *Ultimate erosion*, performs ultimate erosion, _i.e._ object -> to point
%% Expand to mask borders
% Each selected area will be expanded to match the borders of the mask that
% contains selected area.
%% Interpolate
% Interpolation of the |Selection| layer is a method to reconstruct
% |Selection| on empty slices between two slices containing the |Selection|
% layer. Shortcut for this action is |i|. 
%
% There are two types of interpolators. Select the best suitable interpolator in the <ug_gui_menu_file_preferences.html Preferences dialog> 
% or by pressing the Interpolator type button in the <ug_gui_toolbar.html Toolbar>:
%%
% 
% * *shape* - good for interpolation of the blobs (filled structures).
%
% 
% <<images/interpolation_shape.jpg>>
% 
% * *line* - good for interpolation of the *not closed* lines (such as membranes).
%%
% 
% <<images/interpolation_line.jpg>>
% 
% 
% *_Please note!_* there should be only one object in the |Selection| layer on the starting and ending slices.
%
%% Size exclusion filter
% Filters the selection based on size of the objects within this mask. It is
% possible to filter 2D or 3D objects. The minimal and the maximal sizes of
% the objects are asked in the first two edit boxes of the corresponding
% dialog.
%%
% 
% <<images/menuMaskSizeFilter.jpg>>
% 
%% Replace selected area in the image
% Replaces image intensities in the selected areas with new values. A new
% dialog will ask to provide new intensities, slices, and the color channels.
%% Smooth selection
% Smoothes the |Selection| layer in 2D or 3D space.
%% Invert selection
% Inverts the current selection for the whole dataset.
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_menu.html *Menu*>