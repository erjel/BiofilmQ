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
function tempDirInfo(handles)

try
    
    bytes_current_free = disk_free(handles.settings.directory)/(1024*1024*1024);
    bytes_temp_free = disk_free(get(handles.uicontrols.edit.tempFolder, 'String'))/(1024*1024*1024);


    bytes_current = folderSizeTree(handles.settings.directory);
    bytes_current = sum(cell2mat([bytes_current.size]))/(1024*1024*1024);

    try
        bytes_temp = folderSizeTree(get(handles.uicontrols.edit.tempFolder, 'String'));
        bytes_temp = sum(cell2mat([bytes_temp.size]))/(1024*1024*1024);
    catch
        bytes_temp = 0;
    end

    try
        projectFolders = strsplit(handles.settings.directory, filesep);
        bytes_temp_current = folderSizeTree(fullfile(get(handles.uicontrols.edit.tempFolder, 'String'), projectFolders{end-1}, projectFolders{end}));
        bytes_temp_current = sum(cell2mat([bytes_temp_current.size]))/(1024*1024*1024);
    catch
        bytes_temp_current = 0;
    end

    infoString = {sprintf('Temporary files: %.1f / %.1f Gb', bytes_temp_current, bytes_temp_free), sprintf('Current files: %.1f / %.1f Gb', bytes_current,bytes_current_free)};

    set(handles.uicontrols.text.text_tempDirectoryStats, 'String', infoString)
end


