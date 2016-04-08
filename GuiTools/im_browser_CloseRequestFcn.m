function im_browser_CloseRequestFcn(~, ~, handles)
% --- Executes when user attempts to close im_browser.

% Copyright (C) 21.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


choice = questdlg('You are about to close Microsopy Image Browser?', 'Microscopy Image Browser', 'Close', 'Cancel','Cancel');
if strcmp(choice, 'Cancel'); return; end;

% unload OMERO
if ~isdeployed
    if exist('unloadOmero.m','file') == 2;
        % preserve Omero path
        omeroPath = findOmero;
        %s = warning()
        %warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');    % switch off warnings for latex
        warning('off','MATLAB:javaclasspath:jarAlreadySpecified');    % switch off warnings for latex
        unloadOmero;
        addpath(omeroPath);
        warning('on','MATLAB:javaclasspath:jarAlreadySpecified');    % switch off warnings for latex
    end;
end

im_browser_pars = struct();
im_browser_pars.lastpath = handles.mypath;
im_browser_pars.preferences = handles.preferences; %#ok<STRNU>

os = getenv('OS');
if strcmp(os,'Windows_NT')
    if isdir(['c:' filesep 'temp']) == 0; [~, ~, messageid] = mkdir(['c:' filesep 'temp']);        end;    % create a tmp directory for storing im_browser parameters
    try
        save(['c:' filesep 'temp' filesep 'im_browser.mat'],'im_browser_pars');
    catch err
        try     % try to save it into windows temp folder (C:\Users\User-name\AppData\Local\Temp\)
            fn = fullfile(tempdir, 'im_browser.mat');
            save(fn, 'im_browser_pars');
        catch err
            msgbox(sprintf('There is a problem with saving settings\n%s', err.identifier),'Error','error','modal');
        end
    end
else        % linux
    try
        save([fileparts(which('im_browser.m')) filesep 'im_browser.mat'],'im_browser_pars');
    catch err
        try     % try to save it into linux temp folder
            fn = fullfile(tempdir, 'im_browser.mat');
            save(fn, 'im_browser_pars');
        catch err
            msgbox(sprintf('There is a problem with saving settings\n%s', err.identifier),'Error','error','modal');
        end
    end
end

clear imageData;
delete(findall(0,'Type','figure','tag','imAdjustments'));
delete(findall(0,'Type','figure','tag','logWindow'));
delete(findall(0,'Type','figure','tag','maskStatsDlg'));
delete(findall(0,'Type','figure','tag','ib_datasetInfoGui'));
delete(findall(0,'Type','figure','tag','ib_labelsGui'));
delete(findall(0,'Type','figure','tag','ib_MembraneDetection'));
delete(findall(0,'Type','figure','tag','ib_snapshotGui'));
delete(findall(0,'Type','figure','tag','ib_saveVideoGui'));
delete(findall(0,'Type','figure','tag','ib_watershedGui'));
delete(findall(0,'Type','figure','tag','mib_measureTool'));
delete(findall(0,'Type','figure','tag','mib_stereologyGui'));
delete(handles.im_browser);

% Delete Custom scripts figures
windowList = findall(0,'Type','figure');
for i=1:numel(windowList)
    if ~isempty(strfind(get(windowList(i),'Filename'),'Plugins'))
        delete(windowList(i));
    end
end
end