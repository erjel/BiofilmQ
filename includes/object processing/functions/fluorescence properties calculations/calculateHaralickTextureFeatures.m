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
function objects = calculateHaralickTextureFeatures(objects, img, ch_task, range)

if numel(objects.ImageSize) == 2
    warning('backtrace', 'off')
    warning('The calculation of Haralick texture features is only implemented in 3D, yet.');
    warning('backtrace', 'on');
    return;
end



ticValue = displayTime;

img = img{ch_task};

s = round(range*(objects.params.scaling_dxy/1000));
fprintf(' - range corresponds to: %.2f um\n', s);
grid = range;

if isfield(objects.stats, 'Cube_CenterCoord')
    coords = [objects.stats.Cube_CenterCoord];
else
    coords = [objects.stats.Centroid];
end

coords1 = reshape(coords, 3, []);
coords_start = round(coords1 - floor(grid/2));
coords_end   = round(coords1 + ceil(grid/2-1));

[sX, sY, sZ] = size(img);

ind = all(bsxfun(@le, coords_end, [sY; sX; sZ]), 1);
Nc = sum(ind);
coords_start = coords_start(:, ind);
coords_end = coords_end(:, ind);

cubes = zeros(grid, grid, grid, Nc);

for i = 1:Nc
    cubes(:, :, :, i) = img(coords_start(2, i):coords_end(2, i), coords_start(1, i):coords_end(1, i), coords_start(3, i):coords_end(3, i));
end

directions = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1];

fprintf(' - calculating haralick features for each cube');
hFeatures = cooc3d(cubes, 'distance', [1], 'direction',  directions);

hFeatures = mean(reshape(hFeatures, Nc, [], size(directions, 1)), 3);

featureNames = {'Energy', 'Entropy', 'Correlation', 'Contrast', 'Homogeneity', ...
 'Variance', 'SumMean', 'Inertia', 'ClusterShade', 'ClusterTendency', ...
 'MaxProbability', 'InverseVariance'};

feature = NaN(size(ind));
for i = 1:numel(featureNames)
    if ~isempty(hFeatures)
        feature(ind) = hFeatures(:, i);
    end
    featureCell = num2cell(feature);
    [objects.stats.(sprintf('Texture_Haralick_%s_ch%d_range%d', featureNames{i}, ch_task, range))] = featureCell{:};
end

fprintf(' - finished');
displayTime(ticValue);




