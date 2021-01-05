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
function objects = calculateCell2CellDistance(handles, objects, params, ch, filename)
ticValue = displayTime;

distances = nan(objects.NumObjects, 1);

if objects.params.channel ~= ch
    filename = fullfile(handles.settings.directory, 'data', [strrep(filename(1:end-4), sprintf('_ch%d', objects.params.channel), sprintf('_ch%d', ch)), '_data.mat']);
    
    if ~exist(filename, 'file')
        warning('backtrace', 'off');
        warning('Cannot calculate nearest neighbor distances to objects in ch #%d (file "%s" does not exist)!', ch, filename);
        warning('backtrace', 'on');
        
        [objects.stats.(sprintf('Distance_ToNearestObject_ch%s', ch))] = distances{:};
        displayTime(ticValue);
        return
    end
    
    objects_neighbors = loadObjects(filename, 'stats');
else
    objects_neighbors = objects;
end

goodObjects = objects.goodObjects;

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
toUm = @(voxel, scaling) voxel.*scaling/1000;
toPx = @(um, scaling) um.*(1000/scaling);


N = objects.NumObjects;

centroids = cell(3,1);
cc = [objects.stats.Centroid];
centroids{1} = cc(1:3:end);
centroids{2} = cc(2:3:end);
centroids{3} = cc(3:3:end);

centroids_neighbors = cell(3,1);
cc_neighbors = [objects_neighbors.stats.Centroid];
centroids_neighbors{1} = cc_neighbors(1:3:end);
centroids_neighbors{2} = cc_neighbors(2:3:end);
centroids_neighbors{3} = cc_neighbors(3:3:end);

for i = 1:N
    
    if goodObjects(i)
        dist = fhypot(centroids{1}(i)-centroids_neighbors{1}, centroids{2}(i)-centroids_neighbors{2}, centroids{3}(i)-centroids_neighbors{3});
        
        dist(~goodObjects) = Inf;
        
        dist = sort(dist);
        
        if objects.params.channel == ch
            if N > 1
                distances(i) = dist(2);
            else
                distances(i) = NaN;
            end
        else
            if ~isempty(dist)
                distances(i) = dist(1);
            else
                distances(i) = NaN;
            end
        end
    end
    
end

distances = num2cell(toUm(distances, params.scaling_dxy));

if objects.params.channel == ch
    [objects.stats.Distance_ToNearestNeighbor] = distances{:};
else
    [objects.stats.(sprintf('Distance_ToNearestObject_ch%d', ch))] = distances{:};
end
displayTime(ticValue);









