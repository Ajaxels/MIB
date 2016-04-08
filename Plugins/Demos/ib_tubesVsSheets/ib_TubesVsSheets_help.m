%% Tubes vs Sheets analysis 
% This plugin calculates ratio between tubes and sheets from the masked
% areas.
% 
% The results of the plugin may be seen on the screen or exported to the main Matlab workspace or to Excel.
%
% 
% <<ib_TubesVsSheets.jpg>>
% 
%% How to Use
%
% * 1. Load datasets, 2D or 3D. 
%
% 
% <<01_open_dataset.jpg>>
% 
% * 2. Set the pixel size: |Menu->Dataset->Parameters|:
%
% 
% <<02_set_parameters.jpg>>
% 
% * 3.Segment objects of interest and assign them to the |Mask| layer. For
% example, the shown dataset was segmented using the random forest
% classifier: |Menu->Tools->Random Forest Classifier|
%
% 
% <<03_segment_mask.jpg>>
% 
% * 4. Use the ROI tools to select area for the analysis [ _optional_ ].
%
%%
% 
% <<04_define_roi.jpg>>
% 
% * 5. Start |ib_TubesVsSheets| from |Menu->Plugins|
% * 6. Define in pixels width of a typical tube profile and the way to report results.
% * 7. Press the *Calculate* button. The function will first erode image to
% remove tubular components, that is followed with dilation to restore the
% sheets. The difference between the original mask and the generated sheets
% defines the tubular areas. The image below shows the idea of such
% analysis, the value for the width of a typical tube profile should be
% adjusted
%%
% 
% <<05_workflow.jpg>>
% 
% * 8. The results are shown as a model with 2 materials: sheets and tubes.
% 
%%
% 
% <<06_results.jpg>>
% 

