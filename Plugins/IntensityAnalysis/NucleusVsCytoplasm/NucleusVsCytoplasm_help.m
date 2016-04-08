%% NucleusVsCytoplasm 
% This plugin calculates intensities (mean, min, max or sum) of the image
% that belongs to two materials of the opened model.
% 
% The results of the plugin may be seen on the screen of |Microscopy Image
% Browser| or saved as Excel spreadsheet.
%
% 
% <<NucleusVsCytoplasmSnapshot.jpg>>
% 
%% How to Use
%
% * 1. Load images
% * 2. Create a new model: press the |Create| button in the |Segmentation Panel|
% * 3. Add material to the model: press the |+| button in the |Segmentation
% Panel|; select |1| in the |Materials| list, press the right mouse button
% and |Rename| it to _Nucleus_.
%%
% 
% <<Step_03.jpg>>
% 
% * 4. Select the |Brush| tool in the |Selection type| and draw nuclei of
% the cells
%%
% 
% <<Step_04.jpg>>
% 
% * 5. Make sure that the |1| is selected in the |Add to| list and press
% the |A| key button to add the drawn areas to the _Nucleus_ material of the
% model.
%%
% 
% <<Step_05.jpg>>
%
% * 6. Add another material to the model (the |+| button) and rename it to
% _Cytoplasm_.
% * 7. With the Brush tool draw areas of the cytoplasm and add it to the
% |2| material.
%%
% 
% <<Step_07.jpg>>
%
% * 8. Repeat *4., 5. and 7.* for all slices of the opened dataset
% * 9. Start NucleusVsCytoplams tool: Menu->Plugins->IntensityAnalysis->NucleusVsCytoplams
% * 10. Select color channel and materials to analyze, define other parameters of the NucleusVsCytoplams tool and press the
% |Continue| buttton. 
% 
% *Note!* Remember to save the model for future use!
%%
% 
% <<Step_10.jpg>>
%
%% Options
%
% * *Color channel to analyze* - a combo box that allows to define a color channel that will be analyzed.
% * *Calculate parameter* - a combo box that allows to choose type of the
% intensity to analize (Mean, Minimal, Maximal, or Sum).
% * *Calculate ratio of* - two comboboxes that allow to select ratio of
% which materials should be analyzed
% * *Plot ratio as histogram* - the ratio between intensities will be displayed as a histogram.
%%
% 
% <<histogram.jpg>>
%
% * *Save results in Excel format* - check this to save results as Excel
% spreadsheet
% * *Filename to export* - the |...| button and the edit box to specify the
% filename for the export
% 
%% Credits
%
% <html>
%  Written by Ilya Belevich, University of Helsinki<br>
%  version 1.00, 16.03.2014<br>
%  email: <a href="mailto:ilya.belevich@helsinki.fi">ilya.belevich@helsinki.fi</a><br>
%  web: <a href="http://www.biocenter.helsinki.fi/~ibelev/">http://www.biocenter.helsinki.fi/~ibelev/</a><br>
% </html>
%
%
% Part of the code written by
% <http://stackoverflow.com/questions/12083467/find-the-nearest-point-pairs-between-two-sets-of-of-matrix
% Gunther Struyf> was used when writing this function.
