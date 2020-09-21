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
function [range, handles] = checkFileRange(hObject, eventdata, handles)

range = str2num(handles.uicontrols.edit.action_imageRange.String);

switch handles.uicontrols.popupmenu.popupmenu_fileType.Value
    case 1 
        files = handles.settings.lists.files_nd2;
    case 6
        files = handles.settings.lists.files_sim;
    case 4
        files = handles.settings.lists.files_cells;
    otherwise
        files = handles.settings.lists.files_tif; 
end
if isempty(range)
    range = cellfun(@(x) isempty(x), strfind({files.name}, 'missing'));
    if numel(range) > 1
        handles.uicontrols.edit.action_imageRange.String = assembleImageRange(find(range));
    else
        handles.uicontrols.edit.action_imageRange.String = '1';
        range = 1;
    end
end

range_new = intersect(range, 1:numel(files));

if numel(range) ~= numel(range_new)
    warning('backtrace', 'off')
    warning('The image range was adapted to match the existing file list.');
    warning('backtrace', 'on')
    handles.uicontrols.edit.action_imageRange.String = assembleImageRange(range_new);
    handles = storeValues(hObject, eventdata, handles);
end

range = range_new;



