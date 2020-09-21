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
function visualizeExtracellularFluorophores(objects, img, ch_task, opts, task, handles, filename, range)

objects_shells = calculateObjectShells(objects, range);

shells_mask = labelmatrix(objects_shells)>0;

shells = img{ch_task}(shells_mask);

intensity = shells;
[Y, X, Z] = ind2sub(objects.ImageSize, find(shells_mask));
matrix = struct('vertices',[X Y Z], 'intensity',intensity);

zIdx = strfind(filename, '_Nz');
frameIdx = strfind(filename, '_frame');
mvtk_write(matrix, fullfile(handles.settings.directory, 'data', [filename(1:frameIdx-1), '_shell_', filename(frameIdx+1:zIdx-1), '.vtk']) , 'legacy-binary', {'intensity'});






