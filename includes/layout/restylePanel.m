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
function handles = restylePanel(handles, uipanel_handle, panelColor, parent_handle, pos)

if nargin < 3
    panelColor = [0.7490 0.902 1];
end

if nargin < 4
    parent_handle = uipanel_handle.Parent;
end

uipanel_handle.Units = 'normalized';

if nargin < 5
    pos = uipanel_handle.Position;
end

boxPanelName = strrep(uipanel_handle.Tag, 'uipanel', 'boxpanel');
handles.layout.boxPanels.(boxPanelName) = uix.BoxPanel('Parent', parent_handle, 'Position', pos,...
    'Title', uipanel_handle.Title, 'Units', 'normalized', 'TitleColor', panelColor, 'ForegroundColor', [0 0 0]);

uipanel_handle.Parent = handles.layout.boxPanels.(boxPanelName);
uipanel_handle.Title = [];
uipanel_handle.BorderType = 'none';

handles.layout.boxPanels.(boxPanelName).Units = 'characters';


