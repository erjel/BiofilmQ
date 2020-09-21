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
function objects = removeObjectsOnBorder(handles, objects, params, filename)
ticValue = displayTime;

metadata = load(fullfile(handles.settings.directory, [filename(1:end-4), '_metadata.mat']));

try
    params.cropRange = metadata.data.cropRange;
catch
    params.cropRange = [];
end

w = labelmatrix(objects);
borderStack = false(size(w));

if isfield(objects, 'ImageContentFrame')
    x = objects.ImageContentFrame(1:2);
    y = objects.ImageContentFrame(3:4);
    
    borderStack(x(1), :, :) = true;
    borderStack(x(2), :, :) = true;
    borderStack(:, y(1), :) = true;
    borderStack(:, y(2), :) = true;
else
    
    
    
    borderStack(3,:,:) = true;
    borderStack(end-2,:,:) = true;
    borderStack(:,3,:) = true;
    borderStack(:,end-2,:) = true;
end

idsOnBorder = w(borderStack);
idsOnBorder = unique(idsOnBorder);

if idsOnBorder(1) == 0
    idsOnBorder(1) = [];
end

validIds = true(1, objects.NumObjects);
validIds(idsOnBorder) = false;

objects.PixelIdxList = objects.PixelIdxList(validIds);
objects.NumObjects = sum(validIds);
objects.goodObjects = objects.goodObjects(validIds);
objects.stats = objects.stats(validIds);

fprintf(' - %d of %d cells removed', sum(~validIds), numel(validIds));
displayTime(ticValue);



