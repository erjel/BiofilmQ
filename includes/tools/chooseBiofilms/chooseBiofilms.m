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
function varargout = chooseBiofilms(varargin)



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @chooseBiofilms_OpeningFcn, ...
    'gui_OutputFcn',  @chooseBiofilms_OutputFcn, ...
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


function chooseBiofilms_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

addIcon(hObject);

currentDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(currentDir, 'includes')));
addpath(currentDir);

setappdata(0, 'hMain_chooseBiofilms', gcf);
startProgram = 1;

entries = sort(fieldnames(handles));
for i = 1:size(entries, 1)
    entry = entries{i};
    if strfind(entry, 'menu')
        if isempty(strfind(entry, 'popupmenu'))
            handles.menuHandles.menues.(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    if strfind(entry, 'context')
        handles.menuHandles.context.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'uitoolbar')
        handles.menuHandles.uitoolbars.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'Context')
        handles.menuHandles.context.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'colormap_')
        handles.menuHandles.context.colormaps.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'uitoggletool')
        handles.menuHandles.uitoggletools.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    try
        if strcmp(get(handles.(entry), 'Type'), 'uicontrol')
            handles.uicontrols.(get(handles.(entry), 'Style')).(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    try
        if strcmp(get(handles.(entry), 'Type'), 'uitable')
            handles.uitables.(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    if strfind(entry, 'uipanel')
        handles.layout.uipanels.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'axes')
        handles.axes.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
end


handles_main = varargin{1};
handles.handles_main = handles_main;
[image, metadata, filename] = loadImage(handles_main);
handles.settings.image = image;
handles.settings.metadata = metadata;
handles.settings.filename = filename;
handles = initialize(handles);
handles = updateImage(hObject, handles);
guidata(hObject, handles);

function handles = initialize(handles)
handles.settings.pc99 = prctile(double(handles.settings.image(:)),99);
handles.settings.pc10 = prctile(double(handles.settings.image(:)),10);
handles.settings.mask = zeros(size(handles.settings.image(:)));
handles.uicontrols.slider.slider_Threshold.Min = min(handles.settings.image(:));
handles.uicontrols.slider.slider_Threshold.Max = max(handles.settings.image(:));
handles.uicontrols.slider.slider_Threshold.Value = 0.5*(handles.uicontrols.slider.slider_Threshold.Max - handles.uicontrols.slider.slider_Threshold.Min)+handles.uicontrols.slider.slider_Threshold.Min;
handles.uicontrols.slider.slider_colonySize.Min = 0;
handles.uicontrols.slider.slider_colonySize.Max = numel(handles.settings.image);
handles.uicontrols.slider.slider_colonySize.Value = 0;



function [im, metadata, filename] = loadImage(handles_main)
files = handles_main.settings.lists;
file = handles_main.settings.selectedFile;
filename = files.files_tif(file).name;
im = imread(fullfile(handles_main.settings.directory, filename), 1);
metadata = load(fullfile(handles_main.settings.directory, strrep(files.files_tif(file).name, '.tif', '_metadata.mat')));


function handles = updateImage(hObject, handles, varargin)
if nargin==2
    try
        switch hObject.Style
            case 'slider'
                intensityValue = get(handles.uicontrols.slider.slider_Threshold,'Value');
                handles.uicontrols.edit.edit_intensity_threshold.String = num2str(intensityValue);
                sizeValue = get(handles.uicontrols.slider.slider_colonySize, 'Value');
                handles.uicontrols.edit.edit_colony_size.String = num2str(sizeValue);
            case 'edit'
                intensityValue = str2double(handles.uicontrols.edit.edit_intensity_threshold.String);
                handles.uicontrols.slider.slider_Threshold.Value = intensityValue;
                sizeValue = str2double(handles.uicontrols.edit.edit_colony_size.String);
                handles.uicontrols.slider.slider_colonySize.Value = sizeValue;
        end
    catch 
        intensityValue = get(handles.uicontrols.slider.slider_Threshold,'Value');
        handles.uicontrols.edit.edit_intensity_threshold.String = num2str(intensityValue);
        sizeValue = get(handles.uicontrols.slider.slider_colonySize, 'Value');
        handles.uicontrols.edit.edit_colony_size.String = num2str(sizeValue);
    end
    biofilms = handles.settings.image > intensityValue;
    biofilms = imdilate(biofilms, strel('disk', 3));
    biofilms = imfill(biofilms, 'holes');
    biofilms = bwconncomp(biofilms);
    
    sizes = regionprops(biofilms, 'Area');
    
    biofilms.PixelIdxList([sizes.Area]<sizeValue)= [];
    biofilms.NumObjects = biofilms.NumObjects - sum([sizes.Area]<sizeValue);
    biofilms = labelmatrix(biofilms)>0;
    
    handles.settings.mask = biofilms;
else
    biofilms = varargin{1};
end
perim = imdilate(bwperim(biofilms), strel('disk', 2));
image1 = (double(handles.settings.image)-handles.settings.pc10)./(handles.settings.pc99-handles.settings.pc10);
image1(perim) = 1;
image2 =(double(handles.settings.image)-handles.settings.pc10)./(handles.settings.pc99-handles.settings.pc10);
image2(perim) = 0;

image = cat(3, image1, image2, image2);
imagesc(image, 'Parent', handles.biofilmImage);
axis(handles.biofilmImage, 'off');


guidata(hObject, handles);



function varargout = chooseBiofilms_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;


function slider_Threshold_Callback(hObject, eventdata, handles)
updateImage(hObject, handles);


function slider_Threshold_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider_colonySize_Callback(hObject, eventdata, handles)
updateImage(hObject, handles);


function slider_colonySize_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function pushbutton_addColony_Callback(hObject, eventdata, handles)
try
    axes(handles.biofilmImage);
    mask = roipoly;
    handles.settings.mask = handles.settings.mask | mask;
    updateImage(hObject, handles, handles.settings.mask);
catch
end



function pushbutton_removeColony_Callback(hObject, eventdata, handles)
try
    axes(handles.biofilmImage);
    mask = roipoly;
    handles.settings.mask = handles.settings.mask & ~mask;
    updateImage(hObject, handles, handles.settings.mask);
catch
end


function pushbutton_Clone_Callback(hObject, eventdata, handles)
hObject.String = 'Please wait';
objects = bwconncomp(handles.settings.mask);
boxes = regionprops(objects, 'BoundingBox');

fprintf(' - Creating folders for %d subcolonies', objects.NumObjects);
textprogressbar('      ');

if ~handles.uicontrols.checkbox.checkbox_keepDirectory.Value && handles.uicontrols.checkbox.checkbox_applyToAll.Value
    newFolders = BiofilmQ('menu_file_duplicateDir_Callback', handles.handles_main.menuHandles.menues.menu_file_duplicateDir, eventdata, handles.handles_main, objects.NumObjects);
end

for j = 1:objects.NumObjects
    textprogressbar(j/objects.NumObjects*100);
    
    coords = boxes(j).BoundingBox;
    if handles.handles_main.uicontrols.checkbox.imageRegistration.Value && ...
        isfield(handles.settings.metadata.data, 'registration')
        registration = handles.settings.metadata.data.registration.T;
        coords(1:2) = coords(1:2) + [registration(4,1) registration(4,2)];
    end
    coords = round(coords);
    
    
    
    
    if handles.uicontrols.checkbox.checkbox_keepDirectory.Value
        
        features = getFeaturesFromName(handles.settings.filename);
        position = features.pos_str;
        pos = round(str2double(position));
        
        if ~isempty(position) && ~isnan(pos)
            newFileName = strrep(handles.settings.filename, ['_pos', position], ['_pos', num2str(pos+1)]);
            
            
            c = 2;
            
            
            while exist(fullfile(handles.handles_main.settings.directory, newFileName), 'file') &&  c < 1000
                newFileName = strrep(handles.settings.filename, ['_pos', position], ['_pos', num2str(pos+c)]);
                c = c+1;
            end
        else
            c = 1;
            newFileName =sprintf('Colony%d_%s',c,handles.settings.filename);
            while exist(fullfile(handles.handles_main.settings.directory,newFileName), 'file') &&  c < 1000
                c = c+1;
                newFileName =sprintf('Colony%d_%s',c,handles.settings.filename);
            end
        end
        
        
        c = 0;
        while exist(fullfile(handles.handles_main.settings.directory,newFileName), 'file') 
            newFileName = strrep(handles.settings.filename, '.tif', sprintf('_%d.tif', c));
            c = c+1;
        end
        
        copyAndCropChannels(handles, handles.handles_main.settings.directory, newFileName, coords);
        
    else
        
        

        if handles.uicontrols.checkbox.checkbox_applyToAll.Value
            cropAll(handles.handles_main, newFolders{j}, coords);
        else
            newDir = strcat(handles.handles_main.settings.directory, sprintf('-%d',j));
            c = 1;
            while exist(newDir, 'dir')
                newDir = strcat(handles.handles_main.settings.directory, sprintf('-%d',j+c));
                c = c+1;
            end
            mkdir(newDir);
            copyAndCropChannels(handles, newDir, handles.settings.filename, coords);
        end
        
    end
end

textprogressbar(100);
textprogressbar(' Done.');
fprintf('\n');

BiofilmQ('pushbutton_refreshFolder_Callback', handles.handles_main.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, handles.handles_main);


close(handles.figure1);

function copyAndCropChannels(handles, newDir, newName, coords)
files_metadata_name = strrep(handles.settings.filename, '.tif', '_metadata.mat');
channelData = get(handles.handles_main.uicontrols.popupmenu.channel, 'String');
channel = channelData{get(handles.handles_main.uicontrols.popupmenu.channel, 'Value')};
ch_toProcess = 1:length(channelData);
for c = 1:numel(ch_toProcess)
    
    imgName = fullfile(newDir, ...
        strrep(newName, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
    filename_ch = strrep(imgName, '.tif', '_metadata.mat');
    
    copyFrom = fullfile(handles.handles_main.settings.directory, ...
        strrep(handles.settings.filename, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
    
    copyfile(copyFrom, imgName);
    
    try
        data = load(fullfile(handles.handles_main.settings.directory, files_metadata_name));
        data = data.data;
        data.cropRange = coords;
        save(filename_ch, 'data');
    catch err
        warning('backtrace', 'off');
        warning(err.message);
        warning('backtrace', 'on');
    end
end


function copyAllChannels(filename_source, filename_dest, handles_main, varargin)
sourceDir = handles_main.settings.directory;
if nargin > 3
    destDir = varargin{1};
    if strcmp(destDir, sourceDir)
        return
    end
    copyfile(fullfile(sourceDir, 'parameters.mat'), fullfile(destDir, 'parameters.mat'));
else
    destDir = sourceDir;
end

channelData = get(handles_main.uicontrols.popupmenu.channel, 'String');
channel = channelData{get(handles_main.uicontrols.popupmenu.channel, 'Value')};
metadata_source = strrep(filename_source, '.tif', '_metadata.mat');
metadata_dest = strrep(filename_dest, '.tif', '_metadata.mat');
for c = 1:numel(channelData)
    try
        metadata_source_full = fullfile(sourceDir, ...
            strrep(metadata_source, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{c})]));
        metadata_dest_full = fullfile(destDir, ...
            strrep(metadata_dest, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{c})]));
        
        file_source_full = fullfile(sourceDir, ...
            strrep(filename_source, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{c})]));
        
        file_dest_full = fullfile(destDir, ...
            strrep(filename_dest, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{c})]));
        
        copyfile(metadata_source_full, metadata_dest_full);
        copyfile(file_source_full, file_dest_full);
        
    end
end





function checkbox_keepDirectory_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    handles.uicontrols.checkbox.checkbox_applyToAll.Value = 0;
    handles.uicontrols.checkbox.checkbox_applyToAll.Enable = 'off';
else
    handles.uicontrols.checkbox.checkbox_applyToAll.Enable = 'on';
end
guidata(hObject, handles);


function pushbutton_proceedWithOneColony_Callback(hObject, eventdata, handles)
objects = bwconncomp(handles.settings.mask);
[x,y] = ginput(1);
x = round(x);
y = round(y);
if x < 1 || x > objects.ImageSize(2) || y < 1 || y > objects.ImageSize(1)
    msgbox('Coordinates out of image! Please click on a biofilm in the image.', 'Error');
    return
end

pick = zeros(size(handles.settings.mask));
pick(y,x) = 1;
boxes = regionprops(objects, pick, 'BoundingBox', 'MaxIntensity');
match = find([boxes.MaxIntensity]==1);

if isempty(match)
    msgbox('No biofilm present for these coordinates! Please click on a biofilm in the image.', 'Error');
    return
end

match = match(1);
coords = boxes(match).BoundingBox;
if handles.handles_main.uicontrols.checkbox.imageRegistration.Value
    registration = handles.settings.metadata.data.registration.T;
    coords(1:2) = coords(1:2) + [registration(4,1) registration(4,2)];
end
coords = round(coords);

if handles.uicontrols.checkbox.checkbox_keepDirectory.Value

    handles.handles_main.uicontrols.edit.cropRange.String = num2str(coords);
    BiofilmQ('cropRange_Callback', handles.handles_main.uicontrols.edit.cropRange, eventdata, handles.handles_main);

    if handles.uicontrols.checkbox.checkbox_applyToAll.Value
        BiofilmQ('pushbutton_applyCropAll_Callback', handles.handles_main.uicontrols.pushbutton.pushbutton_applyCropAll, eventdata, handles.handles_main);
    end
    
else
    if handles.uicontrols.checkbox.checkbox_applyToAll.Value
        newFolders = BiofilmQ('menu_file_duplicateDir_Callback', handles.handles_main.menuHandles.menues.menu_file_duplicateDir, eventdata, handles.handles_main, 1);
        cropAll(handles.handles_main, newFolders{1}, coords);
    else
        newDir = strcat(handles.handles_main.settings.directory, sprintf('-%d',1));
        c = 1;
        while exist(newDir, 'dir')
            newDir = strcat(handles.handles_main.settings.directory, sprintf('-%d',1+c));
            c = c+1;
        end
        mkdir(newDir);
        copyAndCropChannels(handles, newDir, handles.settings.filename, coords);
    end
    
end
updateWaitbar(handles, 0);
close(handles.figure1)


function checkbox_applyToAll_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    handles.uicontrols.checkbox.checkbox_keepDirectory.Value = 0;
    handles.uicontrols.checkbox.checkbox_keepDirectory.Enable = 'off';
else
    handles.uicontrols.checkbox.checkbox_keepDirectory.Enable = 'on';
end
guidata(hObject, handles);





function edit_intensity_threshold_Callback(hObject, eventdata, handles)
updateImage(hObject, handles);


function edit_intensity_threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_colony_size_Callback(hObject, eventdata, handles)
updateImage(hObject, handles);

function edit_colony_size_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cropAll(handles, directory, cropRange)
for i = 1:length(handles.settings.lists.files_metadata)
    if ~mod(i-1, 10)
        updateWaitbar(handles, i/length(handles.settings.lists.files_metadata))
    end
    
    metadata = load(fullfile(directory, handles.settings.lists.files_metadata(i).name));
    data = metadata.data;
    data.cropRange = cropRange;
    cropRange_appliesToRegisteredImage = get(handles.uicontrols.checkbox.imageRegistration, 'Value');
    data.cropRange_appliesToRegisteredImage = get(handles.uicontrols.checkbox.imageRegistration, 'Value');
    
    handles.settings.metadataGlobal{i}.data = data;
    save(fullfile(directory, handles.settings.lists.files_metadata(i).name), 'data');
    
    
    channelData = get(handles.uicontrols.popupmenu.channel, 'String');
    if numel(channelData) > 1
        channel = channelData{get(handles.uicontrols.popupmenu.channel, 'Value')};
        ch_toProcess = find(~cellfun(@(x) strcmp(x, channel), channelData));
        for c = 1:numel(ch_toProcess)
            filename_ch = fullfile(directory, ...
                strrep(handles.settings.lists.files_metadata(i).name, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
            
            try
                data = load(filename_ch);
                data = data.data;
                data.cropRange = cropRange;
                data.cropRange_appliesToRegisteredImage = cropRange_appliesToRegisteredImage;
                save(filename_ch, 'data');
            catch err
                warning('backtrace', 'off');
                warning(err.message);
                warning('backtrace', 'on');
            end
        end
    end

end



