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
function [xlabel, ylabel, zlabel, clabel] = getLabelsFromGUI(handles, statsLookup)
    labelfields = {'edit_xLabel', 'edit_yLabel', 'edit_zLabel', 'edit_colorLabel'};
    labels = cell(4, 1);

    for i = 1:numel(labelfields)
        labelfield = labelfields{i};
        if ~isempty(handles.handles_analysis.uicontrols.edit.(labelfield).String)
            labels{i} = handles.handles_analysis.uicontrols.edit.(labelfield).String;
        elseif ~isempty(statsLookup{i})
            labels{i} = returnUnitLabel(statsLookup{i});
        else
            labels{i} = '';
        end
        handles.handles_analysis.uicontrols.edit.(labelfield).String = labels{i};
    end
    
    xlabel = labels{1};
    ylabel = labels{2};
    zlabel = labels{3};
    clabel = labels{4};
    
end


