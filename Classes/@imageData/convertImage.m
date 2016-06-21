function [handles, status] = convertImage(obj,format,handles)
% function [handles, status] = convertImage(obj,format,handles)
% Convert image to specified format: 'grayscale', 'truecolor', 'indexed' and 'uint8', 'uint16', 'uint32' class
%
% Parameters:
% format: description of the new image format
% - ''grayscale'' - grayscale image, 1 color channel
% - ''truecolor'' - truecolor image, 2 or 3 color channels (red, green, blue)
% - ''hsvcolor'' - hsv color image, 3 color channels (hue, saturation, value)
% - ''indexed'' - indexed colors, the color map is stored in @em imageData.img_info. @e Colormap
% - ''uint8'' - 8-bit unsinged integer, [0 - 255] levels
% - ''uint16'' - 16-bit unsinged integer, [0 - 65535] levels;
% - ''uint32'' - 32-bit unsinged integer, [0 - 4294967295] levels; @b Note! Not Really tested...
% handles: handles of im_browser.m
%
% Return values:
% handles: handles of im_browser.m
% status: @b 1 -success, @b 0 -fail

%| 
% @b Examples:
% @code handles = imageData.convertImage(handles, 'uint8');  // convert dataset to the uint8 class @endcode
% @code [handles, status] = convertImage(obj, handles, 'grayscale');   // Call within the class; convert dataset to the grayscale type @endcode

% Copyright (C) 30.10.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% Updates
% 18.01.2016, IB, changed .slices() to .slices{:}; .slicesColor->.slices{3}
% 04.02.2016, IB, updated for 4D datasets

status = 0;
tic
maxCounter = obj.time*obj.no_stacks;
wb = waitbar(0,['Converting image to ' format ' format'],'Name','Converting image','WindowStyle','modal');
if strcmp(format, 'grayscale')   % ->grayscale
    switch obj.img_info('ColorType')
        case 'grayscale'        % grayscale->
            delete(wb);
            return;
        case 'truecolor'    % truecolor->grayscale
            from = 'truecolor';
            if size(obj.img,3) > 3;
                button = questdlg(sprintf('!!! Attention !!!\n\nDirect conversion of the multichannel image to greyscale is not possible\nHowever it is possible to perform conversion using the LUT colors'),'Multiple color channels','Convert','Cancel','Cancel');
                if strcmp(button, 'Cancel'); return; end;
                if get(handles.lutCheckbox, 'value') == 0
                    errordlg('Please make sure that the LUT checkbox in the View settings panel is checked!','LUT is not selected');
                    return;
                end
                
                I = zeros([size(obj.img,1),size(obj.img,2),1,size(obj.img,4),size(obj.img,5)], class(obj.img)); %#ok<ZEROLIKE>
                selectedColorsLUT = obj.lutColors(obj.slices{3});     % take LUT colors for the selected color channels
                max_int = double(intmax(class(obj.img)));
                
                index = 0;
                for t=1:obj.time
                    for sliceId=1:obj.no_stacks
                        sliceImg = obj.img(:,:,obj.slices{3},sliceId, t);    % get slice
                        R = zeros([size(sliceImg,1), size(sliceImg,2)], class(obj.img)); %#ok<ZEROLIKE>
                        G = zeros([size(sliceImg,1), size(sliceImg,2)], class(obj.img)); %#ok<ZEROLIKE>
                        B = zeros([size(sliceImg,1), size(sliceImg,2)], class(obj.img)); %#ok<ZEROLIKE>
                        for colorId=1:numel(obj.slices{3})
                            adjImg = imadjust(sliceImg(:,:,colorId),[obj.viewPort.min(obj.slices{3}(colorId))/max_int obj.viewPort.max(obj.slices{3}(colorId))/max_int],[0 1],obj.viewPort.gamma(obj.slices{3}(colorId)));
                            R = R + adjImg*selectedColorsLUT(colorId, 1);
                            G = G + adjImg*selectedColorsLUT(colorId, 2);
                            B = B + adjImg*selectedColorsLUT(colorId, 3);
                        end
                        imgRGB = cat(3,R,G,B);
                        I(:,:,1,sliceId,t) = rgb2gray(imgRGB);
                        index = index + 1;
                        if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                    end
                end
                obj.img = I;
                set(handles.lutCheckbox, 'value', 0);
            else
                I = obj.img;
                if  size(I, 3) == 1  % a single color channel
                    I(:,:,2,:,:) = zeros([size(I,1),size(I,2),size(I,4),size(I,5)],class(I)); %#ok<ZEROLIKE>
                    I(:,:,3,:,:) = zeros([size(I,1),size(I,2),size(I,4),size(I,5)],class(I)); %#ok<ZEROLIKE>
                elseif size(I,3) == 2   % two color channels
                    I(:,:,3,:,:) = zeros([size(I,1),size(I,2),size(I,4),size(I,5)],class(I)); %#ok<ZEROLIKE>
                end
                obj.img = zeros([size(I,1),size(I,2),1,size(I,4),size(I,5)], class(I)); %#ok<ZEROLIKE>
                index = 0;
                for t=1:obj.time
                    for i=1:obj.no_stacks
                        obj.img(:,:,1,i,t) = rgb2gray(I(:,:,:,i,t));
                        if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                        index = index + 1;
                    end
                end
            end
        case 'hsvcolor'    % hsvcolor->grayscale            
            delete(wb);
            errordlg('Please convert the image to RGB color!','Wrong image format!');
            return;
        case 'indexed'      % indexed->grayscale
            from = 'indexed';
            I = obj.img;
            obj.img = zeros([size(I,1),size(I,2),1,size(I,4),size(I,5)],class(I)); %#ok<ZEROLIKE>
            index = 0;
            for t=1:obj.time
                for i=1:obj.no_stacks
                    obj.img(:,:,1,i,t) = ind2gray(I(:,:,:,i,t),obj.img_info('Colormap'));
                    if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                    index = index + 1;
                end
            end
            obj.img_info('Colormap') = '';
    end
    obj.img_info('ColorType') = 'grayscale';
elseif strcmp(format,'truecolor')   % ->truecolor
    switch obj.img_info('ColorType')
        case 'grayscale'    % grayscale->truecolor
            from = 'grayscale';
            I = obj.img;
            obj.img = zeros([size(I,1),size(I,2),3,size(I,4),size(I,5)],class(I)); %#ok<ZEROLIKE>
            obj.img(:,:,1,:,:) = I;
            obj.img(:,:,2,:,:) = I;
            obj.img(:,:,3,:,:) = I;
            waitbar(.85,wb);
        case 'truecolor'    % truecolor->truecolor
            delete(wb);
            return;
        case 'hsvcolor'    % hsvcolor->truecolor
            from = 'hsvcolor';
            I = obj.img;
            obj.img = zeros([size(I,1),size(I,2),3,size(I,4),size(I,5)],'uint8');
            index = 0;
            for t=1:obj.time
                for i=1:obj.no_stacks
                    obj.img(:,:,:,i,t) = uint8(hsv2rgb(double(I(:,:,:,i,t))/255)*255);
                	if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                    index = index + 1;
                end
            end
            waitbar(.85,wb);
        case 'indexed'      % indexed->truecolor
            from = 'indexed';
            I = obj.img;
            obj.img = zeros([size(I,1),size(I,2),3,size(I,4),size(I,5)],class(I)); %#ok<ZEROLIKE>
            max_int = double(intmax(class(I)));
            index = 0;
            for t=1:obj.time
                for i=1:obj.no_stacks
                    obj.img(:,:,:,i,t) = ind2rgb(I(:,:,:,i,t), obj.img_info('Colormap'))*max_int;
                    if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                    index = index + 1;
                end
            end
            obj.img_info('Colormap') = '';
    end
    obj.img_info('ColorType') = 'truecolor';
elseif strcmp(format,'hsvcolor')   % ->hsvcolor
    switch obj.img_info('ColorType')
        case 'grayscale'    % grayscale->hsvcolor
            delete(wb);
            errordlg('Please convert the image to RGB color!','Wrong image format!');
            return;
        case 'truecolor'    % truecolor->hsvcolor
            from = 'truecolor';
            if size(obj.img,3) ~= 3;
                delete(wb);
                errordlg('Please convert the image to RGB color!','Wrong image format!');
                return;
            end
            I = obj.img;
            obj.img = zeros([size(I,1),size(I,2),3,size(I,4),size(I,5)],'uint8');
            index = 0;
            for t=1:obj.time
                for i=1:obj.no_stacks
                    obj.img(:,:,:,i,t) = uint8(rgb2hsv(I(:,:,:,i,t))*255);
                    if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                    index = index + 1;
                end
            end
            waitbar(.85,wb);
        case 'hsvcolor'
            delete(wb);
            return;            
        case 'indexed'      % indexed->hsvcolor
            delete(wb);
            errordlg('Please convert the image to RGB color!','Wrong image format!');
            return;
    end
    obj.img_info('ColorType') = 'hsvcolor';    
elseif strcmp(format,'indexed')   % ->indexed
    if strcmp(obj.img_info('ColorType'),'indexed') % indexed->indexed
        delete(wb);
        return;
    end
    if strcmp(obj.img_info('ColorType'),'hsvcolor') % hsvcolor->indexed
            delete(wb);
            errordlg('Please convert the image to RGB color!','Wrong image format!');
            return;
    end
    %answer = inputdlg(sprintf('Please enter number of graylevels\n [1-65535]'),'Convert to indexed image',1,{'255'});
    answer = mib_inputdlg(handles, sprintf('Please enter number of graylevels\n [1-65535]'),'Convert to indexed image','255');
    if isempty(answer);  delete(wb); return; end;
    levels = round(str2double(cell2mat(answer)));
    if levels >= 1 && levels <=255
        class_id = 'uint8';
    elseif levels > 255 && levels <= 65535
        class_id = 'uint16';
    else
        delete(wb);
        msgbox('Wrong number of gray levels','Error','error');
        return;
    end
    switch obj.img_info('ColorType')
        case 'grayscale'    % grayscale->indexed
            from = 'grayscale';
            I = obj.img;
            obj.img = zeros([size(I,1),size(I,2),1,size(I,4),size(I,5)],class_id);
            index = 0;
            for t=1:obj.time
                for i=1:obj.no_stacks
                    [obj.img(:,:,1,i,t), obj.img_info('Colormap')] =  gray2ind(I(:,:,1,i,t),levels);
                    if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                    index = index + 1;
                end
            end
        case 'truecolor'    % truecolor->indexed
            from = 'truecolor';
            if size(obj.img,3) > 3;
                button = questdlg(sprintf('!!! Attention !!!\n\nDirect conversion of the multichannel image to greyscale is not possible\nHowever it is possible to perform conversion using the LUT colors'),'Multiple color channels','Convert','Cancel','Cancel');
                if strcmp(button, 'Cancel'); return; end;
                if get(handles.lutCheckbox, 'value') == 0
                    errordlg('Please make sure that the LUT checkbox in the View settings panel is checked!','LUT is not selected');
                    return;
                end
                
                I = zeros([size(obj.img,1),size(obj.img,2),1,size(obj.img,4),size(obj.img,5)], class_id);
                selectedColorsLUT = obj.lutColors(obj.slices{3});     % take LUT colors for the selected color channels
                max_int = double(intmax(class(obj.img)));
                index = 0;
                for t=1:obj.time
                    for sliceId=1:obj.no_stacks
                        sliceImg = obj.img(:,:,obj.slices{3},sliceId,t);    % get slice
                        R = zeros([size(sliceImg,1), size(sliceImg,2)], class(obj.img)); %#ok<ZEROLIKE>
                        G = zeros([size(sliceImg,1), size(sliceImg,2)], class(obj.img)); %#ok<ZEROLIKE>
                        B = zeros([size(sliceImg,1), size(sliceImg,2)], class(obj.img)); %#ok<ZEROLIKE>
                        for colorId=1:numel(obj.slices{3})
                            adjImg = imadjust(sliceImg(:,:,colorId),[obj.viewPort.min(obj.slices{3}(colorId))/max_int obj.viewPort.max(obj.slices{3}(colorId))/max_int],[0 1],obj.viewPort.gamma(obj.slices{3}(colorId)));
                            R = R + adjImg*selectedColorsLUT(colorId, 1);
                            G = G + adjImg*selectedColorsLUT(colorId, 2);
                            B = B + adjImg*selectedColorsLUT(colorId, 3);
                        end
                        imgRGB = cat(3,R,G,B);
                        [I(:,:,1,sliceId,t), obj.img_info('Colormap')] = rgb2ind(imgRGB, levels);
                        if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                        index = index + 1;
                    end
                end
                obj.img = I;
                set(handles.lutCheckbox, 'value', 0);
            else
                I = obj.img;
                obj.img = zeros([size(I,1),size(I,2),1,size(I,4),size(I,5)],class_id);
                index = 0;
                for t=1:obj.time
                    for i=1:obj.no_stacks
                        [obj.img(:,:,1,i,t), obj.img_info('Colormap')] =  rgb2ind(I(:,:,:,i,t),levels);
                        if mod(index,10)==0; waitbar(index/maxCounter, wb); end; 
                        index = index + 1;
                    end
                end
            end
    end
    obj.img_info('ColorType') = 'indexed';
elseif strcmp(format,'uint8')   % -> uint8
    if strcmp(obj.img_info('ColorType'),'indexed')
        msgbox('Convert to RGB or Grayscale first','Error','error');
        delete(wb);
        return;
    end
    switch class(obj.img)
        case 'uint8'
            delete(wb);
            return;
        case 'uint16'       % uint16->uint8 
            from = class(obj.img);
            obj.img = uint8(obj.img / (double(intmax('uint16'))/double(intmax('uint8'))));
        case 'uint32'       % uint32->uint8
            from = class(obj.img);
            obj.img = uint8(obj.img / (double(intmax('uint32'))/double(intmax('uint8'))));
    end
elseif strcmp(format,'uint16')   % -> uint16
    if strcmp(obj.img_info('ColorType'),'indexed')
        msgbox('Convert to RGB or Grayscale first','Error','error');
        delete(wb);
        return;
    end
    switch class(obj.img)
        case 'uint16'
            delete(wb);
            return;
        case 'uint8'       % uint8->uint16 
            from = class(obj.img);
            obj.img = uint16(obj.img)*(double(intmax('uint16'))/double(intmax('uint8')));
        case 'uint32'    % uint32->uint16
            from = class(obj.img);
            obj.img = uint32(obj.img)*(double(intmax('uint32'))/double(intmax('uint8')));
    end
elseif strcmp(format,'uint32')   % -> uint32
    if strcmp(obj.img_info('ColorType'),'indexed')
        msgbox('Convert to RGB or Grayscale first','Error','error');
        delete(wb);
        return;
    end
    switch class(obj.img)
        case 'uint32'
            delete(wb);
            return;
        case 'uint8'       % uint8->uint32 
            msgbox('Not implemented','Error','error');
            delete(wb);
            return;
            %from = class(obj.img);
            %obj.img = uint32(obj.img)*(double(intmax('uint32'))/double(intmax('uint8')));
        case 'uint16'      % uint16->uint32
            msgbox('Not implemented','Error','error');
            delete(wb);
            return;
            %from = class(obj.img);
            %obj.img = uint32(obj.img)*(double(intmax('uint32'))/double(intmax('uint16')));
    end
end

obj.colors = size(obj.img,3);
obj.slices{3} = 1:obj.colors;   % color slices to show

% update display parameters
obj.updateDisplayParameters();
handles = updateGuiWidgets(handles);

log_text = ['Converted to from ' from ' to ' format];
obj.updateImgInfo(log_text);
delete(wb);
status = 1;
toc
end
