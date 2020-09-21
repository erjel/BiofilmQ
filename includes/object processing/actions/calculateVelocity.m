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
function objects_t2 = calculateVelocity(objects_t1, objects_t2, params, init)

if nargin == 3
    init = 0;
end

if init
    velocity = num2cell(zeros(1, objects_t2.NumObjects));
    [objects_t2.stats.Track_Velocity] = velocity{:};
    return;
end

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
toUm = @(voxel, scaling) voxel.*params.scaling_dxy/1000;

try
    dt = (datenum(objects_t2.metadata.data.date) - datenum(objects_t1.metadata.data.date))*24*60*60;
    
    velocity = nan(numel(objects_t2.stats),1);
    
    
    parents = [objects_t2.stats.Track_Parent];
    
    
    centroids_parents = [objects_t1.stats.Centroid];
    x_parents = centroids_parents(1:3:end);
    y_parents = centroids_parents(2:3:end);
    z_parents = centroids_parents(3:3:end);
    
    
    centroids = [objects_t2.stats.Centroid];
    x = centroids(1:3:end);
    y = centroids(2:3:end);
    z = centroids(3:3:end);
    
    
    parents(isnan(parents)) = 0;
    validCells = find(parents);
    
    
    x_parents = x_parents(parents(validCells));
    y_parents = y_parents(parents(validCells));
    z_parents = z_parents(parents(validCells));
    
    x = x(validCells);
    y = y(validCells);
    z = z(validCells);
    
    distances = fhypot(x-x_parents, y-y_parents, z-z_parents);
    
    
    distances = toUm(distances);
    
    
    velocity(validCells) = distances/dt; 
    
    
    
    velocity = num2cell(velocity);
    [objects_t2.stats.Track_Velocity] = velocity{:};
catch err
    fprintf('%s\n', err.message);
end


