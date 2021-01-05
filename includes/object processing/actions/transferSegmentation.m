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

function transferSegmentation(handles)
ticValueAll = displayTime;

showPopup = handles.settings.showMsgs;

params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

assert(numel(params.mergeChannel2) == 1);
assert(isnumeric(params.mergeChannel1));
assert(isnumeric(params.mergeChannel2));

range = str2num(params.action_imageRange);

files = handles.settings.lists.files_tif;


range_new = intersect(range, 1:numel(files));
if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;

currentChannel = params.channel;

sourceChannel = params.transferChannel2;
destChannels = unique(params.transferChannel1, 'stable');

N = numel(destChannels);


if ~exist(fullfile(handles.settings.directory, 'data', 'backup_transfer'), 'dir')
    mkdir(fullfile(handles.settings.directory, 'data', 'backup_transfer'));
end
    
for f = 1:numel(range)
    i = range(f);
    ticValueImage = displayTime;
    fprintf('=========== Processing image %d of %d  ===========\n', i, numel(range));
    
    updateWaitbar(handles, (f-0.7)/numel(range));
    
    
    filename =  strrep(files(i).name, '.tif', '_data.mat');
    
    filename_source = strrep(filename, sprintf('_ch%d', currentChannel), sprintf('_ch%d', sourceChannel));
    
    if ~exist(fullfile(handles.settings.directory, 'data', filename_source), 'file')
                showErrorMessage(...
            sprintf('The required file %s does not exist!', fullfile(handles.settings.directory, 'data', filename_source)), ...
            showPopup);
        continue
    end
    
    
    updateWaitbar(handles, (f-0.3)/numel(range));
    
    displayStatus(handles, ...
        sprintf('Loading image sets %d of %d ...', i, numel(range)), ...
        'blue');
    

    for j = 1:N
        filename_dest = strrep(filename, sprintf('_ch%d', currentChannel), sprintf('_ch%d', destChannels(j)));
        if exist(fullfile(handles.settings.directory, 'data', filename_dest), 'file')
            copyfile(fullfile(handles.settings.directory, 'data', filename_dest), fullfile(handles.settings.directory, 'data','backup_transfer', filename_dest));
                ticValue = displayTime();
                fprintf(' -> moving original files to "data/backup_transfer"');
        end
        copyfile(fullfile(handles.settings.directory, 'data', filename_source), fullfile(handles.settings.directory, 'data', filename_dest));
    end
    
    displayStatus(handles, 'Done', 'blue', 'add');
    
    if checkCancelButton(handles)
        break;
    end
    fprintf('-> total elapsed time per image')
    displayTime(ticValueImage);
end


updateWaitbar(handles, 0);

fprintf('-> total elapsed time')
displayTime(ticValueAll);
end


