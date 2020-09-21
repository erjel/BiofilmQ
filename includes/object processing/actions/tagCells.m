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
function objects = tagCells(objects, params)

if any(strcmp(params.tagCells_name, fieldnames(objects.stats)))
    error(['Tagname "%s" already exists!\n', ...
        'Use "Remove object parameters" to delete the existing tag first!'], ...
        params.tagCells_name)
end

for i = 1:size(params.tagCells_rules,1)
    centroids = [objects.stats.Centroid];
    
    if strcmp(params.tagCells_rules{i,1}, 'CentroidCoordinate_x')
        x = centroids(1:3:end);
        field = [params.tagCells_rules{i,1}];
    elseif strcmp(params.tagCells_rules{i,1}, 'CentroidCoordinate_y')
        y = centroids(2:3:end);
        field = [params.tagCells_rules{i,1}];
    elseif strcmp(params.tagCells_rules{i,1}, 'CentroidCoordinate_z')
        z = centroids(3:3:end);
        field = [params.tagCells_rules{i,1}];
    elseif strcmp(params.tagCells_rules{i,1}, 'ID')
        ID = 1:numel(objects.stats);
        field = [params.tagCells_rules{i,1}];
    else
        field = ['[objects.stats.', params.tagCells_rules{i,1}, ']'];
    end
    if i == 1
        rule = [field, params.tagCells_rules{i,2}, num2str(params.tagCells_rules{i,3})];
    else
        rule = [rule, '&', field, params.tagCells_rules{i,2}, num2str(params.tagCells_rules{i,3})];
    end
end

eval(['filterField = ', rule, ';']);

filterField = num2cell(filterField);

[objects.stats.(params.tagCells_name)] = filterField{:};


