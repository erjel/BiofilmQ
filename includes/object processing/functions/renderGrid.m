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
function renderGrid(handles, wCells, wShell, wInt, filename, params)

I = wInt(wShell);
I = prctile(I, 80);

w = uint32(wInt>I | wShell);
w(wCells) = 0;

objects = cubeSegmentation(w, params.gridSpacing);

stats_temp_shell = regionprops(objects, wInt, 'MeanIntensity');
stats_temp_shell = num2cell([stats_temp_shell.MeanIntensity]);
[stats.MeanIntensity] = stats_temp_shell{:};

objects.goodObjects = ones(1, numel(stats));
customFields = {'Area', 'volume_fraction', 'Grid_ID', 'MeanIntensity'};
cells = isosurfaceLabel(labelmatrix(objects), objects, 0.05, customFields, params);
mvtk_write(cells,fullfile(handles.settings.directory, 'data', [filename(1:end-4), '_shell.vtk']), 'legacy-binary', customFields);



