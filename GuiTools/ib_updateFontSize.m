function ib_updateFontSize(hFig, Font)
% function ib_updateFontSize(hFig, fontSize)
% Update font size for text widgets
%
% Parameters:
% hFig: handle to the figure
% Font: - structure with font settings, possible fields
%   .FontName -> 'Arial'
%   .FontWeight -> 'normal'
%   .FontAngle -> 'normal'
%   .FontUnits -> 'points'
%   .FontSize -> 10
%
% Return values:
% 

% Copyright (C) 41.01.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


tempList = findall(hFig,'Style','text');   % set font to text
for i=1:numel(tempList)
    set(tempList(i), Font);
    % combine text and tooltip
    textStr = get(tempList(i),'String');
    TooltipStr = get(tempList(i),'TooltipString');
    if iscell(textStr)
        if isempty(TooltipStr) || numel(textStr{1}) > numel(TooltipStr) || strcmp(TooltipStr(1:numel(textStr{1})), textStr{1}) == 0
            set(tempList(i),'TooltipString', sprintf('%s; %s', textStr{1}, TooltipStr));
        end
    else
        if isempty(TooltipStr) || numel(textStr) > numel(TooltipStr) || strcmp(TooltipStr(1:numel(textStr)), textStr) == 0
            set(tempList(i),'TooltipString', sprintf('%s; %s', textStr, TooltipStr));
        end
    end
end

tempList = findall(hFig,'Style','checkbox');    % set color to checkboxes
for i=1:numel(tempList)
    set(tempList(i), Font);

    % combine text and tooltip
    textStr = get(tempList(i),'String');
    TooltipStr = get(tempList(i),'TooltipString');
    set(tempList(i),'TooltipString', sprintf('%s; %s', textStr, TooltipStr));
end

tempList = findall(hFig,'Type','uipanel');    % set font to panels
set(tempList, Font);

tempList = findall(hFig,'Style','radiobutton');    % set font to radiobuttons
set(tempList, Font);

tempList = findall(hFig,'Type','uibuttongroup');    % set font to uibuttongroup
set(tempList, Font);

tempList = findall(hFig, 'Style', 'pushbutton');    % set font for push buttons
set(tempList, Font);

tempList = findall(hFig, 'Style', 'popupmenu');    % set font for popupmenus
set(tempList, Font);

