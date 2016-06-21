function ib_exportToFiji(handles)
% function ib_exportToFiji(handles)
% Export currently open dataset to Fiji
%
% @note requires Fiji to be installed (http://fiji.sc/Fiji).
%
% Parameters:
% handles: handles structure of im_browser
%
% Return values:

% Copyright (C) 16.05.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 23.03.2016, IB updated to allow sending subsets that are defined by ROI to Fiji


% check for MIJ
if exist('MIJ','class') == 8
    if ~isempty(ij.gui.Toolbar.getInstance)
        ij_instance = char(ij.gui.Toolbar.getInstance.toString);
        % -> ij.gui.Toolbar[canvas1,3,41,548x27,invalid]
        if numel(strfind(ij_instance, 'invalid')) > 0    % instance already exist, but not shown
            Miji_wrapper(true);     % wrapper to Miji.m file
        end
    else
        Miji_wrapper(true);     % wrapper to Miji.m file
    end
else
   Miji_wrapper(true);     % wrapper to Miji.m file
end

filename = handles.Img{handles.Id}.I.img_info('Filename');
[~, fn] = fileparts(filename);

if get(handles.roiShowCheck,'value') == 1
    roiNo = get(handles.roiList, 'value');
    totalROINo = numel(get(handles.roiList, 'string'));
    if totalROINo > 2 && roiNo == 1
        msgbox('Please select ROI from the ROI list or unselect the ROI mode!','Select ROI!','warn','modal');
        return;
    end
end

%options.WindowStyle='modal';
%answer = inputdlg(sprintf('Please name for the dataset:'),'Set name',1,cellstr(fn),options);
answer = mib_inputdlg(handles,'Please name for the dataset:','Set name',fn);
if isempty(answer); return; end;

pause(0.1);     % for some strange reason have to put pause here, otherwise everything is freezing...

% define type of the dataset
datasetTypeValue = get(handles.fijiconnectTypePop, 'value');
datasetTypeList = get(handles.fijiconnectTypePop, 'string');
datasetType = datasetTypeList{datasetTypeValue};

%options.blockModeSwitch = 0;
%img = handles.Img{handles.Id}.I.getData3D(datasetType, NaN, 4, NaN, options);

img = ib_getStack(datasetType, handles, NaN, NaN, NaN);

if size(img{1},3) == 1; img{1} = squeeze(img{1}); end;

if ndims(img{1}) == 4
    img{1} = permute(img{1}, [1 2 4 3]);
    MIJ.createColor(answer{1}, img{1}, 1);
elseif strcmp(handles.Img{handles.Id}.I.img_info('ColorType'),'truecolor')
    MIJ.createColor(answer{1}, img{1}, 1);
else
    imp = MIJ.createImage(answer{1}, img{1}, 0);
    imp.show
end

end

