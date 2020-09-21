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
function handles = assignContextMenu(handles, buttonHandles, parent)
buttonNames = get(buttonHandles, 'Tag');
if ~iscell(buttonNames)
    buttonNames = {buttonNames};
end

for j = 1:size(buttonNames, 1)
    contextMenuName = ['contextMenu_', buttonNames{j}];
    if ~isempty(findobj(parent, 'Tag', buttonNames{j})) && ~isempty(findobj(handles.mainWindow, 'Tag', contextMenuName))
        set(findobj(parent, 'Tag', buttonNames{j}),...
            'UIContextMenu', findobj(handles.mainWindow, 'Tag', contextMenuName));
    end
end



