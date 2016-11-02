classdef Measure < matlab.mixin.Copyable
    % @type Measure class is resposnible for keeping Measurements of the model
    
    % Copyright (C) 21.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
	% 
	% This program is free software; you can redistribute it and/or
	% modify it under the terms of the GNU General Public License
	% as published by the Free Software Foundation; either version 2
	% of the License, or (at your option) any later version.
	%
	% Updates
	% 
    % heavily based on Image Measurement Utility written by Jan Neggers,
    % Eindhoven Univeristy of Technology.
    % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
    
    properties
        Data
        % a structure with measurements
        %      .Data.n  - index, double
        %      .Data.type   - type, string: 'LinDistance',
        %      .Data.value  - value, double
        %      .Data.X      - X-coordinates of points
        %      .Data.Y      - Y-coordinates of points
        %      .Data.Z      - Z-coordinates of points
        %      .Data.T      - T-coordinates of points
        %      .Data.spline
        %      .Data.circ
        %      .Data.intensity  - average intensity of the profile
        %      .Data.profile    - intensity profile
        hImg
        % handle to imageData class
        Options
        % a structure with show options
        %      .Options.marker1 = 'o'; - style 1 for markers
        %      .Options.marker2 = '.';  - style 2 for markers
        %      .Options.markersize = '10'; - size of markers
        %      .Options.linestyle1 = '-'; - style 1 for lines
        %      .Options.linestyle2 = '--'; - style 2 for lines
        %      .Options.linewidth = '1' ; - width for lines
        %      .Options.color1 = 'y';   - color style 1
        %      .Options.color2 = 'k';   - color style 2
        %      .Options.textcolorfg = 'y';  - text color
        %      .Options.textcolorbg = 'none';  - color for text background
        %      .Options.fontsize = '14';  - size of the font
        %      .Options.splinemethod = 'spline';  - method for splines
        %      .Options.showMarkers = 1;
        %      .Options.showLines = 1;
        %      .Options.showText = 1;
        roi
        % a structure with ROI data:
        % - roi.pos - coordinates of ROIs
        % - roi.type - ROIs type: 'imline'
        % - roi.imroi - handle to imroi Matlab class
        % - roi.cb - array of callbacks to 'addNewPositionCallback' function
        typeToShow
        % a string that defines type of measurements to show:
        % - 'All' - show all
        % - 'Angle'
        % - 'Caliper'
        % - 'Circle (R)'
        % - 'Distance (linear)'
        % - 'Distance (polyline)'
        % - 'Point'
        
    end
    
    methods
        function obj = Measure(hImg)
            % function obj = Measure(hImageData)
            % Constructor for the @type Measure class.
            %
            % Constructor for the Measure class. Create a new instance of
            % the class with default parameters
            %
            % Parameters:
            % hImg: - handle to imageData class
            %
            % Return values:
            % obj - instance of the @type Measure class.
            obj.hImg = hImg;
            obj.clearContents();
        end
        
        function addMeasurements(obj, newData, n)
            % function addMeasurements(obj, newData, n)
            % add or insert measurement into the obj.Data structure
            %
            % Parameters:
            % newData: structure of a new measurement to insert. Fields should match those of obj.Data
            % n: [@em optional] position where to add the measurement, @em default - number of measurements in obj.Data + 1
            %
            % Return values:
            %
            
            %|
            % @b Examples:
            % @code Measure.addMeasurements(newData, 5); insert measurement to position 5 @endcode
            % @code addMeasurements(obj, newData); // Call within the class. Add a measurement @endcode
            if nargin < 3; n = obj.getNumberOfMeasurements() + 1; end;
            
            noMeasurements = obj.getNumberOfMeasurements();
            if n <= noMeasurements  % insert measurement
                obj.Data(n+1:numel(obj.Data)+1)  = obj.Data(n:numel(obj.Data));
                obj.Data(n) = newData;
                newNs = num2cell(1:numel(obj.Data));
                [obj.Data(1:numel(obj.Data)).n] = newNs{:};
            else                    % add measurement
                obj.Data(n) = newData;
            end
        end
        
        
        function handles = addMeasurementsToPlot(obj, handles, mode, axes)
            % function handles = addMeasurementsToPlot(obj, handles, mode, axes)
            % plot measurement marks above the imageAxes of im_browser
            %
            % Parameters:
            % handles: handles structure of im_browser.m
            % mode: a string that defines a mode of the shown image: 'shown' (in most cases), or 'full' (for panning)
            % axes: [@em optional], define a handles to axes that should be
            % used for drawing, used in ib_snapshotGui.m; @em default handles.imageAxes
            
            %
            % Return values:
            % handles: handles structure of im_browser.m
            
            %|
            % @b Examples:
            % @code handles = handles.Img{handles.Id}.I.hMeasure.addMeasurementsToPlot(handles, 'shown'); // to show the measurements above the image in the imageData.plotImage function @endcode
            % @code handles = handles.Img{handles.Id}.I.hMeasure.addMeasurementsToPlot(handles, 'full'); // to show the measurements above the image in the im_browser_WindowButtonDownFcn function @endcode
            
            % Credit: adapted from Image Measurement Utility by Jan Neggers
            % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
            
            if nargin < 4
                axes = handles.imageAxes;
            end
            
            sliceNo = handles.Img{handles.Id}.I.getCurrentSliceNumber();
            timePnt = handles.Img{handles.Id}.I.getCurrentTimePoint();
            ZT_vec = [[handles.Img{handles.Id}.I.hMeasure.Data.Z]',[handles.Img{handles.Id}.I.hMeasure.Data.T]'];
            if isempty(ZT_vec); return; end;
            indices = find(ismember(ZT_vec, [sliceNo timePnt],'rows') == 1);    %#ok<EFIND> % get indices of measurements that should be shown
            
            if get(handles.showAnnotationsCheck,'value')==0 || isempty(indices)     % nothing to show
                return;
            end
            
            O = handles.Img{handles.Id}.I.hMeasure.Options;
            % Evaluate options
            % ==============================
            marker = {O.marker1 ; O.marker2};
            markersize = eval(O.markersize);
            if length(O.color1) == 1 || strcmpi(O.color1,'none')
                color{1,1} = O.color1;
            else
                color{1,1} = eval(O.color1);
            end
            if length(O.color2) == 1 || strcmpi(O.color2,'none')
                color{2,1} = O.color2;
            else
                color{2,1} = eval(O.color2);
            end
            linestyle = {O.linestyle1 ; O.linestyle2};
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
            set(axes,'NextPlot','add');
            %indices = find([obj.Data.Z]' == sliceNo);
            
            if ~strcmp(obj.typeToShow, 'All')
                indices2 = find(ismember([obj.Data.type], obj.typeToShow));
                indices = intersect(indices, indices2);
            end
            for i = 1:numel(indices)
                % convert the value to string
                value = sprintf('%.2f',obj.Data(indices(i)).value);
                X = obj.Data(indices(i)).X;
                Y = obj.Data(indices(i)).Y;
                circ  = obj.Data(indices(i)).circ;
                spl   = obj.Data(indices(i)).spline;
                if strcmp(get(get(axes,'parent'),'tag'), 'imagePanel')  % recalculate coordinates for the imageAxes
                    [X,Y] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(X, Y, mode);
                else
                    [X,Y] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(X, Y, mode, 1);
                end
                
                % plot the measurement, and set the plot options
                switch cell2mat(obj.Data(indices(i)).type)
                    case 'Distance (linear)'
                        h1 = plot(axes, X,Y,'-xw',X,Y,':+k');
                        ht = text(X(2),Y(2),['  ' value], 'Parent', axes);
                        h  = h1;
                    case 'Point'
                        h1 = plot(axes, X,Y,'o');
                        ht = text(X,Y,['  ' obj.Data(indices(i)).value], 'Parent', axes);
                        h  = h1;
                        marker = marker(1);
                        color = color(1);
                        linestyle = linestyle(1);
                    case 'Caliper'
                        h1 = plot(axes, X(1:2),Y(1:2),'-xw',X(1:2),Y(1:2),':+k');
                        h2 = plot(axes, X(3:4),Y(3:4),'-xw',X(3:4),Y(3:4),':+k');
                        h  = [h1 ; h2];
                        ht = text(X(3),Y(3),['  ' value], 'Parent', axes);
                        
                        set(h2,{'Marker'},marker)
                        set(h2,'MarkerSize',markersize)
                        set(h2,{'MarkerEdgeColor'},color)
                        
                        set(h2,{'LineStyle'},linestyle)
                        set(h2,{'Color'},color)
                        set(h2,'LineWidth',linewidth)
                    case 'Circle (R)'
                        if strcmp(get(get(axes,'parent'),'tag'), 'imagePanel')  % recalculate coordinates for the imageAxes
                            [circ.xc,circ.yc] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(circ.xc,circ.yc, mode);
                        else
                            [circ.xc,circ.yc] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(circ.xc,circ.yc, mode, 1);
                        end
                        h1 = plot(axes, circ.xc,circ.yc,'xw',circ.xc,circ.yc,'+k');
                        h2 = plot(axes, X,Y,'-w',X,Y,':k');
                        h  = [h1 ; h2];
                        ht = text(circ.xc,circ.yc,['  ' value], 'Parent', axes);
                        
                        set(h2,'Marker','none')
                        set(h2,{'LineStyle'},linestyle)
                        set(h2,{'Color'},color)
                        set(h2,'LineWidth', linewidth)
                    case 'Angle'
                        h1 = plot(axes,X,Y,'-xw',X,Y,':+k');
                        ht = text(X(2),Y(2),['   ' value], 'Parent', axes);
                        h  = h1;
                    case 'Distance (polyline)'
                        if strcmp(get(get(axes,'parent'),'tag'), 'imagePanel')  % recalculate coordinates for the imageAxes
                            [spl.x,spl.y] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(spl.x,spl.y, mode);
                        else
                            [spl.x,spl.y] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(spl.x,spl.y, mode, 1);
                        end
                        h1 = plot(axes,spl.x,spl.y,'xw',spl.x,spl.y,'+k');
                        h2 = plot(axes,X,Y,'-w',X,Y,':k');
                        h  = [h1 ; h2];
                        ht = text(spl.x(end),spl.y(end),[' ' value], 'Parent', axes);
                        
                        set(h2,'Marker','none')
                        set(h2,{'LineStyle'},linestyle)
                        set(h2,{'Color'},color)
                        set(h2,'LineWidth',linewidth)
                end
                
                set(h1,{'Marker'},marker)
                set(h1,'MarkerSize',markersize)
                set(h1,{'MarkerEdgeColor'},color)
                set(h1,{'LineStyle'},linestyle)
                set(h1,{'Color'},color)
                set(h1,'LineWidth',linewidth)
                
                if strcmp(cell2mat(obj.Data(indices(i)).type),'Distance (polyline)')
                    set(h1,'LineStyle','none');
                end
                
                set(ht,'Color',textcolorfg);
                set(ht,'BackgroundColor',textcolorbg);
                set(ht,'FontSize',fontsize);
                
                if O.showMarkers == 0; set(h,'marker','none'); end;
                if O.showLines == 0; set(h,'LineStyle','none'); end;
                if O.showText == 0; set(ht,'Visible','off'); end;
                
                set(ht, 'tag', 'measurements');
                set(h, 'tag', 'measurements');
            end
            set(axes,'NextPlot','replace');
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
            % @code MeasureInstance.clearContents(); @endcode
            % @code clearContents(obj); // Call within the class @endcode
            
            obj.setDefaultOptions();   %  set Options to default state
            obj.clearData();  % clear Data structure
        end
        
        function clearData(obj)
            % function clearData(obj)
            % Removes all values of the Data structure
            %
            % Parameters:
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code MeasureInstance.clearData(); @endcode
            % @code clearData(obj); // Call within the class @endcode
            obj.Data = [];
            
            obj.Data.n = [];
            obj.Data.type = [];
            obj.Data.value  = [];
            obj.Data.X = [];
            obj.Data.Y = [];
            obj.Data.Z = [];
            obj.Data.T = [];
            obj.Data.spline = [];
            obj.Data.circ = [];
            obj.Data.intensity = [];
            obj.Data.profile = [];
            
            obj.roi.pos = [];
            obj.roi.type = [];
            obj.roi.imroi = [];
            obj.roi.cb = [];
            
            if isempty(obj.typeToShow); obj.typeToShow = 'All'; end;
        end
        
        function editMeasurements(obj, handles, index, colCh)
            if nargin < 4; colCh = obj.Data(index).colCh; end;
            
            type = obj.Data(index).type;
            switch cell2mat(type)
                case 'Distance (linear)'
                    obj.DistanceFun(handles, index, colCh);
                case 'Circle (R)'
                    obj.CircleFun(handles, index, colCh);
                case 'Angle'
                    obj.AngleFun(handles, index, colCh);
                case 'Caliper'
                    obj.CaliperFun(handles, index, colCh);
                case 'Distance (polyline)'
                    obj.DistancePolyFun(handles, index, colCh);
                case 'Point'
                    obj.PointFun(handles, index, colCh);
            end
        end
        
        function removeMeasurements(obj, index)
            % removeMeasurements(obj, index)
            % Remove measurement(s) from the class
            %
            % Parameters:
            % index: [optional], an index of the measurement point to remove, when empty or zero - removes all points
            %
            % Return values:
            %
            
            %|
            % @b Examples
            % @code Measure.removeMeasurements(); // remove all measurements @endcode
            % @code removeMeasurements(obj, 5); // Call within the class; remove 5th measurement @endcode
            
            if nargin < 2
                index = 0;
            end
            if isempty(index); index = 0; end;
            
            
            if index == 0   % remove all measurements
                button = questdlg(sprintf('Warning!\nYou are going to delete all measurements\nAre you sure?'),'Delete measurements!','Delete','Cancel','Cancel');
                if strcmp(button, 'Cancel'); return; end;
                obj.clearData();
            else            % remove a single measurement
                if numel(index) == obj.getNumberOfMeasurements();
                    obj.clearData();    % situation that is equal to delete all
                else
                    obj.Data(index) = [];
                    newNs = num2cell(1:numel(obj.Data));
                    [obj.Data(1:numel(obj.Data)).n] = newNs{:};
                end;
                
            end
        end
        
        function setOptions(obj)
            % function setOptions(obj)
            % Update all values of the Options structure of the class
            %
            % Parameters:
            %
            % Return values:
            
            %|
            % @b Examples:
            % @code MeasureInstance.setOptions(); @endcode
            % @code setOptions(obj); // Call within the class @endcode
            
            prompt={...
                sprintf('Marker Style 1\n( + o * . x s d ^ v > < p h )'),...
                'Marker Style 2',...
                'Marker Size',...
                sprintf('Line Style 1\n(-   --   :   -. )'),...
                'Line Style 2',...
                'Line Width',...
                sprintf('Color 1\n( r  g  b  c  m  y  k  w none)'),...
                'Color 2',...
                'Text Foreground Color',...
                'Text Background Color',...
                'Text Fontsize'};
            name='Plot Options';
            numlines=1;
            
            O = obj.Options;
            O = rmfield(O, 'showMarkers');
            O = rmfield(O, 'showLines');
            O = rmfield(O, 'showText');
            O = rmfield(O, 'splinemethod');
            fields = fieldnames(O);
            n = length(fields);
            
            % build the default answer from the options structure
            for k = 1:n
                defaultanswer{k} = O.(fields{k});
                if ~ischar(defaultanswer{k});
                    defaultanswer{k} = num2str(defaultanswer{k});
                end
            end
            A = inputdlg(prompt,name,numlines,defaultanswer);
            if isempty(A); return; end;
            
            O.marker1 = A{1};
            O.marker2 = A{2};
            O.markersize = A{3};
            O.linestyle1 = A{4};
            O.linestyle2 = A{5};
            O.linewidth = A{6};
            O.color1 = A{7};
            O.color2 = A{8};
            O.textcolorfg = A{9};
            O.textcolorbg = A{10};
            O.fontsize = A{11};

            % check Options
            % check if a proper marker entered
            if ~any(strcmp(O.marker1,{'o','s','^','d','v','*','<','>','.','p','h','+','x','none'}))
                errordlg(sprintf('Error!\n\nOptions: invalid marker\nValue reset to default!'),'Wrong value');
                O.marker1 = 'o';
            end
            if ~any(strcmp(O.marker2,{'o','s','^','d','v','*','<','>','.','p','h','+','x','none'}))
                errordlg(sprintf('Error!\n\nOptions: invalid marker\nValue reset to default!'),'Wrong value');
                O.marker1 = '.';
            end
            
            % check if a proper linestyle is entered
            if ~any(strcmp(O.linestyle1,{'-','--','-.',':','none'}))
                errordlg(sprintf('Error!\n\nOptions: invalid linestyle\nValue reset to default!'),'Wrong value');
                O.linestyle1 = '-';
            end
            if ~any(strcmp(O.linestyle2,{'-','--','-.',':','none'}))
                errordlg(sprintf('Error!\n\nOptions: invalid linestyle\nValue reset to default!'),'Wrong value');
                O.linestyle2 = '--';
            end
            
            % check if a proper color is entered
            if ~any(strcmp(O.color1,{'y','m','c','r','g','b','w','k','none'})) ...
                    && isempty(regexp(O.color1,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
                errordlg(sprintf('Error!\n\nOptions: invalid color\nValue reset to default!'),'Wrong value');
                O.color1 = 'r';
            end
            if ~any(strcmp(O.color2,{'y','m','c','r','g','b','w','k','none'})) ...
                    && isempty(regexp(O.color2,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
                errordlg(sprintf('Error!\n\nOptions: invalid color\nValue reset to default!'),'Wrong value');
                O.color2 = 'k';
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
                %handles.h.Img{handles.h.Id}.I.hMeasure.Options.(fields{k}) = A{k};
                obj.Options.(fields{k}) = O.(fields{k});
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
            % @code MeasureInstance.setDefaultOptions(); @endcode
            % @code setDefaultOptions(obj); // Call within the class @endcode
            
            obj.Options.marker1 = 'o';
            obj.Options.marker2 = '.';
            obj.Options.markersize = '10';
            obj.Options.linestyle1 = '-';
            obj.Options.linestyle2 = '--';
            obj.Options.linewidth = '1' ;
            obj.Options.color1 = 'y';
            obj.Options.color2 = 'k';
            obj.Options.textcolorfg = 'y';
            obj.Options.textcolorbg = 'none';
            obj.Options.fontsize = '14';
            obj.Options.splinemethod = 'spline';
            obj.Options.showMarkers = 1;
            obj.Options.showLines = 1;
            obj.Options.showText = 1;
        end
        
        function position = drawROI(obj,handles,type,pos,instant)
            % function drawROI(obj,handles, type, pos, instant)
            % show a ROI object in the handles.imageAxes for selection of
            % the area to measure
            %
            % Creates an instanse of Matlab 'imroi' class and store it in  @em Measure.roi.imroi
            %
            % Parameters:
            % handles: handles structure of im_browser.m
            % type: a type of ROI: ''imline'', ''imellipse''
            % pos: coordinates of the ROI
            % @li [x1, y1; x2, y2] -> '@b imline'
            % @li [x1, y1, Rwidth, Rheight] -> '@b imellipse'
            % instant: [@em optional], used only for imellipse to automatically get position of vertices. 1 or 0 (default).
            %
            % Return values:
            % position:  coordinates of the selected area
            
            %|
            % @b Examples:
            % @code position = roiRegion.drawROI(handles, 'imline', [10, 10; 50, 50]); // draw a line @endcode
            % @code position = drawROI(obj, handles, 'imline', [10, 10; 50, 50]);; // Call within the class; draw a line @endcode
            
            if nargin < 5; instant = 0; end;
            
            % temporary switch off selection
            %disableSelectionSwitch = handles.preferences.disableSelection;    % get current settings
            %handles.preferences.disableSelection = 'yes'; % disable selection
            %guidata(handles.im_browser, handles);   % store handles
            
            %brushSize = get(handles.segmSpotSizeEdit,'string');
            %set(handles.segmSpotSizeEdit,'string', '0');
            
            currentSegmentationTool = get(handles.seltypePopup,'value');
            set(handles.seltypePopup,'value', 4);   % set segmentation tool to black and white theresholding
            
            switch type
                case 'imline'
                    % recalculate coordinates from data to image axes
                    [pos2(:,1), pos2(:,2)] = obj.hImg.convertDataToMouseCoordinates( pos(:,1),  pos(:,2), 'shown');
                    
                    obj.roi.imroi = imline(handles.imageAxes, pos2); %pos = [X-vector Y-vector]
                    obj.roi.pos = pos;
                    obj.roi.type = type;
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition2(p));
                    screenPosition = wait(obj.roi.imroi);
                    position = obj.roi.pos;
                case 'imellipse'
                    [pos2(1), pos2(2)] = obj.hImg.convertDataToMouseCoordinates( pos(1),  pos(2), 'shown');
                    pos2(3) = pos(3)/obj.hImg.magFactor;
                    pos2(4) = pos(4)/obj.hImg.magFactor;
                    obj.roi.imroi = imellipse(handles.imageAxes, pos2); %pos = [x y width height]
                    % fix the aspect ratio (so no ellipses are allowed)
                    setFixedAspectRatioMode(obj.roi.imroi,true);
                    obj.roi.pos = pos;
                    obj.roi.type = type;
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition1(p));
                    if instant
                        position = obj.roi.imroi.getVertices;
                    else
                        position = wait(obj.roi.imroi);
                    end
                    if ~isempty(position)
                        [position(:,1), position(:,2)] = obj.hImg.convertMouseToDataCoordinates(position(:,1), position(:,2), 'shown');
                    end
                    %position = obj.roi.pos;
                case 'impoly'
                    [pos2(:,1), pos2(:,2)] = obj.hImg.convertDataToMouseCoordinates( pos(:,1),  pos(:,2), 'shown');
                    obj.roi.imroi = impoly(handles.imageAxes, pos2,'Closed',false); %pos = [X-vector Y-vector]
                    obj.roi.pos = pos;
                    obj.roi.type = type;
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition2(p));
                    position = wait(obj.roi.imroi);
                    if ~isempty(position)
                        [position(:,1), position(:,2)] = obj.hImg.convertMouseToDataCoordinates(position(:,1), position(:,2), 'shown');
                    end
                case 'impoint'
                    [pos2(:,1), pos2(:,2)] = obj.hImg.convertDataToMouseCoordinates( pos(:,1),  pos(:,2), 'shown');
                    obj.roi.imroi = impoint(handles.imageAxes, pos2);
                    obj.roi.pos = pos;
                    obj.roi.type = type;
                    obj.roi.cb = addNewPositionCallback(obj.roi.imroi, @(p) obj.updateROIposition2(p));
                    position = wait(obj.roi.imroi);
                    if ~isempty(position)
                        [position(1), position(2)] = obj.hImg.convertMouseToDataCoordinates(position(1), position(2), 'shown');
                    end
                case 'imfreehand'
                    obj.roi.imroi = imfreehand(handles.imageAxes,'Closed',false);
                    obj.roi.pos = [];
                    obj.roi.type = type;
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
            
            % restore the brush size
            %set(handles.segmSpotSizeEdit,'string', brushSize);

            set(handles.seltypePopup, 'value', currentSegmentationTool);   % restore segmentation tool
            
            % restore selected state for the selection
            %handles.preferences.disableSelection = disableSelectionSwitch;
            %guidata(handles.im_browser, handles);
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
            %pos2(1) = new_position(1)*obj.hImg.magFactor+max([0 obj.hImg.axesX(1)]);
            %pos2(2) = new_position(2)*obj.hImg.magFactor+max([0 obj.hImg.axesY(1)]);
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
        
        function number = getNumberOfMeasurements(obj)
            % number = getNumberOfMeasurements(obj)
            % Get number of stored measurements
            %
            % Parameters:
            %
            % Return values:
            % number:  number of stored measurements
            
            %|
            % @b Examples
            % @code number = Measure.getNumberOfMeasurements(); // get the total number @endcode
            % @code number = getNumberOfMeasurements(obj); // Call within the class; get the total number @endcode
            
            if isempty(obj.Data(1).n)
                number = 0;
            else
                number = numel(obj.Data);
            end
        end
        
        function circ = circlefit(obj, x,y)
            % function circ = circlefit(obj, x,y)
            % least squares circle fitting (see matlab help/demo (pendulum))
            %
            % Parameters:
            % x:
            % y:
            %
            % Return values:
            % circ:
            
            % Credit: adapted from Image Measurement Utility by Jan Neggers
            % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
            
            n = length(x);
            M   = [x(:), y(:) ones(n,1)];
            abc = M \ -( x(:).^2 + y(:).^2);
            xc  = -abc(1)/2;
            yc  = -abc(2)/2;
            R   = sqrt((xc^2 + yc^2) - abc(3));
            
            circ.xc = xc;
            circ.yc = yc;
            circ.R  = R;
        end
        
        function result = AngleFun(obj, handles, index, colCh, finetuneCheck)
            % function result = AngleFun(obj, handles, index, colCh, finetuneCheck)
            % This function allows the measurement an angle between 3 points
            %
            % Parameters:
            % handles: handles of im_browser
            % index: [@em Optional] an index of measurement to update; when
            % empty (@b [] ) - adds a new measurement
            % colCh: [@em optional] color channel to use for profile; @em default = 1
            % finetuneCheck: [@em optional] @b 1 (@em default) - allow fine-tuning during the placing of measurements; @b 0 - instant placing
            %
            % Return values:
            % result - 1-success, 0-cancel
            
            %|
            % @b Examples
            % @code Measure.AngleFun(handles, [], 1); // get points and measure the angle between them. Calculate intensity profile for color channel 1 @endcode
            % @code Measure.AngleFun(handles, 2, 1); // edit second measurement. @endcode
            
            % Credit: adapted from Image Measurement Utility by Jan Neggers
            % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
            
            if nargin < 4; colCh = 1; end;
            if nargin < 3; index = []; end;
            result = 1;
            
            if isempty(index)   % add new measurement
                % Select the intersection
                set(handles.imageAxes, 'NextPlot','add');
                [x,y,z,u,v] = getClickPoint(handles);
                h = plot(handles.imageAxes,u,v,'r+',u,v,'bo','markersize',10);
                % Select a point on the first line
                [x(2),y(2),z(2),u(2),v(2)] = getClickPoint(handles);
                h(3:4) = plot(handles.imageAxes,u,v,'r+',u,v,'bo','markersize',10);
                % Select a point on the second line
                [x(3),y(3),z(3),u(3),v(3)] = getClickPoint(handles);
                delete(h);
                set(handles.imageAxes, 'NextPlot','replace');
                if finetuneCheck
                    position = obj.drawROI(handles, 'impoly', [x(2),y(2);x(1),y(1);x(3),y(3)]);
                else
                    position = [x(2),y(2);x(1),y(1);x(3),y(3)];
                end
            else                % edit existing measurement
                tempData = obj.Data(index);     % store the current state
                obj.removeMeasurements(index);  % remove measurement
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                x = tempData.X;
                y = tempData.Y;
                position = obj.drawROI(handles, 'impoly', [x(1),y(1);x(2),y(2);x(3),y(3)]);
            end
            
            % get Z-value
            z = handles.Img{handles.Id}.I.getCurrentSliceNumber();
            timePoint = handles.Img{handles.Id}.I.getCurrentTimePoint();
            % detect Cancel due to press of the Escape button
            if isempty(position);
                if exist('tempData','var')
                    obj.addMeasurements(tempData, tempData.n);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            if handles.Img{handles.Id}.I.orientation == 1   % zx orientation
                aspectRatio = handles.Img{handles.Id}.I.pixSize.z/handles.Img{handles.Id}.I.pixSize.x;
            elseif handles.Img{handles.Id}.I.orientation == 2   % zy orientation
                aspectRatio = handles.Img{handles.Id}.I.pixSize.z/handles.Img{handles.Id}.I.pixSize.y;
            else        % xy orientation
                aspectRatio = handles.Img{handles.Id}.I.pixSize.x/handles.Img{handles.Id}.I.pixSize.y;
            end
            
            v1 = [(position(1,1)-position(2,1))*aspectRatio, position(1,2)-position(2,2)];
            v2 = [(position(3,1)-position(2,1))*aspectRatio, position(3,2)-position(2,2)];
            
            phi = acos(dot(v1,v2)/(norm(v1)*norm(v2)));
            Angle = (phi * (180/pi)); % radtodeg(phi)
            
            X = position(:,1);
            Y = position(:,2);
            
            % create image space (for intensity)
            if handles.Img{handles.Id}.I.orientation == 1   % zx orientation
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.no_stacks, 1:handles.Img{handles.Id}.I.width);                
            elseif handles.Img{handles.Id}.I.orientation == 2   % zy orientation
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.no_stacks, 1:handles.Img{handles.Id}.I.height);
            else        % xy orientation
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.width, 1:handles.Img{handles.Id}.I.height);
            end
            
            % calculate a length vector
            t = [ 0 ; hypot(diff(X),diff(Y)) ];
            t = cumsum(t);
            
            % discretize the measurement line
            Ni = max(t);
            ti = linspace(0,max(t),Ni);
            xi = interp1(t,X,ti);
            yi = interp1(t,Y,ti);
            
            im = handles.Img{handles.Id}.I.getFullSlice('image', NaN, NaN, colCh);
            
            % interpolate the intensity profile along the measurement line
            for ch=1:size(im,3)
                profile(ch,:) = interp2(x,y,double(im),xi,yi); %#ok<AGROW>
            end
            
            % calculate the average intensity
            intensity = mean(profile, 2);
            
            % store the measurement
            if isempty(index)
                n = obj.getNumberOfMeasurements + 1;
            else
                n = index;
            end
            newData.n = n;
            newData.type      = cellstr('Angle');
            newData.value     = Angle;
            newData.X         = X;
            newData.Y         = Y;
            newData.Z         = z(1,1);
            newData.T         = timePoint;
            newData.spline    = [];
            newData.circ      = [];
            newData.intensity = intensity;
            newData.profile   = [ti ; profile];
            
            obj.addMeasurements(newData, n);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            result = 1;
        end
        
        function result = CaliperFun(obj, handles, index, colCh, finetuneCheck)
            % function result = CaliperFun(obj, handles, index, colCh, finetuneCheck)
            % measuring a distance between two opposite sides of an object
            %
            % Parameters:
            % handles: handles of im_browser
            % index: [@em Optional] an index of measurement to update; when
            % empty (@b [] ) - adds a new measurement
            % colCh: [@em optional] color channel to use for profile; @em default = 1
            % finetuneCheck: [@em optional] @b 1 (@em default) - allow fine-tuning during the placing of measurements; @b 0 - instant placing
            %
            % Return values:
            % result - 1-success, 0-cancel
            
            %|
            % @b Examples
            % @code Measure.CaliperFun(handles, [], 1); // get points and measure the distance between them. Calculate intensity profile for color channel 1 @endcode
            % @code Measure.CaliperFun(handles, 2, 1); // edit second measurement. @endcode
            
            % Credit: adapted from Image Measurement Utility by Jan Neggers
            % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
            
            if nargin < 4; colCh = 1; end;
            if nargin < 3; index = []; end;
            result = 0;
            
            if isempty(index)   % add new measurement
                set(handles.imageAxes, 'NextPlot','add');
                
                % select two preliminary points
                [x,y,z,u,v] = getClickPoint(handles);
                h = plot(handles.imageAxes,u,v,'r+',u,v,'bo','markersize',10);
                [x(2),y(2),z(2),u(2),v(2)] = getClickPoint(handles);
                delete(h);
                pos(:,1) = x;
                pos(:,2) = y;
                if finetuneCheck
                    L = obj.drawROI(handles, 'imline', pos);
                else
                    L(:,1) = x;
                    L(:,2) = y;
                end
                if isempty(L); % cancel
                    set(handles.imageAxes, 'NextPlot','replace');
                    return;
                end;
                
                [U,V] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(L(:,1),L(:,2), 'shown');
                h = plot(handles.imageAxes, U,V,'-+r',U,V,'--ob','markersize',10);
                
                X = L(:,1);
                Y = L(:,2);
                set(handles.imageAxes, 'NextPlot','replace');
                
                % Adjust the Point, double click the line when ready
                [x(3),y(3),z(3),u(3),v(3)] = getClickPoint(handles);
                if finetuneCheck
                    P = obj.drawROI(handles, 'impoint',[x(3), y(3)]);
                else
                    P = [x(3), y(3)];
                end
                delete(h);
                if isempty(P);  return; end; % cancel
                
                clear position;
                position(1:3,1) = [X ; P(1)];
                position(1:3,2) = [Y ; P(2)];
            else                % edit existing measurement
                tempData = obj.Data(index);     % store the current state
                obj.removeMeasurements(index);  % remove measurement
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                set(handles.imageAxes, 'NextPlot','add');
                clear pos;
                pos(1:2,1) = tempData.X(1:2);
                pos(1:2,2) = tempData.Y(1:2);
                L = obj.drawROI(handles, 'imline', pos);
                if ~isempty(L); % not cancel
                    [U,V] = handles.Img{handles.Id}.I.convertDataToMouseCoordinates(L(:,1),L(:,2), 'shown');
                    h = plot(handles.imageAxes, U,V,'-+r',U,V,'--ob','markersize',10);
                    X = L(:,1);
                    Y = L(:,2);
                    P = obj.drawROI(handles, 'impoint',[tempData.X(3), tempData.Y(3)]);
                    delete(h);
                    if isempty(P); % cancel
                        position = [];
                    else
                        position(:,1) = [X ; P(1)];
                        position(:,2) = [Y ; P(2)];
                    end
                else    % cancel
                    position = [];
                end
                set(handles.imageAxes, 'NextPlot','replace');
            end
            
            % get Z-value
            z = handles.Img{handles.Id}.I.getCurrentSliceNumber();
            timePoint = handles.Img{handles.Id}.I.getCurrentTimePoint();
            
            % detect Cancel due to press of the Escape button
            if isempty(position);
                if exist('tempData','var')
                    obj.addMeasurements(tempData, tempData.n);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            % calculate the perpendicular distance
            x1 = position(1,1);
            x2 = position(2,1);
            x3 = position(3,1);
            y1 = position(1,2);
            y2 = position(2,2);
            y3 = position(3,2);
            
            % calculate the distance (hypot = pythagoras)
            if handles.Img{handles.Id}.I.orientation == 1   % zx orientation
                pixX = handles.Img{handles.Id}.I.pixSize.z;
                pixY = handles.Img{handles.Id}.I.pixSize.x;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.no_stacks, 1:handles.Img{handles.Id}.I.width);
            elseif handles.Img{handles.Id}.I.orientation == 2   % zy orientation
                pixX = handles.Img{handles.Id}.I.pixSize.z;
                pixY = handles.Img{handles.Id}.I.pixSize.y;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.no_stacks, 1:handles.Img{handles.Id}.I.height);
            else        % xy orientation
                pixX = handles.Img{handles.Id}.I.pixSize.x;
                pixY = handles.Img{handles.Id}.I.pixSize.y;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.width,1:handles.Img{handles.Id}.I.height);
            end
            
            % The perpendicular distance (http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html)
            D = ( (x2-x1)*pixX * (y1-y3)*pixY - (x1-x3)*pixX*(y2-y1)*pixY ) / hypot((x2-x1)*pixX,(y2-y1)*pixY);
            Caliper = abs(D);
            D = ( (x2-x1) * (y1-y3) - (x1-x3)*(y2-y1) ) / hypot((x2-x1),(y2-y1));
            
            % now determine the location of the fourth point for plotting
            dx = (x1-x2);
            dy = y1-y2;
            dist = sqrt(dx*dx + dy*dy);
            dx = dx / dist;
            dy = dy / dist;
            x4 = x3 + D*dy;
            y4 = y3 - D*dx;
            
            % Storing the four points
            X = [x1 ; x2 ; x3 ; x4];
            Y = [y1 ; y2 ; y3 ; y4];
            
            % calculate a length vector
            t = [ 0 ; hypot(diff(X(3:4)),diff(Y(3:4))) ];
            t = cumsum(t);
            
            % discretize the measurement line
            Ni = ceil(max(t));
            ti = linspace(0,max(t),Ni);
            xi = interp1(t,X(3:4),ti);
            yi = interp1(t,Y(3:4),ti);
            
            im = handles.Img{handles.Id}.I.getFullSlice('image', NaN, NaN, colCh);
            
            % interpolate the intensity profile along the measurement line
            for ch=1:size(im,3)
                profile(ch, :) = interp2(x,y,double(im),xi,yi);
            end
            
            % calculate the average intensity
            intensity = mean(profile, 2);
            % store the measurement
            if isempty(index)
                n = obj.getNumberOfMeasurements + 1;
            else
                n = index;
            end
            newData.n = n;
            newData.type      = cellstr('Caliper');
            newData.value     = Caliper;
            newData.X         = X;
            newData.Y         = Y;
            newData.Z         = z(1,1);
            newData.T         = timePoint;
            newData.spline    = [];
            newData.circ      = [];
            newData.intensity = intensity;
            newData.profile   = [ti ; profile];
            
            obj.addMeasurements(newData, n);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            result = 1;
        end
        
        function result = CircleFun(obj, handles, index, colCh, finetuneCheck)
            % function result = CircleFun(obj, handles, index, colCh, finetuneCheck)
            % This function allows the measurement of a radius, using a cirlce
            %
            % Parameters:
            % handles: handles of im_browser
            % index: [@em Optional] an index of measurement to update; when
            % empty (@b [] ) - adds a new measurement
            % colCh: [@em optional] color channel to use for profile; @em default = 1
            % finetuneCheck: [@em optional] @b 1 (@em default) - allow fine-tuning during the placing of measurements; @b 0 - instant placing
            %
            % Return values:
            % result - 1-success, 0-cancel
            
            %|
            % @b Examples
            % @code Measure.CircleFun(handles, [], 1); // get points and measure the radius. Calculate intensity profile for color channel 1 @endcode
            % @code Measure.CircleFun(handles, 2, 1); // edit second measurement. @endcode
            
            % Credit: adapted from Image Measurement Utility by Jan Neggers
            % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
            
            if nargin < 4; colCh = 1; end;
            if nargin < 3; index = []; end;
            result = 0;
            
            if isempty(index)   % add new measurement
                set(handles.imageAxes, 'NextPlot','add');
                [x,y,z,u,v] = getClickPoint(handles);
                h = plot(handles.imageAxes,u,v,'r+',u,v,'bo','markersize',10);
                % select edge of the circle
                [x(2),y(2),z(2),u(2),v(2)] = getClickPoint(handles);
                %h(3:4) = plot(handles.h.imageAxes, u,v,'r+',u,v,'bo','markersize',10);
                delete(h);
                set(handles.imageAxes, 'NextPlot','replace');
                
                % calculate the box around the circle
                A = diff(x);
                B = diff(y);
                R = hypot(A,B);
                P = [x(1)-R y(1)-R 2*R 2*R];
                if finetuneCheck
                    position = obj.drawROI(handles, 'imellipse', P);
                else
                    position = obj.drawROI(handles, 'imellipse', P, 1);
                end
            else                % edit existing measurement
                tempData = obj.Data(index);     % store the current state
                obj.removeMeasurements(index);  % remove measurement
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                u = tempData.circ.xc;
                v = tempData.circ.yc;
                u(2) = u + tempData.circ.R;
                v(2) = v;
                A = diff(u);
                B = diff(v);
                R = hypot(A,B);
                P = [u(1)-R v(1)-R 2*R 2*R];
                position = obj.drawROI(handles, 'imellipse', P);
            end
            
            % get Z-value
            z = handles.Img{handles.Id}.I.getCurrentSliceNumber();
            timePoint = handles.Img{handles.Id}.I.getCurrentTimePoint();
            
            % detect Cancel due to press of the Escape button
            if isempty(position);
                if exist('tempData','var')
                    obj.addMeasurements(tempData, tempData.n);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            % use circlefit to obtain the radius
            circ = obj.circlefit(position(:,1),position(:,2));
            xc = circ.xc;
            yc = circ.yc;
            % recalculate radius in image units
            Radius = circ.R*obj.hImg.pixSize.x;
            
            % store points on the circle for later plotting
            phi = linspace(0,2*pi,60);
            X = circ.R*sin(phi) + circ.xc;
            Y = circ.R*cos(phi) + circ.yc;
            
            % create image space (for intensity)
            [x, y] = meshgrid(1:handles.Img{handles.Id}.I.width,1:handles.Img{handles.Id}.I.height);
            
            % find all pixels inside the circle
            incircle = inpolygon(x,y,X,Y);
            
            im = handles.Img{handles.Id}.I.getFullSlice('image', NaN, NaN, colCh);
            for ch=1:size(im,3)
                % profile
                im_temp = im(:,:,ch);
                profile(ch,:) = im_temp(incircle).'; %#ok<AGROW>
                % calculate the average intensity
                intensity(ch) = mean(im_temp(incircle)); %#ok<AGROW>
            end
            
            % distance from center
            ti = hypot(x(incircle)-xc,y(incircle)-yc).';
            
            % store the measurement
            if isempty(index)
                n = obj.getNumberOfMeasurements + 1;
            else
                n = index;
            end
            newData.n = n;
            newData.type      = cellstr('Circle (R)');
            newData.value     = Radius;
            newData.X         = X;
            newData.Y         = Y;
            newData.Z         = z(1,1);
            newData.T         = timePoint;
            newData.spline    = [];
            newData.circ      = circ;
            newData.intensity = intensity;
            newData.profile   = [ti ; profile];
            
            obj.addMeasurements(newData, n);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            result = 1;
        end
        
        function result = DistanceFreeFun(obj, handles, colCh, finetuneCheck)
            % function result = DistanceFreeFun(obj, handles, colCh, finetuneCheck)
            % measuring of distance along the free-hand path. The path is
            % converted to impoly line
            %
            % Parameters:
            % handles: handles of im_browser
            % colCh: [@em optional] color channel to use for profile; @em default = 1
            % finetuneCheck: [@em optional] @b 1 (@em default) - allow fine-tuning during the placing of measurements; @b 0 - instant placing
            %
            % Return values:
            % result - 1-success, 0-cancel
            
            %|
            % @b Examples
            % @code Measure.DistanceFreeFun(handles, 1); // draw a path and measure the distance between points. Calculate intensity profile for color channel 1 @endcode
            
            if nargin < 4; finetuneCheck = 1; end;
            if nargin < 3; colCh = 1; end;
            result = 0;
            
            position = obj.drawROI(handles, 'imfreehand');
            
            % get Z-value
            z = handles.Img{handles.Id}.I.getCurrentSliceNumber();
            timePoint = handles.Img{handles.Id}.I.getCurrentTimePoint();
            
            % detect Cancel due to press of the Escape button
            if isempty(position);
                if exist('tempData','var')
                    obj.addMeasurements(tempData, tempData.n);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            prompt = sprintf('There are %d vertices in the line. Please enter a coefficient to decrease it if needed; any in range 1-%d\n\nIf coefficient is 2, the number of vertices will be reduced in 2 times', size(position,1), size(position,1));
            title = 'Convert to polyline';
            answer = mib_inputdlg(handles, prompt, title,'10');
            if isempty(answer); return; end;
            
            coef = round(str2double(cell2mat(answer)));
            if coef >= size(position,1)
                coef = 1;
            end;
            position = position(1:coef:end,:);
            
            spl.x = position(:,1);
            spl.y = position(:,2);
            
            n = obj.getNumberOfMeasurements + 1;
            newData.n = n;
            newData.type = cellstr('Distance (polyline)');
            newData.value = [];
            newData.X = [];
            newData.Y = [];
            newData.Z = z(1,1);
            newData.T = timePoint;
            newData.spline = spl;
            newData.circ = [];
            newData.intensity = [];
            newData.profile = [];
            obj.addMeasurements(newData, n);
            
            % call DistancePolyFun to do calculations
            obj.DistancePolyFun(handles, n, colCh, size(position,1), finetuneCheck);
            result = 1;
        end
        
        function result = DistancePolyFun(obj, handles, index, colCh, noPoints, finetuneCheck)
            % function result = DistancePolyFun(obj, handles, index, colCh, noPoints, modeString, finetuneCheck)
            % measuring of distance along the path
            %
            % Parameters:
            % handles: handles of im_browser
            % index: [@em Optional] an index of measurement to update; when
            % empty (@b [] ) - adds a new measurement
            % colCh: [@em optional] color channel to use for profile; @em default = 1
            % noPoints: [@em optional] define number of points in the path; @em default = 5
            % finetuneCheck: [@em optional] @b 1 (@em default) - allow fine-tuning during the placing of measurements; @b 0 - instant placing
            %
            % Return values:
            % result - 1-success, 0-cancel
            
            %|
            % @b Examples
            % @code Measure.DistancePolyFun(handles, [], 1, 10); // get 10 points and measure the distance between them. Calculate intensity profile for color channel 1 @endcode
            % @code Measure.DistancePolyFun(handles, 2, 1); // edit second measurement. @endcode
            
            % Credit: adapted from Image Measurement Utility by Jan Neggers
            % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
            if nargin < 6; finetuneCheck = 1; end;
            if nargin < 5; noPoints = 5; end;
            if nargin < 4; colCh = 1; end;
            if nargin < 3; index = []; end;
            result = 0;
            
            % update number of points
            if noPoints < 2; noPoints = 2; end;
            
            if isempty(index)   % add new measurement
                x = zeros(1,noPoints);
                y = zeros(1,noPoints);
                h = zeros(2,noPoints);
                set(handles.imageAxes, 'NextPlot','add');
                for k = 1:noPoints
                    [x(k),y(k),~,u(k),v(k)] = getClickPoint(handles);
                    h(:,k) = plot(handles.imageAxes, u(k),v(k),'r+',u(k),v(k),'bo');
                end
                delete(h);
                set(handles.imageAxes, 'NextPlot','replace');
                if finetuneCheck
                    pos = [x ; y ].';
                    position = obj.drawROI(handles, 'impoly', pos);
                else
                    position(:,1) = x;
                    position(:,2) = y;
                end
                
            else                % edit existing measurement
                tempData = obj.Data(index);     % store the current state
                obj.removeMeasurements(index);  % remove measurement
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                
                pos(:,1) = tempData.spline.x;
                pos(:,2) = tempData.spline.y;
                if finetuneCheck 
                    position = obj.drawROI(handles, 'impoly', pos);
                else
                    position = pos;
                end
            end
            
            % get Z-value
            z = handles.Img{handles.Id}.I.getCurrentSliceNumber();
            timePoint = handles.Img{handles.Id}.I.getCurrentTimePoint();
            
            % detect Cancel due to press of the Escape button
            if isempty(position);
                if exist('tempData','var') && ~isempty(tempData.X)
                    obj.addMeasurements(tempData, tempData.n);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            % calculate the distance (hypot = pythagoras)
            if handles.Img{handles.Id}.I.orientation == 1   % zx orientation
                pixX = handles.Img{handles.Id}.I.pixSize.z;
                pixY = handles.Img{handles.Id}.I.pixSize.x;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.no_stacks, 1:handles.Img{handles.Id}.I.width);
            elseif handles.Img{handles.Id}.I.orientation == 2   % zy orientation
                pixX = handles.Img{handles.Id}.I.pixSize.z;
                pixY = handles.Img{handles.Id}.I.pixSize.y;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.no_stacks, 1:handles.Img{handles.Id}.I.height);
            else        % xy orientation
                pixX = handles.Img{handles.Id}.I.pixSize.x;
                pixY = handles.Img{handles.Id}.I.pixSize.y;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.width, 1:handles.Img{handles.Id}.I.height);
            end
            
            X = position(:,1);
            Y = position(:,2);
            
            % save for later plotting
            spl.x = X;
            spl.y = Y;
            
            % calculate a length vector
            t = [ 0 ; hypot(diff(X),diff(Y)) ];
            t = cumsum(t);
            
            % testing for uniqueness
            I = unique(t);
            if length(I) ~= length(t)
                errordlg(sprintf('!!! Error !!!\n\nPoints must be distict'),'Error','modal');
                return
            end
            % number of interpolation points
            N = 50*length(X);
            % interpolation method
            method = obj.Options.splinemethod;
            % intepolate along the length vector
            ti = linspace(0,max(t),N) ;
            xi = interp1(t,X,ti,method);
            yi = interp1(t,Y,ti,method);
            
            % calculate the spline length
            L = sum( hypot( diff(xi)*pixX,diff(yi)*pixY ) );
            
            im = handles.Img{handles.Id}.I.getFullSlice('image', NaN, NaN, colCh);
            for ch=1:size(im,3) 
                % interpolate the intensity profile along the measurement line
                profile(ch, :) = interp2(x,y,double(im),xi,yi);
            end
            
            % calculate the average intensity
            intensity = mean(profile, 2);
            
            if isempty(index)
                n = obj.getNumberOfMeasurements + 1;
            else
                n = index;
            end
            newData.n = n;
            newData.type = cellstr('Distance (polyline)');
            newData.value = L;
            newData.X = xi;
            newData.Y = yi;
            newData.Z = z(1,1);
            newData.T = timePoint;
            newData.spline = spl;
            newData.circ = [];
            newData.intensity = intensity;
            newData.profile = [ti ; profile];
            
            obj.addMeasurements(newData, n);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            result = 1;
        end
        
        function result = PointFun(obj, handles, index, colCh, finetuneCheck)
            % function result = PointFun(obj, handles, index, colCh, finetuneCheck)
            % add a point as a marker
            %
            % Parameters:
            % handles: handles of im_browser
            % index: [@em Optional] an index of measurement to update; when
            % empty (@b [] ) - adds a new measurement
            % colCh: [@em optional] color channel to use for profile; @em default = 1
            % finetuneCheck: [@em optional] @b 1 (@em default) - allow fine-tuning during the placing of measurements; @b 0 - instant placing
            %
            % Return values:
            % result - 1-success, 0-cancel
            
            %|
            % @b Examples
            % @code Measure.PointFun(handles, [], 1); // place points and assign a label. @endcode
            % @code Measure.PointFun(handles, 2, 1); // edit second measurement. @endcode
            
            if nargin < 5; finetuneCheck = 1; end;
            if nargin < 4; colCh = 1; end;
            if nargin < 3; index = []; end;
            result = 0;
            
            if isempty(index)   % add new measurement
                [x,y,z,u,v] = getClickPoint(handles);
                if finetuneCheck
                    position = obj.drawROI(handles, 'impoint',[x, y]);
                else
                    position = [x, y];
                end
                if isempty(position);  return; end; % cancel
            else                % edit existing measurement
                tempData = obj.Data(index);     % store the current state
                obj.removeMeasurements(index);  % remove measurement
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                
                pos(:,1) = tempData.X;
                pos(:,2) = tempData.Y;
                position = obj.drawROI(handles, 'impoint', pos);
            end
            
            % get Z-value
            z = handles.Img{handles.Id}.I.getCurrentSliceNumber();
            timePoint = handles.Img{handles.Id}.I.getCurrentTimePoint();
            
            % detect Cancel due to press of the Escape button
            if isempty(position);
                if exist('tempData','var')
                    obj.addMeasurements(tempData, tempData.n);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            if isempty(index)   % add new measurement
                n = obj.getNumberOfMeasurements + 1;
                answer = mib_inputdlg(handles, 'Enter a label','Add point',sprintf('Feature %d', n));
            else                % update existing
                n = index;
                answer = mib_inputdlg(handles, 'Enter a label','Add point',tempData.value);
            end
            if isempty(answer); answer = {''}; end;
            for ch=1:size(im,3)
                profile(ch) = handles.Img{handles.Id}.I.img(ceil(position(2)),ceil(position(1)),ch, z); %#ok<AGROW>
                intensity(ch) = profile(ch); %#ok<AGROW>
            end
            
            newData.n = n;
            newData.type = cellstr('Point');
            newData.value = answer{1};
            newData.X = position(1);
            newData.Y = position(2);
            newData.Z = z(1,1);
            newData.T = timePoint;
            newData.spline = [];
            newData.circ = [];
            newData.intensity = intensity;
            newData.profile = [1 ; profile];
            
            obj.addMeasurements(newData, n);
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            result = 1;
        end
        
        function result = DistanceFun(obj, handles, index, colCh, finetuneCheck)
            % function result = DistanceFun(obj, handles, index, colCh, finetuneCheck)
            % measuring of a two point distance
            %
            % Parameters:
            % handles: handles of im_browser
            % index: [@em Optional] an index of measurement to update; when
            % empty (@b [] ) - adds a new measurement
            % colCh: [@em optional] color channel to use for profile; @em default = 1
            % finetuneCheck: [@em optional] @b 1 (@em default) - allow fine-tuning during the placing of measurements; @b 0 - instant placing
            %
            % Return values:
            % result - 1-success, 0-cancel
            
            %|
            % @b Examples
            % @code Measure.DistanceFun(handles, [], 1); // get points and measure the distance between them. Calculate intensity profile for color channel 1 @endcode
            % @code Measure.DistanceFun(handles, 2, 1); // edit second measurement. @endcode
            
            % Credit: adapted from Image Measurement Utility by Jan Neggers
            % http://www.mathworks.com/matlabcentral/fileexchange/25964-image-measurement-utility
            if nargin < 5; finetuneCheck = 1; end;
            if nargin < 4; colCh = 1; end;
            if nargin < 3; index = []; end;
            
            result = 0;
            
            % temporary switch off selection
            %disableSelectionSwitch = handles.preferences.disableSelection;    % get current settings
            %handles.preferences.disableSelection = 'yes'; % disable selection
            %guidata(handles.im_browser, handles);   % store handles
            
            if isempty(index)   % add new measurement
                % select two preliminary points
                set(handles.imageAxes, 'NextPlot','add');
                [x,y,z,u,v] = getClickPoint(handles);
                h = plot(handles.imageAxes,u,v,'r+',u,v,'bo','markersize',10);
                [x(2),y(2),z(2),u(2),v(2)] = getClickPoint(handles);
                %h(3:4) = plot(handles.h.imageAxes, u,v,'r+',u,v,'bo','markersize',10);
                delete(h);
                set(handles.imageAxes, 'NextPlot','replace');
                if finetuneCheck
                    pos(:,1) = x;
                    pos(:,2) = y;
                    position = obj.drawROI(handles, 'imline', pos);
                else
                    position(:,1) = x;
                    position(:,2) = y;
                end
            else                % edit existing measurement
                tempData = obj.Data(index);     % store the current state
                obj.removeMeasurements(index);  % remove measurement
                handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                
                pos(:,1) = tempData.X;
                pos(:,2) = tempData.Y;
                position = obj.drawROI(handles, 'imline', pos);
            end
            
            % get Z-value
            z = handles.Img{handles.Id}.I.getCurrentSliceNumber();
            timePoint = handles.Img{handles.Id}.I.getCurrentTimePoint();
            
            % detect Cancel due to press of the Escape button
            if isempty(position);
                if exist('tempData','var')
                    obj.addMeasurements(tempData, tempData.n);  % restore the old state
                    handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
                end
                return;
            end;
            
            % calculate the distance (hypot = pythagoras)
            if handles.Img{handles.Id}.I.orientation == 1   % zx orientation
                A = diff(position(:,1))*handles.Img{handles.Id}.I.pixSize.z;
                B = diff(position(:,2))*handles.Img{handles.Id}.I.pixSize.x;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.no_stacks, 1:handles.Img{handles.Id}.I.width);
            elseif handles.Img{handles.Id}.I.orientation == 2   % zy orientation
                A = diff(position(:,1))*handles.Img{handles.Id}.I.pixSize.z;
                B = diff(position(:,2))*handles.Img{handles.Id}.I.pixSize.y;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.no_stacks, 1:handles.Img{handles.Id}.I.height);
            else        % xy orientation
                A = diff(position(:,1))*handles.Img{handles.Id}.I.pixSize.x;
                B = diff(position(:,2))*handles.Img{handles.Id}.I.pixSize.y;
                % create image space (for intensity)
                [x, y] = meshgrid(1:handles.Img{handles.Id}.I.width, 1:handles.Img{handles.Id}.I.height);
            end
            Distance = hypot(A,B);
            
            % store position for later plotting
            X = position(:,1);
            Y = position(:,2);
            
            % calculate a length vector
            t = [ 0 ; hypot(diff(X),diff(Y)) ];
            t = cumsum(t);
            
            % discretize the measurement line
            %Ni = 200;
            Ni = max(t);
            ti = linspace(0,max(t),Ni);
            xi = interp1(t,X,ti);
            yi = interp1(t,Y,ti);
            
            im = handles.Img{handles.Id}.I.getFullSlice('image', NaN, NaN, colCh);
            
            % interpolate the intensity profile along the measurement line
            for ch=1:size(im,3)
                profile(ch,:) = interp2(x,y,double(im(:,:,ch)),xi,yi); %#ok<AGROW>
            end
            %profile = ones([size(ti), 1]);
            % calculate the average intensity
            intensity = mean(profile,2);
            
            % store the measurement
            if isempty(index)
                n = obj.getNumberOfMeasurements + 1;
            else
                n = index;
            end
            newData.n = n;
            newData.type = cellstr('Distance (linear)');
            newData.value = Distance;
            newData.X = X;
            newData.Y = Y;
            newData.Z = z(1,1);
            newData.T = timePoint;
            newData.spline = [];
            newData.circ = [];
            newData.intensity = intensity;
            newData.profile = [ti ; profile];
            
            obj.addMeasurements(newData, n);
            % restore selected state for the selection
            % handles.preferences.disableSelection = disableSelectionSwitch;
            
            handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
            result = 1;
        end
    end
end