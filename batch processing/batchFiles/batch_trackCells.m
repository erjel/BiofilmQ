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
cd(fileparts(which('BiofilmQ')));

range = 1:numel(folders);

handles = handles.handles_GUI;
hObject = handles.mainFig;

for i = range
    if isdir(fullfile(folders{i}))
        fprintf('Processing folder %s\n', folders{i}); 
        
        
        set(handles.uicontrols.edit.inputFolder, 'String', fullfile(folders{i}))
        
        
        BiofilmQ('pushbutton_refreshFolder_Callback', handles.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, guidata(hObject));
           
        
        handles = guidata(hObject);
        handles.uicontrols.edit.action_imageRange.String = ['1:', num2str(sum(~cellfun(@(x) ~isempty(x), strfind({handles.settings.lists.files_cells.name}, 'missing'))))];
        storeValues(hObject, eventdata, handles)
      
        
        set(handles.menuHandles.menues.menu_process_all_select_registerImages, 'Checked', 'off');
        
        
        set(handles.menuHandles.menues.menu_process_all_select_trackCells, 'Checked', 'on');
  
        
        set(handles.menuHandles.menues.menu_process_all_select_visCells, 'Checked', 'off');
        
        
        set(handles.menuHandles.menues.menu_process_all_select_cellParams, 'Checked', 'off');
        
        
        set(handles.menuHandles.menues.menu_process_all_select_masks, 'Checked', 'off');
        
        BiofilmQ('menu_process_all_Callback',handles.menuHandles.menues.menu_process_all,eventdata,guidata(hObject))      
    end
end


