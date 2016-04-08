function updateDisplayParameters(obj)
% function updateDisplayParameters(obj)
% Update display parameters for visualization.
%
% The function updates imageData.viewPort structure. It is called from the imageAdjustment.m dialog.
%
% Parameters:
%
% Return values:

%| 
% @b Examples:
% @code imageData.updateDisplayParameters();  // do update @endcode
% @code updateDisplayParameters(obj);   // Call within the class; do update @endcode

% Copyright (C) 18.06.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


obj.viewPort = struct();
[obj.viewPort.min(1:obj.colors)] = deal(0);
if isa(obj.img,'single')
    [obj.viewPort.max(1:obj.colors)] = max(max(max(obj.img)));
else
    if isa(obj.img,'uint32')
        [obj.viewPort.max(1:obj.colors)] = deal(65535);
    else
        [obj.viewPort.max(1:obj.colors)] = deal(double(intmax(class(obj.img))));
    end
end
[obj.viewPort.gamma(1:obj.colors)] = deal(1);

end