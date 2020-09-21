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
function [channels,deconvolvedChannels] = getCurrentChannels(path)

files = dir(fullfile(path, '*.tif'));

channels = [];
deconvolvedChannels = [];
addChannel = {};
for j = 1:length(files)
    features = getFeaturesFromName(files(j).name);
    channel = features.channel;
    if isnan(channel)
        addChannel{end+1} = files(j).name;
    else
        if ~any(channels==channel) && ~any(deconvolvedChannels==channel)
            metadata = load(fullfile(path, strrep(files(j).name, '.tif', '_metadata.mat')));
            metadata = metadata.data;
            
            if isfield(metadata, 'originalChannel')
                deconvolvedChannels(end+1,1) = metadata.originalChannel;
                deconvolvedChannels(end,2) = channel;
            else
                channels = [channels, channel];
            end
        end
        
    end
end

if ~isempty(addChannel)
    if isempty(channels)
        channel = 1;
    else
        channel = max(channels)+1;
    end
    for k = 1:length(addChannel) 
        name = addChannel{k};
        
        assert(contains(name, '_frame'))
        newName = strrep(name, '_frame', sprintf('_ch%d_frame', channel));
        
        if ~exist(fullfile(path, newName), 'file')
            movefile(fullfile(path, name), fullfile(path, newName));
            movefile(fullfile(path, strrep(name, '.tif', '_metadata.mat')), fullfile(path, strrep(newName, '.tif', '_metadata.mat')));
        end
    end
    channels = [channels, channel];
end

end


