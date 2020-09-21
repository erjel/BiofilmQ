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
function processAll(hObject, eventdata, handles)

if strcmp(get(handles.menuHandles.menues.menu_process_batch_allFolders, 'Checked'), 'on')
    
    inputFolder = get(handles.uicontrols.edit.inputFolder, 'String');
    folders = dir(fileparts(inputFolder));
    folders = folders([folders.isdir]);
    folders = folders(3:end);
    [~, ind] = sort_nat({folders.name});
    folders = folders(ind);
    
    answer = questdlg(['Continue processing the following folders?', '', 'Note: the settings associated with each individual folder will be used. If no settings are specified, the last used settings will be applied.', '', cellfun(@(x) ['  "', x, '"'], {folders.name}, 'UniformOutput', false)],...
        'Batch processing', ...
        'Continue','Cancel','Continue');
    
    switch answer
        case 'Continue'
            
        case 'Cancel'
            return;
    end
    
    inputFolder_parent = fileparts(get(handles.uicontrols.edit.inputFolder, 'String'));
    
    folders = cellfun(@(x, y) fullfile(x, y), repmat({inputFolder_parent}, 1, numel(folders)), {folders.name}, 'UniformOutput', false);
else
    folders = {get(handles.uicontrols.edit.inputFolder, 'String')};
end

for i = 1:numel(folders)
    if strcmp(get(handles.menuHandles.menues.menu_process_batch_allFolders, 'Checked'), 'on')
        
        set(handles.uicontrols.edit.inputFolder, 'String', folders{i})
        
        
        BiofilmQ('pushbutton_refreshFolder_Callback', handles.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, guidata(hObject));
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_registerImages, 'Checked'), 'on')
        BiofilmQ('pushbutton_registerImages_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_masks , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_createMasks_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_cellParams , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_calculateCellParameters_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_trackCells , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_trackCells_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_visCells , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_visualize_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_exportFCS , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_exportToFCS_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_exportCSV , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_exportToCSV_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
end


