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
function moveDeconvolvedFiles(input_folder, varargin)

m = msgbox({strcat('Please start Huygens and run the batch script created in ',input_folder , '. Click ok ONLY if deconvolution has finished!')}, 'Deconvolution in progress', 'error');
ticValue = displayTime;
while isvalid(m)
    files = dir(fullfile(input_folder, '*_cmle.tif'));
    
    try
        
        fid = fopen(fullfile(files(1).folder, [files(1).name(1:end-4), '.hgsb']));
        data = textscan(fid,'%s', 'Delimiter', '\n');
        fclose(fid);

        idx1 = strfind(data{1}{8}, 'path {');
        idx2 = strfind(data{1}{8}(idx1:end), '}');
        parentDir = fileparts(data{1}{8}(idx1+6:idx1+idx2(1)-2));

        movefile(fullfile(files(1).folder, files(1).name), fullfile(parentDir, files(1).name));
        delete(fullfile(files(1).folder, [files(1).name(1:end-4), '.hgsb']));
        
        fprintf('File "%s" moved to "%s"', files(1).name, parentDir)
        displayTime(ticValue);
        ticValue = displayTime;
        
        if nargin==2
           channelInfo = varargin{1};
           
           parentDir = strrep(parentDir, '/', '\');
           parentDir = strrep(parentDir, '\deconvolved images', '');
           findDir = @(x) strcmp(x, parentDir);
           currentFolder = cellfun(findDir, {channelInfo.folder});
           deconvolvedChannels = channelInfo(find(currentFolder,1)).deconvolvedChannels;
           features = getFeaturesFromName(files(1).name);
           channel = features.channel;
           newChannel = deconvolvedChannels(find(deconvolvedChannels==channel,1),2);
           
           p = gcp();
           parfeval(p, @moveImageToChannel, 0, parentDir, files(1).name, channel, newChannel);
        end
        
        
    end
    if isempty(files)
        pause(5)
    end
end


