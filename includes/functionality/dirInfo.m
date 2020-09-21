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
function dirInfo(handles)

try
    
    bytes_current_free = disk_free(handles.settings.directory)/(1024*1024*1024);
    bytes_current = folderSizeTree(handles.settings.directory);
    bytes_current = sum(cell2mat([bytes_current.size]))/(1024*1024*1024);

    experimentFolders = dir(fullfile(handles.settings.directory, '..'));
    experimentFoldersN = 0;
    try
        experimentFolders = experimentFolders(3:end);
        experimentFoldersN = sum([experimentFolders.isdir]); 
    end
    infoString = {sprintf('Size of current folder: %.2f Gb, Free disk space: %.1f Gb', bytes_current, bytes_current_free), sprintf('Number of similar experiment folders: %d', experimentFoldersN)};

    set(handles.uicontrols.text.text_folderProperties, 'String', infoString)
end


