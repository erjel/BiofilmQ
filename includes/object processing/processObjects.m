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
function processObjects(hObject, eventdata, handles)
disp(['=========== Calculating cell properties ===========']);

ticValueAll = displayTime;

params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;
range = str2num(params.action_imageRange);

files = handles.settings.lists.files_cells;
if ~isempty(files(:))
    validFiles = find(cellfun(@(x) isempty(x), strfind({files.name}, 'missing')));
    
    range_new = intersect(range, validFiles);
    
    if numel(range) ~= numel(range_new)
        fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
    end
else
    range_new = [];
end
range = range_new;

if isempty(range)
    uiwait(msgbox('No object files present.', 'Error', 'error', 'modal'));
    fprintf('No object files present -> Processing cancelled.\n');
    return;
end

try
    enableCancelButton(handles)
end

for f = range
    ticValueImage = displayTime;
    disp(['=========== Processing image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
    
    
    updateWaitbar(handles, (f-range(1))/(1+range(end)-range(1))+0.001);
    
    
    displayStatus(handles,['Processing cells ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    filename = fullfile(handles.settings.directory, 'data', files(f).name);
    
    try
        objects = loadObjects(filename);
    catch
       fprintf('   - skipping file \n') 
    end
    
    if objects.NumObjects == 0
        fprintf('   - empty file (skipping)\n');
        continue;
    end

    updateWaitbar(handles, (f+0.6-range(1))/(1+range(end)-range(1)));
    displayStatus(handles, 'calculating properties...', 'blue', 'add');
    
    try
        imageFilename = handles.settings.lists.files_tif(f).name;
    catch
        imageFilename = '';   
    end
    
    objects = calculateCellProperties(handles, objects, params, imageFilename, f);
    
    
    updateWaitbar(handles, (f+0.9-range(1))/(1+range(end)-range(1)));
    if ~params.cellParametersNoSaving
        saveObjects(filename, objects, 'all', 'overwrite')
    end
    
    displayStatus(handles, 'Done', 'blue', 'add');

    fprintf('-> total elapsed time per image')
    displayTime(ticValueImage);
    
    if checkCancelButton(handles)
        break;
    end
end


updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);



