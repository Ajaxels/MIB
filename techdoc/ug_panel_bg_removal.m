%% Background Removal Panel
% The background removal panel is one of the left interchangeable panels, it provides three different algorithms for background removal. The image has to be as white
% objects on dark background (use |Invert image| command in the
% <ug_gui_menu_image.html Image menu>). These tools were designed to work with 2D time lapse movies obtained with light
% microscopy.
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>
%%
%
% <<images\16_panel_bg_remove_morph.jpg>>
%% General notes on usage
%
% * Start filtering by pressing the |Remove| button.
% * Check the |Test| checkbox (*9.*) for the test run and press the |Remove| button. 
% * Select the |All| checkbox (*8.*) to subtract background from all images
% in the dataset.
%% Morphological opening and background removal
% Select the |Morph opening| checkbox (*1.*) to select this method.
%
% Original image:
% 
% <<images\Background_orig.jpg>>
% 
% *How it works:*
%
% *1.* Generate *background image* by opening the image with |imopen| function 
% and strel size defined in the |Strel size| editbox (*4.*). 
% This would remove all objects smaller than the strel size from the
% background image. Use high values in the |Strel size| editbox.
% 
% Background to be subtracted
% 
% <<images\Background_morph.jpg>>
%
% *2.* If the |Smoothing| checkbox is |ON| (*3.*), the program filters the *background image* with
% gaussian filter with |Size| and |Sigma| parameters (*6.*).
%
% Smoothed background
%
% <<images\Background_morph_smooth.jpg>>
%
% *3.* Subtract the *background image* from the current image.
%
% Result of background subtraction
%
% <<images\Background_morph_result.jpg>>
%
% *4.* Show profiles for the specified line, if *7.* is checked.
%
%% Background approximation based on local minima 
% This method uses |extrema| and |extrema2| functions written by 
% <http://www.mathworks.com/matlabcentral/fileexchange/12275-extrema-m-extrema2-m Carlos Adrian Vargas Aguilera> 
% from Universidad de Guadalajara, Mexico. The method finds local minima
% and then generates background image using the amplitudes at the local
% minima. Select the |Minima| checkbox (*2.*) to select this method.
%
% <<images\16_panel_bg_remove_minima.jpg>>
%
% *How it works:*
% 
% *1.* Prefilter the image with Circular averaging filter (|fspecial|
% function with |disk| type, using size from the |Strel size| editbox
% (*4.*). Increase of the strel size parameter will reduce number of local
% minima.
%
% Prefiltered image
%
% <<images\Background_minima_prefiltered.jpg>>
% 
% *2.* Find local minima with |extrema2| function.
%
% *3.* Remove all local minima that are higher than the |Max minima|
% parameter (*5.*).
%
% *4.* Reconstruct the background image
%
% <<images\Background_minima_reconst.jpg>>
%
% *5.* Smoothen the backgound image if the |Smoothing| checkbox is selected
%
% <<images\Background_minima_reconst_sm.jpg>>
%
% *6.* Generate averaged background image for the whole stack.
%
% *7.* Substract averaged background from each image in the stack. The
% local minina that were used for reconstruction are marked with crosses.
%
% <<images\Background_minima_result.jpg>>
%
%% Estimation of background as a gaussian blured image
% When both |Morph opening| (*1.*) and |Minima| (*2.*) checkboxes are unchecked
% |im_browser| estimates background as a gaussian blured image. This is the
% easiest method from the computational point of view but may give rise of artifacts
% when the strel size is too small.
%
% *How it works:*
%
% *1.* Generate *background image* by filtering of the image with a large |Size|
% parameter of the gaussian filter (*6.*).
%
% Background to be subtracted, obtained with Size=120, Sigma=40.
%
% <<images\Background_gauss.jpg>>
%
% *2.* Subtract the *background image* from the current image.
%
% Result of background subtraction
%
% <<images\Background_gauss_result.jpg>>
%
% *3.* Show profiles for the specified line, if *7.* is checked.
%
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| <ug_gui_panels.html *Panels*>