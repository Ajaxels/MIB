function Model = ib_fillMembranes(Model, countour, overlap)
% function Model = ib_fillMembranes(Model, countour, overlap)
% Fill holes between the slices for the same object
%
% Experimental function that transforms lines into planar structures to make sure that the line objects on two consecutive frames overlap. 
% The function may be useful to complement the traced membranes. It is
% called from im_browser->Menu->Models->Fill membrane
%
% Parameters:
% Model: - a model [1:height, 1:width, 1:no_stacks]
% countour: index of the material
% overlap: overlap value in pixels
% 
% Return values:
% Model: the model [1:height, 1:width, 1:no_stacks].

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


Otmp = zeros(size(Model),'uint8');
Otmp(Model==countour) = 1;
Otmp2 = zeros(size(Otmp));

for ind = 2:size(Otmp,3)
    if find(Otmp(:,:,ind-1)==1,1,'first') & find(Otmp(:,:,ind)==1,1,'first')    % this contour exist on both frames
        S1 = imfill(Otmp(:,:,ind-1),'holes');
        S2 = imfill(Otmp(:,:,ind),'holes');
        Scombined = uint8(Otmp(:,:,ind-1) | Otmp(:,:,ind));
        if max(max(S1-Otmp(:,:,ind-1))) == 0 && max(max(S2-Otmp(:,:,ind))) == 0
            diffImg = imfill(Scombined,'holes')-Scombined;
            diffImg = imdilate(diffImg,strel('disk',overlap)); % to create overlapping
                if max(max(diffImg)) == 1
                    Otmp2(:,:,ind-1) = Otmp(:,:,ind-1) | diffImg;
                else
                    Otmp2(:,:,ind-1) = Otmp(:,:,ind-1);
                end;
            continue;
        elseif max(max(S1-Otmp(:,:,ind-1))) == 0 || max(max(S2-Otmp(:,:,ind))) == 0
            Otmp2(:,:,ind-1) = Otmp(:,:,ind-1);
            continue;
        end
        S2 = imfill(Otmp(:,:,ind),'holes');
        
        Scombined_f = imfill(Scombined,'holes');
        %SS1 = Scombined_f - imfill(Otmp(:,:,ind-1),'holes');
        %SS2 = Scombined_f - imfill(Otmp(:,:,ind),'holes');
        
        SS1 = Scombined_f - S1;
        SS2 = Scombined_f - S2;
        SS = SS1 | SS2;
        SS = imdilate(SS,strel('disk',overlap)); % to create overlapping
        Otmp2(:,:,ind-1) = Otmp(:,:,ind-1) | SS;
    end
end
Model(Otmp2==1) = countour;
end