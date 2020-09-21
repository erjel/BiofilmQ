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
function objects = loadObjects(filename, fieldnames, silent)

if ~exist(filename, 'file')
    uiwait(msgbox(sprintf('Cell-file "%s" does not exist!', filename), 'Error', 'error'));
    return;
end

[~, fname] = fileparts(filename);


objects = struct;

try
    attr = checkVarnames(filename);
catch
    matObj = matfile(filename);
    fileDetails = whos(matObj);
    attr = {fileDetails.name};
end

if nargin == 1
    fieldnames = 'all';
    silent = 0;
end

if nargin == 2
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

if ~sum(strcmp(fieldnames, 'measurementFields')) && ~sum(strcmp(fieldnames, 'all'))
    try
        fieldnames = {fieldnames{:}, 'Connectivity', 'ImageSize', 'NumObjects', 'merged', 'splitted', 'goodObjects', 'measurementFields', 'params'};
    catch
        fieldnames = {fieldnames, 'Connectivity', 'ImageSize', 'NumObjects', 'merged', 'splitted', 'goodObjects', 'measurementFields', 'params'};
    end
    
end

if strcmp(fieldnames, 'all')
    fieldnames = attr;
end

if ~isempty(cell2mat(strfind(attr, 'objects')))
    
    data = load(filename, 'objects');
    objects = data.objects;
    measurementFields = fields(objects.stats);
    objects.measurementFields = measurementFields;
    save(filename, 'measurementFields', '-append');
else
    
    fieldnames_load = attr;
    
    fieldnames_load = intersect(fieldnames_load, fieldnames);
    
    
    
    
    
    
    
    
    
    fileAttr = dir(filename);
    if ~silent
        fprintf(' - loading cells [%s.mat, %u Mb]', fname, round(fileAttr.bytes/1000/1000))
    end
    if ~silent
        textprogressbar('      ');
    end
    
    for i = 1:numel(fieldnames_load)
        data = load(filename, fieldnames_load{i});
        objects.(fieldnames_load{i}) = data.(fieldnames_load{i});
        if ~silent
            textprogressbar(i/numel(fieldnames_load)*100);
        end
    end   
    

    try
        if ~sum(strcmp(fieldnames_load, 'measurementFields'))
            measurementFields = fields(objects.stats);
            objects.measurementFields = measurementFields;
            save(filename, 'measurementFields', '-append');
        else
            try
                
                measurementFieldsFile = fields(objects.stats);
                if ~strcmp([measurementFieldsFile{:}], [objects.measurementFields{:}])
                    measurementFields = measurementFieldsFile;
                    save(filename, 'measurementFields', '-append');
                end
            end 
        end
    end

end
if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
    displayTime(ticValue);
end


