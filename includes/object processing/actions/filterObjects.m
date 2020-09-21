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
function objects = filterObjects(handles, objects, params, f, silent)
if nargin < 5
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

metadata = load(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(f).name));

if isfield(metadata.data, 'minCellInt')
    value = metadata.data.minCellInt;
    value = strrep(value, ' ', '');
    ind = strfind(value, ',');
    num1 = value(2:ind-1);
    num2 = value(ind+1:end-1);
    
    num1 = str2num(num1);
    num2 = str2num(num2);
    
else
    warning('backtrace', 'off');
    fprintf('\n');
    warning('No filter range defined for for image #%d\n', f);
    warning('backtrace', 'on');
    num1 = -Inf;
    num2 = Inf;
end

filterFieldValue = get(handles.uicontrols.popupmenu.filter_parameter, 'Value');
filterFieldStr = get(handles.uicontrols.popupmenu.filter_parameter, 'String');
logScale = get(handles.uicontrols.checkbox.filterLogScale, 'Value');

filterField = filterFieldStr{filterFieldValue};

displayStatus(handles, 'filtering cells...', 'blue', 'add');
objects = filterCellsByIntensity(objects, filterField, logScale, [num1, num2]);

if ~silent
    fprintf(' - %d of %d objects passed filtering (%s is in between %.2g and %.2g)', sum(objects.goodObjects), numel(objects.goodObjects), filterField, num1, num2);
    displayTime(ticValue);
end


