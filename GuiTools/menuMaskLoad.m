function menuMaskLoad(hObject, eventdata, handles)
% function menuMaskLoad(hObject, eventdata, handles)
% a callback to Menu->Mask->Load Mask
% loads the Mask layer to MIB from a file
%
% Parameters:
% hObject: handle to im_browser.m (see GCBO)
% eventdata: eventdata structure 
% handles: structure with handles of im_browser.m

% Copyright (C) 14.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 07.09.2015, IB updated to use imageData.getData3D methods
% 17.02.2016, IB, updated for 4D datasets

% do nothing is selection is disabled
if strcmp(handles.preferences.disableSelection, 'yes'); 
    warndlg(sprintf('The mask layer is switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The models are disabled','modal');
    return; 
end;

if handles.Img{handles.Id}.I.time < 2
    ib_do_backup(handles, 'mask', 1);
end

handles.mypath = get(handles.pathEdit,'String');
[filename, path] = uigetfile(...
    {'*.mask;',  'Matlab format (*.mask)'; ...
    '*.am;',  'Amira mesh format (*.am)'; ...
    '*.tif;', 'TIF format (*.tif)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Open mask data...',handles.mypath,'MultiSelect','on');
if isequal(filename,0); return; end; % check for cancel
if ischar(filename); filename = cellstr(filename); end;     % convert to cell type
%warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');    % switch off warnings for latex
curInt = get(0, 'DefaulttextInterpreter'); 
set(0, 'DefaulttextInterpreter', 'none'); 
wb = waitbar(0,sprintf('%s\nPlease wait...',fullfile(path, filename{1})),'Name','Loading the mask','WindowStyle','modal');
waitbar(0, wb);

if handles.Img{handles.Id}.I.maskExist == 0 && ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
    handles.Img{handles.Id}.I.maskImg = zeros([handles.Img{handles.Id}.I.height, handles.Img{handles.Id}.I.width, handles.Img{handles.Id}.I.no_stacks, handles.Img{handles.Id}.I.time],'uint8');
    handles.Img{handles.Id}.I.maskExist = 1;
end
setDataOptions.blockModeSwitch = 0;

for fnId = 1:numel(filename)
    if strcmp(filename{1}(end-1:end),'am') % loading amira mesh
        res = amiraLabels2bitmap(fullfile(path, filename{fnId}));
    elseif strcmp(filename{1}(end-3:end),'mask') % loading matlab format
        res = load(fullfile(path, filename{fnId}),'-mat');
        field_name = fieldnames(res);
        res = res.(field_name{1});
    else % loading mask in tif format and other standard formats
        options.bioformatsCheck = 0;
        options.progressDlg = 0;
        [res, ~, ~] = ib_loadImages({fullfile(path, filename{fnId})}, options, handles);
        res =  squeeze(res);
        res = uint8(res>0);    % set masked areas as 1
    end
    
    % check dimensions
    if size(res,1) == size(handles.Img{handles.Id}.I.img,1) && size(res,2) == size(handles.Img{handles.Id}.I.img,2)
        % do nothing
    elseif size(res,1) == size(handles.Img{handles.Id}.I.img,2) && size(res,2) == size(handles.Img{handles.Id}.I.img,1)
        % permute
        res = permute(res, [2 1 3 4]);
    else
        msgbox('Mask image and loaded image dimensions mismatch!','Error!','error','modal');
        delete(wb);
        return;
    end
    
    if size(res, 4) > 1 && size(res, 4) == handles.Img{handles.Id}.I.time   % update complete 4D dataset
        handles.Img{handles.Id}.I.setData4D('mask', res, 4, 0, setDataOptions);
    elseif size(res, 4) == 1 && size(res,3) == handles.Img{handles.Id}.I.no_stacks  % update complete 3D dataset
        if numel(filename) > 1
            handles.Img{handles.Id}.I.setData3D('mask', res, fnId, 4, 0, setDataOptions);
        else
            handles.Img{handles.Id}.I.setData3D('mask', res, NaN, 4, 0, setDataOptions);
        end
    elseif size(res, 3) == 1
        if numel(filename) > 1
            handles.Img{handles.Id}.I.setData2D('mask', res, fnId, 4, 0, NaN, setDataOptions);
        else
            handles.Img{handles.Id}.I.setData2D('mask', res, NaN, 4, 0, NaN, setDataOptions);
        end
    end
    waitbar(fnId/numel(filename),wb);
end
handles.Img{handles.Id}.I.maskImgFilename = fullfile([path filename{1}]);
waitbar(1,wb);

set(handles.maskShowCheck,'Value',1);
delete(wb);
set(0, 'DefaulttextInterpreter', curInt); 
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end