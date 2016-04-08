function redrawChannelMixerTable(handles)
% function redrawChannelMixerTable(handles)
% Update handles.channelMixerTable table and handles.ColChannelCombo color combo box
%
% Parameters:
% handles: handles structure of im_browser
%
% Return values:
%

% Copyright (C) 06.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, changed .slices() to .slices{:}; .slicesColor->.slices{3}


% update color combo box and channel mixer table
storeVal = get(handles.ColChannelCombo,'Value');
set(handles.ColChannelCombo,'Value',1);
data = logical(zeros(size(handles.Img{handles.Id}.I.img,3),1)); %#ok<LOGL>
col_channels(1) = cellstr('All'); %#ok<AGROW>
for col_ch=1:size(handles.Img{handles.Id}.I.img,3)
    col_channels(col_ch+1) = cellstr(['Ch ' num2str(col_ch)]); %#ok<AGROW>
    if isempty(find(handles.Img{handles.Id}.I.slices{3}==col_ch, 1))
        data(col_ch) = false;
    else
        data(col_ch) = true;
    end
end
set(handles.ColChannelCombo,'String',col_channels);
if numel(col_channels) >= storeVal
    set(handles.ColChannelCombo,'Value',storeVal);
end

% update channelMixerTable
colorGen = @(color,text) ['<html><table border=0 width=40 bgcolor=''',color,'''><TR><TD>',text,'</TD></TR> </table></html>'];
tableData = cell([numel(data) 3]);
useLut = get(handles.lutCheckbox,'value');
colorIndex = 0;
for colorId = 1: numel(data)
    tableData{colorId, 1} = colorId;
    tableData{colorId, 2} = data(colorId);
    if useLut
        tableData{colorId, 3} = colorGen(sprintf('rgb(%d, %d, %d)', round(handles.Img{handles.Id}.I.lutColors(colorId, 1)*255), round(handles.Img{handles.Id}.I.lutColors(colorId, 2)*255), round(handles.Img{handles.Id}.I.lutColors(colorId, 3)*255)),'&nbsp;');  % rgb(0,255,0)
    else
        if sum(data) == 1
            if data(colorId) == 1
                tableData{colorId, 3} = colorGen('rgb(0, 0, 0)', '&nbsp;');
            else
                tableData{colorId, 3} = 'X';
            end
            %             if numel(data) < 4 || find(data==1,1,'last') < 4    % when 3 or less color channels present
            %                 if data(colorId) == 1
            %                     tableData{colorId, 3} = colorGen('#000000', '&nbsp;');
            %                     switch colorId
            %                         case 1
            %                             tableData{colorId, 3} = colorGen('#FF0000', '&nbsp;');
            %                         case 2
            %                             tableData{colorId, 3} = colorGen('#00FF00', '&nbsp;');
            %                         case 3
            %                             tableData{colorId, 3} = colorGen('#0000FF', '&nbsp;');
            %                     end
            %                 else
            %                     tableData{colorId, 3} = 'X';
            %                 end
            %             else    % when 4 or more color channels present, show channel in blue
            %                 if data(colorId) == 1
            %                     tableData{colorId, 3} = colorGen('#0000FF', '&nbsp;');
            %                 else
            %                     tableData{colorId, 3} = 'X';
            %                 end
            %             end
        elseif sum(data) == 2
            if numel(data) < 4 || find(data==1,1,'last') < 4    % when 3 or less color channels present, preserve the color channels
                if data(colorId) == 1
                    switch colorId
                        case 1
                            tableData{colorId, 3} = colorGen('rgb(255, 0, 0)', '&nbsp;');
                        case 2
                            tableData{colorId, 3} = colorGen('rgb(0, 255, 0)', '&nbsp;');
                        case 3
                            tableData{colorId, 3} = colorGen('rgb(0, 0, 255)', '&nbsp;');
                    end
                else
                    tableData{colorId, 3} = 'X';
                end
            else    % when 4 or more color channels present, show channel in blue
                if data(colorId) == 1
                    colorIndex = colorIndex + 1;
                    switch colorIndex
                        case 1
                            tableData{colorId, 3} = colorGen('rgb(255, 0, 0)', '&nbsp;');
                        case 2
                            tableData{colorId, 3} = colorGen('rgb(0, 255, 0)', '&nbsp;');
                    end
                else
                    tableData{colorId, 3} = 'X';
                end
            end
            
        else    % 3 or more selected color channels, show only the 3 first in the list
            if data(colorId) == 1
                colorIndex = colorIndex + 1;
                switch colorIndex
                    case 1
                        tableData{colorId, 3} = colorGen('rgb(255, 0, 0)', '&nbsp;');
                    case 2
                        tableData{colorId, 3} = colorGen('rgb(0, 255, 0)', '&nbsp;');
                    case 3
                        tableData{colorId, 3} = colorGen('rgb(0, 0, 255)', '&nbsp;');
                    otherwise
                        tableData{colorId, 3} = 'X';
                end
            else
                tableData{colorId, 3} = 'X';
            end
        end
    end
end
set(handles.channelMixerTable,'Data',tableData);
set(handles.channelMixerTable, 'ColumnWidth', {19 25 15});
end