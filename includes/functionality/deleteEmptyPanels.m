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
function handles = deleteEmptyPanels(handles)

panelNames = fieldnames(handles.layout.uipanels);
validHandles = structfun(@isvalid, [handles.layout.uipanels]);
handles.layout.uipanels = rmfield(handles.layout.uipanels, panelNames(~validHandles));

panelNames = fieldnames(handles.handles_analysis.layout.uipanels);
validHandles = structfun(@isvalid, [handles.handles_analysis.layout.uipanels]);
handles.handles_analysis.layout.uipanels = rmfield(handles.handles_analysis.layout.uipanels, panelNames(~validHandles));




