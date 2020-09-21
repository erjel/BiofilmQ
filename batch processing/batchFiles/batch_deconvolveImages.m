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
batch_output_dir = 'G:\batch_decon';
input_folder = handles.edit_inputFolder.String;

if ~exist(batch_output_dir, 'dir')
    mkdir(batch_output_dir);
end

cd(fileparts(which('BiofilmQ')));

range = 1:numel(folders);

applyRange = 0;

handles = handles.handles_GUI;
hObject = handles.mainFig;

channelInfo = struct.empty;
for i = range
    if isfolder(fullfile(folders{i}))
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
        
        if ~applyRange
            
            BiofilmQ('pushbutton_action_imageRange_takeAll_Callback',handles.uicontrols.pushbutton.pushbutton_action_imageRange_takeAll,eventdata,guidata(hObject));
        end
        
        parameters = load(fullfile(folders{i}, 'parameters.mat'));
        params = parameters.params;
        
        channelInfo(end+1).folder = folders{i};
        [channels, ~] = getCurrentChannels(folders{i});
        deconvolvedChannels = [channels', (1:length(channels))' + max(channels)];
        channelInfo(end).deconvolvedChannels = deconvolvedChannels;
        
        handles = analyzeDirectory(hObject, eventdata, handles);
        
        
        prepareImagesForDeconvolution(handles, params);
        
    end
end

fileName = batch_createOverallHugensFile(input_folder, batch_output_dir, params, folders);
moveDeconvolvedFiles(batch_output_dir, channelInfo);

for i = range
    if isdir(fullfile(folders{i}))
        fprintf('Post-Processing folder %s\n', folders{i}); 
        removeFilesAfterDeconvolution(fullfile(folders{i}, 'deconvolved images'));
    end
end


