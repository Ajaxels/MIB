classdef imageUndo < handle
    % This class is resposnible to store the previous versions of the dataset, to be used for Undo (Ctrl+Z) command
    
    % The usage of this class is implemented via Ctrl+Z short cut. It allows to return one step back to the previous version of the
    % dataset. It works with @em do_undo function of im_browser.m
    % @attention Use of undo, increase memory consumption. The Undo may be switched off in the @em Preferences of
    % im_browser.m: @em Menu->File->Preferences
	
	% Copyright (C) 19.05.2014 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
	% 
	% This program is free software; you can redistribute it and/or
	% modify it under the terms of the GNU General Public License
	% as published by the Free Software Foundation; either version 2
	% of the License, or (at your option) any later version.
	%
	% Updates
	% 28.03.2016, IB, replaced .sliceNo, and .timePnt with .x, .y, .z, .t fields

    properties (SetAccess = public, GetAccess = public)
        enableSwitch         % Enable/disable undo operation
        % a variable to store whether Undo is available or not:
        % @li @b 1 - enable
        % @li @b 0 - disable
        type
        % a variable to store type of the data: ''image'', ''model'', ''selection'', ''mask'','labels',''measurement'',''everything'' (for imageData.model_type==''uint6'' only)
        undoList
        % a structure to store the list of the actions for undo
        % @li @b .type - type of the data: ''image'', ''model'', ''selection'', ''mask'', 'labels',''measurement'',''everything'' (for imageData.model_type==''uint6'' only)
        % @li @b .data - a field to store a 3D dataset or 2D slice
        % @li @b .img_info - img_info containers.Map , for the ''image'' type
        % @li @b .orient - orientation of the slice, @b 1 - xz, @b 2 - yz, @b 4 - yx
        % @li @b .x - vector with .x values
        % @li @b .y - vector with .y values
        % @li @b .z - vector with .z values
        % @li @b .t - vector with .t values
        max_steps
        % a variable to limit maximal number of history steps
        max3d_steps
        % a variable to limit maximal number of history for the 3D datasets
        undoIndex
        % a variable to keep index of @em NaN (currently restored dataset) element of the undoList structure
        prevUndoIndex
        % a variable to keep previous index of NaN element of the undoList structure, for use with Ctrl+Z
        index3d
        % an array of indeces of the 3D datasets
    end
    
    events
        none   %
    end
    
    methods
        function obj = imageUndo(max_steps, max3d_steps)
            % function obj = imageUndo(max_steps, max3d_steps)
            % imageUndo class constructor
            %
            % Constructor for the imageUndo class. Create a new instance of
            % the class with default parameters
            %
            % Parameters:
            % max_steps: maximal length of the history log
            % max3d_steps: maximal length of the 3D history log
            
            obj.max_steps = max_steps;
            obj.max3d_steps = max3d_steps;
            obj.clearContents();
        end
        
        function clearContents(obj)
            % function clearContents(obj)
            % Set all elements of the class to default values
            
            %| 
			% @b Examples:
            % @code imageUndo.clearContents(); @endcode
            % @code clearContents(obj); // Call within the class @endcode
            
            obj.type = '';
            obj.undoList = struct('type', NaN, 'data', NaN, 'img_info', NaN, 'orient', NaN, 'x', NaN, 'y', NaN, 'z', NaN, 't', NaN);
            obj.undoIndex = 1;
            obj.prevUndoIndex = 0;
            obj.index3d = [];
        end
        
        function store(obj, type, data, img_info, options)
            % function store(obj, type, data, img_info, options)
            % Store the data
            %
            % Parameters:
            % type: a string that defines the type of the stored data: ''image'', ''model'', ''selection'', ''mask'', ''everything'' (for imageData.model_type==''uint6'' only)
            % data: a variable with actual 3D or 2D dataset to store
            % img_info: [@em optional] a imageData.img_info containers.Map, not required for ''model'', ''selection'', ''mask'', ''everything'', can be @em NaN
            % options: a structure with fields:
            % @li .orient -> [@em optional], a number with the orientation of the dataset
            % @li .y -> [@em optional], [ymin, ymax] of the part of the dataset to store
            % @li .x -> [@em optional], [xmin, xmax] of the part of the dataset to store
            % @li .z -> [@em optional], [zmin, zmax] of the part of the dataset to store
            % @li .z -> [@em optional], [tmin, tmax] of the part of the dataset to store
            
            %| 
			% @b Examples:
            % @code storeOptions.t = [5 5]; @endcode
            % @code imageUndo.store('image', img, img_info, storeOptions); // store 3D image dataset at the 5th time point @endcode
            % @code store(obj, 'selection', selection, NaN, storeOptions); // Call within the class; store selection at the 5th time point @endcode
            
            if obj.enableSwitch == 0; return; end;
            if nargin < 5; options = struct(); end;
            if nargin < 4; img_info = NaN; end;
            if nargin < 3; error('Store Undo: please provide type and data to store!'); end;
            
            if ~isfield(options, 'orient'); options.orient = NaN; end; % options.orient = NaN identifies 3D dataset
            if ~isfield(options, 'x'); options.x = [1, size(data,2)]; end;
            if ~isfield(options, 'y'); options.y = [1, size(data,1)]; end;
            if strcmp(type, 'image')
                if ~isfield(options, 'z'); options.z = [1, size(data,4)]; end;
                if ~isfield(options, 't'); options.t = [1, size(data,5)]; end;
            else
                if ~isfield(options, 'z'); options.z = [1, size(data,3)]; end;
                if ~isfield(options, 't'); options.t = [1, size(data,4)]; end;
            end
            
            % crop undoList
            if isnan(options.orient) && obj.max3d_steps == 0 && size(data,4) > 1
                clearContents(obj);
                return;
            else
                obj.undoList = obj.undoList(1:obj.undoIndex);
                obj.index3d = obj.index3d(obj.index3d < obj.undoIndex);
            end
            if isnan(options.t(1)); options.t = [1 1]; end;
                
            % calculate number of stored 3d datasets
            newMinIndex = 1;
            if isnan(options.orient)    % adding 3D dataset
                if (numel(obj.index3d)) == obj.max3d_steps - 1 && obj.max3d_steps > 1
                    newMinIndex = obj.index3d(1)+1;   % the element of obj.undoList with this index is going to be number 1
                elseif (numel(obj.index3d)) == obj.max3d_steps && obj.max3d_steps == 1
                    newMinIndex = obj.index3d(1) + 1;   % tweak for a single stored 3D dataset
                elseif(numel(obj.undoList)) == obj.max_steps + 1
                    newMinIndex = 2;
                end
            else
                if(numel(obj.undoList)) == obj.max_steps + 1
                    newMinIndex = 2;
                end
            end
            
            % shift undoList when it gets overloaded
            obj.undoList = obj.undoList(newMinIndex:end);
            % update index3d
            obj.index3d = obj.index3d - (newMinIndex - 1);
            obj.index3d = obj.index3d(obj.index3d>0);
            
            % to check for entry of the first element
            if isstruct(obj.undoList(1).data)
                obj.undoIndex = numel(obj.undoList) + 1;
            else
                if ~isnan(obj.undoList(1).data(1))
                    obj.undoIndex = numel(obj.undoList) + 1;
                else
                    obj.undoIndex = 2;
                end    
            end
            
            obj.prevUndoIndex = obj.undoIndex - 1;
            
            obj.undoList(obj.undoIndex-1).type = type;
            obj.undoList(obj.undoIndex-1).data = data;
            
            % containers.Map is a class and should be reinitialized,
            % the plain copy (obj.undoList(obj.undoIndex-1).img_info = img_info) results in just a new copy of its handle
            if isa(img_info, 'double')
                obj.undoList(obj.undoIndex-1).img_info = NaN;
            else
                obj.undoList(obj.undoIndex-1).img_info = containers.Map(img_info.keys,img_info.values);
            end
            
            obj.undoList(obj.undoIndex-1).orient = options.orient;
            %obj.undoList(obj.undoIndex-1).sliceNo = sliceNo;
            %obj.undoList(obj.undoIndex-1).timePnt = timePnt;
            obj.undoList(obj.undoIndex-1).x = options.x;
            obj.undoList(obj.undoIndex-1).y = options.y;
            obj.undoList(obj.undoIndex-1).z = options.z;
            obj.undoList(obj.undoIndex-1).t = options.t;
            %obj.undoList(obj.undoIndex-1).timePnt = timePnt;
            
            
            obj.undoList(obj.undoIndex).type = NaN;
            obj.undoList(obj.undoIndex).data = NaN;
            obj.undoList(obj.undoIndex).img_info = NaN;
            obj.undoList(obj.undoIndex).orient = NaN;
            obj.undoList(obj.undoIndex).x = NaN;
            obj.undoList(obj.undoIndex).y = NaN;
            obj.undoList(obj.undoIndex).z = NaN;
            obj.undoList(obj.undoIndex).t = NaN;
            %obj.undoList(obj.undoIndex).sliceNo = NaN;
            %obj.undoList(obj.undoIndex).timePnt = NaN;
            
            if isnan(options.orient);
                obj.index3d(end+1) = obj.undoIndex-1;
            end;
        end
        
        function [type, data, img_info, options] = undo(obj, index)
            % function [type, data, img_info, options] = undo(obj, index)
            % Recover the stored dataset
            %
            % Parameters:
            % index: [@em Optional] - index of the dataset to restore. When omitted return the last stored dataset
            %
            % Return values:
            % type: a string that defines the type of the stored data: ''image'', ''model'', ''selection'', ''mask'', ''everything'' (for imageData.model_type==''uint6'' only)
            % data: a variable where to retrieve the dataset
            % img_info: [@em optional, NaN for 2D] a imageData.img_info containers.Map, not required for ''model'', ''selection'', ''mask'', ''everything''
            % options: a structure with fields:
            % @li .orient -> [@em optional], a number with the orientation of the dataset, for 2D slices; or NaN for 3D
            % @li .y -> [@em optional], [ymin, ymax] coordinates of the stored of the part of the dataset
            % @li .x -> [@em optional], [xmin, xmax] coordinates of the stored of the part of the dataset
            % @li .z -> [@em optional], [zmin, zmax] coordinates of the stored of the part of the dataset
            % @li .z -> [@em optional], [tmin, tmax] coordinates of the stored of the part of the dataset
            
            %| 
			% @b Examples:
            % @code [type, img, img_info, options] = imageUndo.undo(); // recover the image @endcode
            % @code [type, img] = undo(obj); // Call within the class; recover the image @endcode
            if obj.enableSwitch == 0; return; end;
            if nargin < 2;
                if obj.undoIndex == numel(obj.undoList)
                    index = obj.undoIndex - 1;
                else
                    index = obj.undoIndex + 1;
                end
            end;
            
            type = obj.undoList(index).type;
            data = obj.undoList(index).data;
            %img_info = obj.undoList(index).img_info;
            if isa(obj.undoList(index).img_info, 'double')  % means NaN
                img_info = NaN;
            else
                % containers.Map is a class and should be reinitialized,
                % the plain copy (obj.undoList(obj.undoIndex-1).img_info = img_info) results in just a new copy of its handle
                img_info = containers.Map(obj.undoList(index).img_info.keys, obj.undoList(index).img_info.values);
            end
            options.orient = obj.undoList(index).orient;
            options.x = obj.undoList(index).x;
            options.y = obj.undoList(index).y;
            options.z = obj.undoList(index).z;
            options.t = obj.undoList(index).t;

            obj.undoIndex = index;
        end
        
        
        function removeItem(obj, index)
            % function removeItem(obj, index)
            % Delete a stored item
            %
            % Parameters:
            % index: [@em optional] - index of the item to remove, when empty will remove the last entry
            
            %| 
			% @b Examples:
            % @code imageUndo.removeItem(5); // delete item number 5 @endcode
            % @code removeItem(obj, 5); // Call within the class; delete item number 5 @endcode
            if nargin < 2; index = numel(obj.undoList); end;
            if obj.undoIndex >= index; obj.undoIndex = obj.undoIndex - 1; end;
            vector = 1:numel(obj.undoList);
            obj.undoList = obj.undoList(vector ~= index);
        end
        
        function replaceItem(obj, index, type, data, img_info, options)
            % function replaceItem(obj, index, type, data, img_info, options)
            % Replace the stored item with a new dataset
            %
            % Parameters:
            % index: an index of the item to replace, when @em empty replace the last entry
            % type: a string that defines the type of the new dataset:  ''image'', ''model'', ''selection'', ''mask'', ''everything'' (for imageData.model_type==''uint6'' only)
            % data: a variable with the new dataset to store
            % img_info: [@em optional] imageData.img_info containers.Map, not required for ''model'', ''selection'', ''mask'', ''everything'', can be @em NaN
            % options: a structure with fields:
            % @li .orient -> [@em optional], a number with the orientation of the dataset
            % @li .y -> [@em optional], [ymin, ymax] of the part of the dataset to store
            % @li .x -> [@em optional], [xmin, xmax] of the part of the dataset to store
            % @li .z -> [@em optional], [zmin, zmax] of the part of the dataset to store
            % @li .z -> [@em optional], [tmin, tmax] of the part of the dataset to store
            
            %| 
			% @b Examples:
            % @code storeOptions.t = [5 5]; @endcode
            % @code imageUndo.replaceItem(1, 'image', img, img_info, storeOptions); // replace the 1st stored dataset @endcode
            % @code replaceItem(obj, 1, 'selection', selection, storeOptions); // Call within the class; replace the 1st stored dataset  @endcode
            
            %if nargin < 7; orient=NaN; sliceNo=NaN; end;
            %if nargin < 6; timePnt=1; end;
            if nargin < 6; options=struct(); end;
            if nargin < 5; img_info=NaN; end;
            if nargin < 3; type=NaN; data=NaN; end;
            if index < 1 || index > numel(obj.undoList); error('Undo:replaceItem wrong index!'); end;
            
            if ~isfield(options, 'orient'); options.orient = NaN; end; % options.orient = NaN identifies 3D dataset
            if ~isfield(options, 'x'); options.x = [1, size(data,2)]; end;
            if ~isfield(options, 'y'); options.y = [1, size(data,1)]; end;
            if ~isfield(options, 'z'); options.z = [1, size(data,4)]; end;
            if ~isfield(options, 't'); options.t = [1, size(data,5)]; end;
            
            obj.undoList(index).type = type;
            obj.undoList(index).data = data;
            obj.undoList(index).img_info = img_info;
            obj.undoList(index).orient = options.orient;
            obj.undoList(index).x = options.x;
            obj.undoList(index).y = options.y;
            obj.undoList(index).z = options.z;
            obj.undoList(index).t = options.t;

            if obj.max3d_steps == 1     % tweak for a single stored 3D dataset
                obj.index3d = index;
            else
                obj.index3d = obj.index3d(obj.index3d ~= index);
                if isnan(options.orient)
                    obj.index3d = sort([obj.index3d index]);
                end
            end
        end
    end
end
