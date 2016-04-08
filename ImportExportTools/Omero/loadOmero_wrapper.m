function [client,session,gateway]=loadOmero_wrapper(varargin)
% function [client,session,gateway]=loadOmero_wrapper(varargin)
% A wrapper function to start Omero. Starts Omero in the Matlab and deployed versions of im_browser.
%
% @note requires Omero to be installed (http://www.openmicroscopy.org/site/products/omero).
% @note Parameters and Return values are the same as in the loadOmero.m 

% Copyright (C) 13.08.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

warning('off','MATLAB:javaclasspath:jarAlreadySpecified');    % switch off warnings for latex
if ~isdeployed
    loadOmero;     % from Matlab, use original loadOmero script in the Omero folder
else
    loadOmero_deploy;  % from deployed im_browser, use modified loadOmero script (loadOmero_deploy.m) in im_browser/Tools/Omero
end
warning('on','MATLAB:javaclasspath:jarAlreadySpecified');    % switch off warnings for latex
end