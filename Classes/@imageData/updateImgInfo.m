function updateImgInfo(obj, addText, action, entryIndex)
% function updateImgInfo(obj, addText, action, entryIndex)
% Update action log
%
% This function updates the image log with recent events done to the dataset; it updates the contents of
% imageData.img_info(''ImageDescription'') key.
%
% Parameters:
% addText: a string that should be added to the log
% action: [@em optional] - defines additional actions that may be performed with the log:
% - ''delete'' - delete entry defined with 'entryIndex'
% - ''insert'' - insert new entry after the one defined with 'entryIndex'
% - ''modify'' - modify entry with 'entryIndex'
% entryIndex: [@em optional] - index of the entry to delete, modify or insert
%
% Return values:

%| 
% @b Examples:
% @code slice = imageData.updateImgInfo('Image was filtered');      // Add 'Image was filtered' text into the imageData.img_info('ImageDescriotion')  @endcode
% @code slice = imageData.updateImgInfo('','delete',4);      // Delete entry number 4 from the log  @endcode
% @code slice = imageData.updateImgInfo('New entry inserted','insert',4);      // Insert new entry into the log at position 4 @endcode
% @code slice = imageData.updateImgInfo('Updated text','modify',4);      // Modify text at position 4 @endcode
% @code slice = updateImgInfo(obj, 'Image was filtered');      // Call within the class; Add 'Image was filtered' text into the imageData.img_info('ImageDescriotion')  @endcode

% Copyright (C) 05.03.2014, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 


add_switch = 0;
if nargin < 3; add_switch = 1; end;     % adding addText to the end of the list

if isnan(addText) == 1; add_switch = 0; end;
curr_text = obj.img_info('ImageDescription');
if add_switch   % add text
    if strcmp(curr_text(end),sprintf('|'))
        obj.img_info('ImageDescription') = [curr_text sprintf('MIB(') datestr(now,'yymmddHHMM') '): ' addText];
    else
        obj.img_info('ImageDescription') = [curr_text sprintf('|MIB(') datestr(now,'yymmddHHMM') '): ' addText];
    end
else            % insert or delete entry
    % generate list of entries
    linefeeds = strfind(curr_text,sprintf('|'));
    %if numel(curr_text) > 1 && isempty(linefeeds)
    %    linefeeds =
    if isempty(linefeeds)
        linefeeds = [1 numel(curr_text)+1];
    else
        linefeeds = [1 linefeeds numel(curr_text)+1];
    end
    for entryId = 1:numel(linefeeds)-1
        entry{entryId} = curr_text(linefeeds(entryId):linefeeds(entryId+1)-1); %#ok<AGROW>
    end
    if strcmp(action, 'delete')     % delete entry
        newIndex = 1;
        for i=1:numel(entry)
            if i~=entryIndex
                entryOut(newIndex) = entry(i); %#ok<AGROW>
                newIndex = newIndex + 1;
            end
        end
        entry = entryOut;
    elseif strcmp(action, 'insert')  % insert entry
        entry(entryIndex+1:numel(entry)+1) = entry(entryIndex:end);
        entry(entryIndex) = cellstr([sprintf('|MIB(') datestr(now,'yymmddHHMM') '): ' addText]);
    elseif strcmp(action, 'modify')  % modify entry
        entry(entryIndex) = cellstr([sprintf('|MIB(') datestr(now,'yymmddHHMM') '): ' addText]);
    end
    curr_text = '';
    for i=1:numel(entry)
        curr_text = [curr_text entry{i}]; %#ok<AGROW>
    end
    obj.img_info('ImageDescription') = curr_text;
end
end