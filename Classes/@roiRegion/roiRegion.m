classdef roiRegion < matlab.mixin.Copyable
    % @type roiRegion class is resposnible to keep regions of interest (ROI)
    
    % Copyright (C) 21.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
	% 
	% This program is free software; you can redistribute it and/or
	% modify it under the terms of the GNU General Public License
	% as published by the Free Software Foundation; either version 2
	% of the License, or (at your option) any later version.
	%
	% Updates
	% 
    %
    % rewritten from the old roiRegion class utilizing technique and code
    % from Image Measurement Utility written by Jan Neggers, 
    % Eindhoven Univeristy of Technology.
    % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
    
    properties (SetAccess = public, GetAccess = public)
        roi
        % a structure with ROI data:
        % - roi.pos - coordinates of ROIs
        % - roi.type - ROIs type: 'imline'
        % - roi.imroi - handle to imroi Matlab class
        % - roi.cb - array of callbacks to 'addNewPositionCallback' function
        
        Data
        % a new structure for ROI data
        %      .Data.label  - string with a label
        %      .Data.type   - type, string: 'imrect', 'imellipse', 'impoly', 'imfreehand'
        %      .Data.X      - X-coordinates of points
        %      .Data.Y      - Y-coordinates of points
        %      .Data.orientation - orientaion of the ROI: 1-'xz', 2-'yz', 4-'yx'
        
        Options
        % a structure with show options
        %      .Options.marker = 's'; - style 1 for markers
        %      .Options.markersize = '10'; - size of markers
        %      .Options.linestyle = '-'; - style 1 for lines
        %      .Options.linewidth = '2' ; - width for lines
        %      .Options.color = 'w';   - color style
        %      .Options.textcolorfg = 'y';  - text color
        %      .Options.textcolorbg = 'none';  - color for text background
        %      .Options.fontsize = '14';  - size of the font
        %      .Options.showMarkers = 1;
        %      .Options.showLines = 1;
        %      .Options.showText = 0;
        
        hImg
        % handle to imageData class
    end
    
    methods
        function obj = roiRegion(hImg)
            % function obj = roiRegion(hImageData)
            % Constructor for the @type roiRegion class.
            %
            % Constructor for the roiRegion class. Create a new instance of
            % the class with default parameters
            %
            % Parameters:
            % hImg: - handle to imageData class
            %
            % Return values:
            % obj - instance of the @type roiRegion class.
            
            obj.hImg = hImg;
            obj.clearContents();
        end
        
        function clearContents(obj)
            % function clearContents(obj)
            % Set all elements of the class to default values
            %
            % Parameters:
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code roiRegion.clearContents(); @endcode
            % @code clearContents(obj); // Call within the class @endcode
            
            obj.setDefaultOptions();   %  set Options to default state
            obj.clearData();  % clear Data structure
        end
        
        function clearData(obj)
            % function clearData(obj)
            % Removes all values of the Data structures
            %
            % Parameters:
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code roiRegion.clearData(); @endcode
            % @code clearData(obj); // Call within the class @endcode
            obj.Data = [];
            
            obj.Data.label = [];
            obj.Data.type = [];
            obj.Data.X = [];
            obj.Data.Y = [];
            obj.Data.orientation = [];
            
            obj.roi.pos = [];   % real positions of rois
            obj.roi.type = [];  % roi type: rect, ellipse, poly, lasso
            obj.roi.imroi = []; % handle of the currently shown rois
            obj.roi.cb = [];    % handles to addNewPositionCallback function
        end
        
        function index = findIndexByLabel(obj, labelStr)
            % function index = findIndexByLabel(obj, labelStr)
            % Finds index of a ROI that has Data.label == labelStr
            %
            % Parameters:
            % labelStr: label string
            %
            % Return values:
            % index: index of the ROI that has the label
            
            %|
            % @b Examples:
            % @code handles.Img{handles.Id}.I.hROI.findIndexByLabel('ROI 1'); // Return index of the ROI that has 'ROI 1' label @endcode
            if strcmp(labelStr, 'All')
                [~, index] = obj.getNumberOfROI(obj.hImg.orientation);
            else
                index = find(ismember([obj.Data.label],labelStr));
            end
        end
        
        function addROI(obj, handles, type, index, coordinates, noPoints)
            % function addROI(obj, handles, type, index, coordinates, noPoints)
            % Adds ROI
            %
            % Parameters:
            % handles: handles structure of im_browser
            % type: type of ROI to add: "imrect", "imellipse", "impoly",
            % "imfreehand"
            % index: [@em optional] index of the ROI. If not empty will
            % allow to modify a ROI with the provided index
            % coordinates: [@em optional] coordinates for placing the ROI, can be @b []
            % noPoints: [@ optional] noPoints for the @em impoly type, @em
            % dafault = 5
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code handles.Img{handles.Id}.I.hROI.addROI(handles, 'imrect'); // Add a new imrect ROI @endcode
            % @code handles.Img{handles.Id}.I.hROI.addROI(handles, [], 3); // Modify the 3rd ROI @endcode
            
            if nargin < 6; noPoints = 5; end;
            if nargin < 5; coordinates = []; end;
            if nargin < 4; index = obj.getNumberOfROI(0)+1; end;
            
            if isempty(index);
                index = obj.getNumberOfROI(0)+1;
            elseif index <= obj.getNumberOfROI(0)
                type = cell2mat(obj.Data(index).type);
            end;
            
            switch type
                case 'imrect'
                    obj.imrectFun(handles, index, coordinates);
                case 'imellipse'
                    obj.imellipseFun(handles, index, coordinates);
                case 'impoly'
                    obj.impolyFun(handles, index, coordinates, noPoints);
                case 'imfreehand'
                    obj.imfreehandFun(handles, index);
            end
        end
        
        
        
        function imfreehandFun(obj, handles, index)
            % function imfreehandFun(obj, handles, index)
            % Adds impoly type of ROI using imfreehand tool
            %
            % Parameters:
            % handles: handles structure of im_browser
            % index: index of the ROI. If not empty will
            % allow to modify a ROI with the provided index
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code handles.Img{handles.Id}.I.hROI.imfreehandFun(handles, 5); // Add a new impoly ROI to position 5 @endcode
            
            position = obj.drawROI(handles, 'imfreehand');
            % detect Cancel due to press of the Escape button
            if isempty(position);
                return;
            end;
            
            prompt = sprintf('There are %d vertices in the line. Please enter a coefficient to decrease it if needed; any in range 1-%d\n\nIf coefficient is 2, the number of vertices will be reduced in 2 times', size(position,1), size(position,1));
            title = 'Convert to polyline';
            answer = mib_inputdlg(NaN,prompt,title,'10');
            if isempty(answer); return; end;
            
            coef = round(str2double(cell2mat(answer)));
            if coef >= size(position,1)
                coef = 1;
            end;
            position = position(1:coef:end,:);
            
            % store the measurement
            newData.label = cellstr(sprintf('%d', index));
            newData.type = cellstr('impoly');
            newData.X = position(:,1);
            newData.Y = position(:,2);
            newData.orientation = obj.hImg.orientation;
            
            obj.storeROI(newData, index);
            % call DistancePolyFun to do calculations
            obj.impolyFun(handles, index);
        end
        
        function impolyFun(obj, handles, index, coordinates, noPoints)
            % function imrectFun(obj, handles, index, coordinates, noPoints)
            % Adds impoly type of ROI
            %
            % Parameters:
            % handles: handles structure of im_browser
            % index: index of the ROI. If not empty will
            % allow to modify a ROI with the provided index
            % coordinates: [@em optional] coordinates for placing the ROI
            % manually
            % noPoints: [@em optional] number of points in the polyline
            % when adding a new ROI
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code handles.Img{handles.Id}.I.hROI.impolyFun(handles, [], [], 5); // Add a new impoly ROI with 5 vertices @endcode
            % @code handles.Img{handles.Id}.I.hROI.impolyFun(handles, 5, [100, 150; 250, 350; 50, 150]); // Add impoly ROI to position 5; with specified vertices @endcode
            
            if nargin < 5; noPoints = 5; end;
            if nargin < 4; coordinates = []; end;
            screenPos = 1;
            pos = [];
            
            if index > obj.getNumberOfROI(0)  % add a new ROI
                if isempty(coordinates)     % interactive mode
                    x = zeros(1,noPoints);
                    y = zeros(1,noPoints);
                    set(handles.imageAxes, 'NextPlot','add');
                    for k = 1:noPoints
                        [x(k),y(k),~,u(k),v(k)] = getClickPoint(handles);
                        h(:,k) = plot(handles.imageAxes, u(k),v(k),'r+',u(k),v(k),'bo');
                    end
                    delete(h);
                    set(handles.imageAxes, 'NextPlot','replace');
                    pos = [x ; y ].';
                    [pos, screenPos] = obj.drawROI(handles, 'impoly', pos);
                    if ~isempty(pos)
                        pos = ceil(pos);
                        position = pos;
                    end
                else  % manual mode
                    pos = 1;
                    position = coordinates;
                end
            else
                tempData = obj.Data(index);     % store the current state
                obj.removeROI(index);  % remove ROI
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                x = tempData.X;
                y = tempData.Y;
                pos(:,1) = x;
                pos(:,2) = y;
                [pos, screenPos] = obj.drawROI(handles, 'impoly', pos);
                if ~isempty(pos)
                    pos = ceil(pos);
                    position = pos;
                end
            end
            
            % detect Cancel due to press of the Escape button
            if isempty(screenPos) || isempty(pos);
                if exist('tempData','var')
                    obj.storeROI(tempData, index);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            X = position(:,1);
            Y = position(:,2);
            
            % store the measurement
            newData.label = cellstr(sprintf('%d', index));
            newData.type = cellstr('impoly');
            newData.X = X;
            newData.Y = Y;
            newData.orientation = obj.hImg.orientation;
            
            obj.storeROI(newData, index);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            
        end
        
        function imrectFun(obj, handles, index, coordinates)
            % function imrectFun(obj, handles, index, coordinates)
            % Adds imrect type of ROI
            %
            % Parameters:
            % handles: handles structure of im_browser
            % index: index of the ROI. If not empty will
            % allow to modify a ROI with the provided index
            % coordinates: [@em optional] coordinates for placing the ROI
            % manually
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code handles.Img{handles.Id}.I.hROI.imrectFun(handles, 5); // Add a new imrect ROI to position 5 @endcode
            % @code handles.Img{handles.Id}.I.hROI.imrectFun(handles, 5, [100, 150, 250, 350]); // Add a new imrect ROI to position 5; x1=100, x2=150, width=250; height=350 @endcode
            
            if nargin < 4; coordinates = []; end;
            screenPos = 1;
            pos = [];
            if index > obj.getNumberOfROI(0)  % add a new ROI
                if isempty(coordinates)     % interactive mode
                    % select two points
                    set(handles.imageAxes, 'NextPlot','add');
                    [x,y,z,u,v] = getClickPoint(handles);
                    h = plot(handles.imageAxes,u,v,'r+',u,v,'bo','markersize',10);
                    [x(2),y(2),z(2),u(2),v(2)] = getClickPoint(handles); %#ok<NASGU>
                    delete(h);
                    set(handles.imageAxes, 'NextPlot','replace');
                    % get position as [Xmin, Y,min, Width, Height]
                    pos(:,1) = [min(x), max(x)];
                    pos(:,2) = [min(y), max(y)];
                    [pos, screenPos] = obj.drawROI(handles, 'imrect', pos); % position returned as [x1 y1 width height]
                    if ~isempty(pos)
                        pos = ceil(pos);
                        position(:,1) = [pos(1), pos(1)+pos(3)-1];
                        position(:,2) = [pos(2), pos(2)+pos(4)-1];
                    end
                else  % manual mode
                    pos = 1;
                    position(:,1) = [coordinates(1) coordinates(1)+coordinates(3)-1];
                    position(:,2) = [coordinates(2) coordinates(2)+coordinates(4)-1];
                end
            else
                tempData = obj.Data(index);     % store the current state
                obj.removeROI(index);  % remove ROI
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                x = tempData.X;
                y = tempData.Y;
                pos(:,1) = [min(x)-1, max(x)];
                pos(:,2) = [min(y)-1, max(y)];
                [pos, screenPos] = obj.drawROI(handles, 'imrect', pos);
                if ~isempty(pos)
                    pos = ceil(pos);
                    position(:,1) = [pos(1), pos(1)+pos(3)-1];
                    position(:,2) = [pos(2), pos(2)+pos(4)-1];
                end
            end
            
            % detect Cancel due to press of the Escape button
            if isempty(screenPos) || isempty(pos);
                if exist('tempData','var')
                    obj.storeROI(tempData, index);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            X = position(:,1);
            Y = position(:,2);
            
            % store the measurement
            newData.label = cellstr(sprintf('%d', index));
            newData.type = cellstr('imrect');
            newData.X = X;
            newData.Y = Y;
            newData.orientation = obj.hImg.orientation;
            
            obj.storeROI(newData, index);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        end
        
        function imellipseFun(obj, handles, index, coordinates)
            % function imellipseFun(obj, handles, index, coordinates)
            % Adds imellipse type of ROI
            %
            % Parameters:
            % handles: handles structure of im_browser
            % index: index of the ROI. If not empty will
            % allow to modify a ROI with the provided index
            % coordinates: [@em optional] coordinates for placing the ROI
            % manually, [x-center y-center, radiusX, radiusY]
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code handles.Img{handles.Id}.I.hROI.imellipseFun(handles, 5); // Add a new imellipse ROI to position 5 @endcode
            % @code handles.Img{handles.Id}.I.hROI.imellipseFun(handles, 5, [100, 150, 250, 350]); // Add a new imellipse ROI to position 5; x1=100, x2=150, radiusX=250; radiusY=350 @endcode
            
            if nargin < 4; coordinates = []; end;
            screenPos = 1;
            pos = [];
            if index > obj.getNumberOfROI(0)  % add a new ROI
                if isempty(coordinates)     % interactive mode
                    % select two points
                    set(handles.imageAxes, 'NextPlot','add');
                    [x,y,z,u,v] = getClickPoint(handles);
                    h = plot(handles.imageAxes,u,v,'r+',u,v,'bo','markersize',10);
                    [x(2),y(2),z(2),u(2),v(2)] = getClickPoint(handles); %#ok<NASGU>
                    delete(h);
                    set(handles.imageAxes, 'NextPlot','replace');
                    % calculate the box around the circle
                    A = diff(x);
                    B = diff(y);
                    R = hypot(A,B);
                    P = [x(1)-R y(1)-R 2*R 2*R];
                    
                    pos = obj.drawROI(handles, 'imellipse', P);
                else  % manual mode
                    pos = 1;
                    instant = 1;
                    % shift coordinates from center to corner
                    coordinates(1) = coordinates(1) - coordinates(3)/2;
                    coordinates(2) = coordinates(2) - coordinates(4)/2;
                    pos = obj.drawROI(handles, 'imellipse', coordinates, instant);  % [xmin ymin width height]
                end
                if ~isempty(pos)
                    position = pos;
                end
            else
                tempData = obj.Data(index);     % store the current state
                obj.removeROI(index);  % remove ROI
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                x = tempData.X;
                y = tempData.Y;
                pos(1) = min(x);
                pos(2) = min(y);
                pos(3) = max(x)-min(x);
                pos(4) = max(y)-min(y);
                [pos, screenPos] = obj.drawROI(handles, 'imellipse', pos);
                if ~isempty(pos)
                    position = pos;
                    screenPos = 1;
                end
            end
            
            % detect Cancel due to press of the Escape button
            if isempty(screenPos) || isempty(pos);
                if exist('tempData','var')
                    obj.storeROI(tempData, index);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            X = position(:,1);
            Y = position(:,2);
            
            % store the measurement
            newData.label = cellstr(sprintf('%d', index));
            newData.type = cellstr('imellipse');
            newData.X = X;
            newData.Y = Y;
            newData.orientation = obj.hImg.orientation;
            
            obj.storeROI(newData, index);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
        end
        
        function storeROI(obj, newData, index)
            % function storeROI(obj, newData, index)
            % add or insert ROI information into the obj.Data structure
            %
            % Parameters:
            % newData: structure of a new measurement to insert. Fields
            % should match those of obj.Data
            % n: [@em optional] position where to add the measurement, @em default - number of measurements in obj.Data + 1
            %
            % Return values:
            %
            
            %|
            % @b Examples:
            % @code roiRegion.storeROI(newData, 5); insert ROI to position 5 @endcode
            % @code storeROI(obj, newData); // Call within the class. Add a ROI @endcode
            if nargin < 3; index = obj.getNumberOfROI(0) + 1; end;
            
            noROI = obj.getNumberOfROI(0);
            if index <= noROI  % insert ROI
                obj.Data(index+1:numel(obj.Data)+1)  = obj.Data(index:numel(obj.Data));
                obj.Data(index) = newData;
                %newNs = num2cell(1:numel(obj.Data));
                %[obj.Data(1:numel(obj.Data)).n] = newNs{:};
            else                    % add noROI
                obj.Data(index) = newData;
            end
        end
        
        function removeROI(obj, index)
            % removeROI(obj, index)
            % Remove ROI(s) from the class
            %
            % Parameters:
            % index: [optional], an index of the measurement point to
            % remove, when empty or zero - removes all ROIs
            %
            % Return values:
            %
            
            %|
            % @b Examples
            % @code Measure.removeROI(); // remove all ROIs @endcode
            % @code removeROI(obj, 5); // Call within the class; remove 5th ROI @endcode
            
            if nargin < 2
                index = 0;
            end
            if isempty(index); index = 0; end;
            
            if index == 0   % remove all measurements
                obj.clearData();
            else            % remove a single measurement
                if numel(index) == obj.getNumberOfROI(0);
                    obj.clearData();    % situation that is equal to delete all
                else
                    obj.Data(index) = [];
                    %newNs = num2cell(1:numel(obj.Data));
                    %[obj.Data(1:numel(obj.Data)).n] = newNs{:};
                end;
            end
        end
        
        function [number, indices] = getNumberOfROI(obj, orientation)
            % [number, indices] = getNumberOfROI(obj, orientation)
            % Get number of stored ROI
            %
            % Parameters:
            % orientation: [@em optional] defines orienation, 1-'xz',
            % 2-'yz', 4-'yx', 0-get all. When omitted returns number of
            % ROIs for the shown orientation
            %
            % Return values:
            % number:  number of ROIs
            % indices:  indices of ROIs
            
            %|
            % @b Examples
            % @code number = roiRegion.getNumberOfROI(4); // get the total number of ROIs for the XY orientation @endcode
            % @code number = getNumberOfROI(obj); // Call within the class; get the total number @endcode
            
            if nargin < 2; orientation = obj.hImg.orientation; end;
            indices = [];
            if orientation == 0     % return total number of ROIs
                if isempty(obj.Data(1).orientation)
                    number = 0;
                else
                    number = numel(obj.Data);
                    indices = 1:number;
                end
            else
                indices = find(ismember([obj.Data.orientation],orientation));
                number = numel(indices);
            end
        end
        
        function setDefaultOptions(obj)
            % function setDefaultOptions(obj)
            % Set all values of the Options structure of the class to default values
            %
            % Parameters:
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code roiRegion.setDefaultOptions(); @endcode
            % @code setDefaultOptions(obj); // Call within the class @endcode
            
            obj.Options.marker = 's';
            obj.Options.markersize = '6';
            obj.Options.linestyle = '-';
            obj.Options.linewidth = '2' ;
            obj.Options.color = 'y';
            obj.Options.textcolorfg = 'y';
            obj.Options.textcolorbg = 'none';
            obj.Options.fontsize = '12';
            obj.Options.showMarkers = 1;
            obj.Options.showLines = 1;
            obj.Options.showText = 1;
        end
        
        function updateOptions(obj)
            % function updateOptions(obj)
            % Update the Options structure of the class
            %
            % Parameters:
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code handles.Img{handles.Id}.I.hROI.updateOptions(); @endcode
            % @code updateOptions(obj); // Call within the class @endcode
            
            prompt={...
                sprintf('Marker Style\n( + o * . x s d ^ v > < p h )'),...
                'Marker Size',...
                sprintf('Line Style\n(-   --   :   -. )'),...
                'Line Width',...
                sprintf('Color\n( r  g  b  c  m  y  k  w none)'),...
                'Text Foreground Color',...
                'Text Background Color',...
                'Text Fontsize'};
            name='ROI Options';
            numlines=1;
            
            O = obj.Options;
            O = rmfield(O, 'showMarkers');
            O = rmfield(O, 'showLines');
            O = rmfield(O, 'showText');
            
            fields = fieldnames(O);
            n = length(fields);
            
            % builde the default answer from the options structure
            for k = 1:n
                defaultanswer{k} = O.(fields{k}); %#ok<AGROW>
                if ~ischar(defaultanswer{k});
                    defaultanswer{k} = num2str(defaultanswer{k}); %#ok<AGROW>
                end
            end
            A = inputdlg(prompt,name,numlines,defaultanswer);
            if isempty(A); return; end;
            
            % check Options
            
            % check if a proper marker entered
            if ~any(strcmp(O.marker,{'o','s','^','d','v','*','<','>','.','p','h','+','x','none'}))
                errordlg(sprintf('Error!\n\nOptions: invalid marker\nValue reset to default!'),'Wrong value');
                O.marker = 's';
            end
            
            % check if a proper linestyle is entered
            if ~any(strcmp(O.linestyle,{'-','--','-.',':','none'}))
                errordlg(sprintf('Error!\n\nOptions: invalid linestyle\nValue reset to default!'),'Wrong value');
                O.linestyle1 = '-';
            end
            
            % check if a proper color is entered
            if ~any(strcmp(O.color,{'y','m','c','r','g','b','w','k','none'})) ...
                    && isempty(regexp(O.color1,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
                errordlg(sprintf('Error!\n\nOptions: invalid color\nValue reset to default!'),'Wrong value');
                O.color = 'r';
            end
            
            if ~any(strcmp(O.textcolorfg,{'y','m','c','r','g','b','w','k','none'})) ...
                    && isempty(regexp(O.textcolorfg,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
                errordlg(sprintf('Error!\n\nOptions: invalid color\nValue reset to default!'),'Wrong value');
                O.textcolorfg = 'y';
            end
            if ~any(strcmp(O.textcolorbg,{'y','m','c','r','g','b','w','k','none'})) ...
                    && isempty(regexp(O.textcolorbg,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
                errordlg(sprintf('Error!\n\nOptions: invalid color\nValue reset to default!'),'Wrong value');
                O.textcolorbg = 'none';
            end
            
            for k = 1:n
                obj.Options.(fields{k}) = A{k};
            end
        end
        
        function resample(obj, resampledRatio)
            % function resample(obj, resampledRatio)
            % Recalculation of ROI position during image resampling
            %
            % Parameters:
            % resampledRatio: a vector [ratioW, ratioH, ratioZ] ratio of new/old dimensions after resampling.
            
            %|
            % @b Examples:
            % @code resampledRatio = [.5 .5 1];  // bin in 2 times XY dimension.  @endcode
            % @code indices = roiRegion.resample(resampledRatio); // resample ROIs @endcode
            % @code indices = resample(obj, resampledRatio); // Call within the class; resample ROIs @endcode
            
            for i=1:numel(obj.Data)
                if obj.Data(i).orientation == 4
                    obj.Data(i).X = obj.Data(i).X * resampledRatio(1);
                    obj.Data(i).Y = obj.Data(i).Y * resampledRatio(2);
                elseif obj.Data(i).orientation == 1
                    obj.Data(i).X = obj.Data(i).X * resampledRatio(3);
                    obj.Data(i).Y = obj.Data(i).Y * resampledRatio(1);
                elseif obj.Data(i).orientation == 2
                    obj.Data(i).X = obj.Data(i).X * resampledRatio(3);
                    obj.Data(i).Y = obj.Data(i).Y * resampledRatio(2);
                end
            end
        end
        
        function crop(obj, cropF)
            % function crop(obj, cropF)
            % Recalculation of ROI position during image crop
            %
            % Parameters:
            % cropF: a vector [x1, y1, dx, dy, z1, dz] with parameters of the crop. @b Note! The units are pixels!
            
            %|
            % @b Examples:
            % @code cropF = [100 512 200 512 5 20];  // define parameters of the crop.  @endcode
            % @code indices = roiRegion.crop(cropF); // crop ROIs @endcode
            % @code indices = remove(obj, cropF); // Call within the class; crop ROIs @endcode
            
            for i=1:numel(obj.Data)
                if obj.Data(i).orientation == 4
                    obj.Data(i).X = obj.Data(i).X - cropF(1)+1;
                    obj.Data(i).Y = obj.Data(i).Y - cropF(2)+1;
                elseif obj.Data(i).orientation == 1
                    obj.Data(i).X = obj.Data(i).X - cropF(5)+1;
                    obj.Data(i).Y = obj.Data(i).Y - cropF(1)+1;
                elseif obj.Data(i).orientation == 2
                    obj.Data(i).X = obj.Data(i).X - cropF(5)+1;
                    obj.Data(i).Y = obj.Data(i).Y - cropF(2)+1;
                end
                %                 if obj.Data(i).orientation == handles.Img{handles.Id}.I.orientation
                %                     if strcmp(obj.roi.type{i},'imrect') || strcmp(obj.roi.type{i},'imellipse')
                %                         obj.roi.pos{i}(1:2) = [obj.roi.pos{i}(1)-cropF(1) obj.roi.pos{i}(2)-cropF(2)];
                %                     elseif strcmp(obj.roi.type{i},'impoly')
                %                         for ind=1:size(obj.roi.pos{i},1)
                %                             obj.roi.pos{i}(ind,1:2) = [obj.roi.pos{i}(ind,1)-cropF(1) obj.roi.pos{i}(ind,2)-cropF(2)];
                %                         end
                %                     end
                %                 end
            end
        end
        
        function [position, screenPosition] = drawROI(obj, handles, type, pos, instant)
            % function [position, screenPosition] = drawROI(obj, handles, type, pos, instant)
            % draw a ROI object in the handles.imageAxes
            %
            % Creates an instanse of Matlab 'imroi' class and store it in  @em roiRegion.roi.imroi
            %
            % Parameters:
            % handles: handles structure of im_browser.m
            % type: a type of ROI: ''imline'', ''imellipse''
            % pos: coordinates of the ROI
            % @li [x1, y1; x2, y2] -> '@b imrect' coordinates of two corners
            % @li [x1, y1, Rwidth, Rheight] -> '@b imellipse'
            % instant: [@em optional], used only for imellipse to automatically get position of vertices. 1 or 0 (default).
            %
            % Return values:
            % position:  coordinates of the selected area in the Data format
            % screenPosition: coordinagtes of the selected area in the imageAxes units
            
            %|
            % @b Examples:
            % @code position = roiRegion.drawROI(handles, 'imline', [10, 10; 50, 50]); // draw a line @endcode
            % @code position = drawROI(obj, handles, 'imline', [10, 10; 50, 50]);; // Call within the class; draw a line @endcode
            
            if nargin < 5; instant = 0; end;
            screenPosition = [];
            switch type
                case 'imrect'
                    % recalculate coordinates from data to image axes
                    [pos2(:,1), pos2(:,2)] = obj.hImg.convertDataToMouseCoordinates(pos(:,1),  pos(:,2), 'shown');
                    
                    % recalculated to the imageAxes
                    imrectPos(1) = pos2(1,1);
                    imrectPos(2) = pos2(1,2);
                    imrectPos(3) = abs(diff(pos2(:,1)));
                    imrectPos(4) = abs(diff(pos2(:,2)));
                    obj.roi.imroi = imrect(handles.imageAxes, imrectPos); %pos = [X-vector Y-vector]
                    
                    % absolute positions
                    imrectPos(1) = pos(1,1);
                    imrectPos(2) = pos(1,2);
                    imrectPos(3) = abs(diff(pos(:,1)));
                    imrectPos(4) = abs(diff(pos(:,2)));
                    obj.roi.pos = imrectPos;
                    
                    obj.roi.type = type;
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition1(p));
                    % fix aspect ratio
                    if get(handles.roiAspectFix, 'value') == 1
                        setFixedAspectRatioMode(obj.roi.imroi, 1);
                    end
                    screenPosition = wait(obj.roi.imroi);   % position of ROI in the imageAxes
                    position = obj.roi.pos;
                case 'imellipse'
                    [pos2(1), pos2(2)] = obj.hImg.convertDataToMouseCoordinates(pos(1),  pos(2), 'shown');
                    pos2(3) = pos(3)/obj.hImg.magFactor;
                    pos2(4) = pos(4)/obj.hImg.magFactor;
                    obj.roi.imroi = imellipse(handles.imageAxes, pos2); %pos = [x y width height]
                    % fix the aspect ratio (so no ellipses are allowed)
                    obj.roi.pos = pos;
                    obj.roi.type = type;
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition1(p));
                    % fix aspect ratio
                    if get(handles.roiAspectFix, 'value') == 1
                        setFixedAspectRatioMode(obj.roi.imroi, 1);
                    end
                    if instant
                        position = obj.roi.imroi.getVertices;
                    else
                        position = wait(obj.roi.imroi);
                    end
                    if ~isempty(position)
                        [position(:,1), position(:,2)] = obj.hImg.convertMouseToDataCoordinates(position(:,1), position(:,2), 'shown');
                    end
                case 'impoly'
                    [pos2(:,1), pos2(:,2)] = obj.hImg.convertDataToMouseCoordinates( pos(:,1),  pos(:,2), 'shown');
                    obj.roi.imroi = impoly(handles.imageAxes, pos2,'Closed',true); %pos = [X-vector Y-vector]
                    obj.roi.pos = pos;
                    obj.roi.type = type;
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition2(p));
                    screenPosition = wait(obj.roi.imroi);
                    position = obj.roi.pos;
                case 'imfreehand'
                    obj.roi.imroi = imfreehand(handles.imageAxes, 'Closed', true);
                    obj.roi.pos = [];
                    obj.roi.type = 'impoly';
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition2(p));
                    position = obj.roi.imroi.getPosition();
                    %position = wait(obj.roi.imroi);
                    if ~isempty(position)
                        [position(:,1), position(:,2)] = obj.hImg.convertMouseToDataCoordinates(position(:,1), position(:,2), 'shown');
                    end
                    
            end
            
            if isvalid(obj.roi.imroi)
                % detect color, if it is red -> set position to [] for to cancel
                color = obj.roi.imroi.getColor();
                delete(obj.roi.imroi);
                if sum(color == [1 0 0])==3;  position=[];   end;
            end
            obj.roi.pos = [];
            obj.roi.type = [];
            obj.roi.imroi = [];
            obj.roi.cb = [];
        end
        
        function updateROIposition1(obj, new_position)
            % function updateROIposition1(obj, new_position, roi_index)
            % Update ROI position during movement of @em imrect and @em imellipse
            %
            % one of two functions resposible for update of @em Measure.roi. @e pos.
            % The other one is @em Measure.updateROIposition2()
            %
            % Parameters:
            % new_position: a vector with coordinates of a new position [xmin, ymin, width, height]
            pos2(1) = new_position(1)*obj.hImg.magFactor+max([0 floor(obj.hImg.axesX(1))]);
            pos2(2) = new_position(2)*obj.hImg.magFactor+max([0 floor(obj.hImg.axesY(1))]);
            pos2(3) = new_position(3)*obj.hImg.magFactor;
            pos2(4) = new_position(4)*obj.hImg.magFactor;
            obj.roi.pos=pos2;
        end
        
        function updateROIposition2(obj, new_position)
            % function updateROIposition2(obj, new_position)
            % Update position during movement of @em impoly, @em imline
            %
            % one of two functions resposible for update of @em Measure.roi. @em pos. The other one is
            % @em Measure.updateROIposition1()
            %
            % Parameters:
            % new_position: a vector with coordinates of a new position [point_number][x, y]
            
            pos2(:,1) = new_position(:,1)*obj.hImg.magFactor+max([0 floor(obj.hImg.axesX(1))]);
            pos2(:,2) = new_position(:,2)*obj.hImg.magFactor+max([0 floor(obj.hImg.axesY(1))]);
            %pos2(:,1) = new_position(:,1)*obj.hImg.magFactor+max([0 obj.hImg.axesX(1)]);
            %pos2(:,2) = new_position(:,2)*obj.hImg.magFactor+max([0 obj.hImg.axesY(1)]);
            obj.roi.pos=pos2;
        end
        
        function handles = addROIsToPlot(obj, handles, mode)
            % function handles = addROIsToPlot(obj, handles, mode)
            % plot ROIs above the imageAxes of im_browser
            %
            % Parameters:
            % handles: handles structure of im_browser.m
            % mode: a string that defines a mode of the shown image: 'shown' (in most cases), or 'full' (for panning)
            
            %
            % Return values:
            % handles: handles structure of im_browser.m
            
            %|
            % @b Examples:
            % @code handles = handles.Img{handles.Id}.I.hMeasure.addROIsToPlot(handles, 'shown'); // to show the measurements above the image in the imageData.plotImage function @endcode
            % @code handles = handles.Img{handles.Id}.I.hMeasure.addROIsToPlot(handles, 'full'); // to show the measurements above the image in the im_browser_WindowButtonDownFcn function @endcode
            
            % Credit: adapted from Image Measurement Utility by Jan Neggers
            % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
            
            currOrientation = handles.Img{handles.Id}.I.orientation;
            
            if get(handles.roiShowCheck,'value')==0 || isempty(find([obj.Data.orientation]' == currOrientation, 1))
                return;
            end
            
            % define to show or not the label
            if get(handles.roiShowLabelCheck, 'value')
                showLabel = 1;
            else
                showLabel = 0;
            end
            
            O = obj.Options;
            % Evaluate options
            % ==============================
            marker = O.marker;
            markersize = eval(O.markersize);
            if length(O.color) == 1 || strcmpi(O.color,'none')
                color = O.color;
            else
                color = eval(O.color);
            end
            
            linestyle = O.linestyle;
            linewidth = eval(O.linewidth);
            if length(O.textcolorfg) == 1 || strcmpi(O.textcolorfg,'none')
                textcolorfg = O.textcolorfg;
            else
                textcolorfg = eval(O.textcolorfg);
            end
            if length(O.textcolorbg) == 1  || strcmpi(O.textcolorbg,'none')
                textcolorbg = O.textcolorbg;
            else
                textcolorbg = eval(O.textcolorbg);
            end
            fontsize = eval(O.fontsize);
            
            set(handles.imageAxes,'NextPlot','add');
            indices = find([obj.Data.orientation]' == currOrientation);
            selectedROI = get(handles.roiList,'value');
            if selectedROI > 1    % show only selected roi
                roiList = get(handles.roiList,'string');
                indices = obj.findIndexByLabel(roiList{selectedROI});
            end
            for i = 1:numel(indices)
                % convert the value to string
                value = cell2mat(obj.Data(indices(i)).label);
                X = obj.Data(indices(i)).X;
                Y = obj.Data(indices(i)).Y;
                
                [X,Y] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(X, Y, mode);
                
                % plot the measurement, and set the plot options
                switch cell2mat(obj.Data(indices(i)).type)
                    case 'imrect'
                        % generate points for plotting
                        splX = sort(X);
                        splX(1) = splX(1) - 1;
                        splY = sort(Y);
                        splY(1) = splY(1) - 1;
                        % save for later plotting
                        spl.x = [splX(1) splX(2) splX(2) splX(1) splX(1)];
                        spl.y = [splY(1) splY(1) splY(2) splY(2) splY(1)];
                        
                        %[spl.x,spl.y] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(spl.x,spl.y, mode);
                        h = plot(handles.imageAxes,spl.x,spl.y,'s-k');
                        if showLabel
                            ht = text(spl.x(3),spl.y(3),['   ' value], 'Parent', handles.imageAxes);
                        end
                        set(h,'Marker',marker);
                        set(h,'MarkerSize',markersize);
                        set(h,'MarkerEdgeColor', color);
                    case {'impoly'}
                        spl.x = X;
                        spl.y = Y;
                        spl.x(end+1) = X(1);
                        spl.y(end+1) = Y(1);
                        
                        h = plot(handles.imageAxes,spl.x,spl.y,'s-k');
                        if showLabel
                            ht = text(spl.x(end),spl.y(end),['  ' value], 'Parent', handles.imageAxes);
                        end
                        
                        set(h,'Marker',marker);
                        set(h,'MarkerSize',markersize);
                        set(h,'MarkerEdgeColor', color);
                    case 'imellipse'
                        h = plot(handles.imageAxes, X, Y, '-k');
                        if showLabel
                            ht = text(X(1), Y(1),['  ' value], 'Parent', handles.imageAxes);
                        end
                end
                
                set(h,'LineStyle',linestyle)
                set(h,'Color',color)
                set(h,'LineWidth',linewidth)
                
                if showLabel
                    set(ht,'Color',textcolorfg);
                    set(ht,'BackgroundColor',textcolorbg);
                    set(ht,'FontSize',fontsize);
                    set(ht, 'tag', 'roi');
                end
                
                if O.showMarkers == 0; set(h,'marker','none'); end;
                if O.showLines == 0; set(h,'LineStyle','none'); end;
                %if O.showText == 0; set(ht,'Visible','off'); end;
                
                set(h, 'tag', 'roi');
            end
            set(handles.imageAxes,'NextPlot','replace');
        end
        
        function mask = returnMask(obj, index, Height, Width, orient)
            % function mask = returnMask(obj, index, Height, Width, orient)
            % Return a bitmap mask of the specified ROI
            %
            % Parameters:
            % index: an index of ROI to get mask, use @b 0 - to get
            % combined mask for all shown ROIs. It is also possible to use
            % obj.Data.label field as string of chars
            % Height: [@em optional] height of the image
            % Width: [@em optional] width of the image
            % orient: [@em optional] orientation of the dataset: 1-'xz', 2-'yz', 4-'yz', 0-for all orientations. @b
            % Default, the currently shown orientation.
            %
            % Return values:
            % mask: mask image [1:Height, 1:Width]
            
            %|
            % @b Examples:
            % @code mask = roiRegion.returnMask(new_position, 1); // get mask of ROI number 1 @endcode
            % @code mask =  returnMask(obj, 0); // Call within the class; get combined mask of all shown ROIs @endcode
            
            if nargin < 5; orient = obj.hImg.orientation; end;
            if nargin < 3 || isnan(Height);
                options.orientation = orient;
                [Height, Width, color, thick] = obj.hImg.getDatasetDimensions('image', NaN, NaN, options);
            end;
            
            mask = zeros(Height, Width,'uint8');
            
            % find index from label
            if ischar(index)
                index = obj.findIndexByLabel(index);
            end
            
            if index == 0   % generate mask for all ROIs
                [number, indexList] = obj.getNumberOfROI(orient);
            else    % only for selected roi
                indexList = index;
            end
            
            % shift coordinates when the block mode is enabled
            shiftX = 0;
            shiftY = 0;
            if obj.hImg.blockModeSwitch == 1
                shiftX = max([0 floor(obj.hImg.axesX(1))]);
                shiftY = max([0 floor(obj.hImg.axesY(1))]);
            end
            
            for i=indexList
                if obj.Data(i).orientation == orient
                    X = obj.Data(i).X - shiftX;
                    Y = obj.Data(i).Y - shiftY;
                    if strcmp(obj.Data(i).type,'imrect')
                        y1 = max([1 min(Y)]);
                        y2 = min([Height max(Y)]);
                        x1 = max([1 min(X)]);
                        x2 = min([Width max(X)]);
                        mask(y1:y2,x1:x2) = 1;
                    elseif strcmp(obj.Data(i).type,'imellipse')
                        % create image space (for intensity)
                        [x, y] = meshgrid(1:Width,1:Height);
                        % find all pixels inside the circle
                        incircle = inpolygon(x,y,X,Y);
                        mask(incircle) = 1;
                    elseif strcmp(obj.Data(i).type,'impoly')
                        options.close = 1;
                        options.fill = 1;
                        clear pos;
                        pos(:,1) = obj.Data(i).X - shiftX;
                        pos(:,2) = obj.Data(i).Y - shiftY;
                        mask = ib_connectPoints(mask, pos, options);
                    end
                end
            end
        end
        
        function updateROIScreenPosition(obj, mode)
            % function updateROIScreenPosition(obj, mode)
            % Updates position of ROI when plotting in handles.imageAxes
            %
            % Parameters:
            % mode: identifier of the updating mode:
            % - ''@b crop'' during zooming
            % - ''@b full'' during panning of the axes
            
            %|
            % @b Examples
            % @code Measure.updateROIScreenPosition('crop'); // update positions of all ROIs during zoom in/out @endcode
            % @code updateROIScreenPosition(obj, 'full'); // Call within the class; update positions of all ROIs during panning @endcode
            pos = obj.roi.pos;
            if strcmp(obj.roi.type,'impoly') || strcmp(obj.roi.type,'imline') || strcmp(obj.roi.type,'impoint')
                if strcmp(mode, 'crop')
                    pos2(:,1) = (pos(:,1) -  max([0 floor(obj.hImg.axesX(1))]))/obj.hImg.magFactor;
                    pos2(:,2) = (pos(:,2) -  max([0 floor(obj.hImg.axesY(1))]))/obj.hImg.magFactor;
                    %pos2(:,1) = (pos(:,1) -  max([0 obj.hImg.axesX(1)]))/obj.hImg.magFactor;
                    %pos2(:,2) = (pos(:,2) -  max([0 obj.hImg.axesY(1)]))/obj.hImg.magFactor;
                    obj.roi.imroi.setPosition(pos2);
                else
                    pos2 = pos/max([1 obj.hImg.magFactor]);
                    obj.roi.imroi.removeNewPositionCallback(obj.roi.cb);
                    obj.roi.imroi.setPosition(pos2);
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition2(p));
                end
            elseif strcmp(obj.roi.type,'imellipse') || strcmp(obj.roi.type,'imrect')
                if strcmp(mode, 'crop')
                    pos2(1) = (pos(1) -  max([0 floor(obj.hImg.axesX(1))]))/obj.hImg.magFactor;
                    pos2(2) = (pos(2) -  max([0 floor(obj.hImg.axesY(1))]))/obj.hImg.magFactor;
                    %pos2(1) = (pos(1) -  max([0 obj.hImg.axesX(1)]))/obj.hImg.magFactor;
                    %pos2(2) = (pos(2) -  max([0 obj.hImg.axesY(1)]))/obj.hImg.magFactor;
                    pos2(3) = pos(3)/obj.hImg.magFactor;
                    pos2(4) = pos(4)/obj.hImg.magFactor;
                    obj.roi.imroi.setPosition(pos2);
                else
                    pos2 = pos/max([1 obj.hImg.magFactor]);
                    obj.roi.imroi.removeNewPositionCallback(obj.roi.cb);
                    obj.roi.imroi.setPosition(pos2);
                    %setFixedAspectRatioMode(obj.roi.imroi, true);
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition1(p));
                end
            end
        end
        
    end
end