function mib_rescaleWidgets(hGui)
% function mib_rescaleWidgets(hGui)
% rescale widgets for different operating systems
%
% Parameters:
% hGui: handle to a window to be rescaled
%
% Return values:

%| 
% @b Examples:
% @code mib_rescaleWidgets(handles.im_browser);     // rescales widgets of im_browser @endcode

% Copyright (C) 14.04.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


% list of affected widgets
list = {'uipanel','uibuttongroup','uitab','uitabgroup','axes','uitable','uicontrol'};

if ~ispc()
    set(hGui, 'visible', 'off');
    if ismac()
        scaleFactor = 1.5;     % increase size of the widgets by 1.5 times
    else  % linux
        scaleFactor = 1.2;     % increase size of the widgets by 1.2 times
    end
    for j=1:numel(list)
        h = findall(hGui, 'type', list{j});
        for i=1:numel(h)
            try
                units = get(h(i),'Units');
                if ~strcmp(units, 'normalized')
                    set(h(i),'position', get(h(i),'position')*scaleFactor);
                end
            end
        end
    end
    % finally update the main window
    pos = get(hGui,'position');
    %pos(1) = 1;
    %pos(2) = 1;
    set(hGui,'position', pos*scaleFactor);
    set(hGui, 'visible', 'on');
end
end