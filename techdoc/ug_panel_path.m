%% Path Panel
% This panel is used to provide the path to the image dataset.
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>
%%
%%
% 
% <<images\04_panel_path.jpg>>
% 
%% 1. Logical drive combo box.
% This combo box is used for fast selection of logical drives. It is initialized during the start of 
% |im_browser| and will show only those logical drives that were available during the initialization.
%% 2. '...' button
% This button is one of the ways to select a folder. It uses |uigetdir| Matlab built-in function.
%% 3. Current path edit box
% Current path edit box shows the path of the current folder. The contents of the folder is
% shown in the <ug_panel_dir.html |Directory Contents panel|>. 
%% 4. Pixel Info field
% Pixel info field provides information about pixel location and intensity of pixels under the
% mouse pointer in <ug_panel_im_view.html the Image View panel> . The format is: |X, Y (Red channel:Green channel:Blue
% channel)|. 
% 
% The right mouse click starts a context menu, that can be used for jumping
% to any point of the dataset.
%
%% 5. Log button
% Shows the log of actions that were performed with the currently opened dataset. The
% action log is stored in the |ImageDescription| field in the TIF files. Each entry in the log list has a date/time stamp.
%
% <<images\04a_actions_log.jpg>>
%
% There are number of actions that are possible to do with
% the action log:
% 
% * *Print to Matlab* - prints the action log in the Matlab command window
% * *Copy to Clipboard* - stores the action log in the clipboard, so it can be pasted with Ctrl+V (Windows OS) command.
% * *Insert after* - inserts a new entry after the one which is highlighted
% * *Modify* - modifies the highlighted entry
% * *Delete* - deletes the highlighted entry
% * *Update* - the log is not updated automatically, so press this button to update it manually
% 
%% 6. Info button
% The |Info| button opens a window with a tree list of parameters for the opened dataset. It is possible to modify the parameters
% using the buttons.
%
% The XY image resolution is stored in the |XResolution| and |YResolution|
% fields, and in the BoundingBox info in the |ImageDescription| field.
% 
% <<images\05_image_description.jpg>>
% 
%
%% 7. Zoom Edit box
% Zoom Edit box, allows selection of the desired zoom level.
%
%% 8. Help
% Access to this help page
%
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>


