%% Edge Enhancing Coherence Filter in the Image Filters Panel
% Perform Anisotropic Non-Linear Diffusion filtering on a 2D gray/color or
% 3D image stack. Anisotropic Non-Linear Diffusion filtering should reduce the noise while 
% preserving the region edges, and also enhancing the edges by smoothing along them.
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| 
% <ug_gui_panels.html *Panels*> |*-->*| <ug_panel_image_filters.html *Image Filters*>
%% 
% 
% <<images\18_panel_AnDiff_filter.jpg>>
% 
%% Coherence Filter Toolbox description
%
% *Image Edge Enhancing Coherence Filter* based on the <http://www.mathworks.com/matlabcentral/fileexchange/25449-image-edge-enhancing-coherence-filter-toolbox
% Image Edge Enhancing Coherence Filter Toolbox> written by Dirk-Jan Kroon and Pascal Getreuer.
% This is one of the most advanced image enhancement methods available, 
% and also contains HDCS (Hybrid Diffusion With Continuous Switch), from October 2009. 
% The result looks like an artist painted the image, with clear brush strokes 
% along the image edges and ridges.
% 
% The basis of the method used is the one introduced by Weickert. 
% 
% # Calculate Hessian from every pixel of the Gaussian smoothed input image 
% # Gaussian Smooth the Hessian, and calculate its eigenvectors and values (image edges give large eigenvalues, and the eigenvectors corresponding to those eigenvalues describes the direction of the edge) 
% # The eigenvectors are used as diffusion tensor directions. The amplitude of the diffusion in those 3 directions is based on the eigen values and determined by Weickerts equation
% # A Finite Difference scheme is used to do the diffusion 
% # Back to step 1, till certain diffusion time is reached
%
% *Diffusion schemes:* 
%
% There are several diffusion schemes available: standard, implicit, 
% nonegative discretization, and also a rotation invariant scheme, and a 
% novel diffusion scheme with new optimized derivatives.
%
%% Coherence Filter Parameters
% 
% *Schemes*, available numerical diffusion schemes:
% 
% * *'R'*, Rotation Invariant, Standard Discretization (implicit) 5x5 kernel;
% * *'O'*, Optimized Derivative Kernels;
% * *'I'*, Implicit Discretization (only works in 2D);
% * *'S'*, Standard Discretization;
% * *'N'*, Non-negativity Discretization.
% 
% *Eigenmode*, different equations to make a diffusion tensor:
%
% * *'0'*, Weickerts equation, *line* like kernel (similar to 3);
% * *'1'*, Weickerts equation, *plane* like kernel;
% * *'2'*, Edge enhancing diffusion (EED) (similar to 4);
% * *'3'*, Coherence-enhancing diffusion (CED) (similar to 0);
% * *'4'*, Hybrid Diffusion With Continuous Switch (HDCS) (similar to 2).
% 
% *Other parameters*
% 
% * *'T'*, The total diffusion time;
% * *'dt'*, Diffusion time stepsize, in case of scheme H,R or I defaults to 1, 
% in case of scheme S or N defaults to 0.15.;
% * *'sigma'*, Sigma of gaussian smothing before calculation of the image Hessian;
% * *'rho'*,Rho gives the sigma of the Gaussian smoothing of the Hessian;
% * *'C'*,  amplitude of the diffusion smoothing in Weickert equation (Default 1e-10);
% * *'m'*,  amplitude of the diffusion smoothing in Weickert equation (1);
% * *'alpha'*,  amplitude of the diffusion smoothing in Weickert equation (0.001);
% * *'lambda_e'*,  Default 0.02, planar structure contrast (CED, EED, HDCS modes);
% * *'lambda_c'*,  Default 0.02, tube like structure contrast (CED, EED, HDCS modes);
% * *'lambda_h'*,  Default 0.5 , threshold between structure and noise (CED, EED, HDCS modes);
%
% *Effective combinations*
%
% * Scheme=N, eigenmode=2/4 or 1, T=5, dt=0.15, Sigma=5, rho=1
% * Scheme=O, eigenmode=1, T=5, dt=1, Sigma=5, rho=1
% * Scheme=R, eigenmode=2/4, T=5, dt=1, Sigma=5, rho=1
% * Scheme=S, eigenmode=2 or 4, T=5, dt=0.15, Sigma=5, rho=1
%
%% Coherence Filter Usage
% Anisotropic Diffusion is fairly slow process and search of best
% parameters may be hard. In order to speed up the process there is a
% possibility to perform a |Test run| to define the best parameters.
% 
% *Test run*
%
% * Zoom in into the area of interest with a mouse wheel. 
% * Press the *Test run* button.
% * Check the region that will be used for the test filtering.
% 
% <<images\18_panel_AnDiff_size.jpg>>
% 
% * Define the variation of Parameters (|T, dt, sigma, rho, C, m, alpha, 
% lambda_e, lambda_c, lambda_h|) using standard Matlab notation
% (start:step:end). By default the script will save middle slice of the
% selected dataset to a file, however this may be changed in the |Save
% frame numbers| editbox. The filter parameters for each image are fused into 
% the saved image and will also be added into the |ImageDescription| field.
%%
% 
% <<images\18_panel_AnDiff_Options.jpg>>
% 
% * Press the *Test Run* button.
% * Define desired *Scheme* and *Eigenmode* values.
%%
% 
% <<images\18_panel_AnDiff_Schemes.jpg>>
% 
% * Give a template for saving
% * Stay patient...
% 
%% Coherence Filter References
% 
% * Kroon and Slump, "Coherence Filtering to Enhance the Mandibular Canal in Cone-Beam CT Data", _IEEE-EMBS Benelux Chapter Symposium_, *2009*. 
% * Kroon _et al_, "Optimized Anisotropic Rotational Invariant Diffusion Scheme on Cone-Beam CT", _MICCAI_, *2010*
% * Weickert, "A Scheme for Coherence-Enhancing Diffusion Filtering with Optimized Rotation Invariance" 
% * Mendrik _et al_, "Noise Reduction in Computed Tomography Scans Using 3-D Anisotropic Hybrid Diffusion With Continuous Switch", October 2009 
% * Weickert, "Anisotropic Diffusion in Image Processing", Thesis 1996 
% * Laura Fritz, "Diffusion-Based Applications for Interactive Medical Image Segmentation" 
% * Siham Tabik et al, "Multiprocessing of Anisotropic Nonlinear Diffusion for filtering 3D image"
%
%% Parallel processing
% There is a small optimization for parallel processing for final runs in 2D mode. 
% The improvement factor is about x3-5 times for 8 cores. 
% Parallel processing should be enabled by pressing the |Turn on parallel processing| button
% in the im_browser <ug_gui_toolbar.html toolbar> .
%
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> |*-->*| 
% <ug_gui_panels.html *Panels*> |*-->*| <ug_panel_image_filters.html *Image Filters*>