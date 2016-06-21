function [block_width, block_height] = generate_grid_block_size(image_width, image_height, block_width)
% function [block_width, block_height] = generate_grid_block_size(image_width, image_height, block_width)
% Calculate size of the block to equally brake the image
%
% Parameters:
% image_width: width of the image
% image_height: height of the image
% block_width: [@em optional] desired width of the block, when omitted a
% dialog asks for a value
% 
% Return values:
% block_width: width of the block
% block_height height of the block

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

block_height = 0;
if nargin < 3; 
    %answer = inputdlg(sprintf('Enter approximate width of a block:\n(Area width=%d, height=%d)',image_width,image_height),'Block parameters',1,{'30'},'on'); 
    answer = mib_inputdlg(NaN, sprintf('Enter approximate width of a block:\n(Area width=%d, height=%d)',image_width,image_height),'Block parameters','30'); 
    if size(answer) == 0; return; end; 
    block_width = str2double(answer{1});
end

hor_blocks = ceil(image_width/block_width);
bl_w = round(image_width/hor_blocks);
vert_blocks = ceil(image_height/block_width);
block_height = round(image_height/vert_blocks);
block_width = bl_w;

%disp(['Area Width=' num2str(image_width) ' Height=' num2str(image_height) '; Block size: Width=' num2str(block_width) ' Height=' num2str(block_height)]);
end