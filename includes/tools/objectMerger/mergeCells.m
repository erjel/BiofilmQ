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
function varargout = mergeCells(varargin)



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mergeCells_OpeningFcn, ...
    'gui_OutputFcn',  @mergeCells_OutputFcn, ...
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


function mergeCells_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

try
    addIcon(hObject);
end

guidata(hObject, handles);



function varargout = mergeCells_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;


function pushbutton_merge_Callback(hObject, eventdata, handles)
files = get(handles.listbox_files, 'String');

data = [];
h = waitbar(0, 'Loading files...', 'Name', 'Please wait');

for i = 1:length(files)
    data{i} = loadObjects(files{i});
    waitbar(i/length(files), h);
end
delete(h);

goOn = 1;
differentFieldnames = 0;
for i = 2:length(files)
    
    if (sum(data{i-1}.ImageSize == data{i}.ImageSize) ~= 3) && get(handles.checkbox_include3D, 'Value');
        disp('Image size is different!');
        goOn = 1;
    end
    if length(fieldnames(data{i-1}.stats)) ~= length(fieldnames(data{i}.stats))
        disp('Number of fieldnames is different!');
        goOn = 1;
        differentFieldnames = 1;
    else
        if sum(strcmp(sort(fieldnames(data{i-1}.stats)), sort(fieldnames(data{i}.stats)))) ~= length(strcmp(fieldnames(data{i-1}.stats), fieldnames(data{i}.stats)))
            disp('Fieldnames are different!');
            goOn = 1;
            differentFieldnames = 1;
        end
    end
end

if goOn
    h = waitbar(0, 'Merging files...', 'Name', 'Please wait');
    
    objects = [];
    
    Connectivity = data{1}.Connectivity;
    ImageSize = data{1}.ImageSize;
    
    for f = 2:length(files)
        
        NumObjects = data{f-1}.NumObjects+data{f}.NumObjects;
        
        if isfield(data{f}.stats, 'Grid_ID') 

            
            
            globalID1s = [data{f-1}.stats.Grid_ID];
            globalID2s = [data{f}.stats.Grid_ID];
            
            PixelIdxList = data{f-1}.PixelIdxList;
            
            for globalID2Ind = 1:numel(globalID2s)
                globalID2 = globalID2s(globalID2Ind);
                oldEntry = find(globalID2 == globalID1s);
                if ~isempty(oldEntry)
                    PixelIdxList{oldEntry} = union(PixelIdxList{oldEntry}, data{f}.PixelIdxList{globalID2Ind});
                else
                    PixelIdxList(end+1) = data{f}.PixelIdxList(globalID2Ind);
                end
            end
        end
        
        PixelIdxList = [data{f-1}.PixelIdxList data{f}.PixelIdxList];
        
        
        
        goodObjects = [data{f-1}.goodObjects; data{f}.goodObjects];
        
        if differentFieldnames
            fNames1 = fieldnames(data{i-1}.stats);
            fNames2 = fieldnames(data{i}.stats);
            fNames = intersect(fNames1, fNames2);
            
        else
            fNames = fieldnames(data{f-1}.stats);
        end
        
        waitbar(f/length(files), h);
        
        for i = 1:length(fNames)
            if size(data{f-1}.stats(1).(fNames{i}), 2) > 1 
                data_temp = [{data{f-1}.stats.(fNames{i})}'; {data{f}.stats.(fNames{i})}'];
                for j = 1:length(data_temp)
                    stats(j).(fNames{i}) = data_temp{j};
                end
            else
                data_temp = [[data{f-1}.stats.(fNames{i})]'; [data{f}.stats.(fNames{i})]'];
                for j = 1:length(data_temp)
                    stats(j).(fNames{i}) = data_temp(j);
                end
            end
        end
    end
    
    objects = data{1};
    
    objects.NumObjects = NumObjects;
    objects.PixelIdxList = PixelIdxList;
    objects.goodObjects = goodObjects;
    objects.stats = stats;
    
    
    objects = averageObjectParameters(objects);
    objects.stats = orderfields(objects.stats);
    objects.globalMeasurements = orderfields(objects.globalMeasurements);
    
    delete(h);
    
    
    if length(fNames) > 4
        uiwait(msgbox({'The files contain more than the basic measurements.',  'Please consider recalculating measurements which rely on the spatial distribution of the objects (e.g. "Distance to neared neighbor" or "Local density") as this has been changed.'}, 'Warning', 'warn', 'modal'));
    end
    if differentFieldnames
        uiwait(msgbox({'Files contained different measurements!',' Only measurements present in all files were taken.'}, 'Warning', 'warn', 'modal'));
    end
    
    
    
    if exist('directory.mat','file')
        load('directory.mat');
    else
        directory = '';
    end
    
    [filepath, filename, ext] = fileparts(files{1});
    
    
    [filename, directory] = uiputfile([filename, ext], 'Save merged objects', files{1});
    
    if directory
        h = waitbar(0.3, 'Saving files...', 'Name', 'Please wait');
        
        save('directory.mat', 'directory');
        
        saveObjects(fullfile(directory, filename), objects, 'all', 'init');

        disp('Cell files merged!');
        
        try
            waitbar(1, h);
            delete(h);
        end
        try
            delete(handles.figure1);
        end
        
    else
        disp('No file selected');
        return;
    end
    
else
    uiwait(msgbox('Cannot merge cell files.', 'Error', 'error'));
end

function pushbutton_cancel_Callback(hObject, eventdata, handles)
delete(handles.figure1);


function pushbutton_fileSelect_Callback(hObject, eventdata, handles)
if exist('directory.mat','file')
    load('directory.mat');
else
    directory = '';
end

[filename, directory] = uigetfile({'*.mat', 'Cell files'}, 'Please select all cell files you want to merge',  'MultiSelect','on', directory);
if directory
    save('directory.mat', 'directory');
    filepath = [];
    
    if ~iscell(filename)
        filepath = fullfile(directory, filename);
    else
        for i = 1:length(filename)
            filepath{i} = fullfile(directory, filename{i});
        end
    end
    set(handles.listbox_files, 'String', filepath);
    
    
else
    disp('No file selected');
    return;
end


function listbox_files_Callback(hObject, eventdata, handles)



function listbox_files_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_include3D_Callback(hObject, eventdata, handles)




