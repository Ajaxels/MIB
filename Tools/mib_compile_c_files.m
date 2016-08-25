% This script will compile all the C files
%% Compiling coherence filter
wb = waitbar(0, sprintf('Compiling Coherence Filter\nPlease wait...'), 'Name', 'Compiling c files');

% get MIB directory
mibDir = fileparts(which('im_browser'));

currDir = fullfile(mibDir, 'GuiTools','volren');
cd(currDir);
mex affine_transform_2d_double.c image_interpolation.c -v;

currDir = fullfile(mibDir, 'ImageFilters','Coherence_filter','functions');
cd(currDir);
mex('derivatives.c' ,'-v');
mex('imgaussian.c' ,'-v');

currDir = fullfile(mibDir, 'ImageFilters','Coherence_filter','functions2D');
cd(currDir);
mex('CoherenceFilterStep2D.c' ,'-v');

currDir = fullfile(mibDir, 'ImageFilters','Coherence_filter','functions3D');
cd(currDir);
mex('CoherenceFilterStep3D.c' ,'-v');
mex('diffusion_scheme_3D_non_negativity.c' ,'-v');
mex('diffusion_scheme_3D_rotation_invariant.c' ,'-v');
mex('diffusion_scheme_3D_standard.c' ,'-v');
mex('EigenVectors3D.c' ,'-v');
mex('StructureTensor2DiffusionTensor3D.c' ,'-v');
mex('diffusion_scheme_3D_novel_getUpdate.c' ,'-v');

%% Compiling fast marching
waitbar(0.05, wb, sprintf('Compiling Fast Marching\nPlease wait...'));
currDir = fullfile(mibDir, 'ImageFilters','FastMarching','functions');
cd(currDir);
mex('msfm2d.c' ,'-v');
mex('msfm3d.c' ,'-v');

currDir = fullfile(mibDir, 'ImageFilters','FastMarching','shortestpath');
cd(currDir);
mex('rk4.c' ,'-v');

%% Compiling Frangi
waitbar(0.1, wb, sprintf('Compiling Frangi\nPlease wait...'));
currDir = fullfile(mibDir, 'ImageFilters','Frangi');
cd(currDir);
mex('eig3volume.c' ,'-v');
mex('imgaussian.c' ,'-v');

%% Compiling Membrane Detection 
waitbar(0.15, wb, sprintf('Compiling Membrane Detection\nPlease wait...'));
currDir = fullfile(mibDir, 'ImageFilters','RandomForest','MembraneDetection');
cd(currDir);
mex('meanvar.c' ,'-v');
mex('transformImageFast.c' ,'-v');

%% Compiling SLIC superpixels
waitbar(0.2, wb, sprintf('Compiling SLIC and Maxflow\nPlease wait...'));
currDir = fullfile(mibDir, 'ImageFilters','Supervoxels');
cd(currDir);
mex('slicmex.c' ,'-v');
mex('slicsupervoxelmex.c' ,'-v');
mex('slicsupervoxelmex_byte.c' ,'-v');
mex -v -largeArrayDims maxflowmex_v222.cpp maxflow-v2.22/adjacency_list_new_interface/graph.cpp maxflow-v2.22/adjacency_list_new_interface/maxflow.cpp
%mex -v -largeArrayDims maxflowmex_v301.cpp maxflow-v3.01/graph.cpp maxflow-v3.01/maxflow.cpp

%% Compiling Region Growing
waitbar(0.25, wb, sprintf('Compiling Region Growing\nPlease wait...'));
currDir = fullfile(mibDir, 'Tools','RegionGrowing');
cd(currDir);
mex('RegionGrowing_mex.cpp' ,'-v');
waitbar(1, wb);
delete(wb);

nrrdPath = fullfile(mibDir, 'ImportExportTools','nrrd','compilethis.m');
forestPath1 = fullfile(mibDir, 'ImageFilters','RandomForest','RF_Class_C');
forestPath2 = fullfile(mibDir, 'ImageFilters','RandomForest','RF_Reg_C');
strText = '!!! Warning !!!\n\nThe following files have to be compiled manually:\n1) NRRD Reader\n%s\n\n2) Random Forest Classifier for Linux\n%s\n%s';
warndlg(sprintf(strText, nrrdPath, forestPath1,forestPath2));
disp('!!!!!!!!!!!!!!!!!!! Warning !!!!!!!!!!!!!!!!!!!')
disp('The following files have to be compiled manually:')
disp('1) NRRD Reader')
disp(nrrdPath)
disp('2) Random Forest Classifier for Linux')
disp(forestPath1)
disp(forestPath2)
