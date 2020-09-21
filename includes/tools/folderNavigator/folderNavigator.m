%%
% BiofilmQ
%
% Copyright (c) 2020 Raimo Hartmann, Hannah Jeckel, and Eric Jelli <biofilmQ@gmail.com>
% Copyright (c) 2020 Drescher-lab, Max Planck Institute for Terrestrial Microbiology, Marburg, Germany
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%
function varargout = folderNavigator(varargin)



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @folderNavigator_OpeningFcn, ...
    'gui_OutputFcn',  @folderNavigator_OutputFcn, ...
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


function folderNavigator_OpeningFcn(hObject, eventdata, handles, varargin)
guiPath = mfilename('fullpath');
guiPath = fileparts(guiPath);
addpath(genpath(fullfile(guiPath, 'includes')));

try
    addIcon(hObject);
end
handles.output = hObject;

if ~isempty(varargin{2})
    handles.handles_GUI = varargin{2};
end


guidata(hObject, handles);

if ~isempty(varargin{1})
    set(handles.edit_inputFolder, 'String', fileparts(varargin{1}{1}))
    scanningInputFolder(hObject, eventdata, handles)
end



function varargout = folderNavigator_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;


function listbox_files_Callback(hObject, eventdata, handles)



function listbox_files_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_inputFolder_Callback(hObject, eventdata, handles)



function edit_inputFolder_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_selectFolder_Callback(hObject, eventdata, handles)
if exist('directory.mat','file')
    load('directory.mat');
else
    directory = '';
end

directory = uigetdir(directory, 'Please select directory containing the subfolders of the experiment');
if directory
    save('directory.mat', 'directory');
else
    disp('No folder selected');
    return;
end

set(handles.edit_inputFolder, 'String', directory);
scanningInputFolder(hObject, eventdata, handles)

function scanningInputFolder(hObject, eventdata, handles)

inputFolder = get(handles.edit_inputFolder, 'String');
if isempty(inputFolder)
    return;
end
folders = strsplit(genpath(inputFolder), pathsep);

folders_name = cell(numel(folders, 1));
for i = 1:numel(folders)
    [~, folders_name{i}, ext] = fileparts(folders{i});
    
    
    folders_name{i} = [folders_name{i}, ext];
end
dataFolders = strcmp(folders_name, 'data');
decovolutionFolders = strcmp(folders_name, 'deconvolved images');
emptyFoldersNames = cellfun(@isempty, {folders_name});

subfolders = struct('name', folders_name, 'folder', cellfun(@fileparts, folders, 'UniformOutput', false), 'isdir', repmat({true}, 1, numel(folders)));



numFiles = cellfun(@(folder_base, subfolder) numel(dir(fullfile(folder_base, subfolder, '*.tif'))), {subfolders.folder}', {subfolders.name}');

validFormats = {'*.nd2', '*.lif', '*.czl', '*.lsm', '*.oif', '*.oib', '*.ome.tiff', '*.ome.tif'};

for j = 1:length(validFormats)
    numFiles = numFiles + cellfun(@(folder_base, subfolder) numel(dir(fullfile(folder_base, subfolder, validFormats{j}))), {subfolders.folder}', {subfolders.name}');
end

emptyFolders = numFiles == 0;

subfolders(emptyFolders | dataFolders' | decovolutionFolders' | emptyFoldersNames) = [];
numFiles(emptyFolders | dataFolders' | decovolutionFolders' | emptyFolders) = [];

folderProcessed = cellfun(@(folder_base, subfolder) exist(fullfile(folder_base, subfolder, 'data'), 'dir'), {subfolders.folder}', {subfolders.name}')>0;

files = cellfun(@(folder_base, subfolder) dir(fullfile(folder_base, subfolder, '*.tif')), {subfolders.folder}', {subfolders.name}', 'UniformOutput', false);
bytes = cellfun(@(files) sum([files.bytes])/1024/1024/1024, files);


colors = flip(autumn(256))+0.4;
colors(colors>1) = 1;
    

colorIdx = round((bytes-min(bytes))/(max(bytes)-min(bytes))*255+1);
if isnan(colorIdx)
    colorIdx = repmat(1, 1, numel(colorIdx));
end

bytes_color = colors(colorIdx, :);
byte_str = cell(numel(bytes), 1);

spaces = cellfun(@(x) [repmat('&nbsp;', 1, x)], num2cell(round(colorIdx/20)), 'UniformOutput', false);
for i = 1:numel(bytes)
    try
        byte_str{i} = sprintf('<html><body bgcolor="%s">%.2f%s', rgb2hex(bytes_color(i,:)), bytes(i), spaces{i});
    catch
        byte_str{i} = '';
    end
end

try
    
    filenames = cellfun(@(filelist) {filelist.name}, files, 'un', 0);
    filename_features =  cellfun(@(x) getFeaturesFromName(x), filenames);
    
    numZMax = cellfun(@(x) max(x), {filename_features.Nz});
    
    colorIdx = round((numZMax-min(numZMax))/(max(numZMax)-min(numZMax))*255+1);
    
    colorIdx(isnan(colorIdx)) = 1;

    numZMax_color = colors(colorIdx, :);
    numZMax_str = cell(numel(numZMax), 1);
    
    spaces = cellfun(@(x) [repmat('&nbsp;', 1, x)], num2cell(round(colorIdx/20)), 'UniformOutput', false);
    for i = 1:numel(numZMax)
        try
            if numZMax(i)
                numZMax_str{i} = sprintf('<html><body bgcolor="%s">%d%s', rgb2hex(numZMax_color(i,:)), numZMax(i), spaces{i});
            else
                numZMax_str{i} = '';
            end
        catch
            numZMax_str{i} = '';
        end
    end
catch
   numZMax_str = repmat({''}, numel(byte_str), 1);
   numZMax = zeros(1, numel(byte_str));
end

colorIdx = round((numFiles-min(numFiles))/(max(numFiles)-min(numFiles))*255+1);
if isnan(colorIdx)
    colorIdx = repmat(1, 1, numel(colorIdx));
end
numFiles_color = colors(colorIdx, :);
numFiles_str = cell(numel(numFiles), 1);

spaces = cellfun(@(x) [repmat('&nbsp;', 1, x)], num2cell(round(colorIdx/20)), 'UniformOutput', false);
for i = 1:numel(numFiles)
    try
        numFiles_str{i} = sprintf('<html><body bgcolor="%s">%d%s', rgb2hex(numFiles_color(i,:)), numFiles(i), spaces{i});
    catch
        numFiles_str{i} = '';
    end
end


filesStr = [{subfolders.name}', numFiles_str, numZMax_str, byte_str, num2cell(folderProcessed), {subfolders.folder}'];
files = [{subfolders.name}', num2cell(numFiles), num2cell(numZMax'), num2cell(bytes), num2cell(folderProcessed), {subfolders.folder}'];

idx = 1:numel(bytes);
set(handles.uitable_files, 'Data', filesStr(idx, :), 'UserData', files(idx, : ));

function pushbutton_open_Callback(hObject, eventdata, handles)
cellSelection = get(handles.folderNavigator, 'UserData');
inputFolder = get(handles.edit_inputFolder, 'String');
filesTable = get(handles.uitable_files, 'UserData');

if isempty(cellSelection) || isempty(filesTable)
    msgbox('No files selected', 'Info', 'warn', 'modal')
    return;
end
for i = 1:size(cellSelection(:,1))
    folderToOpen = fullfile(inputFolder, filesTable{cellSelection(i,1),1});
    
    files = dir(fullfile(folderToOpen, '*.tif'));
    metadata_files = dir(fullfile(folderToOpen, '*_metadata.mat'));
    
    timepoints = cell(numel(files, 1));
    
    for i = 1:numel(metadata_files)
        metadata = load(fullfile(folderToOpen, metadata_files(i).name));
        timepoints{i} = metadata.data.date;
    end
    
    data = cell(numel(files, 1));
    
    data{1} = imread3D(fullfile(files(1).folder, files(1).name));
    
    im = data{1}(:,:,2:end);
    
    maxZ = filesTable{cellSelection(1),3};
    
    zSlicer_time(im, maxZ, files, timepoints, filesTable{cellSelection(1), 1}, metadata.data.scaling, 1);
end

function uitable_files_CellSelectionCallback(hObject, eventdata, handles)
set(handles.folderNavigator, 'UserData', eventdata.Indices);


function pushbutton_batchProcessing_Callback(hObject, eventdata, handles)
parameterFile = get(handles.edit_parameterFile, 'String');
if ~exist(parameterFile, 'file')
    parameterFile = [];
end

batchFile = get(handles.edit_batchFile, 'String');

cellSelection = get(handles.folderNavigator, 'UserData');
inputFolder = get(handles.edit_inputFolder, 'String');
filesTable = get(handles.uitable_files, 'UserData');
folders = filesTable(unique(cellSelection(:,1)),1);
base = filesTable(cellSelection(:,1),6);
folders = cellfun(@(x, y) fullfile(x, y), base, folders, 'UniformOutput', false);

addpath(genpath(fullfile(fileparts(which('BiofilmQ')), 'batch processing', 'batchFiles')));

for i = 1:numel(folders)
    if exist(fullfile(folders{i}), 'dir')
        
        if ~isempty(parameterFile)
            try
                copyfile(parameterFile, fullfile(folders{i}, 'parameters.mat'), 'f');
            catch
                warning('Cannot copy parameter-file');
            end
        end
    end
end
handles.handles_GUI.settings.showMsgs = 0;
run(batchFile);
handles.handles_GUI.settings.showMsgs = 1;


function pushbutton_selectBatchFile_Callback(hObject, eventdata, handles)
[fname, directory] = uigetfile('*.m', 'Please select directory containing the subfolders of the experiment', fullfile(fullfile(fileparts(which('BiofilmQ')), 'batch processing', 'batchFiles'), 'batch.m'));

set(handles.edit_batchFile, 'String', fullfile(directory, fname));

function edit_batchFile_Callback(hObject, eventdata, handles)



function edit_batchFile_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_selectParameterFile_Callback(hObject, eventdata, handles)
if exist('directory.mat','file')
    load('directory.mat');
else
    directory = '';
end

[fname, directory] = uigetfile('*.mat', 'Please select directory containing the subfolders of the experiment', fullfile(directory, 'parameters.mat'));
if directory
    save('directory.mat', 'directory');
else
    disp('No folder selected');
    return;
end

set(handles.edit_parameterFile, 'String', fullfile(directory, fname));


function edit_parameterFile_Callback(hObject, eventdata, handles)



function edit_parameterFile_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_openSegmentation_Callback(hObject, eventdata, handles)
cellSelection = get(handles.folderNavigator, 'UserData');
inputFolder = get(handles.edit_inputFolder, 'String');
filesTable = get(handles.uitable_files, 'UserData');

if isempty(cellSelection) || isempty(filesTable)
    msgbox('No files selected', 'Info', 'warn', 'modal')
    return;
end
if size(cellSelection, 1) > 1
    msgbox('Multiple folders selected!', 'Info', 'warn', 'modal')
    return;
end

if isfield(handles, 'handles_GUI')
    figure(handles.handles_GUI.mainFig);
    handles.handles_GUI.settings.directory = fullfile(filesTable{cellSelection(1), 6}, filesTable{cellSelection(1), 1});
    set(handles.handles_GUI.uicontrols.edit.inputFolder, 'String', fullfile(filesTable{cellSelection(1), 6}, filesTable{cellSelection(1), 1}));
    BiofilmQ('pushbutton_refreshFolder_Callback', handles.handles_GUI.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, handles.handles_GUI)
else
    msgbox('Please call the folderNavigator from inside the Segmentation Toolbox.', 'Info', 'warn', 'modal')
    return;
end



