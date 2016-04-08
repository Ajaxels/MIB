function scrollbarClick_Callback(jListbox, jEventData, hListbox, defaultValue)
% function scrollbarClick_Callback(jListbox, jEventData, hListbox, defaultValue)
% this is callback for the press of a mouse button above specified scroll bar
%
% Parameters:
% jListbox: a java handle to a scroll bar object
% jEventData: event data that has information about the click 
% hListbox: a handles of the parent widget in Matlab
% defaultValue: default value to put into the scroll bar

% Copyright (C) 13.03.2015, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


%if jEventData.getClickCount > 1    % detect double click
if jEventData.isMetaDown  % right-click is like a Meta-button   
    switch get(hListbox,'tag')
        case 'filesListbox'
            jListbox.setValue(1);
            set(hListbox, 'value', defaultValue);
    end
end
end