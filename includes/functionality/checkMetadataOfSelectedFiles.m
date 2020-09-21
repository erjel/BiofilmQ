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
function handles = checkMetadataOfSelectedFiles(hObject, eventdata, handles)
range = str2num(handles.uicontrols.edit.action_imageRange.String);

if handles.uicontrols.popupmenu.popupmenu_fileType.Value > 1 && handles.uicontrols.popupmenu.popupmenu_fileType.Value < 5
    if handles.uicontrols.checkbox.imageRegistration.Value
        
        metadata = handles.settings.metadataGlobal;
        params = load(fullfile(handles.settings.directory, 'parameters.mat'));
        params = params.params;
        registeredFiles = cell2mat(params.files(:,5));
        
        if ~isempty(setdiff(range, find(registeredFiles)))
            if ~isempty(find(registeredFiles))
                message = sprintf( ...
                    ['Image registration was selected.',  ...
                    ' But only files [%s] are registered!', ...
                    ' Please adapt the image range or register the non-aligned images first!', ...
                    ' For now, image registration is disabled.'], ...
                    assembleImageRange(find(registeredFiles)));
            else
                message = ['Image registration was selected.' ...
                    ' But images are not registered!' ...
                    ' Please adapt the image range or register the non-aligned images first!' ...
                    ' For now, image registration is disabled.'];
            end
            
            if handles.settings.showMsgs
                uiwait(msgbox(message, 'Error', 'error', 'modal'));
            else
                warning(message);
            end
            
            handles.uicontrols.checkbox.imageRegistration.Value = false;
            handles.uicontrols.checkbox.displayAlignedImage.Value = false;
            return;
        end
        
        registered = 1;
        for j = range
            try
                cropRangeRegistered = metadata{j}.data.cropRange_appliesToRegisteredImage;
                isCropped = ~isempty(metadata{j}.data.cropRange);
                if ~cropRangeRegistered && isCropped
                    registered = 0;
                    break;
                end
            end
        end
        
        if ~registered
            answer = questdlg('Previous cropping information refers to un-registered data. Please be aware that the cropping rectangle is repositioned if you continue. You can also decide to reset the existing crop-data. Then you will have to repeat the cropping.', 'Please note', 'Continue', 'Remove existing crop-data', 'Cancel', 'Cancel');
            switch answer
                case 'Continue'
                    
                    
                case 'Remove existing crop-data'
                    set(handles.uicontrols.edit.cropRange, 'String', '');
                    handles = BiofilmQ('pushbutton_applyCropAll_Callback', hObject,eventdata,handles);
                case 'Cancel'
                    handles.uicontrols.checkbox.imageRegistration.Value = 0;
                    return;
            end
        end
        
    else
        metadata = handles.settings.metadataGlobal;
        
        registered = 0;
        for j = range
            try
                cropRangeRegistered = metadata{j}.data.cropRange_appliesToRegisteredImage;
                isCropped = ~isempty(metadata{j}.data.cropRange);
                if cropRangeRegistered && isCropped
                    registered = 1;
                    break;
                end
            end
        end
        
        if registered
            answer = questdlg('Previous cropping information refers to registered data. Please be aware that the cropping rectangle is repositioned if you continue. You can also decide to reset the existing crop-data. Then you will have to repeat the cropping.', 'Please note', 'Continue', 'Remove existing crop-data', 'Cancel', 'Cancel');
            switch answer
                case 'Continue'
                    
                    
                case 'Remove existing crop-data'
                    set(handles.uicontrols.edit.cropRange, 'String', '');
                    handles = BiofilmQ('pushbutton_applyCropAll_Callback', hObject,eventdata,handles);
                case 'Cancel'
                    handles.uicontrols.checkbox.imageRegistration.Value = 1;
                    return;
            end
        end
    end
end


