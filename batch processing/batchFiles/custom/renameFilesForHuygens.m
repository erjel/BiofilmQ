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

cd(fileparts(which('BiofilmQ')));

range = 1:numel(folders);

handles = handles.handles_GUI;
hObject = handles.mainFig;

for i = range
    if isdir(fullfile(folders{i}))
        path = folders{i};
        files = dir(path);
        files = files(3:end);
        files = files(~[files.isdir]);
        for j = 1:length(files)
            name = files(j).name;
            newName = strrep(name , ' ', '');
            if ~strcmp(name, newName)
                movefile(fullfile(path, name), fullfile(path, newName));
            end
        end

        path = fullfile(path, 'deconvolved images');
        files = dir(path);
        files = files(3:end);
        files = files(~[files.isdir]);
        for j = 1:length(files)
            name = files(j).name;
            newName = strrep(name , ' ', '');
            if ~strcmp(name, newName)
                movefile(fullfile(path, name), fullfile(path, newName));
            end
        end
    
    end
end


