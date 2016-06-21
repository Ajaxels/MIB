function result = setData4D(obj, type, dataset, orient, col_channel, options)
% result = setData4D(obj, type, dataset, orient, col_channel, options)
% Set complete 5D dataset
%
% Parameters:
% type: type of the dataset to update, 'image', 'model','mask', 'selection', or 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% dataset: 4D or 5D stack. For the 'image' type: [1:height, 1:width, 1:colors, 1:depth, 1:time]; for all other types: [1:height, 1:width, 1:thickness, 1:time]
% orient: [@em optional], can be @em NaN
% @li when @b 0 (@b default) updates the dataset transposed from the current orientation (obj.orientation)
% @li when @b 1 returns transposed dataset from the zx configuration: [x,z,c,y,t] -> [y,x,c,z,t]
% @li when @b 2 returns transposed dataset from the zy configuration: [y,z,c,y,t] -> [y,x,c,z,t]
% @li when @b 3 not used
% @li when @b 4 returns original dataset from the yx configuration: [y,x,c,z,t]
% @li when @b 5 not used
% col_channel: [@em optional],
% @li when @b type is 'image', @b col_channel is a vector with color numbers to take, when @b NaN [@e default] take the colors
% selected in the imageData.slices{3} variable, when @b 0 - take all colors of the dataset.
% @li when @b type is 'model' @b col_channel may be @em NaN - to take all materials of the model or an integer to take specific material. In the later case the selected material will have index = 1.
% options: [@em optional], a structure with extra parameters
% @li .blockModeSwitch -> override the imageData.blockModeSwitch (@b 0 - update the full dataset, @b 1 - update only the shown part)
% @li .y -> [@em optional], [ymin, ymax] coordinates of the dataset to take after transpose, height
% @li .x -> [@em optional], [xmin, xmax] coordinates of the dataset to take after transpose, width
% @li .z -> [@em optional], [zmin, zmax] coordinates of the dataset to take after transpose, depth
% @li .t -> [@em optional], [tmin, tmax] coordinates of the dataset to take after transpose, time
%
% Return values:
% result: -> @b 1 - success, @b 0 - error

%|
% @b Examples:
% @code handles.Img{handles.Id}.I.setData4D('image', dataset);      // update the complete dataset in the shown orientation @endcode
% @code handles.Img{handles.Id}.I.setData4D('image', dataset, NaN, NaN, options.blockModeSwitch=1); // update the croped to the viewing window dataset, with shown colors @endcode
% @code handles.Img{handles.Id}.I.setData4D('image', dataset, 4, 2); // update complete dataset in the XY orientation with only second color channel @endcode
% @code obj.setData4D('image', dataset);      // Call within the class, update the complete dataset  @endcode
% @attention @b sensitive to the imageData.blockModeSwitch
% @attention @b not @b sensitive to the shown ROI
% @attention for normal calls it is recommended to use ib_getDataset.m wrapper function, as @code
% dataset = ib_getDataset('image', handles); @endcode

% Copyright (C) 03.09.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.01.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3};

result = 0; %#ok<NASGU>
if nargin < 6; options=struct(); end;
if nargin < 5; col_channel = NaN; end;
if nargin < 4; orient=obj.orientation; end;

% setting default values for the orientation
if orient == 0 || isnan(orient); orient=obj.orientation; end;

if ~isfield(options, 'blockModeSwitch'); options.blockModeSwitch = obj.blockModeSwitch; end;
blockModeSwitchLocal = obj.blockModeSwitch;
if isfield(options, 'y') || isfield(options, 'x') || isfield(options, 'z') || options.blockModeSwitch || (isfield(options, 't') && obj.time > 1)
    blockModeSwitchLocal = 1;
elseif isfield(options, 't') && obj.time == 1     % override the blockmode switch for 4D datasets
    blockModeSwitchLocal = 0;
end;

replaceDatasetSwitch = 0; % defines whether the dataset should be replaced, in a situation when width/height mismatch
if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0; col_channel = 1:size(obj.img,3); end;
    if (size(dataset,1) ~= size(obj.img,1) || size(dataset,2) ~= size(obj.img,2) || size(dataset,4) ~= size(obj.img,4) || ...
            ~strcmp(class(dataset), class(obj.img))) && options.blockModeSwitch == 0
        replaceDatasetSwitch = 1;
    end
end

if islogical(dataset(1)); dataset = uint8(dataset); end;

if blockModeSwitchLocal == 1
    % get coordinates of the shown block for the original dataset in
    % the yx dimension
    Xlim = [1 obj.width];
    Ylim = [1 obj.height];
    Zlim = [1 obj.no_stacks];
    
    if orient==1     % xz
        if isfield(options, 'x')
            Zlim = options.x;
        elseif options.blockModeSwitch
            Zlim = ceil(obj.axesX);
        end
        if isfield(options, 'z')
            Ylim = options.z;
        elseif options.blockModeSwitch
            Ylim = [1 obj.height];
        end
        if isfield(options, 'y')
            Xlim = options.y;
        elseif options.blockModeSwitch
            Xlim = ceil(obj.axesY);
        end
    elseif orient==2 % yz
        if isfield(options, 'x')
            Zlim = options.x;
        elseif options.blockModeSwitch
            Zlim = ceil(obj.axesX);
        end
        if isfield(options, 'y')
            Ylim = options.y;
        elseif options.blockModeSwitch
            Ylim = ceil(obj.axesY);
        end
        if isfield(options, 'z')
            Xlim = options.z;
        elseif options.blockModeSwitch
            Xlim = [1 obj.width];
        end
    elseif orient==4 % yx
        if isfield(options, 'x')
            Xlim = options.x;
        elseif options.blockModeSwitch
            Xlim = ceil(obj.axesX);
        end
        if isfield(options, 'y')
            Ylim = options.y;
        elseif options.blockModeSwitch
            Ylim = ceil(obj.axesY);
        end
        if isfield(options, 'z')
            Zlim = options.z;
        elseif options.blockModeSwitch
            Zlim = [1 obj.no_stacks];
        end
    end
    if isfield(options, 't')
        Tlim = options.t;
    else
        Tlim = [1 obj.time];
    end
    % make sure that the coordinates within the dimensions of the dataset
    Xlim = [max([Xlim(1) 1]) min([Xlim(2) obj.width])];
    Ylim = [max([Ylim(1) 1]) min([Ylim(2) obj.height])];
    Zlim = [max([Zlim(1) 1]) min([Zlim(2) obj.no_stacks])];
    Tlim = [max([Tlim(1) 1]) min([Tlim(2) obj.time])];
end

if ~strcmp(obj.model_type, 'uint6')  % uint8/int8 type of the model
    if blockModeSwitchLocal == 0     % set the full size dataset
        if strcmp(type,'image')
            if replaceDatasetSwitch
                if orient == 4 % yx
                    obj.img = dataset;
                elseif orient==1    % xz; get permuted dataset
                    obj.img = permute(dataset, [4 1 3 2 5]);
                elseif orient==2    % yz; get permuted dataset
                    obj.img = permute(dataset, [1 4 3 2 5]);
                end
            else
                if orient == 4 % yx
                    obj.img(:,:,col_channel,:,:) = dataset;
                elseif orient==1    % xz; get permuted dataset
                    obj.img(:,:,col_channel,:,:) = permute(dataset ,[4 1 3 2 5]);
                elseif orient==2    % yz; get permuted dataset
                    obj.img(:,:,col_channel,:,:) = permute(dataset,[1 4 3 2 5]);
                end
            end
        elseif strcmp(type,'model')
            if orient == 4 % yx
                if ~isnan(col_channel)     % take only specific object
                    obj.model(obj.model == col_channel) = 0;
                    obj.model(dataset == 1) = col_channel;
                else
                    obj.model = dataset;
                end
            elseif orient==1    % xz; get permuted dataset
                if ~isnan(col_channel)     % take only specific object
                    dataset = permute(dataset ,[3 1 2 4]);
                    obj.model(obj.model == col_channel) = 0;
                    obj.model(dataset == 1) = col_channel;
                else
                    obj.model = permute(dataset ,[3 1 2 4]);
                end
            elseif orient==2    % yz; get permuted dataset
                if ~isnan(col_channel)     % take only specific object
                    dataset = permute(dataset,[1 3 2 4]);
                    obj.model(obj.model == col_channel) = 0;
                    obj.model(dataset == 1) = col_channel;
                else
                    obj.model = permute(dataset,[1 3 2 4]);
                end
            end
            obj.modelExist = 1;
        elseif strcmp(type,'mask')
            if orient == 4 % yx
                obj.maskImg = dataset;
            elseif orient==1    % xz; get permuted dataset
                obj.maskImg = permute(dataset ,[3 1 2 4]);
            elseif orient==2    % yz; get permuted dataset
                obj.maskImg = permute(dataset,[1 3 2 4]);
            end
            obj.maskExist = 1;
        elseif strcmp(type,'selection')
            if orient == 4 % yx
                obj.selection = dataset;
            elseif orient==1    % xz; get permuted dataset
                obj.selection = permute(dataset ,[3 1 2 4]);
            elseif orient==2    % yz; get permuted dataset
                obj.selection = permute(dataset,[1 3 2 4]);
            end
        end
    else    % set the shown block
        if strcmp(type,'image')
            if orient==1     % xz
                dataset = permute(dataset,[4 1 3 2 5]);
            elseif orient==2 % yz
                dataset = permute(dataset,[1 4 3 2 5]);
            end
            obj.img(Ylim(1):Ylim(2),Xlim(1):Xlim(2),col_channel,Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = dataset;
        elseif strcmp(type,'model')
            if orient==1     % xz
                dataset = permute(dataset,[3 1 2 4]);
            elseif orient==2 % yz
                dataset = permute(dataset,[1 3 2 4]);
            end
            if ~isnan(col_channel)     % take only specific object
                currentDataset = obj.model(Zlim(1):Zlim(2),max([Ylim(1) 1]):min([Ylim(2) obj.width]),max([Xlim(1) 1]):min([Xlim(2) obj.no_stacks]));
                currentDataset(currentDataset == col_channel) = 0;
                currentDataset(dataset == 1) = col_channel;
                dataset = currentDataset;
            end
            obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = dataset;
        elseif strcmp(type,'mask')
            if obj.maskExist == 0  % create maskImg
                obj.maskImg = zeros(size(obj.img,1),size(obj.img,2),size(obj.img,4),size(obj.img,5),'uint8');
            end
            if orient==1     % xz
                dataset = permute(dataset,[3 1 2 4]);
            elseif orient==2 % yz
                dataset = permute(dataset,[1 3 2 4]);
            end
            obj.maskImg(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = dataset;
            obj.maskExist = 1;
        elseif strcmp(type,'selection')
            if orient==1     % xz
                dataset = permute(dataset,[3 1 2 4]);
            elseif orient==2 % yz
                dataset = permute(dataset,[1 3 2 4]);
            end
            obj.selection(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = dataset;
        end
    end
else        % ************ uint6 model type
    % the following part of the code is broken into two sections because it is faster
    if blockModeSwitchLocal == 0     % set the full size dataset
        if strcmp(type,'image')
            if replaceDatasetSwitch
                if orient == 4      % yx
                    obj.img = dataset;
                elseif orient==1    % xz; get permuted dataset
                    obj.img = permute(dataset, [4 1 3 2 5]);
                elseif orient==2    % yz; get permuted dataset
                    obj.img = permute(dataset, [1 4 3 2 5]);
                end
            else
                if orient == 4 % yx
                    obj.img(:,:,col_channel,:,:) = dataset;
                elseif orient==1    % xz; get permuted dataset
                    obj.img(:,:,col_channel,:,:) = permute(dataset ,[4 1 3 2 5]);
                elseif orient==2    % yz; get permuted dataset
                    obj.img(:,:,col_channel,:,:) = permute(dataset,[1 4 3 2 5]);
                end
            end
        else    % set all other layers: model, mask, selection
            % permute dataset if needed
            if orient==1     % xz
                dataset = permute(dataset ,[3 1 2 4]);
            elseif orient==2 % yz
                dataset = permute(dataset,[1 3 2 4]);
            end
            
            switch type
                case 'model'
                    if ~isnan(col_channel)     % set only specific object
                        obj.model(bitand(dataset, 1)==1) = bitand(obj.model(bitand(dataset, 1)==1), 192);  % 192 = 11000000, remove Material from the model
                        obj.model(dataset==1) = bitor(obj.model(dataset==1), col_channel);
                    else
                        obj.model = bitand(obj.model, 192); % clear current model
                        obj.model = bitor(obj.model, dataset);
                    end
                case 'mask'
                    obj.model = bitset(obj.model, 7, 0);    % clear current mask
                    obj.model = bitor(obj.model, dataset*64);
                    obj.maskExist = 1;
                case 'selection'
                    obj.model = bitset(obj.model, 8, 0);    % clear existing selection
                    obj.model = bitor(obj.model, dataset*128);
                case 'everything'
                    obj.model = dataset;
            end
        end
    else        % get the shown block
        if strcmp(type,'image')
            if orient==1     % permute from xz
                dataset = permute(dataset,[4 1 3 2 5]);
            elseif orient==2 % permute from yz
                dataset = permute(dataset,[1 4 3 2 5]);
            end
            obj.img(Ylim(1):Ylim(2),Xlim(1):Xlim(2),col_channel,Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = dataset;
        else
            if orient==1     % permute to xz
                dataset = permute(dataset,[3 1 2 4]);
            elseif orient==2 % permute to yz
                dataset = permute(dataset,[1 3 2 4]);
            end
            
            switch type
                case 'model'
                    if ~isnan(col_channel)     % take only specific object
                        currentDataset = obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2));
                        currentDataset(bitand(currentDataset, col_channel)==col_channel) = bitand(currentDataset(bitand(currentDataset, col_channel)==col_channel), 192);  % 192 = 11000000, remove Material from the model
                        currentDataset(dataset==1) = bitor(currentDataset(dataset==1), col_channel);
                        obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = currentDataset;
                    else
                        currentDataset = bitand(obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)), 192); % clear current model    
                        obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = bitor(currentDataset, dataset);
                    end
                case 'mask'
                    currentDataset = obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2));
                    currentDataset = bitset(currentDataset,7,0);    % clear mask
                    currentDataset = bitor(currentDataset, dataset*64);
                    obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = currentDataset;
                    obj.maskExist = 1;
                case 'selection'
                    currentDataset = obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2));
                    currentDataset = bitset(currentDataset,8,0);    % clear selection
                    currentDataset = bitor(currentDataset, dataset*128);
                    obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = currentDataset;
                case 'everything'
                    obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2)) = dataset;
            end
        end
    end
end

% update obj.height, obj.width, etc
if strcmp(type,'image') && blockModeSwitchLocal == 0
    obj.height = size(obj.img, 1);
    obj.width = size(obj.img, 2);
    obj.no_stacks = size(obj.img, 4);
    obj.time = size(obj.img, 5);
    obj.img_info('Height') = size(obj.img, 1);
    obj.img_info('Width') = size(obj.img, 2);
    obj.img_info('Stacks') = size(obj.img, 4);
    obj.img_info('Time') = size(obj.img, 5);
    
    % update I.slices
    currSlices = obj.slices;
    obj.slices{1} = [1, obj.height];
    obj.slices{2} = [1, obj.width];
    obj.slices{3} = 1:size(obj.img,3);
    obj.slices{4} = [1, size(obj.no_stacks,4)];
    obj.slices{5} = [1, 1];
    
    if currSlices{obj.orientation}(1) > size(obj.img, obj.orientation)
        obj.slices{obj.orientation} = [size(obj.img, obj.orientation), size(obj.img, obj.orientation)];
    else
        obj.slices{obj.orientation} = currSlices{obj.orientation};
    end
    
    obj.current_yxz(1) = min([obj.current_yxz(1) obj.height]);
    obj.current_yxz(2) = min([obj.current_yxz(2) obj.width]);
    obj.current_yxz(3) = min([obj.current_yxz(3) obj.no_stacks]);
end
if strcmp(type, 'model'); obj.modelExist = 1; end;


result = 1;