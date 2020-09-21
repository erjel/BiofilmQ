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
function storeValuesPerImage(hObject, eventdata, handles)
edits = fieldnames(handles.uicontrols.edit);
for i = 1:length(edits)
    if strcmp(get(handles.uicontrols.edit.(edits{i}), 'Tag'), 'action_imageRange')...
            || strcmp(get(handles.uicontrols.edit.(edits{i}), 'Tag'), 'visCell_range')
        params.(get(handles.uicontrols.edit.(edits{i}), 'Tag')) = get(handles.uicontrols.edit.(edits{i}), 'String');
    else
        params.(get(handles.uicontrols.edit.(edits{i}), 'Tag')) = str2num(get(handles.uicontrols.edit.(edits{i}), 'String'));
        
    end
end
checkboxes = fieldnames(handles.uicontrols.checkbox);
for i = 1:length(checkboxes)
    params.(get(handles.uicontrols.checkbox.(checkboxes{i}), 'Tag')) = get(handles.uicontrols.checkbox.(checkboxes{i}), 'Value');
end
popupmenus = fieldnames(handles.uicontrols.popupmenu);
for i = 1:length(popupmenus)
    params.(get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag')) = get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Value');
end
tables = fieldnames(handles.uitables);
for i = 1:length(tables)
    params.(get(handles.uitables.(tables{i}), 'Tag')) = get(handles.uitables.(tables{i}), 'Data');
end

save(fullfile(handles.settings.directory, 'parameters.mat'), 'params');

displayStatus(handles, 'Parameters updated', 'green')


