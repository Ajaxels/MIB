function convertModel(obj, type)
% function convertModel(obj, type)
% Convert model from uint6 to uint8 and other way around.
%
% @note The current type is defined with imageData.model_type
%
% Parameters:
% type: [optional] a type of a new model: 'uint8' or 'uint6'
%
% Return values:
%

%| 
% @b Examples:
% @code imageData.convertModel('uint8');  // convert model to the uint8 type @endcode
% @code convertModel(obj, 'uint8');   // Call within the class; convert model to the uint8 type @endcode

% Copyright (C) 30.10.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 


if nargin < 2
    if strcmp(obj.model_type, 'uint8')
        type = 'uint6';
    else
        type = 'uint8';
    end
end
if strcmp(type,'uint8') && strcmp(obj.model_type, 'uint8'); return; end;
if strcmp(type,'uint6') && strcmp(obj.model_type, 'uint6'); return; end;
wb = waitbar(0,sprintf('Converting the model to the %s type\n\nPlease wait...', type),'Name','Converting the model','WindowStyle','modal');
if strcmp(type,'uint6')     % convert from uint8 to uint6
    if ~isnan(obj.selection(1))
        if isnan(obj.model(1)); obj.model = zeros([size(obj.img,1) size(obj.img,2) size(obj.img,4)], 'uint8'); end; % create new model
        obj.model(obj.selection==1) = bitset(obj.model(obj.selection==1), 8, 1);    % generate selection layer
        waitbar(0.4, wb);
        if obj.maskExist == 1
            obj.model(obj.maskImg==1) = bitset(obj.model(obj.maskImg==1), 7, 1);    % generate mask layer
        end
        waitbar(0.8, wb);
        obj.maskExist = 1;
        obj.maskImg = NaN;
        obj.selection = NaN;
    end
    obj.model_type = 'uint6';
    waitbar(1, wb);
else                        % convert from uint6 to uint8
    waitbar(0.3, wb);
    if ~isnan(obj.model(1))     % convert when the layers are present
        obj.selection = zeros([size(obj.img,1) size(obj.img,2) size(obj.img,4)],'uint8');
        obj.maskImg = zeros([size(obj.img,1) size(obj.img,2) size(obj.img,4)],'uint8');
        obj.selection = bitand(obj.model, 128)/128;     % generate selection
        obj.maskImg = bitand(obj.model, 64)/64;     % generate mask
        waitbar(0.6, wb);
        obj.model = bitand(obj.model, 63);  % clear mask and selection from the model
        waitbar(0.9, wb);
        obj.maskExist = 1;
    end
    obj.model_type = 'uint8';
    waitbar(1, wb);
end
delete(wb);
drawnow;    % otherwise im_browser crashes after model convertion when leaving the preferences dialog
end