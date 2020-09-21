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
function handles = biofilmInfo(hObject, eventdata, handles)

biofilmData = getLoadedBiofilmFromWorkspace;
if isempty(biofilmData)
    return;
end

infoTable = {};

if numel(biofilmData.timepoints) > 1
    minInterval = min(diff(biofilmData.timepoints(2:end)));
else
    minInterval = 0;
end


if minInterval < 10
   factor = 1;
   t_label = 't [s]';
elseif minInterval < 100
    factor = 1/60;
    t_label = 't [min]';
else
    factor = 1/(60*60);
    t_label = 't [h]';
end
timepoints = biofilmData.timepoints*factor;
index = 1:numel(timepoints);

if sum(timepoints) == 0
    t_label = '#';
    timepoints = index;
end

table_overviewFields = {'Index', t_label, 'Ncells', 'Max track ID', 'Filename'};
try
    for i = 1:numel(biofilmData.data)
        if isfield(biofilmData.data(i).stats, 'Track_ID')
            infoTable(i, :) = {index(i), timepoints(i), biofilmData.data(i).NumObjects, max([biofilmData.data(i).stats.Track_ID]), biofilmData.data(i).Filename};
        else
            infoTable(i, :) = {index(i), timepoints(i), biofilmData.data(i).NumObjects, [], biofilmData.data(i).Filename};
        end
    end
end


additionalFields = [];
if isfield(biofilmData.data, 'globalMeasurements')
    
    additionalFields = cellfun(@getFieldnames, {biofilmData.data.globalMeasurements}, 'UniformOutput', false);
    additionalFields = unique(vertcat(additionalFields{:}));
    additionalFields(cellfun(@isempty, additionalFields)) = [];
    additionalFields = additionalFields;
    
    additionalFields = setdiff(additionalFields, {'Time', 'Cell_Number', 'Distance_FromSubstrate'});
    fieldsToShow = {};
    correspondingFields(1).reduced = '';
    correspondingFields(1).fields = {};
    appendices = {'_core_', '_shell_', '_mean', '_median', '_std', '_p25', '_p75', '_min', '_max'};
        
    columes_infoTable = size(infoTable,2);
    for i = 1:numel(biofilmData.data)
        for j = 1:numel(additionalFields)
            if isfield(biofilmData.data(i).globalMeasurements, additionalFields{j})
                if isstruct(biofilmData.data(i).globalMeasurements.(additionalFields{j}))
                    infoTable{i, columes_infoTable+j:columes_infoTable+j} = 'Multi-dim data';
                else
                    infoTable{i, columes_infoTable+j:columes_infoTable+j} = biofilmData.data(i).globalMeasurements.(additionalFields{j});
                    
                    if i==1
                        hasAppendix = @(x) any(strfind(additionalFields{j}, x));
                        ind = cellfun(hasAppendix, appendices);
                        if sum(ind)>0
                            app = find(ind);
                            ind = strfind(additionalFields{j}, appendices{app(1)});
                            index = find(cellfun(@(x) strcmp(x, ['[+] ', additionalFields{j}(1:ind-1)]), {correspondingFields.reduced}));
                            if isempty(index)
                                correspondingFields(end+1).reduced = ['[+] ', additionalFields{j}(1:ind-1)];
                                correspondingFields(end).fields = {['   ',additionalFields{j}]};
                            else
                                correspondingFields(index).fields = unique([correspondingFields(index).fields, {['   ',additionalFields{j}]}]);
                            end
                        else
                            correspondingFields(end+1).reduced = additionalFields{j};
                        end
                    end
                end
            else
                infoTable{i, columes_infoTable+j:columes_infoTable+j} = '';
            end
        end
    end
    
    tableHeader = cell(numel(additionalFields), 1);
    for i = 1:numel(additionalFields)
        [label, unit] = returnUnitLabel(additionalFields{i});
        unit = strrep(unit, '\mu', 'u');
        
        tableHeader{i} = [additionalFields{i}, ' ', unit];
    end
    table_overviewFields = [table_overviewFields tableHeader'];
    
else
    
end


createJavaTable(handles.java.tableAnalysis{2}, [], handles.java.tableAnalysis{1}, infoTable, table_overviewFields, false(numel(table_overviewFields), 1));


additionalFields = [{'Time', 'Cell_Number'}, additionalFields'];
fNames = cellfun(@fieldnames, {biofilmData.data.stats}, 'UniformOutput', false);
fNames = unique(vertcat(fNames{:}));
idxInd = unique([find(cellfun(@(x) ~isempty(x), strfind(fNames, '_Idx_'))), find(cellfun(@(x) ~isempty(x), strfind(fNames, 'Foci_Intensity'))), find(cellfun(@(x) ~isempty(x), strfind(fNames, 'Foci_Quality')))]);
fNames(idxInd) = [];
fNames = setdiff(fNames, {'BoundingBox', 'MinBoundBox_Cornerpoints', 'Cube_CenterCoord', 'Orientation_Matrix', 'Centroid'});

firstFields = {'Time', 'Cell_Number', 'Distance_FromSubstrate'};
set(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'String', vertcat(firstFields', sort(setdiff(fNames,firstFields))), 'Value', 1);

correspondingFields = correspondingFields(2:end);
fieldsToShow = [{'Time', 'Cell_Number'}, {correspondingFields.reduced}];
fieldsToShow = unique(fieldsToShow);
firstFields = {'Time', 'Cell_Number'};
fieldsToShow = vertcat(firstFields', sort(setdiff(fieldsToShow',firstFields)));

handles.settings.measurementFieldsAnalysis_singleCell = fNames;
handles.settings.measurementFieldsAnalysis_global = additionalFields;
handles.settings.measurementFieldsAnalysis_globalReduced = fieldsToShow;
handles.settings.measurementFieldAnalysis_correspondingFields = correspondingFields;



function fNames = getFieldnames(x)

try 
    fNames = fieldnames(x);
catch
    fNames = [];
end


