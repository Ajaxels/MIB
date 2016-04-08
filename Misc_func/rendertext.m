function out=rendertext(target, text, color, pos, mode1, mode2)
% function out=rendertext(target, text, color, pos, mode1, mode2)
%Render RGB text over RGB or grayscale images by Davide Di Gloria with the great contribution of Franz-Gerold Url
%
% Parameters:
% target: MxNx3 or MxN matrix (grayscale will be converted to RGB)
% text: string (NO LINE FEED SUPPORT)
% color: vector in the form [r g b] 0-255
% pos: position (r,c) 
% mode1: [@em optional] 'ovr' to overwrite, 'bnd' to blend text over image; @b default is 'ovr'
% mode2: [@em optional] text aligment 'left', 'mid'  or 'right'; @b default is 'right'
%
% Return values:
% out: output, has the same size of target

%| @b Example:
% @code
% in=imread('football.jpg');
% out=rendertext(in,'OVERWRITE mode',[0 255 0], [1, 1]);
% out=rendertext(out,'BLEND mode',[255 0 255], [30, 1], 'bnd', 'left');
% out=rendertext(out,'left',[0 0 255], [101, 150], 'ovr', 'left');
% out=rendertext(out,'mid',[0 0 255], [130, 150], 'ovr', 'mid');
% out=rendertext(out,'right',[0 0 255], [160, 150], 'ovr', 'right');
% imshow(out);
% @endcode


if nargin == 4
    mode1='ovr';
    mode2='left';
end

dim = length(size(target));
if dim == 2
  target = cat(3, target, target, target);
end

pos = uint16(pos);

r=color(1);
g=color(2);
b=color(3);

n=uint16(numel(text));

base=uint8(1-logical(imread('chars.bmp')));
base=cat(3, base*r, base*g, base*b);

table='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890''м!"Ј$%&/()=?^и+тащ,.-<\|;:_>з°§й*@#[]{} ';

coord(2,n)=0;
for i=1:n    
  coord(:,i)= [0 find(table == text(i))-1];
end

m = floor(coord(2,:)/26);
coord(1,:) = m*20+1;
coord(2,:) = (coord(2,:)-m*26)*13+1;

model = uint8(zeros(20,n*13,3));
for i=1:n
  model(:, (13*i-12):(i*13), :) = imcrop(base,[coord(2,i) coord(1,i) 12 19]);
end

dim = uint16(size(model(:,:,1)));

if strcmp(mode2, 'mid') == 1
  pos = pos-dim/2+1;
elseif strcmp(mode2, 'right') == 1
  pos = pos-dim+1;
elseif strcmp(mode2, 'left') ~= 1
  error('%s not allowed as alignment specifier. (Allowed: left, mid  or right)', mode2)
end

dim_img = uint16(size(target(:,:,1)));
if sum(dim > dim_img) ~= 0
    error('The text is too long for this image.')
end 

pos = min(dim_img,pos+dim)-dim;

area_y = pos(1):(pos(1)+size(model,1)-1);
area_x = pos(2):(pos(2)+size(model,2)-1);

if strcmp(mode1, 'ovr') == 1
  target(area_y, area_x,:)=model; 
elseif strcmp(mode1,'bnd') == 1
  area = target(area_y, area_x, :);
  area(model~=0) = 0;
  target(area_y, area_x, :) = model + area;
else
  error('%s is a wrong model mode (allowed: ovr or bnd)', mode1)
end

out=target;


