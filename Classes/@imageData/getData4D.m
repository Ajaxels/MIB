function dataset = getData4D(obj, type, orient, col_channel, options, custom_img) % get complete 4D dataset
% function dataset = getData4D(obj, type, orient, col_channel, options, custom_img)
% Get complete 4D dataset
%
% Parameters:
% type: type of the dataset to retrieve, 'image', 'model','mask', 'selection', or 'everything' ('model','mask' and 'selection' for imageData.model_type==''uint6'' only)
% orient: [@em optional], can be @em NaN
% @li when @b 0 (@b default) returns the dataset transposed to the current orientation (obj.orientation)
% @li when @b 1 returns transposed dataset to the zx configuration: [y,x,c,z,t] -> [x,z,c,y,t]
% @li when @b 2 returns transposed dataset to the zy configuration: [y,x,c,z,t] -> [y,z,c,y,t]
% @li when @b 3 not used
% @li when @b 4 returns original dataset to the yx configuration: [y,x,c,z,t]
% @li when @b 5 not used
% col_channel: [@em optional],
% @li when @b type is 'image', @b col_channel is a vector with color numbers to take, when @b NaN [@e default] take the colors
% selected in the imageData.slices{3} variable, when @b 0 - take all colors of the dataset.
% @li when @b type is 'model' @b col_channel may be @em NaN - to take all materials of the model or an integer to take specific material. In the later case the selected material will have index = 1.
% options: [@em optional], a structure with extra parameters
% @li .blockModeSwitch -> override the imageData.blockModeSwitch (@b 0 - return full dataset, @b 1 - return only the shown part)
% @li .y -> [@em optional], [ymin, ymax] coordinates of the dataset to take after transpose, height
% @li .x -> [@em optional], [xmin, xmax] coordinates of the dataset to take after transpose, width
% @li .z -> [@em optional], [zmin, zmax] coordinates of the dataset to take after transpose, depth
% @li .t -> [@em optional], [tmin, tmax] coordinates of the dataset to take after transpose, time
%
% Return values:
% dataset: 4D or 5D stack. For the 'image' type: [1:height, 1:width, 1:colors, 1:depth, 1:time]; for all other types: [1:height, 1:width, 1:thickness, 1:time]

%|
% @b Examples:
% @code dataset = handles.Img{handles.Id}.I.getData4D('image');      // get the complete dataset in the shown orientation @endcode
% @code dataset = handles.Img{handles.Id}.I.getData4D('image', NaN, NaN, options.blockModeSwitch=1); // get the croped to the viewing window dataset, with shown colors @endcode
% @code dataset = handles.Img{handles.Id}.I.getData4D('image', 4, 2); // get complete dataset in the XY orientation with only second color channel @endcode
% @code dataset = obj.getData4D('image');      // Call within the class, get the complete dataset  @endcode
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
% 18.09.2016, changed .slices to cells


if nargin < 6; custom_img=NaN; end;
if nargin < 5; options=struct(); end;
if nargin < 4; col_channel = NaN; end;
if nargin < 3; orient=obj.orientation; end;

% setting default values for the orientation
if orient == 0 || isnan(orient); orient=obj.orientation; end;

if ~isfield(options, 'blockModeSwitch'); options.blockModeSwitch = obj.blockModeSwitch; end;
blockModeSwitchLocal = obj.blockModeSwitch;
if isfield(options, 'y') || isfield(options, 'x') || isfield(options, 'z') || options.blockModeSwitch || (isfield(options, 't') && obj.time > 1)
    blockModeSwitchLocal = 1;
elseif isfield(options, 't') && obj.time == 1     % override the blockmode switch for 4D datasets
    blockModeSwitchLocal = 0;
end;

if strcmp(type,'image')
    if isnan(col_channel); col_channel=obj.slices{3}; end;
    if col_channel(1) == 0;  col_channel = 1:size(obj.img,3); end;
end

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

if ~strcmp(obj.model_type, 'uint6')
    if blockModeSwitchLocal == 0     % get the full size dataset
        if strcmp(type,'image')
            if orient == 4 % yx
                dataset = obj.img(:,:,col_channel,:,:);
            elseif orient==1    % xz; get permuted dataset
                dataset = permute(obj.img(:,:,col_channel,:),[2 4 3 1 5]);
            elseif orient==2    % yz; get permuted dataset
                dataset = permute(obj.img(:,:,col_channel,:),[1 4 3 2 5]);
            end
        elseif strcmp(type,'model')
            if ~isnan(col_channel)     % take only specific object
                dataset = zeros(size(obj.model), class(obj.model));   %#ok<*ZEROLIKE>
                dataset(obj.model == col_channel) = 1;
            else
                dataset = obj.model;
            end
            if orient==1    % xz; get permuted dataset
                dataset = permute(dataset,[2 3 1 4]);
            elseif orient==2    % yz; get permuted dataset
                dataset = permute(dataset,[1 3 2 4]);
            end
        elseif strcmp(type,'mask')
            if orient == 4 % yx
                dataset = obj.maskImg;
            elseif orient==1    % xz; get permuted dataset
                dataset = permute(obj.maskImg,[2 3 1 4]);
            elseif orient==2    % yz; get permuted dataset
                dataset = permute(obj.maskImg,[1 3 2 4]);
            end
        elseif strcmp(type,'selection')
            if orient == 4 % yx
                dataset = obj.selection;
            elseif orient==1    % xz; get permuted dataset
                dataset = permute(obj.selection,[2 3 1 4]);
            elseif orient==2    % yz; get permuted dataset
                dataset = permute(obj.selection,[1 3 2 4]);
            end
        end
    else    % get the shown block
        if strcmp(type,'image')
            dataset = obj.img(Ylim(1):Ylim(2),Xlim(1):Xlim(2),col_channel,Zlim(1):Zlim(2),Tlim(1):Tlim(2));
            if orient==1     % permute to xz
                dataset = permute(dataset,[2 4 3 1 5]);
            elseif orient==2 % permute to yz
                dataset = permute(dataset,[1 4 3 2 5]);
            end
        elseif strcmp(type,'model')
            dataset = obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2));
            if orient==1     % xz
                dataset = permute(dataset,[2 3 1 4]);
            elseif orient==2 % yz
                dataset = permute(dataset,[1 3 2 4]);
            end
            if ~isnan(col_channel)     % take only specific object
                dataset2 = zeros(size(dataset), class(dataset));
                dataset2(dataset == col_channel) = 1;
                dataset = dataset2;
                clear dataset2;
            end
        elseif strcmp(type,'mask')
            dataset = obj.maskImg(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2));
            if orient==1     % xz
                dataset = permute(dataset,[2 3 1 4]);
            elseif orient==2 % yz
                dataset = permute(dataset,[1 3 2 4]);
            end
        elseif strcmp(type,'selection')   
            dataset = obj.selection(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2));
            if orient==1     % xz
                dataset = permute(dataset,[2 3 1 4]);
            elseif orient==2 % yz
                dataset = permute(dataset,[1 3 2 4]);
            end
        end
    end
else            % ************ uint6 model type
    % the following part of the code is broken into two sections because it is faster
    if blockModeSwitchLocal == 0     % get the full size dataset
        if strcmp(type,'image')
            dataset = obj.img(:,:,col_channel,:,:);
            if orient==1    % xz; get permuted dataset
                dataset = permute(dataset,[2 4 3 1 5]);
            elseif orient==2    % yz; get permuted dataset
                dataset = permute(dataset,[1 4 3 2 5]);
            end
        else
            if orient == 4 % yx
                dataset = obj.model;
            elseif orient==1     % xz
                dataset = permute(obj.model,[2 3 1 4]);
            elseif orient==2 % yz
                dataset = permute(obj.model,[1 3 2 4]);
            end
            switch type
                case 'model'
                    if ~isnan(col_channel)     % take only specific object
                        dataset = uint8(bitand(dataset, 63)==col_channel(1));
                    else
                        dataset = bitand(dataset, 63);     % get all model objects
                    end
                case 'mask'
                    dataset = bitand(dataset, 64)/64;  % 64 = 01000000
                case 'selection'
                    dataset = bitand(dataset, 128)/128;  % 128 = 10000000
                case 'everything'
                    % do nothing
            end
        end
    else        % get the shown block
        if strcmp(type,'image')
            dataset = obj.img(Ylim(1):Ylim(2),Xlim(1):Xlim(2),col_channel,Zlim(1):Zlim(2),Tlim(1):Tlim(2));
            if orient==1     % permute to xz
                dataset = permute(dataset,[2 4 3 1 5]);
            elseif orient==2 % permute to yz
                dataset = permute(dataset,[1 4 3 2 5]);
            end
        else
            dataset = obj.model(Ylim(1):Ylim(2),Xlim(1):Xlim(2),Zlim(1):Zlim(2),Tlim(1):Tlim(2));
            if orient==1     % permute to xz
                dataset = permute(dataset,[2 3 1 4]);
            elseif orient==2 % permute to yz
                dataset = permute(dataset,[1 3 2 4]);
            end
            
            switch type
                case 'model'
                    if ~isnan(col_channel)     % take only specific object
                        dataset = uint8(bitand(dataset, 63)==col_channel(1));
                    else
                        dataset = bitand(dataset, 63);     % get all model objects
                    end
                case 'mask'
                    dataset = bitand(dataset, 64)/64;  % 64 = 01000000
                case 'selection'
                    dataset = bitand(dataset, 128)/128;  % 128 = 10000000
                case 'everything'
                    % do nothing
            end
        end
    end
end
end