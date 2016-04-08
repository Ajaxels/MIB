function handles = ib_smoothImage(handles, type)
% function handles = ib_smoothImage(handles, type, options)
% Smooth 'Mask', 'Selection' or 'Model' layer
%
% Parameters:
% handles: structure with handles of im_browser.m
% type: a type of the layer for the smoothing:
% - ''selection'' - run size exclusion on the 'Selection' layer
% - ''model'' - - run size exclusion on the 'Model' layer
% - ''mask'' - - run size exclusion on the 'Mask' layer
% 
% Return values:
% handles: structure with handles of im_browser.m

% Copyright (C) 30.04.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 21.02.2016, IB, updated for 4D datasets


title = [type 'Smoothing...'];
def = {'2D','5','5','5',};
prompt = {'Mode (''3D'' for smoothing in 3D or ''2D'' for smoothing in 2D):','XY Kernel size:',sprintf('Z Kernel size for 3D; Y-dim for 2D\nleave empty for automatic calculation based on voxel size:'),'Sigma'};
answer = inputdlg(prompt,title,[1 30],def,'on');    
if size(answer) == 0; return; end; 
if isnan(str2double(answer{3}))
    kernel = str2double(answer{2});
else
    kernel = [str2double(answer{2}) str2double(answer{3})];
end

if strcmp(answer{1},'2D')
    options.fitType = 'Gaussian';
else
    options.fitType = 'Gaussian 3D';
end
options.hSize = kernel;
if isempty(answer{4})
    options.sigma = 1;
else
    options.sigma = str2double(answer{4});    
end

options.pixSize = handles.Img{handles.Id}.I.pixSize;
options.orientation = handles.Img{handles.Id}.I.orientation;
options.showWaitbar = 0;    % do not show the waitbar in the ib_doImageFiltering function
type = lower(type);
t1 = 1;
t2 = handles.Img{handles.Id}.I.time;

wb = waitbar(0, sprintf('Smoothing the %s layer\nPlease wait...', type),'Name','Smoothing','WindowStyle','modal');

switch type
    case {'mask', 'selection'}
        if t1==t2
            ib_do_backup(handles, type, 1);
        end
        options.dataType = '3D';
        for t=t1:t2
            mask = ib_getStack(type, handles, t, 4);
            for roi=1:numel(mask)
                mask{roi} = ib_doImageFiltering(mask{roi}, options);
            end
            ib_setStack(type, mask, handles, t, 4);
            waitbar(t/t2,wb);
        end
    case 'model'
        options.dataType = '3D';
        sel_model = get(handles.segmList,'Value');
        if t1==t2
            ib_do_backup(handles, 'model', 1);
        end
        start_no=sel_model;
        end_no=sel_model;
        
        for t=t1:t2
            for object = start_no:end_no
                model = ib_getStack('model', handles, t, 4, object);
                for roi=1:numel(model)
                    model{roi} = ib_doImageFiltering(model{roi}, options);
                end
                ib_setStack('model', model, handles, t, 4, object);
            end
            waitbar(t/t2,wb);
        end
end
delete(wb);
end