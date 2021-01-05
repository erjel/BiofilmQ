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
function [xUnit, yUnit, zUnit, cUnit] = getUnitsFromGUI(handles, statsLookup)
    unitfields = {'edit_xLabel_unit', 'edit_yLabel_unit', 'edit_zLabel_unit', 'edit_colorLabel_unit'};
    units = cell(4, 1);

    for i = 1:numel(unitfields)
        unitfield = unitfields{i};
        if ~isempty(handles.handles_analysis.uicontrols.edit.(unitfield).String)
            units{i} = handles.handles_analysis.uicontrols.edit.(unitfield).String;
        elseif ~isempty(statsLookup{i})
            [~ , units{i}] = returnUnitLabel(statsLookup{i});
        else
            units{i} = '';
        end
        handles.handles_analysis.uicontrols.edit.(unitfield).String = units{i};
    end
    
    xUnit = units{1};
    yUnit = units{2};
    zUnit = units{3};
    cUnit = units{4};
    
end

