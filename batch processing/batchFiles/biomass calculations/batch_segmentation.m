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
channelsToSegment = [2 3];
useManualThreshold = false;
manualThreshold = [50 100];

cd(fileparts(which('BiofilmQ')));

range = 1:numel(folders);

handles = handles.handles_GUI;
hObject = handles.mainFig;

for i = range
    if isdir(fullfile(folders{i}))
        fprintf('Processing folder %s\n', folders{i});
        
        
        if ~isempty(parameterFile)
            try
                copyfile(parameterFile, fullfile(folders{i}, 'parameters.mat'), 'f');
            catch
                warning('Cannot copy parameter-file');
            end
        end
        
        
        set(handles.uicontrols.edit.inputFolder, 'String', folders{i})
        
        
        BiofilmQ('pushbutton_refreshFolder_Callback', handles.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, guidata(hObject));
        
        
        BiofilmQ('pushbutton_action_imageRange_takeAll_Callback',handles.uicontrols.pushbutton.pushbutton_action_imageRange_takeAll,eventdata,guidata(hObject))
        
        for ch = 1:numel(channelsToSegment)
            
            set(handles.uicontrols.popupmenu.channel, 'Value', channelsToSegment(ch));
            BiofilmQ('channel_Callback',handles.uicontrols.popupmenu.channel,eventdata,guidata(hObject))
            
            if useManualThreshold
                
                set(handles.uicontrols.popupmenu.thresholdingMethod, 'Value', 5);
                BiofilmQ('thresholdingMethod_Callback',handles.uicontrols.popupmenu.thresholdingMethod,eventdata,guidata(hObject))
                
                
                set(handles.uicontrols.edit.manualThreshold, 'string', num2str(manualThreshold(ch)));
                BiofilmQ('pushbutton_ApplyTHAll_Callback',handles.uicontrols.pushbutton.pushbutton_ApplyTHAll,eventdata,guidata(hObject))
            end
            
            
            set(handles.menuHandles.menues.menu_process_all_select_registerImages, 'Checked', 'off');
            
            
            set(handles.menuHandles.menues.menu_process_all_select_trackCells, 'Checked', 'off');
            
            
            set(handles.menuHandles.menues.menu_process_all_select_visCells, 'Checked', 'off');
            
            
            set(handles.menuHandles.menues.menu_process_all_select_cellParams, 'Checked', 'off');
            
            
            set(handles.menuHandles.menues.menu_process_all_select_masks, 'Checked', 'on');
            
            BiofilmQ('menu_process_all_Callback',handles.menuHandles.menues.menu_process_all,eventdata,guidata(hObject))
        end
    end
end


