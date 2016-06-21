function varargout = ib_importOmero(varargin)
% function varargout = ib_importOmero(varargin)
% ib_importOmero function is responsible for a dialog to advanced opening images from OMERO servers.
%
% ib_importOmero contains MATLAB code for ib_importOmero.fig

% Last Modified by GUIDE v2.5 22-Apr-2013 15:50:06

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
                   'gui_OpeningFcn', @ib_importOmero_OpeningFcn, ...
                   'gui_OutputFcn',  @ib_importOmero_OutputFcn, ...
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
% End initialization code - DO NOT EDIT
end

% --- Executes just before ib_importOmero is made visible.
function ib_importOmero_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_importOmero (see VARARGIN)

handles.h = varargin{1};    % handles of im_browser

% Choose default command line output for ib_importOmero
handles.output = NaN;

result = ib_omeroLoginDlg(handles.h.preferences.Font);
if isempty(fieldnames(result)); 
    cancelBtn_Callback(handles.cancelBtn, eventdata, handles);
    return;
end;

%handles.client = omero.client(result.server, result.port);
handles.client = connectOmero(result.server, result.port);
try
    handles.session = handles.client.createSession(result.username, result.password);
catch err
    if isa(err.ExceptionObject, 'Glacier2.PermissionDeniedException')
        handles.client.closeSession();
        errordlg('Wrong username or password!','Login error...','modal');
        cancelBtn_Callback(handles.cancelBtn, eventdata, handles);
        return;
    end

end

% update font and size
if get(handles.text1, 'fontsize') ~= handles.h.preferences.Font.FontSize ...
        || ~strcmp(get(handles.text1, 'fontname'), handles.h.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_importOmero, handles.h.preferences.Font);
end

% resize all elements x1.25 times for macOS
mib_rescaleWidgets(handles.ib_importOmero);

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

% update the project list
handles = updateProjectTable(handles);

% Update handles structure
guidata(hObject, handles);

% Make the GUI modal
% set(handles.ib_importOmero,'WindowStyle','modal');

% UIWAIT makes ib_importOmero wait for user response (see UIRESUME)
uiwait(handles.ib_importOmero);
end

% --- Outputs from this function are returned to the command line.
function varargout = ib_importOmero_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.ib_importOmero);
end

function handles = updateProjectTable(handles)
% update project list 
proxy = handles.session.getContainerService();
param = omero.sys.ParametersI();
userId = handles.session.getAdminService().getEventContext().userId; %id of the user.
param.exp(omero.rtypes.rlong(userId));
projectsList = proxy.loadContainerHierarchy('omero.model.Project', [], param);

for j = 0:projectsList.size()-1
    p = projectsList.get(j);
    list{j+1,1} = char(p.getName.getValue()); %#ok<AGROW>
    list{j+1,2} = double(p.getId.getValue()); %#ok<AGROW>
end
set(handles.projectTable,'data',list);
set(handles.imageTable,'data',[]);

handles.projectId = list{1,2};
handles.datasetId = NaN;
handles.imageId = NaN;
guidata(handles.ib_importOmero, handles);
updateDatasets('project', handles);
end

% --- Executes on button press in continueBtn.
function continueBtn_Callback(hObject, eventdata, handles)
% hObject    handle to continueBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wb = waitbar(0,'Please wait...','Name','OMERO Import');
ids = java.util.ArrayList();
imageId = java.lang.Long(handles.imageId);
ids.add(imageId); %add the id of the image
proxy = handles.session.getContainerService();
list = proxy.getImages('omero.model.Image', ids, omero.sys.ParametersI());
image = list.get(0);
pixelsList = image.copyPixels();

for k = 0:pixelsList.size()-1,
    pixels = pixelsList.get(k);
    pixelsId = pixels.getId().getValue();
    store = handles.session.createRawPixelsStore();
    store.setPixelsId(pixelsId, false); %Indicate the pixels set you are working on
    
    sizeX = pixels.getSizeX().getValue();
    sizeY = pixels.getSizeY().getValue();
    sizeZ = pixels.getSizeZ().getValue();
    sizeT = pixels.getSizeT().getValue();
    sizeC = pixels.getSizeC().getValue();
    
    if ~isempty(pixels.getPhysicalSizeX)
        pixSizeX = pixels.getPhysicalSizeX.getValue();
        pixSizeY = pixels.getPhysicalSizeY.getValue();
    else
        pixSizeX = 1;
        pixSizeY = 1;
    end
    
    if ~isempty(pixels.getPhysicalSizeZ)
        pixSizeZ = pixels.getPhysicalSizeZ.getValue();
    else
        pixSizeZ = 1;
    end
    if pixSizeZ == Inf; pixSizeZ = pixSizeX; end;
    pixSizeT = pixels.getTimeIncrement;
    if isempty(pixSizeT)
        pixSizeT = 1;
    else
        pixSizeT = pixSizeT.getValue();
    end

    minX = str2double(get(handles.minX,'string'))-1; 
    stepX = str2double(get(handles.stepX,'string'));
    maxX = str2double(get(handles.maxX,'string'))-1;
    minY = str2double(get(handles.minY,'string'))-1; 
    stepY = str2double(get(handles.stepY,'string'));
    maxY = str2double(get(handles.maxY,'string'))-1;
    minC = str2double(get(handles.minC,'string'))-1; 
    stepC = str2double(get(handles.stepC,'string'));
    maxC = str2double(get(handles.maxC,'string'))-1;
    minZ = str2double(get(handles.minZ,'string'))-1; 
    stepZ = str2double(get(handles.stepZ,'string'));
    maxZ = str2double(get(handles.maxZ,'string'))-1;
    minT = str2double(get(handles.minT,'string'))-1; 
    stepT = str2double(get(handles.stepT,'string'));
    maxT = str2double(get(handles.maxT,'string'))-1;
    
    width = numel(minX:stepX:maxX);
    height = numel(minY:stepY:maxY);
    colors = numel(minC:stepC:maxC);
    zThick = numel(minZ:stepZ:maxZ);
    tThick = numel(minT:stepT:maxT);

    
    waitbar(0.05,wb);
    % get image class
    if store.getByteWidth == 1
        outputClass = 'uint8';
    elseif store.getByteWidth == 2
        outputClass = 'uint16';
    else
        outputClass = 'uint32';
    end
    
    if sizeZ > 1 && sizeT > 1
        button = questdlg(sprintf('This is 5D dataset.\nWould you like to load Z-stacks or T-stacks?'),...
            '5D dataset','z-stacks','t-stacks','cancel','z-stacks');
        if strcmp(button,'cancel'); cancelBtn_Callback(handles.cancelBtn, eventdata, handles); return; end;
        
        if strcmp(button,'z-stacks')
            %answer = inputdlg(sprintf('Please enter the T-value (1-%d):', sizeT),'Time value',1,{'1'});
            answer = mib_inputdlg(handles.h, sprintf('Please enter the T-value (1-%d):', sizeT),'Time value','1');
            if isempty(answer); cancelBtn_Callback(handles.cancelBtn, eventdata, handles); return; end;
            minT = str2double(answer{1})-1;
            maxT = str2double(answer{1})-1;
            tThick = 1;
            imgOut = zeros([height, width, colors, zThick], outputClass);  
        end
        
        if strcmp(button,'t-stacks')
            %answer = inputdlg(sprintf('Please enter the Z-value (1-%d):', sizeZ),'Z-stack value',1,{'1'});
            answer = mib_inputdlg(handles.h, sprintf('Please enter the Z-value (1-%d):', sizeZ),'Z-stack value','1');
            if isempty(answer); cancelBtn_Callback(handles.cancelBtn, eventdata, handles); return; end;
            minZ = str2double(answer{1})-1;
            maxZ = str2double(answer{1})-1;
            zThick = 1;
            imgOut = zeros([height, width, colors, tThick], outputClass);  
        end
    else
        imgOut = zeros([height, width, colors, max([zThick, tThick])], outputClass);    
    end
    
    tic;
    maxVal = colors*zThick*tThick;
    counter = 0;
    zIndex = 1;
    for z = minZ:stepZ:maxZ
        tIndex = 1;
        for t = minT:stepT:maxT
            cIndex = 1;
            for c = minC:stepC:maxC
                tile = store.getTile(z, c, t, minX, minY, width, height);
                
                tPlane = typecast(tile, outputClass);
                tPlane = reshape(tPlane, [width, height])';
                tPlane = swapbytes(tPlane); 
                if tThick < zThick
                    imgOut(:,:,cIndex,zIndex) = swapbytes(tPlane);
                else
                    imgOut(:,:,cIndex,tIndex) = swapbytes(tPlane);
                end
                cIndex = cIndex + 1;
            end
            tIndex = tIndex + 1;
            counter = counter + colors;
            waitbar(counter/maxVal,wb);
        end
        zIndex = zIndex + 1;
    end
    t1=toc;
    sprintf('Elapsed time is %f seconds, transfer rate: %f MB/sec', t1, numel(imgOut)/1000000/t1)
end
store.close();
delete(wb);

% metadataService = handles.session.getMetadataService();
% annotationTypes = java.util.ArrayList();
% %annotationTypes.add('ome.model.annotations.TagAnnotation');
% % Unused
% annotatorIds = java.util.ArrayList();
% parameters = omero.sys.Parameters();
%     
% % retrieve the annotations linked to images, for datasets use: 'omero.model.Dataset'
% annotations = metadataService.loadAnnotations('Image', ids, annotationTypes, annotatorIds, parameters);
% annotations = metadataService.loadAnnotations('Image', ids);
% for i=1:annotations.size
%     ArrList = annotations.get(imageId);
%     for j=1:ArrList.size
%         tagValue = ArrList.get(j-1).getTextValue().getValue();
%         txt = ['TagVale: ' char(tagValue)];
%         disp(txt);
%     end
% end

if isfield(handles, 'client')
    handles.client.closeSession();
end
img_info = containers.Map;
if size(imgOut,3) > 1
    img_info('ColorType') = 'truecolor';
else
    img_info('ColorType') = 'grayscale';
end
img_info('ImageDescription') = '';
img_info('Height') = sizeY;
img_info('Width') = sizeX;
img_info('Stacks') = size(imgOut,4);
%img_info('XResolution') = 1;
%img_info('YResolution') = 1;
%img_info('ResolutionUnit') = 'Inch';
img_info('Filename') = 'omero.tif';

handles.h.Img{handles.h.Id}.I.pixSize.x = pixSizeX*stepX;
handles.h.Img{handles.h.Id}.I.pixSize.y = pixSizeY*stepY;
handles.h.Img{handles.h.Id}.I.pixSize.z = pixSizeZ*stepZ;
handles.h.Img{handles.h.Id}.I.pixSize.t = pixSizeT*stepT;

handles.h = handles.h.Img{handles.h.Id}.I.replaceDataset(imgOut, handles.h, img_info);

handles.output = handles.h;
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_importOmero);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
if isfield(handles, 'client')
    handles.client.closeSession();
end

handles.output = NaN;
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.ib_importOmero);
end


% --- Executes when selected cell(s) is changed in projectTable.
function projectTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to projectTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.projectTable, 'data');
handles.projectId = data{eventdata.Indices(1,1), 2};
handles.datasetId = NaN;
handles.imageId = NaN;
updateDatasets('project', handles);
end

% --- Executes when selected cell(s) is changed in datasetTable.
function datasetTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to datasetTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.datasetTable, 'data');
if isempty(data); return; end;
if isempty(eventdata.Indices); 
    Indices(1,1) = 1; 
else
    Indices = eventdata.Indices;
end;
handles.datasetId = data{Indices(1,1), 2};
handles.imageId = NaN;
updateDatasets('dataset', handles);
end

% --- Executes when selected cell(s) is changed in imageTable.
function imageTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to imageTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.imageTable, 'data');
if isempty(data); return; end;
if isempty(eventdata.Indices); 
    Indices(1,1) = 1; 
else
    Indices = eventdata.Indices; 
end;
handles.imageId = data{Indices(1,1), 2};
updateDatasets('image', handles)
end


function updateDatasets(tableId, handles)
ids = java.util.ArrayList();
proxy = handles.session.getContainerService();
switch tableId
    case 'project'
        projectId = java.lang.Long(handles.projectId);
        ids.add(projectId); %add the id of the dataset.
        param = omero.sys.ParametersI();
        userId = handles.session.getAdminService().getEventContext().userId; %id of the user.
        param.exp(omero.rtypes.rlong(userId));
        list = proxy.loadContainerHierarchy('omero.model.Project', ids, param);
        dataset = list.get(0);
        datasetList = dataset.linkedDatasetList; % The datasets in the project.
        if datasetList.size() > 0
            for id=0:datasetList.size()-1
                dataset = datasetList.get(id);
                data{id+1,1} = char(dataset.getName.getValue()); %#ok<AGROW>
                data{id+1,2} = double(dataset.getId.getValue()); %#ok<AGROW>
            end
        else
            data = [];
        end
        set(handles.datasetTable,'data',data);
        set(handles.imageTable,'data',[]);
    case 'dataset'
        datasetId = java.lang.Long(handles.datasetId);
        ids.add(datasetId); %add the id of the dataset.
        param = omero.sys.ParametersI();
        param.leaves(); % indicate to load the images.
        list = proxy.loadContainerHierarchy('omero.model.Dataset', ids, param);
        dataset = list.get(0);
        imageList = dataset.linkedImageList; % The images in the dataset.
        if imageList.size() > 0
            for id=0:imageList.size()-1
                image = imageList.get(id);
                data{id+1,1} = char(image.getName.getValue()); %#ok<AGROW>
                data{id+1,2} = double(image.getId.getValue()); %#ok<AGROW>
            end
        else
            data = [];
        end
        set(handles.imageTable,'data',data);
    case 'image'
        imageId = java.lang.Long(handles.imageId);
        ids.add(imageId); %add the id of the image
        proxy = handles.session.getContainerService();
        list = proxy.getImages('omero.model.Image', ids, omero.sys.ParametersI());
        image = list.get(0);
        pixelsList = image.copyPixels();
        for k = 0:pixelsList.size()-1,
            pixels = pixelsList.get(k);
            sizeZ = pixels.getSizeZ().getValue(); % The number of z-sections.
            sizeT = pixels.getSizeT().getValue(); % The number of timepoints.
            sizeC = pixels.getSizeC().getValue(); % The number of channels.
            sizeX = pixels.getSizeX().getValue(); % The number of pixels along the X-axis.
            sizeY = pixels.getSizeY().getValue(); % The number of pixels along the Y-axis.
            pixelsId = pixels.getId().getValue();
            data(:,1) = {'Width','Height', 'Colors', 'Z-sections', 'Timepoints'};
            data(:,2) = {sizeX, sizeY, sizeC, sizeZ, sizeT};
            set(handles.imageParametersTable,'data', data);
            
            set(handles.maxX,'String', num2str(sizeX));
            set(handles.maxY,'String', num2str(sizeY));
            set(handles.maxC,'String', num2str(sizeC));
            set(handles.maxZ,'String', num2str(sizeZ));
            set(handles.maxT,'String', num2str(sizeT));
        end
        
        store = handles.session.createThumbnailStore();
        map = store.getThumbnailByLongestSideSet(omero.rtypes.rint(150), java.util.Arrays.asList(java.lang.Long(pixelsId)));
        %Display the thumbnail;
        collection = map.values();
        i = collection.iterator();
        %while (i.hasNext())
            stream = java.io.ByteArrayInputStream(i.next());
            image = javax.imageio.ImageIO.read(stream);
            stream.close();
            img = JavaImageToMatlab(image);
            imagesc(img, 'parent', handles.thumbView);
            set(handles.thumbView,'dataAspectRatio',[1 1 1]);
            set(handles.thumbView, 'xtick', []);
            set(handles.thumbView, 'ytick', []);
        %end
        
end
guidata(handles.ib_importOmero, handles);
end
