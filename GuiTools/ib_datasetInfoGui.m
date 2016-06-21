function varargout = ib_datasetInfoGui(varargin)
% function varargout = ib_datasetInfoGui(varargin)
% ib_datasetInfoGui is a GUI window that shows parameters of the dataset
%
%
% ib_datasetInfoGui.m contains MATLAB code for ib_datasetInfoGui.fig
%

% Copyright (C) 07.11.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 22.04.2016, IB, updated to use uiTree class instead of a table

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ib_datasetInfoGui_OpeningFcn, ...
    'gui_OutputFcn',  @ib_datasetInfoGui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before ib_datasetInfoGui is made visible.
function ib_datasetInfoGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ib_datasetInfoGui (see VARARGIN)

repositionSwitch = 1; % reposition the figure, when creating a new figure
if numel(varargin) > 1  % for the update of the window from updateGuiWidgets function, not used any more
    handles = guidata(varargin{2});
    repositionSwitch = 0; % keep the current coordinates when the figure already exist
    handles = rmfield(handles, 'hMain');
end

% Choose default command line output for ib_datasetInfoGui
handles.output = hObject;
set(hObject,'Name','Dataset parameters');
handles.hMain = varargin{1};

if repositionSwitch == 1
    % setup uiTree
    % based on description by Yair Altman:
    % http://undocumentedmatlab.com/blog/customizing-uitree
    warning('off','MATLAB:uitreenode:DeprecatedFunction');
    warning('off','MATLAB:uitree:DeprecatedFunction');
    
    import javax.swing.*
    import javax.swing.tree.*;
    handles.rootNode = uitreenode('v0','root', 'img_info', [], false);  % initialize the root node
    handles.treeModel = DefaultTreeModel(handles.rootNode);     % set the tree Model
    [handles.uiTree, handles.uiTreeContainer] = uitree('v0');   % create the uiTree
    handles.uiTree.setModel(handles.treeModel);
    
    set(handles.uiTreeContainer, 'parent', handles.uiTreePanel);    % assign to the parent panel
    set(handles.uiTreeContainer, 'units', 'points');
    uiTreePanelPos = get(handles.uiTreePanel,'Position');
    set(handles.uiTreeContainer,'Position', [5, 5, uiTreePanelPos(3)-8, uiTreePanelPos(4)-8]); % resize uiTree
    handles.uiTree.setSelectedNode(handles.rootNode);   % make root the initially selected node
    
    handles.uiTree.setMultipleSelectionEnabled(1);  % enable multiple selections
end
refreshBtn_Callback(handles.refreshBtn, eventdata, handles);    % fill the Tree

% update font and size
if get(handles.uipanel1, 'fontsize') ~= handles.hMain.preferences.Font.FontSize ...
        || ~strcmp(get(handles.uipanel1, 'fontname'), handles.hMain.preferences.Font.FontName)
    ib_updateFontSize(handles.ib_datasetInfoGui, handles.hMain.preferences.Font);
end

% rescale widgets for Mac and Linux
mib_rescaleWidgets(handles.ib_datasetInfoGui);

% Update handles structure
guidata(hObject, handles);

% Determine the position of the dialog - on a side of the main figure
% if available, else, centered on the screen
if repositionSwitch
    FigPos=get(0,'DefaultFigurePosition');
    OldUnits = get(hObject, 'Units');
    set(hObject, 'Units', 'pixels');
    OldPos = get(hObject,'Position');
    FigWidth = OldPos(3);
    FigHeight = OldPos(4);
    if isempty(gcbf)
        ScreenUnits=get(0,'Units');
        set(0,'Units','pixels');
        ScreenSize=get(0,'ScreenSize');
        set(0,'Units',ScreenUnits);
        
        FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
        FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
    else
        GCBFOldUnits = get(gcbf,'Units');
        set(gcbf,'Units','pixels');
        GCBFPos = get(gcbf,'Position');
        set(gcbf,'Units',GCBFOldUnits);
        screenSize = get(0,'ScreenSize');
        if GCBFPos(1)-FigWidth > 0 % put figure on the left side of the main figure
            FigPos(1:2) = [GCBFPos(1)-FigWidth-16 GCBFPos(2)+GCBFPos(4)-FigHeight+55];
        elseif GCBFPos(1) + GCBFPos(3) + FigWidth < screenSize(3) % put figure on the right side of the main figure
            FigPos(1:2) = [GCBFPos(1)+GCBFPos(3)+16 GCBFPos(2)+GCBFPos(4)-FigHeight+55];
        else
            FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
        end
    end
    FigPos(3:4)=[FigWidth FigHeight];
    set(hObject, 'Position', FigPos);
    set(hObject, 'Units', OldUnits);
end
ib_datasetInfoGui_ResizeFcn(hObject, eventdata, handles);
% UIWAIT makes ib_datasetInfoGui wait for user response (see UIRESUME)
% uiwait(handles.ib_datasetInfoGui);
end


% --- Outputs from this function are returned to the command line.
function varargout = ib_datasetInfoGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
% delete(handles.ib_datasetInfoGui);
end

% --- Executes on button press in refreshBtn.
function refreshBtn_Callback(hObject, eventdata, handles)
handles.hMain = guidata(handles.hMain.im_browser);  % update handles of MIB
% % populate uiTree
import javax.swing.*
import javax.swing.tree.*;
warning('off','MATLAB:uitreenode:DeprecatedFunction');
warning('off','MATLAB:uitree:DeprecatedFunction');

keySet = keys(handles.hMain.Img{handles.hMain.Id}.I.img_info);

handles.rootNode = uitreenode('v0','root', 'img_info', [], false);  % initialize the root node
handles.treeModel = DefaultTreeModel(handles.rootNode);     % set the tree Model
handles.uiTree.setModel(handles.treeModel);     

set(handles.uiTreeContainer, 'parent', handles.uiTreePanel);
set(handles.uiTreeContainer, 'units', 'points');
uiTreePanelPos = get(handles.uiTreePanel,'Position');
set(handles.uiTreeContainer,'Position', [5, 5, uiTreePanelPos(3)-8, uiTreePanelPos(4)-8]);

%handles.uiTree.setSelectedNode(handles.rootNode); % select the node

% add main key
mainKeys = {'Filename', 'Height','Width', 'Stacks', 'Time', 'ImageDescription', 'ColorType', 'ResolutionUnit', ...
    'XResolution','YResolution','SliceName','SeriesNumber','lutColors'};
mainKeysPos = ismember(keySet, mainKeys);
mainKeys = keySet(mainKeysPos);
syncNode = [];  % id of a node for uiTree sync

for keyId = 1:numel(mainKeys)
    if isnumeric(handles.hMain.Img{handles.hMain.Id}.I.img_info(mainKeys{keyId}))
        val = handles.hMain.Img{handles.hMain.Id}.I.img_info(mainKeys{keyId});
        if size(val,1) == 1
            strVal = sprintf('%s: %s', mainKeys{keyId}, num2str(val));
            childNode = uitreenode('v0',1, strVal, [], true);
            handles.treeModel.insertNodeInto(childNode, handles.rootNode, handles.rootNode.getChildCount());
        else
            childNode = uitreenode('v0','dummy', mainKeys{keyId}, [], false);
            handles.treeModel.insertNodeInto(childNode, handles.rootNode, handles.rootNode.getChildCount());
            for chId = 1:size(val,1)
                subChildNode = uitreenode('v0', num2str(chId), sprintf('%s', num2str(val(chId,:))), [], true);
                handles.treeModel.insertNodeInto(subChildNode, childNode, childNode.getChildCount());    
            end
        end
    elseif iscell(handles.hMain.Img{handles.hMain.Id}.I.img_info(mainKeys{keyId}))
        elementList = handles.hMain.Img{handles.hMain.Id}.I.img_info(mainKeys{keyId});
        if numel(elementList) == 1
            strVal = sprintf('%s: %s',mainKeys{keyId}, elementList{1});
            childNode = uitreenode('v0', '1', strVal, [], true);
            handles.treeModel.insertNodeInto(childNode, handles.rootNode, handles.rootNode.getChildCount());
        else
            childNode = uitreenode('v0','dummy', mainKeys{keyId}, [], false);
            handles.treeModel.insertNodeInto(childNode, handles.rootNode, handles.rootNode.getChildCount());
            
            for elelentId = 1:numel(elementList)
                subChildNode = uitreenode('v0', num2str(elelentId), elementList{elelentId}, [], true);
                handles.treeModel.insertNodeInto(subChildNode, childNode, childNode.getChildCount());
            end
        end
    else
        strVal = sprintf('%s: %s',mainKeys{keyId}, handles.hMain.Img{handles.hMain.Id}.I.img_info(mainKeys{keyId}));
        childNode = uitreenode('v0','dummy', strVal, [], true);
        handles.treeModel.insertNodeInto(childNode, handles.rootNode, handles.rootNode.getChildCount());
    end
    % sync selected nodes
    if isfield(handles,'selectedNodeName')
        if strcmp(mainKeys{keyId}, handles.selectedNodeName)
            syncNode = childNode;
        end
    end
end

if isKey(handles.hMain.Img{handles.hMain.Id}.I.img_info,'meta')
    handles.uiTreeRoot = parseStructToTree(handles.hMain.Img{handles.hMain.Id}.I.img_info('meta'), handles.treeModel, handles.rootNode);
    keySet(ismember(keySet, 'meta')) = [];
end
keySet(mainKeysPos) = [];

childNode = uitreenode('v0','Extras', 'Extras', [], false);
handles.treeModel.insertNodeInto(childNode, handles.rootNode, handles.rootNode.getChildCount());

for keyId = 1:numel(keySet)
    if isnumeric(handles.hMain.Img{handles.hMain.Id}.I.img_info(keySet{keyId}))
        strVal = sprintf('%s: %f',keySet{keyId}, handles.hMain.Img{handles.hMain.Id}.I.img_info(keySet{keyId}));
        subChildNode = uitreenode('v0','Extras', strVal, [], true);
        handles.treeModel.insertNodeInto(subChildNode, childNode, childNode.getChildCount());
    elseif iscell(handles.hMain.Img{handles.hMain.Id}.I.img_info(keySet{keyId}))
        elementList = handles.hMain.Img{handles.hMain.Id}.I.img_info(keySet{keyId});
        if numel(elementList) == 1
            strVal = sprintf('%s: %s',keySet{keyId}, elementList{1});
            subChildNode = uitreenode('v0','1', strVal, [], true);
            handles.treeModel.insertNodeInto(subChildNode, childNode, childNode.getChildCount());
        else
            subChildNode = uitreenode('v0','Extras', keySet{keyId}, [], false);
            handles.treeModel.insertNodeInto(subChildNode, childNode, childNode.getChildCount());
            
            for elelentId = 1:numel(elementList)
                subChildNode2 = uitreenode('v0', num2str(elelentId), elementList{elelentId}, [], true);
                handles.treeModel.insertNodeInto(subChildNode2, subChildNode, subChildNode.getChildCount());
            end
        end
    else
        strVal = sprintf('%s: %s',keySet{keyId}, handles.hMain.Img{handles.hMain.Id}.I.img_info(keySet{keyId}));
        subChildNode = uitreenode('v0','Extras', strVal, [], true);
        handles.treeModel.insertNodeInto(subChildNode, childNode, childNode.getChildCount());
    end
    % sync selected nodes
    if isfield(handles,'selectedNodeName')
        if strcmp(keySet{keyId}, handles.selectedNodeName)
            syncNode = subChildNode;
        end
    end
end
handles.uiTree.expand(handles.rootNode);  % expand uiTree
if ~isempty(syncNode)
    handles.uiTree.setSelectedNode(syncNode);
    handles.uiTree.expand(syncNode);
    scrollPane = handles.uiTree.ScrollPane;
    scrollPaneViewport = scrollPane.getViewport;
    drawnow;
    scrollPaneViewport.setViewPosition(handles.selectedNodePos);
    scrollPane.repaint;
end

set(handles.uiTree, 'NodeSelectedCallback', {@uiTreeNodeSelectedCallback, handles});    % set the node selection callback
guidata(handles.ib_datasetInfoGui, handles);
end

function uiTreeNodeSelectedCallback(tree, event, handles)
nodes = tree.getSelectedNodes;
if isempty(nodes); return; end;
% store name of the selected field for syncronization
handles.selectedNodeName = char(nodes(1).getName);
colonChar = strfind(handles.selectedNodeName, ':');
if ~isempty(colonChar)
    handles.selectedNodeName = handles.selectedNodeName(1:colonChar-1);     
end
scrollPane = handles.uiTree.ScrollPane;
scrollPaneViewport = scrollPane.getViewport;
handles.selectedNodePos = scrollPaneViewport.getViewPosition;

nodeName = char(nodes(1).getName);
set(handles.selectedText, 'String', nodeName);

guidata(handles.ib_datasetInfoGui, handles);
end

% --- Executes when ib_datasetInfoGui is resized.
function ib_datasetInfoGui_ResizeFcn(hObject, eventdata, handles)
if isstruct(handles) == 0; return; end;
guiPos = get(handles.ib_datasetInfoGui, 'position');
set(handles.uipanel1, 'Position', [2, 65, guiPos(3)-5, guiPos(4)-70]);
selTextPos = get(handles.selectedText, 'Position');
set(handles.selectedText, 'Position', [selTextPos(1), guiPos(4)-120, guiPos(3)-25 selTextPos(4)]);
set(handles.uiTreePanel, 'Position', [selTextPos(1), 10, guiPos(3)-25 guiPos(4)-135]);

set(handles.uiTreeContainer,'Position', [5, 5, guiPos(3)-25-8, guiPos(4)-135-8]);
end


% --- Executes when user attempts to close ib_datasetInfoGui.
function ib_datasetInfoGui_CloseRequestFcn(hObject, eventdata, handles)
guidata(handles.hMain.im_browser, handles.hMain);
delete(hObject);
end


% --- Executes on button press in insertBtn.
function insertBtn_Callback(hObject, eventdata, handles)
options.Resize = 'on';
prompt = {'New parameter name:','New parameter value:'};
answer = inputdlg(prompt,'Insert an entry',[1; 5],{'',''},options);
if isempty(answer); return; end;
handles.hMain.Img{handles.hMain.Id}.I.img_info(answer{1}) = answer{2};
refreshBtn_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in modifyBtn.
function modifyBtn_Callback(hObject, eventdata, handles)
options.Resize = 'on';
nodes = handles.uiTree.getSelectedNodes;
nodeName = char(nodes(1).getName);
colonChar = strfind(nodeName, ':');
if ~isempty(colonChar)
    nodeName = nodeName(1:colonChar-1);     
end

subIndex = [];  % subindex of entries
if ~isKey(handles.hMain.Img{handles.hMain.Id}.I.img_info, nodeName) && nodes(1).isLeaf
    parent = nodes(1).getParent;
    nodeName = char(parent(1).getName);
    colonChar = strfind(nodeName, ':');
    if ~isempty(colonChar)
        nodeName = nodeName(1:colonChar-1);     
    end
    subIndex = str2double(nodes(1).getValue);
end

if isKey(handles.hMain.Img{handles.hMain.Id}.I.img_info, nodeName)
    if isnumeric(handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName))
        strVal{1} = nodeName;
        value = handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName);
        if ~isempty(subIndex)
            value = value(subIndex, :);
        end
        strVal{2} = num2str(value);
        answer = inputdlg({'New field name:','New value'}, 'Modify the entry',size(strVal{2},1), strVal, options);
        if isempty(answer); return; end;
        if ~isempty(subIndex)
            value = handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName);
            value(subIndex, :) = str2num(answer{2});
            handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName) = value;
        else
            remove(handles.hMain.Img{handles.hMain.Id}.I.img_info, nodeName);      % remove the old key
            handles.hMain.Img{handles.hMain.Id}.I.img_info(answer{1}) = str2num(answer{2});
        end
    elseif iscell(handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName))
        if isempty(subIndex)
            answer = inputdlg('New field name:', 'Modify the entry',1, {nodeName}, options);
            if isempty(answer); return; end;
            value = handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName);
            remove(handles.hMain.Img{handles.hMain.Id}.I.img_info, nodeName);      % remove the old key
            handles.hMain.Img{handles.hMain.Id}.I.img_info(answer{1}) = value;
        else
            strVal{1} = nodeName;
            value = handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName);
            strVal{2} = value{subIndex};
            answer = inputdlg({'New field name:','New value'}, 'Modify the entry',size(strVal{2},1), strVal, options);
            if isempty(answer); return; end;
            value(subIndex) = answer(2);
            handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName) = value;
        end
    else
        strVal{1} = nodeName;
        strVal{2} = handles.hMain.Img{handles.hMain.Id}.I.img_info(nodeName);
        answer = inputdlg({'New field name:','New value'}, 'Modify the entry',5, strVal, options);
        if isempty(answer); return; end;
        remove(handles.hMain.Img{handles.hMain.Id}.I.img_info, nodeName);      % remove the old key
        handles.hMain.Img{handles.hMain.Id}.I.img_info(answer{1}) = answer{2};
    end
end
refreshBtn_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in deleteBtn.
function deleteBtn_Callback(hObject, eventdata, handles)
button = questdlg(sprintf('Warning!!!\n\nYou are going to delete the highlighted parameters!\nAre you sure?'),'Delete entries','Delete','Cancel','Cancel');
if strcmp(button, 'Cancel'); return; end;

nodes = handles.uiTree.getSelectedNodes;
keySet = cell([numel(nodes), 1]);
for i=1:numel(nodes)
    nodeName = char(nodes(i).getName);
    colonChar = strfind(nodeName, ':');
    if ~isempty(colonChar)
        nodeName = nodeName(1:colonChar-1);     
    end
    keySet{i} = nodeName;
end
remove(handles.hMain.Img{handles.hMain.Id}.I.img_info, keySet);

refreshBtn_Callback(hObject, eventdata, handles);
end
