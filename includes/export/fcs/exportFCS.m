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
function handles = exportFCS(handles, objects, params, fields, filename)
ticValue = displayTime;

fieldsSave = [];
data = [];

goodObjects = objects.goodObjects;

fields = setdiff(fields, {'Centroid', 'BoundingBox', 'Cube_CenterCoord', 'Orientation_Matrix', 'Timepoint'});


invalidProps = {};
for i = 1:numel(fields)
    if any(strcmp(fields{i}, {'ID', 'RandomNumber', 'Distance_FromSubstrate'}))
        continue;
    end
    data_temp = [objects.stats(goodObjects).(fields{i})];
    if any(data_temp < 0)
        fprintf('\nfound invalid values in field %s\n', fields{i});
        invalidProps{end + 1} = fields{i};
    end
end

if ~isempty(invalidProps)
    propStr = join(invalidProps,', ');
    msg = sprintf([
        'The properties %s contain negativ values ', ...
        'which will be set to zero during export!'], propStr{:});
    title = 'Export error';
    
    
    
    if ~isfield(handles.settings, 'showedFCSError')
        handles.settings.showedFCSError = false;
    end
    
    if handles.settings.showMsgs && ~handles.settings.showedFCSError
        uiwait(msgbox(msg, title, 'warn', 'modal'));
        handles.settings.showedFCSError = true;
    else
        warning(msg);
    end
end
    

for i = 1:numel(fields)
    switch fields{i}
        case 'ID'
            data_temp = 1:objects.NumObjects;
            data_temp = data_temp(goodObjects);
            firstEntry = 1;
        case 'RandomNumber'
            data_temp = 1000*rand(1, sum(goodObjects));
            firstEntry = 1;
        case 'Distance_FromSubstrate'
            centroids = [objects.stats.Centroid];
            centroids = centroids(3:3:end)*objects.params.scaling_dxy/1000;
            data_temp = centroids(goodObjects);
            firstEntry = 1;
        otherwise
            data_temp = [objects.stats(goodObjects).(fields{i})];
            firstEntry = objects.stats(1).(fields{i});
    end
    
    if numel(firstEntry) == 1
        fieldsSave = [fieldsSave fields(i)];
        data = [data, data_temp'];
    end
end

directory_save = fullfile(handles.settings.directory, 'data', 'fcs_output');
if ~exist(directory_save, 'dir')
    mkdir(directory_save);
end

filename = fullfile(directory_save, filename);

if exist(filename, 'file')
    fprintf('\n - deleting old file');
    delete(filename);
end


fprintf('\n - writing "%s"\n', filename);
TEXT = [];
TEXT.PnN = fieldsSave;
warning('off','backtrace')
writeFCS(filename, single(data), TEXT);
warning('on','backtrace')
fprintf('-> Done');

displayTime(ticValue);



