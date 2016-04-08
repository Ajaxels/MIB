function [img, status] = do_diplib_andiff_filtering(img, options)
% function [img, status] = do_diplib_andiff_filtering(img, options)
% Anisotropic diffusion filters from the Diplib library (http://www.diplib.org)
%
% Parameters:
% img: -> input image img{roi}(1:height, 1:width, 1:color, 1:layers)
% options: -> structure with parameters
% - .Filter = ''pmd'',  Perona Malik anisotropic diffusion, diplib
% - .Filter = ''aniso'',   Robust Anisotropic Diffusion using Tukey error norm, diplib
% - .Filter = ''mcd'',   Mean Curvature Diffusion, diplib
% - .Filter = ''cpf'',   Nonlinear Diffusion using Corner Preserving Formula (improved over MCD), diplib
% - .Filter = ''kuwahara'',   Kuwahara filter for edge-preserving smoothing, diplib
% - .Iter -> number of iterations, or shape of the kuwahara filter (0-rectangular, 1-elliptic, 2-diamond)
% - .KSigma -> K, edge stopping parameter (pmd), or Sigma,
% - .Lambda -> rate parameter (pmd, aniso)
% - .Orientation -> orientation parameter: 4-for xy, 1-for xz, 2-for yz
% - .start_no -> first index
% - .end_no -> start index
% - .Color -> color channel, when 0, do for all colors
%
% Return values:
% img: -> output image
% status: -> @b 1 - success, @b 0 - fail

% Copyright (C) 21.05.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


status = 0; %#ok<NASGU>

if ~isfield(options, 'Color')
    options.Color = 0;
end

if options.Color == 0
    colorStart = 1;
    colorEnd = size(img,3);
    colors = colorEnd;
else
    colorStart = options.Color;
    colorEnd = options.Color;
    colors = 1;
end
wb = waitbar(0,sprintf('Filtering the image (Color:%d) with %s filter...', options.Color, options.Filter),'Name','Anisotropic Diffusion');
% modify for parallel run
iter = options.Iter;
filter = options.Filter;
KSigma = options.KSigma;
Lambda = options.Lambda;

if iter == 0;   kuwa_shape = 'rectangular';
elseif iter == 1;  kuwa_shape = 'elliptic';
else kuwa_shape = 'diamond';
end

for roi=1:numel(img)
    for color=colorStart:colorEnd
        for layer = options.start_no:options.end_no
            % convert to diplib obj
            if options.Orientation == 4     % xy plane
                currimg = dip_image(img{roi}(:,:,color,layer));
            elseif options.Orientation == 1     % xz plane
                currimg = dip_image(squeeze(img{roi}(layer,:,color,:)));
            elseif options.Orientation == 2     % yz plane
                currimg = dip_image(squeeze(img{roi}(:,layer,color,:)));
            else
                error('Wrong orientation parameter');
            end
            
            switch filter
                case 'pmd'
                    currimg = pmd(currimg, iter, KSigma, Lambda);
                case 'aniso'
                    currimg = aniso(currimg, KSigma, iter, Lambda);
                case 'mcd'
                    currimg = mcd(currimg, KSigma, iter);
                case 'cpf'
                    currimg = cpf(currimg, KSigma, iter);
                case 'kuwahara'
                    currimg = kuwahara(currimg, KSigma, kuwa_shape);
            end
            % convert back to the standard image class
            currimg = double(currimg);
            if options.Orientation == 4     % xy plane
                img{roi}(:,:,color,layer) = currimg;
            elseif options.Orientation == 1     % xz plane
                img{roi}(layer,:,color,:) = currimg;
            elseif options.Orientation == 2     % yz plane
                img{roi}(:,layer,color,:) = currimg;
            end;
        end
        waitbar(color/colors, wb);
    end
end
status = 1;
delete(wb);
end