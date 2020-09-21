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
function handles = flagCropData(hObject, eventdata, handles, appliesToRegisteredImage)

displayStatus(handles, 'Updating crop-ranges for all images...', 'green');

for i = 1:length(handles.settings.lists.files_metadata)
    if ~mod(i-1, 10)
        updateWaitbar(handles, i/length(handles.settings.lists.files_metadata))
    end
    
    metadata = load(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name));
    data = metadata.data;
    data.cropRange_appliesToRegisteredImage = appliesToRegisteredImage;
    
    handles.settings.metadataGlobal{i}.data = data;
    save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name), 'data');
    
    
    channelData = get(handles.uicontrols.popupmenu.channel, 'String');
    if numel(channelData) > 1
        channel = channelData{get(handles.uicontrols.popupmenu.channel, 'Value')};
        ch_toProcess = find(~cellfun(@(x) strcmp(x, channel), channelData));
        for c = 1:numel(ch_toProcess)
            filename_ch = fullfile(handles.settings.directory, ...
                strrep(handles.settings.lists.files_metadata(i).name, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
            
            data = load(filename_ch);
            data = data.data;
            data.cropRange_appliesToRegisteredImage = appliesToRegisteredImage;
            save(filename_ch, 'data');
        end
        
    end
    
    guidata(hObject, handles);
    if checkCancelButton(handles)
        return;
    end
end

displayStatus(handles, 'Done', 'black', 'add');
updateWaitbar(handles, 0);


