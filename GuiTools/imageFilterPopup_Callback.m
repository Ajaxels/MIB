function imageFilterPopup_Callback(hObject, eventdata, handles)
% function imageFilterPopup_Callback(hObject, eventdata, handles)
% a callback to the handles.imageFilterPopup, modifies panels with respect to the selected filter type
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

returnFromFrangi = get(handles.imfiltPar4Edit,'Enable');


% change type of image filter
set(handles.andiffPopupFavours,'Enable','off');
set(handles.imfiltPar1Edit,'Enable','on');
set(handles.imfiltPar2Edit,'Enable','on');
set(handles.imfiltPar3Edit,'Enable','off');
set(handles.imfiltPar4Edit,'Enable','off');
set(handles.imfiltPar5Edit,'Enable','off');
set(handles.imfiltPar1Edit,'TooltipString','Kernel size in pixels, use two semicolon separated numbers for custom kernels');
set(handles.imfiltPar2Edit,'TooltipString','');
set(handles.coherenceFilterPanel,'visible','off');

selval = get(handles.imageFilterPopup,'Value');
list =get(handles.imageFilterPopup,'String');
selfilter = cell2mat(list(selval));

if strcmp(returnFromFrangi, 'on')   % reinitialize default values when returning back from Frangi filter
    set(handles.imfiltPar1Edit,'String','3');
    set(handles.imfiltPar2Edit,'String','0.6');
    set(handles.imfiltPar3Edit,'String','0.25');
end

switch selfilter
    case {'Gaussian', 'Gaussian 3D'}
        set(handles.imfiltPar1Txt,'String','HSize:');
        set(handles.imfiltPar2Txt,'String','Sigma:');
        set(handles.imfiltPar2Edit,'String','0.6');
    case 'Unsharp'
        if handles.matlabVersion < 8.1
            set(handles.imfiltPar1Txt,'String','HSize:');
            set(handles.imfiltPar2Edit,'Enable','off');
        else
            set(handles.imfiltPar1Txt,'String','Radius:');
            set(handles.imfiltPar2Txt,'String','Amount:');
            set(handles.imfiltPar3Txt,'String','Threshold:');
            set(handles.imfiltPar3Edit,'Enable','on');
            set(handles.imfiltPar1Edit,'TooltipString','Standard deviation of the Gaussian lowpass filter, float');
            set(handles.imfiltPar2Edit,'TooltipString','Strength of the sharpening effect, float [0-2]');
            set(handles.imfiltPar3Edit,'TooltipString','Minimum contrast required for a pixel to be considered an edgepixel, specified as a float in the range [0 1].');
        end
    case 'Motion'
        set(handles.imfiltPar1Txt,'String','Length:');
        set(handles.imfiltPar2Txt,'String','Angle:');
    case {'Average', 'Disk', 'Median 2D', 'Wiener 2D'}
        set(handles.imfiltPar1Txt,'String','HSize:');
        set(handles.imfiltPar2Edit,'Enable','off');
    case {'Gradient 2D', 'Gradient 3D'}
        set(handles.imfiltPar1Edit,'Enable','off');
        set(handles.imfiltPar2Edit,'Enable','off');
    case {'Frangi 2D', 'Frangi 3D'}        
        set(handles.imfiltPar1Txt,'String','Range');
        set(handles.imfiltPar1Edit,'String','1-6');
        set(handles.imfiltPar1Edit,'TooltipString','The range of sigmas used, default [1-6]');
        set(handles.imfiltPar2Txt,'String','Ratio');
        set(handles.imfiltPar2Edit,'String','2');
        set(handles.imfiltPar2Edit,'TooltipString','Step size between sigmas, default 2');
        set(handles.imfiltPar3Txt,'String','beta1');
        set(handles.imfiltPar3Edit,'String','0.9');
        set(handles.imfiltPar3Edit,'Enable','on');
        set(handles.imfiltPar4Edit,'Enable','on');
        set(handles.andiffPopupFavours,'Enable','On');
        set(handles.andiffPopupFavours,'String',{'Black on White','White on Black'});
        if strcmp(selfilter, 'Frangi 3D')
            set(handles.imfiltPar5Edit,'Enable','on');
            set(handles.imfiltPar3Edit,'TooltipString','Frangi vesselness constant, treshold on Lambda2/Lambda3 determines if its a line(vessel) or a plane like structure, default .5;');
            set(handles.imfiltPar4Edit,'TooltipString','Frangi vesselness constant, which determines the deviation from a blob like structure, default .5;');
            set(handles.imfiltPar5Edit,'TooltipString','Frangi vesselness constant which gives the threshold between eigenvalues of noise and vessel structure. A thumb rule is dividing the the greyvalues of the vessels by 4 till 6');
        else
            set(handles.imfiltPar3Edit,'TooltipString','Frangi correction constant, default 0.5');
            set(handles.imfiltPar4Edit,'TooltipString','Frangi correction constant, default 15');
        end
    case 'Laplacian'
        set(handles.imfiltPar2Txt,'String','Alpha:');
        set(handles.imfiltPar2Edit,'String','0.5');
        set(handles.imfiltPar1Edit,'Enable','off');
    case 'Perona Malik anisotropic diffusion'
        set(handles.imfiltPar1Edit,'TooltipString','Number of Iterations');
        set(handles.imfiltPar2Edit,'TooltipString','Edge-stopping parameter (4% of the image''s range is a good start). Default=4');
        set(handles.imfiltPar3Edit,'TooltipString','Diffusion step (<1, smaller + more iterations = more accurate). Default=0.25');
        set(handles.imfiltPar1Txt,'String','Iter:');
        set(handles.imfiltPar2Txt,'String','K (%):');
        set(handles.imfiltPar3Edit,'Enable','on');
        set(handles.imfiltPar3Edit,'TooltipString','Diffusion step (<1, smaller + more iterations = more accurate). Default=0.25');
        set(handles.imfiltPar2Edit,'String','4');
        set(handles.andiffPopupFavours,'Enable','on');
        set(handles.andiffPopupFavours,'String',{'Edges','Regions'});
    case {'Edge Enhancing Coherence Filter'}
        set(handles.imfiltPar1Edit,'Enable','off');
        set(handles.imfiltPar2Edit,'Enable','off');
        set(handles.imfiltPar3Edit,'Enable','off');
        set(handles.coherenceFilterPanel,'visible','on');
    case 'Diplib: Perona Malik anisotropic diffusion'
        set(handles.imfiltPar1Edit,'TooltipString','Number of Iterations');
        set(handles.imfiltPar1Txt,'String','Iter:');
        set(handles.imfiltPar2Txt,'String','K:');
        set(handles.imfiltPar2Edit,'TooltipString','Edge-stopping parameter (4% of the image''s range is a good start). Default=10');
        set(handles.imfiltPar3Edit,'TooltipString','Diffusion step (<1, smaller + more iterations = more accurate). Default=0.25');
    case 'Diplib: Robust Anisotropic Diffusion'
        set(handles.imfiltPar1Txt,'String','Iter:');
        set(handles.imfiltPar2Txt,'String','Sigma:');
        set(handles.imfiltPar2Edit,'TooltipString','Scale parameter on the psiFunction. Choose this number to be bigger than the noise but small than the real discontinuties. Default=20');
        set(handles.imfiltPar3Edit,'TooltipString','Rate parameter. To approximage a continuous-time PDE, make lambda small and increase the number of iterations. Default=0.25');
    case {'Diplib: Mean Curvature Diffusion', 'Diplib: Corner Preserving Diffusion'}
        set(handles.imfiltPar1Txt,'String','Iter:');
        set(handles.imfiltPar2Txt,'String','Sigma:');
        set(handles.imfiltPar3Edit,'Enable','off');
        set(handles.imfiltPar2Edit,'TooltipString','For Gaussian derivative, should increase with noise level. Default=1');
    case 'Diplib: Kuwahara filter for edge-preserving smoothing'
        set(handles.imfiltPar1Txt,'String','Shape:');
        set(handles.imfiltPar1Edit,'TooltipString','filterShape: 1:rectangular, 2:elliptic, 3:diamond');
        set(handles.imfiltPar3Edit,'String','2');
        set(handles.imfiltPar2Txt,'String','Size:');
        set(handles.imfiltPar3Edit,'Enable','off');
end

% update the mode from 2D to 3D when using the 3D filters
if ismember(selfilter, {'Gaussian 3D', 'Gradient 3D','Frangi 3D'})
    if get(handles.imageFiltersMode, 'value') == 1
        set(handles.imageFiltersMode, 'value', 2);
    end
end

imfiltPar1Edit_Callback(handles.imfiltPar1Edit, eventdata, handles);
% Update handles structure
%guidata(handles.im_browser, handles);
end