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
function biofilmHull = createHull(objects, params, res)

if res ==1
    biofilmHull = labelmatrix(objects)>0;
    return;
end

toPix = @(voxel, scaling) voxel./scaling*1000;


centroid = [objects.stats.Centroid];
Cx = centroid(1:3:end);
Cy = centroid(2:3:end);
Cz = centroid(3:3:end);

if isfield(objects.stats, 'length')
    length = toPix([objects.stats.length], objects.params.scaling_dxy);
    
    evecs = {objects.stats.evecs};
    
    cell_edges1 = zeros(numel(length), 3);
    cell_edges2 = zeros(numel(length), 3);
    for i = 1:numel(length)
        cell_edges1(i,:) = [Cx(i) Cy(i) Cz(i)]' + 0.5*length(i)*evecs{i}(:,1);
        cell_edges2(i,:) = [Cx(i) Cy(i) Cz(i)]' - 0.5*length(i)*evecs{i}(:,1);
    end
    
    allPoints = [cell_edges1(:,1) cell_edges1(:,2) cell_edges1(:,3);...
        Cx'                Cy'                Cz';...
        cell_edges2(:,1) cell_edges2(:,2) cell_edges2(:,3)];
else
    allPoints = [Cx' Cy' Cz'+params.gridSpacing/2];
end

X = res/2:res:objects.ImageSize(2)-res/2;
Y = res/2:res:objects.ImageSize(1)-res/2;


hull_z = zeros(numel(Y), numel(X));
for x_ind = 1:numel(X)
    x = X(x_ind);
    for y_ind = 1:numel(Y)
        y = Y(y_ind);
        distance_to_anchor = hypot(x-allPoints(:,1), y-allPoints(:,2));
        pointsCloseBy = find(distance_to_anchor<res);
        if ~isempty(pointsCloseBy)
            hull_z(y_ind, x_ind) = max(allPoints(pointsCloseBy, 3)); 
        else
            hull_z(y_ind, x_ind) = 0;
        end
    end
end
hull_z = imresize(hull_z, [objects.ImageSize(1) objects.ImageSize(2)]);

if numel(objects.ImageSize)==3
    biofilmHull = false(objects.ImageSize(1), objects.ImageSize(2), objects.ImageSize(3));
else
    biofilmHull = false(objects.ImageSize(1), objects.ImageSize(2), 1);
end

for x = 1:size(biofilmHull,1)
    for y = 1:size(biofilmHull,2)
        biofilmHull(x,y,1:round(hull_z(x,y))) = true;
    end
end


