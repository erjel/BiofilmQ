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
function [objects, distMap] = calculateDistanceToSurface(objects, params, res)

ticValue = displayTime;

fprintf(' [resolution=%d vox]', res);
toUm = @(voxel, scaling) voxel.*scaling/1000;
toPix = @(voxel, scaling) voxel./(scaling/1000);

objectsHull = objects;


biofilmHull = createHull(objectsHull, params, res);

distMap = bwdist(true-biofilmHull);

centroid = [objects.stats.Centroid];
Cx = centroid(1:3:end);
Cy = centroid(2:3:end);
Cz = centroid(3:3:end);

badCoordinates = unique([find(isnan(Cx)) find(isnan(Cy)) find(isnan(Cz))]);

ind = sub2ind(size(distMap), round(Cy), round(Cx), round(Cz));
ind(badCoordinates) = 1;
distanceToSurface = double(distMap(ind));
distanceToSurface = toUm(distanceToSurface, objects.params.scaling_dxy);
distanceToSurface(badCoordinates) = NaN;
distanceToSurface = num2cell(distanceToSurface);

[objects.stats.(sprintf('Distance_ToSurface_resolution%d', res))] = distanceToSurface{:};

displayTime(ticValue);




