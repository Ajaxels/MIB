%% The View Settings Panel
% The View Settings panel gives basic tools for visualization of the
% dataset.
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>
%%
% 
% <<images\09_panel_view_settings.jpg>>
% 
%% 1. The Colors table and the LUT checkbox
% This table contains a list of color channels of the dataset.
% The color channels may be switched on and off (a combination of |Ctrl+left mouse click| above checkboxes turns on selection of a single color channel). 
% The image is generated depending on selection state of the |LUT checkbox|. When the |LUT checkbox| is selected |im_browser|
% generates the final image based on defined colors (the third column in this table).
% *Note!* When the |LUT checkbox| is unchecked the maximal number of colors that can be shown simultaneously is limited to 3. If more than 3
% colors are selected then only the first 3 color channels are shown. 
%
% The right mouse button gives access to additional color channel actions:
% 
% * *Insert empty channel...*, insert an empty channel (intensity of all pixels is 0) to the specified position
% * *Copy channel*, to copy the selected color channel to a new channel (available also from <ug_gui_menu_image.html Menu-Image-Color Channels>)
% * *Invert channel*, to invert the selected color channel (available also from <ug_gui_menu_image.html Menu-Image-Color Channels>)
% * *Rotate channel*, rotate the specified color channel (available also from <ug_gui_menu_image.html Menu-Image-Color Channels>)
% * *Swap channels*, to swap the selected color channel with another one (available also from <ug_gui_menu_image.html Menu-Image-Color Channels>)
% * *Delete channel*, to delete the selected color channel (available also from <ug_gui_menu_image.html Menu-Image-Color Channels>)
% * *Set LUT color*, to set colors for use with the |LUT checkbox| (available also from <ug_gui_menu_file_preferences.html Menu-File-Preferences>)
% 
%% 2. The Show Model check box
% Switch on/off the |Model| layer. This check box has a shortcut *'spacebar'*. 
%% 3. The Show Mask check box
% Switch on/off |Mask| layer. This check box has a shortcut *'Ctrl + spacebar'*. 
%% 4. The Hide image check box
% Switch on/off display of the |Image| layer.
%
%% 5. The Annotations check box
% Switch on/off Annotation layer.
%
%% 6. Display
% Press to start display adjustments GUI tool, <ug_panel_adjustments.html *see more here*>. 
%
% <<images\12_panel_adj_disp.jpg>>
%
%% 7. The Brightness/Contrast panel
%
% *The Auto button*
% Auto brightness adjustment of complete dataset. The function asks
% for saturation parameters for both low and high intensity borders. As
% a result, the image intensities are _*recalculated*_ to increase the contrast.
% *Note*, the function behaviour is affected by the |stack|
% switch. When the |stack| switch is |off| the brightness
% is individually adjusted for each frame of the dataset. Alternatively, when checked,
% the function first finds minimal and maximal stretching parameters for
% the whole dataset and then uses these values to adjust the contrast.
%
% *The Contrast button*
% Allows changing of the contrast of the image. Possible combinations:
% 
% * *Left mouse click*, contrast adjustment with desired parameters for the
% current frame or for the whole dataset. *Note!* It is better to use
% |Display| (*6.*) button for contrast adjustment.
% * *Right mouse click + Show histogram*, shows histogram of the current image
% in a separate window to find best parameters for contrast stretch. 
% * *Right mouse click + Contrast-limited adaptive histogram equalization*, starts Contrast-limited adaptive histogram
% equalization (CLAHE) for the choosen part of the dataset. See help for
% |adapthisteq| Matlab function for details. This option is also available from the <ug_gui_menu_image.html
% |Menu->Image->Contrast|>.
%
%
% *The on fly checkbox*
% automatically adjust contrast for each shown image without recalculation
% of intensities of the actual data.
%
%% 8. The Transparency sliders
% * *The top trasparency slider* regulates transparency of the |Model| layer 
% from opaque (slider in the left position) to transparent (slider in the right position). 
% For the difference maps (result of the
% <ug_panel_corr.html correlation analysis>) this slider changes the
% gain of the difference map. 
% * *The middle transparency slider* changes transparency values for
% the |Mask| layers from opaque to transparent.
% * *The lower trasparency slider* change transparency values for
% the |Selection| layer from opaque to transparent.
%
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>
