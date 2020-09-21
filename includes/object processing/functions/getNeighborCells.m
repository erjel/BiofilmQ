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
function [indObj_exp, distances] = getNeighborCells(centroid_sim, objects_exp, params)

goodObjects = objects_exp.goodObjects;

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
toUm = @(voxel, scaling) voxel.*scaling/1000;

centroids = [objects_exp.stats.Centroid];

x = centroids(1:3:end);
y = centroids(2:3:end);
z = centroids(3:3:end);

dist = fhypot(centroid_sim(1)-x, centroid_sim(2)-y, centroid_sim(3)-z);

dist(~goodObjects) = Inf;

[dist, indObj_exp] = sort(dist);

distances = toUm(dist, params.scaling_dxy);









