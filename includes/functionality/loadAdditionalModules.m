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
function handles = loadAdditionalModules(handles)
if isdeployed
    addModules = dir(fullfile(handles.settings.pathGUI, '..', 'includes', 'additional modules'));
else
    addModules = dir(fullfile(handles.settings.pathGUI, 'includes', 'additional modules'));
end

addModules = addModules(setdiff(find([addModules.isdir]), [1, 2]));

fprintf('\n');
for i = 1:numel(addModules)
    fprintf('Enabling additional module "%s"\n', addModules(i).name);
    eval(sprintf('handles = enable_%s(handles);', strrep(addModules(i).name, ' ', '_')));
end


