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
function handles = storeValues(hObject, eventdata, handles, perFile, silent, storeInHandles)

if nargin == 3
    perFile = 0;
    silent = 0;
end

if nargin < 5
    silent = 0;
end

if nargin < 6
    storeInHandles = 0;
end


if isfield(handles, 'settings')
    if ~perFile
        edits = fieldnames(handles.uicontrols.edit);
        for i = 1:length(edits)
            try
            fieldvalue = get(handles.uicontrols.edit.(edits{i}), 'String');
            catch err
                fprintf('handles.uicontrols.edit.%s\n', edits{i});
                rethrow(err);
            end
            if isempty(str2num(fieldvalue)) ...
                    || any(strcmp(get(handles.uicontrols.edit.(edits{i}), 'Tag'), ...
                        ... 
                            {'action_imageRange', ...
                            'visCell_range', ...
                            'minCellInt'}))
                params.(get(handles.uicontrols.edit.(edits{i}), 'Tag')) = fieldvalue;
            else
                params.(get(handles.uicontrols.edit.(edits{i}), 'Tag')) = str2num(fieldvalue);
            end
        end
        checkboxes = fieldnames(handles.uicontrols.checkbox);
        for i = 1:length(checkboxes)
            try
                params.(get(handles.uicontrols.checkbox.(checkboxes{i}), 'Tag')) = get(handles.uicontrols.checkbox.(checkboxes{i}), 'Value');
            catch err
                fprintf('handles.uicontrols.checkbox.%s\n', (checkboxes{i}));
                rethrow(err)
            end
        end
        popupmenus = fieldnames(handles.uicontrols.popupmenu);
        for i = 1:length(popupmenus)
            try
                params.(get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag')) = get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Value');
            catch err
                fprintf('handles.uicontrols.popupmenu.%s\n', popupmenus{i});
                rethrow(err)
            end
        end
        tables = fieldnames(handles.uitables);
        for i = 1:length(tables)
            try
                params.(get(handles.uitables.(tables{i}), 'Tag')) = get(handles.uitables.(tables{i}), 'Data');
            catch err
                if ~(strcmp(err.message, 'Invalid or deleted object.')&& strcmp(tables{i},'importResults'))
                    warning('backtrace', 'off')
                    warning('Table "%s": %s', tables{i}, err.message);
                    warning('backtrace', 'on')
                end
            end
        end
        
        params = orderfields(params);
        
        
        params.tableData = handles.tableData;
        
        
        if storeInHandles
            handles.settings.defaultParams = params;
        else
            save(fullfile(handles.settings.directory, 'parameters.mat'), 'params');
        end
      
        if ~silent; displayStatus(handles, 'Parameters updated', 'green'); end
    else
        I_base = str2num(get(handles.uicontrols.edit.I_base, 'String'));
        manualThreshold = str2num(get(handles.uicontrols.edit.manualThreshold, 'String'));
        cropRange = str2num(get(handles.uicontrols.edit.cropRange, 'String'));
        cropRange_appliesToRegisteredImage = get(handles.uicontrols.checkbox.imageRegistration, 'Value');
        cropRangeInterpolated = get(handles.uicontrols.checkbox.cropRangeInterpolated, 'Value');
        minCellInt = get(handles.uicontrols.edit.minCellInt, 'String');
        scaling_dxy = str2num(get(handles.uicontrols.edit.scaling_dxy, 'String'));
        scaling_dz = str2num(get(handles.uicontrols.edit.scaling_dz, 'String'));
        
        metadata = load(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(perFile).name));
        data = metadata.data;
        data.I_base = I_base;
        data.cropRange = cropRange;
        data.cropRange_appliesToRegisteredImage = cropRange_appliesToRegisteredImage;
        data.cropRangeInterpolated = cropRangeInterpolated;
        data.minCellInt = minCellInt;
        data.manualThreshold = manualThreshold;
        data.scaling.dxy = scaling_dxy/1000;
        data.scaling.dz = scaling_dz/1000;
        
        save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(perFile).name), 'data');
        handles.settings.metadataGlobal{perFile}.data = data;
        
        if ~silent; displayStatus(handles, ['Parameters in file "', handles.settings.lists.files_metadata(perFile).name,'" updated'], 'green'); end
        
        
        channelData = get(handles.uicontrols.popupmenu.channel, 'String');
        if numel(channelData) > 1
            channel = channelData{get(handles.uicontrols.popupmenu.channel, 'Value')};
            ch_toProcess = find(~cellfun(@(x) strcmp(x, channel), channelData));
            for c = 1:numel(ch_toProcess)
                try
                    filename_ch = fullfile(handles.settings.directory, ...
                        strrep(handles.settings.lists.files_metadata(perFile).name, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
                    
                    data = load(filename_ch);
                    data = data.data;
                    data.cropRange = cropRange;
                    data.cropRange_appliesToRegisteredImage = cropRange_appliesToRegisteredImage;
                    data.cropRangeInterpolated = cropRangeInterpolated;
                    
                    
                    data.scaling.dxy = scaling_dxy/1000;
                    data.scaling.dz = scaling_dz/1000;
                    
                    save(filename_ch, 'data');
                end
            end
            
        end
        
        guidata(hObject, handles);
        
    end
else
    disp('Please specify a working directory first to save changes.');
    displayStatus(handles, 'Please specify a working directory first to save changes.', 'red');
end


