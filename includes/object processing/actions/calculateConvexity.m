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
function objects = calculateConvexity(objects, silent)
if nargin < 2
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

convexity = zeros(objects.NumObjects,1);

N = objects.NumObjects;

PixelIdxList = objects.PixelIdxList;
ImageSize = objects.ImageSize;

parfor i = 1:N
    try
        [y, x, z] = ind2sub(ImageSize, PixelIdxList{i});
        if sum(sum(diff(z))) 
            [~, v] = convhull(x,y,z);
        else 
            [~, v] = convhull(x,y);
        end
        convexity(i) = numel(PixelIdxList{i})/v;
    catch
        convexity(i) = NaN;
    end
end


convexity = num2cell(convexity);
[objects.stats.Shape_Convexity] = convexity{:};

if ~silent
    displayTime(ticValue);
end


