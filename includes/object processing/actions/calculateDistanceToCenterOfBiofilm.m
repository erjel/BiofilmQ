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
function objects = calculateDistanceToCenterOfBiofilm(objects)

ticValue = displayTime;

N = objects.NumObjects;


goodObjects = objects.goodObjects;

coords = [objects.stats.Centroid];

x = coords(1:3:end);
y = coords(2:3:end);
z = coords(3:3:end);

x_ = x(goodObjects);
y_ = y(goodObjects);
z_ = z(goodObjects);

CM = [mean(x_), mean(y_), mean(z_)];

toUm = @(voxel, scaling) voxel.*scaling/1000;

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);

distanceToCenter = fhypot(CM(1)-x, CM(2)-y, CM(3)-z);
distanceToCenterOfBiofilm = fhypot(CM(1)-x, CM(2)-y, min(z)-z);

distanceToCenter = num2cell(toUm(distanceToCenter, objects.params.scaling_dxy));
distanceToCenterOfBiofilm = num2cell(toUm(distanceToCenterOfBiofilm, objects.params.scaling_dxy));

distanceToCenter(~goodObjects) = {NaN};
distanceToCenterOfBiofilm(~goodObjects) = {NaN};

[objects.stats.Distance_ToBiofilmCenter] = distanceToCenter{:};
[objects.stats.Distance_ToBiofilmCenterAtSubstrate] = distanceToCenterOfBiofilm{:};

fprintf('   - CM: [x=%.02f, y=%.02f, z=%.02f]', CM(1), CM(2), CM(3));
displayTime(ticValue);



