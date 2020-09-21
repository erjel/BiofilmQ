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
        
        
        if ~isempty(parameterFile)
            try
                copyfile(parameterFile, fullfile(folders{i}, 'parameters.mat'), 'f');
            catch
                warning('Cannot copy parameter-file');
            end
        end
        
        
        set(handles.uicontrols.edit.inputFolder, 'String', fullfile(folders{i}))
        
        
        BiofilmQ('pushbutton_refreshFolder_Callback', handles.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, guidata(hObject));
             
        
        handles = guidata(hObject);
        cropRangeRef = handles.uicontrols.edit.registrationReferenceCropping.String;
        refFrame = handles.uicontrols.edit.registrationReferenceFrame.String;
        
        
        
        BiofilmQ('pushbutton_refreshFolder_Callback', handles.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, guidata(hObject));
        
        
        handles.uicontrols.edit.registrationReferenceCropping.String = cropRangeRef;
        handles.uicontrols.edit.registrationReferenceFrame.String = refFrame;
        storeValues(hObject, eventdata, handles)
        
        
        BiofilmQ('pushbutton_action_imageRange_takeAll_Callback',handles.uicontrols.pushbutton.pushbutton_action_imageRange_takeAll,eventdata,guidata(hObject))    
        
        
        BiofilmQ('pushbutton_files_export_Callback',handles.uicontrols.pushbutton.pushbutton_files_export,eventdata,guidata(hObject)) 
        
    end
end


