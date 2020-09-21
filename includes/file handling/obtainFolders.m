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
function folders = obtainFolders(inputFolder, varargin)

p = inputParser;

addRequired(p, 'inputFolder');
addParameter(p, 'state', 'all');
addParameter(p, 'foldersToProcess', {''});

parse(p,inputFolder,varargin{:});

inputFolder = p.Results.inputFolder;
state = p.Results.state;
foldersToProcess = p.Results.foldersToProcess;

folders = genpath(inputFolder);
folders = strsplit(folders, ';');

if ~isempty(foldersToProcess{1})
    
    continueWithFolders = false(1, numel(folders));
    for i = 1:numel(foldersToProcess)
        processFolder = strfind(folders, foldersToProcess{i});
        continueWithFolders(~cellfun(@isempty, processFolder)) = true;
    end
    folders = folders(continueWithFolders);
end

if strcmpi(state, 'processed')
    
    continueWithFolders = false(1, numel(folders));
    for i = 1:numel(folders)
        [~, lastFolder] = fileparts(folders{i});
        if strcmp(lastFolder, 'data')
            continueWithFolders(i) = true;
        end
    end
    folders = folders(continueWithFolders);
    
    
    folders = cellfun(@fileparts, folders, 'UniformOutput', false);
end
 
continueWithFolders = false(1, numel(folders));
for i = 1:numel(folders)
    [~, lastFolder] = fileparts(strrep(folders{i}, '.', '_'));
    if ~isempty(strfind(lower(lastFolder), 'pos'))
        continueWithFolders(i) = true;
    end
end
folders = folders(continueWithFolders);

if strcmpi(state, 'unprocessed')
    
    continueWithFolders = false(1, numel(folders));
    for i = 1:numel(folders)
        if ~isdir(fullfile(folders{i}, 'data'))
            continueWithFolders(i) = true;
        end
    end
    folders = folders(continueWithFolders);
end

folders = folders';


