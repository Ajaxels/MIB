function varargout = anDiffOptionsDlg(varargin)
% function varargout = anDiffOptionsDlg(varargin)
% anDiffOptionsDlg function is responsible for a dialog for the coherence filter.
%
% anDiffOptionsDlg contains MATLAB code for anDiffOptionsDlg.fig 

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @anDiffOptionsDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @anDiffOptionsDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% End initialization code - DO NOT EDIT

% --- Executes just before anDiffOptionsDlg is made visible.
function anDiffOptionsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to anDiffOptionsDlg (see VARARGIN)

% Choose default command line output for anDiffOptionsDlg
handles.output = [{NaN} {NaN}];

% Update handles structure
guidata(hObject, handles);

if (nargin < 5)
    handles.img = NaN;  % image
else
    handles.img = varargin{2};
end
handles.type = varargin{1}; % type of the dialog: options or test

% load parameters when available
localPath = fileparts(which('anDiffOptionsDlg'));
handles.parametersFile = fullfile(localPath, 'anDiffOptionsDlg_parameters.mat');
if exist(handles.parametersFile, 'file') == 0   % no settings available, use default
    parameters.Scheme = 'N';    % The numerical diffusion scheme: R, O, I(for 2d only), S, N
    parameters.T = 5;    % The total diffusion time
    parameters.dt = 0.15;    % Diffusion time stepsize
    parameters.sigma = 5;    % Sigma of gaussian smoothing before calculation of the image Hessian
    parameters.rho = 1;    % the sigma of the Gaussian smoothing of the Hessian
    parameters.verbose = 'iter';    % show info: 'none','iter','full'
    parameters.eigenmode = 2;    % diffusion tensor for 3d (0, 1, 2, 3, 4)
    parameters.C = 1e-10;        % Constants which determine the amplitude of the diffusion smoothing for Tensor=0,1
    parameters.m = 1;            % Constants which determine the amplitude of the diffusion smoothing for Tensor=0,1
    parameters.alpha = 0.001;    % Constants which determine the amplitude of the diffusion smoothing for Tensor=0,1
    parameters.lambda_e = 0.02;  % Constants which are needed with Tensor=2,3,4;  planar structure contrast
    parameters.lambda_c = 0.02;  % Constants which are needed with Tensor=2,3,4;  tube like structure contrast
    parameters.lambda_h = 0.5;   % Constants which are needed with Tensor=2,3,4;  treshold between structure and noise
    anDiffDim = '3d';
else
    load(handles.parametersFile);   % load parameters structure
end

handles.dimension = anDiffDim; % 2d or 3d, handles.anDiffDim

if strcmp(handles.dimension,'3d')
    set(handles.radio3d,'Value',1);
else
    set(handles.radio2d,'Value',1);
end;
handles.anDiffOptions = parameters;    %handles.anDiffOptions

if strcmp(handles.type,'options')
    set(handles.saveResCheck,'Value',0);
    set(handles.saveResCheck,'Enable','off');
    set(handles.testRunBtn,'Visible','off');
elseif strcmp(handles.type,'test')
    set(handles.acceptBtn,'Visible','off');
    set(handles.testRunBtn,'Visible','on');
    saveResCheck_Callback(handles.saveResCheck, eventdata, handles);
    set(handles.saveFramesTxt,'String',sprintf('Save frames numbers (ex. 1:5):\nNumber of layers=%i\nNote: parameters will be stored in the ImageDescription field of the image',size(handles.img,4)));
    set(handles.framesEdit,'String',num2str(round(size(handles.img,4)/2)));
end

% set columns
field_names = fieldnames(handles.anDiffOptions);
set(handles.optionsTable1,'Data',{handles.anDiffOptions.Scheme,handles.anDiffOptions.eigenmode,handles.anDiffOptions.verbose})
ind = 1;
for i=1:numel(field_names)
    if ~strcmp(field_names{i},'Scheme') && ~strcmp(field_names{i},'eigenmode') && ~strcmp(field_names{i},'verbose')
        data{ind} = num2str(handles.anDiffOptions.(field_names{i}));
        f_names{ind} = field_names{i};
        ind = ind + 1;
    end
end
set(handles.optionsTable2,'RowName',f_names);
set(handles.optionsTable2,'Data',data');
set(handles.optionsTable2,'ColumnWidth',{145});

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.anDiffOptionsDlg);

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Make the GUI modal
%set(handles.anDiffOptionsDlg,'WindowStyle','modal')
guidata(hObject, handles);
% UIWAIT makes anDiffOptionsDlg wait for user response (see UIRESUME)
uiwait(handles.anDiffOptionsDlg);
end


% --- Outputs from this function are returned to the command line.
function varargout = anDiffOptionsDlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout = handles.output;

% The figure can be deleted now
delete(handles.anDiffOptionsDlg);
end

% --- Executes on button press in acceptBtn.
function acceptBtn_Callback(hObject, eventdata, handles)
% hObject    handle to acceptBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f_names = get(handles.optionsTable2,'RowName');
data = get(handles.optionsTable2,'Data');
for i=1:numel(f_names)
    handles.anDiffOptions.(f_names{i}) = str2double(data{i});
end
data = get(handles.optionsTable1,'Data');
handles.anDiffOptions.Scheme = data{1};
handles.anDiffOptions.eigenmode = data{2};
handles.anDiffOptions.verbose = data{3};

% saving parameters    
try
    parameters = handles.anDiffOptions;  %#ok<NASGU>
    anDiffDim = handles.dimension; %#ok<NASGU>
    save(handles.parametersFile, 'parameters','anDiffDim');
catch err
    msgbox(sprintf('There is a problem with saving parameters\n%s', err.identifier),'Error','error','modal');
end

handles.output = [{handles.anDiffOptions} {handles.dimension}];

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.anDiffOptionsDlg);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
handles.output = [{NaN} {NaN}];
% Update handles structure
guidata(hObject, handles);
uiresume(handles.anDiffOptionsDlg);
end

% --- Executes when user attempts to close anDiffOptionsDlg.
function anDiffOptionsDlg_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
end

% --- Executes on key press over anDiffOptionsDlg with no controls selected.
function anDiffOptionsDlg_KeyPressFcn(hObject, eventdata, handles)
% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = [{NaN} {NaN}];
    % Update handles structure
    guidata(hObject, handles);
    uiresume(handles.anDiffOptionsDlg);
end    
    
end

% --- Executes on button press in testRunBtn.
function testRunBtn_Callback(hObject, eventdata, handles)
title = 'Extra parameters';
lines = 1;
if strcmp(handles.dimension,'3d') & size(handles.img,4) < 3
    msgbox('3d mode requires more than 3 layers!','Warning!','warn');
    return;
end
if strcmp(handles.dimension,'2d')
    set(handles.radio2d,'Value',1);
end

prompt = {'The numerical diffusion scheme (R,O,I(only for 2d),S,N):','Diffusion tensor type, eigenmode (0,1,2,3,4):'};
def = {'R,O,S,N', '0,1,2,3,4'};
answer = inputdlg(prompt,title,lines,def,'on');
if size(answer) == 0; return; end;
commas = [0 strfind(answer{2},',') length(answer{2})+1];
for i=1:numel(commas)-1
    testOptions.eigenmode(i) = str2double(answer{2}(commas(i)+1:commas(i+1)-1));
end

commas = [0 strfind(answer{1},',') length(answer{1})+1];
for i=1:numel(commas)-1
    testOptions.Scheme(i) = {answer{1}(commas(i)+1:commas(i+1)-1)};
end
fields_part = get(handles.optionsTable2,'RowName');
data = get(handles.optionsTable2,'Data');
for i=1:numel(fields_part)
    testOptions.(fields_part{i}) = str2num(cell2mat(data(i))); %#ok<*ST2NM>
end

if get(handles.saveResCheck,'Value')
    [fn,path] = uiputfile({'*.tif','TIF images (*.tif)';'*.*','All Files (*.*)'},'Save results as...','anDiffTest');
    if fn ~= 0
        fn = fullfile(path, fn);
    else
        return;
    end;

end
save_index = str2num(get(handles.framesEdit,'String'));

% do actual filtration
fImg2 = fuseImageDescription(handles.img(:,:,:,save_index(1):save_index(end)), 'Original,,,,,,,,,');
% ib_image2tiff(fn, fImg2, NaN, 'multy', 1, cellstr('Original')); old syntax
savingOptions = struct('overwrite', 1, 'Saving3d', 'multi', 'cmap', NaN);
ib_image2tiff(fn, fImg2, savingOptions, cellstr('Original')); 

fid = fopen([fn(1:end-3) 'txt'],'w');
field_names = fieldnames(testOptions);
for i=1:numel(field_names)
    if strcmp(field_names{i},'Scheme') | strcmp(field_names{i},'verbose') %#ok<OR2>
        fprintf(fid,'%s: %s\n',field_names{i}, cell2mat(testOptions.(field_names{i})));
    else
        fprintf(fid,'%s: %s\n',field_names{i}, num2str(testOptions.(field_names{i})));
    end
end
fclose(fid);
counter_max = numel(testOptions.Scheme)*numel(testOptions.eigenmode)*numel(testOptions.T)*numel(testOptions.dt)*numel(testOptions.sigma)*numel(testOptions.rho)*...
    numel(testOptions.C)*numel(testOptions.m)*numel(testOptions.alpha)*numel(testOptions.lambda_e)*numel(testOptions.lambda_c)*numel(testOptions.lambda_h);
wb = waitbar(0,'','Name','Testing Anisotropic Diffusion...','WindowStyle','modal');
dim_var = handles.dimension;
total_index = 0;
tStart = tic;
for scheme=1:numel(testOptions.Scheme)  % scheme loop
    for eigen=1:numel(testOptions.eigenmode)    % eigen loop
        par_ind = 0; % iterator for filenames
        for T=1:numel(testOptions.T)    % T loop
            for dt=1:numel(testOptions.dt)  % dt loop
                for sigma=1:numel(testOptions.sigma)    % sigma loop
                    for rho=1:numel(testOptions.rho)    % rho loop
                        for C=1:numel(testOptions.C)    % C loop
                            for m=1:numel(testOptions.m)    % m loop
                                for alpha=1:numel(testOptions.alpha)    % alpha loop
                                    for lambda_e=1:numel(testOptions.lambda_e)    % lambda_e loop
                                       for lambda_c=1:numel(testOptions.lambda_c)    % lambda_c loop
                                           for lambda_h=1:numel(testOptions.lambda_h)    % lambda_h loop
                                               Options.Scheme = testOptions.Scheme{scheme};
                                               Options.eigenmode = testOptions.eigenmode(eigen);
                                               Options.T = testOptions.T(T);
                                               Options.dt = testOptions.dt(dt);
                                               Options.sigma = testOptions.sigma(sigma);
                                               Options.rho = testOptions.rho(rho);
                                               Options.C = testOptions.C(C);
                                               Options.m = testOptions.m(m);
                                               Options.alpha = testOptions.alpha(alpha);
                                               Options.lambda_e = testOptions.lambda_e(lambda_e);
                                               Options.lambda_c = testOptions.lambda_c(lambda_c);
                                               Options.lambda_h = testOptions.lambda_h(lambda_h);
                                               Options.verbose = 'none';
                                               im_info = ['Anisotropic filtering options: Scheme=' Options.Scheme ...
                                                   ', eigenmode=' num2str(Options.eigenmode) ', T=' num2str(Options.T)...
                                                   ', dt=' num2str(Options.dt) ', sigma=' num2str(Options.sigma)...
                                                   ', rho=' num2str(Options.rho) ', C=' num2str(Options.C)...
                                                   ', m=' num2str(Options.m) ', alpha=' num2str(Options.alpha)...
                                                   ', lambda_e=' num2str(Options.lambda_e) ', lambda_c=' num2str(Options.lambda_c)...
                                                   ', lambda_h=' num2str(Options.lambda_h)];
                                               if strcmp(dim_var,'2d')   % 2d mode
                                                   fImg = zeros(size(handles.img,1),size(handles.img,2),size(handles.img,3),numel(save_index),class(handles.img));
                                                   for index=1:numel(save_index)
                                                        layer = save_index(index);
                                                        if size(handles.img,3)==1
                                                            fImg(:,:,1,index) = CoherenceFilter(handles.img(:,:,:,layer),Options);
                                                        else
                                                            fImg(:,:,:,index) = CoherenceFilter(handles.img(:,:,:,layer),Options);
                                                        end
                                                   end
                                                   file_name = [fn(1:end-4) '_' Options.Scheme '_' num2str(Options.eigenmode) sprintf('_%.4d',par_ind) fn(end-3:end)];
                                                   fImg = fuseImageDescription(fImg, ['2d ' im_info]);
                                                   % ib_image2tiff(file_name,fImg, NaN, 'multy', 1, cellstr(['2d ' im_info])); old syntax
                                                   savingOptions = struct('overwrite', 1, 'Saving3d', 'multi', 'cmap', NaN);
                                                   ib_image2tiff(file_name, fImg, savingOptions, cellstr(['2d ' im_info])); 
                                               elseif strcmp(dim_var,'3d')   % 3d mode
                                                    fImg = cast(CoherenceFilter(squeeze(handles.img),Options),'like', handles.img);
                                                    fImg = reshape(fImg,size(fImg,1),size(fImg,2),1,size(fImg,3));
                                                    file_name = [fn(1:end-4) '_' Options.Scheme '_' num2str(Options.eigenmode) sprintf('_%.4d',par_ind) fn(end-3:end)];
                                                    fImg = fuseImageDescription(fImg(:,:,:,save_index(1):save_index(end)), ['3d ' im_info]);
                                                    %ib_image2tiff(file_name, fImg, NaN, 'multy', 1, cellstr(['3d ' im_info]));
                                                    savingOptions = struct('overwrite', 1, 'Saving3d', 'multi', 'cmap', NaN);
                                                    ib_image2tiff(file_name, fImg, savingOptions, cellstr(['3d ' im_info]));
                                               end
                                               par_ind = par_ind + 1;
                                               total_index = total_index + 1;
                                               tElapsed = toc(tStart);
                                               eta = (counter_max*tElapsed/total_index-tElapsed)/60;
                                               waitbar(total_index/counter_max,wb, sprintf('Time left ~ %f min', eta));
                                           end  % end of lambda_h loop
                                       end  % end of lambda_c loop
                                    end     % end of lambda_e loop
                                end     % end of alpha loop
                            end     % end of m loop
                        end     % end of C loop
                    end     % rnd of rho loop
                end     % end of sigma loop
            end     % end of dt loop
        end     % end of T loop
    end     % end of eigen loop
end     % end of scheme loop
delete(wb);
disp('Anisotropic Diffusion Test: Done!');
toc(tStart);
% scheme_v = testOptions.Scheme;
% eigen_v = testOptions.eigenmode;
% T_v = testOptions.T;
% dt_v = testOptions.dt;
% sigma_v = testOptions.sigma;
% rho_v = testOptions.rho;
% C_v = testOptions.C;
% m_v = testOptions.m;
% alpha_v = testOptions.alpha;
% lambda_e_v = testOptions.lambda_e;
% lambda_c_v = testOptions.lambda_c;
% lambda_h_v = testOptions.lambda_h;
% img = handles.img;
% parfor scheme=1:numel(scheme_v)  % scheme loop
%     for eigen=1:numel(eigen_v)    % eigen loop
%         par_ind = 0;    % iterator for filenames
%         for T=1:numel(T_v)    % T loop
%             for dt=1:numel(dt_v)  % dt loop
%                 for sigma=1:numel(sigma_v)    % sigma loop
%                     for rho=1:numel(rho_v)    % rho loop
%                         for C=1:numel(C_v)    % C loop
%                             for m=1:numel(m_v)    % m loop
%                                 for alpha=1:numel(alpha_v)    % alpha loop
%                                     for lambda_e=1:numel(lambda_e_v)    % lambda_e loop
%                                        for lambda_c=1:numel(lambda_c_v)    % lambda_c loop
%                                            for lambda_h=1:numel(lambda_h_v)    % lambda_h loop
%                                                OScheme = scheme_v{scheme};
%                                                Oeigenmode = eigen_v(eigen);
%                                                OT = T_v(T);
%                                                Odt = dt_v(dt);
%                                                Osigma = sigma_v(sigma);
%                                                Orho = rho_v(rho);
%                                                OC = C_v(C);
%                                                Om = m_v(m);
%                                                Oalpha = alpha_v(alpha);
%                                                Olambda_e = lambda_e_v(lambda_e);
%                                                Olambda_c = lambda_c_v(lambda_c);
%                                                Olambda_h = lambda_h_v(lambda_h);
%                                                %Overbose = 'none';
%                                                im_info = ['Anisotropic filtering options: Scheme=' OScheme ...
%                                                    ', eigenmode=' num2str(Oeigenmode) ', T=' num2str(OT)...
%                                                    ', dt=' num2str(Odt) ', sigma=' num2str(Osigma)...
%                                                    ', rho=' num2str(Orho) ', C=' num2str(OC)...
%                                                    ', m=' num2str(Om) ', alpha=' num2str(Oalpha)...
%                                                    ', lambda_e=' num2str(Olambda_e) ', lambda_c=' num2str(Olambda_c)...
%                                                    ', lambda_h=' num2str(Olambda_h)];
%                                                if strcmp(dim_var,'2d')   % 2d mode
%                                                    fImg = zeros(size(img,1),size(img,2),size(img,3),numel(save_index),class(img));
%                                                    for index=1:numel(save_index)
%                                                         layer = save_index(index);
%                                                         if size(img,3)==1
%                                                             fImg(:,:,1,index) = uint8(CoherenceFilter(img(:,:,:,layer),Options));
%                                                         else
%                                                             fImg(:,:,:,index) = uint8(CoherenceFilter(img(:,:,:,layer),Options));
%                                                         end
%                                                    end
%                                                    file_name = [fn(1:end-4) '_' OScheme '_' num2str(Oeigenmode) sprintf('_%.4d',par_ind) fn(end-3:end)];
%                                                    ib_image2tiff(file_name, fImg, NaN, 'multy', 1, cellstr(['2d ' im_info]));
%                                                elseif strcmp(dim_var,'3d')   % 3d mode
%                                                     fImg = uint8(CoherenceFilter(squeeze(img),Options));
%                                                     fImg = reshape(fImg,size(fImg,1),size(fImg,2),1,size(fImg,3));
%                                                     file_name = [fn(1:end-4) '_' OScheme '_' num2str(Oeigenmode) sprintf('_%.4d',par_ind) fn(end-3:end)];
%                                                     ib_image2tiff(file_name, fImg(:,:,:,save_index(1):save_index(end)), NaN, 'multy', 1, cellstr(['3d ' im_info]));
%                                                end
%                                                par_ind = par_ind + 1;
%                                            end  % end of lambda_h loop
%                                        end  % end of lambda_c loop
%                                     end     % end of lambda_e loop
%                                 end     % end of alpha loop
%                             end     % end of m loop
%                         end     % end of C loop
%                     end     % rnd of rho loop
%                 end     % end of sigma loop
%             end     % end of dt loop
%         end     % end of T loop
%     end     % end of eigen loop
% end     % end of scheme loop

end


function I = fuseImageDescription(I, desc)
% fuse the imagedescription field into an image
% strip desc field
desc = strrep(desc, '3d Anisotropic filtering options: Scheme', '3d Sch');
desc = strrep(desc, '2d Anisotropic filtering options: Scheme', '2d Sch');
desc = strrep(desc, 'eigenmode', 'Eig');
desc = strrep(desc, 'sigma', 'Sig');
desc = strrep(desc, 'alpha', 'al');
desc = strrep(desc, 'lambda_e', 'l_e');
desc = strrep(desc, 'lambda_c', 'l_c');
desc = strrep(desc, 'lambda_h', 'l_h');
commas = strfind(desc, ',');
if numel(commas) > 1 
    text_out = {desc(1:commas(5)); desc(commas(5)+2:commas(9)); desc(commas(9)+2:end)};
else
    text_out = {desc};
end
I = renderText(I, text_out);
end

function I = renderText(I, text)
% Fuse text into an image I
% based on original code by by Davide Di Gloria 
% http://www.mathworks.com/matlabcentral/fileexchange/26940-render-rgb-text-over-rgb-or-grayscale-image
% I=renderText(I, text)
% text -> cell with text

base=uint8(1-logical(imread('chars.bmp')));
table='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890''ì!"£$%&/()=?^è+òàù,.-<\|;:_>ç°§é*@#[]{} ';

text_str = cat(2,text{:});
n = numel(text_str);


coord(2,n)=0;
for i=1:n    
  coord(:,i)= [0 find(table == text_str(i))-1];
end
m = floor(coord(2,:)/26);
coord(1,:) = m*20+1;
coord(2,:) = (coord(2,:)-m*26)*13+1;

model = zeros(20*size(text,1)+size(text,1)*2,size(I,2),size(I,3), class(I));
total_index = 1;
max_int = double(intmax(class(I)));
for text_line = 1:size(text,1)
    for index = 1:numel(text{text_line,:})
        model(20*(text_line-1)+1:20*(text_line-1)+20, (12*index-11):(index*12), :) = imcrop(base,[coord(2,total_index) coord(1,total_index) 11 19])*max_int;
        total_index = total_index + 1;
    end
end 
I2 = zeros(size(model,1),size(I,2),size(I,3),size(I,4),class(I));
for frame = 1:size(I,4)
    I2(:,:,:,frame) = model(:,1:size(I,2));
end
I = cat(1, I, I2);
end


% --- Executes on button press in helpBtn.
function helpBtn_Callback(hObject, eventdata, handles)
help_txt = [
        {'Scheme, the numerical diffusion scheme:'}
        {'R : Rotation Invariant, Standard Discretization (implicit) 5x5 kernel'}
        {'O : Optimized Derivative Kernels'}
        {'I : Implicit Discretization (only works in 2D)'}
        {'S : Standard Discretization'}
        {'N : Non-negativity Discretization'}
		{''}
        {'Eigenmode, an diffusion tensor:'}
        {'0 : Weickerts equation, line like kernel (similar to 3)'}
		{'1 : Weickerts equation, plane like kernel'}
		{'2 : Edge enhancing diffusion (EED) (similar to 4)'}
		{'3 : Coherence-enhancing diffusion (CED) (similar to 0)'}
		{'4 : Hybrid Diffusion With Continuous Switch (HDCS) (similar to 2)'}
        {''}
        {'Verbose: show iterations in the main Matlab window, not for tests'}
        {'T : The total diffusion time, number of iterations'}
        {'dt : Diffusion time stepsize, for H,R,I = 1; for S,N=0.15'}
        {'sigma : Sigma of gaussian smoothing before calculation of the image Hessian'}
        {'rho : Rho gives the sigma of the Gaussian smoothing of the Hessian'}
        {'C : the amplitude of the diffusion smoothing in Weickert equation'}
        {'m : the amplitude of the diffusion smoothing in Weickert equation'}
        {'alpha : the amplitude of the diffusion smoothing in Weickert equation'}
        {'lambda_e : for CED, EED and HDCS eigenmodes, planar structure contrast'}
        {'lambda_c : for CED, EED and HDCS eigenmodes, tubular structure contrast'}
        {'lambda_h : for CED, EED and HDCS eigenmodes, treshold between structure and noise'}
        {''}
        {'Best effective combinations:'}
        {'N,2/4 or 1,T=5,dt=0.15,Sigma=5,rho=1'}
        {'O,1,T=5,dt=1,Sigma=5,rho=1'}
        {'R,2/4,T=5,dt=1,Sigma=5,rho=1'}
        {'S,2 or 4,T=5,dt=0.15,Sigma=5,rho=1'}
        ];
helpdlg(help_txt,'Explanation of parameters');
end


% --- Executes when entered data in editable cell(s) in optionsTable1.
function optionsTable1_CellEditCallback(hObject, eventdata, handles)
data = get(handles.optionsTable1,'Data');
handles.anDiffOptions.Scheme = data{1};
handles.anDiffOptions.eigenmode = data{2};
handles.anDiffOptions.verbose = data{3};
guidata(hObject, handles);
end


% --- Executes when entered data in editable cell(s) in optionsTable2.
function optionsTable2_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to optionsTable2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
row_names = get(handles.optionsTable2,'Rowname');
index = eventdata.Indices;
handles.anDiffOptions.(row_names{index(1)}) = {eventdata.EditData};
guidata(hObject, handles);
end


% --- Executes on button press in saveResCheck.
function saveResCheck_Callback(hObject, eventdata, handles)
val = get(handles.saveResCheck,'Value');
if val
    set(handles.saveFramesTxt,'Visible','on');
    set(handles.framesEdit,'Visible','on');
else
    set(handles.saveFramesTxt,'Visible','off');
    set(handles.framesEdit,'Visible','off');
end
end


% --- Executes on button press in radio3d.
function radio3d_Callback(hObject, eventdata, handles)
val = get(handles.radio3d,'Value');
if val  % 3d mode
    handles.dimension = '3d';
else
    handles.dimension = '2d';
    set(handles.radio2d,'Value',1);
end
guidata(hObject, handles);
end

% --- Executes on button press in radio2d.
function radio2d_Callback(hObject, eventdata, handles)
val = get(handles.radio2d,'Value');
if val  % 2d mode
    handles.dimension = '2d';
else
    handles.dimension = '3d';
    set(handles.radio3d,'Value',1);
end
guidata(hObject, handles);
end
