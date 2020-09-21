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
function removeFilesAfterDeconvolution(handles)


if isstruct(handles)
    mode = 1;
    output_folder = fullfile(handles.settings.directory, 'deconvolved images');
else
    mode = 0;
    output_folder = handles;
end


if ~exist(output_folder, 'dir')
    warning('Files are not deconvoluted.');
    return;
end

if mode
    displayStatus(handles, 'Removing files...', 'black')
end

true_files = dir(fullfile(output_folder, '*.tif'));

try
    delete(fullfile(output_folder, '*.txt'));
    delete(fullfile(output_folder, '*.hgsb'));
    delete(fullfile(output_folder, '*.log'));
end

for j = 1:numel(true_files)
    if mode
        updateWaitbar(handles, j/numel(true_files));
    end
    
    name = true_files(j).name;
    
    if ~any(strfind(name, 'cmle'))
        delete(fullfile(true_files(j).folder, true_files(j).name));
    end
end
if mode
    displayStatus(handles, 'Done', 'gray', 1);
    updateWaitbar(handles, 0);
end

leftfiles = dir(output_folder);
if length(leftfiles)<3
    rmdir(output_folder);
end

end




