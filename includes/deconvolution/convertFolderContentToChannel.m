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
function convertFolderContentToChannel(path)

[channels,deconvolvedChannels] = getCurrentChannels(path);
pathToDeconvolution = fullfile(path, 'deconvolved images');

files = dir(fullfile(pathToDeconvolution, '*_cmle.tif'));

for j = 1:length(files)
    features = getFeaturesFromName(files(j).name);
    channel = features.channel;
    
    if isnan(channel)
        channelNumber = 2;
    else
        
        
        
        if ~isempty(deconvolvedChannels) 
            if any(channel == deconvolvedChannels(:,1))
            index = find(channel == deconvolvedChannels(:,1), 1);
            channelNumber = deconvolvedChannels(index, 2);
            else
                channelNumber = max(channels)+1;
                channelNumber = max(channelNumber, max(deconvolvedChannels(:))+1);
                deconvolvedChannels(end+1, :) = [channel, channelNumber];
            end
        else
            channelNumber = max(channels)+1;
            deconvolvedChannels(end+1, :) = [channel, channelNumber];
        end
    end
    
    moveImageToChannel(path, files(j).name, channel, channelNumber);
    
end







end




