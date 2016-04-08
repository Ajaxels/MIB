%% Mask Generators panel
% This panel hosts several ways of automatic mask generation. Specific areas of interest from the generated mask may 
% further be selected for segmentation. <ug_gui_data_layers.html See more about masks>.
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>
%% Common fields
% There are several common fields that do not depend on type of the selected mask
% generator.
%
% <<images\13_panel_mask_gen_common.jpg>>
% 
% * 1. The *Filter type* combo box, allows to select one of the possible mask
% generators
% * 2. The *Mode* radio buttons:
%
%
% <html>
% <ul style="position:relative; left:35px;">
% <li><b>current</b>, generate mask for the currently shown slice;</li>
% <li><b>2D all</b>, generate mask for the whole dataset using the 2D mode,
% <em>i.e.</em> slice by slice;</li>
% <li><b>3D</b>, generate mask for the whole dataset using the 3D mode;</li>
% </ul>
% </html>
%
% the whole dataset in the 2D mode, _i.e._ slice by slice; _3D_ use the 3D mode for the mask generation
%
% 3. *Do it* button:
%
%
% <html>
% <ul style="position:relative; left:35px;">
% <li> 
% -<b>left mouse click</b>, starts the selected generator. The existing mask will be deleted.
% </li>
% <li> 
% -<b>right mouse click + Do new mask</b>, starts the selected generator.
% The existing mask will be deleted.
% </li>
% <li> 
% -<b>right mouse click + Generate new mask and add it to the existing mask</b>, the generated mask will be added to the existing mask.
% This option may be
% used for multi-dimensional filtering: 1. run Generator for XY; 2. Change
% dimension by pressing |'XZ'| or |'YZ'| button in the Toolbar; 3. Run Generator again with the |Generate new mask and add it to the existing mask| option.
% </li>
% </ul>
% </html>
%
%
%% Frangi Filter
% <http://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter
% Hessian based Frangi Vesselness filter>, written by Marc Schrijver and Dirk-Jan Kroon. This 
% function uses the eigenvectors of the Hessian to compute the likeliness 
% of an image region to contain vessels or other image ridges, 
% according to the method described by Frangi <http://www.dtic.upf.edu/~afrangi/articles/miccai1998.pdf 1998>, <http://www.tecn.upf.es/~afrangi/articles/tmi2001.pdf 2001>.
%
% *Note*, to work properly this function should be compiled. See details in
% <im_browser_system_requirements.html System Requirements>
% 
% <<images\13_panel_frangi.jpg>>
%
% *Parameters:*
%
% * *Range*, the range of sigmas used, default [1-6]
% * *Ratio*, step size between sigmas, default [2]
% * *beta1*, the Frangi correction constant, default [0.9]
% * *beta2*, the Frangi correction constant, default [15]
% * *beta3*, the Frangi vesselness constant which gives the threshold between eigenvalues of noise and vessel structure. A thumb rule is dividing the the greyvalues of the vessels by 4 till 6, default [500];
% * *B/W threshold*, defines thresholding parameter for generation of the
% |Mask| layer. When set to 0 results in the filtered instead of binary
% image.
% * *Object size limit*, after the run of the Frangi filter removes all
% 2D objects that are smaller than this value.
% * *Black on white* checkbox, if checked, detects black ridges on white background.
%
%% Morphological filters
% Set of Matlab based morphological filters.
% 
% <<images\13_panel_morph.jpg>>
%
% * *Extended-maxima transform* - based on |imextendedmax| function of
% Matlab. Computes the extended-maxima transform, which is the regional maxima of the H-maxima transform. 
% Regional maxima are connected components of pixels with a constant intensity value, and whose external boundary pixels all have a lower value.
%%
% 
% <<images\13_panel_morph_extMaxTrans.jpg>>
% 
%
% * *Extended-minima transform* - based on |imextendedmin| function of
% Matlab. Computes the extended-minima transform, which is the regional minima of the H-minima transform. Regional minima are connected components of pixels with a constant intensity value, and whose external boundary pixels all have a higher value.
%%
% 
% <<images\13_panel_morph_extMinTrans.jpg>>
% 
% * *Regional maxima* - based on |imregionalmax| function of Matlab. Returns the binary mask that identifies the locations of the regional 
% maxima in the image. In mask, pixels that are set to 1 identify regional
% maxima; all other pixels are set to 0. Regional maxima are connected components of pixels with a constant intensity value, and whose external boundary pixels all have a lower value.
%
% * *Regional minima* - based on |imregionalmin| function of Matlab. The output binary mask has value 1 corresponding to the pixels of the image
% that belong to regional minima and 0 otherwise. Regional minima are connected components of pixels with a constant intensity value, and whose external boundary pixels all have a higher value. 
%
%
%% Strel Filter
% Generate mask based on morphological image opening and black-and-white
% thresholding. The function first performs morphological bottom-hat (|Black on white| is checked, *5.*)
% or top-hat (|Black on white| is unchecked, *5.*) filtering of the image. 
% The top-hat filtering computes the morphological opening of the image (using |imopen|)
% and then subtracts the result from the original image. The result is then
% black and white thresholded with parameter in the |B/W threshold| edit
% box (*3.*).
%
% <<images\14_panel_maskGen_strel.jpg>>
%
% # *Strel size*, defines size of the structural element (|disk| type) for |imtophat| and |imbothat|
% filtering. 
% # *Fill* checkbox, check it to fill holes in the resulted |Mask| image.
% # *B/W threshold*, specifies parameter for the black and white thresholding.
% # *Size limit*, limits the size of generated 2D objects so that objects smaller than this value are removed from the |Mask| during the
% filter run.
% # *Black on white* checkbox, when checked, the filter will use morphological bottom-hat filtering
% (|imbothat|). When unchecked - morphological top-hat filtering (|imtophat|).
%
%% BW Threshold Black Filter
% Different approaches for black-and-white thresholding. The data should
% be as bright object on dark background. The thresholding
% is applied to <ug_panel_roi.html ROI regions> or to the whole image. The
% resulting mask may be further filtered with tools in the
% <ug_gui_menu_mask.html |Mask| menu>.
% 
% <<images\14_panel_maskgenerators_bw.jpg>>
% 
% # *For bright object extraction*, use the *1.* editbox to specify a threshold value. 
% The objects that are brighter than the specified value will be used to 
% generate the |Mask| layer. The |auto| checkbox *3.* should be unchecked!
% # *For dark object extraction*, use the *2.* editbox to specify a threshold value. 
% The objects that are dimmer than the specified value will be used to 
% generate the |Mask| layer. The |auto| checkbox *3.* should be unchecked!
% # *Auto* checkbox, enables automatic image thresholding using Otsu's
% method. *Note!* The auto mode is affected by the values in
% the *1.* and *2.* editboxes. If the threshold coefficient is smaller than the
% parameter in the *1.* editbox, the specified *1.* parameters will be used
% instead of automatic coefficient.
% # *Auto grid* checkbox, another approach to the automatic thresholding. In this method the image/ROI region is
% divided into a separate blocks. The program calculates threshold values for 
% each block and use these values to prepare the image for final
% thresholding. This method works for cases when the image intensity is
% constant in each block in Z-direction.
% The grid will be displayed after the run as the |Selection| layer and can be removed with *Ctrl+C* / *C* shortcut.
% 
%
% <html>
% <ul style="position:relative; left:35px;"><b>Procedure description:</b>
% <li>1. Select the |Auto grid| checkbox (*4.*) to enable grid mode.</li>
% <li>2. Enter size of a single grid box.</li>
% <li>3. Specify grid threshold coefficient (*5.*). Leave |0| for the automatic mode
% during the first run.</li>
% <li>4. Press the *Do it* button to begin the thresholding procedure.</li>
% <li>5. For each block the proper automatic threshold value is estimated with
% Otsu's method (this threshold may be altered with values in the <b>1.</b> and
% <b>2.</b> editboxes).</li>
% <li>6. Find minimal threshold value for the set of blocks or use provided in
% the <b>5.</b> editbox coefficient. This value will be used for final image
% thresholding (<em>threshold<sub>final</sub></em>).</li>
% <li>7. The original image in each box is magnified with the values that
% are defined as<br>
% <em>I<sub>block</sub> = I<sub>block</sub> x (1 -
% threshold<sub>block</sub> - threshold<sub>final</sub>)</em></li>
% <li> Finally the magnified image is thresholded with the
% <em>threshold<sub>final</sub></em> coefficient. </li>
% </ul>
% <br>
% It is recommended to run grid mode with 0 coefficient in <b>5.</b>. The image will be
% somehow thresholded and the used coefficient will be shown in the Matlab
% command window. If result is not good enough, a new coefficient that is
% differ from the automatically determined value should be placed into the <b>5.</b>
% editbox.
% </html>
%
% 6. *Manual grid* checkbox, in this mode the coeficients for each box may
% be manually tuned.
% 
% <html>
% <ul style="position:relative; left:35px;">
% <b>Procedure description:</b>
% <li>1. Run first Auto grid mode. After the run 'thrMatrix' variable with coefficients for each block will be created in the main Matlab workspace</li>
% <li>2. Select the Manual grid checkbox. Enter the grid size and press the Do it button.</li>
% <li>3. A new window for manual black and white thresholding will appear. Press the Import button and import thrMatrix variable.</li>
% <li>4. Press the Start button to theshold the image.</li>
% <li>5. Adjust the threshold coefficients in the blocks.</li>
% <li>6. When result seems to be fine select the All check box and press the Start button to make the final thresholding for the whole stack.</li>
% </ul>
% <br>
% The coefficients may be saved and loaded for future use.
% </html>
%
%% Parallel processing
% Code is optimized for Parallel processing. The grid run mode gives x5-6
% times better performance with 8 cores. Parallel processing should be enabled by pressing the |Turn on parallel processing| button
% in the im_browser <ug_gui_toolbar.html#37 toolbar>.
%
%
% 
% <<images\toolbar_parallel.jpg>>
% 
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>
