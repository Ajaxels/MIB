function im_browser_deploy

% try
%     javaaddpath('c:\Science\Fiji\jars\', '-end');
% catch err
%     sprintf('%s', err.identifier)
% end

% the reason for the following Java connecting code is that javaaddpath function is not completely compatible with the
% deployed version of im_browser

% Copyright (C) 12.05.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% get java library paths

% see more on path
% http://blogs.mathworks.com/loren/2008/08/11/path-management-in-deployed-applications/

fijiJavaPath = 0;
omeroJavaPath = 0;

if isunix()
    [~, user_name] = system('whoami'); 
    pathName = fullfile('./Users', user_name(1:end-1), 'Documents/MIB');
else
    pathName = pwd;
end


javaPathfn = fullfile(pathName, 'java_path.txt');
if exist(javaPathfn,'file') ~= 2
    msgbox(sprintf('A path-file for Java libraries was not found!\n\nPlease add "java_path.txt" file with the list of JAR directories (for example: "C:\\Fiji\\jars") to the im_browser directory (%s)', javaPathfn),'Missing Fiji JARs','error');
else
    fid = fopen(javaPathfn);
    tline = fgetl(fid);
    while ischar(tline)
        if isunix()   % in MacOS the path should not have :  
            if ~isempty(strfind(lower(tline), 'fiji')) && isempty(strfind(tline, ':'))
                fijiJavaPath = tline;
            elseif ~isempty(strfind(lower(tline), 'omero')) && isempty(strfind(tline, ':'))
                omeroJavaPath = tline;  
            end
        else
            if ~isempty(strfind(lower(tline), 'fiji')) && ~isempty(strfind(tline, ':'))
                fijiJavaPath = tline;
            elseif ~isempty(strfind(lower(tline), 'omero')) && ~isempty(strfind(tline, ':'))
                omeroJavaPath = tline;
            elseif ~isempty(strfind(lower(tline), 'imaris')) && ~isempty(strfind(tline, ':'))
                imarisJavaPath = tline;
                if exist(imarisJavaPath, 'file') == 0   % check presense of imaris library
                    imarisJavaPath = 0;
                end
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end

% Load Fiji libraries
if fijiJavaPath == 0
    sprintf('Fiji path was not found!\n\nPlease add it (for example: "C:\\Fiji\\") to "java_path.txt" file at the im_browser directory (%s)', javaPathfn)
else
    if exist(fijiJavaPath,'dir') ~= 7    % not a folder
        sprintf('Fiji path was not correct!\n\nPlease fix it (for example: "C:\\Fiji\\") in "java_path.txt" file at the im_browser directory (%s)', javaPathfn);
    else
        % add Fiji libraries
        % Get the Fiji directory
        %fiji_directory = fileparts(fijiJavaPath);
        fiji_directory = fijiJavaPath;
        
        % Get the Java classpath
        classpath = javaclasspath('-all');
        
        % Add all libraries in jars/ and plugins/ to the classpath
        
        % Switch off warning
        warning_state = warning('off');
        add_to_classpath(classpath, fullfile(fiji_directory, 'jars'));
        classpath = javaclasspath('-all');
        add_to_classpath(classpath, fullfile(fiji_directory, 'plugins'));
        
        % Switch warning back to initial settings
        warning(warning_state);
        
        % Set the Fiji directory (and plugins.dir which is not Fiji.app/plugins/)
        java.lang.System.setProperty('ij.dir', fiji_directory);
        java.lang.System.setProperty('plugins.dir', fiji_directory);
    end
end

% Load Omero libraries
if omeroJavaPath == 0
    sprintf('Omero Java libraries path was not found!\n\nPlease add it (for example: "C:\\Omero\\libs") to "java_path.txt" file at the im_browser directory (%s)', javaPathfn)
else
    if exist(omeroJavaPath,'dir') ~= 7    % not a folder
        sprintf('Fiji Java libraries path was not correct!\n\nPlease fix it (for example: "C:\\Omero\\libs") in "java_path.txt" file at the im_browser directory (%s)', javaPathfn);
    else
        % add Omero libraries
        OmeroClient_Jar = fullfile(omeroJavaPath, 'omero_client.jar');
        javaaddpath(OmeroClient_Jar);
        import omero.*;
    end
end
   
% add BioFormats
% Switch off warning
warning_state = warning('off');

javaaddpath(fullfile(fileparts(mfilename('fullpath')),'File_formats','BioFormats','bioformats_package.jar'));
% Switch warning back to initial settings
warning(warning_state);

% the following wrapper is needed for im_browser
global running
running = 1;
im_browser;
while running
    pause(0.05);
end
end

function add_to_classpath(classpath, directory)
% Get all .jar files in the directory
test = dir(strcat([directory filesep '*.jar']));
path_= cell(0);
for i = 1:length(test)
    if not_yet_in_classpath(classpath, test(i).name)
        path_{length(path_) + 1} = strcat([directory filesep test(i).name]);
    end
end

% Add them to the classpath
if ~isempty(path_)
    try
        javaaddpath(path_, '-end');
    catch err
        sprintf('%s', err.identifier);
    end
end
end

function test = not_yet_in_classpath(classpath, filename)
% Test whether the library was already imported
%expression = strcat([filesep filename '$']);
%test = isempty(cell2mat(regexp(classpath, expression)));
expression = strcat([filesep filename]);
test = isempty(cell2mat(strfind(classpath, expression)));
end