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
function objects_merged = mergeChannelsNone(objects_cell, mergeChannelArray)
fprintf(' - merging non-cubed data...\n');

assert(numel(objects_cell) == numel(mergeChannelArray));

if numel(unique(cellfun(@(x) x.Connectivity, objects_cell))) ~= 1
    me = MException('BiofilmQ:mismatchingConnectivity', ...
        'Different Connectivity!');
    throw(me);
    
elseif containsDifferentArrays(cellfun(@(x) x.ImageSize, objects_cell, 'UniformOutput', false))
    me = MException('BiofilmQ:mismatchingImageSize', ...
        'Merging cannot be perfomed, channels have different image sizes!');
    throw(me);
end

fnames = cellfun(@(x) sort(fieldnames(x.stats)), objects_cell, 'UniformOutput', false);

warning('backtrace', 'off');
intersectFields = true;
if differentNumberOfElements(fnames)
    warning( ...
        ['The measurement fields of object files are not the same', ...
        ' (different numbers)!', ...
        ' -> Taking only the ones present in both files.']);
elseif containsDifferentStrings(fnames)
    warning( ...
        ['The measurement fields of object files are not the same', ...
        ' (different types)!', ...
        ' -> Taking only the ones present in both files.']);
else
    intersectFields = false;
end
warning('backtrace', 'on');

if intersectFields
    fNames_intersection = fnames{1};
    for i = 2:numel(fnames)
        fNames_intersection = intersect(fNames_intersection, fnames{i});
    end
    
    for i = 1:numel(objects_cell)
        fnames_object = fnames{i};
        for j = 1:numel(fnames_object)
            if ~ismember(fNames_intersection, fnames_object{j})
                objects_cell{i}.stats = rmfield(objects_cell{i}.stats,  fnames_object{j});
            end
        end
    end
end

for i = 1:numel(objects_cell)
    channel = num2cell(mergeChannelArray(i)*ones(objects_cell{i}.NumObjects, 1));
    [objects_cell{i}.stats.Channel] = channel{:};
    
    for field = {'merged', 'splitted'}
        if ~isfield(objects_cell, field{:})
            objects_cell{i}.(field{:}) = false(objects_cell{i}.NumObjects, 1);
        end
    end
end

objects_merged = [];
PixelIdxList_cell = cellfun(@(x) x.PixelIdxList, objects_cell, 'UniformOutput', false);
objects_merged.PixelIdxList = horzcat(PixelIdxList_cell{:});

for field = {'goodObjects', 'stats', 'merged', 'splitted'}
    try
        fields_cell = cellfun(@(x) x.(field{:}), objects_cell, 'UniformOutput', false);
        objects_merged.(field{:}) = vertcat(fields_cell{:});
        
    catch err
        fprintf('objects_cell.%s\n', field{:});
        rethrow(err);
    end
end

objects_merged.NumObjects = sum(cellfun(@(x) x.NumObjects, objects_cell));
objects_merged.Connectivity = objects_cell{1}.Connectivity;
objects_merged.ImageSize = objects_cell{1}.ImageSize;

objects_merged.measurementFields = objects_cell{1}.measurementFields;

objects_merged.comment = sprintf('merged data of channels (%s%d)', ...
    sprintf('%d, ', mergeChannelArray(1:end-1)), ...
    mergeChannelArray(end));

end

function different_number = differentNumberOfElements(cell)
different_number = numel(unique(cellfun(@numel, cell))) ~= 1;
end


function any_different = containsDifferentStrings(cells)
different_from_first = cellfun(@(x) any(~strcmp(cells{1}, x)), cells(2:end));
any_different = any(different_from_first);
end

function any_different = containsDifferentArrays(cells)
different_from_first = cellfun(@(x) any(cells{1} ~= x), cells(2:end));
any_different = any(different_from_first);
end


